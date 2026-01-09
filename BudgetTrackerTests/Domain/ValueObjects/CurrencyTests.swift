//
//  CurrencyTests.swift
//  BudgetTrackerTests
//
//  Unit tests for Currency Value Object
//

import XCTest
@testable import BudgetTracker

final class CurrencyTests: XCTestCase {

    func test_symbol_returnsCorrectSymbolForEachCurrency() {
        XCTAssertEqual(Currency.USD.symbol, "$")
        XCTAssertEqual(Currency.EUR.symbol, "€")
        XCTAssertEqual(Currency.GBP.symbol, "£")
        XCTAssertEqual(Currency.JPY.symbol, "¥")
    }

    func test_name_returnsCorrectNameForEachCurrency() {
        XCTAssertEqual(Currency.USD.name, "US Dollar")
        XCTAssertEqual(Currency.EUR.name, "Euro")
        XCTAssertEqual(Currency.GBP.name, "British Pound")
        XCTAssertEqual(Currency.JPY.name, "Japanese Yen")
    }

    func test_decimalPlaces_returnsCorrectValueForEachCurrency() {
        XCTAssertEqual(Currency.USD.decimalPlaces, 2)
        XCTAssertEqual(Currency.EUR.decimalPlaces, 2)
        XCTAssertEqual(Currency.JPY.decimalPlaces, 0) // Yen has no decimal places
    }

    func test_allCases_includesAllCurrencies() {
        XCTAssertTrue(Currency.allCases.contains(.USD))
        XCTAssertTrue(Currency.allCases.contains(.EUR))
        XCTAssertTrue(Currency.allCases.contains(.GBP))
        XCTAssertTrue(Currency.allCases.contains(.JPY))
        XCTAssertGreaterThanOrEqual(Currency.allCases.count, 4)
    }
}
