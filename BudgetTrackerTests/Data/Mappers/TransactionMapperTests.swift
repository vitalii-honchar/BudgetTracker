//
//  TransactionMapperTests.swift
//  BudgetTrackerTests
//
//  Integration tests for TransactionMapper
//

import XCTest
import CoreData
@testable import BudgetTracker

final class TransactionMapperTests: XCTestCase {

    // MARK: - Test Infrastructure

    var context: NSManagedObjectContext!
    var testCategory: CategoryEntity!

    override func setUp() {
        super.setUp()
        context = CoreDataStack.preview.viewContext

        // Create a test category for transaction relationships
        testCategory = CategoryEntity(context: context)
        testCategory.id = UUID()
        testCategory.name = "Test Category"
        testCategory.icon = "star.fill"
        testCategory.colorHex = "#FF6B6B"
        testCategory.isCustom = false
        testCategory.sortOrder = 1
        testCategory.createdAt = Date()
        testCategory.updatedAt = Date()
    }

    override func tearDown() {
        testCategory = nil
        context = nil
        super.tearDown()
    }

    // MARK: - Domain → Core Data Tests

    func test_toCoreData_createsNewEntity() {
        // Arrange
        let money = Money(amount: Decimal(42.50), currency: .USD)
        let transaction = try! Transaction.create(
            money: money,
            name: "Coffee",
            categoryId: testCategory.id
        )

        // Act
        let entity = TransactionMapper.toCoreData(transaction, in: context)
        entity.category = testCategory // Set relationship manually

        // Assert
        XCTAssertEqual(entity.id, transaction.id)
        XCTAssertEqual(entity.amount.decimalValue, Decimal(42.50))
        XCTAssertEqual(entity.currency, "USD")
        XCTAssertEqual(entity.name, "Coffee")
        XCTAssertNil(entity.descriptionText)
    }

    func test_toCoreData_withDescription_setsDescription() {
        // Arrange
        let money = Money(amount: Decimal(100.00), currency: .EUR)
        let transaction = try! Transaction.createDetailed(
            money: money,
            name: "Dinner",
            categoryId: testCategory.id,
            date: Date(),
            description: "Business dinner with client",
            periodId: nil
        )

        // Act
        let entity = TransactionMapper.toCoreData(transaction, in: context)
        entity.category = testCategory

        // Assert
        XCTAssertEqual(entity.descriptionText, "Business dinner with client")
    }

    func test_toCoreData_updatesExistingEntity() {
        // Arrange
        let money = Money(amount: Decimal(50.00), currency: .USD)
        let original = try! Transaction.create(
            money: money,
            name: "Lunch",
            categoryId: testCategory.id
        )
        let entity = TransactionMapper.toCoreData(original, in: context)
        entity.category = testCategory

        // Modify transaction
        var updated = original
        let newMoney = Money(amount: Decimal(60.00), currency: .USD)
        try! updated.updateAmount(newMoney)

        // Act
        let result = TransactionMapper.toCoreData(updated, in: context, existing: entity)

        // Assert
        XCTAssertEqual(result, entity) // Same entity object
        XCTAssertEqual(result.amount.decimalValue, Decimal(60.00))
        XCTAssertEqual(result.id, original.id)
    }

    // MARK: - Core Data → Domain Tests

    func test_toDomain_withValidEntity_returnsDomainTransaction() throws {
        // Arrange
        let entity = TransactionEntity(context: context)
        entity.id = UUID()
        entity.amount = NSDecimalNumber(decimal: Decimal(75.00))
        entity.currency = "GBP"
        entity.name = "Shopping"
        entity.transactionDate = Date()
        entity.descriptionText = "Weekly groceries"
        entity.createdAt = Date()
        entity.updatedAt = Date()
        entity.category = testCategory

        // Act
        let transaction = try TransactionMapper.toDomain(entity)

        // Assert
        XCTAssertEqual(transaction.id, entity.id)
        XCTAssertEqual(transaction.money.amount, Decimal(75.00))
        XCTAssertEqual(transaction.money.currency, .GBP)
        XCTAssertEqual(transaction.name, "Shopping")
        XCTAssertEqual(transaction.description, "Weekly groceries")
        XCTAssertEqual(transaction.categoryId, testCategory.id)
    }

    func test_toDomain_withInvalidCurrency_throwsError() {
        // Arrange
        let entity = TransactionEntity(context: context)
        entity.id = UUID()
        entity.amount = NSDecimalNumber(decimal: Decimal(50.00))
        entity.currency = "INVALID"
        entity.name = "Transaction"
        entity.transactionDate = Date()
        entity.createdAt = Date()
        entity.updatedAt = Date()
        entity.category = testCategory

        // Act & Assert
        XCTAssertThrowsError(try TransactionMapper.toDomain(entity)) { error in
            if case MappingError.invalidCurrency(let code) = error {
                XCTAssertEqual(code, "INVALID")
            } else {
                XCTFail("Expected MappingError.invalidCurrency")
            }
        }
    }

    func test_toDomain_withZeroAmount_throwsError() {
        // Arrange
        let entity = TransactionEntity(context: context)
        entity.id = UUID()
        entity.amount = NSDecimalNumber(decimal: Decimal(0))
        entity.currency = "USD"
        entity.name = "Transaction"
        entity.transactionDate = Date()
        entity.createdAt = Date()
        entity.updatedAt = Date()
        entity.category = testCategory

        // Act & Assert
        XCTAssertThrowsError(try TransactionMapper.toDomain(entity)) { error in
            XCTAssertEqual(error as? MoneyError, .invalidAmount)
        }
    }

    func test_toDomain_withNegativeAmount_throwsError() {
        // Arrange
        let entity = TransactionEntity(context: context)
        entity.id = UUID()
        entity.amount = NSDecimalNumber(decimal: Decimal(-10.00))
        entity.currency = "USD"
        entity.name = "Transaction"
        entity.transactionDate = Date()
        entity.createdAt = Date()
        entity.updatedAt = Date()
        entity.category = testCategory

        // Act & Assert
        XCTAssertThrowsError(try TransactionMapper.toDomain(entity)) { error in
            XCTAssertEqual(error as? MoneyError, .invalidAmount)
        }
    }

    // MARK: - Bidirectional Mapping Tests

    func test_roundTrip_preservesAllData() throws {
        // Arrange
        let money = Money(amount: Decimal(123.45), currency: .EUR)
        let original = try Transaction.createDetailed(
            money: money,
            name: "Restaurant Bill",
            categoryId: testCategory.id,
            date: Date(),
            description: "Team lunch",
            periodId: nil
        )

        // Act: Domain → Core Data → Domain
        let entity = TransactionMapper.toCoreData(original, in: context)
        entity.category = testCategory
        let result = try TransactionMapper.toDomain(entity)

        // Assert: All data preserved
        XCTAssertEqual(result.id, original.id)
        XCTAssertEqual(result.money.amount, original.money.amount)
        XCTAssertEqual(result.money.currency, original.money.currency)
        XCTAssertEqual(result.name, original.name)
        XCTAssertEqual(result.description, original.description)
        XCTAssertEqual(result.categoryId, original.categoryId)
    }

    func test_roundTrip_withDifferentCurrencies_preservesCurrency() throws {
        let currencies: [Currency] = [.USD, .EUR, .GBP, .JPY]

        for currency in currencies {
            // Arrange
            let money = Money(amount: Decimal(100.00), currency: currency)
            let original = try Transaction.create(
                money: money,
                name: "Test",
                categoryId: testCategory.id
            )

            // Act
            let entity = TransactionMapper.toCoreData(original, in: context)
            entity.category = testCategory
            let result = try TransactionMapper.toDomain(entity)

            // Assert
            XCTAssertEqual(result.money.currency, currency,
                          "Currency \(currency.rawValue) not preserved")
        }
    }

    // MARK: - Batch Mapping Tests

    func test_batchToDomain_mapsMultipleEntities() throws {
        // Arrange
        let entities = [
            createEntity(amount: 10.00, name: "Coffee"),
            createEntity(amount: 25.50, name: "Lunch"),
            createEntity(amount: 100.00, name: "Dinner")
        ]

        // Act
        let transactions = try TransactionMapper.toDomain(entities)

        // Assert
        XCTAssertEqual(transactions.count, 3)
        XCTAssertEqual(transactions[0].name, "Coffee")
        XCTAssertEqual(transactions[1].name, "Lunch")
        XCTAssertEqual(transactions[2].name, "Dinner")
    }

    func test_batchToDomain_withInvalidEntity_throwsError() {
        // Arrange
        let entities = [
            createEntity(amount: 10.00, name: "Valid"),
            createInvalidEntity(), // Zero amount
            createEntity(amount: 50.00, name: "Also Valid")
        ]

        // Act & Assert
        XCTAssertThrowsError(try TransactionMapper.toDomain(entities))
    }

    // MARK: - Decimal Precision Tests

    func test_roundTrip_preservesDecimalPrecision() throws {
        let testAmounts: [Decimal] = [
            Decimal(string: "0.01")!,
            Decimal(string: "1.99")!,
            Decimal(string: "123.45")!,
            Decimal(string: "9999.9999")!
        ]

        for amount in testAmounts {
            // Arrange
            let money = Money(amount: amount, currency: .USD)
            let original = try Transaction.create(
                money: money,
                name: "Test",
                categoryId: testCategory.id
            )

            // Act
            let entity = TransactionMapper.toCoreData(original, in: context)
            entity.category = testCategory
            let result = try TransactionMapper.toDomain(entity)

            // Assert
            XCTAssertEqual(result.money.amount, amount,
                          "Decimal precision lost for \(amount)")
        }
    }

    // MARK: - Test Helpers

    private func createEntity(amount: Double, name: String) -> TransactionEntity {
        let entity = TransactionEntity(context: context)
        entity.id = UUID()
        entity.amount = NSDecimalNumber(value: amount)
        entity.currency = "USD"
        entity.name = name
        entity.transactionDate = Date()
        entity.createdAt = Date()
        entity.updatedAt = Date()
        entity.category = testCategory
        return entity
    }

    private func createInvalidEntity() -> TransactionEntity {
        let entity = TransactionEntity(context: context)
        entity.id = UUID()
        entity.amount = NSDecimalNumber(value: 0) // Invalid: zero amount
        entity.currency = "USD"
        entity.name = "Invalid"
        entity.transactionDate = Date()
        entity.createdAt = Date()
        entity.updatedAt = Date()
        entity.category = testCategory
        return entity
    }
}
