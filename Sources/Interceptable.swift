//
//  ErrorHandleable.swift
//  APIKit
//
//  Created by Hanguang on 2017/8/5.
//  Copyright © 2017年 Yosuke Ishikawa. All rights reserved.
//

import Foundation

public protocol Interceptable {
    /// Intercepts `URLRequest` which is created by `Request.buildURLRequest()`. If an error is
    /// thrown in this method, the result of `APIKit.send()` turns `.failure(.requestError(error))`.
    /// - Throws: `Error`
    /// 验证此次请求的 URLRequest 是否合法
    func verification(request: URLRequest) throws -> URLRequest
    
    /// Intercepts response `Any` and `HTTPURLResponse`. If an error is thrown in this method,
    /// the result of `Session.send()` turns `.failure(.responseError(error))`.
    /// The default implementation of this method is provided to throw `RequestError.unacceptableStatusCode`
    /// if the HTTP status code is not in `200..<300`.
    /// - Throws: `Error`
    func process(parsedResult: Any, urlResponse: HTTPURLResponse) throws -> Any
}

public extension Interceptable {
    func verification(request: URLRequest) throws -> URLRequest {
        print("Origin: \(#function)")
        return request
    }
    
    func process(parsedResult: Any, urlResponse: HTTPURLResponse) throws -> Any {
        print("Origin: \(#function)")
        guard 200..<300 ~= urlResponse.statusCode else {
            throw ResponseError.unacceptableStatusCode(urlResponse.statusCode)
        }
        return parsedResult
    }
}
