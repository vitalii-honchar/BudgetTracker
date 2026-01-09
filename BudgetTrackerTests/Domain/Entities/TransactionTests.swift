//
//  TransactionTests.swift
//  BudgetTrackerTests
//
//  Unit tests for Transaction Entity
//

import XCTest
@testable import BudgetTracker

final class TransactionTests: XCTestCase {

    // MARK: - Test Helpers

    private func createTestMoney() -> Money {
        return Money(amount: Decimal(42.50), currency: .USD)
    }

    private func createTestCategoryId() -> UUID {
        return UUID()
    }

    // MARK: - Initialization Tests

    func test_init_withValidData_createsTransaction() throws {
        // Arrange
        let money = createTestMoney()
        let categoryId = createTestCategoryId()
        let date = Date()

        // Act
        let transaction = try Transaction(
            money: money,
            name: "Coffee",
            categoryId: categoryId,
            date: date
        )

        // Assert
        XCTAssertEqual(transaction.money, money)
        XCTAssertEqual(transaction.name, "Coffee")
        XCTAssertEqual(transaction.categoryId, categoryId)
        XCTAssertEqual(transaction.date, date)
        XCTAssertNil(transaction.description)
        XCTAssertNil(transaction.periodId)
        XCTAssertNotNil(transaction.id)
        XCTAssertNotNil(transaction.createdAt)
        XCTAssertNotNil(transaction.updatedAt)
    }

    func test_init_withZeroAmount_throwsInvalidAmountError() {
        // Arrange
        let money = Money(amount: Decimal(0), currency: .USD)
        let categoryId = createTestCategoryId()

        // Act & Assert
        XCTAssertThrowsError(try Transaction(
            money: money,
            name: "Test",
            categoryId: categoryId
        )) { error in
            XCTAssertEqual(error as? TransactionError, .invalidAmount)
        }
    }

    func test_init_withNegativeAmount_throwsInvalidAmountError() {
        // Arrange
        let money = Money(amount: Decimal(-10.00), currency: .USD)
        let categoryId = createTestCategoryId()

        // Act & Assert
        XCTAssertThrowsError(try Transaction(
            money: money,
            name: "Test",
            categoryId: categoryId
        )) { error in
            XCTAssertEqual(error as? TransactionError, .invalidAmount)
        }
    }

    func test_init_withEmptyName_throwsEmptyNameError() {
        // Arrange
        let money = createTestMoney()
        let categoryId = createTestCategoryId()

        // Act & Assert
        XCTAssertThrowsError(try Transaction(
            money: money,
            name: "",
            categoryId: categoryId
        )) { error in
            XCTAssertEqual(error as? TransactionError, .emptyName)
        }
    }

    func test_init_withNameTooLong_throwsNameTooLongError() {
        // Arrange
        let money = createTestMoney()
        let categoryId = createTestCategoryId()
        let longName = String(repeating: "a", count: 101)

        // Act & Assert
        XCTAssertThrowsError(try Transaction(
            money: money,
            name: longName,
            categoryId: categoryId
        )) { error in
            XCTAssertEqual(error as? TransactionError, .nameTooLong)
        }
    }

    func test_init_withFutureDate_throwsFutureDateError() {
        // Arrange
        let money = createTestMoney()
        let categoryId = createTestCategoryId()
        let futureDate = Date().addingTimeInterval(86400) // Tomorrow

        // Act & Assert
        XCTAssertThrowsError(try Transaction(
            money: money,
            name: "Test",
            categoryId: categoryId,
            date: futureDate
        )) { error in
            XCTAssertEqual(error as? TransactionError, .futureDate)
        }
    }

    func test_init_withDescriptionTooLong_throwsDescriptionTooLongError() {
        // Arrange
        let money = createTestMoney()
        let categoryId = createTestCategoryId()
        let longDescription = String(repeating: "a", count: 501)

        // Act & Assert
        XCTAssertThrowsError(try Transaction(
            money: money,
            name: "Test",
            categoryId: categoryId,
            description: longDescription
        )) { error in
            XCTAssertEqual(error as? TransactionError, .descriptionTooLong)
        }
    }

    // MARK: - Factory Method Tests

    func test_create_withMinimalData_createsTransaction() throws {
        // Arrange
        let money = createTestMoney()
        let categoryId = createTestCategoryId()

        // Act
        let transaction = try Transaction.create(
            money: money,
            name: "Coffee",
            categoryId: categoryId
        )

        // Assert
        XCTAssertEqual(transaction.name, "Coffee")
        XCTAssertEqual(transaction.money, money)
        XCTAssertEqual(transaction.categoryId, categoryId)
    }

    func test_createDetailed_withAllFields_createsTransaction() throws {
        // Arrange
        let money = createTestMoney()
        let categoryId = createTestCategoryId()
        let periodId = UUID()
        let date = Date()

        // Act
        let transaction = try Transaction.createDetailed(
            money: money,
            name: "Lunch",
            categoryId: categoryId,
            date: date,
            description: "Business lunch",
            periodId: periodId
        )

        // Assert
        XCTAssertEqual(transaction.name, "Lunch")
        XCTAssertEqual(transaction.description, "Business lunch")
        XCTAssertEqual(transaction.periodId, periodId)
    }

    // MARK: - Mutation Tests

    func test_updateAmount_withValidMoney_updatesAmountAndTimestamp() throws {
        // Arrange
        var transaction = try Transaction.create(
            money: createTestMoney(),
            name: "Coffee",
            categoryId: createTestCategoryId()
        )
        let originalUpdatedAt = transaction.updatedAt
        Thread.sleep(forTimeInterval: 0.01)
        let newMoney = Money(amount: Decimal(50.00), currency: .USD)

        // Act
        try transaction.updateAmount(newMoney)

        // Assert
        XCTAssertEqual(transaction.money, newMoney)
        XCTAssertGreaterThan(transaction.updatedAt, originalUpdatedAt)
    }

    func test_updateAmount_withZeroAmount_throwsError() throws {
        // Arrange
        var transaction = try Transaction.create(
            money: createTestMoney(),
            name: "Coffee",
            categoryId: createTestCategoryId()
        )
        let zeroMoney = Money(amount: Decimal(0), currency: .USD)

        // Act & Assert
        XCTAssertThrowsError(try transaction.updateAmount(zeroMoney)) { error in
            XCTAssertEqual(error as? TransactionError, .invalidAmount)
        }
    }

    func test_updateName_withValidName_updatesNameAndTimestamp() throws {
        // Arrange
        var transaction = try Transaction.create(
            money: createTestMoney(),
            name: "Old Name",
            categoryId: createTestCategoryId()
        )
        let originalUpdatedAt = transaction.updatedAt
        Thread.sleep(forTimeInterval: 0.01)

        // Act
        try transaction.updateName("New Name")

        // Assert
        XCTAssertEqual(transaction.name, "New Name")
        XCTAssertGreaterThan(transaction.updatedAt, originalUpdatedAt)
    }

    func test_updateCategory_updatesCategory AndTimestamp() throws {
        // Arrange
        var transaction = try Transaction.create(
            money: createTestMoney(),
            name: "Coffee",
            categoryId: createTestCategoryId()
        )
        let originalUpdatedAt = transaction.updatedAt
        Thread.sleep(forTimeInterval: 0.01)
        let newCategoryId = UUID()

        // Act
        transaction.updateCategory(newCategoryId)

        // Assert
        XCTAssertEqual(transaction.categoryId, newCategoryId)
        XCTAssertGreaterThan(transaction.updatedAt, originalUpdatedAt)
    }

    func test_updateDate_withPastDate_updatesDateAndTimestamp() throws {
        // Arrange
        var transaction = try Transaction.create(
            money: createTestMoney(),
            name: "Coffee",
            categoryId: createTestCategoryId()
        )
        let originalUpdatedAt = transaction.updatedAt
        Thread.sleep(forTimeInterval: 0.01)
        let pastDate = Date().addingTimeInterval(-86400) // Yesterday

        // Act
        try transaction.updateDate(pastDate)

        // Assert
        XCTAssertEqual(transaction.date, pastDate)
        XCTAssertGreaterThan(transaction.updatedAt, originalUpdatedAt)
    }

    func test_updateDate_withFutureDate_throwsError() throws {
        // Arrange
        var transaction = try Transaction.create(
            money: createTestMoney(),
            name: "Coffee",
            categoryId: createTestCategoryId()
        )
        let futureDate = Date().addingTimeInterval(86400) // Tomorrow

        // Act & Assert
        XCTAssertThrowsError(try transaction.updateDate(futureDate)) { error in
            XCTAssertEqual(error as? TransactionError, .futureDate)
        }
    }

    func test_updateDescription_withValidDescription_updatesDescriptionAndTimestamp() throws {
        // Arrange
        var transaction = try Transaction.create(
            money: createTestMoney(),
            name: "Coffee",
            categoryId: createTestCategoryId()
        )
        let originalUpdatedAt = transaction.updatedAt
        Thread.sleep(forTimeInterval: 0.01)

        // Act
        try transaction.updateDescription("New description")

        // Assert
        XCTAssertEqual(transaction.description, "New description")
        XCTAssertGreaterThan(transaction.updatedAt, originalUpdatedAt)
    }

    func test_linkToPeriod_linksPeriodAndUpdatesTimestamp() throws {
        // Arrange
        var transaction = try Transaction.create(
            money: createTestMoney(),
            name: "Coffee",
            categoryId: createTestCategoryId()
        )
        let originalUpdatedAt = transaction.updatedAt
        Thread.sleep(forTimeInterval: 0.01)
        let periodId = UUID()

        // Act
        transaction.linkToPeriod(periodId)

        // Assert
        XCTAssertEqual(transaction.periodId, periodId)
        XCTAssertGreaterThan(transaction.updatedAt, originalUpdatedAt)
    }

    func test_unlinkFromPeriod_removesLinkAndUpdatesTimestamp() throws {
        // Arrange
        var transaction = try Transaction.createDetailed(
            money: createTestMoney(),
            name: "Coffee",
            categoryId: createTestCategoryId(),
            date: Date(),
            description: nil,
            periodId: UUID()
        )
        let originalUpdatedAt = transaction.updatedAt
        Thread.sleep(forTimeInterval: 0.01)

        // Act
        transaction.unlinkFromPeriod()

        // Assert
        XCTAssertNil(transaction.periodId)
        XCTAssertGreaterThan(transaction.updatedAt, originalUpdatedAt)
    }

    // MARK: - Business Logic Tests

    func test_isRecent_withTransactionFromYesterday_returnsTrue() throws {
        // Arrange
        let yesterday = Date().addingTimeInterval(-86400)
        let transaction = try Transaction.createDetailed(
            money: createTestMoney(),
            name: "Coffee",
            categoryId: createTestCategoryId(),
            date: yesterday,
            description: nil,
            periodId: nil
        )

        // Act & Assert
        XCTAssertTrue(transaction.isRecent)
    }

    func test_isRecent_withTransactionFrom10DaysAgo_returnsFalse() throws {
        // Arrange
        let tenDaysAgo = Date().addingTimeInterval(-86400 * 10)
        let transaction = try Transaction.createDetailed(
            money: createTestMoney(),
            name: "Coffee",
            categoryId: createTestCategoryId(),
            date: tenDaysAgo,
            description: nil,
            periodId: nil
        )

        // Act & Assert
        XCTAssertFalse(transaction.isRecent)
    }

    func test_hasDescription_withDescription_returnsTrue() throws {
        // Arrange
        let transaction = try Transaction.createDetailed(
            money: createTestMoney(),
            name: "Coffee",
            categoryId: createTestCategoryId(),
            date: Date(),
            description: "Morning coffee",
            periodId: nil
        )

        // Act & Assert
        XCTAssertTrue(transaction.hasDescription)
    }

    func test_hasDescription_withoutDescription_returnsFalse() throws {
        // Arrange
        let transaction = try Transaction.create(
            money: createTestMoney(),
            name: "Coffee",
            categoryId: createTestCategoryId()
        )

        // Act & Assert
        XCTAssertFalse(transaction.hasDescription)
    }

    func test_isLinkedToPeriod_withPeriod_returnsTrue() throws {
        // Arrange
        let transaction = try Transaction.createDetailed(
            money: createTestMoney(),
            name: "Coffee",
            categoryId: createTestCategoryId(),
            date: Date(),
            description: nil,
            periodId: UUID()
        )

        // Act & Assert
        XCTAssertTrue(transaction.isLinkedToPeriod)
    }

    func test_isLinkedToPeriod_withoutPeriod_returnsFalse() throws {
        // Arrange
        let transaction = try Transaction.create(
            money: createTestMoney(),
            name: "Coffee",
            categoryId: createTestCategoryId()
        )

        // Act & Assert
        XCTAssertFalse(transaction.isLinkedToPeriod)
    }

    func test_ageInDays_withTransactionFrom5DaysAgo_returns5() throws {
        // Arrange
        let fiveDaysAgo = Date().addingTimeInterval(-86400 * 5)
        let transaction = try Transaction.createDetailed(
            money: createTestMoney(),
            name: "Coffee",
            categoryId: createTestCategoryId(),
            date: fiveDaysAgo,
            description: nil,
            periodId: nil
        )

        // Act
        let age = transaction.ageInDays

        // Assert
        XCTAssertEqual(age, 5)
    }

    func test_formattedAmount_returnsFormattedString() throws {
        // Arrange
        let money = Money(amount: Decimal(42.50), currency: .USD)
        let transaction = try Transaction.create(
            money: money,
            name: "Coffee",
            categoryId: createTestCategoryId()
        )

        // Act
        let formatted = transaction.formattedAmount

        // Assert
        XCTAssertTrue(formatted.contains("42.50") || formatted.contains("42,50"))
        XCTAssertTrue(formatted.contains("$"))
    }

    // MARK: - Comparison Tests

    func test_compareByDateDescending_sortsNewestFirst() throws {
        // Arrange
        let older = try Transaction.createDetailed(
            money: createTestMoney(),
            name: "Older",
            categoryId: createTestCategoryId(),
            date: Date().addingTimeInterval(-86400),
            description: nil,
            periodId: nil
        )
        let newer = try Transaction.create(
            money: createTestMoney(),
            name: "Newer",
            categoryId: createTestCategoryId()
        )

        // Act
        let result = Transaction.compareByDateDescending(newer, older)

        // Assert
        XCTAssertTrue(result)
    }

    func test_compareByAmountDescending_sortsHighestFirst() throws {
        // Arrange
        let smaller = try Transaction.create(
            money: Money(amount: Decimal(10.00), currency: .USD),
            name: "Smaller",
            categoryId: createTestCategoryId()
        )
        let larger = try Transaction.create(
            money: Money(amount: Decimal(100.00), currency: .USD),
            name: "Larger",
            categoryId: createTestCategoryId()
        )

        // Act
        let result = Transaction.compareByAmountDescending(larger, smaller)

        // Assert
        XCTAssertTrue(result)
    }
}
