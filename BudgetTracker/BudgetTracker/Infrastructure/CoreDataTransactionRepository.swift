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
}
