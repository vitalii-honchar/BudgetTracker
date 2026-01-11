//
//  DeleteTransactionUseCase.swift
//  BudgetTracker
//
//  Created by Claude Code on 1/11/26.
//

import Foundation

/// Use case for deleting a transaction.
/// Removes the transaction from persistent storage.
final class DeleteTransactionUseCase {
    private let repository: TransactionRepository

    init(repository: TransactionRepository) {
        self.repository = repository
    }

    /// Deletes a transaction by its ID.
    /// - Parameter id: The unique identifier of the transaction to delete
    /// - Throws: RepositoryError.notFound if transaction doesn't exist
    ///           RepositoryError.deleteFailed if deletion fails
    func execute(id: UUID) async throws {
        try await repository.delete(id: id)
    }
}
