//
//  Currency.swift
//  BudgetTracker
//
//  Created by Claude Code on 1/11/26.
//

import Foundation

/// Represents supported currencies following ISO 4217 standard
enum Currency: String, Codable, CaseIterable {
    case USD
    case EUR
    case GBP
    case JPY
    case UAH

    /// Currency symbol (e.g., "$", "€", "£")
    var symbol: String {
        switch self {
        case .USD: return "$"
        case .EUR: return "€"
        case .GBP: return "£"
        case .JPY: return "¥"
        case .UAH: return "₴"
        }
    }

    /// ISO 4217 currency code
    var code: String {
        return self.rawValue
    }

    /// Human-readable currency name
    var name: String {
        switch self {
        case .USD: return "US Dollar"
        case .EUR: return "Euro"
        case .GBP: return "British Pound"
        case .JPY: return "Japanese Yen"
        case .UAH: return "Ukrainian Hryvnia"
        }
    }
}

// MARK: - CustomStringConvertible
extension Currency: CustomStringConvertible {
    var description: String {
        return "\(symbol) \(code)"
    }
}
