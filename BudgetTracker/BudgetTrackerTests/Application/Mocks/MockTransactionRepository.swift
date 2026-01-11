//
//  MockTransactionRepository.swift
//  BudgetTrackerTests
//
//  Created by Claude Code on 1/11/26.
//

import Foundation
@testable import BudgetTracker

final class MockTransactionRepository: TransactionRepository {
    var createCalled = false
    var createInput: Transaction?
    var createResult: Result<Transaction, Error>?

    var findAllCalled = false
    var findAllResult: Result<[Transaction], Error>?

    var updateCalled = false
    var updateInput: Transaction?
    var updateResult: Result<Transaction, Error>?

    var deleteCalled = false
    var deleteInput: UUID?
    var deleteResult: Result<Void, Error>?

    func create(transaction: Transaction) async throws -> Transaction {
        createCalled = true
        createInput = transaction

        switch createResult {
        case .success(let transaction):
            return transaction
        case .failure(let error):
            throw error
        case .none:
            return transaction
        }
    }

    func findAll() async throws -> [Transaction] {
        findAllCalled = true

        switch findAllResult {
        case .success(let transactions):
            return transactions
        case .failure(let error):
            throw error
        case .none:
            return []
        }
    }

    func update(transaction: Transaction) async throws -> Transaction {
        updateCalled = true
        updateInput = transaction

        switch updateResult {
        case .success(let transaction):
            return transaction
        case .failure(let error):
            throw error
        case .none:
            return transaction
        }
    }

    func delete(id: UUID) async throws {
        deleteCalled = true
        deleteInput = id

        switch deleteResult {
        case .success:
            return
        case .failure(let error):
            throw error
        case .none:
            return
        }
    }
}
