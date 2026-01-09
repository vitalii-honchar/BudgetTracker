//
//  ExpensePeriod.swift
//  BudgetTracker
//
//  Domain Layer - Entity
//  Pure Swift, zero dependencies
//

import Foundation

/// ExpensePeriod represents a time period for grouping transactions
/// Entity: Has identity (UUID), contains DateRange, can generate reports
struct ExpensePeriod: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var dateRange: DateRange
    let createdAt: Date
    var updatedAt: Date

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        name: String,
        dateRange: DateRange,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) throws {
        self.id = id
        self.name = name
        self.dateRange = dateRange
        self.createdAt = createdAt
        self.updatedAt = updatedAt

        // Validate
        try validate()
    }

    // MARK: - Validation

    func validate() throws {
        // Name validation
        guard !name.isEmpty else {
            throw ExpensePeriodError.emptyName
        }

        guard name.count <= 100 else {
            throw ExpensePeriodError.nameTooLong
        }
    }

    // MARK: - Factory Methods

    /// Create a period for the current month
    static func currentMonth() throws -> ExpensePeriod {
        let dateRange = try DateRange.currentMonth()
        let calendar = Calendar.current
        let month = calendar.component(.month, from: dateRange.start)
        let year = calendar.component(.year, from: dateRange.start)
        let monthName = calendar.monthSymbols[month - 1]
        let name = "\(monthName) \(year)"

        return try ExpensePeriod(name: name, dateRange: dateRange)
    }

    /// Create a period for a specific month and year
    static func forMonth(_ month: Int, year: Int) throws -> ExpensePeriod {
        guard month >= 1 && month <= 12 else {
            throw ExpensePeriodError.invalidMonth
        }

        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1

        guard let start = calendar.date(from: components) else {
            throw ExpensePeriodError.invalidDateRange
        }

        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: start) else {
            throw ExpensePeriodError.invalidDateRange
        }

        guard let end = calendar.date(byAdding: .day, value: -1, to: nextMonth) else {
            throw ExpensePeriodError.invalidDateRange
        }

        let dateRange = try DateRange(start: start, end: end)
        let monthName = calendar.monthSymbols[month - 1]
        let name = "\(monthName) \(year)"

        return try ExpensePeriod(name: name, dateRange: dateRange)
    }

    /// Create a custom period with arbitrary dates
    static func custom(name: String, start: Date, end: Date?) throws -> ExpensePeriod {
        let dateRange = try DateRange(start: start, end: end)
        return try ExpensePeriod(name: name, dateRange: dateRange)
    }

    /// Create an ongoing period (no end date)
    static func ongoing(name: String, start: Date = Date()) throws -> ExpensePeriod {
        let dateRange = try DateRange(start: start, end: nil)
        return try ExpensePeriod(name: name, dateRange: dateRange)
    }

    // MARK: - Mutations

    /// Update period name
    mutating func updateName(_ newName: String) throws {
        guard !newName.isEmpty else {
            throw ExpensePeriodError.emptyName
        }
        guard newName.count <= 100 else {
            throw ExpensePeriodError.nameTooLong
        }
        self.name = newName
        self.updatedAt = Date()
    }

    /// Update date range
    mutating func updateDateRange(_ newDateRange: DateRange) {
        self.dateRange = newDateRange
        self.updatedAt = Date()
    }

    /// Close an ongoing period by setting an end date
    mutating func close(endDate: Date = Date()) throws {
        let newDateRange = try DateRange(start: dateRange.start, end: endDate)
        self.dateRange = newDateRange
        self.updatedAt = Date()
    }

    /// Reopen a closed period (remove end date)
    mutating func reopen() throws {
        let newDateRange = try DateRange(start: dateRange.start, end: nil)
        self.dateRange = newDateRange
        self.updatedAt = Date()
    }

    // MARK: - Business Logic

    /// Check if a transaction date falls within this period
    func contains(_ transactionDate: Date) -> Bool {
        return dateRange.contains(transactionDate)
    }

    /// Check if this is an ongoing period
    var isOngoing: Bool {
        return dateRange.isOngoing
    }

    /// Check if this period has ended
    var hasEnded: Bool {
        return dateRange.hasEnded
    }

    /// Check if this period is active (ongoing or future)
    var isActive: Bool {
        return isOngoing || !hasEnded
    }

    /// Duration of the period in days (nil if ongoing)
    var durationInDays: Int? {
        return dateRange.durationInDays
    }

    /// Formatted date range string
    var formattedDateRange: String {
        return dateRange.formatted
    }

    /// Short formatted date range
    var shortFormattedDateRange: String {
        return dateRange.shortFormatted
    }

    /// Check if this period overlaps with another period
    func overlaps(with other: ExpensePeriod) -> Bool {
        // If either period is ongoing, check if the other's start is after this start
        if self.isOngoing && other.isOngoing {
            return true // Both ongoing = always overlap
        }

        if self.isOngoing {
            // This is ongoing, check if other starts before now
            return other.dateRange.start >= self.dateRange.start
        }

        if other.isOngoing {
            // Other is ongoing, check if it starts before this ends
            guard let thisEnd = self.dateRange.end else { return false }
            return other.dateRange.start <= thisEnd
        }

        // Both have end dates, check for overlap
        guard let thisEnd = self.dateRange.end,
              let otherEnd = other.dateRange.end else {
            return false
        }

        return self.dateRange.start <= otherEnd && other.dateRange.start <= thisEnd
    }
}

// MARK: - Errors

enum ExpensePeriodError: Error, Equatable {
    case emptyName
    case nameTooLong
    case invalidDateRange
    case invalidMonth
    case periodNotFound
    case overlappingPeriod

    var localizedDescription: String {
        switch self {
        case .emptyName:
            return "Period name cannot be empty"
        case .nameTooLong:
            return "Period name must be 100 characters or less"
        case .invalidDateRange:
            return "Invalid date range for period"
        case .invalidMonth:
            return "Month must be between 1 and 12"
        case .periodNotFound:
            return "Expense period not found"
        case .overlappingPeriod:
            return "This period overlaps with an existing period"
        }
    }
}

// MARK: - Extensions

extension ExpensePeriod {
    /// Compare periods by start date (newest first)
    static func compareByStartDateDescending(_ p1: ExpensePeriod, _ p2: ExpensePeriod) -> Bool {
        return p1.dateRange.start > p2.dateRange.start
    }

    /// Compare periods by name alphabetically
    static func compareByNameAscending(_ p1: ExpensePeriod, _ p2: ExpensePeriod) -> Bool {
        return p1.name < p2.name
    }
}
