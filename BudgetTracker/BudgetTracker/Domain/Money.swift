//
//  Money.swift
//  BudgetTracker
//
//  Created by Claude Code on 1/11/26.
//

import Foundation

/// Represents a monetary amount with a specific currency
struct Money: Equatable, Codable {
    let amount: Decimal
    let currency: Currency

    // MARK: - Initialization

    /// Creates a Money instance with validation
    /// - Parameters:
    ///   - amount: The monetary amount (must be non-negative)
    ///   - currency: The currency
    /// - Throws: MoneyError if validation fails
    init(amount: Decimal, currency: Currency) throws {
        guard amount >= 0 else {
            throw MoneyError.negativeAmount
        }
        self.amount = amount
        self.currency = currency
    }

    /// Creates a Money instance without validation (internal use)
    private init(unchecked amount: Decimal, currency: Currency) {
        self.amount = amount
        self.currency = currency
    }

    // MARK: - Arithmetic Operations

    /// Adds two Money values
    /// - Parameter other: Money to add
    /// - Returns: Sum of the two Money values
    /// - Throws: MoneyError.currencyMismatch if currencies don't match
    func add(_ other: Money) throws -> Money {
        guard self.currency == other.currency else {
            throw MoneyError.currencyMismatch
        }
        return Money(unchecked: self.amount + other.amount, currency: self.currency)
    }

    /// Subtracts another Money value from this one
    /// - Parameter other: Money to subtract
    /// - Returns: Difference of the two Money values
    /// - Throws: MoneyError.currencyMismatch if currencies don't match, MoneyError.negativeResult if result would be negative
    func subtract(_ other: Money) throws -> Money {
        guard self.currency == other.currency else {
            throw MoneyError.currencyMismatch
        }
        let result = self.amount - other.amount
        guard result >= 0 else {
            throw MoneyError.negativeResult
        }
        return Money(unchecked: result, currency: self.currency)
    }

    /// Multiplies Money by a scalar value
    /// - Parameter multiplier: The scalar multiplier
    /// - Returns: Product of Money and multiplier
    /// - Throws: MoneyError.negativeAmount if multiplier is negative
    func multiply(by multiplier: Decimal) throws -> Money {
        guard multiplier >= 0 else {
            throw MoneyError.negativeAmount
        }
        return Money(unchecked: self.amount * multiplier, currency: self.currency)
    }

    // MARK: - Comparison

    /// Checks if this Money is less than another
    /// - Parameter other: Money to compare with
    /// - Returns: True if this Money is less than other
    /// - Throws: MoneyError.currencyMismatch if currencies don't match
    func isLess(than other: Money) throws -> Bool {
        guard self.currency == other.currency else {
            throw MoneyError.currencyMismatch
        }
        return self.amount < other.amount
    }

    /// Checks if this Money is greater than another
    /// - Parameter other: Money to compare with
    /// - Returns: True if this Money is greater than other
    /// - Throws: MoneyError.currencyMismatch if currencies don't match
    func isGreater(than other: Money) throws -> Bool {
        guard self.currency == other.currency else {
            throw MoneyError.currencyMismatch
        }
        return self.amount > other.amount
    }

    // MARK: - Formatting

    /// Returns formatted string representation
    var formatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let amountString = formatter.string(from: amount as NSDecimalNumber) ?? "0.00"
        return "\(currency.symbol)\(amountString)"
    }
}

// MARK: - Errors

enum MoneyError: Error, Equatable {
    case negativeAmount
    case negativeResult
    case currencyMismatch
}

// MARK: - CustomStringConvertible

extension Money: CustomStringConvertible {
    var description: String {
        return formatted
    }
}

// MARK: - Convenience Initializers

extension Money {
    /// Creates Money with zero amount
    static func zero(currency: Currency) -> Money {
        return Money(unchecked: 0, currency: currency)
    }
}
