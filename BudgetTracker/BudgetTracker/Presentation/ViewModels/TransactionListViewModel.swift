//
//  TransactionListViewModel.swift
//  BudgetTracker
//
//  Created by Claude Code on 1/11/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class TransactionListViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let getTransactionsUseCase: GetTransactionsUseCase
    private let deleteTransactionUseCase: DeleteTransactionUseCase

    init(getTransactionsUseCase: GetTransactionsUseCase, deleteTransactionUseCase: DeleteTransactionUseCase) {
        self.getTransactionsUseCase = getTransactionsUseCase
        self.deleteTransactionUseCase = deleteTransactionUseCase
    }

    func loadTransactions() {
        Task {
            isLoading = true
            errorMessage = nil

            do {
                transactions = try await getTransactionsUseCase.execute()
            } catch {
                errorMessage = "Failed to load transactions: \(error.localizedDescription)"
            }

            isLoading = false
        }
    }

    func deleteTransaction(_ transaction: Transaction) {
        Task {
            errorMessage = nil

            do {
                try await deleteTransactionUseCase.execute(id: transaction.id)
                // Reload transactions after successful deletion
                loadTransactions()
            } catch {
                errorMessage = "Failed to delete transaction: \(error.localizedDescription)"
            }
        }
    }
}
