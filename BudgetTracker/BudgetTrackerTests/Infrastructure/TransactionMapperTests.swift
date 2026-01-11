//
//  TransactionMapperTests.swift
//  BudgetTrackerTests
//
//  Created by Claude Code on 1/11/26.
//

import XCTest
import CoreData
@testable import BudgetTracker

final class TransactionMapperTests: XCTestCase {
    var context: NSManagedObjectContext!
    var container: NSPersistentContainer!

    override func setUp() {
        super.setUp()
        container = InMemoryCoreDataStack.create()
        context = container.viewContext
    }

    override func tearDown() {
        context = nil
        container = nil
        super.tearDown()
    }

    // MARK: - To Entity Tests

    func test_toEntity_mapsAllFields() throws {
        // Arrange
        let money = try Money(amount: 42.50, currency: .USD)
        let transaction = try Transaction(
            money: money,
            name: "Grocery Shopping",
            category: .food,
            date: Date(),
            description: "Weekly groceries"
        )

        // Act
        let entity = TransactionMapper.toEntity(transaction: transaction, context: context)

        // Assert
        XCTAssertEqual(entity.id, transaction.id)
        XCTAssertEqual(entity.amount as Decimal?, 42.50)
        XCTAssertEqual(entity.currencyCode, "USD")
        XCTAssertEqual(entity.name, "Grocery Shopping")
        XCTAssertEqual(entity.categoryRawValue, "food")
        XCTAssertEqual(entity.transactionDescription, "Weekly groceries")
    }

    // MARK: - To Domain Tests

    func test_toDomain_mapsAllFields() throws {
        // Arrange
        let entity = TransactionEntity(context: context)
        entity.id = UUID()
        entity.amount = NSDecimalNumber(string: "25.00")
        entity.currencyCode = "EUR"
        entity.name = "Coffee"
        entity.categoryRawValue = "food"
        entity.date = Date()
        entity.transactionDescription = "Morning coffee"
        entity.createdAt = Date()
        entity.updatedAt = Date()

        // Act
        let transaction = try TransactionMapper.toDomain(entity: entity)

        // Assert
        XCTAssertEqual(transaction.id, entity.id)
        XCTAssertEqual(transaction.money.amount, 25.00)
        XCTAssertEqual(transaction.money.currency, .EUR)
        XCTAssertEqual(transaction.name, "Coffee")
        XCTAssertEqual(transaction.category, .food)
        XCTAssertEqual(transaction.description, "Morning coffee")
    }

    func test_toDomain_withMissingFields_throwsError() {
        // Arrange
        let entity = TransactionEntity(context: context)
        entity.id = UUID()
        // Missing required fields

        // Act & Assert
        XCTAssertThrowsError(try TransactionMapper.toDomain(entity: entity)) { error in
            XCTAssertEqual(error as? MapperError, .missingRequiredFields)
        }
    }

    func test_toDomain_withInvalidCurrency_throwsError() {
        // Arrange
        let entity = TransactionEntity(context: context)
        entity.id = UUID()
        entity.amount = NSDecimalNumber(string: "10")
        entity.currencyCode = "INVALID"
        entity.name = "Test"
        entity.categoryRawValue = "food"
        entity.date = Date()
        entity.createdAt = Date()
        entity.updatedAt = Date()

        // Act & Assert
        XCTAssertThrowsError(try TransactionMapper.toDomain(entity: entity)) { error in
            XCTAssertEqual(error as? MapperError, .invalidCurrency("INVALID"))
        }
    }
}
