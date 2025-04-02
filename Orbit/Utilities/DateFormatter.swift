//
//  DateFormatter.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2025-03-11.
//

import Foundation

enum DateFormatterUtility {
    private static let formatterQueue = DispatchQueue(
        label: "com.orbit.dateformatter")

    static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime, .withFractionalSeconds,
        ]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    static let dateOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    static let timeOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    static let isoDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static func formatForDisplay(_ date: Date) -> String {
        return displayDateFormatter.string(from: date)
    }

    static func formatISO8601(_ date: Date) -> String {
        return formatterQueue.sync {
            return iso8601Formatter.string(from: date)
        }
    }

    static func parseISO8601(_ string: String) -> Date? {
        return formatterQueue.sync {
            return iso8601Formatter.date(from: string)
        }
    }

    static func formatTimeOnly(_ date: Date) -> String {
        return timeOnlyFormatter.string(from: date)
    }

    static func formatDateOnly(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    static func parseDateOnly(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }

    static func parseISODate(_ string: String) -> Date? {
        return isoDateFormatter.date(from: string)
    }

    static func formatISODate(_ date: Date) -> String {
        return isoDateFormatter.string(from: date)
    }
    /// Returns the user's age as an integer based on their date-of-birth string.
    /// - Parameter dobString: A string representing the user's date of birth in "yyyy-MM-dd" format.
    /// - Returns: The calculated age or nil if the date could not be parsed.
    static func age(from dobString: String) -> Int? {
        guard let dob = parseDateOnly(dobString) else { return nil }
        let now = Date()
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dob, to: now)
        return ageComponents.year
    }
}
