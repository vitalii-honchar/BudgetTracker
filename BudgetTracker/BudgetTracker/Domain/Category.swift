//
//  Category.swift
//  BudgetTracker
//
//  Created by Claude Code on 1/11/26.
//

import Foundation

/// Represents predefined transaction categories
enum Category: String, Codable, CaseIterable {
    case food
    case transport
    case shopping
    case entertainment
    case bills
    case health
    case other

    /// Human-readable category name
    var name: String {
        switch self {
        case .food: return "Food & Dining"
        case .transport: return "Transport"
        case .shopping: return "Shopping"
        case .entertainment: return "Entertainment"
        case .bills: return "Bills & Utilities"
        case .health: return "Health & Fitness"
        case .other: return "Other"
        }
    }

    /// SF Symbol icon name
    var icon: String {
        switch self {
        case .food: return "cart.fill"
        case .transport: return "car.fill"
        case .shopping: return "bag.fill"
        case .entertainment: return "tv.fill"
        case .bills: return "doc.text.fill"
        case .health: return "heart.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }

    /// Hex color code for UI representation
    var colorHex: String {
        switch self {
        case .food: return "#FF6B6B"           // Red
        case .transport: return "#4ECDC4"      // Teal
        case .shopping: return "#45B7D1"       // Blue
        case .entertainment: return "#FFA07A" // Light Salmon
        case .bills: return "#98D8C8"          // Mint
        case .health: return "#FF6B9D"         // Pink
        case .other: return "#95A5A6"          // Gray
        }
    }
}

// MARK: - CustomStringConvertible
extension Category: CustomStringConvertible {
    var description: String {
        return name
    }
}
