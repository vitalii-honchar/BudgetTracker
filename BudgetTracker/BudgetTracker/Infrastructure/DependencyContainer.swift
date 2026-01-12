//
//  DependencyContainer.swift
//  BudgetTracker
//
//  Created by Claude Code on 1/11/26.
//

import Foundation

/// Dependency Injection container
final class DependencyContainer {
    static let shared = DependencyContainer()

    // MARK: - Infrastructure

    private lazy var coreDataStack = CoreDataStack.shared

    // MARK: - Repositories

    lazy var transactionRepository: TransactionRepository = {
        return CoreDataTransactionRepository(context: coreDataStack.viewContext)
    }()

    // MARK: - Use Cases

    lazy var createTransactionUseCase: CreateTransactionUseCase = {
        return CreateTransactionUseCase(repository: transactionRepository)
    }()

    lazy var getTransactionsUseCase: GetTransactionsUseCase = {
        return GetTransactionsUseCase(repository: transactionRepository)
    }()

    lazy var updateTransactionUseCase: UpdateTransactionUseCase = {
        return UpdateTransactionUseCase(repository: transactionRepository)
    }()

    lazy var deleteTransactionUseCase: DeleteTransactionUseCase = {
        return DeleteTransactionUseCase(repository: transactionRepository)
    }()

    private init() {}
}
