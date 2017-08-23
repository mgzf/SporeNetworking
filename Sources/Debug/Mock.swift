//
//  Mock.swift
//  SporeExample
//
//  Created by luhao on 2017/7/31.
//  Copyright © 2017年 luhao. All rights reserved.
//

import Foundation

public enum MockedType {
    case plist(String)
    case textFile
}

public protocol Mocked {
    
    var isMock: Bool { get }
    var bundle: Bundle { get }
    
    var mockType: MockedType { get }
    
    func generateData() -> (Data?, HTTPURLResponse, Error?)
}

public extension Mocked where Self: Request {
    
    var isMock: Bool {
        return false
    }
    
    var bundle: Bundle {
        return Bundle.main
    }
    
    var mockType: MockedType {
        fatalError("You must set mocked-file name")
    }
    
    func generateData() -> (Data?, HTTPURLResponse, Error?) {
        
        var name: String = ""
        var resourceType: String = ""
        switch mockType {
        case .plist(let fileName):
            guard !fileName.isEmpty else {
                fatalError("You must set mocked-file name")
            }
            name = fileName
            resourceType = "plist"
        case .textFile:
            resourceType = "text"
        }
        
        guard let path = bundle.path(forResource: name, ofType: resourceType) else {
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
