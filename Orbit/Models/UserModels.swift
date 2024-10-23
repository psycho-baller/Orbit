//
//  UserModels.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-05.
//  Copyright © 2024 CPSC 575. All rights reserved.
//

import Appwrite
import CoreLocation
import Foundation
import UIKit

struct UserModel: Codable, Identifiable {
    let accountId: String
    var id: String {
        return accountId
    }
    var name: String
    var interests: [String]?
    var latitude: Double?
    var longitude: Double?
    var isInterestedToMeet: Bool?
    

    

    
    init(accountId: String, name: String, interests: [String]? = nil, latitude: Double? = nil, longitude: Double? = nil, isInterestedToMeet: Bool? = nil) {
            self.accountId = accountId
            self.name = name
            self.interests = interests
            self.latitude = latitude
            self.longitude = longitude
            self.isInterestedToMeet = isInterestedToMeet
        }
    
    //    var isOnline: Bool
    //    var lastActive: Date
    //    var lastActive:
    //    let bio: String?
    //    let friends: [String]?
    //    let profilePictureId: String?  // Reference to the File ID
    //    let settings: Settings?
}

typealias UserDocument = AppwriteModels.Document<UserModel>

