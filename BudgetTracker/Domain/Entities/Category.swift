//
//  Category.swift
//  BudgetTracker
//
//  Domain Layer - Entity
//  Pure Swift, zero dependencies
//

import Foundation

/// Category represents a transaction category (predefined or custom)
/// Entity: Has identity (UUID), mutable over time
struct Category: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var icon: String // SF Symbol name
    var colorHex: String
    var isCustom: Bool
    var sortOrder: Int
    let createdAt: Date
    var updatedAt: Date

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        colorHex: String = "#999999",
        isCustom: Bool = false,
        sortOrder: Int = 999,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) throws {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.isCustom = isCustom
        self.sortOrder = sortOrder
        self.createdAt = createdAt
        self.updatedAt = updatedAt

        // Validate
        try validate()
    }

    // MARK: - Validation

    func validate() throws {
        // Name validation
        guard !name.isEmpty else {
            throw CategoryError.emptyName
        }

        guard name.count <= 50 else {
            throw CategoryError.nameTooLong
        }

        // Icon validation
        guard !icon.isEmpty else {
            throw CategoryError.emptyIcon
        }

        // Color validation (basic hex format check)
        guard colorHex.hasPrefix("#") && colorHex.count == 7 else {
            throw CategoryError.invalidColorFormat
        }

        // Sort order validation
        guard sortOrder >= 0 else {
            throw CategoryError.invalidSortOrder
        }
    }

    // MARK: - Factory Methods

    /// Create a predefined category from TransactionCategory enum
    static func predefined(from transactionCategory: TransactionCategory, sortOrder: Int) throws -> Category {
        return try Category(
            name: transactionCategory.rawValue,
            icon: transactionCategory.icon,
            colorHex: transactionCategory.colorHex,
            isCustom: false,
            sortOrder: sortOrder
        )
    }

    /// Create a custom category
    static func custom(name: String, icon: String, colorHex: String) throws -> Category {
        return try Category(
            name: name,
            icon: icon,
            colorHex: colorHex,
            isCustom: true,
            sortOrder: 100 // Custom categories appear after predefined ones
        )
    }

    // MARK: - Mutations

    /// Update category name
    mutating func updateName(_ newName: String) throws {
        guard !newName.isEmpty else {
            throw CategoryError.emptyName
        }
        guard newName.count <= 50 else {
            throw CategoryError.nameTooLong
        }
        self.name = newName
        self.updatedAt = Date()
    }

    /// Update category icon
    mutating func updateIcon(_ newIcon: String) throws {
        guard !newIcon.isEmpty else {
            throw CategoryError.emptyIcon
        }
        self.icon = newIcon
        self.updatedAt = Date()
    }

    /// Update category color
    mutating func updateColor(_ newColorHex: String) throws {
        guard newColorHex.hasPrefix("#") && newColorHex.count == 7 else {
            throw CategoryError.invalidColorFormat
        }
        self.colorHex = newColorHex
        self.updatedAt = Date()
    }

    /// Update sort order
    mutating func updateSortOrder(_ newSortOrder: Int) throws {
        guard newSortOrder >= 0 else {
            throw CategoryError.invalidSortOrder
        }
        self.sortOrder = newSortOrder
        self.updatedAt = Date()
    }

    // MARK: - Business Logic

    /// Check if this category can be deleted (only custom categories can be deleted)
    var canBeDeleted: Bool {
        return isCustom
    }

    /// Check if this category can be edited
    var canBeEdited: Bool {
        return isCustom // Only custom categories can be fully edited
    }
}

// MARK: - Errors

enum CategoryError: Error, Equatable {
    case emptyName
    case nameTooLong
    case emptyIcon
    case invalidColorFormat
    case invalidSortOrder
    case cannotDeletePredefinedCategory
    case categoryNotFound

    var localizedDescription: String {
        switch self {
        case .emptyName:
            return "Category name cannot be empty"
        case .nameTooLong:
            return "Category name must be 50 characters or less"
        case .emptyIcon:
            return "Category icon cannot be empty"
        case .invalidColorFormat:
            return "Color must be in hex format (#RRGGBB)"
        case .invalidSortOrder:
            return "Sort order must be non-negative"
        case .cannotDeletePredefinedCategory:
            return "Predefined categories cannot be deleted"
        case .categoryNotFound:
            return "Category not found"
        }
    }
}
