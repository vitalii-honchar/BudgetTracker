//
//  CategoryMapperTests.swift
//  BudgetTrackerTests
//
//  Integration tests for CategoryMapper
//

import XCTest
import CoreData
@testable import BudgetTracker

final class CategoryMapperTests: XCTestCase {

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

    func test_toCoreData_createsNewEntity() {
        // Arrange
        let category = try! Category(
            name: "Food",
            icon: "cart.fill",
            colorHex: "#FF6B6B",
            isCustom: false,
            sortOrder: 1
        )

        // Act
        let entity = CategoryMapper.toCoreData(category, in: context)

        // Assert
        XCTAssertEqual(entity.id, category.id)
        XCTAssertEqual(entity.name, "Food")
        XCTAssertEqual(entity.icon, "cart.fill")
        XCTAssertEqual(entity.colorHex, "#FF6B6B")
        XCTAssertFalse(entity.isCustom)
        XCTAssertEqual(entity.sortOrder, 1)
    }

    func test_toCoreData_updatesExistingEntity() {
        // Arrange
        let original = try! Category(
            name: "Food",
            icon: "cart.fill",
            colorHex: "#FF6B6B",
            isCustom: false,
            sortOrder: 1
        )
        let entity = CategoryMapper.toCoreData(original, in: context)

        // Modify domain category
        var updated = original
        try! updated.updateName("Groceries")

        // Act
        let result = CategoryMapper.toCoreData(updated, in: context, existing: entity)

        // Assert
        XCTAssertEqual(result, entity) // Same entity object
        XCTAssertEqual(result.name, "Groceries")
        XCTAssertEqual(result.id, original.id)
    }

    // MARK: - Core Data → Domain Tests

    func test_toDomain_withValidEntity_returnsDomainCategory() throws {
        // Arrange
        let entity = CategoryEntity(context: context)
        entity.id = UUID()
        entity.name = "Transport"
        entity.icon = "car.fill"
        entity.colorHex = "#4ECDC4"
        entity.isCustom = false
        entity.sortOrder = 3
        entity.createdAt = Date()
        entity.updatedAt = Date()

        // Act
        let category = try CategoryMapper.toDomain(entity)

        // Assert
        XCTAssertEqual(category.id, entity.id)
        XCTAssertEqual(category.name, "Transport")
        XCTAssertEqual(category.icon, "car.fill")
        XCTAssertEqual(category.colorHex, "#4ECDC4")
        XCTAssertFalse(category.isCustom)
        XCTAssertEqual(category.sortOrder, 3)
    }

    func test_toDomain_withInvalidData_throwsError() {
        // Arrange
        let entity = CategoryEntity(context: context)
        entity.id = UUID()
        entity.name = "" // Invalid: empty name
        entity.icon = "cart.fill"
        entity.colorHex = "#FF6B6B"
        entity.isCustom = false
        entity.sortOrder = 1
        entity.createdAt = Date()
        entity.updatedAt = Date()

        // Act & Assert
        XCTAssertThrowsError(try CategoryMapper.toDomain(entity)) { error in
            XCTAssertEqual(error as? CategoryError, .emptyName)
        }
    }

    // MARK: - Bidirectional Mapping Tests

    func test_roundTrip_preservesAllData() throws {
        // Arrange
        let original = try Category(
            name: "Shopping",
            icon: "bag.fill",
            colorHex: "#95E1D3",
            isCustom: true,
            sortOrder: 10
        )

        // Act: Domain → Core Data → Domain
        let entity = CategoryMapper.toCoreData(original, in: context)
        let result = try CategoryMapper.toDomain(entity)

        // Assert: All data preserved
        XCTAssertEqual(result.id, original.id)
        XCTAssertEqual(result.name, original.name)
        XCTAssertEqual(result.icon, original.icon)
        XCTAssertEqual(result.colorHex, original.colorHex)
        XCTAssertEqual(result.isCustom, original.isCustom)
        XCTAssertEqual(result.sortOrder, original.sortOrder)
    }

    // MARK: - Batch Mapping Tests

    func test_batchToDomain_mapsMultipleEntities() throws {
        // Arrange
        let entities = [
            createEntity(name: "Food", sortOrder: 1),
            createEntity(name: "Transport", sortOrder: 2),
            createEntity(name: "Shopping", sortOrder: 3)
        ]

        // Act
        let categories = try CategoryMapper.toDomain(entities)

        // Assert
        XCTAssertEqual(categories.count, 3)
        XCTAssertEqual(categories[0].name, "Food")
        XCTAssertEqual(categories[1].name, "Transport")
        XCTAssertEqual(categories[2].name, "Shopping")
    }

    func test_batchToDomain_withInvalidEntity_throwsError() {
        // Arrange
        let entities = [
            createEntity(name: "Food", sortOrder: 1),
            createInvalidEntity(), // Invalid name
            createEntity(name: "Shopping", sortOrder: 3)
        ]

        // Act & Assert
        XCTAssertThrowsError(try CategoryMapper.toDomain(entities))
    }

    // MARK: - Test Helpers

    private func createEntity(name: String, sortOrder: Int16) -> CategoryEntity {
        let entity = CategoryEntity(context: context)
        entity.id = UUID()
        entity.name = name
        entity.icon = "star.fill"
        entity.colorHex = "#FF6B6B"
        entity.isCustom = false
        entity.sortOrder = sortOrder
        entity.createdAt = Date()
        entity.updatedAt = Date()
        return entity
    }

    private func createInvalidEntity() -> CategoryEntity {
        let entity = CategoryEntity(context: context)
        entity.id = UUID()
        entity.name = "" // Invalid
        entity.icon = "star.fill"
        entity.colorHex = "#FF6B6B"
        entity.isCustom = false
        entity.sortOrder = 2
        entity.createdAt = Date()
        entity.updatedAt = Date()
        return entity
    }
}
