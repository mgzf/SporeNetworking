//
//  Mock.swift
//  SporeExample
//
//  Created by luhao on 2017/7/31.
//  Copyright © 2017年 luhao. All rights reserved.
//

import Foundation

public enum MockedType {
    case plist
    case textFile
}

public protocol Mocked {
    
    var isMock: Bool { get }
    
    var fileName: String { get }
    var type: MockedType { get }
    
    func generateData() -> (Data?, HTTPURLResponse, Error?)
}

public extension Mocked where Self: Request {
    
    var isMock: Bool {
        return false
    }
    
    var fileName: String {
        fatalError("You must set mocked-file name")
    }
    
    var type: MockedType {
        return MockedType.plist
    }
    
    func generateData() -> (Data?, HTTPURLResponse, Error?) {
        
        let name: String = fileName
        var resourceType: String = ""
        switch type {
        case .plist:
            resourceType = "plist"
        case .textFile:
            resourceType = "text"
        }
        
        guard let path = Bundle.main.path(forResource: name, ofType: resourceType) else {
            return (nil, HTTPURLResponse.init(), MockedError.plistNotFound)
        }
        
        guard let json: [String : Any] = NSDictionary.init(contentsOfFile: path) as? [String : Any] else {
            return (nil, HTTPURLResponse.init(), MockedError.plistConvertError)
        }
        
        guard let jsonData: Data = try? JSONSerialization.data(withJSONObject: json, options: []) else {
            return (nil, HTTPURLResponse.init(), MockedError.plistConvertError)
        }
        
        let mockURL: URL = URL.init(string: "mogo://mock")!
        let urlResponse: HTTPURLResponse = HTTPURLResponse.init(url: mockURL, statusCode: 99999, httpVersion: nil, headerFields: nil)!
        return (jsonData, urlResponse, nil)
    }
}

enum MockedError: Error {
    case plistNotFound
    case plistConvertError
}
