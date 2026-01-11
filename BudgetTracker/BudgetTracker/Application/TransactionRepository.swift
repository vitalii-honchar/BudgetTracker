//
//  TransactionRepository.swift
//  BudgetTracker
//
//  Created by Claude Code on 1/11/26.
//

import Foundation

/// Protocol defining transaction data access operations
protocol TransactionRepository {
    /// Creates a new transaction
    /// - Parameter transaction: The transaction to create
    /// - Returns: The created transaction
    /// - Throws: RepositoryError if creation fails
    func create(transaction: Transaction) async throws -> Transaction

    /// Retrieves all transactions
    /// - Returns: Array of all transactions, sorted by date (newest first)
    /// - Throws: RepositoryError if retrieval fails
    func findAll() async throws -> [Transaction]

    /// Updates an existing transaction
    /// - Parameter transaction: The transaction with updated data (must have existing ID)
    /// - Returns: The updated transaction
    /// - Throws: RepositoryError.notFound if transaction doesn't exist
    ///           RepositoryError.saveFailed if update fails
    func update(transaction: Transaction) async throws -> Transaction

    /// Deletes a transaction by its ID
    /// - Parameter id: The unique identifier of the transaction to delete
    /// - Throws: RepositoryError.notFound if transaction doesn't exist
    ///           RepositoryError.deleteFailed if deletion fails
    func delete(id: UUID) async throws
}

/// Repository operation errors
enum RepositoryError: Error, Equatable {
    case saveFailed
    case fetchFailed
    case notFound
    case invalidData
    case deleteFailed
}
