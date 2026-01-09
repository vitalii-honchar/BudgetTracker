//
//  CategoryTests.swift
//  BudgetTrackerTests
//
//  Unit tests for Category Entity
//

import XCTest
@testable import BudgetTracker

final class CategoryTests: XCTestCase {

    // MARK: - Initialization Tests

    func test_init_withValidData_createsCategory() throws {
        // Arrange & Act
        let category = try Category(
            name: "Food",
            icon: "cart.fill",
            colorHex: "#FF6B6B",
            isCustom: false,
            sortOrder: 1
        )

        // Assert
        XCTAssertEqual(category.name, "Food")
        XCTAssertEqual(category.icon, "cart.fill")
        XCTAssertEqual(category.colorHex, "#FF6B6B")
        XCTAssertFalse(category.isCustom)
        XCTAssertEqual(category.sortOrder, 1)
        XCTAssertNotNil(category.id)
        XCTAssertNotNil(category.createdAt)
        XCTAssertNotNil(category.updatedAt)
    }

    func test_init_withEmptyName_throwsError() {
        // Act & Assert
        XCTAssertThrowsError(try Category(
            name: "",
            icon: "cart.fill"
        )) { error in
            XCTAssertEqual(error as? CategoryError, .emptyName)
        }
    }

    func test_init_withNameTooLong_throwsError() {
        // Arrange
        let longName = String(repeating: "a", count: 51)

        // Act & Assert
        XCTAssertThrowsError(try Category(
            name: longName,
            icon: "cart.fill"
        )) { error in
            XCTAssertEqual(error as? CategoryError, .nameTooLong)
        }
    }

    func test_init_withEmptyIcon_throwsError() {
        // Act & Assert
        XCTAssertThrowsError(try Category(
            name: "Food",
            icon: ""
        )) { error in
            XCTAssertEqual(error as? CategoryError, .emptyIcon)
        }
    }

    func test_init_withInvalidColorFormat_throwsError() {
        // Act & Assert
        XCTAssertThrowsError(try Category(
            name: "Food",
            icon: "cart.fill",
            colorHex: "FF6B6B" // Missing #
        )) { error in
            XCTAssertEqual(error as? CategoryError, .invalidColorFormat)
        }
    }

    func test_init_withNegativeSortOrder_throwsError() {
        // Act & Assert
        XCTAssertThrowsError(try Category(
            name: "Food",
            icon: "cart.fill",
            sortOrder: -1
        )) { error in
            XCTAssertEqual(error as? CategoryError, .invalidSortOrder)
        }
    }

    // MARK: - Factory Method Tests

    func test_predefined_fromTransactionCategory_createsPredefinedCategory() throws {
        // Act
        let category = try Category.predefined(from: .food, sortOrder: 1)

        // Assert
        XCTAssertEqual(category.name, "Food")
        XCTAssertEqual(category.icon, "cart.fill")
        XCTAssertEqual(category.colorHex, "#FF6B6B")
        XCTAssertFalse(category.isCustom)
        XCTAssertEqual(category.sortOrder, 1)
    }

    func test_custom_withValidData_createsCustomCategory() throws {
        // Act
        let category = try Category.custom(
            name: "My Category",
            icon: "star.fill",
            colorHex: "#123456"
        )

        // Assert
        XCTAssertEqual(category.name, "My Category")
        XCTAssertEqual(category.icon, "star.fill")
        XCTAssertEqual(category.colorHex, "#123456")
        XCTAssertTrue(category.isCustom)
        XCTAssertEqual(category.sortOrder, 100)
    }

    // MARK: - Mutation Tests

    func test_updateName_withValidName_updatesNameAndTimestamp() throws {
        // Arrange
        var category = try Category(name: "Old Name", icon: "cart.fill")
        let originalUpdatedAt = category.updatedAt
        Thread.sleep(forTimeInterval: 0.01) // Ensure timestamp changes

        // Act
        try category.updateName("New Name")

        // Assert
        XCTAssertEqual(category.name, "New Name")
        XCTAssertGreaterThan(category.updatedAt, originalUpdatedAt)
    }

    func test_updateName_withEmptyName_throwsError() throws {
        // Arrange
        var category = try Category(name: "Food", icon: "cart.fill")

        // Act & Assert
        XCTAssertThrowsError(try category.updateName("")) { error in
            XCTAssertEqual(error as? CategoryError, .emptyName)
        }
    }

    func test_updateIcon_withValidIcon_updatesIconAndTimestamp() throws {
        // Arrange
        var category = try Category(name: "Food", icon: "cart.fill")
        let originalUpdatedAt = category.updatedAt
        Thread.sleep(forTimeInterval: 0.01)

        // Act
        try category.updateIcon("fork.knife")

        // Assert
        XCTAssertEqual(category.icon, "fork.knife")
        XCTAssertGreaterThan(category.updatedAt, originalUpdatedAt)
    }

    func test_updateColor_withValidColor_updatesColorAndTimestamp() throws {
        // Arrange
        var category = try Category(name: "Food", icon: "cart.fill")
        let originalUpdatedAt = category.updatedAt
        Thread.sleep(forTimeInterval: 0.01)

        // Act
        try category.updateColor("#ABCDEF")

        // Assert
        XCTAssertEqual(category.colorHex, "#ABCDEF")
        XCTAssertGreaterThan(category.updatedAt, originalUpdatedAt)
    }

    func test_updateSortOrder_withValidOrder_updatesOrderAndTimestamp() throws {
        // Arrange
        var category = try Category(name: "Food", icon: "cart.fill", sortOrder: 1)
        let originalUpdatedAt = category.updatedAt
        Thread.sleep(forTimeInterval: 0.01)

        // Act
        try category.updateSortOrder(5)

        // Assert
        XCTAssertEqual(category.sortOrder, 5)
        XCTAssertGreaterThan(category.updatedAt, originalUpdatedAt)
    }

    // MARK: - Business Logic Tests

    func test_canBeDeleted_withCustomCategory_returnsTrue() throws {
        // Arrange
        let category = try Category.custom(name: "Custom", icon: "star", colorHex: "#123456")

        // Act & Assert
        XCTAssertTrue(category.canBeDeleted)
    }

    func test_canBeDeleted_withPredefinedCategory_returnsFalse() throws {
        // Arrange
        let category = try Category.predefined(from: .food, sortOrder: 1)

        // Act & Assert
        XCTAssertFalse(category.canBeDeleted)
    }

    func test_canBeEdited_withCustomCategory_returnsTrue() throws {
        // Arrange
        let category = try Category.custom(name: "Custom", icon: "star", colorHex: "#123456")

        // Act & Assert
        XCTAssertTrue(category.canBeEdited)
    }

    func test_canBeEdited_withPredefinedCategory_returnsFalse() throws {
        // Arrange
        let category = try Category.predefined(from: .food, sortOrder: 1)

        // Act & Assert
        XCTAssertFalse(category.canBeEdited)
    }

    // MARK: - Equality Tests

    func test_equality_withSameId_returnsTrue() throws {
        // Arrange
        let id = UUID()
        let category1 = try Category(id: id, name: "Food", icon: "cart.fill")
        let category2 = try Category(id: id, name: "Food", icon: "cart.fill")

        // Act & Assert
        XCTAssertEqual(category1, category2)
    }

    func test_equality_withDifferentId_returnsFalse() throws {
        // Arrange
        let category1 = try Category(name: "Food", icon: "cart.fill")
        let category2 = try Category(name: "Food", icon: "cart.fill")

        // Act & Assert
        XCTAssertNotEqual(category1, category2)
    }
}
