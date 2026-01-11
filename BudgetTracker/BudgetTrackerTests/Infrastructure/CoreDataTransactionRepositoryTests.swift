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
}
