//
//  ErrorHandleable.swift
//  APIKit
//
//  Created by Hanguang on 2017/8/5.
//  Copyright © 2017年 Yosuke Ishikawa. All rights reserved.
//

import Foundation

public protocol ErrorHandleable {
    /// Handle any error thrown during a network request process
    /// Default implementation does nothing
    /// - Parameter error: SessionTaskError
    func handle(error: SessionTaskError)
}

public extension ErrorHandleable {
    func handle(error: SessionTaskError) {}
}
