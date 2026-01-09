//
//  TransactionCategory.swift
//  BudgetTracker
//
//  Domain Layer - Value Object
//  Pure Swift, zero dependencies
//

import Foundation

/// TransactionCategory represents predefined transaction categories
/// Value Object: Type-safe category representation
/// Note: This is different from the Category entity which supports custom categories
enum TransactionCategory: String, Codable, CaseIterable, Identifiable {
    case food = "Food"
    case restaurants = "Restaurants"
    case transport = "Transport"
    case shopping = "Shopping"
    case entertainment = "Entertainment"
    case health = "Health"
    case sport = "Sport"
    case bills = "Bills"
    case education = "Education"
    case travel = "Travel"
    case other = "Other"

    var id: String { self.rawValue }

    /// Icon name (SF Symbol)
    var icon: String {
        switch self {
        case .food: return "cart.fill"
        case .restaurants: return "fork.knife"
        case .transport: return "car.fill"
        case .shopping: return "bag.fill"
        case .entertainment: return "ticket.fill"
        case .health: return "heart.fill"
        case .sport: return "figure.run"
        case .bills: return "doc.text.fill"
        case .education: return "book.fill"
        case .travel: return "airplane"
        case .other: return "questionmark.circle.fill"
        }
    }

    /// Color hex for display
    var colorHex: String {
        switch self {
        case .food: return "#FF6B6B"
        case .restaurants: return "#FFA07A"
        case .transport: return "#4ECDC4"
        case .shopping: return "#95E1D3"
        case .entertainment: return "#A8E6CF"
        case .health: return "#FFD93D"
        case .sport: return "#6BCB77"
        case .bills: return "#4D96FF"
        case .education: return "#B565D8"
        case .travel: return "#FF9A76"
        case .other: return "#999999"
        }
    }

    /// Sort order for display
    var sortOrder: Int {
        switch self {
        case .food: return 1
        case .restaurants: return 2
        case .transport: return 3
        case .shopping: return 4
        case .entertainment: return 5
        case .health: return 6
        case .sport: return 7
        case .bills: return 8
        case .education: return 9
        case .travel: return 10
        case .other: return 99
        }
    }

    /// Display name (same as rawValue for now, but allows for localization later)
    var displayName: String {
        return self.rawValue
    }
}

// MARK: - Utilities

extension TransactionCategory {
    /// Get all categories sorted by their sort order
    static var sortedByOrder: [TransactionCategory] {
        return TransactionCategory.allCases.sorted { $0.sortOrder < $1.sortOrder }
    }

    /// Get category from string (case-insensitive)
    static func from(string: String) -> TransactionCategory? {
        return TransactionCategory(rawValue: string) ??
               TransactionCategory.allCases.first { $0.rawValue.lowercased() == string.lowercased() }
    }
}
