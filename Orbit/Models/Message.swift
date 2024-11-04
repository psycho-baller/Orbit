//
//  Message.swift
//  Orbit
//
//  Created by Devon Tran on 2024-11-01.
//

import Foundation

struct Message: Identifiable, Codable {
    var id: String
    var text: String
    var received: Bool  //to determine who the receiver and who the sender is
    var timestamp: Date
}
