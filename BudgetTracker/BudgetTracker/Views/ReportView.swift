import SwiftUI
import CoreData

struct ReportView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate = Date()
    @State private var transactions: [Transaction] = []
    @State private var categoryTotals: [(category: String, amount: Double, icon: String)] = []

    var totalSpent: Double {
        transactions.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 25) {
                        // Date Range Picker
                        VStack(spacing: 15) {
                            HStack {
                                Text("From")
                                    .foregroundColor(.gray)
                                    .frame(width: 60, alignment: .leading)

                                DatePicker("", selection: $startDate, displayedComponents: .date)
                                    .labelsHidden()
                                    .onChange(of: startDate) { _ in
                                        fetchTransactions()
                                    }
                            }
                            .padding()
                            .background(Color(white: 0.15))
                            .cornerRadius(12)

                            HStack {
                                Text("To")
                                    .foregroundColor(.gray)
                                    .frame(width: 60, alignment: .leading)

                                DatePicker("", selection: $endDate, displayedComponents: .date)
                                    .labelsHidden()
                                    .onChange(of: endDate) { _ in
                                        fetchTransactions()
                                    }
                            }
                            .padding()
                            .background(Color(white: 0.15))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)

                        // Total Spent Card
                        VStack(spacing: 10) {
                            Text("Total Spent")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            Text("€\(totalSpent, specifier: "%.2f")")
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(.white)

                            Text("\(transactions.count) transactions")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.1)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .padding(.horizontal)

                        // Category Breakdown
                        if !categoryTotals.isEmpty {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Spending by Category")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)

                                VStack(spacing: 12) {
                                    ForEach(categoryTotals, id: \.category) { item in
                                        CategoryRowView(
                                            category: item.category,
                                            icon: item.icon,
                                            amount: item.amount,
                                            percentage: totalSpent > 0 ? (item.amount / totalSpent) * 100 : 0
                                        )
                                    }
                                }
                                .padding()
                                .background(Color(white: 0.15))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                        }

                        Spacer(minLength: 20)
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Reports")
            .onAppear {
                fetchTransactions()
            }
        }
        .preferredColorScheme(.dark)
    }

    private func fetchTransactions() {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]

        do {
            transactions = try viewContext.fetch(request)
            calculateCategoryTotals()
        } catch {
            print("Error fetching transactions: \(error.localizedDescription)")
        }
    }

    private func calculateCategoryTotals() {
        var totals: [String: Double] = [:]

        for transaction in transactions {
            let category = transaction.category ?? "Other"
            totals[category, default: 0] += transaction.amount
        }

        categoryTotals = totals.map { (category, amount) in
            let cat = TransactionCategory(rawValue: category) ?? .other
            return (category: category, amount: amount, icon: cat.icon)
        }.sorted { $0.amount > $1.amount }
    }
}

struct CategoryRowView: View {
    let category: String
    let icon: String
    let amount: Double
    let percentage: Double

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .foregroundColor(.blue)
                        .frame(width: 24)

                    Text(category)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("€\(amount, specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    Text("\(percentage, specifier: "%.1f")%")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                        .cornerRadius(2)

                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * (percentage / 100), height: 4)
                        .cornerRadius(2)
                }
            }
            .frame(height: 4)
        }
    }
}

#Preview {
    ReportView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
