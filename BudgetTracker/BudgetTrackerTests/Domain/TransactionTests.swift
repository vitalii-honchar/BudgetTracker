//
//  TransactionTests.swift
//  BudgetTrackerTests
//
//  Created by Claude Code on 1/11/26.
//

import XCTest
@testable import BudgetTracker

final class TransactionTests: XCTestCase {

    // MARK: - Helper

    private func createValidMoney() throws -> Money {
        return try Money(amount: 50, currency: .USD)
    }

    private func createPastDate() -> Date {
        return Date().addingTimeInterval(-86400) // Yesterday
    }

    // MARK: - Initialization Tests

    func test_init_withValidData_createsTransactionSuccessfully() throws {
        let money = try createValidMoney()
        let date = createPastDate()

        let transaction = try Transaction(
            money: money,
            name: "Grocery Shopping",
            category: .food,
            date: date
        )

        XCTAssertNotNil(transaction.id)
        XCTAssertEqual(transaction.money, money)
        XCTAssertEqual(transaction.name, "Grocery Shopping")
        XCTAssertEqual(transaction.category, .food)
        XCTAssertEqual(transaction.date, date)
        XCTAssertNil(transaction.description)
    }

    func test_init_withAllParameters_createsTransactionSuccessfully() throws {
        let id = UUID()
        let money = try createValidMoney()
        let date = createPastDate()
        let created = Date()
        let updated = Date()

        let transaction = try Transaction(
            id: id,
            money: money,
            name: "Coffee",
            category: .food,
            date: date,
            description: "Morning coffee at Starbucks",
            createdAt: created,
            updatedAt: updated
        )

        XCTAssertEqual(transaction.id, id)
        XCTAssertEqual(transaction.description, "Morning coffee at Starbucks")
        XCTAssertEqual(transaction.createdAt, created)
        XCTAssertEqual(transaction.updatedAt, updated)
    }

    func test_init_withDescription_trimsWhitespace() throws {
        let transaction = try Transaction(
            money: try createValidMoney(),
            name: "Test",
            category: .other,
            date: createPastDate(),
            description: "  Extra spaces  "
        )

        XCTAssertEqual(transaction.description, "Extra spaces")
    }

    func test_init_withName_trimsWhitespace() throws {
        let transaction = try Transaction(
            money: try createValidMoney(),
            name: "  Coffee  ",
            category: .food,
            date: createPastDate()
        )

        XCTAssertEqual(transaction.name, "Coffee")
    }

    // MARK: - Name Validation Tests

    func test_init_withEmptyName_throwsEmptyNameError() throws {
        let money = try createValidMoney()

        XCTAssertThrowsError(
            try Transaction(
                money: money,
                name: "",
                category: .food,
                date: createPastDate()
            )
        ) { error in
            XCTAssertEqual(error as? TransactionError, .emptyName)
        }
    }

    func test_init_withWhitespaceOnlyName_throwsEmptyNameError() throws {
        let money = try createValidMoney()

        XCTAssertThrowsError(
            try Transaction(
                money: money,
                name: "   ",
                category: .food,
                date: createPastDate()
            )
        ) { error in
            XCTAssertEqual(error as? TransactionError, .emptyName)
        }
    }

    func test_init_withNameExactly100Characters_succeeds() throws {
        let name = String(repeating: "a", count: 100)
        let transaction = try Transaction(
            money: try createValidMoney(),
            name: name,
            category: .food,
            date: createPastDate()
        )

        XCTAssertEqual(transaction.name.count, 100)
    }

    func test_init_withNameOver100Characters_throwsNameTooLongError() throws {
        let name = String(repeating: "a", count: 101)

        XCTAssertThrowsError(
            try Transaction(
                money: try createValidMoney(),
                name: name,
                category: .food,
                date: createPastDate()
            )
        ) { error in
            XCTAssertEqual(error as? TransactionError, .nameTooLong)
        }
    }

    // MARK: - Date Validation Tests

    func test_init_withCurrentDate_succeeds() throws {
        let transaction = try Transaction(
            money: try createValidMoney(),
            name: "Test",
            category: .food,
            date: Date()
        )

        XCTAssertNotNil(transaction)
    }

    func test_init_withPastDate_succeeds() throws {
        let pastDate = Date().addingTimeInterval(-86400 * 30) // 30 days ago

        let transaction = try Transaction(
            money: try createValidMoney(),
            name: "Test",
            category: .food,
            date: pastDate
        )

        XCTAssertEqual(transaction.date, pastDate)
    }

    func test_init_withFutureDate_throwsFutureDateError() throws {
        let futureDate = Date().addingTimeInterval(86400) // Tomorrow

        XCTAssertThrowsError(
            try Transaction(
                money: try createValidMoney(),
                name: "Test",
                category: .food,
                date: futureDate
            )
        ) { error in
            XCTAssertEqual(error as? TransactionError, .futureDate)
        }
    }

    // MARK: - Description Validation Tests

    func test_init_withNilDescription_succeeds() throws {
        let transaction = try Transaction(
            money: try createValidMoney(),
            name: "Test",
            category: .food,
            date: createPastDate(),
            description: nil
        )

        XCTAssertNil(transaction.description)
    }

    func test_init_withDescriptionExactly500Characters_succeeds() throws {
        let description = String(repeating: "a", count: 500)

        let transaction = try Transaction(
            money: try createValidMoney(),
            name: "Test",
            category: .food,
            date: createPastDate(),
            description: description
        )

        XCTAssertEqual(transaction.description?.count, 500)
    }

    func test_init_withDescriptionOver500Characters_throwsDescriptionTooLongError() throws {
        let description = String(repeating: "a", count: 501)

        XCTAssertThrowsError(
            try Transaction(
                money: try createValidMoney(),
                name: "Test",
                category: .food,
                date: createPastDate(),
                description: description
            )
        ) { error in
            XCTAssertEqual(error as? TransactionError, .descriptionTooLong)
        }
    }

    // MARK: - Equality Tests

    func test_equality_withSameIdAndAllFields_returnsTrue() throws {
        let id = UUID()
        let money = try createValidMoney()
        let date = createPastDate()
        let created = Date()
        let updated = Date()

        let transaction1 = try Transaction(
            id: id,
            money: money,
            name: "Test",
            category: .food,
            date: date,
            description: nil,
            createdAt: created,
            updatedAt: updated
        )
        let transaction2 = try Transaction(
            id: id,
            money: money,
            name: "Test",
            category: .food,
            date: date,
            description: nil,
            createdAt: created,
            updatedAt: updated
        )

        XCTAssertEqual(transaction1, transaction2)
    }

    func test_equality_withDifferentId_returnsFalse() throws {
        let money = try createValidMoney()
        let date = createPastDate()

        let transaction1 = try Transaction(money: money, name: "Test", category: .food, date: date)
        let transaction2 = try Transaction(money: money, name: "Test", category: .food, date: date)

        XCTAssertNotEqual(transaction1, transaction2)
    }

    // MARK: - Display Text Tests

    func test_displayText_includesNameMoneyAndCategory() throws {
        let money = try Money(amount: 42.50, currency: .USD)
        let transaction = try Transaction(
            money: money,
            name: "Lunch",
            category: .food,
            date: createPastDate()
        )

        XCTAssertEqual(transaction.displayText, "Lunch: $42.50 [Food & Dining]")
    }

    // MARK: - Identifiable Tests

    func test_identifiable_hasUniqueId() throws {
        let transaction = try Transaction(
            money: try createValidMoney(),
            name: "Test",
            category: .food,
            date: createPastDate()
        )

        XCTAssertNotNil(transaction.id)
    }

    // MARK: - Codable Tests

    func test_encode_encodesAllFields() throws {
        let id = UUID()
        let money = try Money(amount: 25, currency: .EUR)
        let date = Date(timeIntervalSince1970: 1704067200) // Fixed date for testing
        let transaction = try Transaction(
            id: id,
            money: money,
            name: "Test Transaction",
            category: .shopping,
            date: date,
            description: "Test description",
            createdAt: date,
            updatedAt: date
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(transaction)

        // Decode to verify
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Transaction.self, from: data)

        XCTAssertEqual(decoded.id, id)
        XCTAssertEqual(decoded.money, money)
        XCTAssertEqual(decoded.name, "Test Transaction")
        XCTAssertEqual(decoded.category, .shopping)
        XCTAssertEqual(decoded.description, "Test description")
    }

    func test_decode_decodesAllFields() throws {
        let json = """
        {
            "id": "123e4567-e89b-12d3-a456-426614174000",
            "money": {"amount": 100, "currency": "USD"},
            "name": "Coffee",
            "category": "food",
            "date": 1704067200,
            "description": "Morning coffee",
            "createdAt": 1704067200,
            "updatedAt": 1704067200
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let transaction = try decoder.decode(Transaction.self, from: json)

        XCTAssertEqual(transaction.name, "Coffee")
        XCTAssertEqual(transaction.category, .food)
        XCTAssertEqual(transaction.description, "Morning coffee")
    }
}
