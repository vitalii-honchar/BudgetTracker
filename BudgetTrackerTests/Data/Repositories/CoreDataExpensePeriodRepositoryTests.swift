//
//  CoreDataExpensePeriodRepositoryTests.swift
//  BudgetTrackerTests
//
//  Integration tests for CoreDataExpensePeriodRepository
//

import XCTest
import CoreData
@testable import BudgetTracker

final class CoreDataExpensePeriodRepositoryTests: XCTestCase {

    // MARK: - Test Infrastructure

    var repository: CoreDataExpensePeriodRepository!
    var coreDataStack: CoreDataStack!

    override func setUp() async throws {
        try await super.setUp()
        coreDataStack = CoreDataStack.preview
        repository = CoreDataExpensePeriodRepository(coreDataStack: coreDataStack)
    }

    override func tearDown() async throws {
        repository = nil
        coreDataStack = nil
        try await super.tearDown()
    }

    // MARK: - Create Tests

    func test_create_withValidPeriod_savesAndReturnsPeriod() async throws {
        // Arrange
        let dateRange = try DateRange(
            start: Date(timeIntervalSince1970: 0),
            end: Date(timeIntervalSince1970: 86400 * 30)
        )
        let period = try ExpensePeriod(name: "March 2024", dateRange: dateRange)

        // Act
        let result = try await repository.create(period: period)

        // Assert
        XCTAssertEqual(result.id, period.id)
        XCTAssertEqual(result.name, "March 2024")

        // Verify persisted
        let found = try await repository.findById(id: period.id)
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.name, "March 2024")
    }

    func test_create_withOverlappingPeriod_throwsError() async throws {
        // Arrange
        let dateRange1 = try DateRange(
            start: Date(timeIntervalSince1970: 0),
            end: Date(timeIntervalSince1970: 86400 * 30)
        )
        let period1 = try ExpensePeriod(name: "Period 1", dateRange: dateRange1)
        _ = try await repository.create(period: period1)

        // Overlapping period
        let dateRange2 = try DateRange(
            start: Date(timeIntervalSince1970: 86400 * 15), // Overlaps with period1
            end: Date(timeIntervalSince1970: 86400 * 45)
        )
        let period2 = try ExpensePeriod(name: "Period 2", dateRange: dateRange2)

        // Act & Assert
        do {
            _ = try await repository.create(period: period2)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is RepositoryError)
        }
    }

    // MARK: - Find Tests

    func test_findById_withExistingPeriod_returnsPeriod() async throws {
        // Arrange
        let dateRange = try DateRange(
            start: Date(timeIntervalSince1970: 0),
            end: Date(timeIntervalSince1970: 86400 * 30)
        )
        let period = try ExpensePeriod(name: "Test", dateRange: dateRange)
        _ = try await repository.create(period: period)

        // Act
        let result = try await repository.findById(id: period.id)

        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, period.id)
        XCTAssertEqual(result?.name, "Test")
    }

    func test_findById_withNonexistentId_returnsNil() async throws {
        // Act
        let result = try await repository.findById(id: UUID())

        // Assert
        XCTAssertNil(result)
    }

    func test_findAll_returnsAllPeriods() async throws {
        // Arrange
        _ = try await repository.create(period: createPeriod(name: "Jan", startDay: 0, endDay: 30))
        _ = try await repository.create(period: createPeriod(name: "Feb", startDay: 31, endDay: 59))
        _ = try await repository.create(period: createPeriod(name: "Mar", startDay: 60, endDay: 90))

        // Act
        let result = try await repository.findAll()

        // Assert
        XCTAssertEqual(result.count, 3)
        // Sorted by startDate descending
        XCTAssertEqual(result[0].name, "Mar")
        XCTAssertEqual(result[1].name, "Feb")
        XCTAssertEqual(result[2].name, "Jan")
    }

    func test_findActive_withOngoingPeriod_returnsPeriod() async throws {
        // Arrange
        let ongoingRange = try DateRange(start: Date(), end: nil)
        let ongoing = try ExpensePeriod(name: "Current", dateRange: ongoingRange)
        _ = try await repository.create(period: ongoing)

        let closedRange = try DateRange(
            start: Date(timeIntervalSince1970: 0),
            end: Date(timeIntervalSince1970: 86400 * 30)
        )
        let closed = try ExpensePeriod(name: "Closed", dateRange: closedRange)
        _ = try await repository.create(period: closed)

        // Act
        let result = try await repository.findActive()

        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.name, "Current")
        XCTAssertTrue(result?.isOngoing ?? false)
    }

    func test_findActive_withNoPeriods_returnsNil() async throws {
        // Act
        let result = try await repository.findActive()

        // Assert
        XCTAssertNil(result)
    }

    func test_findCurrent_withActivePeriod_returnsPeriod() async throws {
        // Arrange
        let now = Date()
        let yesterday = now.addingTimeInterval(-86400)
        let tomorrow = now.addingTimeInterval(86400)

        let currentRange = try DateRange(start: yesterday, end: tomorrow)
        let current = try ExpensePeriod(name: "Current", dateRange: currentRange)
        _ = try await repository.create(period: current)

        // Act
        let result = try await repository.findCurrent()

        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.name, "Current")
    }

    func test_findOverlapping_returnsOverlappingPeriods() async throws {
        // Arrange
        _ = try await repository.create(period: createPeriod(name: "Jan", startDay: 0, endDay: 30))
        _ = try await repository.create(period: createPeriod(name: "Feb", startDay: 31, endDay: 60))
        _ = try await repository.create(period: createPeriod(name: "Mar", startDay: 61, endDay: 90))

        // Test period that overlaps with Jan and Feb
        let testRange = try DateRange(
            start: Date(timeIntervalSince1970: 86400 * 20), // In Jan
            end: Date(timeIntervalSince1970: 86400 * 50)   // In Feb
        )
        let testPeriod = try ExpensePeriod(name: "Test", dateRange: testRange)

        // Act
        let result = try await repository.findOverlapping(with: testPeriod)

        // Assert
        XCTAssertEqual(result.count, 2) // Jan and Feb
        let names = Set(result.map { $0.name })
        XCTAssertTrue(names.contains("Jan"))
        XCTAssertTrue(names.contains("Feb"))
        XCTAssertFalse(names.contains("Mar"))
    }

    // MARK: - Update Tests

    func test_update_withValidChanges_updatesPeriod() async throws {
        // Arrange
        let dateRange = try DateRange(
            start: Date(timeIntervalSince1970: 0),
            end: Date(timeIntervalSince1970: 86400 * 30)
        )
        let original = try ExpensePeriod(name: "Old Name", dateRange: dateRange)
        _ = try await repository.create(period: original)

        // Modify
        var updated = original
        try updated.updateName("New Name")

        // Act
        let result = try await repository.update(period: updated)

        // Assert
        XCTAssertEqual(result.name, "New Name")
        XCTAssertEqual(result.id, original.id)

        // Verify persisted
        let found = try await repository.findById(id: original.id)
        XCTAssertEqual(found?.name, "New Name")
    }

    func test_update_withNonexistentId_throwsError() async throws {
        // Arrange
        let dateRange = try DateRange(
            start: Date(timeIntervalSince1970: 0),
            end: Date(timeIntervalSince1970: 86400 * 30)
        )
        let period = try ExpensePeriod(name: "Test", dateRange: dateRange)

        // Act & Assert
        do {
            _ = try await repository.update(period: period)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is RepositoryError)
        }
    }

    // MARK: - Delete Tests

    func test_delete_withExistingPeriod_deletesSuccessfully() async throws {
        // Arrange
        let dateRange = try DateRange(
            start: Date(timeIntervalSince1970: 0),
            end: Date(timeIntervalSince1970: 86400 * 30)
        )
        let period = try ExpensePeriod(name: "Test", dateRange: dateRange)
        let created = try await repository.create(period: period)

        // Act
        try await repository.delete(id: created.id)

        // Assert
        let found = try await repository.findById(id: created.id)
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

    // MARK: - Find Recent Tests

    func test_findRecent_returnsLimitedResults() async throws {
        // Arrange
        for i in 0..<10 {
            let period = try createPeriod(
                name: "Period \(i)",
                startDay: i * 30,
                endDay: (i + 1) * 30
            )
            _ = try await repository.create(period: period)
        }

        // Act
        let result = try await repository.findRecent(limit: 5)

        // Assert
        XCTAssertEqual(result.count, 5)
        // Should be most recent (highest startDay)
        XCTAssertEqual(result[0].name, "Period 9")
    }

    // MARK: - Count Transactions Tests

    func test_countTransactions_withNoPeriod_returnsZero() async throws {
        // Act
        let count = try await repository.countTransactions(for: UUID())

        // Assert
        XCTAssertEqual(count, 0)
    }

    // MARK: - Test Helpers

    private func createPeriod(name: String, startDay: Int, endDay: Int) throws -> ExpensePeriod {
        let dateRange = try DateRange(
            start: Date(timeIntervalSince1970: 86400 * Double(startDay)),
            end: Date(timeIntervalSince1970: 86400 * Double(endDay))
        )
        return try ExpensePeriod(name: name, dateRange: dateRange)
    }
}
