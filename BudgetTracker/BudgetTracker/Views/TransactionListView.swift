import SwiftUI
import CoreData

struct TransactionListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)],
        animation: .default)
    private var transactions: FetchedResults<Transaction>

    @State private var showingAddTransaction = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                if transactions.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)

                        Text("No transactions yet")
                            .font(.title2)
                            .foregroundColor(.gray)

                        Text("Tap + to add your first transaction")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.7))
                    }
                } else {
                    List {
                        ForEach(transactions) { transaction in
                            TransactionRowView(transaction: transaction)
                                .listRowBackground(Color(white: 0.15))
                                .listRowSeparatorTint(.gray.opacity(0.3))
                        }
                        .onDelete(perform: deleteTransactions)
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddTransaction = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView()
            }
        }
        .preferredColorScheme(.dark)
    }

    private func deleteTransactions(offsets: IndexSet) {
        withAnimation {
            offsets.map { transactions[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                print("Error deleting transaction: \(error.localizedDescription)")
            }
        }
    }
}

struct TransactionRowView: View {
    let transaction: Transaction

    private var category: TransactionCategory? {
        TransactionCategory(rawValue: transaction.category ?? "Other")
    }

    private var currency: Currency? {
        Currency(rawValue: transaction.currency ?? "EUR")
    }

    var body: some View {
        HStack(spacing: 15) {
            // Category icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 45, height: 45)

                Image(systemName: category?.icon ?? "questionmark")
                    .foregroundColor(.blue)
                    .font(.system(size: 20))
            }

            // Transaction details
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.name ?? "Unknown")
                    .font(.headline)
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    Text(category?.rawValue ?? "Other")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text("•")
                        .foregroundColor(.gray)

                    Text(transaction.date ?? Date(), style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            // Amount
            Text("\(currency?.symbol ?? "€")\(transaction.amount, specifier: "%.2f")")
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    TransactionListView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
