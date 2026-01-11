//
//  UpdateTransactionUseCase.swift
//  BudgetTracker
//
//  Created by Claude Code on 1/11/26.
//

import Foundation

/// Use case for updating an existing transaction.
/// Validates the transaction and persists changes to the repository.
final class UpdateTransactionUseCase {
    private let repository: TransactionRepository

    init(repository: TransactionRepository) {
        self.repository = repository
    }

    /// Updates an existing transaction with new data.
    /// - Parameter transaction: The transaction with updated data (must have existing ID)
    /// - Returns: The updated transaction
    /// - Throws: RepositoryError if update fails or transaction doesn't exist
    func execute(transaction: Transaction) async throws -> Transaction {
        return try await repository.update(transaction: transaction)
    }
}
