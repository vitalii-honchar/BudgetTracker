//
//  MoneyTests.swift
//  BudgetTrackerTests
//
//  Created by Claude Code on 1/11/26.
//

import XCTest
@testable import BudgetTracker

final class MoneyTests: XCTestCase {

    // MARK: - Initialization Tests

    func test_init_withPositiveAmount_createsMoneySuccessfully() throws {
        let money = try Money(amount: 100.50, currency: .USD)

        XCTAssertEqual(money.amount, 100.50)
        XCTAssertEqual(money.currency, .USD)
    }

    func test_init_withZeroAmount_createsMoneySuccessfully() throws {
        let money = try Money(amount: 0, currency: .EUR)

        XCTAssertEqual(money.amount, 0)
        XCTAssertEqual(money.currency, .EUR)
    }

    func test_init_withNegativeAmount_throwsNegativeAmountError() {
        XCTAssertThrowsError(try Money(amount: -10, currency: .USD)) { error in
            XCTAssertEqual(error as? MoneyError, .negativeAmount)
        }
    }

    func test_zero_createsMoneyWithZeroAmount() {
        let money = Money.zero(currency: .GBP)

        XCTAssertEqual(money.amount, 0)
        XCTAssertEqual(money.currency, .GBP)
    }

    // MARK: - Addition Tests

    func test_add_withSameCurrency_returnsCorrectSum() throws {
        let money1 = try Money(amount: 10.50, currency: .USD)
        let money2 = try Money(amount: 5.25, currency: .USD)

        let result = try money1.add(money2)

        XCTAssertEqual(result.amount, 15.75)
        XCTAssertEqual(result.currency, .USD)
    }

    func test_add_withZeroAmount_returnsOriginalMoney() throws {
        let money = try Money(amount: 10.50, currency: .USD)
        let zero = Money.zero(currency: .USD)

        let result = try money.add(zero)

        XCTAssertEqual(result.amount, 10.50)
        XCTAssertEqual(result.currency, .USD)
    }

    func test_add_withDifferentCurrency_throwsCurrencyMismatchError() throws {
        let money1 = try Money(amount: 10, currency: .USD)
        let money2 = try Money(amount: 5, currency: .EUR)

        XCTAssertThrowsError(try money1.add(money2)) { error in
            XCTAssertEqual(error as? MoneyError, .currencyMismatch)
        }
    }

    func test_add_withLargeAmounts_handlesCorrectly() throws {
        let money1 = try Money(amount: Decimal(string: "999999.99")!, currency: .JPY)
        let money2 = try Money(amount: Decimal(string: "1000000.01")!, currency: .JPY)

        let result = try money1.add(money2)

        XCTAssertEqual(result.amount, Decimal(string: "2000000.00")!)
    }

    // MARK: - Subtraction Tests

    func test_subtract_withSameCurrency_returnsCorrectDifference() throws {
        let money1 = try Money(amount: 10.50, currency: .USD)
        let money2 = try Money(amount: 5.25, currency: .USD)

        let result = try money1.subtract(money2)

        XCTAssertEqual(result.amount, 5.25)
        XCTAssertEqual(result.currency, .USD)
    }

    func test_subtract_resultingInZero_returnsZeroMoney() throws {
        let money1 = try Money(amount: 10, currency: .EUR)
        let money2 = try Money(amount: 10, currency: .EUR)

        let result = try money1.subtract(money2)

        XCTAssertEqual(result.amount, 0)
    }

    func test_subtract_withDifferentCurrency_throwsCurrencyMismatchError() throws {
        let money1 = try Money(amount: 10, currency: .USD)
        let money2 = try Money(amount: 5, currency: .GBP)

        XCTAssertThrowsError(try money1.subtract(money2)) { error in
            XCTAssertEqual(error as? MoneyError, .currencyMismatch)
        }
    }

    func test_subtract_resultingInNegative_throwsNegativeResultError() throws {
        let money1 = try Money(amount: 5, currency: .USD)
        let money2 = try Money(amount: 10, currency: .USD)

        XCTAssertThrowsError(try money1.subtract(money2)) { error in
            XCTAssertEqual(error as? MoneyError, .negativeResult)
        }
    }

    // MARK: - Multiplication Tests

    func test_multiply_byPositiveScalar_returnsCorrectProduct() throws {
        let money = try Money(amount: 10, currency: .USD)

        let result = try money.multiply(by: 2.5)

        XCTAssertEqual(result.amount, 25)
        XCTAssertEqual(result.currency, .USD)
    }

    func test_multiply_byZero_returnsZero() throws {
        let money = try Money(amount: 100, currency: .EUR)

        let result = try money.multiply(by: 0)

        XCTAssertEqual(result.amount, 0)
    }

    func test_multiply_byOne_returnsOriginalAmount() throws {
        let money = try Money(amount: 42.50, currency: .GBP)

        let result = try money.multiply(by: 1)

        XCTAssertEqual(result.amount, 42.50)
    }

    func test_multiply_byNegativeScalar_throwsNegativeAmountError() throws {
        let money = try Money(amount: 10, currency: .USD)

        XCTAssertThrowsError(try money.multiply(by: -2)) { error in
            XCTAssertEqual(error as? MoneyError, .negativeAmount)
        }
    }

    // MARK: - Comparison Tests

    func test_isLess_withSmallerAmount_returnsTrue() throws {
        let money1 = try Money(amount: 5, currency: .USD)
        let money2 = try Money(amount: 10, currency: .USD)

        XCTAssertTrue(try money1.isLess(than: money2))
    }

    func test_isLess_withGreaterAmount_returnsFalse() throws {
        let money1 = try Money(amount: 10, currency: .USD)
        let money2 = try Money(amount: 5, currency: .USD)

        XCTAssertFalse(try money1.isLess(than: money2))
    }

    func test_isLess_withEqualAmount_returnsFalse() throws {
        let money1 = try Money(amount: 10, currency: .USD)
        let money2 = try Money(amount: 10, currency: .USD)

        XCTAssertFalse(try money1.isLess(than: money2))
    }

    func test_isLess_withDifferentCurrency_throwsCurrencyMismatchError() throws {
        let money1 = try Money(amount: 5, currency: .USD)
        let money2 = try Money(amount: 10, currency: .EUR)

        XCTAssertThrowsError(try money1.isLess(than: money2)) { error in
            XCTAssertEqual(error as? MoneyError, .currencyMismatch)
        }
    }

    func test_isGreater_withGreaterAmount_returnsTrue() throws {
        let money1 = try Money(amount: 10, currency: .USD)
        let money2 = try Money(amount: 5, currency: .USD)

        XCTAssertTrue(try money1.isGreater(than: money2))
    }

    func test_isGreater_withSmallerAmount_returnsFalse() throws {
        let money1 = try Money(amount: 5, currency: .USD)
        let money2 = try Money(amount: 10, currency: .USD)

        XCTAssertFalse(try money1.isGreater(than: money2))
    }

    func test_isGreater_withEqualAmount_returnsFalse() throws {
        let money1 = try Money(amount: 10, currency: .USD)
        let money2 = try Money(amount: 10, currency: .USD)

        XCTAssertFalse(try money1.isGreater(than: money2))
    }

    func test_isGreater_withDifferentCurrency_throwsCurrencyMismatchError() throws {
        let money1 = try Money(amount: 10, currency: .USD)
        let money2 = try Money(amount: 5, currency: .GBP)

        XCTAssertThrowsError(try money1.isGreater(than: money2)) { error in
            XCTAssertEqual(error as? MoneyError, .currencyMismatch)
        }
    }

    // MARK: - Equality Tests

    func test_equality_withSameAmountAndCurrency_returnsTrue() throws {
        let money1 = try Money(amount: 10.50, currency: .USD)
        let money2 = try Money(amount: 10.50, currency: .USD)

        XCTAssertEqual(money1, money2)
    }

    func test_equality_withDifferentAmount_returnsFalse() throws {
        let money1 = try Money(amount: 10, currency: .USD)
        let money2 = try Money(amount: 20, currency: .USD)

        XCTAssertNotEqual(money1, money2)
    }

    func test_equality_withDifferentCurrency_returnsFalse() throws {
        let money1 = try Money(amount: 10, currency: .USD)
        let money2 = try Money(amount: 10, currency: .EUR)

        XCTAssertNotEqual(money1, money2)
    }

    // MARK: - Formatting Tests

    func test_formatted_USD_includesSymbolAndTwoDecimals() throws {
        let money = try Money(amount: 42.5, currency: .USD)

        XCTAssertEqual(money.formatted, "$42.50")
    }

    func test_formatted_EUR_includesSymbolAndTwoDecimals() throws {
        let money = try Money(amount: 100, currency: .EUR)

        XCTAssertEqual(money.formatted, "€100.00")
    }

    func test_formatted_withZero_showsTwoDecimals() {
        let money = Money.zero(currency: .GBP)

        XCTAssertEqual(money.formatted, "£0.00")
    }

    func test_description_returnsFormattedString() throws {
        let money = try Money(amount: 25.99, currency: .UAH)

        XCTAssertEqual(money.description, "₴25.99")
    }

    // MARK: - Codable Tests

    func test_encode_encodesCorrectly() throws {
        let money = try Money(amount: 50.75, currency: .USD)
        let encoder = JSONEncoder()
        let data = try encoder.encode(money)

        // Decode to verify it encodes correctly
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Money.self, from: data)

        XCTAssertEqual(decoded.amount, 50.75)
        XCTAssertEqual(decoded.currency, .USD)
    }

    func test_decode_decodesCorrectly() throws {
        let json = """
        {"amount":75.50,"currency":"EUR"}
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        let money = try decoder.decode(Money.self, from: json)

        XCTAssertEqual(money.amount, 75.50)
        XCTAssertEqual(money.currency, .EUR)
    }
}
