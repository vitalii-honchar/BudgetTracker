//
//  TransactionMapper.swift
//  BudgetTracker
//
//  Created by Claude Code on 1/11/26.
//

import Foundation
import CoreData

/// Maps between Transaction domain model and TransactionEntity Core Data model
final class TransactionMapper {

    // MARK: - Domain to Entity

    static func toEntity(
        transaction: Transaction,
        context: NSManagedObjectContext
    ) -> TransactionEntity {
        let entity = TransactionEntity(context: context)

        entity.id = transaction.id
        entity.amount = NSDecimalNumber(decimal: transaction.money.amount)
        entity.currencyCode = transaction.money.currency.rawValue
        entity.name = transaction.name
        entity.categoryRawValue = transaction.category.rawValue
        entity.date = transaction.date
        entity.transactionDescription = transaction.description
        entity.createdAt = transaction.createdAt
        entity.updatedAt = transaction.updatedAt

        return entity
    }

    // MARK: - Entity to Domain

    static func toDomain(entity: TransactionEntity) throws -> Transaction {
        guard let id = entity.id,
              let amountNumber = entity.amount,
              let currencyCode = entity.currencyCode,
              let name = entity.name,
              let categoryRawValue = entity.categoryRawValue,
              let date = entity.date,
              let createdAt = entity.createdAt,
              let updatedAt = entity.updatedAt
        else {
            throw MapperError.missingRequiredFields
        }

        guard let currency = Currency(rawValue: currencyCode) else {
            throw MapperError.invalidCurrency(currencyCode)
        }

        guard let category = Category(rawValue: categoryRawValue) else {
            throw MapperError.invalidCategory(categoryRawValue)
        }

        let amount = amountNumber as Decimal
        let money = try Money(amount: amount, currency: currency)

        return try Transaction(
            id: id,
            money: money,
            name: name,
            category: category,
            date: date,
            description: entity.transactionDescription,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - Errors

enum MapperError: Error, Equatable {
    case missingRequiredFields
    case invalidCurrency(String)
    case invalidCategory(String)
}
