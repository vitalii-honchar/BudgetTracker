//
//  CoreDataTransactionRepositoryTests.swift
//  BudgetTrackerTests
//
//  Created by Claude Code on 1/11/26.
//

import XCTest
import CoreData
@testable import BudgetTracker

final class CoreDataTransactionRepositoryTests: XCTestCase {
    var sut: CoreDataTransactionRepository!
    var context: NSManagedObjectContext!
    var container: NSPersistentContainer!

    override func setUp() {
        super.setUp()
        container = InMemoryCoreDataStack.create()
        context = container.viewContext
        sut = CoreDataTransactionRepository(context: context)
    }

    override func tearDown() {
        sut = nil
        context = nil
        container = nil
        super.tearDown()
    }

    // MARK: - Helper

    private func createTestTransaction() throws -> Transaction {
        let money = try Money(amount: 42.50, currency: .USD)
        return try Transaction(
            money: money,
            name: "Test Transaction",
            category: .food,
            date: Date()
        )
    }

    // MARK: - Create Tests

    func test_create_persistsToDatabase() async throws {
        // Arrange
        let transaction = try createTestTransaction()

        // Act
        _ = try await sut.create(transaction: transaction)

        // Assert
        let fetchRequest: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        let results = try context.fetch(fetchRequest)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Test Transaction")
        XCTAssertEqual(results.first?.amount as Decimal?, 42.50)
    }

    func test_create_returnsTransaction() async throws {
        // Arrange
        let transaction = try createTestTransaction()

        // Act
        let result = try await sut.create(transaction: transaction)

        // Assert
        XCTAssertEqual(result.id, transaction.id)
        XCTAssertEqual(result.name, "Test Transaction")
    }

    // MARK: - FindAll Tests

    func test_findAll_withNoTransactions_returnsEmptyArray() async throws {
        // Act
        let result = try await sut.findAll()

        // Assert
        XCTAssertTrue(result.isEmpty)
    }

    func test_findAll_returnsAllTransactions() async throws {
        // Arrange
        let transaction1 = try createTestTransaction()
        let transaction2 = try Money(amount: 25, currency: .EUR)
        let tx2 = try Transaction(money: transaction2, name: "Second", category: .transport, date: Date())

        _ = try await sut.create(transaction: transaction1)
        _ = try await sut.create(transaction: tx2)

        // Act
        let result = try await sut.findAll()

        // Assert
        XCTAssertEqual(result.count, 2)
    }

    func test_findAll_sortsByDateDescending() async throws {
        // Arrange
        let oldDate = Date().addingTimeInterval(-86400) // Yesterday
        let newDate = Date() // Today

        let oldMoney = try Money(amount: 10, currency: .USD)
        let newMoney = try Money(amount: 20, currency: .USD)

        let oldTransaction = try Transaction(money: oldMoney, name: "Old", category: .food, date: oldDate)
        let newTransaction = try Transaction(money: newMoney, name: "New", category: .food, date: newDate)

        _ = try await sut.create(transaction: oldTransaction)
        _ = try await sut.create(transaction: newTransaction)

        // Act
        let result = try await sut.findAll()

        // Assert
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].name, "New") // Newest first
        XCTAssertEqual(result[1].name, "Old")
    }

    // MARK: - Update Tests

    func test_update_existingTransaction_updatesInDatabase() async throws {
        // Arrange
        let original = try createTestTransaction()
        _ = try await sut.create(transaction: original)

        let updatedMoney = try Money(amount: 99.99, currency: .EUR)
        let updated = try Transaction(
            id: original.id,
            money: updatedMoney,
            name: "Updated Name",
            category: .shopping,
            date: original.date,
            description: "Updated description"
        )

        // Act
        let result = try await sut.update(transaction: updated)

        // Assert
        XCTAssertEqual(result.id, original.id)
        XCTAssertEqual(result.name, "Updated Name")
        XCTAssertEqual(result.money.amount, 99.99)
        XCTAssertEqual(result.money.currency, .EUR)
        XCTAssertEqual(result.category, .shopping)
        XCTAssertEqual(result.description, "Updated description")

        // Verify in database
        let fetchRequest: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        let results = try context.fetch(fetchRequest)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Updated Name")
        XCTAssertEqual(results.first?.amount as Decimal?, 99.99)
        XCTAssertEqual(results.first?.currencyCode, "EUR")
    }

    func test_update_nonExistentTransaction_throwsNotFoundError() async throws {
        // Arrange
        let transaction = try createTestTransaction()

        // Act/Assert
        do {
            _ = try await sut.update(transaction: transaction)
            XCTFail("Expected notFound error")
        } catch let error as RepositoryError {
            XCTAssertEqual(error, .notFound)
        }
    }

    func test_update_updatesAllFields() async throws {
        // Arrange
        let original = try createTestTransaction()
        _ = try await sut.create(transaction: original)

        let newDate = Date().addingTimeInterval(3600)
        let updatedMoney = try Money(amount: 123.45, currency: .GBP)
        let updated = try Transaction(
            id: original.id,
            money: updatedMoney,
            name: "New Name",
            category: .entertainment,
            date: newDate,
            description: "New description"
        )

        // Act
        let result = try await sut.update(transaction: updated)

        // Assert
        XCTAssertEqual(result.name, "New Name")
        XCTAssertEqual(result.money.amount, 123.45)
        XCTAssertEqual(result.money.currency, .GBP)
        XCTAssertEqual(result.category, .entertainment)
        XCTAssertEqual(result.description, "New description")
    }

    // MARK: - Delete Tests

    func test_delete_existingTransaction_removesFromDatabase() async throws {
        // Arrange
        let transaction = try createTestTransaction()
        _ = try await sut.create(transaction: transaction)

        // Verify it exists
        var fetchRequest: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        var results = try context.fetch(fetchRequest)
        XCTAssertEqual(results.count, 1)

        // Act
        try await sut.delete(id: transaction.id)

        // Assert
        fetchRequest = TransactionEntity.fetchRequest()
        results = try context.fetch(fetchRequest)
        XCTAssertEqual(results.count, 0)
    }

    func test_delete_nonExistentTransaction_throwsNotFoundError() async throws {
        // Arrange
        let nonExistentID = UUID()

        // Act/Assert
        do {
            try await sut.delete(id: nonExistentID)
            XCTFail("Expected notFound error")
        } catch let error as RepositoryError {
            XCTAssertEqual(error, .notFound)
        }
    }

    func test_delete_removesOnlySpecifiedTransaction() async throws {
        // Arrange
        let transaction1 = try createTestTransaction()
        let money2 = try Money(amount: 25, currency: .EUR)
        let transaction2 = try Transaction(money: money2, name: "Second", category: .transport, date: Date())

        _ = try await sut.create(transaction: transaction1)
        _ = try await sut.create(transaction: transaction2)

        // Verify both exist
        var fetchRequest: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        var results = try context.fetch(fetchRequest)
        XCTAssertEqual(results.count, 2)

        // Act - delete first transaction
        try await sut.delete(id: transaction1.id)

        // Assert - only second transaction remains
        fetchRequest = TransactionEntity.fetchRequest()
        results = try context.fetch(fetchRequest)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Second")
    }
}
