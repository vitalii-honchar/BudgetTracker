//
//  CreateTransactionUseCaseTests.swift
//  BudgetTrackerTests
//
//  Created by Claude Code on 1/11/26.
//

import XCTest
@testable import BudgetTracker

final class CreateTransactionUseCaseTests: XCTestCase {
    var sut: CreateTransactionUseCase!
    var mockRepository: MockTransactionRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockTransactionRepository()
        sut = CreateTransactionUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Helper

    private func createValidTransaction() throws -> Transaction {
        let money = try Money(amount: 50, currency: .USD)
        return try Transaction(
            money: money,
            name: "Grocery Shopping",
            category: .food,
            date: Date()
        )
    }

    // MARK: - Success Tests

    func test_execute_withValidTransaction_callsRepositoryCreate() async throws {
        // Arrange
        let transaction = try createValidTransaction()
        mockRepository.createResult = .success(transaction)

        // Act
        _ = try await sut.execute(transaction: transaction)

        // Assert
        XCTAssertTrue(mockRepository.createCalled)
        XCTAssertEqual(mockRepository.createInput?.id, transaction.id)
    }

    func test_execute_withValidTransaction_returnsCreatedTransaction() async throws {
        // Arrange
        let transaction = try createValidTransaction()
        mockRepository.createResult = .success(transaction)

        // Act
        let result = try await sut.execute(transaction: transaction)

        // Assert
        XCTAssertEqual(result.id, transaction.id)
        XCTAssertEqual(result.name, "Grocery Shopping")
    }

    func test_execute_passesCorrectTransactionToRepository() async throws {
        // Arrange
        let money = try Money(amount: 25.50, currency: .EUR)
        let transaction = try Transaction(
            money: money,
            name: "Coffee",
            category: .food,
            date: Date(),
            description: "Morning coffee"
        )
        mockRepository.createResult = .success(transaction)

        // Act
        _ = try await sut.execute(transaction: transaction)

        // Assert
        XCTAssertEqual(mockRepository.createInput?.money, money)
        XCTAssertEqual(mockRepository.createInput?.name, "Coffee")
        XCTAssertEqual(mockRepository.createInput?.category, .food)
        XCTAssertEqual(mockRepository.createInput?.description, "Morning coffee")
    }

    // MARK: - Error Tests

    func test_execute_whenRepositoryThrowsSaveFailed_propagatesError() async {
        // Arrange
        let transaction = try! createValidTransaction()
        mockRepository.createResult = .failure(RepositoryError.saveFailed)

        // Act & Assert
        do {
            _ = try await sut.execute(transaction: transaction)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? RepositoryError, .saveFailed)
        }
    }

    func test_execute_whenRepositoryThrowsInvalidData_propagatesError() async {
        // Arrange
        let transaction = try! createValidTransaction()
        mockRepository.createResult = .failure(RepositoryError.invalidData)

        // Act & Assert
        do {
            _ = try await sut.execute(transaction: transaction)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? RepositoryError, .invalidData)
        }
    }
}
