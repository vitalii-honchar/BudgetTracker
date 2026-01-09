//
//  Money.swift
//  BudgetTracker
//
//  Domain Layer - Value Object
//  Pure Swift, zero dependencies
//

import Foundation

/// Money represents a monetary amount with currency
/// Value Object: Immutable, type-safe monetary operations
struct Money: Codable, Equatable, Hashable {
    let amount: Decimal
    let currency: Currency

    // MARK: - Initialization

    init(amount: Decimal, currency: Currency) {
        self.amount = amount
        self.currency = currency
    }

    init(amount: Double, currency: Currency) {
        self.amount = Decimal(amount)
        self.currency = currency
    }

    init(amount: Int, currency: Currency) {
        self.amount = Decimal(amount)
        self.currency = currency
    }

    // MARK: - Validation

    /// Validates that the money amount is valid (non-negative)
    func validate() throws {
        guard amount >= 0 else {
            throw MoneyError.negativeAmount
        }
    }

    // MARK: - Arithmetic Operations

    /// Add two Money values (must have same currency)
    func add(_ other: Money) throws -> Money {
        guard self.currency == other.currency else {
            throw MoneyError.currencyMismatch(self.currency, other.currency)
        }
        return Money(amount: self.amount + other.amount, currency: self.currency)
    }

    /// Subtract two Money values (must have same currency)
    func subtract(_ other: Money) throws -> Money {
        guard self.currency == other.currency else {
            throw MoneyError.currencyMismatch(self.currency, other.currency)
        }
        let result = self.amount - other.amount
        return Money(amount: result, currency: self.currency)
    }

    /// Multiply money by a scalar
    func multiply(by scalar: Decimal) -> Money {
        return Money(amount: self.amount * scalar, currency: self.currency)
    }

    /// Divide money by a scalar
    func divide(by scalar: Decimal) throws -> Money {
        guard scalar != 0 else {
            throw MoneyError.divisionByZero
        }
        return Money(amount: self.amount / scalar, currency: self.currency)
    }

    // MARK: - Comparison

    /// Compare two Money values (must have same currency)
    func isGreaterThan(_ other: Money) throws -> Bool {
        guard self.currency == other.currency else {
            throw MoneyError.currencyMismatch(self.currency, other.currency)
        }
        return self.amount > other.amount
    }

    func isLessThan(_ other: Money) throws -> Bool {
        guard self.currency == other.currency else {
            throw MoneyError.currencyMismatch(self.currency, other.currency)
        }
        return self.amount < other.amount
    }

    // MARK: - Formatting

    /// Formatted string representation with currency symbol
    var formatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.rawValue
        formatter.currencySymbol = currency.symbol
        formatter.minimumFractionDigits = currency.decimalPlaces
        formatter.maximumFractionDigits = currency.decimalPlaces

        return formatter.string(from: amount as NSDecimalNumber) ?? "\(currency.symbol)\(amount)"
    }

    /// Formatted string with explicit sign (for displaying expenses/income)
    var formattedWithSign: String {
        let sign = amount >= 0 ? "+" : "-"
        return "\(sign)\(formatted)"
    }
}

// MARK: - Errors

enum MoneyError: Error, Equatable {
    case negativeAmount
    case currencyMismatch(Currency, Currency)
    case divisionByZero
    case invalidAmount

    var localizedDescription: String {
        switch self {
        case .negativeAmount:
            return "Amount cannot be negative"
        case .currencyMismatch(let c1, let c2):
            return "Cannot perform operation on different currencies: \(c1.rawValue) and \(c2.rawValue)"
        case .divisionByZero:
            return "Cannot divide by zero"
        case .invalidAmount:
            return "Invalid amount value"
        }
    }
}

// MARK: - Convenience Extensions

extension Money {
    /// Zero money for a given currency
    static func zero(_ currency: Currency) -> Money {
        return Money(amount: 0, currency: currency)
    }

    /// Check if this is zero money
    var isZero: Bool {
        return amount == 0
    }

    /// Check if this is positive money
    var isPositive: Bool {
        return amount > 0
    }

    /// Absolute value
    var absoluteValue: Money {
        return Money(amount: abs(amount), currency: currency)
    }
}
