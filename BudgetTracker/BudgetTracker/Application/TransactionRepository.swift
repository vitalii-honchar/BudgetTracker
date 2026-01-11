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
}

/// Repository operation errors
enum RepositoryError: Error, Equatable {
    case saveFailed
    case fetchFailed
    case notFound
    case invalidData
}
