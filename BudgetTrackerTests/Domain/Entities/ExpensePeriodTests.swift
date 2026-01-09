//
//  ExpensePeriodTests.swift
//  BudgetTrackerTests
//
//  Unit tests for ExpensePeriod Entity
//

import XCTest
@testable import BudgetTracker

final class ExpensePeriodTests: XCTestCase {

    // MARK: - Initialization Tests

    func test_init_withValidData_createsExpensePeriod() throws {
        // Arrange
        let dateRange = try DateRange(
            start: Date(),
            end: Date().addingTimeInterval(86400 * 30)
        )

        // Act
        let period = try ExpensePeriod(
            name: "March 2024",
            dateRange: dateRange
        )

        // Assert
        XCTAssertEqual(period.name, "March 2024")
        XCTAssertEqual(period.dateRange, dateRange)
        XCTAssertNotNil(period.id)
        XCTAssertNotNil(period.createdAt)
        XCTAssertNotNil(period.updatedAt)
    }

    func test_init_withEmptyName_throwsError() {
        // Arrange
        let dateRange = try! DateRange(start: Date(), end: nil)

        // Act & Assert
        XCTAssertThrowsError(try ExpensePeriod(
            name: "",
            dateRange: dateRange
        )) { error in
            XCTAssertEqual(error as? ExpensePeriodError, .emptyName)
        }
    }

    func test_init_withNameTooLong_throwsError() {
        // Arrange
        let dateRange = try! DateRange(start: Date(), end: nil)
        let longName = String(repeating: "a", count: 101)

        // Act & Assert
        XCTAssertThrowsError(try ExpensePeriod(
            name: longName,
            dateRange: dateRange
        )) { error in
            XCTAssertEqual(error as? ExpensePeriodError, .nameTooLong)
        }
    }

    // MARK: - Factory Method Tests

    func test_currentMonth_createsValidPeriod() throws {
        // Act
        let period = try ExpensePeriod.currentMonth()

        // Assert
        XCTAssertFalse(period.name.isEmpty)
        XCTAssertFalse(period.isOngoing)
        XCTAssertNotNil(period.durationInDays)

        // Duration should be roughly 28-31 days
        let duration = period.durationInDays!
        XCTAssertGreaterThanOrEqual(duration, 27)
        XCTAssertLessThanOrEqual(duration, 32)
    }

    func test_forMonth_withValidMonthAndYear_createsPeriod() throws {
        // Act
        let period = try ExpensePeriod.forMonth(3, year: 2024) // March 2024

        // Assert
        XCTAssertEqual(period.name, "March 2024")

        // Verify start date is March 1
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.year, .month, .day], from: period.dateRange.start)
        XCTAssertEqual(startComponents.year, 2024)
        XCTAssertEqual(startComponents.month, 3)
        XCTAssertEqual(startComponents.day, 1)

        // Verify end date is March 31
        let endComponents = calendar.dateComponents([.year, .month, .day], from: period.dateRange.end!)
        XCTAssertEqual(endComponents.day, 31)
    }

    func test_forMonth_withInvalidMonth_throwsError() {
        // Act & Assert
        XCTAssertThrowsError(try ExpensePeriod.forMonth(13, year: 2024)) { error in
            XCTAssertEqual(error as? ExpensePeriodError, .invalidMonth)
        }
    }

    func test_custom_withValidDates_createsPeriod() throws {
        // Arrange
        let start = Date()
        let end = Date().addingTimeInterval(86400 * 7) // 7 days later

        // Act
        let period = try ExpensePeriod.custom(name: "Week 1", start: start, end: end)

        // Assert
        XCTAssertEqual(period.name, "Week 1")
        XCTAssertEqual(period.dateRange.start, start)
        XCTAssertEqual(period.dateRange.end, end)
    }

    func test_ongoing_createsOngoingPeriod() throws {
        // Act
        let period = try ExpensePeriod.ongoing(name: "Current")

        // Assert
        XCTAssertEqual(period.name, "Current")
        XCTAssertTrue(period.isOngoing)
        XCTAssertNil(period.dateRange.end)
    }

    // MARK: - Mutation Tests

    func test_updateName_withValidName_updatesNameAndTimestamp() throws {
        // Arrange
        var period = try ExpensePeriod.ongoing(name: "Old Name")
        let originalUpdatedAt = period.updatedAt
        Thread.sleep(forTimeInterval: 0.01)

        // Act
        try period.updateName("New Name")

        // Assert
        XCTAssertEqual(period.name, "New Name")
        XCTAssertGreaterThan(period.updatedAt, originalUpdatedAt)
    }

    func test_updateName_withEmptyName_throwsError() throws {
        // Arrange
        var period = try ExpensePeriod.ongoing(name: "Test")

        // Act & Assert
        XCTAssertThrowsError(try period.updateName("")) { error in
            XCTAssertEqual(error as? ExpensePeriodError, .emptyName)
        }
    }

    func test_updateDateRange_updatesRangeAndTimestamp() throws {
        // Arrange
        var period = try ExpensePeriod.ongoing(name: "Test")
        let originalUpdatedAt = period.updatedAt
        Thread.sleep(forTimeInterval: 0.01)
        let newRange = try DateRange(start: Date(), end: Date().addingTimeInterval(86400))

        // Act
        period.updateDateRange(newRange)

        // Assert
        XCTAssertEqual(period.dateRange, newRange)
        XCTAssertGreaterThan(period.updatedAt, originalUpdatedAt)
    }

    func test_close_closesOngoingPeriodWithEndDate() throws {
        // Arrange
        var period = try ExpensePeriod.ongoing(name: "Test")
        let endDate = Date()

        // Act
        try period.close(endDate: endDate)

        // Assert
        XCTAssertFalse(period.isOngoing)
        XCTAssertEqual(period.dateRange.end, endDate)
    }

    func test_reopen_reopensClosedPeriod() throws {
        // Arrange
        let start = Date().addingTimeInterval(-86400 * 30)
        let end = Date().addingTimeInterval(-86400)
        var period = try ExpensePeriod.custom(name: "Test", start: start, end: end)

        // Act
        try period.reopen()

        // Assert
        XCTAssertTrue(period.isOngoing)
        XCTAssertNil(period.dateRange.end)
    }

    // MARK: - Business Logic Tests

    func test_contains_withDateInRange_returnsTrue() throws {
        // Arrange
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 86400 * 30)
        let period = try ExpensePeriod.custom(name: "Test", start: start, end: end)
        let dateInRange = Date(timeIntervalSince1970: 86400 * 15)

        // Act
        let result = period.contains(dateInRange)

        // Assert
        XCTAssertTrue(result)
    }

    func test_contains_withDateOutsideRange_returnsFalse() throws {
        // Arrange
        let start = Date(timeIntervalSince1970: 86400)
        let end = Date(timeIntervalSince1970: 86400 * 30)
        let period = try ExpensePeriod.custom(name: "Test", start: start, end: end)
        let dateOutsideRange = Date(timeIntervalSince1970: 0) // Before start

        // Act
        let result = period.contains(dateOutsideRange)

        // Assert
        XCTAssertFalse(result)
    }

    func test_isOngoing_withNoEndDate_returnsTrue() throws {
        // Arrange
        let period = try ExpensePeriod.ongoing(name: "Test")

        // Act & Assert
        XCTAssertTrue(period.isOngoing)
    }

    func test_isOngoing_withEndDate_returnsFalse() throws {
        // Arrange
        let period = try ExpensePeriod.custom(
            name: "Test",
            start: Date(),
            end: Date().addingTimeInterval(86400)
        )

        // Act & Assert
        XCTAssertFalse(period.isOngoing)
    }

    func test_hasEnded_withPastEndDate_returnsTrue() throws {
        // Arrange
        let start = Date().addingTimeInterval(-86400 * 10)
        let end = Date().addingTimeInterval(-86400) // Yesterday
        let period = try ExpensePeriod.custom(name: "Test", start: start, end: end)

        // Act & Assert
        XCTAssertTrue(period.hasEnded)
    }

    func test_hasEnded_withFutureEndDate_returnsFalse() throws {
        // Arrange
        let period = try ExpensePeriod.custom(
            name: "Test",
            start: Date(),
            end: Date().addingTimeInterval(86400) // Tomorrow
        )

        // Act & Assert
        XCTAssertFalse(period.hasEnded)
    }

    func test_isActive_withOngoingPeriod_returnsTrue() throws {
        // Arrange
        let period = try ExpensePeriod.ongoing(name: "Test")

        // Act & Assert
        XCTAssertTrue(period.isActive)
    }

    func test_isActive_withPastPeriod_returnsFalse() throws {
        // Arrange
        let start = Date().addingTimeInterval(-86400 * 10)
        let end = Date().addingTimeInterval(-86400)
        let period = try ExpensePeriod.custom(name: "Test", start: start, end: end)

        // Act & Assert
        XCTAssertFalse(period.isActive)
    }

    func test_durationInDays_withKnownRange_returnsCorrectDuration() throws {
        // Arrange
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 86400 * 30) // 30 days later
        let period = try ExpensePeriod.custom(name: "Test", start: start, end: end)

        // Act
        let duration = period.durationInDays

        // Assert
        XCTAssertEqual(duration, 30)
    }

    func test_durationInDays_withOngoingPeriod_returnsNil() throws {
        // Arrange
        let period = try ExpensePeriod.ongoing(name: "Test")

        // Act
        let duration = period.durationInDays

        // Assert
        XCTAssertNil(duration)
    }

    func test_overlaps_withOverlappingPeriods_returnsTrue() throws {
        // Arrange
        let period1 = try ExpensePeriod.custom(
            name: "Period 1",
            start: Date(timeIntervalSince1970: 0),
            end: Date(timeIntervalSince1970: 86400 * 30)
        )
        let period2 = try ExpensePeriod.custom(
            name: "Period 2",
            start: Date(timeIntervalSince1970: 86400 * 15), // Overlaps with period1
            end: Date(timeIntervalSince1970: 86400 * 45)
        )

        // Act
        let result = period1.overlaps(with: period2)

        // Assert
        XCTAssertTrue(result)
    }

    func test_overlaps_withNonOverlappingPeriods_returnsFalse() throws {
        // Arrange
        let period1 = try ExpensePeriod.custom(
            name: "Period 1",
            start: Date(timeIntervalSince1970: 0),
            end: Date(timeIntervalSince1970: 86400 * 10)
        )
        let period2 = try ExpensePeriod.custom(
            name: "Period 2",
            start: Date(timeIntervalSince1970: 86400 * 20), // After period1
            end: Date(timeIntervalSince1970: 86400 * 30)
        )

        // Act
        let result = period1.overlaps(with: period2)

        // Assert
        XCTAssertFalse(result)
    }

    func test_overlaps_withBothOngoing_returnsTrue() throws {
        // Arrange
        let period1 = try ExpensePeriod.ongoing(name: "Period 1")
        let period2 = try ExpensePeriod.ongoing(name: "Period 2")

        // Act
        let result = period1.overlaps(with: period2)

        // Assert
        XCTAssertTrue(result)
    }

    // MARK: - Comparison Tests

    func test_compareByStartDateDescending_sortsNewestFirst() throws {
        // Arrange
        let older = try ExpensePeriod.custom(
            name: "Older",
            start: Date().addingTimeInterval(-86400 * 30),
            end: Date().addingTimeInterval(-86400)
        )
        let newer = try ExpensePeriod.ongoing(name: "Newer")

        // Act
        let result = ExpensePeriod.compareByStartDateDescending(newer, older)

        // Assert
        XCTAssertTrue(result)
    }

    func test_compareByNameAscending_sortsAlphabetically() throws {
        // Arrange
        let periodA = try ExpensePeriod.ongoing(name: "A Period")
        let periodZ = try ExpensePeriod.ongoing(name: "Z Period")

        // Act
        let result = ExpensePeriod.compareByNameAscending(periodA, periodZ)

        // Assert
        XCTAssertTrue(result)
    }
}
