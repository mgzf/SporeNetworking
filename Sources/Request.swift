import Foundation

public protocol Request: CustomDebugStringConvertible, Interceptable, RequestSerializable, ErrorHandleable, Mocked {
    
    associatedtype Response
    
    /// The convenience property for `queryParameters` and `bodyParameters`. If the implementation of
    /// `queryParameters` and `bodyParameters` are not provided, the values for them will be computed
    /// from this property depending on `method`.
    var parameters: Any? { get }
    
    /// The actual parameters for the URL query. The values of this property will be escaped using `URLEncodedSerialization`.
    /// If this property is not implemented and `method.prefersQueryParameter` is `true`, the value of this property
    /// will be computed from `parameters`.
    var queryParameters: [String: Any]? { get }
    
    /// The actual parameters for the HTTP body. If this property is not implemented and `method.prefersQueryParameter` is `false`,
    /// the value of this property will be computed from `parameters` using `JSONBodyParameters`.
    var bodyParameters: BodyParameters? { get }
    
    // The base URL.
    var baseURL: URL { get }
    
    // The HTTP request method.
    var method: HTTPMethod { get }
    
    // The path URL component.
    var path: String { get }
    
    var headerFields: [String: String] { get }
    
    // 解析此请求服务器返回的数据
    var dataParser: DataParser { get }
    
    /// Build `Response` instance from raw response object. This method is called after
    /// `process(parsedResult:urlResponse:)` if it does not throw any error.
    /// - Throws: `Error`
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response
}

public extension Request {
    
    var method: HTTPMethod {
        return .post
    }
    
    var dataParser: DataParser {
        return JSONDataParser(readingOptions: [])
    }
    
    public var parameters: Any? {
        return nil
    }
    
    public var queryParameters: [String: Any]? {
        guard let parameters = parameters as? [String: Any], method.prefersQueryParameters else {
            return nil
        }
        
        return parameters
    }
    
    public var bodyParameters: BodyParameters? {
        guard let parameters = parameters, !method.prefersQueryParameters else {
            return nil
        }
        
        return JSONBodyParameters(JSONObject: parameters)
    }
    
    // 该次请求返回以后解析数据
    public func parse(data: Data, urlResponse: HTTPURLResponse) throws -> Response {
        let parsedObject = try dataParser.parse(data: data)
        let processResult = try process(parsedResult: parsedObject, urlResponse: urlResponse)
        return try response(from: processResult, urlResponse: urlResponse)
    }
}

