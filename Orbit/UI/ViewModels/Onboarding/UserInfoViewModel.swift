//
//  UserInfoViewModel.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-12-19.
//

import Foundation

class UserInfoViewModel: ObservableObject {
    @Published var bio: String = ""
    @Published var dateOfBirth: Date = Date()

    func loadUserData(user: UserModel?) {
        bio = user?.bio ?? ""
        guard let dateString = user?.dob else {
            dateOfBirth = Date()
            return
        }
        
        if let date = DateFormatterUtility.parseDateOnly(dateString) ?? DateFormatterUtility.parseISO8601(dateString) {
            print("Converted Date: \(date)")
            dateOfBirth = date
        } else {
            print("Invalid date string.")
            dateOfBirth = Date()
        }
    }

    func canProceed() -> Bool {
        // Ensure bio is not empty and date of birth is in a reasonable range
        let minimumDOB = Calendar.current.date(
            byAdding: .year, value: -120, to: Date())
        return !bio.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && dateOfBirth > minimumDOB!
    }
}
