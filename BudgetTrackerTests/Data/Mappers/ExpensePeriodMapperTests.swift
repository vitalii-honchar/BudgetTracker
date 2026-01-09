//
//  ExpensePeriodMapperTests.swift
//  BudgetTrackerTests
//
//  Integration tests for ExpensePeriodMapper
//

import XCTest
import CoreData
@testable import BudgetTracker

final class ExpensePeriodMapperTests: XCTestCase {

    // MARK: - Test Infrastructure

    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        context = CoreDataStack.preview.viewContext
    }

    override func tearDown() {
        context = nil
        super.tearDown()
    }

    // MARK: - Domain → Core Data Tests

    func test_toCoreData_createsNewEntity() throws {
        // Arrange
        let dateRange = try DateRange(
            start: Date(timeIntervalSince1970: 0),
            end: Date(timeIntervalSince1970: 86400 * 30)
        )
        let period = try ExpensePeriod(name: "March 2024", dateRange: dateRange)

        // Act
        let entity = ExpensePeriodMapper.toCoreData(period, in: context)

        // Assert
        XCTAssertEqual(entity.id, period.id)
        XCTAssertEqual(entity.name, "March 2024")
        XCTAssertEqual(entity.startDate, dateRange.start)
        XCTAssertEqual(entity.endDate, dateRange.end)
    }

    func test_toCoreData_withOngoingPeriod_setsEndDateToNil() throws {
        // Arrange
        let dateRange = try DateRange(start: Date(), end: nil)
        let period = try ExpensePeriod(name: "Current", dateRange: dateRange)

        // Act
        let entity = ExpensePeriodMapper.toCoreData(period, in: context)

        // Assert
        XCTAssertNil(entity.endDate)
    }

    func test_toCoreData_updatesExistingEntity() throws {
        // Arrange
        let dateRange = try DateRange(
            start: Date(timeIntervalSince1970: 0),
            end: Date(timeIntervalSince1970: 86400 * 30)
        )
        let original = try ExpensePeriod(name: "March 2024", dateRange: dateRange)
        let entity = ExpensePeriodMapper.toCoreData(original, in: context)

        // Modify domain period
        var updated = original
        try updated.updateName("March Budget")

        // Act
        let result = ExpensePeriodMapper.toCoreData(updated, in: context, existing: entity)

        // Assert
        XCTAssertEqual(result, entity) // Same entity object
        XCTAssertEqual(result.name, "March Budget")
        XCTAssertEqual(result.id, original.id)
    }

    // MARK: - Core Data → Domain Tests

    func test_toDomain_withValidEntity_returnsDomainPeriod() throws {
        // Arrange
        let entity = ExpensePeriodEntity(context: context)
        entity.id = UUID()
        entity.name = "February 2024"
        entity.startDate = Date(timeIntervalSince1970: 0)
        entity.endDate = Date(timeIntervalSince1970: 86400 * 28)
        entity.createdAt = Date()
        entity.updatedAt = Date()

        // Act
        let period = try ExpensePeriodMapper.toDomain(entity)

        // Assert
        XCTAssertEqual(period.id, entity.id)
        XCTAssertEqual(period.name, "February 2024")
        XCTAssertEqual(period.dateRange.start, entity.startDate)
        XCTAssertEqual(period.dateRange.end, entity.endDate)
    }

    func test_toDomain_withOngoingPeriod_returnsOngoingPeriod() throws {
        // Arrange
        let entity = ExpensePeriodEntity(context: context)
        entity.id = UUID()
        entity.name = "Current"
        entity.startDate = Date()
        entity.endDate = nil // Ongoing
        entity.createdAt = Date()
        entity.updatedAt = Date()

        // Act
        let period = try ExpensePeriodMapper.toDomain(entity)

        // Assert
        XCTAssertTrue(period.isOngoing)
        XCTAssertNil(period.dateRange.end)
    }

    func test_toDomain_withInvalidData_throwsError() {
        // Arrange
        let entity = ExpensePeriodEntity(context: context)
        entity.id = UUID()
        entity.name = "" // Invalid: empty name
        entity.startDate = Date()
        entity.endDate = Date().addingTimeInterval(86400)
        entity.createdAt = Date()
        entity.updatedAt = Date()

        // Act & Assert
        XCTAssertThrowsError(try ExpensePeriodMapper.toDomain(entity)) { error in
            XCTAssertEqual(error as? ExpensePeriodError, .emptyName)
        }
    }

    func test_toDomain_withInvalidDateRange_throwsError() {
        // Arrange
        let entity = ExpensePeriodEntity(context: context)
        entity.id = UUID()
        entity.name = "Invalid Period"
        entity.startDate = Date(timeIntervalSince1970: 86400 * 30)
        entity.endDate = Date(timeIntervalSince1970: 0) // End before start
        entity.createdAt = Date()
        entity.updatedAt = Date()

        // Act & Assert
        XCTAssertThrowsError(try ExpensePeriodMapper.toDomain(entity)) { error in
            XCTAssertEqual(error as? DateRangeError, .invalidDateRange)
        }
    }

    // MARK: - Bidirectional Mapping Tests

    func test_roundTrip_preservesAllData() throws {
        // Arrange
        let dateRange = try DateRange(
            start: Date(timeIntervalSince1970: 0),
            end: Date(timeIntervalSince1970: 86400 * 30)
        )
        let original = try ExpensePeriod(name: "Test Period", dateRange: dateRange)

        // Act: Domain → Core Data → Domain
        let entity = ExpensePeriodMapper.toCoreData(original, in: context)
        let result = try ExpensePeriodMapper.toDomain(entity)

        // Assert: All data preserved
        XCTAssertEqual(result.id, original.id)
        XCTAssertEqual(result.name, original.name)
        XCTAssertEqual(result.dateRange.start, original.dateRange.start)
        XCTAssertEqual(result.dateRange.end, original.dateRange.end)
    }

    func test_roundTrip_withOngoingPeriod_preservesOngoingState() throws {
        // Arrange
        let dateRange = try DateRange(start: Date(), end: nil)
        let original = try ExpensePeriod(name: "Ongoing", dateRange: dateRange)

        // Act: Domain → Core Data → Domain
        let entity = ExpensePeriodMapper.toCoreData(original, in: context)
        let result = try ExpensePeriodMapper.toDomain(entity)

        // Assert
        XCTAssertTrue(result.isOngoing)
        XCTAssertNil(result.dateRange.end)
    }

    // MARK: - Batch Mapping Tests

    func test_batchToDomain_mapsMultipleEntities() throws {
        // Arrange
        let entities = [
            try createEntity(name: "January 2024", days: 31),
            try createEntity(name: "February 2024", days: 28),
            try createEntity(name: "March 2024", days: 31)
        ]

        // Act
        let periods = try ExpensePeriodMapper.toDomain(entities)

        // Assert
        XCTAssertEqual(periods.count, 3)
        XCTAssertEqual(periods[0].name, "January 2024")
        XCTAssertEqual(periods[1].name, "February 2024")
        XCTAssertEqual(periods[2].name, "March 2024")
    }

    func test_batchToDomain_withInvalidEntity_throwsError() throws {
        // Arrange
        let entities = [
            try createEntity(name: "Valid Period", days: 30),
            createInvalidEntity(),
            try createEntity(name: "Another Valid", days: 30)
        ]

        // Act & Assert
        XCTAssertThrowsError(try ExpensePeriodMapper.toDomain(entities))
    }

    // MARK: - Test Helpers

    private func createEntity(name: String, days: Int) throws -> ExpensePeriodEntity {
        let entity = ExpensePeriodEntity(context: context)
        entity.id = UUID()
        entity.name = name
        entity.startDate = Date(timeIntervalSince1970: 0)
        entity.endDate = Date(timeIntervalSince1970: 86400 * Double(days))
        entity.createdAt = Date()
        entity.updatedAt = Date()
        return entity
    }

    private func createInvalidEntity() -> ExpensePeriodEntity {
        let entity = ExpensePeriodEntity(context: context)
        entity.id = UUID()
        entity.name = "" // Invalid
        entity.startDate = Date()
        entity.endDate = Date().addingTimeInterval(86400)
        entity.createdAt = Date()
        entity.updatedAt = Date()
        return entity
    }
}
