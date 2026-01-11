//
//  TransactionEntity+CoreDataProperties.swift
//  BudgetTracker
//
//  Created by Claude Code on 1/11/26.
//

import Foundation
import CoreData

extension TransactionEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TransactionEntity> {
        return NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var amount: NSDecimalNumber?
    @NSManaged public var currencyCode: String?
    @NSManaged public var name: String?
    @NSManaged public var categoryRawValue: String?
    @NSManaged public var date: Date?
    @NSManaged public var transactionDescription: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?

}

extension TransactionEntity : Identifiable {

}
