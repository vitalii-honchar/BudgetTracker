//
//  CoreDataCategoryRepositoryTests.swift
//  BudgetTrackerTests
//
//  Integration tests for CoreDataCategoryRepository
//

import XCTest
import CoreData
@testable import BudgetTracker

final class CoreDataCategoryRepositoryTests: XCTestCase {

    // MARK: - Test Infrastructure

    var repository: CoreDataCategoryRepository!
    var coreDataStack: CoreDataStack!

    override func setUp() async throws {
        try await super.setUp()
        coreDataStack = CoreDataStack.preview
        repository = CoreDataCategoryRepository(coreDataStack: coreDataStack)
    }

    override func tearDown() async throws {
        repository = nil
        coreDataStack = nil
        try await super.tearDown()
    }

    // MARK: - Create Tests

    func test_create_withValidCategory_savesAndReturnsCategory() async throws {
        // Arrange
        let category = try Category(
            name: "Food",
            icon: "cart.fill",
            colorHex: "#FF6B6B",
            isCustom: false,
            sortOrder: 1
        )

        // Act
        let result = try await repository.create(category: category)

        // Assert
        XCTAssertEqual(result.id, category.id)
        XCTAssertEqual(result.name, "Food")
        XCTAssertEqual(result.icon, "cart.fill")

        // Verify persisted
        let found = try await repository.findById(id: category.id)
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.name, "Food")
    }

    // MARK: - Find Tests

    func test_findById_withExistingCategory_returnsCategory() async throws {
        // Arrange
        let category = try Category(
            name: "Transport",
            icon: "car.fill",
            colorHex: "#4ECDC4",
            isCustom: false,
            sortOrder: 2
        )
        _ = try await repository.create(category: category)

        // Act
        let result = try await repository.findById(id: category.id)

        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, category.id)
        XCTAssertEqual(result?.name, "Transport")
    }

    func test_findById_withNonexistentId_returnsNil() async throws {
        // Act
        let result = try await repository.findById(id: UUID())

        // Assert
        XCTAssertNil(result)
    }

    func test_findAll_returnsAllCategories() async throws {
        // Arrange
        _ = try await repository.create(category: createCategory(name: "Food", sortOrder: 1))
        _ = try await repository.create(category: createCategory(name: "Transport", sortOrder: 2))
        _ = try await repository.create(category: createCategory(name: "Shopping", sortOrder: 3))

        // Act
        let result = try await repository.findAll()

        // Assert
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].name, "Food") // Sorted by sortOrder
        XCTAssertEqual(result[1].name, "Transport")
        XCTAssertEqual(result[2].name, "Shopping")
    }

    func test_findPredefined_returnsOnlyPredefinedCategories() async throws {
        // Arrange
        _ = try await repository.create(category: createCategory(name: "Food", sortOrder: 1, isCustom: false))
        _ = try await repository.create(category: createCategory(name: "Custom", sortOrder: 2, isCustom: true))
        _ = try await repository.create(category: createCategory(name: "Transport", sortOrder: 3, isCustom: false))

        // Act
        let result = try await repository.findPredefined()

        // Assert
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { !$0.isCustom })
    }

    func test_findCustom_returnsOnlyCustomCategories() async throws {
        // Arrange
        _ = try await repository.create(category: createCategory(name: "Food", sortOrder: 1, isCustom: false))
        _ = try await repository.create(category: createCategory(name: "Custom 1", sortOrder: 2, isCustom: true))
        _ = try await repository.create(category: createCategory(name: "Custom 2", sortOrder: 3, isCustom: true))

        // Act
        let result = try await repository.findCustom()

        // Assert
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { $0.isCustom })
    }

    // MARK: - Update Tests

    func test_update_withValidChanges_updatesCategory() async throws {
        // Arrange
        let original = try Category(
            name: "Old Name",
            icon: "star.fill",
            colorHex: "#FF6B6B",
            isCustom: true,
            sortOrder: 1
        )
        _ = try await repository.create(category: original)

        // Modify
        var updated = original
        try updated.updateName("New Name")

        // Act
        let result = try await repository.update(category: updated)

        // Assert
        XCTAssertEqual(result.name, "New Name")
        XCTAssertEqual(result.id, original.id)

        // Verify persisted
        let found = try await repository.findById(id: original.id)
        XCTAssertEqual(found?.name, "New Name")
    }

    func test_update_withNonexistentId_throwsError() async throws {
        // Arrange
        let category = try Category(
            name: "Test",
            icon: "star.fill",
            colorHex: "#FF6B6B",
            isCustom: true,
            sortOrder: 1
        )

        // Act & Assert
        do {
            _ = try await repository.update(category: category)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is RepositoryError)
        }
    }

    // MARK: - Delete Tests

    func test_delete_withCustomCategoryNoTransactions_deletesSuccessfully() async throws {
        // Arrange
        let category = try Category(
            name: "Custom",
            icon: "star.fill",
            colorHex: "#FF6B6B",
            isCustom: true,
            sortOrder: 1
        )
        let created = try await repository.create(category: category)

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

    // MARK: - CanDelete Tests

    func test_canDelete_withCustomCategoryNoTransactions_returnsTrue() async throws {
        // Arrange
        let category = try Category(
            name: "Custom",
            icon: "star.fill",
            colorHex: "#FF6B6B",
            isCustom: true,
            sortOrder: 1
        )
        let created = try await repository.create(category: category)

        // Act
        let result = try await repository.canDelete(id: created.id)

        // Assert
        XCTAssertTrue(result)
    }

    func test_canDelete_withPredefinedCategory_returnsFalse() async throws {
        // Arrange
        let category = try Category(
            name: "Food",
            icon: "cart.fill",
            colorHex: "#FF6B6B",
            isCustom: false,
            sortOrder: 1
        )
        let created = try await repository.create(category: category)

        // Act
        let result = try await repository.canDelete(id: created.id)

        // Assert
        XCTAssertFalse(result)
    }

    // MARK: - Transaction Count Tests

    func test_countTransactions_withNoTransactions_returnsZero() async throws {
        // Arrange
        let category = try Category(
            name: "Food",
            icon: "cart.fill",
            colorHex: "#FF6B6B",
            isCustom: false,
            sortOrder: 1
        )
        let created = try await repository.create(category: category)

        // Act
        let count = try await repository.countTransactions(for: created.id)

        // Assert
        XCTAssertEqual(count, 0)
    }

    // MARK: - Reorder Tests

    func test_reorderCategories_updatesSort Order() async throws {
        // Arrange
        let cat1 = try await repository.create(category: createCategory(name: "A", sortOrder: 1))
        let cat2 = try await repository.create(category: createCategory(name: "B", sortOrder: 2))
        let cat3 = try await repository.create(category: createCategory(name: "C", sortOrder: 3))

        // Act: Reverse order
        try await repository.reorderCategories([cat3.id, cat2.id, cat1.id])

        // Assert
        let all = try await repository.findAll()
        XCTAssertEqual(all[0].name, "C") // Now first
        XCTAssertEqual(all[1].name, "B")
        XCTAssertEqual(all[2].name, "A") // Now last
    }

    // MARK: - Test Helpers

    private func createCategory(
        name: String,
        sortOrder: Int,
        isCustom: Bool = false
    ) throws -> Category {
        return try Category(
            name: name,
            icon: "star.fill",
            colorHex: "#FF6B6B",
            isCustom: isCustom,
            sortOrder: sortOrder
        )
    }
}
