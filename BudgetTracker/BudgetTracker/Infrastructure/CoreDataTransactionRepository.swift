//
//  CoreDataTransactionRepository.swift
//  BudgetTracker
//
//  Created by Claude Code on 1/11/26.
//

import Foundation
import CoreData

/// Core Data implementation of TransactionRepository
final class CoreDataTransactionRepository: TransactionRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - TransactionRepository

    func create(transaction: Transaction) async throws -> Transaction {
        return try await context.perform {
            // Create entity
            let entity = TransactionMapper.toEntity(transaction: transaction, context: self.context)

            // Save context
            do {
                try self.context.save()
                return transaction
            } catch {
                throw RepositoryError.saveFailed
            }
        }
    }

    func findAll() async throws -> [Transaction] {
        return try await context.perform {
            let fetchRequest: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

            do {
                let entities = try self.context.fetch(fetchRequest)
                return try entities.compactMap { entity in
                    try? TransactionMapper.toDomain(entity: entity)
                }
            } catch {
                throw RepositoryError.fetchFailed
            }
        }
    }

    func update(transaction: Transaction) async throws -> Transaction {
        return try await context.perform {
            // Find existing entity by ID
            let fetchRequest: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", transaction.id as CVarArg)
            fetchRequest.fetchLimit = 1

            do {
                let entities = try self.context.fetch(fetchRequest)

                guard let entity = entities.first else {
                    throw RepositoryError.notFound
                }

                // Update entity fields
                entity.amount = NSDecimalNumber(decimal: transaction.money.amount)
                entity.currencyCode = transaction.money.currency.rawValue
                entity.name = transaction.name
                entity.categoryRawValue = transaction.category.rawValue
                entity.date = transaction.date
                entity.transactionDescription = transaction.description

                // Save context
                try self.context.save()
                return transaction
            } catch let error as RepositoryError {
                throw error
            } catch {
                throw RepositoryError.saveFailed
            }
        }
    }

    func delete(id: UUID) async throws {
        try await context.perform {
            // Find existing entity by ID
            let fetchRequest: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            fetchRequest.fetchLimit = 1

            do {
                let entities = try self.context.fetch(fetchRequest)

                guard let entity = entities.first else {
                    throw RepositoryError.notFound
                }

                // Delete entity
                self.context.delete(entity)

                // Save context
                try self.context.save()
            } catch let error as RepositoryError {
                throw error
            } catch {
                throw RepositoryError.deleteFailed
            }
        }
    }
}
