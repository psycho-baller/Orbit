//
//  AuthNavigationPath.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-02-22.
//  Copyright © 2024 CPSC 575. All rights reserved.
//

import SwiftUI

enum AuthDestination: Hashable {
    case login
    case signup
    case userDetails(accountId: String)
}

class AuthNavigationCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    
    func navigateToSignup() {
        path.append(AuthDestination.signup)
    }
    
    func navigateToUserDetails(accountId: String) {
        path.append(AuthDestination.userDetails(accountId: accountId))
    }
    
    func navigateToRoot() {
        path.removeLast(path.count)
    }
}
