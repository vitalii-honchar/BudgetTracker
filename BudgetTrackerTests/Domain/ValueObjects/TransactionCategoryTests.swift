//
//  TransactionCategoryTests.swift
//  BudgetTrackerTests
//
//  Unit tests for TransactionCategory Value Object
//

import XCTest
@testable import BudgetTracker

final class TransactionCategoryTests: XCTestCase {

    func test_icon_returnsValidSFSymbolForEachCategory() {
        XCTAssertEqual(TransactionCategory.food.icon, "cart.fill")
        XCTAssertEqual(TransactionCategory.restaurants.icon, "fork.knife")
        XCTAssertEqual(TransactionCategory.transport.icon, "car.fill")
        XCTAssertEqual(TransactionCategory.shopping.icon, "bag.fill")
    }

    func test_colorHex_returnsValidHexCodeForEachCategory() {
        XCTAssertTrue(TransactionCategory.food.colorHex.hasPrefix("#"))
        XCTAssertTrue(TransactionCategory.restaurants.colorHex.hasPrefix("#"))
        XCTAssertEqual(TransactionCategory.food.colorHex.count, 7) // #RRGGBB
    }

    func test_sortOrder_returnsUniqueOrderForEachCategory() {
        let orders = TransactionCategory.allCases.map { $0.sortOrder }
        let uniqueOrders = Set(orders)
        XCTAssertEqual(orders.count, uniqueOrders.count) // All orders should be unique
    }

    func test_sortedByOrder_returnsCategoriesInCorrectOrder() {
        let sorted = TransactionCategory.sortedByOrder
        for i in 0..<(sorted.count - 1) {
            XCTAssertLessThan(sorted[i].sortOrder, sorted[i + 1].sortOrder)
        }
    }

    func test_from_withValidString_returnsCorrectCategory() {
        XCTAssertEqual(TransactionCategory.from(string: "Food"), .food)
        XCTAssertEqual(TransactionCategory.from(string: "Transport"), .transport)
        XCTAssertEqual(TransactionCategory.from(string: "food"), .food) // Case insensitive
        XCTAssertEqual(TransactionCategory.from(string: "FOOD"), .food) // Case insensitive
    }

    func test_from_withInvalidString_returnsNil() {
        XCTAssertNil(TransactionCategory.from(string: "InvalidCategory"))
    }

    func test_displayName_returnsCorrectName() {
        XCTAssertEqual(TransactionCategory.food.displayName, "Food")
        XCTAssertEqual(TransactionCategory.restaurants.displayName, "Restaurants")
    }

    func test_allCases_includesAllCategories() {
        XCTAssertTrue(TransactionCategory.allCases.contains(.food))
        XCTAssertTrue(TransactionCategory.allCases.contains(.restaurants))
        XCTAssertTrue(TransactionCategory.allCases.contains(.transport))
        XCTAssertTrue(TransactionCategory.allCases.contains(.shopping))
        XCTAssertTrue(TransactionCategory.allCases.contains(.other))
        XCTAssertGreaterThanOrEqual(TransactionCategory.allCases.count, 8)
    }
}
