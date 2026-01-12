//
//  ExpensePeriodTests.swift
//  BudgetTrackerTests
//
//  Created by Claude Code on 1/12/26.
//

import XCTest
@testable import BudgetTracker

final class ExpensePeriodTests: XCTestCase {

    // MARK: - Happy Path Tests

    func test_init_withValidName_createsExpensePeriod() throws {
        // Given
        let name = "March 2024"
        let startDate = Date()

        // When
        let period = try ExpensePeriod(name: name, startDate: startDate)

        // Then
        XCTAssertEqual(period.name, name)
        XCTAssertEqual(period.startDate, startDate)
        XCTAssertNil(period.endDate)
        XCTAssertNotNil(period.id)
        XCTAssertNotNil(period.createdAt)
        XCTAssertNotNil(period.updatedAt)
    }

    func test_init_withStartAndEndDate_createsExpensePeriod() throws {
        // Given
        let name = "Q1 2024"
        let startDate = Date()
        let endDate = Date().addingTimeInterval(90 * 24 * 60 * 60) // 90 days later

        // When
        let period = try ExpensePeriod(
            name: name,
            startDate: startDate,
            endDate: endDate
        )

        // Then
        XCTAssertEqual(period.name, name)
        XCTAssertEqual(period.startDate, startDate)
        XCTAssertEqual(period.endDate, endDate)
    }

    func test_init_withAllParameters_createsExpensePeriod() throws {
        // Given
        let id = UUID()
        let name = "Vacation Budget"
        let startDate = Date()
        let endDate = Date().addingTimeInterval(7 * 24 * 60 * 60)
        let createdAt = Date()
        let updatedAt = Date()

        // When
        let period = try ExpensePeriod(
            id: id,
            name: name,
            startDate: startDate,
            endDate: endDate,
            createdAt: createdAt,
            updatedAt: updatedAt
        )

        // Then
        XCTAssertEqual(period.id, id)
        XCTAssertEqual(period.name, name)
        XCTAssertEqual(period.startDate, startDate)
        XCTAssertEqual(period.endDate, endDate)
        XCTAssertEqual(period.createdAt, createdAt)
        XCTAssertEqual(period.updatedAt, updatedAt)
    }

    func test_init_trimsWhitespace() throws {
        // Given
        let nameWithWhitespace = "  March 2024  "

        // When
        let period = try ExpensePeriod(name: nameWithWhitespace, startDate: Date())

        // Then
        XCTAssertEqual(period.name, "March 2024")
    }

    // MARK: - Validation Tests

    func test_init_withEmptyName_throwsNameEmptyError() {
        // Given
        let emptyName = ""

        // When/Then
        XCTAssertThrowsError(try ExpensePeriod(name: emptyName, startDate: Date())) { error in
            XCTAssertEqual(error as? ExpensePeriod.ValidationError, .nameEmpty)
        }
    }

    func test_init_withWhitespaceOnlyName_throwsNameEmptyError() {
        // Given
        let whitespaceName = "   "

        // When/Then
        XCTAssertThrowsError(try ExpensePeriod(name: whitespaceName, startDate: Date())) { error in
            XCTAssertEqual(error as? ExpensePeriod.ValidationError, .nameEmpty)
        }
    }

    func test_init_withNameTooLong_throwsNameTooLongError() {
        // Given
        let longName = String(repeating: "a", count: 101)

        // When/Then
        XCTAssertThrowsError(try ExpensePeriod(name: longName, startDate: Date())) { error in
            XCTAssertEqual(error as? ExpensePeriod.ValidationError, .nameTooLong)
        }
    }

    func test_init_withNameExactly100Chars_succeeds() throws {
        // Given
        let name = String(repeating: "a", count: 100)

        // When
        let period = try ExpensePeriod(name: name, startDate: Date())

        // Then
        XCTAssertEqual(period.name.count, 100)
    }

    func test_init_withEndDateBeforeStartDate_throwsError() {
        // Given
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(-86400) // 1 day earlier

        // When/Then
        XCTAssertThrowsError(
            try ExpensePeriod(name: "Invalid Period", startDate: startDate, endDate: endDate)
        ) { error in
            XCTAssertEqual(error as? ExpensePeriod.ValidationError, .endDateBeforeStartDate)
        }
    }

    func test_init_withEndDateEqualToStartDate_succeeds() throws {
        // Given
        let date = Date()

        // When
        let period = try ExpensePeriod(
            name: "Single Day",
            startDate: date,
            endDate: date
        )

        // Then
        XCTAssertEqual(period.startDate, period.endDate)
    }

    // MARK: - Computed Properties Tests

    func test_isOngoing_withNoEndDate_returnsTrue() throws {
        // Given
        let period = try ExpensePeriod(name: "Ongoing", startDate: Date())

        // When/Then
        XCTAssertTrue(period.isOngoing)
    }

    func test_isOngoing_withEndDate_returnsFalse() throws {
        // Given
        let period = try ExpensePeriod(
            name: "Finished",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400)
        )

        // When/Then
        XCTAssertFalse(period.isOngoing)
    }

    func test_isActive_withStartInPastAndNoEnd_returnsTrue() throws {
        // Given
        let pastDate = Date().addingTimeInterval(-86400) // Yesterday
        let period = try ExpensePeriod(name: "Active", startDate: pastDate)

        // When/Then
        XCTAssertTrue(period.isActive)
    }

    func test_isActive_withStartInFutureAndNoEnd_returnsFalse() throws {
        // Given
        let futureDate = Date().addingTimeInterval(86400) // Tomorrow
        let period = try ExpensePeriod(name: "Future", startDate: futureDate)

        // When/Then
        XCTAssertFalse(period.isActive)
    }

    func test_isActive_withCurrentDateBetweenStartAndEnd_returnsTrue() throws {
        // Given
        let pastDate = Date().addingTimeInterval(-86400) // Yesterday
        let futureDate = Date().addingTimeInterval(86400) // Tomorrow
        let period = try ExpensePeriod(
            name: "Current",
            startDate: pastDate,
            endDate: futureDate
        )

        // When/Then
        XCTAssertTrue(period.isActive)
    }

    func test_isActive_withEndDateInPast_returnsFalse() throws {
        // Given
        let startDate = Date().addingTimeInterval(-172800) // 2 days ago
        let endDate = Date().addingTimeInterval(-86400) // Yesterday
        let period = try ExpensePeriod(
            name: "Past",
            startDate: startDate,
            endDate: endDate
        )

        // When/Then
        XCTAssertFalse(period.isActive)
    }

    func test_durationDays_withNoEndDate_returnsNil() throws {
        // Given
        let period = try ExpensePeriod(name: "Ongoing", startDate: Date())

        // When/Then
        XCTAssertNil(period.durationDays)
    }

    func test_durationDays_with7DayPeriod_returns7() throws {
        // Given
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(7 * 24 * 60 * 60) // 7 days
        let period = try ExpensePeriod(
            name: "Week",
            startDate: startDate,
            endDate: endDate
        )

        // When/Then
        XCTAssertEqual(period.durationDays, 7)
    }

    func test_dateRangeString_withNoEndDate_showsOngoing() throws {
        // Given
        let period = try ExpensePeriod(name: "Ongoing", startDate: Date())

        // When
        let rangeString = period.dateRangeString

        // Then
        XCTAssertTrue(rangeString.contains("Ongoing"))
    }

    func test_dateRangeString_withEndDate_showsBothDates() throws {
        // Given
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(30 * 24 * 60 * 60)
        let period = try ExpensePeriod(
            name: "Month",
            startDate: startDate,
            endDate: endDate
        )

        // When
        let rangeString = period.dateRangeString

        // Then
        XCTAssertTrue(rangeString.contains("-"))
        XCTAssertFalse(rangeString.contains("Ongoing"))
    }

    // MARK: - Equality Tests

    func test_equality_samePeriods_areEqual() throws {
        // Given
        let id = UUID()
        let name = "March 2024"
        let startDate = Date()

        let period1 = try ExpensePeriod(id: id, name: name, startDate: startDate)
        let period2 = try ExpensePeriod(id: id, name: name, startDate: startDate)

        // When/Then
        XCTAssertEqual(period1, period2)
    }

    func test_equality_differentIDs_areNotEqual() throws {
        // Given
        let name = "March 2024"
        let startDate = Date()

        let period1 = try ExpensePeriod(name: name, startDate: startDate)
        let period2 = try ExpensePeriod(name: name, startDate: startDate)

        // When/Then
        XCTAssertNotEqual(period1, period2)
    }

    // MARK: - Identifiable Tests

    func test_identifiable_hasValidID() throws {
        // Given
        let period = try ExpensePeriod(name: "Test", startDate: Date())

        // When/Then
        XCTAssertNotNil(period.id)
    }

    // MARK: - Codable Tests

    func test_codable_encodesAndDecodes() throws {
        // Given
        let original = try ExpensePeriod(
            name: "Vacation",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400)
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ExpensePeriod.self, from: data)

        // Then
        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.name, original.name)
    }
}
