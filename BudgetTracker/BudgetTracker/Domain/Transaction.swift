//
//  Transaction.swift
//  BudgetTracker
//
//  Created by Claude Code on 1/11/26.
//

import Foundation

/// Represents a financial transaction
struct Transaction: Equatable, Identifiable {
    let id: UUID
    let money: Money
    let name: String
    let category: Category
    let date: Date
    let description: String?
    let createdAt: Date
    let updatedAt: Date

    // MARK: - Initialization

    /// Creates a Transaction with validation
    /// - Parameters:
    ///   - id: Unique identifier (defaults to new UUID)
    ///   - money: Monetary amount
    ///   - name: Transaction name (1-100 characters)
    ///   - category: Transaction category
    ///   - date: Transaction date (cannot be in future)
    ///   - description: Optional description (max 500 characters)
    ///   - createdAt: Creation timestamp (defaults to now)
    ///   - updatedAt: Update timestamp (defaults to now)
    /// - Throws: TransactionError if validation fails
    init(
        id: UUID = UUID(),
        money: Money,
        name: String,
        category: Category,
        date: Date,
        description: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) throws {
        // Trim name first
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        // Validate name
        guard !trimmedName.isEmpty else {
            throw TransactionError.emptyName
        }
        guard trimmedName.count <= 100 else {
            throw TransactionError.nameTooLong
        }

        // Validate date (cannot be in future)
        guard date <= Date() else {
            throw TransactionError.futureDate
        }

        // Validate description length if provided
        if let desc = description {
            guard desc.count <= 500 else {
                throw TransactionError.descriptionTooLong
            }
        }

        self.id = id
        self.money = money
        self.name = trimmedName
        self.category = category
        self.date = date
        self.description = description?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Errors

enum TransactionError: Error, Equatable {
    case emptyName
    case nameTooLong
    case futureDate
    case descriptionTooLong
}

// MARK: - Formatting

extension Transaction {
    /// Returns formatted string representation for display
    var displayText: String {
        return "\(name): \(money.formatted) [\(category.name)]"
    }
}

// MARK: - Codable

extension Transaction: Codable {
    enum CodingKeys: String, CodingKey {
        case id, money, name, category, date, description, createdAt, updatedAt
    }
}
