//
//  DateRangeTests.swift
//  BudgetTrackerTests
//
//  Unit tests for DateRange Value Object
//

import XCTest
@testable import BudgetTracker

final class DateRangeTests: XCTestCase {

    // MARK: - Initialization Tests

    func test_init_withValidDates_createsDateRangeSuccessfully() throws {
        // Arrange
        let start = Date()
        let end = Date().addingTimeInterval(86400) // +1 day

        // Act
        let dateRange = try DateRange(start: start, end: end)

        // Assert
        XCTAssertEqual(dateRange.start, start)
        XCTAssertEqual(dateRange.end, end)
    }

    func test_init_withOnlyStartDate_createsOngoingRange() throws {
        // Arrange
        let start = Date()

        // Act
        let dateRange = try DateRange(start: start, end: nil)

        // Assert
        XCTAssertEqual(dateRange.start, start)
        XCTAssertNil(dateRange.end)
        XCTAssertTrue(dateRange.isOngoing)
    }

    func test_init_withEndBeforeStart_throwsError() {
        // Arrange
        let start = Date()
        let end = Date().addingTimeInterval(-86400) // -1 day (before start)

        // Act & Assert
        XCTAssertThrowsError(try DateRange(start: start, end: end)) { error in
            XCTAssertEqual(error as? DateRangeError, .endBeforeStart)
        }
    }

    func test_init_withSameStartAndEnd_succeeds() throws {
        // Arrange
        let date = Date()

        // Act & Assert
        XCTAssertNoThrow(try DateRange(start: date, end: date))
    }

    // MARK: - Contains Tests

    func test_contains_withDateInRange_returnsTrue() throws {
        // Arrange
        let start = Date(timeIntervalSince1970: 0) // Jan 1, 1970
        let end = Date(timeIntervalSince1970: 86400 * 10) // 10 days later
        let dateRange = try DateRange(start: start, end: end)
        let dateInRange = Date(timeIntervalSince1970: 86400 * 5) // 5 days later

        // Act
        let result = dateRange.contains(dateInRange)

        // Assert
        XCTAssertTrue(result)
    }

    func test_contains_withDateBeforeRange_returnsFalse() throws {
        // Arrange
        let start = Date(timeIntervalSince1970: 86400) // 1 day after epoch
        let end = Date(timeIntervalSince1970: 86400 * 10)
        let dateRange = try DateRange(start: start, end: end)
        let dateBeforeRange = Date(timeIntervalSince1970: 0) // Before start

        // Act
        let result = dateRange.contains(dateBeforeRange)

        // Assert
        XCTAssertFalse(result)
    }

    func test_contains_withDateAfterRange_returnsFalse() throws {
        // Arrange
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 86400 * 10)
        let dateRange = try DateRange(start: start, end: end)
        let dateAfterRange = Date(timeIntervalSince1970: 86400 * 20) // After end

        // Act
        let result = dateRange.contains(dateAfterRange)

        // Assert
        XCTAssertFalse(result)
    }

    func test_contains_withOngoingRange_returnsTrueForFutureDate() throws {
        // Arrange
        let start = Date()
        let dateRange = try DateRange(start: start, end: nil)
        let futureDate = Date().addingTimeInterval(86400 * 365) // 1 year later

        // Act
        let result = dateRange.contains(futureDate)

        // Assert
        XCTAssertTrue(result)
    }

    // MARK: - Status Tests

    func test_isOngoing_withNoEndDate_returnsTrue() throws {
        // Arrange
        let dateRange = try DateRange(start: Date(), end: nil)

        // Act & Assert
        XCTAssertTrue(dateRange.isOngoing)
    }

    func test_isOngoing_withEndDate_returnsFalse() throws {
        // Arrange
        let start = Date()
        let end = Date().addingTimeInterval(86400)
        let dateRange = try DateRange(start: start, end: end)

        // Act & Assert
        XCTAssertFalse(dateRange.isOngoing)
    }

    func test_hasEnded_withPastEndDate_returnsTrue() throws {
        // Arrange
        let start = Date().addingTimeInterval(-86400 * 10) // 10 days ago
        let end = Date().addingTimeInterval(-86400) // 1 day ago
        let dateRange = try DateRange(start: start, end: end)

        // Act & Assert
        XCTAssertTrue(dateRange.hasEnded)
    }

    func test_hasEnded_withFutureEndDate_returnsFalse() throws {
        // Arrange
        let start = Date()
        let end = Date().addingTimeInterval(86400) // 1 day later
        let dateRange = try DateRange(start: start, end: end)

        // Act & Assert
        XCTAssertFalse(dateRange.hasEnded)
    }

    // MARK: - Duration Tests

    func test_durationInDays_withKnownRange_returnsCorrectDays() throws {
        // Arrange
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 86400 * 10) // 10 days later
        let dateRange = try DateRange(start: start, end: end)

        // Act
        let duration = dateRange.durationInDays

        // Assert
        XCTAssertEqual(duration, 10)
    }

    func test_durationInDays_withOngoingRange_returnsNil() throws {
        // Arrange
        let dateRange = try DateRange(start: Date(), end: nil)

        // Act
        let duration = dateRange.durationInDays

        // Assert
        XCTAssertNil(duration)
    }

    func test_durationInSeconds_withKnownRange_returnsCorrectSeconds() throws {
        // Arrange
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 3600) // 1 hour later
        let dateRange = try DateRange(start: start, end: end)

        // Act
        let duration = dateRange.durationInSeconds

        // Assert
        XCTAssertEqual(duration, 3600)
    }

    // MARK: - Factory Method Tests

    func test_currentMonth_createsValidDateRange() throws {
        // Act
        let dateRange = try DateRange.currentMonth()

        // Assert
        XCTAssertFalse(dateRange.isOngoing)
        XCTAssertNotNil(dateRange.end)

        // Verify it's roughly 28-31 days
        let duration = dateRange.durationInDays
        XCTAssertNotNil(duration)
        XCTAssertGreaterThanOrEqual(duration!, 27)
        XCTAssertLessThanOrEqual(duration!, 32)
    }

    func test_lastDays_withValidDayCount_createsValidRange() throws {
        // Act
        let dateRange = try DateRange.lastDays(7)

        // Assert
        XCTAssertFalse(dateRange.isOngoing)
        XCTAssertNotNil(dateRange.end)

        // Verify it's 7 days
        let duration = dateRange.durationInDays
        XCTAssertEqual(duration, 7)
    }

    func test_lastMonth_createsValidDateRange() throws {
        // Act
        let dateRange = try DateRange.lastMonth()

        // Assert
        XCTAssertFalse(dateRange.isOngoing)
        XCTAssertNotNil(dateRange.end)

        // Verify it's roughly 28-31 days
        let duration = dateRange.durationInDays
        XCTAssertNotNil(duration)
        XCTAssertGreaterThanOrEqual(duration!, 27)
        XCTAssertLessThanOrEqual(duration!, 32)
    }

    func test_year_withValidYear_createsFullYearRange() throws {
        // Act
        let dateRange = try DateRange.year(2024)

        // Assert
        XCTAssertFalse(dateRange.isOngoing)

        // Verify it starts on Jan 1
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.year, .month, .day], from: dateRange.start)
        XCTAssertEqual(startComponents.year, 2024)
        XCTAssertEqual(startComponents.month, 1)
        XCTAssertEqual(startComponents.day, 1)

        // Verify it ends on Dec 31
        let endComponents = calendar.dateComponents([.year, .month, .day], from: dateRange.end!)
        XCTAssertEqual(endComponents.year, 2024)
        XCTAssertEqual(endComponents.month, 12)
        XCTAssertEqual(endComponents.day, 31)
    }

    // MARK: - Equality Tests

    func test_equality_withSameDates_returnsTrue() throws {
        // Arrange
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 86400)
        let dateRange1 = try DateRange(start: start, end: end)
        let dateRange2 = try DateRange(start: start, end: end)

        // Act & Assert
        XCTAssertEqual(dateRange1, dateRange2)
    }

    func test_equality_withDifferentDates_returnsFalse() throws {
        // Arrange
        let start1 = Date(timeIntervalSince1970: 0)
        let end1 = Date(timeIntervalSince1970: 86400)
        let dateRange1 = try DateRange(start: start1, end: end1)

        let start2 = Date(timeIntervalSince1970: 3600)
        let end2 = Date(timeIntervalSince1970: 86400 * 2)
        let dateRange2 = try DateRange(start: start2, end: end2)

        // Act & Assert
        XCTAssertNotEqual(dateRange1, dateRange2)
    }
}
