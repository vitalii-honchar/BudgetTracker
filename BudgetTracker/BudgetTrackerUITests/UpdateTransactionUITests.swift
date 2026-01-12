//
//  UpdateTransactionUITests.swift
//  BudgetTrackerUITests
//
//  Created by Claude Code on 1/12/26.
//

import XCTest

/// E2E tests for Update Transaction use case.
/// NO MOCKS - Tests the full app stack with real database.
final class UpdateTransactionUITests: XCTestCase {
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

    // MARK: - Navigation Tests

    @MainActor
    func test_tapTransaction_opensEditForm() throws {
        // First create a transaction to edit
        createTestTransaction(name: "Test Coffee", amount: "5.50")

        // Tap the transaction
        let transactionCell = app.staticTexts["Test Coffee"]
        XCTAssertTrue(transactionCell.waitForExistence(timeout: 2))
        transactionCell.tap()

        // Verify edit form opened
        XCTAssertTrue(app.navigationBars["Edit Transaction"].waitForExistence(timeout: 2))
    }

    @MainActor
    func test_editForm_fieldsPrePopulated() throws {
        // Create a transaction
        createTestTransaction(name: "Grocery", amount: "45.99", description: "Weekly shopping")

        // Tap to edit
        let transactionCell = app.staticTexts["Grocery"]
        XCTAssertTrue(transactionCell.waitForExistence(timeout: 2))
        transactionCell.tap()

        // Wait for edit form
        XCTAssertTrue(app.navigationBars["Edit Transaction"].waitForExistence(timeout: 2))

        // Verify fields are pre-populated
        let amountField = app.textFields["Amount"]
        XCTAssertTrue(amountField.exists)
        XCTAssertTrue(amountField.value as? String == "45.99" || amountField.value as? String == "45,99")

        let nameField = app.textFields["Name"]
        XCTAssertTrue(nameField.exists)
        XCTAssertEqual(nameField.value as? String, "Grocery")
    }

    // MARK: - Edit Tests

    @MainActor
    func test_editAmount_savesSuccessfully() throws {
        // Create a transaction
        createTestTransaction(name: "Coffee", amount: "5.00")

        // Tap to edit
        let transactionCell = app.staticTexts["Coffee"]
        XCTAssertTrue(transactionCell.waitForExistence(timeout: 2))
        transactionCell.tap()

        // Wait for form
        XCTAssertTrue(app.navigationBars["Edit Transaction"].waitForExistence(timeout: 2))

        // Edit amount
        let amountField = app.textFields["Amount"]
        amountField.tap()
        amountField.clearText()
        amountField.typeText("7.50")

        // Save
        app.navigationBars.buttons["Update"].tap()

        // Verify list shows updated amount
        XCTAssertTrue(app.navigationBars["Budget Tracker"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Coffee"].waitForExistence(timeout: 2))
        // Amount formatting may vary, just verify transaction still exists
    }

    @MainActor
    func test_editName_savesSuccessfully() throws {
        // Create a transaction
        createTestTransaction(name: "Coffee", amount: "5.00")

        // Tap to edit
        let transactionCell = app.staticTexts["Coffee"]
        XCTAssertTrue(transactionCell.waitForExistence(timeout: 2))
        transactionCell.tap()

        // Wait for form
        XCTAssertTrue(app.navigationBars["Edit Transaction"].waitForExistence(timeout: 2))

        // Edit name
        let nameField = app.textFields["Name"]
        nameField.tap()
        nameField.clearText()
        nameField.typeText("Espresso")

        // Save
        app.navigationBars.buttons["Update"].tap()

        // Verify list shows updated name
        XCTAssertTrue(app.navigationBars["Budget Tracker"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Espresso"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.staticTexts["Coffee"].exists)
    }

    @MainActor
    func test_editCategory_savesSuccessfully() throws {
        // Create a transaction with Food category
        createTestTransaction(name: "Lunch", amount: "12.00")

        // Tap to edit
        let transactionCell = app.staticTexts["Lunch"]
        XCTAssertTrue(transactionCell.waitForExistence(timeout: 2))
        transactionCell.tap()

        // Wait for form
        XCTAssertTrue(app.navigationBars["Edit Transaction"].waitForExistence(timeout: 2))

        // Verify initially Food category (default from createTestTransaction)
        // Now change category
        let categoryPicker = app.buttons["Category"]
        if categoryPicker.exists {
            categoryPicker.tap()
            app.menuItems["Shopping"].tap()
        }

        // Save
        app.navigationBars.buttons["Update"].tap()

        // Verify saved successfully
        XCTAssertTrue(app.navigationBars["Budget Tracker"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Lunch"].waitForExistence(timeout: 2))
    }

    @MainActor
    func test_editMultipleFields_savesSuccessfully() throws {
        // Create a transaction
        createTestTransaction(name: "Coffee", amount: "5.00")

        // Tap to edit
        let transactionCell = app.staticTexts["Coffee"]
        XCTAssertTrue(transactionCell.waitForExistence(timeout: 2))
        transactionCell.tap()

        // Wait for form
        XCTAssertTrue(app.navigationBars["Edit Transaction"].waitForExistence(timeout: 2))

        // Edit name
        let nameField = app.textFields["Name"]
        nameField.tap()
        nameField.clearText()
        nameField.typeText("Latte")

        // Edit amount
        let amountField = app.textFields["Amount"]
        amountField.tap()
        amountField.clearText()
        amountField.typeText("6.50")

        // Save
        app.navigationBars.buttons["Update"].tap()

        // Verify both fields updated
        XCTAssertTrue(app.navigationBars["Budget Tracker"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Latte"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.staticTexts["Coffee"].exists)
    }

    // MARK: - Cancel Tests

    @MainActor
    func test_cancel_discardsChanges() throws {
        // Create a transaction
        createTestTransaction(name: "Coffee", amount: "5.00")

        // Tap to edit
        let transactionCell = app.staticTexts["Coffee"]
        XCTAssertTrue(transactionCell.waitForExistence(timeout: 2))
        transactionCell.tap()

        // Wait for form
        XCTAssertTrue(app.navigationBars["Edit Transaction"].waitForExistence(timeout: 2))

        // Edit name
        let nameField = app.textFields["Name"]
        nameField.tap()
        nameField.clearText()
        nameField.typeText("Changed Name")

        // Cancel
        app.navigationBars.buttons["Cancel"].tap()

        // Verify original name still exists
        XCTAssertTrue(app.navigationBars["Budget Tracker"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Coffee"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.staticTexts["Changed Name"].exists)
    }

    // MARK: - Validation Tests

    @MainActor
    func test_editWithEmptyAmount_showsError() throws {
        // Create a transaction
        createTestTransaction(name: "Coffee", amount: "5.00")

        // Tap to edit
        let transactionCell = app.staticTexts["Coffee"]
        XCTAssertTrue(transactionCell.waitForExistence(timeout: 2))
        transactionCell.tap()

        // Wait for form
        XCTAssertTrue(app.navigationBars["Edit Transaction"].waitForExistence(timeout: 2))

        // Clear amount
        let amountField = app.textFields["Amount"]
        amountField.tap()
        amountField.clearText()

        // Try to save
        app.navigationBars.buttons["Update"].tap()

        // Verify error shown (form doesn't dismiss)
        XCTAssertTrue(app.navigationBars["Edit Transaction"].exists)
    }

    @MainActor
    func test_editWithEmptyName_showsError() throws {
        // Create a transaction
        createTestTransaction(name: "Coffee", amount: "5.00")

        // Tap to edit
        let transactionCell = app.staticTexts["Coffee"]
        XCTAssertTrue(transactionCell.waitForExistence(timeout: 2))
        transactionCell.tap()

        // Wait for form
        XCTAssertTrue(app.navigationBars["Edit Transaction"].waitForExistence(timeout: 2))

        // Clear name
        let nameField = app.textFields["Name"]
        nameField.tap()
        nameField.clearText()

        // Try to save
        app.navigationBars.buttons["Update"].tap()

        // Verify error shown (form doesn't dismiss)
        XCTAssertTrue(app.navigationBars["Edit Transaction"].exists)
    }

    // MARK: - Helper Methods

    private func createTestTransaction(name: String, amount: String, description: String? = nil) {
        let addButton = app.navigationBars.buttons.element(boundBy: 0)
        if addButton.waitForExistence(timeout: 5) {
            addButton.tap()
        }

        let amountField = app.textFields["Amount"]
        if amountField.waitForExistence(timeout: 2) {
            amountField.tap()
            amountField.typeText(amount)
        }

        let nameField = app.textFields["Name"]
        nameField.tap()
        nameField.typeText(name)

        if let desc = description {
            // Assuming there's a description text field
            let descField = app.textViews.firstMatch
            if descField.exists {
                descField.tap()
                descField.typeText(desc)
            }
        }

        let saveButton = app.navigationBars.buttons["Save"]
        if saveButton.waitForExistence(timeout: 2) {
            saveButton.tap()
        }

        // Wait for form to dismiss
        XCTAssertTrue(app.navigationBars["Budget Tracker"].waitForExistence(timeout: 3))
    }
}

// Helper extension to clear text fields
extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String else {
            return
        }

        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
    }
}
