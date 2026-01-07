import SwiftUI
import CoreData

struct AIInsightsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate = Date()
    @State private var transactions: [Transaction] = []
    @State private var summary: String = ""
    @State private var insights: [SpendingInsight] = []
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 25) {
                        // AI Header
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 28))
                                .foregroundColor(.blue)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("AI Insights")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)

                                HStack(spacing: 6) {
                                    Image(systemName: "iphone")
                                        .font(.caption2)
                                    Text("On-Device AI • 100% Private")
                                        .font(.caption)
                                }
                                .foregroundColor(.green)
                            }

                            Spacer()

                            // Privacy badge
                            VStack(spacing: 2) {
                                Image(systemName: "lock.shield.fill")
                                    .foregroundColor(.green)
                                Text("Private")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .padding(.horizontal)

                        // Date Range Picker
                        VStack(spacing: 15) {
                            HStack {
                                Text("From")
                                    .foregroundColor(.gray)
                                    .frame(width: 60, alignment: .leading)

                                DatePicker("", selection: $startDate, displayedComponents: .date)
                                    .labelsHidden()
                                    .onChange(of: startDate) { _ in
                                        generateInsights()
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
                                        generateInsights()
                                    }
                            }
                            .padding()
                            .background(Color(white: 0.15))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)

                        // AI Summary Card
                        if !summary.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(.yellow)
                                    Text("Smart Summary")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }

                                Text(summary)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineSpacing(6)
                            }
                            .padding(20)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(white: 0.15), Color(white: 0.12)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }

                        // Optimization Insights
                        if !insights.isEmpty {
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .foregroundColor(.green)
                                    Text("Optimization Opportunities")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal)

                                VStack(spacing: 12) {
                                    ForEach(insights) { insight in
                                        InsightCardView(insight: insight)
                                    }
                                }
                            }
                        }

                        // Empty state
                        if summary.isEmpty && !isLoading {
                            VStack(spacing: 15) {
                                Image(systemName: "chart.bar.doc.horizontal")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)

                                Text("No data yet")
                                    .font(.headline)
                                    .foregroundColor(.gray)

                                Text("Add some transactions to see AI-powered insights")
                                    .font(.caption)
                                    .foregroundColor(.gray.opacity(0.7))
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 50)
                        }

                        Spacer(minLength: 20)
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("AI Insights")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                fetchTransactions()
                generateInsights()
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
        } catch {
            print("Error fetching transactions: \(error.localizedDescription)")
        }
    }

    private func generateInsights() {
        isLoading = true
        fetchTransactions()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let result = AIInsightsService.shared.generateInsights(
                transactions: transactions,
                startDate: startDate,
                endDate: endDate
            )

            withAnimation {
                summary = result.summary
                insights = result.insights
                isLoading = false
            }
        }
    }
}

struct InsightCardView: View {
    let insight: SpendingInsight

    var priorityColor: Color {
        switch insight.priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .yellow
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(priorityColor.opacity(0.2))
                        .frame(width: 40, height: 40)

                    Image(systemName: insight.icon)
                        .foregroundColor(priorityColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(insight.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.green)

                        Text("Potential savings: €\(insight.savings, specifier: "%.2f")")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }

                Spacer()

                // Priority indicator
                Circle()
                    .fill(priorityColor)
                    .frame(width: 8, height: 8)
            }

            Text(insight.description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4)

            // Savings visualization
            if insight.amount > 0 {
                HStack {
                    Text("Current: €\(insight.amount, specifier: "%.2f")")
                        .font(.caption2)
                        .foregroundColor(.gray)

                    Spacer()

                    Text("After: €\(insight.amount - insight.savings, specifier: "%.2f")")
                        .font(.caption2)
                        .foregroundColor(.green)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 4)
                            .cornerRadius(2)

                        Rectangle()
                            .fill(priorityColor)
                            .frame(width: geometry.size.width * CGFloat((insight.amount - insight.savings) / insight.amount), height: 4)
                            .cornerRadius(2)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(16)
        .background(Color(white: 0.15))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(priorityColor.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

#Preview {
    AIInsightsView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
