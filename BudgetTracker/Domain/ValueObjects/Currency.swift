//
//  Currency.swift
//  BudgetTracker
//
//  Domain Layer - Value Object
//  Pure Swift, zero dependencies
//

import Foundation

/// Currency represents ISO 4217 currency codes
/// Value Object: Immutable, compared by value
enum Currency: String, Codable, CaseIterable, Identifiable {
    case USD = "USD"
    case EUR = "EUR"
    case GBP = "GBP"
    case JPY = "JPY"
    case CAD = "CAD"
    case AUD = "AUD"
    case CHF = "CHF"
    case CNY = "CNY"
    case INR = "INR"
    case BRL = "BRL"

    var id: String { self.rawValue }

    /// Currency symbol for display
    var symbol: String {
        switch self {
        case .USD: return "$"
        case .EUR: return "€"
        case .GBP: return "£"
        case .JPY: return "¥"
        case .CAD: return "C$"
        case .AUD: return "A$"
        case .CHF: return "CHF"
        case .CNY: return "¥"
        case .INR: return "₹"
        case .BRL: return "R$"
        }
    }

    /// Full currency name
    var name: String {
        switch self {
        case .USD: return "US Dollar"
        case .EUR: return "Euro"
        case .GBP: return "British Pound"
        case .JPY: return "Japanese Yen"
        case .CAD: return "Canadian Dollar"
        case .AUD: return "Australian Dollar"
        case .CHF: return "Swiss Franc"
        case .CNY: return "Chinese Yuan"
        case .INR: return "Indian Rupee"
        case .BRL: return "Brazilian Real"
        }
    }

    /// Number of decimal places for this currency
    var decimalPlaces: Int {
        switch self {
        case .JPY: return 0  // Yen has no decimal places
        default: return 2
        }
    }
}
