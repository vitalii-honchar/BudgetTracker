//
//  DeleteTransactionUseCaseTests.swift
//  BudgetTrackerTests
//
//  Created by Claude Code on 1/11/26.
//

import XCTest
@testable import BudgetTracker

final class DeleteTransactionUseCaseTests: XCTestCase {
    var sut: DeleteTransactionUseCase!
    var mockRepository: MockTransactionRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockTransactionRepository()
        sut = DeleteTransactionUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Happy Path Tests

    @MainActor
    func test_execute_withValidID_callsRepositoryDelete() async throws {
        // Given
        let transactionID = UUID()
        mockRepository.deleteResult = .success(())

        // When
        try await sut.execute(id: transactionID)

        // Then
        XCTAssertTrue(mockRepository.deleteCalled)
        XCTAssertEqual(mockRepository.deleteInput, transactionID)
    }

    @MainActor
    func test_execute_withValidID_completesSuccessfully() async throws {
        // Given
        let transactionID = UUID()
        mockRepository.deleteResult = .success(())

        // When/Then - should not throw
        try await sut.execute(id: transactionID)
        XCTAssertTrue(mockRepository.deleteCalled)
    }

    @MainActor
    func test_execute_callsRepositoryWithCorrectID() async throws {
        // Given
        let expectedID = UUID()
        mockRepository.deleteResult = .success(())

        // When
        try await sut.execute(id: expectedID)

        // Then
        XCTAssertEqual(mockRepository.deleteInput, expectedID)
    }

    // MARK: - Error Handling Tests

    @MainActor
    func test_execute_whenTransactionNotFound_throwsNotFoundError() async throws {
        // Given
        let transactionID = UUID()
        mockRepository.deleteResult = .failure(RepositoryError.notFound)

        // When/Then
        do {
            try await sut.execute(id: transactionID)
            XCTFail("Expected notFound error")
        } catch let error as RepositoryError {
            XCTAssertEqual(error, .notFound)
            XCTAssertTrue(mockRepository.deleteCalled)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    @MainActor
    func test_execute_whenDeleteFails_throwsDeleteFailedError() async throws {
        // Given
        let transactionID = UUID()
        mockRepository.deleteResult = .failure(RepositoryError.deleteFailed)

        // When/Then
        do {
            try await sut.execute(id: transactionID)
            XCTFail("Expected deleteFailed error")
        } catch let error as RepositoryError {
            XCTAssertEqual(error, .deleteFailed)
            XCTAssertTrue(mockRepository.deleteCalled)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    @MainActor
    func test_execute_whenRepositoryThrowsGenericError_propagatesError() async throws {
        // Given
        let transactionID = UUID()
        struct GenericError: Error {}
        mockRepository.deleteResult = .failure(GenericError())

        // When/Then
        do {
            try await sut.execute(id: transactionID)
            XCTFail("Expected error to be thrown")
        } catch is GenericError {
            XCTAssertTrue(mockRepository.deleteCalled)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
