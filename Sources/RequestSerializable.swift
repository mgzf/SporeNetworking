//
//  RequestSerializable.swift
//  APIKit
//
//  Created by Hanguang on 2017/8/4.
//  Copyright © 2017年 Yosuke Ishikawa. All rights reserved.
//

import Foundation

public protocol RequestSerializable {
    
    /// joining together baseURL and path
    ///
    /// - Returns: URL
    /// - Throws: RequestError
    func generateURL() -> URL
    
    /// Builds `URLRequest` from `Request`.
    /// - Throws: `RequestError`, `Error`
    func buildURLRequest(encoding: URLEncoding) throws -> URLRequest
}

public extension RequestSerializable where Self: SporeNetworking.Request {
    
    func generateURL() -> URL {
        let url = path.isEmpty ? baseURL : baseURL.appendingPathComponent(path)
        return url
    }
    
    func buildURLRequest(encoding: URLEncoding = URLEncoding.default) throws -> URLRequest {
        
        let url: URL = generateURL()
        
        guard var compnents = URLComponents.init(url: url, resolvingAgainstBaseURL: true) else {
            throw RequestError.invalidBaseURL(baseURL)
        }
        
        var urlRequest: URLRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = method.rawValue
        
        urlRequest.setValue(dataParser.contentType, forHTTPHeaderField: "Accept")
        
        if let queryParameters = queryParameters, !queryParameters.isEmpty {
            let queryString: String = (compnents.percentEncodedQuery.map{ $0 + "&" } ?? "") + encoding.query(from: queryParameters)
            compnents.percentEncodedQuery = queryString
        }
        
        if let bodyParameters = bodyParameters {
            urlRequest.setValue(bodyParameters.contentType, forHTTPHeaderField: "Content-Type")
            
            switch try bodyParameters.buildEntity() {
            case .data(let data):
                urlRequest.httpBody = data
                
            case .inputStream(let inputStream):
                urlRequest.httpBodyStream = inputStream
            }
        }
        
        urlRequest.url = compnents.url
        headerFields.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        return (try intercept(urlRequest: urlRequest) as URLRequest)
    }
}
