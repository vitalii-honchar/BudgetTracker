//
//  InMemoryCoreDataStack.swift
//  BudgetTrackerTests
//
//  Created by Claude Code on 1/11/26.
//

import Foundation
import CoreData
@testable import BudgetTracker

/// In-memory Core Data stack for testing
final class InMemoryCoreDataStack {
    static func create() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "BudgetTracker")

        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false

        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { (description, error) in
            precondition(description.type == NSInMemoryStoreType)
            if let error = error {
                fatalError("Failed to create in-memory store: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true

        return container
    }
}
