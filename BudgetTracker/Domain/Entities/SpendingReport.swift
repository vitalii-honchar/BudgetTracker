//
//  SpendingReport.swift
//  BudgetTracker
//
//  Domain Layer - Entity (Aggregate)
//  Pure Swift, zero dependencies
//

import Foundation

/// SpendingReport represents aggregated spending analytics for a date range
/// Entity/Aggregate: Computed from transactions, provides insights
struct SpendingReport: Codable, Equatable {
    let dateRange: DateRange
    let totalSpent: Money
    let transactionCount: Int
    let categoryBreakdown: [CategorySpending]
    let averageTransactionAmount: Money
    let generatedAt: Date

    // MARK: - Initialization

    init(
        dateRange: DateRange,
        totalSpent: Money,
        transactionCount: Int,
        categoryBreakdown: [CategorySpending],
        averageTransactionAmount: Money,
        generatedAt: Date = Date()
    ) {
        self.dateRange = dateRange
        self.totalSpent = totalSpent
        self.transactionCount = transactionCount
        self.categoryBreakdown = categoryBreakdown
        self.averageTransactionAmount = averageTransactionAmount
        self.generatedAt = generatedAt
    }

    // MARK: - Factory Methods

    /// Generate a spending report from a list of transactions
    static func generate(
        from transactions: [Transaction],
        dateRange: DateRange
    ) throws -> SpendingReport {
        // Filter transactions within date range
        let relevantTransactions = transactions.filter { dateRange.contains($0.date) }

        guard !relevantTransactions.isEmpty else {
            // Return empty report if no transactions
            let currency = transactions.first?.money.currency ?? .USD
            return SpendingReport(
                dateRange: dateRange,
                totalSpent: Money.zero(currency),
                transactionCount: 0,
                categoryBreakdown: [],
                averageTransactionAmount: Money.zero(currency),
                generatedAt: Date()
            )
        }

        // Calculate total spent
        let currency = relevantTransactions[0].money.currency
        var total = Money.zero(currency)

        for transaction in relevantTransactions {
            total = try total.add(transaction.money)
        }

        // Calculate category breakdown
        var categoryTotals: [UUID: Money] = [:]
        var categoryTransactionCounts: [UUID: Int] = [:]

        for transaction in relevantTransactions {
            let categoryId = transaction.categoryId

            if let existing = categoryTotals[categoryId] {
                categoryTotals[categoryId] = try existing.add(transaction.money)
            } else {
                categoryTotals[categoryId] = transaction.money
            }

            categoryTransactionCounts[categoryId, default: 0] += 1
        }

        let categoryBreakdown = categoryTotals.map { (categoryId, amount) in
            CategorySpending(
                categoryId: categoryId,
                totalSpent: amount,
                transactionCount: categoryTransactionCounts[categoryId] ?? 0,
                percentageOfTotal: calculatePercentage(amount: amount, total: total)
            )
        }.sorted { $0.totalSpent.amount > $1.totalSpent.amount }

        // Calculate average transaction amount
        let average = total.divide(by: Decimal(relevantTransactions.count))

        return SpendingReport(
            dateRange: dateRange,
            totalSpent: total,
            transactionCount: relevantTransactions.count,
            categoryBreakdown: categoryBreakdown,
            averageTransactionAmount: try average,
            generatedAt: Date()
        )
    }

    // MARK: - Business Logic

    /// Get spending for a specific category
    func spendingForCategory(_ categoryId: UUID) -> CategorySpending? {
        return categoryBreakdown.first { $0.categoryId == categoryId }
    }

    /// Get top N spending categories
    func topCategories(limit: Int = 5) -> [CategorySpending] {
        return Array(categoryBreakdown.prefix(limit))
    }

    /// Check if there were any transactions
    var hasTransactions: Bool {
        return transactionCount > 0
    }

    /// Daily average spending (total / days in period)
    var dailyAverage: Money? {
        guard let days = dateRange.durationInDays, days > 0 else {
            return nil
        }
        return try? totalSpent.divide(by: Decimal(days))
    }

    /// Formatted total spent
    var formattedTotal: String {
        return totalSpent.formatted
    }

    /// Formatted average transaction
    var formattedAverage: String {
        return averageTransactionAmount.formatted
    }

    // MARK: - Private Helpers

    private static func calculatePercentage(amount: Money, total: Money) -> Double {
        guard total.amount > 0 else { return 0 }
        let percentage = (amount.amount / total.amount) * 100
        return NSDecimalNumber(decimal: percentage).doubleValue
    }
}

// MARK: - Category Spending

/// CategorySpending represents spending data for a single category
struct CategorySpending: Codable, Equatable {
    let categoryId: UUID
    let totalSpent: Money
    let transactionCount: Int
    let percentageOfTotal: Double

    // MARK: - Computed Properties

    /// Formatted total spent
    var formattedTotal: String {
        return totalSpent.formatted
    }

    /// Formatted percentage
    var formattedPercentage: String {
        return String(format: "%.1f%%", percentageOfTotal)
    }

    /// Average per transaction
    var averagePerTransaction: Money? {
        guard transactionCount > 0 else { return nil }
        return try? totalSpent.divide(by: Decimal(transactionCount))
    }
}

// MARK: - Errors

enum SpendingReportError: Error, Equatable {
    case noTransactions
    case currencyMismatch
    case invalidDateRange

    var localizedDescription: String {
        switch self {
        case .noTransactions:
            return "No transactions found for the specified period"
        case .currencyMismatch:
            return "Transactions have different currencies"
        case .invalidDateRange:
            return "Invalid date range for report generation"
        }
    }
}

// MARK: - Extensions

extension SpendingReport {
    /// Summary string for display
    var summary: String {
        let period = dateRange.shortFormatted
        let count = transactionCount
        let total = formattedTotal

        if transactionCount == 0 {
            return "No transactions in \(period)"
        } else if transactionCount == 1 {
            return "1 transaction totaling \(total) in \(period)"
        } else {
            return "\(count) transactions totaling \(total) in \(period)"
        }
    }

    /// Detailed summary with average
    var detailedSummary: String {
        guard hasTransactions else {
            return "No spending data available for this period"
        }

        let basicSummary = summary
        let avgTransaction = formattedAverage

        if let dailyAvg = dailyAverage {
            return "\(basicSummary)\nAverage per transaction: \(avgTransaction)\nDaily average: \(dailyAvg.formatted)"
        } else {
            return "\(basicSummary)\nAverage per transaction: \(avgTransaction)"
        }
    }
}
