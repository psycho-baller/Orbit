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
