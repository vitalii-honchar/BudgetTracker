//
//  TransactionFormViewModel.swift
//  BudgetTracker
//
//  Created by Claude Code on 1/11/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class TransactionFormViewModel: ObservableObject {
    @Published var amount: String = ""
    @Published var name: String = ""
    @Published var selectedCurrency: Currency = .EUR
    @Published var selectedCategory: Category = .food
    @Published var date: Date = Date()
    @Published var transactionDescription: String = ""

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showSuccess = false

    private let createTransactionUseCase: CreateTransactionUseCase

    init(createTransactionUseCase: CreateTransactionUseCase) {
        self.createTransactionUseCase = createTransactionUseCase
    }

    func saveTransaction() {
        Task {
            isLoading = true
            errorMessage = nil

            do {
                // Validate amount
                guard let amountDecimal = Decimal(string: amount), amountDecimal > 0 else {
                    errorMessage = "Please enter a valid amount"
                    isLoading = false
                    return
                }

                // Validate name
                guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    errorMessage = "Please enter a transaction name"
                    isLoading = false
                    return
                }

                // Create Money
                let money = try Money(amount: amountDecimal, currency: selectedCurrency)

                // Create Transaction
                let transaction = try Transaction(
                    money: money,
                    name: name,
                    category: selectedCategory,
                    date: date,
                    description: transactionDescription.isEmpty ? nil : transactionDescription
                )

                // Save
                _ = try await createTransactionUseCase.execute(transaction: transaction)

                // Success
                showSuccess = true
                clearForm()

            } catch {
                errorMessage = "Failed to save: \(error.localizedDescription)"
            }

            isLoading = false
        }
    }

    private func clearForm() {
        amount = ""
        name = ""
        selectedCurrency = .EUR
        selectedCategory = .food
        date = Date()
        transactionDescription = ""
    }
}
