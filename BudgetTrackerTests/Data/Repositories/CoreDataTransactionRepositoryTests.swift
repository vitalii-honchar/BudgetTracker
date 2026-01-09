//
//  CoreDataTransactionRepositoryTests.swift
//  BudgetTrackerTests
//
//  Integration tests for CoreDataTransactionRepository
//

import XCTest
import CoreData
@testable import BudgetTracker

final class CoreDataTransactionRepositoryTests: XCTestCase {

    // MARK: - Test Infrastructure

    var repository: CoreDataTransactionRepository!
    var categoryRepository: CoreDataCategoryRepository!
    var periodRepository: CoreDataExpensePeriodRepository!
    var coreDataStack: CoreDataStack!

    var testCategory: Category!
    var testPeriod: ExpensePeriod!

    override func setUp() async throws {
        try await super.setUp()
        coreDataStack = CoreDataStack.preview
        repository = CoreDataTransactionRepository(coreDataStack: coreDataStack)
        categoryRepository = CoreDataCategoryRepository(coreDataStack: coreDataStack)
        periodRepository = CoreDataExpensePeriodRepository(coreDataStack: coreDataStack)

        // Create test category
        testCategory = try Category(
            name: "Test Category",
            icon: "star.fill",
            colorHex: "#FF6B6B",
            isCustom: false,
            sortOrder: 1
        )
        testCategory = try await categoryRepository.create(category: testCategory)

        // Create test period
        let dateRange = try DateRange(
            start: Date(timeIntervalSince1970: 0),
            end: Date(timeIntervalSince1970: 86400 * 30)
        )
        testPeriod = try ExpensePeriod(name: "Test Period", dateRange: dateRange)
        testPeriod = try await periodRepository.create(period: testPeriod)
    }

    override func tearDown() async throws {
        testCategory = nil
        testPeriod = nil
        repository = nil
        categoryRepository = nil
        periodRepository = nil
        coreDataStack = nil
        try await super.tearDown()
    }

    // MARK: - Create Tests

    func test_create_withValidTransaction_savesAndReturnsTransaction() async throws {
        // Arrange
        let money = Money(amount: Decimal(42.50), currency: .USD)
        let transaction = try Transaction.create(
            money: money,
            name: "Coffee",
            categoryId: testCategory.id
        )

        // Act
        let result = try await repository.create(transaction: transaction)

        // Assert
        XCTAssertEqual(result.id, transaction.id)
        XCTAssertEqual(result.name, "Coffee")
        XCTAssertEqual(result.money.amount, Decimal(42.50))

        // Verify persisted
        let found = try await repository.findById(id: transaction.id)
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.name, "Coffee")
    }

    func test_create_withPeriod_linksTransactionToPeriod() async throws {
        // Arrange
        let money = Money(amount: Decimal(100.00), currency: .USD)
        let transaction = try Transaction.createDetailed(
            money: money,
            name: "Dinner",
            categoryId: testCategory.id,
            date: Date(),
            description: "Business dinner",
            periodId: testPeriod.id
        )

        // Act
        let result = try await repository.create(transaction: transaction)

        // Assert
        XCTAssertEqual(result.periodId, testPeriod.id)
    }

    // MARK: - Find Tests

    func test_findById_withExistingTransaction_returnsTransaction() async throws {
        // Arrange
        let money = Money(amount: Decimal(50.00), currency: .USD)
        let transaction = try Transaction.create(
            money: money,
            name: "Lunch",
            categoryId: testCategory.id
        )
        _ = try await repository.create(transaction: transaction)

        // Act
        let result = try await repository.findById(id: transaction.id)

        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, transaction.id)
        XCTAssertEqual(result?.name, "Lunch")
    }

    func test_findById_withNonexistentId_returnsNil() async throws {
        // Act
        let result = try await repository.findById(id: UUID())

        // Assert
        XCTAssertNil(result)
    }

    func test_findAll_returnsAllTransactions() async throws {
        // Arrange
        _ = try await createTransaction(amount: 10.00, name: "Coffee")
        _ = try await createTransaction(amount: 25.50, name: "Lunch")
        _ = try await createTransaction(amount: 100.00, name: "Dinner")

        // Act
        let result = try await repository.findAll()

        // Assert
        XCTAssertEqual(result.count, 3)
    }

    func test_findByCategory_returnsTransactionsForCategory() async throws {
        // Arrange
        let category2 = try Category(
            name: "Other",
            icon: "star.fill",
            colorHex: "#00FF00",
            isCustom: false,
            sortOrder: 2
        )
        let created2 = try await categoryRepository.create(category: category2)

        _ = try await createTransaction(amount: 10.00, name: "Cat1-1", categoryId: testCategory.id)
        _ = try await createTransaction(amount: 20.00, name: "Cat2-1", categoryId: created2.id)
        _ = try await createTransaction(amount: 30.00, name: "Cat1-2", categoryId: testCategory.id)

        // Act
        let result = try await repository.findByCategory(categoryId: testCategory.id)

        // Assert
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { $0.categoryId == testCategory.id })
    }

    func test_findByPeriod_returnsTransactionsForPeriod() async throws {
        // Arrange
        _ = try await createTransaction(amount: 10.00, name: "With Period", periodId: testPeriod.id)
        _ = try await createTransaction(amount: 20.00, name: "Without Period")
        _ = try await createTransaction(amount: 30.00, name: "Also With Period", periodId: testPeriod.id)

        // Act
        let result = try await repository.findByPeriod(periodId: testPeriod.id)

        // Assert
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { $0.periodId == testPeriod.id })
    }

    func test_findByDateRange_returnsTransactionsInRange() async throws {
        // Arrange
        let start = Date(timeIntervalSince1970: 0)
        let middle = Date(timeIntervalSince1970: 86400 * 15)
        let end = Date(timeIntervalSince1970: 86400 * 30)

        _ = try await createTransaction(amount: 10.00, name: "Before", date: start.addingTimeInterval(-86400))
        _ = try await createTransaction(amount: 20.00, name: "In Range 1", date: start.addingTimeInterval(86400))
        _ = try await createTransaction(amount: 30.00, name: "In Range 2", date: middle)
        _ = try await createTransaction(amount: 40.00, name: "After", date: end.addingTimeInterval(86400))

        // Act
        let dateRange = try DateRange(start: start, end: end)
        let result = try await repository.findByDateRange(dateRange: dateRange)

        // Assert
        XCTAssertEqual(result.count, 2)
    }

    // MARK: - Update Tests

    func test_update_withValidChanges_updatesTransaction() async throws {
        // Arrange
        let money = Money(amount: Decimal(50.00), currency: .USD)
        let original = try Transaction.create(
            money: money,
            name: "Old Name",
            categoryId: testCategory.id
        )
        let created = try await repository.create(transaction: original)

        // Modify
        var updated = created
        try updated.updateName("New Name")

        // Act
        let result = try await repository.update(transaction: updated)

        // Assert
        XCTAssertEqual(result.name, "New Name")
        XCTAssertEqual(result.id, original.id)

        // Verify persisted
        let found = try await repository.findById(id: original.id)
        XCTAssertEqual(found?.name, "New Name")
    }

    func test_update_withNonexistentId_throwsError() async throws {
        // Arrange
        let money = Money(amount: Decimal(50.00), currency: .USD)
        let transaction = try Transaction.create(
            money: money,
            name: "Test",
            categoryId: testCategory.id
        )

        // Act & Assert
        do {
            _ = try await repository.update(transaction: transaction)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is RepositoryError)
        }
    }

    // MARK: - Delete Tests

    func test_delete_withExistingTransaction_deletesSuccessfully() async throws {
        // Arrange
        let transaction = try await createTransaction(amount: 50.00, name: "To Delete")

        // Act
        try await repository.delete(id: transaction.id)

        // Assert
        let found = try await repository.findById(id: transaction.id)
        XCTAssertNil(found)
    }

    func test_delete_withNonexistentId_throwsError() async throws {
        // Act & Assert
        do {
            try await repository.delete(id: UUID())
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is RepositoryError)
        }
    }

    // MARK: - Aggregation Tests

    func test_totalSpent_withTransactions_returnsTotal() async throws {
        // Arrange
        _ = try await createTransaction(amount: 10.00, name: "A", date: Date(timeIntervalSince1970: 86400))
        _ = try await createTransaction(amount: 20.00, name: "B", date: Date(timeIntervalSince1970: 86400 * 2))
        _ = try await createTransaction(amount: 30.00, name: "C", date: Date(timeIntervalSince1970: 86400 * 3))

        // Act
        let dateRange = try DateRange(
            start: Date(timeIntervalSince1970: 0),
            end: Date(timeIntervalSince1970: 86400 * 10)
        )
        let result = try await repository.totalSpent(in: dateRange)

        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.amount, Decimal(60.00))
    }

    func test_totalSpent_withNoTransactions_returnsNil() async throws {
        // Act
        let dateRange = try DateRange(
            start: Date(timeIntervalSince1970: 0),
            end: Date(timeIntervalSince1970: 86400 * 10)
        )
        let result = try await repository.totalSpent(in: dateRange)

        // Assert
        XCTAssertNil(result)
    }

    func test_averageAmount_withTransactions_returnsAverage() async throws {
        // Arrange
        _ = try await createTransaction(amount: 10.00, name: "A", date: Date(timeIntervalSince1970: 86400))
        _ = try await createTransaction(amount: 20.00, name: "B", date: Date(timeIntervalSince1970: 86400 * 2))
        _ = try await createTransaction(amount: 30.00, name: "C", date: Date(timeIntervalSince1970: 86400 * 3))

        // Act
        let dateRange = try DateRange(
            start: Date(timeIntervalSince1970: 0),
            end: Date(timeIntervalSince1970: 86400 * 10)
        )
        let result = try await repository.averageAmount(in: dateRange)

        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.amount, Decimal(20.00)) // (10 + 20 + 30) / 3
    }

    func test_count_returnsCorrectCount() async throws {
        // Arrange
        _ = try await createTransaction(amount: 10.00, name: "A", date: Date(timeIntervalSince1970: 86400))
        _ = try await createTransaction(amount: 20.00, name: "B", date: Date(timeIntervalSince1970: 86400 * 2))

        // Act
        let dateRange = try DateRange(
            start: Date(timeIntervalSince1970: 0),
            end: Date(timeIntervalSince1970: 86400 * 10)
        )
        let count = try await repository.count(in: dateRange)

        // Assert
        XCTAssertEqual(count, 2)
    }

    func test_findRecent_returnsLimitedResults() async throws {
        // Arrange
        for i in 0..<10 {
            let date = Date(timeIntervalSince1970: 86400 * Double(i))
            _ = try await createTransaction(amount: 10.00, name: "T\(i)", date: date)
        }

        // Act
        let result = try await repository.findRecent(limit: 5)

        // Assert
        XCTAssertEqual(result.count, 5)
        // Should be most recent (highest date)
        XCTAssertEqual(result[0].name, "T9")
    }

    // MARK: - Test Helpers

    @discardableResult
    private func createTransaction(
        amount: Double,
        name: String,
        categoryId: UUID? = nil,
        periodId: UUID? = nil,
        date: Date = Date()
    ) async throws -> Transaction {
        let money = Money(amount: Decimal(amount), currency: .USD)
        let transaction = try Transaction.createDetailed(
            money: money,
            name: name,
            categoryId: categoryId ?? testCategory.id,
            date: date,
            description: nil,
            periodId: periodId
        )
        return try await repository.create(transaction: transaction)
    }
}
