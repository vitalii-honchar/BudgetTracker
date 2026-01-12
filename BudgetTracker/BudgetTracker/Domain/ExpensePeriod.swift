//
//  ExpensePeriod.swift
//  BudgetTracker
//
//  Created by Claude Code on 1/12/26.
//

import Foundation

/// Represents an expense period for organizing transactions into logical groups.
/// Examples: "March 2024", "Vacation Budget", "Q1 Expenses"
struct ExpensePeriod: Identifiable, Equatable {
    let id: UUID
    let name: String
    let startDate: Date
    let endDate: Date?  // nil = ongoing period
    let createdAt: Date
    let updatedAt: Date

    /// Errors that can occur during ExpensePeriod creation/validation
    enum ValidationError: Error, Equatable {
        case nameEmpty
        case nameTooLong
        case endDateBeforeStartDate
    }

    /// Creates a new expense period
    /// - Parameters:
    ///   - id: Unique identifier (generates new UUID if not provided)
    ///   - name: Period name (1-100 characters)
    ///   - startDate: Period start date
    ///   - endDate: Optional period end date (nil = ongoing)
    ///   - createdAt: Creation timestamp (defaults to now)
    ///   - updatedAt: Last update timestamp (defaults to now)
    /// - Throws: ValidationError if business rules are violated
    init(
        id: UUID = UUID(),
        name: String,
        startDate: Date,
        endDate: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) throws {
        // Validate name
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw ValidationError.nameEmpty
        }
        guard trimmedName.count <= 100 else {
            throw ValidationError.nameTooLong
        }

        // Validate dates
        if let end = endDate, end < startDate {
            throw ValidationError.endDateBeforeStartDate
        }

        self.id = id
        self.name = trimmedName
        self.startDate = startDate
        self.endDate = endDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Whether this period is ongoing (no end date)
    var isOngoing: Bool {
        endDate == nil
    }

    /// Whether this period is currently active (today is between start and end dates)
    var isActive: Bool {
        let now = Date()
        if let end = endDate {
            return startDate <= now && now <= end
        }
        return startDate <= now // Ongoing period is active if started
    }

    /// Duration of the period in days (nil if ongoing)
    var durationDays: Int? {
        guard let end = endDate else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: end)
        return components.day
    }

    /// Formatted date range string
    var dateRangeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        let startString = formatter.string(from: startDate)

        if let end = endDate {
            let endString = formatter.string(from: end)
            return "\(startString) - \(endString)"
        } else {
            return "\(startString) - Ongoing"
        }
    }
}

// MARK: - Codable
extension ExpensePeriod: Codable {}

// MARK: - Hashable
extension ExpensePeriod: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
