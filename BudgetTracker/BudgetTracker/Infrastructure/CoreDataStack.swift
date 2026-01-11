//
//  CoreDataStack.swift
//  BudgetTracker
//
//  Created by Claude Code on 1/11/26.
//

import Foundation
import CoreData

/// Manages Core Data stack for local persistence
final class CoreDataStack {
    static let shared = CoreDataStack()

    private init() {}

    // MARK: - Core Data Stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BudgetTracker")

        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        return container
    }()

    // MARK: - Convenience Properties

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func backgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }

    // MARK: - Save Context

    func saveContext() throws {
        let context = viewContext
        if context.hasChanges {
            try context.save()
        }
    }
}
