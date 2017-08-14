//
//  APIList.swift
//  SporeExample
//
//  Created by luhao on 2017/7/30.
//  Copyright © 2017年 luhao. All rights reserved.
//

import Foundation
import SporeNetworking

extension MogoAPIRequest where Response: MogoDecodable {
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard let resp = object as? MogoResponse else {
            throw MogoError.ResponseError.cannotConvertToModel(object)
        }
        return try Response.buildModel(resp)
    }
}

protocol MogoDecodable {
    static func buildModel(_ response: MogoResponse) throws -> Self
}

final class MogoAPIs {
    
    struct HotBusinessAreaAPI: MogoAPIRequest {
        
        var method: HTTPMethod {
            return .post
        }
        
        typealias Response = BusinessArea
        
        var isMock: Bool = false
        var fileName: String = "HotBusinessAreaAPI"
        
        var lat: Float = 31.232046440972223
        var lng: Float = 121.45450792100695
        var cityID: String = "289"
        
        var path: String {
            return "/mogoroom-renter/elastic/getHotBusinessArea"
        }
        
        func contentParameters() -> [String : Any] {
            return [
                "lat": 31.231771918402778,
                "lng": 121.4545787217882,
                "cityId": "289"
            ]
        }
    }
    
}

struct BusinessArea: MogoDecodable {
    
    var list: [Dictionary<String, String>] = []
    
    static func buildModel(_ response: MogoResponse) throws -> BusinessArea {
        
        if response.contentJSON.isEmpty {
            throw MogoError.ResponseError.emptyContent
        }
        
        let list: [Dictionary<String, String>] = response.contentJSON["list"] as! [Dictionary<String, String>]
        
        var area: BusinessArea = BusinessArea.init()
        area.list = list
        return area
    }
}
