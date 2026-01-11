# Current Work: V1 Development - Iteration 1

**Last Updated**: January 11, 2026
**Current Iteration**: Iteration 1 - Add Transaction + View List
**Overall Progress**: 0% (0/13 tasks complete)

---

## Iteration 1: Add Transaction + View List (0% - 0/13 complete)

**Goal**: Deliver a working app where users can add a transaction and see it in a list.

**Completion Criteria**:
- ✅ App launches on physical device
- ✅ Can tap "Add Transaction" button
- ✅ Can fill form (amount, name, category, date)
- ✅ Can save transaction
- ✅ Transaction appears in list view
- ✅ All tests pass (Domain, Data, Application layers)

---

### Phase 1: Domain Layer (0/5 complete)

#### Task 1.1: Create Currency Value Object
- [x] Create `BudgetTracker/Domain/Currency.swift`
- [x] Implement as enum with cases: USD, EUR, GBP, JPY, UAH
- [x] Add symbol property (e.g., "$", "€", "£", "¥", "₴")
- [x] Add ISO code property
- [ ] Create `BudgetTrackerTests/Domain/CurrencyTests.swift`
- [ ] Write unit tests (5-10 test cases)
- [ ] Run tests and verify all pass
- [ ] Commit: "Add Currency value object with tests"

#### Task 1.2: Create Money Value Object
- [ ] Create `BudgetTracker/Domain/Money.swift`
- [ ] Implement struct with `amount: Decimal` and `currency: Currency`
- [ ] Add arithmetic operations: add, subtract (with currency validation)
- [ ] Add comparison operations (equals, lessThan, greaterThan)
- [ ] Add validation (no negative amounts)
- [ ] Create `BudgetTrackerTests/Domain/MoneyTests.swift`
- [ ] Write unit tests (15-20 test cases covering arithmetic, validation, edge cases)
- [ ] Run tests and verify all pass
- [ ] Commit: "Add Money value object with arithmetic and tests"

#### Task 1.3: Create Category Entity
- [ ] Create `BudgetTracker/Domain/Category.swift`
- [ ] Implement as enum with predefined categories:
  - `food` (icon: "cart.fill", color: "#FF6B6B")
  - `transport` (icon: "car.fill", color: "#4ECDC4")
  - `shopping` (icon: "bag.fill", color: "#45B7D1")
  - `entertainment` (icon: "tv.fill", color: "#FFA07A")
  - `bills` (icon: "doc.text.fill", color: "#98D8C8")
  - `health` (icon: "heart.fill", color: "#FF6B9D")
  - `other` (icon: "ellipsis.circle.fill", color: "#95A5A6")
- [ ] Add properties: name, icon (SF Symbol), colorHex
- [ ] Create `BudgetTrackerTests/Domain/CategoryTests.swift`
- [ ] Write unit tests (5-10 test cases)
- [ ] Run tests and verify all pass
- [ ] Commit: "Add Category entity with predefined categories and tests"

#### Task 1.4: Create Transaction Entity
- [ ] Create `BudgetTracker/Domain/Transaction.swift`
- [ ] Implement struct with properties:
  - `id: UUID`
  - `money: Money`
  - `name: String` (1-100 characters)
  - `category: Category`
  - `date: Date` (cannot be in future)
  - `description: String?` (optional, max 500 characters)
  - `createdAt: Date`
  - `updatedAt: Date`
- [ ] Add validation in initializer
- [ ] Add custom errors: `TransactionError` enum
- [ ] Create `BudgetTrackerTests/Domain/TransactionTests.swift`
- [ ] Write unit tests (20-25 test cases covering validation, edge cases)
- [ ] Run tests and verify all pass
- [ ] Commit: "Add Transaction entity with validation and tests"

#### Task 1.5: Create Core Data Model
- [ ] Create `BudgetTracker/Domain/BudgetTracker.xcdatamodeld` (in Domain layer)
- [ ] Add `TransactionEntity` with attributes
- [ ] Set code generation to "Manual/None"
- [ ] Generate NSManagedObject subclass in Domain layer
- [ ] Commit: "Add Core Data model in Domain layer"

---

### Phase 2: Application Layer (0/3 complete)

#### Task 2.1: Create TransactionRepository Protocol
- [ ] Create `BudgetTracker/Application/TransactionRepository.swift`
- [ ] Define protocol with methods:
  - `create(transaction: Transaction) async throws -> Transaction`
  - `findAll() async throws -> [Transaction]`
- [ ] Add repository errors: `RepositoryError` enum
- [ ] No tests needed (protocol only)
- [ ] Commit: "Add TransactionRepository protocol in Application layer"

#### Task 2.2: Create CreateTransactionUseCase
- [ ] Create `BudgetTracker/Application/CreateTransactionUseCase.swift`
- [ ] Implement with dependency on `TransactionRepository`
- [ ] Add `execute(transaction: Transaction) async throws -> Transaction` method
- [ ] Create `BudgetTrackerTests/Application/Mocks/MockTransactionRepository.swift`
- [ ] Create `BudgetTrackerTests/Application/CreateTransactionUseCaseTests.swift`
- [ ] Write unit tests with mocked repository (10-15 test cases)
- [ ] Run tests and verify all pass
- [ ] Commit: "Add CreateTransactionUseCase with tests"

#### Task 2.3: Create GetTransactionsUseCase
- [ ] Create `BudgetTracker/Application/GetTransactionsUseCase.swift`
- [ ] Implement with dependency on `TransactionRepository`
- [ ] Add `execute() async throws -> [Transaction]` method
- [ ] Create `BudgetTrackerTests/Application/GetTransactionsUseCaseTests.swift`
- [ ] Write unit tests with mocked repository (8-10 test cases)
- [ ] Run tests and verify all pass
- [ ] Commit: "Add GetTransactionsUseCase with tests"

---

### Phase 3: Infrastructure Layer (0/4 complete)

#### Task 3.1: Create CoreDataStack
- [ ] Create `BudgetTracker/Infrastructure/CoreDataStack.swift`
- [ ] Implement with NSPersistentContainer (local only, no CloudKit)
- [ ] Add error handling for store loading
- [ ] Add convenience properties: `viewContext`, `backgroundContext`
- [ ] Create `BudgetTrackerTests/Infrastructure/InMemoryCoreDataStack.swift`
- [ ] Implement in-memory stack for testing
- [ ] Commit: "Add CoreDataStack with in-memory test helper"

#### Task 3.2: Create TransactionMapper
- [ ] Create `BudgetTracker/Infrastructure/TransactionMapper.swift`
- [ ] Implement `toDomain(entity: TransactionEntity) throws -> Transaction`
- [ ] Implement `toEntity(transaction: Transaction, context: NSManagedObjectContext) -> TransactionEntity`
- [ ] Add mapping error handling
- [ ] Create `BudgetTrackerTests/Infrastructure/TransactionMapperTests.swift`
- [ ] Write integration tests (10-15 test cases)
- [ ] Run tests and verify all pass
- [ ] Commit: "Add TransactionMapper with bidirectional mapping and tests"

#### Task 3.3: Implement CoreDataTransactionRepository
- [ ] Create `BudgetTracker/Infrastructure/CoreDataTransactionRepository.swift`
- [ ] Implement `TransactionRepository` protocol
- [ ] Implement `create(transaction:)` method with Core Data save
- [ ] Implement `findAll()` method with fetch request (sorted by date descending)
- [ ] Add error handling and logging
- [ ] Create `BudgetTrackerTests/Infrastructure/CoreDataTransactionRepositoryTests.swift`
- [ ] Write integration tests using in-memory stack (10-15 test cases)
- [ ] Run tests and verify all pass
- [ ] Commit: "Add CoreDataTransactionRepository implementation with tests"

#### Task 3.4: Setup Dependency Injection
- [ ] Create `BudgetTracker/Infrastructure/DependencyContainer.swift`
- [ ] Initialize CoreDataStack
- [ ] Create repository instances
- [ ] Create use case instances
- [ ] Expose via singleton or environment
- [ ] Update `BudgetTracker/BudgetTrackerApp.swift`:
  - Remove SwiftData imports
  - Initialize DependencyContainer
  - Inject dependencies into environment
- [ ] Verify app builds successfully
- [ ] Commit: "Setup infrastructure with DI container"

---

### Phase 4: Presentation Layer (0/1 complete)

#### Task 4.1: Create Presentation Layer
- [ ] Create `BudgetTracker/Presentation/ViewModels/TransactionListViewModel.swift`
  - Properties: `transactions: [Transaction]`, `isLoading: Bool`, `errorMessage: String?`
  - Method: `loadTransactions()` using GetTransactionsUseCase
  - Published properties for SwiftUI binding
- [ ] Create `BudgetTracker/Presentation/ViewModels/TransactionFormViewModel.swift`
  - Properties: form fields (amount, name, category, date, description)
  - Method: `saveTransaction()` using CreateTransactionUseCase
  - Validation logic
- [ ] Create `BudgetTracker/Presentation/Views/TransactionListView.swift`
  - Replace ContentView.swift content
  - Display list of transactions grouped by date
  - Add "+" button to navigate to form
  - Show empty state if no transactions
- [ ] Create `BudgetTracker/Presentation/Views/TransactionFormView.swift`
  - Form with text fields for amount, name, description
  - CategoryPickerView for category selection
  - DatePicker for date
  - Save button that calls ViewModel
  - Cancel button to dismiss
- [ ] Create `BudgetTracker/Presentation/Views/Components/CategoryPickerView.swift`
  - Grid or list of categories with icons and colors
  - Selection state
- [ ] Create basic ViewModel tests (optional for iteration 1, critical for iteration 2+)
- [ ] Build and run on simulator
- [ ] Verify full flow: Launch → Add Transaction → See in List
- [ ] Commit: "Add presentation layer with ViewModels and Views"

---

## Testing Checklist for Iteration 1

Before marking iteration complete, verify:

- [ ] All Domain layer tests pass (Currency, Money, Category, Transaction)
- [ ] All Data layer tests pass (Mapper, Repository with in-memory Core Data)
- [ ] All Application layer tests pass (Use cases with mocked repository)
- [ ] App builds without errors
- [ ] App runs on iOS Simulator
- [ ] Can navigate to Add Transaction form
- [ ] Can fill out form completely
- [ ] Can save transaction
- [ ] Transaction appears in list
- [ ] **CRITICAL: Test on physical iPhone device**

---

## Future Iterations (Planned)

### Iteration 2: Edit Transaction (Not Started)
- Update transaction use case
- Edit mode in form
- Navigation from list to edit
- Device test: Can edit transactions

### Iteration 3: Delete Transaction (Not Started)
- Delete transaction use case
- Swipe-to-delete in list
- Device test: Can delete transactions

### Iteration 4+: Reports & Analytics (Not Started)
- Total spending report
- Category breakdown
- Date range filtering
- Charts and visualizations

### V2 Features (Future)
- ExpensePeriod support
- Custom categories
- CloudKit sync
- AI-powered insights
- Budget limits and alerts

---

## Notes

### Current Approach
- **Vertical slices**: Each iteration goes through all layers
- **Working software**: Every iteration produces a testable app
- **Continuous Delivery**: Each iteration is deployable
- **Fast feedback**: Test on device after each iteration

### Architecture Reminder
- **Domain Layer**: Value objects (Money, Currency), Entities (Transaction, Category), Core Data models (TransactionEntity)
- **Application Layer**: Use cases + Repository protocols (interfaces)
- **Infrastructure Layer**: Repository implementations, CoreDataStack, Mappers, DI
- **Presentation Layer**: SwiftUI Views + ViewModels

### Blocked
- None

### Risks
- None for Iteration 1 (minimal scope, well-defined)
