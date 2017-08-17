//
//  TestRequest.swift
//  SporeExample
//
//  Created by luhao on 2017/8/1.
//  Copyright © 2017年 luhao. All rights reserved.
//

import Foundation
import SporeNetworking

struct TestRequest: Request {
    
    var isMock: Bool = false

    
    var absoluteURL: URL? {
        let urlRequest = try? buildURLRequest()
        return urlRequest?.url
    }
    
    // MARK: Request
    typealias Response = [String : Any]
    
    init(baseURL: String = "https://example.com", path: String = "/", method: HTTPMethod = .get, parameters: Any? = [:], headerFields: [String: String] = [:], interceptURLRequest: @escaping (URLRequest) throws -> URLRequest = { $0 }) {
        self.baseURL = URL(string: baseURL)!
        self.path = path
        self.method = method
        self.parameters = parameters
        self.headerFields = headerFields
        self.interceptURLRequest = interceptURLRequest
    }
    
    let baseURL: URL
    let method: HTTPMethod
    let path: String
    let parameters: Any?
    var headerFields: [String: String]
    let dataParser: DataParser = JSONDataParser(readingOptions: [])
    let interceptURLRequest: (URLRequest) throws -> URLRequest

    
    func intercept(urlRequest: URLRequest) throws -> URLRequest {
        return try interceptURLRequest(urlRequest)
    }
    
    func process(parsedResult: Any, urlResponse: HTTPURLResponse) throws -> Any {
        if urlResponse.statusCode == 400 {
            throw ResponseError.unacceptableStatusCode(400)
        }
        return parsedResult
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard let responseDic = object as? [String : Any] else {
            throw SessionTaskError.responseError(TestError.someError)
        }
        return responseDic
    }
}

enum TestError: Error {
    case someError
}
