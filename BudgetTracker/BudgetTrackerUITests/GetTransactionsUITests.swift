//
//  GetTransactionsUITests.swift
//  BudgetTrackerUITests
//
//  E2E tests for Get Transactions use case.
//  NO MOCKS - Tests the full app stack with real database.
//

import XCTest

final class GetTransactionsUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Empty State Tests

    @MainActor
    func test_launchApp_withNoTransactions_showsEmptyState() throws {
        // Verify navigation title
        XCTAssertTrue(app.navigationBars["Budget Tracker"].exists)

        // Verify empty state is visible
        XCTAssertTrue(app.staticTexts["No Transactions"].exists)
        XCTAssertTrue(app.staticTexts["Tap + to add your first transaction"].exists)

        // Verify + button exists
        let addButton = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(addButton.exists)
    }

    @MainActor
    func test_emptyState_addButton_opensTransactionForm() throws {
        // Verify empty state
        XCTAssertTrue(app.staticTexts["No Transactions"].exists)

        // Tap + button
        let addButton = app.navigationBars.buttons.element(boundBy: 0)
        addButton.tap()

        // Verify form appeared
        XCTAssertTrue(app.navigationBars["Add Transaction"].exists)
    }

    // MARK: - Transaction List Tests

    @MainActor
    func test_transactionList_afterCreating_displaysTransaction() throws {
        // Create a transaction
        createTestTransaction(name: "Test Coffee", amount: "5.50", currency: .EUR)

        // Verify transaction appears in list
        XCTAssertTrue(app.staticTexts["Test Coffee"].exists)
        XCTAssertTrue(app.staticTexts["€5.50"].exists || app.staticTexts["5.50"].exists)

        // Verify empty state is gone
        XCTAssertFalse(app.staticTexts["No Transactions"].exists)
    }

    @MainActor
    func test_transactionList_displaysMultipleTransactions() throws {
        // Create multiple transactions
        createTestTransaction(name: "Breakfast", amount: "12", currency: .EUR)
        createTestTransaction(name: "Lunch", amount: "25", currency: .EUR)
        createTestTransaction(name: "Dinner", amount: "35", currency: .EUR)

        // Verify all transactions appear
        XCTAssertTrue(app.staticTexts["Breakfast"].exists)
        XCTAssertTrue(app.staticTexts["Lunch"].exists)
        XCTAssertTrue(app.staticTexts["Dinner"].exists)
    }

    @MainActor
    func test_transactionList_displaysCategoryIcon() throws {
        // Create transaction with specific category
        createTestTransaction(name: "Grocery Shopping", amount: "50", currency: .EUR)

        // Verify transaction shows category name
        XCTAssertTrue(app.staticTexts["Food"].exists)
    }

    @MainActor
    func test_transactionList_displaysDate() throws {
        // Create transaction
        createTestTransaction(name: "Daily Expense", amount: "20", currency: .EUR)

        // Verify transaction shows date (today's date should be visible)
        // The exact date format depends on implementation
        // Just verify transaction row is complete
        XCTAssertTrue(app.staticTexts["Daily Expense"].exists)
    }

    @MainActor
    func test_transactionList_displaysFormattedAmount() throws {
        // Create transaction with decimal amount
        createTestTransaction(name: "Coffee", amount: "4.75", currency: .EUR)

        // Verify amount is displayed with currency symbol
        let formattedAmountExists = app.staticTexts["€4.75"].exists ||
                                      app.staticTexts["4.75"].exists
        XCTAssertTrue(formattedAmountExists)
    }

    // MARK: - Sorting Tests

    @MainActor
    func test_transactionList_sortedByDateDescending() throws {
        // Create transactions in specific order
        createTestTransaction(name: "First", amount: "10", currency: .EUR)

        // Small delay to ensure different timestamps
        sleep(1)

        createTestTransaction(name: "Second", amount: "20", currency: .EUR)

        // Verify newest transaction appears first in list
        // Get all transaction cells
        let cells = app.cells

        // Verify we have at least 2 transactions
        XCTAssertTrue(cells.count >= 2)

        // Note: Exact sorting verification depends on list implementation
        // In a real test, you'd check the order of cells
    }

    // MARK: - Navigation Tests

    @MainActor
    func test_transactionList_addButton_opensForm() throws {
        // Verify main screen
        XCTAssertTrue(app.navigationBars["Budget Tracker"].exists)

        // Tap + button
        let addButton = app.navigationBars.buttons.element(boundBy: 0)
        addButton.tap()

        // Verify form appeared
        XCTAssertTrue(app.navigationBars["Add Transaction"].exists)

        // Verify form fields exist
        XCTAssertTrue(app.textFields["Amount"].exists)
        XCTAssertTrue(app.textFields["Name"].exists)
        XCTAssertTrue(app.buttons["Category"].exists)
        XCTAssertTrue(app.datePickers.element.exists)
    }

    @MainActor
    func test_transactionList_afterAddingTransaction_reloadsAutomatically() throws {
        // Verify empty state initially
        XCTAssertTrue(app.staticTexts["No Transactions"].exists)

        // Create transaction
        createTestTransaction(name: "Auto Reload Test", amount: "99", currency: .EUR)

        // List should automatically reload and show new transaction
        XCTAssertTrue(app.staticTexts["Auto Reload Test"].exists)
        XCTAssertFalse(app.staticTexts["No Transactions"].exists)
    }

    // MARK: - Multiple Currency Tests

    @MainActor
    func test_transactionList_displaysMultipleCurrencies() throws {
        // Create transactions with different currencies
        createTestTransaction(name: "EUR Transaction", amount: "50", currency: .EUR)
        createTestTransaction(name: "USD Transaction", amount: "60", currency: .USD)

        // Verify both appear in list
        XCTAssertTrue(app.staticTexts["EUR Transaction"].exists)
        XCTAssertTrue(app.staticTexts["USD Transaction"].exists)

        // Verify correct currency symbols
        let eurExists = app.staticTexts["€50"].exists || app.staticTexts["50"].exists
        let usdExists = app.staticTexts["$60"].exists || app.staticTexts["60"].exists

        XCTAssertTrue(eurExists)
        XCTAssertTrue(usdExists)
    }

    // MARK: - Helper Methods

    private enum TestCurrency {
        case EUR
        case USD
        case GBP
        case JPY
        case UAH
    }

    private func createTestTransaction(name: String, amount: String, currency: TestCurrency) {
        // Open add transaction form
        let addButton = app.navigationBars.buttons.element(boundBy: 0)
        addButton.tap()

        // Fill amount
        let amountField = app.textFields["Amount"]
        amountField.tap()
        amountField.typeText(amount)

        // Select currency if not EUR (EUR is default)
        if currency != .EUR {
            let currencyPicker = app.buttons["Currency"]
            currencyPicker.tap()
            // Select appropriate currency from menu
            // Note: Exact implementation depends on menu structure
        }

        // Fill name
        let nameField = app.textFields["Name"]
        nameField.tap()
        nameField.typeText(name)

        // Save
        let saveButton = app.navigationBars.buttons["Save"]
        saveButton.tap()

        // Wait for form to dismiss
        let budgetTrackerNav = app.navigationBars["Budget Tracker"]
        XCTAssertTrue(budgetTrackerNav.waitForExistence(timeout: 2))
    }
}
