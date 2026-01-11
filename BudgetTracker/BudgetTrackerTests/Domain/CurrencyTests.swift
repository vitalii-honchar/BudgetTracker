//
//  CurrencyTests.swift
//  BudgetTrackerTests
//
//  Created by Claude Code on 1/11/26.
//

import XCTest
@testable import BudgetTracker

final class CurrencyTests: XCTestCase {

    // MARK: - Symbol Tests

    func test_symbol_USD_returnsCorrectSymbol() {
        XCTAssertEqual(Currency.USD.symbol, "$")
    }

    func test_symbol_EUR_returnsCorrectSymbol() {
        XCTAssertEqual(Currency.EUR.symbol, "€")
    }

    func test_symbol_GBP_returnsCorrectSymbol() {
        XCTAssertEqual(Currency.GBP.symbol, "£")
    }

    func test_symbol_JPY_returnsCorrectSymbol() {
        XCTAssertEqual(Currency.JPY.symbol, "¥")
    }

    func test_symbol_UAH_returnsCorrectSymbol() {
        XCTAssertEqual(Currency.UAH.symbol, "₴")
    }

    // MARK: - Code Tests

    func test_code_USD_returnsCorrectCode() {
        XCTAssertEqual(Currency.USD.code, "USD")
    }

    func test_code_EUR_returnsCorrectCode() {
        XCTAssertEqual(Currency.EUR.code, "EUR")
    }

    // MARK: - Name Tests

    func test_name_USD_returnsCorrectName() {
        XCTAssertEqual(Currency.USD.name, "US Dollar")
    }

    func test_name_EUR_returnsCorrectName() {
        XCTAssertEqual(Currency.EUR.name, "Euro")
    }

    func test_name_GBP_returnsCorrectName() {
        XCTAssertEqual(Currency.GBP.name, "British Pound")
    }

    func test_name_JPY_returnsCorrectName() {
        XCTAssertEqual(Currency.JPY.name, "Japanese Yen")
    }

    func test_name_UAH_returnsCorrectName() {
        XCTAssertEqual(Currency.UAH.name, "Ukrainian Hryvnia")
    }

    // MARK: - Description Tests

    func test_description_USD_returnsSymbolAndCode() {
        XCTAssertEqual(Currency.USD.description, "$ USD")
    }

    func test_description_EUR_returnsSymbolAndCode() {
        XCTAssertEqual(Currency.EUR.description, "€ EUR")
    }

    // MARK: - Codable Tests

    func test_encode_USD_encodesCorrectly() throws {
        let currency = Currency.USD
        let encoder = JSONEncoder()
        let data = try encoder.encode(currency)
        let json = String(data: data, encoding: .utf8)

        XCTAssertEqual(json, "\"USD\"")
    }

    func test_decode_USD_decodesCorrectly() throws {
        let json = "\"USD\"".data(using: .utf8)!
        let decoder = JSONDecoder()
        let currency = try decoder.decode(Currency.self, from: json)

        XCTAssertEqual(currency, .USD)
    }

    func test_decode_invalidCurrency_throwsError() {
        let json = "\"INVALID\"".data(using: .utf8)!
        let decoder = JSONDecoder()

        XCTAssertThrowsError(try decoder.decode(Currency.self, from: json))
    }

    // MARK: - CaseIterable Tests

    func test_allCases_containsAllCurrencies() {
        XCTAssertEqual(Currency.allCases.count, 5)
        XCTAssertTrue(Currency.allCases.contains(.USD))
        XCTAssertTrue(Currency.allCases.contains(.EUR))
        XCTAssertTrue(Currency.allCases.contains(.GBP))
        XCTAssertTrue(Currency.allCases.contains(.JPY))
        XCTAssertTrue(Currency.allCases.contains(.UAH))
    }
}
