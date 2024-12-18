//
//  Helpers.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-11-20.
//

import Foundation

let isPreviewMode =
    ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"]
    == "1"

protocol OptionalProtocol {
    var isNil: Bool { get }
    var wrappedValue: Any? { get }
    var jsonValue: Any { get }
}

extension Optional: OptionalProtocol {
    var isNil: Bool { self == nil }
    var wrappedValue: Any? { self }
    var jsonValue: Any {
        if let value = self {
            return value
        } else {
            return NSNull()  // Use `NSNull` for JSON compatibility with nil
        }
    }
}
