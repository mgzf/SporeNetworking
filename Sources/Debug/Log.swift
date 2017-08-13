//
//  Log.swift
//  SporeExample
//
//  Created by luhao on 2017/7/31.
//  Copyright © 2017年 luhao. All rights reserved.
//

import Foundation

extension Request {
    
    public var debugDescription: String {
        return cURLRepresentation()
    }
    
    func cURLRepresentation() -> String {
        
        guard let request: URLRequest = try? self.buildURLRequest(), let url = request.url else {
            return "$ curl command could not be created"
        }
        
        var components = ["$ curl -v"]
        
        if let httpMethod = request.httpMethod, httpMethod != "GET" {
            components.append("-X \(httpMethod)")
        }
        
        var headers: [AnyHashable: Any] = [:]
        
        if let headerFields = request.allHTTPHeaderFields {
            for (field, value) in headerFields where field != "Cookie" {
                headers[field] = value
            }
        }
        
        for (field, value) in headers {
            components.append("-H \"\(field): \(value)\"")
        }
        
        if let httpBodyData = request.httpBody, let httpBody = String(data: httpBodyData, encoding: .utf8) {
            var escapedBody = httpBody.replacingOccurrences(of: "\\\"", with: "\\\\\"")
            escapedBody = escapedBody.replacingOccurrences(of: "\"", with: "\\\"")
            
            components.append("-d \"\(escapedBody)\"")
        }
        
        components.append("\"\(url.absoluteString)\"")
        
        return components.joined(separator: " \\\n\t")
    }
}
