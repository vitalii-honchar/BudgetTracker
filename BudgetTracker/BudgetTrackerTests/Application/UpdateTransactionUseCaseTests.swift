//
//  UpdateTransactionUseCaseTests.swift
//  BudgetTrackerTests
//
//  Created by Claude Code on 1/11/26.
//

import XCTest
@testable import BudgetTracker

final class UpdateTransactionUseCaseTests: XCTestCase {
    var sut: UpdateTransactionUseCase!
    var mockRepository: MockTransactionRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockTransactionRepository()
        sut = UpdateTransactionUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Happy Path Tests

    @MainActor
    func test_execute_withValidTransaction_callsRepositoryUpdate() async throws {
        // Given
        let money = try Money(amount: 50, currency: .EUR)
        let transaction = try Transaction(
            id: UUID(),
            money: money,
            name: "Coffee",
            category: .food,
            date: Date(),
            description: "Morning coffee"
        )
        mockRepository.updateResult = .success(transaction)

        // When
        let result = try await sut.execute(transaction: transaction)

        // Then
        XCTAssertTrue(mockRepository.updateCalled)
        XCTAssertEqual(mockRepository.updateInput?.id, transaction.id)
        XCTAssertEqual(result.id, transaction.id)
    }

    @MainActor
    func test_execute_withValidTransaction_returnsUpdatedTransaction() async throws {
        // Given
        let originalMoney = try Money(amount: 50, currency: .EUR)
        let originalTransaction = try Transaction(
            id: UUID(),
            money: originalMoney,
            name: "Coffee",
            category: .food,
            date: Date(),
            description: "Morning coffee"
        )

        let updatedMoney = try Money(amount: 60, currency: .EUR)
        let updatedTransaction = try Transaction(
            id: originalTransaction.id,
            money: updatedMoney,
            name: "Updated Coffee",
            category: .food,
            date: Date(),
            description: "Updated description"
        )

        mockRepository.updateResult = .success(updatedTransaction)

        // When
        let result = try await sut.execute(transaction: updatedTransaction)

        // Then
        XCTAssertEqual(result.id, updatedTransaction.id)
        XCTAssertEqual(result.money.amount, 60)
        XCTAssertEqual(result.name, "Updated Coffee")
        XCTAssertEqual(result.description, "Updated description")
    }

    @MainActor
    func test_execute_withDifferentAmount_updatesSuccessfully() async throws {
        // Given
        let money = try Money(amount: 100, currency: .USD)
        let transaction = try Transaction(
            id: UUID(),
            money: money,
            name: "Grocery",
            category: .shopping,
            date: Date(),
            description: nil
        )
        mockRepository.updateResult = .success(transaction)

        // When
        let result = try await sut.execute(transaction: transaction)

        // Then
        XCTAssertTrue(mockRepository.updateCalled)
        XCTAssertEqual(result.money.amount, 100)
        XCTAssertEqual(result.money.currency, .USD)
    }

    // MARK: - Error Handling Tests

    @MainActor
    func test_execute_whenTransactionNotFound_throwsNotFoundError() async throws {
        // Given
        let money = try Money(amount: 50, currency: .EUR)
        let transaction = try Transaction(
            id: UUID(),
            money: money,
            name: "Coffee",
            category: .food,
            date: Date(),
            description: nil
        )
        mockRepository.updateResult = .failure(RepositoryError.notFound)

        // When/Then
        do {
            _ = try await sut.execute(transaction: transaction)
            XCTFail("Expected notFound error")
        } catch let error as RepositoryError {
            XCTAssertEqual(error, .notFound)
            XCTAssertTrue(mockRepository.updateCalled)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    @MainActor
    func test_execute_whenUpdateFails_throwsSaveFailedError() async throws {
        // Given
        let money = try Money(amount: 50, currency: .EUR)
        let transaction = try Transaction(
            id: UUID(),
            money: money,
            name: "Coffee",
            category: .food,
            date: Date(),
            description: nil
        )
        mockRepository.updateResult = .failure(RepositoryError.saveFailed)

        // When/Then
        do {
            _ = try await sut.execute(transaction: transaction)
            XCTFail("Expected saveFailed error")
        } catch let error as RepositoryError {
            XCTAssertEqual(error, .saveFailed)
            XCTAssertTrue(mockRepository.updateCalled)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    @MainActor
    func test_execute_whenRepositoryThrowsGenericError_propagatesError() async throws {
        // Given
        let money = try Money(amount: 50, currency: .EUR)
        let transaction = try Transaction(
            id: UUID(),
            money: money,
            name: "Coffee",
            category: .food,
            date: Date(),
            description: nil
        )

        struct GenericError: Error {}
        mockRepository.updateResult = .failure(GenericError())

        // When/Then
        do {
            _ = try await sut.execute(transaction: transaction)
            XCTFail("Expected error to be thrown")
        } catch is GenericError {
            XCTAssertTrue(mockRepository.updateCalled)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
