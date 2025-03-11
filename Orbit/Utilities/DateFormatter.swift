//
//  DateFormatter.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2025-03-11.
//

import Foundation

enum DateFormatterUtility {
    private static let formatterQueue = DispatchQueue(label: "com.orbit.dateformatter")
    
    static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
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
        return dateOnlyFormatter.string(from: date)
    }
}

