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
        let dateString = user?.dob ?? "none"
        let dateComponent = dateString.split(separator: "T").first ?? ""  // Get the part before 'T'

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        if let date = dateFormatter.date(from: String(dateComponent)) {
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
