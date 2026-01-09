//
//  CategoryRepository.swift
//  BudgetTracker
//
//  Domain Layer - Repository Protocol (Contract)
//  Pure Swift, zero dependencies
//  Implementation will be in Data layer
//

import Foundation

/// CategoryRepository defines the contract for category persistence
/// Protocol: Abstracts data access, implemented by Data layer
protocol CategoryRepository {

    // MARK: - Create

    /// Create a new category
    /// - Parameter category: The category to create
    /// - Returns: The created category
    /// - Throws: RepositoryError if creation fails
    func create(category: Category) async throws -> Category

    // MARK: - Read

    /// Find a category by its ID
    /// - Parameter id: The category ID
    /// - Returns: The category if found, nil otherwise
    /// - Throws: RepositoryError if query fails
    func findById(id: UUID) async throws -> Category?

    /// Get all categories
    /// - Returns: Array of all categories, sorted by sort order
    /// - Throws: RepositoryError if query fails
    func findAll() async throws -> [Category]

    /// Get all predefined categories
    /// - Returns: Array of predefined categories only
    /// - Throws: RepositoryError if query fails
    func findPredefined() async throws -> [Category]

    /// Get all custom categories
    /// - Returns: Array of custom categories only
    /// - Throws: RepositoryError if query fails
    func findCustom() async throws -> [Category]

    /// Find category by name (case-insensitive)
    /// - Parameter name: The category name
    /// - Returns: The category if found, nil otherwise
    /// - Throws: RepositoryError if query fails
    func findByName(name: String) async throws -> Category?

    /// Check if a category name already exists
    /// - Parameter name: The category name to check
    /// - Returns: True if name exists, false otherwise
    /// - Throws: RepositoryError if query fails
    func exists(name: String) async throws -> Bool

    /// Count total categories
    /// - Returns: Total number of categories
    /// - Throws: RepositoryError if query fails
    func count() async throws -> Int

    // MARK: - Update

    /// Update an existing category
    /// - Parameter category: The category with updated fields
    /// - Returns: The updated category
    /// - Throws: RepositoryError if update fails or category not found
    func update(category: Category) async throws -> Category

    // MARK: - Delete

    /// Delete a category by ID
    /// - Parameter id: The category ID
    /// - Throws: RepositoryError if deletion fails or category not found
    /// - Note: Should fail if category has transactions (referential integrity)
    func delete(id: UUID) async throws

    /// Check if a category can be deleted (has no transactions)
    /// - Parameter id: The category ID
    /// - Returns: True if category can be deleted, false otherwise
    /// - Throws: RepositoryError if query fails
    func canDelete(id: UUID) async throws -> Bool

    // MARK: - Statistics

    /// Count transactions for a category
    /// - Parameter categoryId: The category ID
    /// - Returns: Number of transactions in this category
    /// - Throws: RepositoryError if query fails
    func transactionCount(for categoryId: UUID) async throws -> Int

    /// Get categories ordered by usage (transaction count)
    /// - Parameter limit: Maximum number of categories to return
    /// - Returns: Array of categories sorted by transaction count (descending)
    /// - Throws: RepositoryError if query fails
    func findByUsage(limit: Int?) async throws -> [Category]
}
