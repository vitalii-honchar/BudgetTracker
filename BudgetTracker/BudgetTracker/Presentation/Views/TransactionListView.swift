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
                        createTransactionUseCase: dependencies.createTransactionUseCase
                    )
                )
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
