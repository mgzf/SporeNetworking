//
//  SporeNetworkingConfig.swift
//  SporeExample
//
//  Created by luhao on 2017/7/30.
//  Copyright © 2017年 luhao. All rights reserved.
//

import Foundation
import SporeNetworking

// 实现协议: Request

protocol MogoAPIRequest: Request {
    func contentParameters() -> [String : Any]
}

extension MogoAPIRequest {
    
    var baseURL: URL {
        return NetworkConfig.baseURL
    }
    
    var headerFields: [String : String] {
        return ["user-agent": NetworkConfig.userAgent,
                "source-type": "1",
                "accept-language": "en-US;q=1, zh-Hans-US;q=0.9, ja-JP;q=0.8",
                "__btg_request_identify_uuid": NetworkConfig.identifyUUID,
                "cache-control": "no-cache"
        ]
    }
    
    //?_from=4.0.0
    var queryParameters: [String: Any]? {
        return ["_from": "4.0.0"]
    }
    
    var parameters: Any? {
        let content: [String : Any] = contentParameters()
        return [
            "head": [
                "os": "iOS",
                "appVersion": NetworkConfig.appVersion,
                "channel": NetworkConfig.channel,
                "osVersion": NetworkConfig.osVersion,
                "model": NetworkConfig.modelType,
                "uuid": NetworkConfig.uuid,
                "regId": NetworkConfig.regID,
                "key": NetworkConfig.keyString
            ],
            "para": content
        ]
    }
    
    // 返回的数据经过 DataParse 解析之后, 做进一步的处理
    func process(parsedResult: Any, urlResponse: HTTPURLResponse) throws -> Any{
        
        guard let json = parsedResult as? [String : Any] else {
            throw MogoError.ResponseError.notJSON
        }
        
        guard let head = json["head"] as? [String : Any] else {
            throw MogoError.ResponseError.incompleteJSON(json)
        }
        
        guard let statusStr = head["code"] as? String else {
            throw MogoError.ResponseError.incompleteJSON(json)
        }
        
        guard let status = Int(statusStr) else {
            throw MogoError.ResponseError.incompleteJSON(json)
        }
        
        switch status {
        case 10000:
            print("\(status)")
        default:
            throw MogoError.ResponseError.incompleteJSON(json)
        }
        
        if let msg = head["msg"] as? String {
            print("\(msg)")
        }
        
        guard let body = json["body"] as? [String : Any] else {
            throw MogoError.ResponseError.incompleteJSON(json)
        }
        
        guard let contentJSON = body["content"] as? [String : Any] else {
            throw MogoError.ResponseError.incompleteJSON(json)
        }
        
        return MogoResponse.init(statusCode: status, contentJSON: contentJSON, urlResponse: urlResponse)
    }
}


// 网络请求的配置
struct NetworkConfig {
    
    static var baseURL: URL {
        return URL.init(string: "https://app.api.mgzf.com")!
    }
    
    fileprivate static var userAgent: String {
        return "MogoRenter/\(appVersion) (iPhone; iOS \(osVersion); Scale/2.00)"
    }
    
    fileprivate static var identifyUUID: String {
        return "NTY5MTY4QTgtNzc3Qi00QjM2LUE1QkYtMzNCNEMyMkVGNzU1LDc1ODM0MTgxOTI="
    }
    
    fileprivate static var appVersion: String {
        return "4.1.0"
    }
    
    fileprivate static var channel: String {
        return "租客App"
    }
    
    fileprivate static var osVersion: String {
        return "11.0"
    }
    
    fileprivate static var modelType: String {
        return "iPhone 6 (A1549/A1586)"
    }
    
    fileprivate static var uuid: String {
        return "1111EEB4-4955-458C-831A-865BBD7AA422"
    }
    
    fileprivate static var regID: String {
        return "101d855909705e8aa97"
    }
    
    fileprivate static var keyString: String {
        return "1b592a13c7a559b82d01f40a46e11c26"
    }
}

struct MogoResponse {
    
    var statusCode: Int
    var contentJSON: [String : Any]
    var urlResponse: URLResponse
    
}

struct MogoError {
    
    enum RequestError: Error {
        // Cannot convert parameters to JSON Data
        case notConvertParametersToJSON([String : Any])
    }
    
    public struct ResponseJSON {
        var code: Int
        var json: [String : Any]
    }
    
    enum ResponseError: Error {
        
        case notJSON
        
        case emptyContent
        
        case typeError(Any)
        
        // Can not convert
        case cannotConvertToResponse(Data)
        
        // can not convert to Model
        case cannotConvertToModel(Any)
        
        // Incomplete JSON
        case incompleteJSON([String : Any])
        
        /// Indicates `HTTPURLResponse.statusCode` is not acceptable.
        /// In most cases, *acceptable* means the value is in `200..<300`.
        case unacceptableStatusCode(ResponseJSON)
    }
}
