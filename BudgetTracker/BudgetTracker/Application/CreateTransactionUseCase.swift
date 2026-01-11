//
//  CreateTransactionUseCase.swift
//  BudgetTracker
//
//  Created by Claude Code on 1/11/26.
//

import Foundation

/// Use case for creating a new transaction
final class CreateTransactionUseCase {
    private let repository: TransactionRepository

    init(repository: TransactionRepository) {
        self.repository = repository
    }

    /// Executes the use case to create a transaction
    /// - Parameter transaction: The transaction to create
    /// - Returns: The created transaction
    /// - Throws: RepositoryError if creation fails
    func execute(transaction: Transaction) async throws -> Transaction {
        return try await repository.create(transaction: transaction)
    }
}
