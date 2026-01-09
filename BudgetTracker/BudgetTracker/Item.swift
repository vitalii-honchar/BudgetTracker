//
//  Item.swift
//  BudgetTracker
//
//  Created by Vitalii Honchar on 2026-01-09.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
