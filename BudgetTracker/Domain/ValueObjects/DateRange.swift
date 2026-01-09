//
//  DateRange.swift
//  BudgetTracker
//
//  Domain Layer - Value Object
//  Pure Swift, zero dependencies
//

import Foundation

/// DateRange represents a time period with start and optional end dates
/// Value Object: Immutable, validated date range
struct DateRange: Codable, Equatable, Hashable {
    let start: Date
    let end: Date?

    // MARK: - Initialization

    init(start: Date, end: Date? = nil) throws {
        self.start = start
        self.end = end

        // Validation
        try validate()
    }

    // MARK: - Validation

    private func validate() throws {
        // If end date is provided, it must be after or equal to start date
        if let end = end {
            guard end >= start else {
                throw DateRangeError.endBeforeStart
            }
        }
    }

    // MARK: - Queries

    /// Check if a date falls within this range
    func contains(_ date: Date) -> Bool {
        if let end = end {
            return date >= start && date <= end
        } else {
            // If no end date, only check if date is after or equal to start
            return date >= start
        }
    }

    /// Check if this is an ongoing period (no end date)
    var isOngoing: Bool {
        return end == nil
    }

    /// Check if this period has ended
    var hasEnded: Bool {
        guard let end = end else { return false }
        return end < Date()
    }

    /// Duration in days (nil if ongoing)
    var durationInDays: Int? {
        guard let end = end else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: start, to: end)
        return components.day
    }

    /// Duration in seconds (nil if ongoing)
    var durationInSeconds: TimeInterval? {
        guard let end = end else { return nil }
        return end.timeIntervalSince(start)
    }

    // MARK: - Factory Methods

    /// Create a date range for the current month
    static func currentMonth() throws -> DateRange {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month], from: now)
        guard let start = calendar.date(from: components) else {
            throw DateRangeError.invalidDateRange
        }
        guard let end = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: start) else {
            throw DateRangeError.invalidDateRange
        }
        return try DateRange(start: start, end: end)
    }

    /// Create a date range for the last N days
    static func lastDays(_ days: Int) throws -> DateRange {
        let calendar = Calendar.current
        let end = Date()
        guard let start = calendar.date(byAdding: .day, value: -days, to: end) else {
            throw DateRangeError.invalidDateRange
        }
        return try DateRange(start: start, end: end)
    }

    /// Create a date range for last month
    static func lastMonth() throws -> DateRange {
        let calendar = Calendar.current
        let now = Date()
        guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) else {
            throw DateRangeError.invalidDateRange
        }
        let components = calendar.dateComponents([.year, .month], from: lastMonth)
        guard let start = calendar.date(from: components) else {
            throw DateRangeError.invalidDateRange
        }
        guard let end = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: start) else {
            throw DateRangeError.invalidDateRange
        }
        return try DateRange(start: start, end: end)
    }

    /// Create a date range for a specific year
    static func year(_ year: Int) throws -> DateRange {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = 1
        components.day = 1
        guard let start = calendar.date(from: components) else {
            throw DateRangeError.invalidDateRange
        }
        components.year = year
        components.month = 12
        components.day = 31
        guard let end = calendar.date(from: components) else {
            throw DateRangeError.invalidDateRange
        }
        return try DateRange(start: start, end: end)
    }

    // MARK: - Formatting

    /// Formatted string representation
    var formatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        if let end = end {
            return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
        } else {
            return "From \(formatter.string(from: start)) (ongoing)"
        }
    }

    /// Short formatted string (e.g., "Mar 1 - Mar 31")
    var shortFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"

        if let end = end {
            // Check if same month
            let calendar = Calendar.current
            let startComponents = calendar.dateComponents([.year, .month], from: start)
            let endComponents = calendar.dateComponents([.year, .month], from: end)

            if startComponents.year == endComponents.year && startComponents.month == endComponents.month {
                return formatter.string(from: start) + " - " + String(calendar.component(.day, from: end))
            } else {
                return formatter.string(from: start) + " - " + formatter.string(from: end)
            }
        } else {
            return "From " + formatter.string(from: start)
        }
    }
}

// MARK: - Errors

enum DateRangeError: Error, Equatable {
    case endBeforeStart
    case invalidDateRange

    var localizedDescription: String {
        switch self {
        case .endBeforeStart:
            return "End date cannot be before start date"
        case .invalidDateRange:
            return "Invalid date range"
        }
    }
}
