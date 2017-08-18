import Foundation
import Result

private var taskRequestKey: Void?

open class Session {
    
    // Adapter that send request
    // 真正网络请求的发起由 Adapter 发起, 具体实现由业务层决定
    public let adapter: SessionAdapter // AF or AL
    
    // Callback Queue, default is Main Queue
    public let callbackQueue: CallbackQueue
    
    public init(adapter: SessionAdapter, callbackQueue: CallbackQueue = .main) {
        self.adapter = adapter
        self.callbackQueue = callbackQueue
    }
    
    /// Returns a default `Session`. A global constant `APIKit` is a shortcut of `Session.default`.
    open static let `default` = Session()
    
    // Shared session for class methods
    private convenience init() {
        let configuration = URLSessionConfiguration.default
        let adapter = URLSessionAdapter(configuration: configuration)
        self.init(adapter: adapter)
    }
    
    @discardableResult
    open func send<Request: SporeNetworking.Request>(_ request: Request, callbackQueue: CallbackQueue? = nil, handler: @escaping (Result<Request.Response, SessionTaskError>) -> Void = { _ in }) -> SessionTask? {
        
        let callbackQueue = callbackQueue ?? self.callbackQueue
        
        let urlRequest: URLRequest
        do {
            urlRequest = try request.buildURLRequest()
        } catch {
            callbackQueue.execute {
                let e = SessionTaskError.requestError(error)
                request.handle(error: e)
                handler(Result.failure(e))
            }
            return nil
        }
        
        if request.isMock {
            
            let result: Result<Request.Response, SessionTaskError>
            
            let (data, urlResponse, error): (Data?, HTTPURLResponse, Error?) = request.generateData()
            
            switch (data, urlResponse, error) {
            case (_, _, let error?):
                result = .failure(.connectionError(error))
            case (let data?, let urlResponse, _):
                do {
                    result = .success(try request.parse(data: data as Data, urlResponse: urlResponse))
                } catch {
                    result = .failure(.responseError(error))
                }
            default:
                result = .failure(.responseError(ResponseError.nonHTTPURLResponse(urlResponse)))
            }
            
            callbackQueue.execute {
                switch result {
                case .failure(let e):
                    request.handle(error: e)
                default: break
                }
                handler(result)
            }
            
            return nil
        } else {
            let task: SessionTask = adapter.createTask(with: urlRequest) {
                (data, urlResponse, error) -> Void in
                
                let result: Result<Request.Response, SessionTaskError>
                
                switch (data, urlResponse, error) {
                case (_, _, let error?):
                    result = .failure(.connectionError(error))
                case (let data?, let urlResponse as HTTPURLResponse, _):
                    do {
                        result = .success(try request.parse(data: data as Data, urlResponse: urlResponse))
                    } catch {
                        result = .failure(.responseError(error))
                    }
                default:
                    result = .failure(.responseError(ResponseError.nonHTTPURLResponse(urlResponse)))
                }
                
                callbackQueue.execute {
                    switch result {
                    case .failure(let e):
                        request.handle(error: e)
                    default: break
                    }
                    handler(result)
                }
            }
            
            bindSessinTask(task, withRequest: request)
            task.resume()
            
            return task
        }
    }
    
    open func cancelRequests<Request: SporeNetworking.Request>(with requestTyle: Request.Type, passingTest test: @escaping (Request) -> Bool = { _ in true }) -> Void {
        
        adapter.getTasks { [weak self] (sessionTaskList) in
            sessionTaskList
                .filter { (task) -> Bool in
                    if let request = self?.getRequest(for: task) as Request? {
                        return test(request)
                    } else {
                        return false
                    }
                }
                .forEach { $0.cancel() }
        }
    }
    
    private func bindSessinTask<Request: SporeNetworking.Request>(_ sessionTask: SessionTask, withRequest request: Request) {
        objc_setAssociatedObject(sessionTask, &taskRequestKey, request, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func getRequest<Request: SporeNetworking.Request>(for sessionTask: SessionTask) -> Request? {
        return objc_getAssociatedObject(sessionTask, &taskRequestKey) as? Request
    }
    
    open func multipleSend<Request: SporeNetworking.Request>(_ requests: Request..., callbackQueue: CallbackQueue? = nil, handle: @escaping (Result<[Any?], [Any?]>) -> Void ) -> [SessionTask?] {
        
        let callbackQueue: CallbackQueue = callbackQueue ?? self.callbackQueue
        
        let group: DispatchGroup = DispatchGroup.init()
        
        var models: [Any?] = Array.init(repeating: nil, count: requests.count)
        var errors: [Error?] = Array.init(repeating: nil, count: requests.count)
        var sessionTasks: [SessionTask?] = Array.init(repeating: nil, count: requests.count)
        
        var allSuccess: Bool = true
        
        for i in 0..<requests.count {
            
            group.enter()
            let request: Request = requests[i]
            
            let index: Int = i
            let session = self.send(request, callbackQueue: callbackQueue, handler: {
                (result: Result<Request.Response, SessionTaskError>) in
                switch result {
                case .success(let resultModel):
                    models.replaceSubrange(index..<index+1, with: [resultModel])
                case .failure(let sessionError):
                    allSuccess = false
                    errors.replaceSubrange(index..<index+1, with: [sessionError])
                }
                group.leave()
            })
            
            sessionTasks.append(session)
        }
        
        group.notify(queue: DispatchQueue.main) { 
            callbackQueue.execute {
                if allSuccess {
                    handle(.success(models))
                } else {
                    handle(.failure(errors))
                }
            }
        }
        
        return sessionTasks
    }
}

extension Array: Error {}

// MARK: - Default SporeNetworking instance

public let Spore = Session.default
