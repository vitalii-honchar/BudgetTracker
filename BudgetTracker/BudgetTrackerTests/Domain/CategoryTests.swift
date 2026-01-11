//
//  CategoryTests.swift
//  BudgetTrackerTests
//
//  Created by Claude Code on 1/11/26.
//

import XCTest
@testable import BudgetTracker

final class CategoryTests: XCTestCase {

    // MARK: - Name Tests

    func test_name_food_returnsCorrectName() {
        XCTAssertEqual(Category.food.name, "Food & Dining")
    }

    func test_name_transport_returnsCorrectName() {
        XCTAssertEqual(Category.transport.name, "Transport")
    }

    func test_name_shopping_returnsCorrectName() {
        XCTAssertEqual(Category.shopping.name, "Shopping")
    }

    func test_name_entertainment_returnsCorrectName() {
        XCTAssertEqual(Category.entertainment.name, "Entertainment")
    }

    func test_name_bills_returnsCorrectName() {
        XCTAssertEqual(Category.bills.name, "Bills & Utilities")
    }

    func test_name_health_returnsCorrectName() {
        XCTAssertEqual(Category.health.name, "Health & Fitness")
    }

    func test_name_other_returnsCorrectName() {
        XCTAssertEqual(Category.other.name, "Other")
    }

    // MARK: - Icon Tests

    func test_icon_food_returnsCorrectIcon() {
        XCTAssertEqual(Category.food.icon, "cart.fill")
    }

    func test_icon_transport_returnsCorrectIcon() {
        XCTAssertEqual(Category.transport.icon, "car.fill")
    }

    func test_icon_shopping_returnsCorrectIcon() {
        XCTAssertEqual(Category.shopping.icon, "bag.fill")
    }

    func test_icon_entertainment_returnsCorrectIcon() {
        XCTAssertEqual(Category.entertainment.icon, "tv.fill")
    }

    func test_icon_bills_returnsCorrectIcon() {
        XCTAssertEqual(Category.bills.icon, "doc.text.fill")
    }

    func test_icon_health_returnsCorrectIcon() {
        XCTAssertEqual(Category.health.icon, "heart.fill")
    }

    func test_icon_other_returnsCorrectIcon() {
        XCTAssertEqual(Category.other.icon, "ellipsis.circle.fill")
    }

    // MARK: - Color Tests

    func test_colorHex_food_returnsCorrectColor() {
        XCTAssertEqual(Category.food.colorHex, "#FF6B6B")
    }

    func test_colorHex_transport_returnsCorrectColor() {
        XCTAssertEqual(Category.transport.colorHex, "#4ECDC4")
    }

    func test_colorHex_shopping_returnsCorrectColor() {
        XCTAssertEqual(Category.shopping.colorHex, "#45B7D1")
    }

    func test_colorHex_entertainment_returnsCorrectColor() {
        XCTAssertEqual(Category.entertainment.colorHex, "#FFA07A")
    }

    func test_colorHex_bills_returnsCorrectColor() {
        XCTAssertEqual(Category.bills.colorHex, "#98D8C8")
    }

    func test_colorHex_health_returnsCorrectColor() {
        XCTAssertEqual(Category.health.colorHex, "#FF6B9D")
    }

    func test_colorHex_other_returnsCorrectColor() {
        XCTAssertEqual(Category.other.colorHex, "#95A5A6")
    }

    // MARK: - Description Tests

    func test_description_returnsName() {
        XCTAssertEqual(Category.food.description, "Food & Dining")
        XCTAssertEqual(Category.other.description, "Other")
    }

    // MARK: - CaseIterable Tests

    func test_allCases_containsAllCategories() {
        XCTAssertEqual(Category.allCases.count, 7)
        XCTAssertTrue(Category.allCases.contains(.food))
        XCTAssertTrue(Category.allCases.contains(.transport))
        XCTAssertTrue(Category.allCases.contains(.shopping))
        XCTAssertTrue(Category.allCases.contains(.entertainment))
        XCTAssertTrue(Category.allCases.contains(.bills))
        XCTAssertTrue(Category.allCases.contains(.health))
        XCTAssertTrue(Category.allCases.contains(.other))
    }

    // MARK: - Codable Tests

    func test_encode_encodesCorrectly() throws {
        let category = Category.food
        let encoder = JSONEncoder()
        let data = try encoder.encode(category)
        let json = String(data: data, encoding: .utf8)

        XCTAssertEqual(json, "\"food\"")
    }

    func test_decode_decodesCorrectly() throws {
        let json = "\"transport\"".data(using: .utf8)!
        let decoder = JSONDecoder()
        let category = try decoder.decode(Category.self, from: json)

        XCTAssertEqual(category, .transport)
    }

    func test_decode_invalidCategory_throwsError() {
        let json = "\"invalid\"".data(using: .utf8)!
        let decoder = JSONDecoder()

        XCTAssertThrowsError(try decoder.decode(Category.self, from: json))
    }
}
