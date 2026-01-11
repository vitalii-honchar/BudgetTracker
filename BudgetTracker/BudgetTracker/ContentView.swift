//
//  ContentView.swift
//  BudgetTracker
//
//  Created by Vitalii Honchar on 2026-01-09.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.dependencies) private var dependencies

    var body: some View {
        TransactionListView(
            viewModel: TransactionListViewModel(
                getTransactionsUseCase: dependencies.getTransactionsUseCase
            )
        )
    }
}
