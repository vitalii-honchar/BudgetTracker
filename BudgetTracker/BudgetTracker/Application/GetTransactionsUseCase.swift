//
//  GetTransactionsUseCase.swift
//  BudgetTracker
//
//  Created by Claude Code on 1/11/26.
//

import Foundation

/// Use case for retrieving all transactions
final class GetTransactionsUseCase {
    private let repository: TransactionRepository

    init(repository: TransactionRepository) {
        self.repository = repository
    }

    /// Executes the use case to retrieve all transactions
    /// - Returns: Array of transactions sorted by date (newest first)
    /// - Throws: RepositoryError if retrieval fails
    func execute() async throws -> [Transaction] {
        let transactions = try await repository.findAll()
        return transactions.sorted { $0.date > $1.date }
    }
}
