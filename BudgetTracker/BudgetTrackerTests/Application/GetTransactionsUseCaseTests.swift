//
//  GetTransactionsUseCaseTests.swift
//  BudgetTrackerTests
//
//  Created by Claude Code on 1/11/26.
//

import XCTest
@testable import BudgetTracker

final class GetTransactionsUseCaseTests: XCTestCase {
    var sut: GetTransactionsUseCase!
    var mockRepository: MockTransactionRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockTransactionRepository()
        sut = GetTransactionsUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Helper

    private func createTransaction(name: String, date: Date) throws -> Transaction {
        let money = try Money(amount: 50, currency: .USD)
        return try Transaction(
            money: money,
            name: name,
            category: .food,
            date: date
        )
    }

    // MARK: - Success Tests

    func test_execute_callsRepositoryFindAll() async throws {
        // Arrange
        mockRepository.findAllResult = .success([])

        // Act
        _ = try await sut.execute()

        // Assert
        XCTAssertTrue(mockRepository.findAllCalled)
    }

    func test_execute_withNoTransactions_returnsEmptyArray() async throws {
        // Arrange
        mockRepository.findAllResult = .success([])

        // Act
        let result = try await sut.execute()

        // Assert
        XCTAssertTrue(result.isEmpty)
    }

    func test_execute_withTransactions_returnsAllTransactions() async throws {
        // Arrange
        let transaction1 = try createTransaction(name: "Coffee", date: Date())
        let transaction2 = try createTransaction(name: "Lunch", date: Date())
        mockRepository.findAllResult = .success([transaction1, transaction2])

        // Act
        let result = try await sut.execute()

        // Assert
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.contains(where: { $0.id == transaction1.id }))
        XCTAssertTrue(result.contains(where: { $0.id == transaction2.id }))
    }

    func test_execute_sortsTransactionsByDateNewestFirst() async throws {
        // Arrange
        let oldDate = Date().addingTimeInterval(-86400 * 7) // 7 days ago
        let recentDate = Date().addingTimeInterval(-86400) // Yesterday
        let newestDate = Date() // Today

        let oldTransaction = try createTransaction(name: "Old", date: oldDate)
        let recentTransaction = try createTransaction(name: "Recent", date: recentDate)
        let newestTransaction = try createTransaction(name: "Newest", date: newestDate)

        // Return in random order
        mockRepository.findAllResult = .success([recentTransaction, oldTransaction, newestTransaction])

        // Act
        let result = try await sut.execute()

        // Assert
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].name, "Newest")
        XCTAssertEqual(result[1].name, "Recent")
        XCTAssertEqual(result[2].name, "Old")
    }

    // MARK: - Error Tests

    func test_execute_whenRepositoryThrowsFetchFailed_propagatesError() async {
        // Arrange
        mockRepository.findAllResult = .failure(RepositoryError.fetchFailed)

        // Act & Assert
        do {
            _ = try await sut.execute()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? RepositoryError, .fetchFailed)
        }
    }

    func test_execute_whenRepositoryThrowsInvalidData_propagatesError() async {
        // Arrange
        mockRepository.findAllResult = .failure(RepositoryError.invalidData)

        // Act & Assert
        do {
            _ = try await sut.execute()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? RepositoryError, .invalidData)
        }
    }
}
