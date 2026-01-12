//
//  TransactionFormView.swift
//  BudgetTracker
//
//  Created by Claude Code on 1/11/26.
//

import SwiftUI

struct TransactionFormView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: TransactionFormViewModel
    @State private var showingDeleteConfirmation = false

    init(viewModel: TransactionFormViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Transaction Details") {
                    HStack {
                        TextField("Amount", text: $viewModel.amount)
                            .keyboardType(.decimalPad)

                        Picker("Currency", selection: $viewModel.selectedCurrency) {
                            ForEach(Currency.allCases, id: \.self) { currency in
                                Text(currency.symbol)
                                    .tag(currency)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 60)
                    }

                    TextField("Name", text: $viewModel.name)

                    DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
                }

                Section("Category") {
                    Picker("Category", selection: $viewModel.selectedCategory) {
                        ForEach(Category.allCases, id: \.self) { category in
                            Label(category.name, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Description (Optional)") {
                    TextEditor(text: $viewModel.transactionDescription)
                        .frame(height: 80)
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle(viewModel.isEditMode ? "Edit Transaction" : "Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                if viewModel.isEditMode {
                    ToolbarItem(placement: .destructiveAction) {
                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(viewModel.isEditMode ? "Update" : "Save") {
                        viewModel.saveTransaction()
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .alert("Delete Transaction", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    viewModel.deleteTransaction()
                }
            } message: {
                Text("Are you sure you want to delete this transaction? This action cannot be undone.")
            }
            .onChange(of: viewModel.showSuccess) { _, newValue in
                if newValue {
                    dismiss()
                }
            }
        }
    }
}
