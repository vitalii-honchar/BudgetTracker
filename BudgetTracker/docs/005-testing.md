# Budget Tracker iOS - Testing Strategy

## 1. Testing Philosophy

**Principles**:
- **Test Pyramid**: Many unit tests, fewer integration tests, minimal E2E tests
- **Fast Feedback**: Unit tests run in milliseconds, full suite under 10 seconds
- **Confidence**: Each layer thoroughly tested at appropriate level
- **Maintainability**: Clear naming conventions, no test duplication
- **Isolation**: Unit tests have zero dependencies on frameworks or infrastructure

**Quality Gates**:
- Unit test coverage: >80% for Domain and Application layers
- Integration test coverage: >70% for Data layer
- E2E test coverage: Critical user flows only
- All tests must pass before merge

---

## 2. Testing Pyramid

```
                    ┌─────────────────┐
                    │   E2E Tests     │ ← 5-10 tests
                    │   (UI Tests)    │   Slow (seconds)
                    │                 │   Full system
                    └─────────────────┘
                   /                   \
                  /                     \
           ┌─────────────────────────────┐
           │   Integration Tests         │ ← 30-50 tests
           │   (Data Layer + Infra)      │   Medium (100ms)
           │                             │   Real Core Data
           └─────────────────────────────┘
          /                               \
         /                                 \
┌───────────────────────────────────────────┐
│         Unit Tests                        │ ← 200+ tests
│   (Domain + Application + ViewModels)     │   Fast (<10ms)
│                                           │   Pure logic
└───────────────────────────────────────────┘

Distribution:
• Unit Tests:        80-85% of all tests
• Integration Tests: 10-15% of all tests
• E2E Tests:         5% of all tests
```

**Rationale**:
- **Unit tests**: Fast, isolated, test business logic thoroughly
- **Integration tests**: Verify layer boundaries and database operations
- **E2E tests**: Validate critical paths work end-to-end in real app

---

## 3. Test Naming Convention

### 3.1 Standard Format

```
test_[methodName]_[scenario]_[expectedBehavior]
```

**Components**:
- `test_`: Required XCTest prefix
- `[methodName]`: Method/function being tested (camelCase)
- `[scenario]`: Input conditions or state (camelCase)
- `[expectedBehavior]`: Expected outcome (camelCase)

**Examples**:

```swift
// Good: Clear, descriptive, follows convention
test_createTransaction_withValidData_returnsTransaction()
test_createTransaction_withNegativeAmount_throwsValidationError()
test_createTransaction_withEmptyName_throwsValidationError()

// Bad: Unclear, missing context
test_transaction()
test_create()
test_error()
```

### 3.2 Layer-Specific Patterns

**Domain Layer (Pure Logic)**:
```swift
// Entities
test_transactionInit_withValidMoney_createsTransaction()
test_transactionInit_withFutureDate_throwsInvalidDateError()

// Value Objects
test_moneyAdd_withSameCurrency_returnsSum()
test_moneyAdd_withDifferentCurrency_throwsCurrencyMismatchError()
```

**Application Layer (Use Cases)**:
```swift
// Use Cases
test_createTransactionUseCase_withValidInput_savesAndReturnsTransaction()
test_createTransactionUseCase_withDuplicateId_throwsDuplicateError()
test_getTransactionsByPeriodUseCase_withValidPeriodId_returnsFilteredTransactions()
```

**Data Layer (Integration)**:
```swift
// Repositories
test_coreDataTransactionRepository_create_persistsToDatabase()
test_coreDataTransactionRepository_findById_withNonexistentId_returnsNil()

// Mappers
test_transactionMapper_toDomain_mapsAllFieldsCorrectly()
test_transactionMapper_toEntity_handlesOptionalDescriptionCorrectly()
```

**Presentation Layer (ViewModels)**:
```swift
// ViewModels
test_transactionListViewModel_loadTransactions_updatesStateWithData()
test_transactionFormViewModel_submitForm_withInvalidAmount_setsErrorState()
```

**E2E Tests (UI)**:
```swift
// User flows
test_userCanCreateTransaction_endToEnd()
test_userCanEditTransaction_endToEnd()
test_userCanDeleteTransaction_endToEnd()
```

---

## 4. Technology Stack

### 4.1 Core Technologies

**Testing Frameworks**:
```
┌────────────────────────────────────────────────────┐
│  XCTest (Apple's Native Framework)                 │
│  • Unit tests                                      │
│  • Integration tests                               │
│  • UI tests (XCUITest)                             │
│  • Asynchronous testing (XCTestExpectation)        │
└────────────────────────────────────────────────────┘

Why XCTest?
✅ Native Apple framework (zero dependencies)
✅ Excellent Xcode integration
✅ Fast execution
✅ Built-in async/await support (Swift 5.5+)
✅ Code coverage reporting
```

**Additional Tools**:
```
┌────────────────────────────────────────────────────┐
│  Swift Testing Utilities                           │
│  • XCTestExpectation: Async operation testing      │
│  • XCTWaiter: Timeout and wait handling            │
│  • NSPredicate: Expectation predicates             │
└────────────────────────────────────────────────────┘
```

### 4.2 Mock Strategy

**Protocol-Based Mocking** (No framework needed):

```swift
// Domain protocol
protocol TransactionRepository {
    func create(transaction: Transaction) async throws -> Transaction
    func findById(id: UUID) async throws -> Transaction?
}

// Mock implementation for testing
class MockTransactionRepository: TransactionRepository {
    var createCalled = false
    var createInput: Transaction?
    var createResult: Result<Transaction, Error>?

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

    func findById(id: UUID) async throws -> Transaction? {
        // Mock implementation
        return nil
    }
}
```

**Why Protocol-Based?**
- ✅ No external dependencies
- ✅ Type-safe
- ✅ Compile-time checking
- ✅ Full control over behavior

---

## 5. Testing by Architecture Layer

### 5.1 Domain Layer (Unit Tests Only)

**What to Test**:
- Entity initialization and validation
- Value object operations (Money.add, DateRange.contains)
- Business rule enforcement
- Edge cases and error conditions

**Characteristics**:
- **Speed**: <10ms per test
- **Dependencies**: ZERO (pure Swift)
- **Mocking**: Not needed (no dependencies)
- **Coverage Target**: >90%

**Example Structure**:

```
BudgetTrackerTests/
└── Domain/
    ├── Entities/
    │   ├── TransactionTests.swift
    │   ├── ExpensePeriodTests.swift
    │   └── CategoryTests.swift
    ├── ValueObjects/
    │   ├── MoneyTests.swift
    │   ├── CurrencyTests.swift
    │   └── DateRangeTests.swift
    └── DomainServices/
        └── ReportGeneratorTests.swift
```

**Example Test**:

```swift
import XCTest
@testable import BudgetTracker

final class MoneyTests: XCTestCase {

    // MARK: - Addition Tests

    func test_add_withSameCurrency_returnsCorrectSum() {
        // Arrange
        let money1 = Money(amount: 10.50, currency: .USD)
        let money2 = Money(amount: 5.25, currency: .USD)

        // Act
        let result = try? money1.add(money2)

        // Assert
        XCTAssertEqual(result?.amount, 15.75)
        XCTAssertEqual(result?.currency, .USD)
    }

    func test_add_withDifferentCurrency_throwsCurrencyMismatchError() {
        // Arrange
        let money1 = Money(amount: 10.50, currency: .USD)
        let money2 = Money(amount: 5.25, currency: .EUR)

        // Act & Assert
        XCTAssertThrowsError(try money1.add(money2)) { error in
            XCTAssertEqual(error as? MoneyError, .currencyMismatch)
        }
    }

    func test_add_withZeroAmount_returnsOriginalMoney() {
        // Arrange
        let money = Money(amount: 10.50, currency: .USD)
        let zero = Money(amount: 0, currency: .USD)

        // Act
        let result = try? money.add(zero)

        // Assert
        XCTAssertEqual(result?.amount, 10.50)
    }
}
```

---

### 5.2 Application Layer (Unit Tests)

**What to Test**:
- Use case orchestration logic
- Input validation
- Error handling
- Repository interaction (with mocks)
- Business workflow correctness

**Characteristics**:
- **Speed**: <50ms per test (includes mock setup)
- **Dependencies**: Domain only
- **Mocking**: Repository protocols
- **Coverage Target**: >85%

**Example Structure**:

```
BudgetTrackerTests/
└── Application/
    └── UseCases/
        ├── Transaction/
        │   ├── CreateTransactionUseCaseTests.swift
        │   ├── UpdateTransactionUseCaseTests.swift
        │   └── DeleteTransactionUseCaseTests.swift
        ├── ExpensePeriod/
        │   └── GenerateReportUseCaseTests.swift
        └── Mocks/
            ├── MockTransactionRepository.swift
            └── MockExpensePeriodRepository.swift
```

**Example Test**:

```swift
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

    // MARK: - Success Cases

    func test_execute_withValidTransaction_callsRepositoryCreate() async throws {
        // Arrange
        let transaction = try Transaction(
            money: Money(amount: 50.00, currency: .USD),
            name: "Grocery Shopping",
            category: Category(id: UUID(), name: "Food", icon: "cart.fill"),
            date: Date()
        )
        mockRepository.createResult = .success(transaction)

        // Act
        _ = try await sut.execute(transaction: transaction)

        // Assert
        XCTAssertTrue(mockRepository.createCalled)
        XCTAssertEqual(mockRepository.createInput?.name, "Grocery Shopping")
    }

    func test_execute_withValidTransaction_returnsCreatedTransaction() async throws {
        // Arrange
        let transaction = try Transaction(
            money: Money(amount: 50.00, currency: .USD),
            name: "Grocery Shopping",
            category: Category(id: UUID(), name: "Food", icon: "cart.fill"),
            date: Date()
        )
        mockRepository.createResult = .success(transaction)

        // Act
        let result = try await sut.execute(transaction: transaction)

        // Assert
        XCTAssertEqual(result.id, transaction.id)
        XCTAssertEqual(result.name, "Grocery Shopping")
    }

    // MARK: - Error Cases

    func test_execute_whenRepositoryFails_propagatesError() async {
        // Arrange
        let transaction = try! Transaction(
            money: Money(amount: 50.00, currency: .USD),
            name: "Test",
            category: Category(id: UUID(), name: "Food", icon: "cart.fill"),
            date: Date()
        )
        mockRepository.createResult = .failure(RepositoryError.saveFailed)

        // Act & Assert
        do {
            _ = try await sut.execute(transaction: transaction)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? RepositoryError, .saveFailed)
        }
    }
}
```

---

### 5.3 Data Layer (Integration Tests)

**What to Test**:
- Repository implementations with real Core Data
- Mapper conversions (Domain ↔ Entity)
- Database queries and filtering
- Relationship handling
- Migration correctness

**Characteristics**:
- **Speed**: 50-200ms per test (includes DB setup/teardown)
- **Dependencies**: Core Data (in-memory)
- **Mocking**: None (uses real Core Data stack)
- **Coverage Target**: >75%

**Example Structure**:

```
BudgetTrackerTests/
└── Data/
    ├── Repositories/
    │   ├── CoreDataTransactionRepositoryTests.swift
    │   ├── CoreDataExpensePeriodRepositoryTests.swift
    │   └── CoreDataCategoryRepositoryTests.swift
    ├── Mappers/
    │   ├── TransactionMapperTests.swift
    │   └── ExpensePeriodMapperTests.swift
    └── TestHelpers/
        └── InMemoryCoreDataStack.swift
```

**In-Memory Core Data Setup**:

```swift
import CoreData

class InMemoryCoreDataStack {
    static func create() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "BudgetTracker")

        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false

        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { (description, error) in
            precondition(description.type == NSInMemoryStoreType)
            if let error = error {
                fatalError("Failed to create in-memory store: \(error)")
            }
        }

        return container
    }
}
```

**Example Test**:

```swift
import XCTest
import CoreData
@testable import BudgetTracker

final class CoreDataTransactionRepositoryTests: XCTestCase {

    var sut: CoreDataTransactionRepository!
    var context: NSManagedObjectContext!
    var container: NSPersistentContainer!

    override func setUp() {
        super.setUp()
        container = InMemoryCoreDataStack.create()
        context = container.viewContext
        sut = CoreDataTransactionRepository(context: context)
    }

    override func tearDown() {
        sut = nil
        context = nil
        container = nil
        super.tearDown()
    }

    // MARK: - Create Tests

    func test_create_withValidTransaction_persistsToDatabase() async throws {
        // Arrange
        let transaction = try Transaction(
            money: Money(amount: 42.50, currency: .USD),
            name: "Coffee",
            category: createTestCategory(),
            date: Date()
        )

        // Act
        let created = try await sut.create(transaction: transaction)

        // Assert
        let fetchRequest: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        let results = try context.fetch(fetchRequest)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Coffee")
        XCTAssertEqual(results.first?.amount as Decimal?, 42.50)
        XCTAssertEqual(created.id, transaction.id)
    }

    // MARK: - Find Tests

    func test_findById_withExistingId_returnsTransaction() async throws {
        // Arrange
        let transaction = try Transaction(
            money: Money(amount: 25.00, currency: .USD),
            name: "Lunch",
            category: createTestCategory(),
            date: Date()
        )
        let created = try await sut.create(transaction: transaction)

        // Act
        let found = try await sut.findById(id: created.id)

        // Assert
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.id, created.id)
        XCTAssertEqual(found?.name, "Lunch")
    }

    func test_findById_withNonexistentId_returnsNil() async throws {
        // Arrange
        let nonexistentId = UUID()

        // Act
        let found = try await sut.findById(id: nonexistentId)

        // Assert
        XCTAssertNil(found)
    }

    // MARK: - Helper Methods

    private func createTestCategory() -> Category {
        return Category(
            id: UUID(),
            name: "Food",
            icon: "cart.fill",
            colorHex: "#FF6B6B",
            isCustom: false
        )
    }
}
```

---

### 5.4 Presentation Layer (Unit Tests)

**What to Test**:
- ViewModel state management
- User input handling
- Use case invocation
- Error state handling
- Loading state transitions

**Characteristics**:
- **Speed**: <50ms per test
- **Dependencies**: Application layer (with mocks)
- **Mocking**: Use cases
- **Coverage Target**: >80%

**Example Structure**:

```
BudgetTrackerTests/
└── Presentation/
    ├── ViewModels/
    │   ├── TransactionListViewModelTests.swift
    │   ├── TransactionFormViewModelTests.swift
    │   └── ReportViewModelTests.swift
    └── Mocks/
        └── MockUseCases.swift
```

**Example Test**:

```swift
import XCTest
import Combine
@testable import BudgetTracker

final class TransactionFormViewModelTests: XCTestCase {

    var sut: TransactionFormViewModel!
    var mockCreateUseCase: MockCreateTransactionUseCase!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockCreateUseCase = MockCreateTransactionUseCase()
        sut = TransactionFormViewModel(createUseCase: mockCreateUseCase)
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        sut = nil
        mockCreateUseCase = nil
        super.tearDown()
    }

    // MARK: - Validation Tests

    func test_submitForm_withEmptyName_setsErrorState() async {
        // Arrange
        sut.name = ""
        sut.amount = "50.00"

        // Act
        await sut.submitForm()

        // Assert
        XCTAssertTrue(sut.hasError)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(mockCreateUseCase.executeCalled)
    }

    func test_submitForm_withValidData_callsCreateUseCase() async {
        // Arrange
        sut.name = "Coffee"
        sut.amount = "4.50"
        sut.selectedCategory = createTestCategory()

        // Act
        await sut.submitForm()

        // Assert
        XCTAssertTrue(mockCreateUseCase.executeCalled)
        XCTAssertEqual(mockCreateUseCase.executeInput?.name, "Coffee")
    }

    // MARK: - Loading State Tests

    func test_submitForm_setsLoadingStateDuringExecution() async {
        // Arrange
        sut.name = "Test"
        sut.amount = "10.00"
        mockCreateUseCase.executeDelay = 0.1

        var loadingStates: [Bool] = []
        sut.$isLoading
            .sink { loadingStates.append($0) }
            .store(in: &cancellables)

        // Act
        await sut.submitForm()

        // Assert
        XCTAssertTrue(loadingStates.contains(true))
        XCTAssertFalse(sut.isLoading) // Should be false after completion
    }

    private func createTestCategory() -> Category {
        Category(id: UUID(), name: "Food", icon: "cart.fill")
    }
}
```

---

### 5.5 End-to-End Tests (UI Tests)

**IMPORTANT**: UI Tests are E2E (End-to-End) tests that test the ENTIRE application stack with ZERO MOCKS. They use the real database, real networking, and real application logic. These tests verify that the complete user journey works as expected in a production-like environment.

**What to Test**:
- Critical user flows only
- Happy path scenarios
- Real app with real database (NO IN-MEMORY DATABASE)
- Real use cases (NO MOCKED USE CASES)
- Real repositories (NO MOCKED REPOSITORIES)
- User interaction sequences
- Validation errors with real validation logic

**What NOT to Test**:
- ❌ Do NOT use mocks of any kind
- ❌ Do NOT use in-memory databases
- ❌ Do NOT mock network calls (use real backend or test backend)
- ❌ Do NOT mock use cases or repositories
- ❌ Do NOT test framework internals (SwiftUI rendering)

**Characteristics**:
- **Speed**: 2-10 seconds per test
- **Dependencies**: Full app stack (real system)
- **Mocking**: ZERO MOCKS - tests work like real user
- **Coverage Target**: 5-10 critical flows per use case
- **Database**: Real Core Data persistent store (or in-memory for isolation if needed)
- **Isolation**: Each test should clean up after itself

**Example Structure** (Organized by Use Case):

```
BudgetTrackerUITests/
├── CreateTransactionUITests.swift      ← E2E tests for Create Transaction use case
├── GetTransactionsUITests.swift        ← E2E tests for Get Transactions use case
├── UpdateTransactionUITests.swift      ← E2E tests for Update Transaction use case
├── DeleteTransactionUITests.swift      ← E2E tests for Delete Transaction use case
├── GenerateReportUITests.swift         ← E2E tests for Generate Report use case
└── TestHelpers/
    └── UITestHelpers.swift

Naming Convention: <UseCaseName>UITests.swift
```

**File Naming Convention**:
- Format: `<UseCaseName>UITests.swift`
- Examples:
  - `CreateTransactionUITests.swift` - Tests AddTransaction use case
  - `GetTransactionsUITests.swift` - Tests ViewTransactionList use case
  - `UpdateTransactionUITests.swift` - Tests EditTransaction use case

**Example Test** (CreateTransactionUITests.swift):

```swift
import XCTest

/// E2E tests for Create Transaction use case.
/// NO MOCKS - Tests the full app stack with real database.
final class CreateTransactionUITests: XCTestCase {

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

    // MARK: - Happy Path Tests

    @MainActor
    func test_createTransaction_withAllFields_savesSuccessfully() throws {
        // Open add transaction form
        let addButton = app.navigationBars.buttons.element(boundBy: 0)
        addButton.tap()

        // Fill amount
        let amountField = app.textFields["Amount"]
        amountField.tap()
        amountField.typeText("42.50")

        // Fill name
        let nameField = app.textFields["Name"]
        nameField.tap()
        nameField.typeText("Coffee at Starbucks")

        // Select currency (EUR is default)
        // Leave as default or tap to change

        // Select category
        let categoryPicker = app.buttons["Category"]
        categoryPicker.tap()

        // Optional: Add description
        let descriptionEditor = app.textViews.element(boundBy: 0)
        descriptionEditor.tap()
        descriptionEditor.typeText("Morning coffee")

        // Save
        let saveButton = app.navigationBars.buttons["Save"]
        saveButton.tap()

        // Verify transaction appears in list (real database, no mocks!)
        XCTAssertTrue(app.staticTexts["Coffee at Starbucks"].exists)
        XCTAssertTrue(app.staticTexts["€42.50"].exists || app.staticTexts["42.50"].exists)
    }

    // MARK: - Validation Error Tests

    @MainActor
    func test_createTransaction_withEmptyAmount_showsError() throws {
        let addButton = app.navigationBars.buttons.element(boundBy: 0)
        addButton.tap()

        // Fill only name
        let nameField = app.textFields["Name"]
        nameField.tap()
        nameField.typeText("Test")

        // Try to save
        let saveButton = app.navigationBars.buttons["Save"]
        saveButton.tap()

        // Verify real validation error (not mocked!)
        XCTAssertTrue(app.staticTexts["Please enter a valid amount"].exists)
    }

    // MARK: - Edit Transaction Flow

    func test_userCanEditTransaction_endToEnd() {
        // Prerequisite: Create a transaction first
        createTestTransaction(name: "Original Name", amount: "10.00")

        // Tap transaction to edit
        app.staticTexts["Original Name"].tap()

        // Edit name
        let nameField = app.textFields["Transaction Name"]
        nameField.tap()
        nameField.clearText()
        nameField.typeText("Updated Name")

        // Save
        app.buttons["Save"].tap()

        // Verify updated transaction
        XCTAssertTrue(app.staticTexts["Updated Name"].exists)
        XCTAssertFalse(app.staticTexts["Original Name"].exists)
    }

    // MARK: - Delete Transaction Flow

    func test_userCanDeleteTransaction_endToEnd() {
        // Prerequisite: Create a transaction
        createTestTransaction(name: "To Delete", amount: "15.00")

        // Swipe left to reveal delete action
        let cell = app.cells.containing(.staticText, identifier: "To Delete").element
        cell.swipeLeft()

        // Tap delete
        app.buttons["Delete"].tap()

        // Confirm deletion
        app.alerts.buttons["Delete"].tap()

        // Verify transaction is gone
        XCTAssertFalse(app.staticTexts["To Delete"].exists)
    }

    // MARK: - Helper Methods

    private func createTestTransaction(name: String, amount: String) {
        app.tabBars.buttons["Transactions"].tap()
        app.navigationBars.buttons["Add"].tap()

        app.textFields["Amount"].tap()
        app.textFields["Amount"].typeText(amount)

        app.textFields["Transaction Name"].tap()
        app.textFields["Transaction Name"].typeText(name)

        app.buttons["Food"].tap()
        app.buttons["Save & Close"].tap()
    }
}

// XCUIElement extension for helper methods
extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String else { return }
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
    }
}
```

---

## 6. Test Organization

### 6.1 Directory Structure

```
BudgetTracker/
├── BudgetTracker/
│   └── [Source code organized by layers]
│
├── BudgetTrackerTests/              ← Unit & Integration Tests
│   ├── Domain/
│   │   ├── Entities/
│   │   ├── ValueObjects/
│   │   └── DomainServices/
│   ├── Application/
│   │   └── UseCases/
│   ├── Data/
│   │   ├── Repositories/
│   │   └── Mappers/
│   ├── Presentation/
│   │   └── ViewModels/
│   └── TestHelpers/
│       ├── Mocks/
│       └── Builders/
│
└── BudgetTrackerUITests/            ← E2E Tests
    ├── TransactionFlowTests.swift
    ├── ExpensePeriodFlowTests.swift
    └── TestHelpers/
```

### 6.2 Test File Naming

```
Pattern: [ComponentName]Tests.swift

Examples:
• MoneyTests.swift              (Domain value object)
• TransactionTests.swift        (Domain entity)
• CreateTransactionUseCaseTests.swift  (Application use case)
• CoreDataTransactionRepositoryTests.swift  (Data repository)
• TransactionFormViewModelTests.swift  (Presentation ViewModel)
• TransactionFlowTests.swift    (E2E UI test)
```

---

## 7. Continuous Integration

### 7.1 CI Pipeline

```
┌────────────────────────────────────────────────────┐
│  CI Pipeline (GitHub Actions / Xcode Cloud)        │
│                                                    │
│  1. Checkout code                                  │
│  2. Install dependencies                           │
│  3. Build project                                  │
│  4. Run unit tests (fast)          ← 5 seconds     │
│  5. Run integration tests          ← 30 seconds    │
│  6. Run UI tests (E2E)             ← 2 minutes     │
│  7. Generate coverage report       ← 10 seconds    │
│  8. Quality gates check            ← 1 second      │
│                                                    │
│  Total: ~3 minutes                                 │
└────────────────────────────────────────────────────┘
```

### 7.2 Quality Gates

```
┌────────────────────────────────────────────────────┐
│  Required for Merge:                               │
│                                                    │
│  ✅ All unit tests pass                            │
│  ✅ All integration tests pass                     │
│  ✅ All E2E tests pass                             │
│  ✅ Domain layer coverage >90%                     │
│  ✅ Application layer coverage >85%                │
│  ✅ Data layer coverage >75%                       │
│  ✅ No failing tests                               │
│  ✅ No test warnings                               │
└────────────────────────────────────────────────────┘
```

---

## 8. Running Tests

### 8.1 Command Line

**All Tests**:
```bash
xcodebuild test \
  -scheme BudgetTracker \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

**Unit Tests Only**:
```bash
xcodebuild test \
  -scheme BudgetTracker \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:BudgetTrackerTests
```

**Integration Tests Only**:
```bash
xcodebuild test \
  -scheme BudgetTracker \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:BudgetTrackerTests/Data
```

**UI Tests Only**:
```bash
xcodebuild test \
  -scheme BudgetTracker \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:BudgetTrackerUITests
```

**Specific Test**:
```bash
xcodebuild test \
  -scheme BudgetTracker \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:BudgetTrackerTests/MoneyTests/test_add_withSameCurrency_returnsCorrectSum
```

### 8.2 Xcode

**Run All Tests**: `Cmd + U`

**Run Single Test**: Click diamond icon next to test method

**Run Test Class**: Click diamond icon next to class name

**Debug Test**: Right-click test → "Debug [Test Name]"

---

## 9. Code Coverage

### 9.1 Target Coverage

```
┌────────────────────────────────────────────────────┐
│  Coverage Targets by Layer:                       │
│                                                    │
│  Domain Layer:        >90%  ████████████████████  │
│  Application Layer:   >85%  █████████████████░░░  │
│  Data Layer:          >75%  ███████████████░░░░░  │
│  Presentation Layer:  >80%  ████████████████░░░░  │
│  Infrastructure:      >60%  ████████████░░░░░░░░  │
│                                                    │
│  Overall Target:      >80%                         │
└────────────────────────────────────────────────────┘
```

### 9.2 Generate Coverage Report

```bash
# Run tests with coverage
xcodebuild test \
  -scheme BudgetTracker \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -enableCodeCoverage YES

# View in Xcode
# Product → Show Build Folder in Finder
# Navigate to Logs/Test/*.xcresult
# Open in Xcode → Coverage tab
```

---

## 10. Best Practices

### 10.1 Test Independence

```swift
// ✅ Good: Each test is independent
func test_create_firstTransaction_succeeds() {
    let transaction = createTestTransaction()
    let result = sut.create(transaction)
    XCTAssertNotNil(result)
}

func test_create_secondTransaction_succeeds() {
    let transaction = createTestTransaction()
    let result = sut.create(transaction)
    XCTAssertNotNil(result)
}

// ❌ Bad: Tests depend on execution order
var sharedTransaction: Transaction?

func test_1_create() {
    sharedTransaction = sut.create(...)
}

func test_2_update() {
    sut.update(sharedTransaction!) // Fails if test_1_create didn't run
}
```

### 10.2 Arrange-Act-Assert Pattern

```swift
func test_methodName_scenario_expectedBehavior() {
    // Arrange: Set up test data and preconditions
    let input = "test data"
    let expected = "expected result"

    // Act: Execute the method being tested
    let result = sut.methodUnderTest(input)

    // Assert: Verify the outcome
    XCTAssertEqual(result, expected)
}
```

### 10.3 One Assertion Per Concept

```swift
// ✅ Good: Multiple related assertions for one concept
func test_create_withValidData_returnsTransactionWithCorrectProperties() {
    let result = sut.create(...)

    XCTAssertEqual(result.name, "Coffee")
    XCTAssertEqual(result.amount, 4.50)
    XCTAssertEqual(result.currency, .USD)
}

// ❌ Bad: Testing multiple unrelated concepts
func test_create() {
    let result1 = sut.create(transaction1)
    XCTAssertNotNil(result1)

    let result2 = sut.update(transaction2)
    XCTAssertNotNil(result2)

    let result3 = sut.delete(id: UUID())
    XCTAssertTrue(result3)
}
```

### 10.4 Async Testing

```swift
// Using async/await (Swift 5.5+)
func test_fetchData_returnsData() async throws {
    let result = try await sut.fetchData()
    XCTAssertNotNil(result)
}

// Using XCTestExpectation (for callbacks)
func test_fetchDataWithCompletion_callsCompletion() {
    let expectation = XCTestExpectation(description: "Completion called")

    sut.fetchData { result in
        XCTAssertNotNil(result)
        expectation.fulfill()
    }

    wait(for: [expectation], timeout: 2.0)
}
```

---

## 11. Testing Anti-Patterns

### 11.1 Avoid

```swift
// ❌ Testing implementation details
func test_methodCallsPrivateMethod() {
    // Don't test private methods directly
}

// ❌ Overly complex test setup
func test_scenario() {
    // 50 lines of setup code
    // Test becomes unmaintainable
}

// ❌ Multiple unrelated assertions
func test_everythingAboutTransaction() {
    // Tests create, update, delete, find all in one test
}

// ❌ Hard-coded sleep/delays
func test_asyncOperation() {
    sut.performAsync()
    sleep(2) // Bad: flaky, slow
    XCTAssertTrue(sut.completed)
}

// ❌ Testing framework code
func test_swiftUIViewRenders() {
    // Don't test SwiftUI framework itself
}
```

### 11.2 Do Instead

```swift
// ✅ Test public interface
func test_create_withValidData_returnsTransaction() {
    // Test public behavior, not implementation
}

// ✅ Use test builders/factories
func test_scenario() {
    let transaction = TransactionBuilder().withName("Test").build()
    // Clean, readable setup
}

// ✅ Single responsibility per test
func test_create_succeeds() { /* Only test create */ }
func test_update_succeeds() { /* Only test update */ }

// ✅ Use XCTestExpectation
func test_asyncOperation() async {
    let result = await sut.performAsync()
    XCTAssertTrue(result.completed)
}

// ✅ Test ViewModel logic
func test_viewModel_formatsDataCorrectly() {
    // Test your logic, not framework
}
```

---

## 12. Summary

**Testing Strategy Highlights**:

✅ **Testing Pyramid**: 80% unit, 15% integration, 5% E2E
✅ **Clear Naming**: `test_method_scenario_expectedBehavior`
✅ **Technology**: XCTest (native, zero dependencies)
✅ **Fast Execution**: Unit tests <10ms, full suite <3 minutes
✅ **High Coverage**: >80% overall, >90% in Domain
✅ **Protocol Mocking**: No mocking frameworks needed
✅ **In-Memory Testing**: Core Data integration tests use memory store
✅ **CI Integration**: Automated testing in pipeline

**Test Distribution**:
- **200+ Unit Tests**: Domain + Application + ViewModels
- **30-50 Integration Tests**: Data layer + Core Data
- **5-10 E2E Tests**: Critical user flows

**Quality Gates**:
- All tests must pass
- Coverage targets met per layer
- No test warnings or flakiness
- Fast execution (<3 minutes total)

The testing strategy ensures **confidence without compromising speed**, focusing test effort where it matters most: pure business logic in Domain and Application layers.
