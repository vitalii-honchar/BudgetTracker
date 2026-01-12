//
//  TransactionListView.swift
//  BudgetTracker
//
//  Created by Claude Code on 1/11/26.
//

import SwiftUI

struct TransactionListView: View {
    @Environment(\.dependencies) private var dependencies
    @StateObject private var viewModel: TransactionListViewModel
    @State private var showingAddTransaction = false
    @State private var showingEditTransaction = false
    @State private var transactionToEdit: Transaction?
    @State private var transactionToDelete: Transaction?
    @State private var showingDeleteConfirmation = false

    init(viewModel: TransactionListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if viewModel.transactions.isEmpty {
                    emptyStateView
                } else {
                    transactionsList
                }
            }
            .navigationTitle("Budget Tracker")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddTransaction = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                viewModel.loadTransactions()
            } content: {
                TransactionFormView(
                    viewModel: TransactionFormViewModel(
                        createTransactionUseCase: dependencies.createTransactionUseCase,
                        updateTransactionUseCase: dependencies.updateTransactionUseCase,
                        deleteTransactionUseCase: dependencies.deleteTransactionUseCase
                    )
                )
            }
            .sheet(isPresented: $showingEditTransaction) {
                viewModel.loadTransactions()
            } content: {
                if let transaction = transactionToEdit {
                    TransactionFormView(
                        viewModel: TransactionFormViewModel(
                            createTransactionUseCase: dependencies.createTransactionUseCase,
                            updateTransactionUseCase: dependencies.updateTransactionUseCase,
                            deleteTransactionUseCase: dependencies.deleteTransactionUseCase,
                            transactionToEdit: transaction
                        )
                    )
                }
            }
            .alert("Delete Transaction", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let transaction = transactionToDelete {
                        viewModel.deleteTransaction(transaction)
                    }
                }
            } message: {
                if let transaction = transactionToDelete {
                    Text("Are you sure you want to delete '\(transaction.name)'?")
                }
            }
            .onAppear {
                viewModel.loadTransactions()
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No Transactions")
                .font(.title2)
            Text("Tap + to add your first transaction")
                .foregroundColor(.secondary)
        }
    }

    private var transactionsList: some View {
        List(viewModel.transactions) { transaction in
            TransactionRow(transaction: transaction)
                .contentShape(Rectangle())
                .onTapGesture {
                    transactionToEdit = transaction
                    showingEditTransaction = true
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        transactionToDelete = transaction
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
        }
    }
}

struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.name)
                    .font(.headline)
                Text(transaction.category.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(transaction.date, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(transaction.money.formatted)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
}
