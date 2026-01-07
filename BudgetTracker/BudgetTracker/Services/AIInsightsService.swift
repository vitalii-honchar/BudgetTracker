import Foundation

struct SpendingInsight: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: String
    let amount: Double
    let savings: Double
    let icon: String
    let priority: InsightPriority
}

enum InsightPriority: Int {
    case high = 3
    case medium = 2
    case low = 1
}

class AIInsightsService {
    static let shared = AIInsightsService()

    private init() {}

    func generateInsights(transactions: [Transaction], startDate: Date, endDate: Date) -> (summary: String, insights: [SpendingInsight]) {
        let filteredTransactions = transactions.filter { transaction in
            guard let date = transaction.date else { return false }
            return date >= startDate && date <= endDate
        }

        // Calculate statistics
        let totalSpent = filteredTransactions.reduce(0) { $0 + $1.amount }
        let categoryTotals = calculateCategoryTotals(transactions: filteredTransactions)
        let averageTransaction = totalSpent / Double(max(filteredTransactions.count, 1))

        // Generate AI summary
        let summary = generateSummary(
            totalSpent: totalSpent,
            transactionCount: filteredTransactions.count,
            categoryTotals: categoryTotals,
            averageTransaction: averageTransaction
        )

        // Generate optimization insights
        let insights = generateOptimizationInsights(
            categoryTotals: categoryTotals,
            totalSpent: totalSpent,
            transactions: filteredTransactions
        )

        return (summary, insights)
    }

    private func calculateCategoryTotals(transactions: [Transaction]) -> [String: Double] {
        var totals: [String: Double] = [:]
        for transaction in transactions {
            let category = transaction.category ?? "Other"
            totals[category, default: 0] += transaction.amount
        }
        return totals
    }

    private func generateSummary(totalSpent: Double, transactionCount: Int, categoryTotals: [String: Double], averageTransaction: Double) -> String {
        guard totalSpent > 0 else {
            return "No transactions found for the selected period. Start tracking your expenses to see AI-powered insights."
        }

        let topCategory = categoryTotals.max(by: { $0.value < $1.value })
        let topCategoryName = topCategory?.key ?? "Unknown"
        let topCategoryAmount = topCategory?.value ?? 0
        let topCategoryPercentage = (topCategoryAmount / totalSpent) * 100

        var summary = "During this period, you spent €\(String(format: "%.2f", totalSpent)) across \(transactionCount) transactions. "

        if categoryTotals.count > 1 {
            summary += "Your largest expense category was \(topCategoryName), accounting for \(String(format: "%.0f", topCategoryPercentage))% of your total spending. "
        }

        if averageTransaction > 0 {
            summary += "Your average transaction amount is €\(String(format: "%.2f", averageTransaction)). "
        }

        // Add spending pattern insight
        if topCategoryPercentage > 40 {
            summary += "You're heavily focused on \(topCategoryName) expenses, which might indicate an opportunity to diversify your budget."
        } else if categoryTotals.count >= 3 {
            summary += "Your spending is well-distributed across multiple categories, showing balanced financial habits."
        }

        return summary
    }

    private func generateOptimizationInsights(categoryTotals: [String: Double], totalSpent: Double, transactions: [Transaction]) -> [SpendingInsight] {
        var insights: [SpendingInsight] = []

        // Analyze each category for optimization opportunities
        for (category, amount) in categoryTotals.sorted(by: { $0.value > $1.value }) {
            let percentage = (amount / totalSpent) * 100
            let categoryTransactions = transactions.filter { $0.category == category }

            // High spending categories
            if percentage > 30 && amount > 100 {
                let potentialSavings = amount * 0.2 // Suggest 20% reduction
                insights.append(SpendingInsight(
                    title: "High \(category) Spending",
                    description: "You spent \(String(format: "%.0f", percentage))% of your budget on \(category). Consider reducing by 20% to save €\(String(format: "%.2f", potentialSavings)) per period.",
                    category: category,
                    amount: amount,
                    savings: potentialSavings,
                    icon: getCategoryIcon(category),
                    priority: .high
                ))
            }

            // Frequent small transactions
            let smallTransactions = categoryTransactions.filter { $0.amount < 10 }
            if smallTransactions.count >= 5 {
                let smallTotal = smallTransactions.reduce(0) { $0 + $1.amount }
                insights.append(SpendingInsight(
                    title: "Frequent Small \(category) Purchases",
                    description: "You made \(smallTransactions.count) small \(category) transactions totaling €\(String(format: "%.2f", smallTotal)). Consolidating purchases could save time and potentially reduce spending.",
                    category: category,
                    amount: smallTotal,
                    savings: smallTotal * 0.15,
                    icon: getCategoryIcon(category),
                    priority: .medium
                ))
            }

            // Entertainment/Shopping optimization
            if (category == "Entertainment" || category == "Shopping") && amount > 150 {
                insights.append(SpendingInsight(
                    title: "Optimize \(category) Budget",
                    description: "Your \(category) expenses are €\(String(format: "%.2f", amount)). Setting a monthly limit could help you save up to €\(String(format: "%.2f", amount * 0.25)) without sacrificing enjoyment.",
                    category: category,
                    amount: amount,
                    savings: amount * 0.25,
                    icon: getCategoryIcon(category),
                    priority: .medium
                ))
            }
        }

        // Add subscription/recurring payment insight
        let potentialRecurring = identifyRecurringPayments(transactions: transactions)
        if !potentialRecurring.isEmpty {
            let recurringTotal = potentialRecurring.reduce(0) { $0 + $1.amount }
            insights.append(SpendingInsight(
                title: "Review Recurring Payments",
                description: "Found \(potentialRecurring.count) potentially recurring payments totaling €\(String(format: "%.2f", recurringTotal)). Review subscriptions you might not be using.",
                category: "Bills",
                amount: recurringTotal,
                savings: recurringTotal * 0.3,
                icon: "arrow.clockwise.circle.fill",
                priority: .high
            ))
        }

        return insights.sorted { $0.priority.rawValue > $1.priority.rawValue }
    }

    private func identifyRecurringPayments(transactions: [Transaction]) -> [Transaction] {
        // Simple heuristic: find transactions with similar amounts
        var recurringCandidates: [Transaction] = []
        let grouped = Dictionary(grouping: transactions) { transaction -> Int in
            Int(transaction.amount * 100) // Group by cents
        }

        for (_, group) in grouped where group.count >= 2 {
            recurringCandidates.append(contentsOf: group)
        }

        return recurringCandidates
    }

    private func getCategoryIcon(_ category: String) -> String {
        switch category {
        case "Food": return "fork.knife"
        case "Transport": return "car.fill"
        case "Shopping": return "cart.fill"
        case "Entertainment": return "tv.fill"
        case "Bills": return "doc.text.fill"
        case "Health": return "cross.case.fill"
        case "Education": return "book.fill"
        default: return "ellipsis.circle.fill"
        }
    }
}
