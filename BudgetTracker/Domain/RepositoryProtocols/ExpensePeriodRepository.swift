//
//  ExpensePeriodRepository.swift
//  BudgetTracker
//
//  Domain Layer - Repository Protocol (Contract)
//  Pure Swift, zero dependencies
//  Implementation will be in Data layer
//

import Foundation

/// ExpensePeriodRepository defines the contract for expense period persistence
/// Protocol: Abstracts data access, implemented by Data layer
protocol ExpensePeriodRepository {

    // MARK: - Create

    /// Create a new expense period
    /// - Parameter period: The expense period to create
    /// - Returns: The created expense period
    /// - Throws: RepositoryError if creation fails
    func create(period: ExpensePeriod) async throws -> ExpensePeriod

    // MARK: - Read

    /// Find an expense period by its ID
    /// - Parameter id: The period ID
    /// - Returns: The period if found, nil otherwise
    /// - Throws: RepositoryError if query fails
    func findById(id: UUID) async throws -> ExpensePeriod?

    /// Get all expense periods
    /// - Returns: Array of all periods, sorted by start date (newest first)
    /// - Throws: RepositoryError if query fails
    func findAll() async throws -> [ExpensePeriod]

    /// Find the active (ongoing) period
    /// - Returns: The active period if one exists, nil otherwise
    /// - Throws: RepositoryError if query fails
    func findActive() async throws -> ExpensePeriod?

    /// Find periods that contain a specific date
    /// - Parameter date: The date to check
    /// - Returns: Array of periods containing this date
    /// - Throws: RepositoryError if query fails
    func findContaining(date: Date) async throws -> [ExpensePeriod]

    /// Find periods within a date range
    /// - Parameter dateRange: The date range to filter by
    /// - Returns: Array of periods that overlap with this range
    /// - Throws: RepositoryError if query fails
    func findInDateRange(dateRange: DateRange) async throws -> [ExpensePeriod]

    /// Find closed (ended) periods
    /// - Returns: Array of periods with end dates in the past
    /// - Throws: RepositoryError if query fails
    func findClosed() async throws -> [ExpensePeriod]

    /// Find period by name (case-insensitive)
    /// - Parameter name: The period name
    /// - Returns: The period if found, nil otherwise
    /// - Throws: RepositoryError if query fails
    func findByName(name: String) async throws -> ExpensePeriod?

    /// Check if a period name already exists
    /// - Parameter name: The period name to check
    /// - Returns: True if name exists, false otherwise
    /// - Throws: RepositoryError if query fails
    func exists(name: String) async throws -> Bool

    /// Count total periods
    /// - Returns: Total number of periods
    /// - Throws: RepositoryError if query fails
    func count() async throws -> Int

    // MARK: - Update

    /// Update an existing expense period
    /// - Parameter period: The period with updated fields
    /// - Returns: The updated period
    /// - Throws: RepositoryError if update fails or period not found
    func update(period: ExpensePeriod) async throws -> ExpensePeriod

    // MARK: - Delete

    /// Delete an expense period by ID
    /// - Parameter id: The period ID
    /// - Throws: RepositoryError if deletion fails or period not found
    /// - Note: Transactions in this period should have their periodId set to nil
    func delete(id: UUID) async throws

    /// Delete all expense periods
    /// - Throws: RepositoryError if deletion fails
    func deleteAll() async throws

    // MARK: - Statistics

    /// Count transactions in a period
    /// - Parameter periodId: The period ID
    /// - Returns: Number of transactions in this period
    /// - Throws: RepositoryError if query fails
    func transactionCount(for periodId: UUID) async throws -> Int

    /// Calculate total spending for a period
    /// - Parameter periodId: The period ID
    /// - Returns: Total money spent in period, nil if no transactions
    /// - Throws: RepositoryError if calculation fails
    func totalSpent(for periodId: UUID) async throws -> Money?

    // MARK: - Validation

    /// Check if a new period overlaps with existing periods
    /// - Parameter period: The period to check
    /// - Returns: Array of periods that overlap with this period
    /// - Throws: RepositoryError if query fails
    func findOverlapping(with period: ExpensePeriod) async throws -> [ExpensePeriod]
}
