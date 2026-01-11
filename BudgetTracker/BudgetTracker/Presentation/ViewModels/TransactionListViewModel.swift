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

    init(getTransactionsUseCase: GetTransactionsUseCase) {
        self.getTransactionsUseCase = getTransactionsUseCase
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
}
