//
//  Transaction.swift
//  BudgetTracker
//
//  Domain Layer - Entity
//  Pure Swift, zero dependencies
//

import Foundation

/// Transaction represents a single financial transaction (expense or income)
/// Entity: Has identity (UUID), mutable over time, contains business rules
struct Transaction: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var money: Money
    var name: String
    var categoryId: UUID
    var date: Date
    var description: String?
    var periodId: UUID? // Optional link to expense period
    let createdAt: Date
    var updatedAt: Date

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        money: Money,
        name: String,
        categoryId: UUID,
        date: Date = Date(),
        description: String? = nil,
        periodId: UUID? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) throws {
        self.id = id
        self.money = money
        self.name = name
        self.categoryId = categoryId
        self.date = date
        self.description = description
        self.periodId = periodId
        self.createdAt = createdAt
        self.updatedAt = updatedAt

        // Validate
        try validate()
    }

    // MARK: - Validation

    func validate() throws {
        // Validate money amount is positive
        guard money.amount > 0 else {
            throw TransactionError.invalidAmount
        }

        // Validate name
        guard !name.isEmpty else {
            throw TransactionError.emptyName
        }

        guard name.count <= 100 else {
            throw TransactionError.nameTooLong
        }

        // Validate date is not in the future
        guard date <= Date() else {
            throw TransactionError.futureDate
        }

        // Validate description length if present
        if let desc = description {
            guard desc.count <= 500 else {
                throw TransactionError.descriptionTooLong
            }
        }
    }

    // MARK: - Factory Methods

    /// Create a simple transaction with minimal required fields
    static func create(
        money: Money,
        name: String,
        categoryId: UUID
    ) throws -> Transaction {
        return try Transaction(
            money: money,
            name: name,
            categoryId: categoryId
        )
    }

    /// Create a transaction with all details
    static func createDetailed(
        money: Money,
        name: String,
        categoryId: UUID,
        date: Date,
        description: String?,
        periodId: UUID?
    ) throws -> Transaction {
        return try Transaction(
            money: money,
            name: name,
            categoryId: categoryId,
            date: date,
            description: description,
            periodId: periodId
        )
    }

    // MARK: - Mutations

    /// Update transaction amount
    mutating func updateAmount(_ newMoney: Money) throws {
        guard newMoney.amount > 0 else {
            throw TransactionError.invalidAmount
        }
        self.money = newMoney
        self.updatedAt = Date()
    }

    /// Update transaction name
    mutating func updateName(_ newName: String) throws {
        guard !newName.isEmpty else {
            throw TransactionError.emptyName
        }
        guard newName.count <= 100 else {
            throw TransactionError.nameTooLong
        }
        self.name = newName
        self.updatedAt = Date()
    }

    /// Update category
    mutating func updateCategory(_ newCategoryId: UUID) {
        self.categoryId = newCategoryId
        self.updatedAt = Date()
    }

    /// Update date
    mutating func updateDate(_ newDate: Date) throws {
        guard newDate <= Date() else {
            throw TransactionError.futureDate
        }
        self.date = newDate
        self.updatedAt = Date()
    }

    /// Update description
    mutating func updateDescription(_ newDescription: String?) throws {
        if let desc = newDescription {
            guard desc.count <= 500 else {
                throw TransactionError.descriptionTooLong
            }
        }
        self.description = newDescription
        self.updatedAt = Date()
    }

    /// Link to an expense period
    mutating func linkToPeriod(_ periodId: UUID) {
        self.periodId = periodId
        self.updatedAt = Date()
    }

    /// Unlink from expense period
    mutating func unlinkFromPeriod() {
        self.periodId = nil
        self.updatedAt = Date()
    }

    // MARK: - Business Logic

    /// Check if transaction is recent (within last 7 days)
    var isRecent: Bool {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return date >= sevenDaysAgo
    }

    /// Check if transaction has a description
    var hasDescription: Bool {
        return description != nil && !description!.isEmpty
    }

    /// Check if transaction is linked to a period
    var isLinkedToPeriod: Bool {
        return periodId != nil
    }

    /// Age of transaction in days
    var ageInDays: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date, to: Date())
        return components.day ?? 0
    }

    /// Formatted amount string
    var formattedAmount: String {
        return money.formatted
    }
}

// MARK: - Errors

enum TransactionError: Error, Equatable {
    case invalidAmount
    case emptyName
    case nameTooLong
    case futureDate
    case descriptionTooLong
    case invalidCategory
    case transactionNotFound

    var localizedDescription: String {
        switch self {
        case .invalidAmount:
            return "Transaction amount must be greater than zero"
        case .emptyName:
            return "Transaction name cannot be empty"
        case .nameTooLong:
            return "Transaction name must be 100 characters or less"
        case .futureDate:
            return "Transaction date cannot be in the future"
        case .descriptionTooLong:
            return "Description must be 500 characters or less"
        case .invalidCategory:
            return "Invalid category selected"
        case .transactionNotFound:
            return "Transaction not found"
        }
    }
}

// MARK: - Extensions

extension Transaction {
    /// Compare transactions by date (newest first)
    static func compareByDateDescending(_ t1: Transaction, _ t2: Transaction) -> Bool {
        return t1.date > t2.date
    }

    /// Compare transactions by amount (highest first)
    static func compareByAmountDescending(_ t1: Transaction, _ t2: Transaction) -> Bool {
        return t1.money.amount > t2.money.amount
    }
}
