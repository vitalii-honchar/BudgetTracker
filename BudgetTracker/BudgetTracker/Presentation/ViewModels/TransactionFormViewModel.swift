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
    private let updateTransactionUseCase: UpdateTransactionUseCase?
    private let deleteTransactionUseCase: DeleteTransactionUseCase?
    private let transactionToEdit: Transaction?

    var isEditMode: Bool {
        transactionToEdit != nil
    }

    init(
        createTransactionUseCase: CreateTransactionUseCase,
        updateTransactionUseCase: UpdateTransactionUseCase? = nil,
        deleteTransactionUseCase: DeleteTransactionUseCase? = nil,
        transactionToEdit: Transaction? = nil
    ) {
        self.createTransactionUseCase = createTransactionUseCase
        self.updateTransactionUseCase = updateTransactionUseCase
        self.deleteTransactionUseCase = deleteTransactionUseCase
        self.transactionToEdit = transactionToEdit

        // Pre-populate form if editing
        if let transaction = transactionToEdit {
            self.amount = String(describing: transaction.money.amount)
            self.name = transaction.name
            self.selectedCurrency = transaction.money.currency
            self.selectedCategory = transaction.category
            self.date = transaction.date
            self.transactionDescription = transaction.description ?? ""
        }
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

                if isEditMode, let existingTransaction = transactionToEdit, let updateUseCase = updateTransactionUseCase {
                    // Update existing transaction
                    let updatedTransaction = try Transaction(
                        id: existingTransaction.id,
                        money: money,
                        name: name,
                        category: selectedCategory,
                        date: date,
                        description: transactionDescription.isEmpty ? nil : transactionDescription
                    )
                    _ = try await updateUseCase.execute(transaction: updatedTransaction)
                } else {
                    // Create new transaction
                    let transaction = try Transaction(
                        money: money,
                        name: name,
                        category: selectedCategory,
                        date: date,
                        description: transactionDescription.isEmpty ? nil : transactionDescription
                    )
                    _ = try await createTransactionUseCase.execute(transaction: transaction)
                }

                // Success
                showSuccess = true
                if !isEditMode {
                    clearForm()
                }

            } catch {
                errorMessage = "Failed to save: \(error.localizedDescription)"
            }

            isLoading = false
        }
    }

    func deleteTransaction() {
        Task {
            guard let transaction = transactionToEdit, let deleteUseCase = deleteTransactionUseCase else {
                return
            }

            isLoading = true
            errorMessage = nil

            do {
                try await deleteUseCase.execute(id: transaction.id)
                showSuccess = true
            } catch {
                errorMessage = "Failed to delete: \(error.localizedDescription)"
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
