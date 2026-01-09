//
//  TransactionRepository.swift
//  BudgetTracker
//
//  Domain Layer - Repository Protocol (Contract)
//  Pure Swift, zero dependencies
//  Implementation will be in Data layer
//

import Foundation

/// TransactionRepository defines the contract for transaction persistence
/// Protocol: Abstracts data access, implemented by Data layer
protocol TransactionRepository {

    // MARK: - Create

    /// Create a new transaction
    /// - Parameter transaction: The transaction to create
    /// - Returns: The created transaction with any system-generated fields
    /// - Throws: RepositoryError if creation fails
    func create(transaction: Transaction) async throws -> Transaction

    // MARK: - Read

    /// Find a transaction by its ID
    /// - Parameter id: The transaction ID
    /// - Returns: The transaction if found, nil otherwise
    /// - Throws: RepositoryError if query fails
    func findById(id: UUID) async throws -> Transaction?

    /// Get all transactions
    /// - Returns: Array of all transactions, sorted by date (newest first)
    /// - Throws: RepositoryError if query fails
    func findAll() async throws -> [Transaction]

    /// Find transactions by expense period
    /// - Parameter periodId: The expense period ID
    /// - Returns: Array of transactions in the period, sorted by date
    /// - Throws: RepositoryError if query fails
    func findByPeriod(periodId: UUID) async throws -> [Transaction]

    /// Find transactions by category
    /// - Parameter categoryId: The category ID
    /// - Returns: Array of transactions in the category, sorted by date
    /// - Throws: RepositoryError if query fails
    func findByCategory(categoryId: UUID) async throws -> [Transaction]

    /// Find transactions within a date range
    /// - Parameter dateRange: The date range to filter by
    /// - Returns: Array of transactions within the range, sorted by date
    /// - Throws: RepositoryError if query fails
    func findByDateRange(dateRange: DateRange) async throws -> [Transaction]

    /// Find transactions by multiple criteria
    /// - Parameters:
    ///   - periodId: Optional period filter
    ///   - categoryId: Optional category filter
    ///   - dateRange: Optional date range filter
    /// - Returns: Array of matching transactions, sorted by date
    /// - Throws: RepositoryError if query fails
    func findByCriteria(
        periodId: UUID?,
        categoryId: UUID?,
        dateRange: DateRange?
    ) async throws -> [Transaction]

    /// Find recent transactions (last N days)
    /// - Parameter days: Number of days to look back
    /// - Returns: Array of recent transactions, sorted by date
    /// - Throws: RepositoryError if query fails
    func findRecent(days: Int) async throws -> [Transaction]

    /// Count total transactions
    /// - Returns: Total number of transactions
    /// - Throws: RepositoryError if query fails
    func count() async throws -> Int

    /// Count transactions in a period
    /// - Parameter periodId: The expense period ID
    /// - Returns: Number of transactions in the period
    /// - Throws: RepositoryError if query fails
    func countByPeriod(periodId: UUID) async throws -> Int

    // MARK: - Update

    /// Update an existing transaction
    /// - Parameter transaction: The transaction with updated fields
    /// - Returns: The updated transaction
    /// - Throws: RepositoryError if update fails or transaction not found
    func update(transaction: Transaction) async throws -> Transaction

    // MARK: - Delete

    /// Delete a transaction by ID
    /// - Parameter id: The transaction ID
    /// - Throws: RepositoryError if deletion fails or transaction not found
    func delete(id: UUID) async throws

    /// Delete all transactions in a period
    /// - Parameter periodId: The expense period ID
    /// - Throws: RepositoryError if deletion fails
    func deleteByPeriod(periodId: UUID) async throws

    /// Delete all transactions
    /// - Throws: RepositoryError if deletion fails
    func deleteAll() async throws

    // MARK: - Aggregations

    /// Calculate total spending for a date range
    /// - Parameter dateRange: The date range
    /// - Returns: Total money spent, nil if no transactions
    /// - Throws: RepositoryError if calculation fails
    func totalSpent(in dateRange: DateRange) async throws -> Money?

    /// Calculate total spending by category
    /// - Parameter categoryId: The category ID
    /// - Returns: Total money spent in category, nil if no transactions
    /// - Throws: RepositoryError if calculation fails
    func totalSpentByCategory(categoryId: UUID) async throws -> Money?
}

// MARK: - Repository Errors

/// RepositoryError represents errors that can occur during repository operations
enum RepositoryError: Error, Equatable {
    case notFound(String)
    case createFailed(String)
    case updateFailed(String)
    case deleteFailed(String)
    case queryFailed(String)
    case invalidData(String)
    case unknown(String)

    var localizedDescription: String {
        switch self {
        case .notFound(let message):
            return "Not found: \(message)"
        case .createFailed(let message):
            return "Create failed: \(message)"
        case .updateFailed(let message):
            return "Update failed: \(message)"
        case .deleteFailed(let message):
            return "Delete failed: \(message)"
        case .queryFailed(let message):
            return "Query failed: \(message)"
        case .invalidData(let message):
            return "Invalid data: \(message)"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
}
