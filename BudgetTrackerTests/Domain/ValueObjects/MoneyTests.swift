//
//  MoneyTests.swift
//  BudgetTrackerTests
//
//  Unit tests for Money Value Object
//  Following test naming convention: test_[methodName]_[scenario]_[expectedBehavior]
//

import XCTest
@testable import BudgetTracker

final class MoneyTests: XCTestCase {

    // MARK: - Initialization Tests

    func test_init_withDecimalAmount_createsMoneySuccessfully() {
        // Arrange & Act
        let money = Money(amount: Decimal(42.50), currency: .USD)

        // Assert
        XCTAssertEqual(money.amount, Decimal(42.50))
        XCTAssertEqual(money.currency, .USD)
    }

    func test_init_withDoubleAmount_createsMoneySuccessfully() {
        // Arrange & Act
        let money = Money(amount: 100.00, currency: .EUR)

        // Assert
        XCTAssertEqual(money.amount, Decimal(100.00))
        XCTAssertEqual(money.currency, .EUR)
    }

    func test_init_withIntAmount_createsMoneySuccessfully() {
        // Arrange & Act
        let money = Money(amount: 50, currency: .GBP)

        // Assert
        XCTAssertEqual(money.amount, Decimal(50))
        XCTAssertEqual(money.currency, .GBP)
    }

    // MARK: - Validation Tests

    func test_validate_withPositiveAmount_succeeds() throws {
        // Arrange
        let money = Money(amount: Decimal(10.00), currency: .USD)

        // Act & Assert
        XCTAssertNoThrow(try money.validate())
    }

    func test_validate_withZeroAmount_succeeds() throws {
        // Arrange
        let money = Money(amount: Decimal(0), currency: .USD)

        // Act & Assert
        XCTAssertNoThrow(try money.validate())
    }

    func test_validate_withNegativeAmount_throwsError() {
        // Arrange
        let money = Money(amount: Decimal(-10.00), currency: .USD)

        // Act & Assert
        XCTAssertThrowsError(try money.validate()) { error in
            XCTAssertEqual(error as? MoneyError, .negativeAmount)
        }
    }

    // MARK: - Addition Tests

    func test_add_withSameCurrency_returnsCorrectSum() throws {
        // Arrange
        let money1 = Money(amount: Decimal(10.50), currency: .USD)
        let money2 = Money(amount: Decimal(5.25), currency: .USD)

        // Act
        let result = try money1.add(money2)

        // Assert
        XCTAssertEqual(result.amount, Decimal(15.75))
        XCTAssertEqual(result.currency, .USD)
    }

    func test_add_withDifferentCurrency_throwsCurrencyMismatchError() {
        // Arrange
        let money1 = Money(amount: Decimal(10.50), currency: .USD)
        let money2 = Money(amount: Decimal(5.25), currency: .EUR)

        // Act & Assert
        XCTAssertThrowsError(try money1.add(money2)) { error in
            XCTAssertEqual(error as? MoneyError, .currencyMismatch(.USD, .EUR))
        }
    }

    func test_add_withZeroAmount_returnsOriginalMoney() throws {
        // Arrange
        let money = Money(amount: Decimal(10.50), currency: .USD)
        let zero = Money(amount: Decimal(0), currency: .USD)

        // Act
        let result = try money.add(zero)

        // Assert
        XCTAssertEqual(result.amount, Decimal(10.50))
        XCTAssertEqual(result.currency, .USD)
    }

    // MARK: - Subtraction Tests

    func test_subtract_withSameCurrency_returnsCorrectDifference() throws {
        // Arrange
        let money1 = Money(amount: Decimal(10.50), currency: .USD)
        let money2 = Money(amount: Decimal(5.25), currency: .USD)

        // Act
        let result = try money1.subtract(money2)

        // Assert
        XCTAssertEqual(result.amount, Decimal(5.25))
        XCTAssertEqual(result.currency, .USD)
    }

    func test_subtract_withDifferentCurrency_throwsCurrencyMismatchError() {
        // Arrange
        let money1 = Money(amount: Decimal(10.50), currency: .USD)
        let money2 = Money(amount: Decimal(5.25), currency: .EUR)

        // Act & Assert
        XCTAssertThrowsError(try money1.subtract(money2)) { error in
            XCTAssertEqual(error as? MoneyError, .currencyMismatch(.USD, .EUR))
        }
    }

    func test_subtract_resultingInNegative_allowsNegativeResult() throws {
        // Arrange
        let money1 = Money(amount: Decimal(5.00), currency: .USD)
        let money2 = Money(amount: Decimal(10.00), currency: .USD)

        // Act
        let result = try money1.subtract(money2)

        // Assert
        XCTAssertEqual(result.amount, Decimal(-5.00))
    }

    // MARK: - Multiplication Tests

    func test_multiply_byPositiveScalar_returnsCorrectProduct() {
        // Arrange
        let money = Money(amount: Decimal(10.00), currency: .USD)

        // Act
        let result = money.multiply(by: Decimal(2.5))

        // Assert
        XCTAssertEqual(result.amount, Decimal(25.00))
        XCTAssertEqual(result.currency, .USD)
    }

    func test_multiply_byZero_returnsZero() {
        // Arrange
        let money = Money(amount: Decimal(10.00), currency: .USD)

        // Act
        let result = money.multiply(by: Decimal(0))

        // Assert
        XCTAssertEqual(result.amount, Decimal(0))
        XCTAssertEqual(result.currency, .USD)
    }

    func test_multiply_byNegativeScalar_returnsNegativeAmount() {
        // Arrange
        let money = Money(amount: Decimal(10.00), currency: .USD)

        // Act
        let result = money.multiply(by: Decimal(-2))

        // Assert
        XCTAssertEqual(result.amount, Decimal(-20.00))
    }

    // MARK: - Division Tests

    func test_divide_byPositiveScalar_returnsCorrectQuotient() throws {
        // Arrange
        let money = Money(amount: Decimal(10.00), currency: .USD)

        // Act
        let result = try money.divide(by: Decimal(2))

        // Assert
        XCTAssertEqual(result.amount, Decimal(5.00))
        XCTAssertEqual(result.currency, .USD)
    }

    func test_divide_byZero_throwsDivisionByZeroError() {
        // Arrange
        let money = Money(amount: Decimal(10.00), currency: .USD)

        // Act & Assert
        XCTAssertThrowsError(try money.divide(by: Decimal(0))) { error in
            XCTAssertEqual(error as? MoneyError, .divisionByZero)
        }
    }

    // MARK: - Comparison Tests

    func test_isGreaterThan_withLargerAmount_returnsTrue() throws {
        // Arrange
        let money1 = Money(amount: Decimal(10.00), currency: .USD)
        let money2 = Money(amount: Decimal(5.00), currency: .USD)

        // Act
        let result = try money1.isGreaterThan(money2)

        // Assert
        XCTAssertTrue(result)
    }

    func test_isGreaterThan_withSmallerAmount_returnsFalse() throws {
        // Arrange
        let money1 = Money(amount: Decimal(5.00), currency: .USD)
        let money2 = Money(amount: Decimal(10.00), currency: .USD)

        // Act
        let result = try money1.isGreaterThan(money2)

        // Assert
        XCTAssertFalse(result)
    }

    func test_isGreaterThan_withDifferentCurrency_throwsError() {
        // Arrange
        let money1 = Money(amount: Decimal(10.00), currency: .USD)
        let money2 = Money(amount: Decimal(5.00), currency: .EUR)

        // Act & Assert
        XCTAssertThrowsError(try money1.isGreaterThan(money2)) { error in
            XCTAssertEqual(error as? MoneyError, .currencyMismatch(.USD, .EUR))
        }
    }

    func test_isLessThan_withSmallerAmount_returnsTrue() throws {
        // Arrange
        let money1 = Money(amount: Decimal(5.00), currency: .USD)
        let money2 = Money(amount: Decimal(10.00), currency: .USD)

        // Act
        let result = try money1.isLessThan(money2)

        // Assert
        XCTAssertTrue(result)
    }

    // MARK: - Convenience Properties Tests

    func test_zero_createsZeroMoneyForCurrency() {
        // Arrange & Act
        let zero = Money.zero(.USD)

        // Assert
        XCTAssertEqual(zero.amount, Decimal(0))
        XCTAssertEqual(zero.currency, .USD)
        XCTAssertTrue(zero.isZero)
    }

    func test_isZero_withZeroAmount_returnsTrue() {
        // Arrange
        let money = Money(amount: Decimal(0), currency: .USD)

        // Act & Assert
        XCTAssertTrue(money.isZero)
    }

    func test_isZero_withNonZeroAmount_returnsFalse() {
        // Arrange
        let money = Money(amount: Decimal(10.00), currency: .USD)

        // Act & Assert
        XCTAssertFalse(money.isZero)
    }

    func test_isPositive_withPositiveAmount_returnsTrue() {
        // Arrange
        let money = Money(amount: Decimal(10.00), currency: .USD)

        // Act & Assert
        XCTAssertTrue(money.isPositive)
    }

    func test_isPositive_withZeroAmount_returnsFalse() {
        // Arrange
        let money = Money(amount: Decimal(0), currency: .USD)

        // Act & Assert
        XCTAssertFalse(money.isPositive)
    }

    func test_absoluteValue_withNegativeAmount_returnsPositive() {
        // Arrange
        let money = Money(amount: Decimal(-10.00), currency: .USD)

        // Act
        let result = money.absoluteValue

        // Assert
        XCTAssertEqual(result.amount, Decimal(10.00))
        XCTAssertEqual(result.currency, .USD)
    }

    func test_absoluteValue_withPositiveAmount_returnsUnchanged() {
        // Arrange
        let money = Money(amount: Decimal(10.00), currency: .USD)

        // Act
        let result = money.absoluteValue

        // Assert
        XCTAssertEqual(result.amount, Decimal(10.00))
    }

    // MARK: - Formatting Tests

    func test_formatted_withUSD_returnsFormattedString() {
        // Arrange
        let money = Money(amount: Decimal(42.50), currency: .USD)

        // Act
        let formatted = money.formatted

        // Assert
        XCTAssertTrue(formatted.contains("42.50") || formatted.contains("42,50"))
        XCTAssertTrue(formatted.contains("$"))
    }

    func test_formatted_withJPY_formatsWithoutDecimals() {
        // Arrange
        let money = Money(amount: Decimal(1000), currency: .JPY)

        // Act
        let formatted = money.formatted

        // Assert
        XCTAssertTrue(formatted.contains("1000") || formatted.contains("1,000"))
        XCTAssertFalse(formatted.contains("."))
    }

    // MARK: - Equality Tests

    func test_equality_withSameAmountAndCurrency_returnsTrue() {
        // Arrange
        let money1 = Money(amount: Decimal(10.00), currency: .USD)
        let money2 = Money(amount: Decimal(10.00), currency: .USD)

        // Act & Assert
        XCTAssertEqual(money1, money2)
    }

    func test_equality_withDifferentAmount_returnsFalse() {
        // Arrange
        let money1 = Money(amount: Decimal(10.00), currency: .USD)
        let money2 = Money(amount: Decimal(15.00), currency: .USD)

        // Act & Assert
        XCTAssertNotEqual(money1, money2)
    }

    func test_equality_withDifferentCurrency_returnsFalse() {
        // Arrange
        let money1 = Money(amount: Decimal(10.00), currency: .USD)
        let money2 = Money(amount: Decimal(10.00), currency: .EUR)

        // Act & Assert
        XCTAssertNotEqual(money1, money2)
    }
}
