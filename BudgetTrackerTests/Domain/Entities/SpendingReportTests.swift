//
//  SpendingReportTests.swift
//  BudgetTrackerTests
//
//  Unit tests for SpendingReport Entity
//

import XCTest
@testable import BudgetTracker

final class SpendingReportTests: XCTestCase {

    // MARK: - Test Helpers

    private func createTestTransactions() throws -> [Transaction] {
        let categoryId1 = UUID()
        let categoryId2 = UUID()

        return [
            try Transaction.create(
                money: Money(amount: Decimal(50.00), currency: .USD),
                name: "Grocery",
                categoryId: categoryId1
            ),
            try Transaction.create(
                money: Money(amount: Decimal(30.00), currency: .USD),
                name: "Coffee",
                categoryId: categoryId2
            ),
            try Transaction.create(
                money: Money(amount: Decimal(20.00), currency: .USD),
                name: "Snack",
                categoryId: categoryId1
            )
        ]
    }

    // MARK: - Generation Tests

    func test_generate_withTransactions_createsValidReport() throws {
        // Arrange
        let transactions = try createTestTransactions()
        let dateRange = try DateRange(
            start: Date().addingTimeInterval(-86400 * 30),
            end: Date()
        )

        // Act
        let report = try SpendingReport.generate(from: transactions, dateRange: dateRange)

        // Assert
        XCTAssertEqual(report.transactionCount, 3)
        XCTAssertEqual(report.totalSpent.amount, Decimal(100.00))
        XCTAssertEqual(report.totalSpent.currency, .USD)
        XCTAssertEqual(report.categoryBreakdown.count, 2) // 2 unique categories
        XCTAssertTrue(report.hasTransactions)
    }

    func test_generate_withEmptyTransactions_createsEmptyReport() throws {
        // Arrange
        let transactions: [Transaction] = []
        let dateRange = try DateRange(start: Date(), end: Date().addingTimeInterval(86400))

        // Act
        let report = try SpendingReport.generate(from: transactions, dateRange: dateRange)

        // Assert
        XCTAssertEqual(report.transactionCount, 0)
        XCTAssertEqual(report.totalSpent.amount, Decimal(0))
        XCTAssertEqual(report.categoryBreakdown.count, 0)
        XCTAssertFalse(report.hasTransactions)
    }

    func test_generate_withTransactionsOutsideDateRange_excludesThem() throws {
        // Arrange
        let categoryId = UUID()
        let oldDate = Date().addingTimeInterval(-86400 * 60) // 60 days ago
        let transactions = [
            try Transaction.createDetailed(
                money: Money(amount: Decimal(50.00), currency: .USD),
                name: "Old Transaction",
                categoryId: categoryId,
                date: oldDate,
                description: nil,
                periodId: nil
            )
        ]
        let dateRange = try DateRange.lastDays(30) // Last 30 days

        // Act
        let report = try SpendingReport.generate(from: transactions, dateRange: dateRange)

        // Assert
        XCTAssertEqual(report.transactionCount, 0) // Should be excluded
        XCTAssertEqual(report.totalSpent.amount, Decimal(0))
    }

    func test_generate_calculatesAverageCorrectly() throws {
        // Arrange
        let categoryId = UUID()
        let transactions = [
            try Transaction.create(
                money: Money(amount: Decimal(100.00), currency: .USD),
                name: "Transaction 1",
                categoryId: categoryId
            ),
            try Transaction.create(
                money: Money(amount: Decimal(50.00), currency: .USD),
                name: "Transaction 2",
                categoryId: categoryId
            )
        ]
        let dateRange = try DateRange(start: Date(), end: Date().addingTimeInterval(86400))

        // Act
        let report = try SpendingReport.generate(from: transactions, dateRange: dateRange)

        // Assert
        XCTAssertEqual(report.averageTransactionAmount.amount, Decimal(75.00)) // (100 + 50) / 2
    }

    // MARK: - Category Breakdown Tests

    func test_generate_categoryBreakdownSortedByAmount() throws {
        // Arrange
        let categoryId1 = UUID()
        let categoryId2 = UUID()
        let transactions = [
            try Transaction.create(
                money: Money(amount: Decimal(100.00), currency: .USD),
                name: "Large",
                categoryId: categoryId1
            ),
            try Transaction.create(
                money: Money(amount: Decimal(20.00), currency: .USD),
                name: "Small",
                categoryId: categoryId2
            )
        ]
        let dateRange = try DateRange(start: Date(), end: Date().addingTimeInterval(86400))

        // Act
        let report = try SpendingReport.generate(from: transactions, dateRange: dateRange)

        // Assert
        XCTAssertEqual(report.categoryBreakdown.count, 2)
        XCTAssertEqual(report.categoryBreakdown[0].totalSpent.amount, Decimal(100.00)) // Largest first
        XCTAssertEqual(report.categoryBreakdown[1].totalSpent.amount, Decimal(20.00))
    }

    func test_generate_calculatesPercentagesCorrectly() throws {
        // Arrange
        let categoryId = UUID()
        let transactions = [
            try Transaction.create(
                money: Money(amount: Decimal(50.00), currency: .USD),
                name: "Transaction",
                categoryId: categoryId
            )
        ]
        let dateRange = try DateRange(start: Date(), end: Date().addingTimeInterval(86400))

        // Act
        let report = try SpendingReport.generate(from: transactions, dateRange: dateRange)

        // Assert
        XCTAssertEqual(report.categoryBreakdown.count, 1)
        XCTAssertEqual(report.categoryBreakdown[0].percentageOfTotal, 100.0) // 100% of total
    }

    func test_generate_aggregatesMultipleTransactionsPerCategory() throws {
        // Arrange
        let categoryId = UUID()
        let transactions = [
            try Transaction.create(
                money: Money(amount: Decimal(30.00), currency: .USD),
                name: "Transaction 1",
                categoryId: categoryId
            ),
            try Transaction.create(
                money: Money(amount: Decimal(20.00), currency: .USD),
                name: "Transaction 2",
                categoryId: categoryId
            )
        ]
        let dateRange = try DateRange(start: Date(), end: Date().addingTimeInterval(86400))

        // Act
        let report = try SpendingReport.generate(from: transactions, dateRange: dateRange)

        // Assert
        XCTAssertEqual(report.categoryBreakdown.count, 1) // One category
        XCTAssertEqual(report.categoryBreakdown[0].totalSpent.amount, Decimal(50.00)) // 30 + 20
        XCTAssertEqual(report.categoryBreakdown[0].transactionCount, 2)
    }

    // MARK: - Business Logic Tests

    func test_spendingForCategory_withExistingCategory_returnsSpending() throws {
        // Arrange
        let categoryId = UUID()
        let transactions = [
            try Transaction.create(
                money: Money(amount: Decimal(50.00), currency: .USD),
                name: "Transaction",
                categoryId: categoryId
            )
        ]
        let dateRange = try DateRange(start: Date(), end: Date().addingTimeInterval(86400))
        let report = try SpendingReport.generate(from: transactions, dateRange: dateRange)

        // Act
        let spending = report.spendingForCategory(categoryId)

        // Assert
        XCTAssertNotNil(spending)
        XCTAssertEqual(spending?.totalSpent.amount, Decimal(50.00))
    }

    func test_spendingForCategory_withNonexistentCategory_returnsNil() throws {
        // Arrange
        let categoryId = UUID()
        let transactions = [
            try Transaction.create(
                money: Money(amount: Decimal(50.00), currency: .USD),
                name: "Transaction",
                categoryId: categoryId
            )
        ]
        let dateRange = try DateRange(start: Date(), end: Date().addingTimeInterval(86400))
        let report = try SpendingReport.generate(from: transactions, dateRange: dateRange)

        // Act
        let spending = report.spendingForCategory(UUID()) // Different ID

        // Assert
        XCTAssertNil(spending)
    }

    func test_topCategories_returnsCorrectNumber() throws {
        // Arrange
        let transactions = try createTestTransactions()
        let dateRange = try DateRange(start: Date(), end: Date().addingTimeInterval(86400))
        let report = try SpendingReport.generate(from: transactions, dateRange: dateRange)

        // Act
        let top = report.topCategories(limit: 1)

        // Assert
        XCTAssertEqual(top.count, 1)
        XCTAssertEqual(top[0].totalSpent.amount, Decimal(70.00)) // Largest category
    }

    func test_hasTransactions_withTransactions_returnsTrue() throws {
        // Arrange
        let transactions = try createTestTransactions()
        let dateRange = try DateRange(start: Date(), end: Date().addingTimeInterval(86400))
        let report = try SpendingReport.generate(from: transactions, dateRange: dateRange)

        // Act & Assert
        XCTAssertTrue(report.hasTransactions)
    }

    func test_hasTransactions_withoutTransactions_returnsFalse() throws {
        // Arrange
        let dateRange = try DateRange(start: Date(), end: Date().addingTimeInterval(86400))
        let report = try SpendingReport.generate(from: [], dateRange: dateRange)

        // Act & Assert
        XCTAssertFalse(report.hasTransactions)
    }

    func test_dailyAverage_withKnownPeriod_calculatesCorrectly() throws {
        // Arrange
        let categoryId = UUID()
        let transactions = [
            try Transaction.create(
                money: Money(amount: Decimal(100.00), currency: .USD),
                name: "Transaction",
                categoryId: categoryId
            )
        ]
        let dateRange = try DateRange(
            start: Date(timeIntervalSince1970: 0),
            end: Date(timeIntervalSince1970: 86400 * 10) // 10 days
        )
        let report = try SpendingReport.generate(from: transactions, dateRange: dateRange)

        // Act
        let dailyAvg = report.dailyAverage

        // Assert
        XCTAssertNotNil(dailyAvg)
        XCTAssertEqual(dailyAvg?.amount, Decimal(10.00)) // 100 / 10 days
    }

    func test_dailyAverage_withOngoingPeriod_returnsNil() throws {
        // Arrange
        let categoryId = UUID()
        let transactions = [
            try Transaction.create(
                money: Money(amount: Decimal(100.00), currency: .USD),
                name: "Transaction",
                categoryId: categoryId
            )
        ]
        let dateRange = try DateRange(start: Date(), end: nil) // Ongoing
        let report = try SpendingReport.generate(from: transactions, dateRange: dateRange)

        // Act
        let dailyAvg = report.dailyAverage

        // Assert
        XCTAssertNil(dailyAvg)
    }

    // MARK: - CategorySpending Tests

    func test_categorySpending_formattedPercentage_returnsCorrectFormat() {
        // Arrange
        let categorySpending = CategorySpending(
            categoryId: UUID(),
            totalSpent: Money(amount: Decimal(50.00), currency: .USD),
            transactionCount: 2,
            percentageOfTotal: 33.33
        )

        // Act
        let formatted = categorySpending.formattedPercentage

        // Assert
        XCTAssertEqual(formatted, "33.3%")
    }

    func test_categorySpending_averagePerTransaction_calculatesCorrectly() {
        // Arrange
        let categorySpending = CategorySpending(
            categoryId: UUID(),
            totalSpent: Money(amount: Decimal(100.00), currency: .USD),
            transactionCount: 4,
            percentageOfTotal: 100.0
        )

        // Act
        let average = categorySpending.averagePerTransaction

        // Assert
        XCTAssertNotNil(average)
        XCTAssertEqual(average?.amount, Decimal(25.00)) // 100 / 4
    }

    func test_categorySpending_averagePerTransaction_withZeroTransactions_returnsNil() {
        // Arrange
        let categorySpending = CategorySpending(
            categoryId: UUID(),
            totalSpent: Money(amount: Decimal(0), currency: .USD),
            transactionCount: 0,
            percentageOfTotal: 0.0
        )

        // Act
        let average = categorySpending.averagePerTransaction

        // Assert
        XCTAssertNil(average)
    }

    // MARK: - Summary Tests

    func test_summary_withTransactions_returnsCorrectSummary() throws {
        // Arrange
        let transactions = try createTestTransactions()
        let dateRange = try DateRange(start: Date(), end: Date().addingTimeInterval(86400))
        let report = try SpendingReport.generate(from: transactions, dateRange: dateRange)

        // Act
        let summary = report.summary

        // Assert
        XCTAssertTrue(summary.contains("3 transactions"))
        XCTAssertTrue(summary.contains("100") || summary.contains("100.00"))
    }

    func test_summary_withNoTransactions_returnsNoDataMessage() throws {
        // Arrange
        let dateRange = try DateRange(start: Date(), end: Date().addingTimeInterval(86400))
        let report = try SpendingReport.generate(from: [], dateRange: dateRange)

        // Act
        let summary = report.summary

        // Assert
        XCTAssertTrue(summary.contains("No transactions"))
    }

    func test_detailedSummary_includesAverages() throws {
        // Arrange
        let transactions = try createTestTransactions()
        let dateRange = try DateRange(start: Date(), end: Date().addingTimeInterval(86400))
        let report = try SpendingReport.generate(from: transactions, dateRange: dateRange)

        // Act
        let detailedSummary = report.detailedSummary

        // Assert
        XCTAssertTrue(detailedSummary.contains("Average per transaction"))
    }
}
