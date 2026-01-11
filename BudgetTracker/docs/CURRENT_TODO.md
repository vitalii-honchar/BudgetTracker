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
- [ ] Create `BudgetTracker/Domain/ValueObjects/Currency.swift`
- [ ] Implement as enum with cases: USD, EUR, GBP, JPY, UAH
- [ ] Add symbol property (e.g., "$", "€", "£", "¥", "₴")
- [ ] Add ISO code property
- [ ] Create `BudgetTrackerTests/Domain/ValueObjects/CurrencyTests.swift`
- [ ] Write unit tests (5-10 test cases)
- [ ] Run tests and verify all pass
- [ ] Commit: "Add Currency value object with tests"

#### Task 1.2: Create Money Value Object
- [ ] Create `BudgetTracker/Domain/ValueObjects/Money.swift`
- [ ] Implement struct with `amount: Decimal` and `currency: Currency`
- [ ] Add arithmetic operations: add, subtract (with currency validation)
- [ ] Add comparison operations (equals, lessThan, greaterThan)
- [ ] Add validation (no negative amounts)
- [ ] Create `BudgetTrackerTests/Domain/ValueObjects/MoneyTests.swift`
- [ ] Write unit tests (15-20 test cases covering arithmetic, validation, edge cases)
- [ ] Run tests and verify all pass
- [ ] Commit: "Add Money value object with arithmetic and tests"

#### Task 1.3: Create Category Entity
- [ ] Create `BudgetTracker/Domain/Entities/Category.swift`
- [ ] Implement as enum with predefined categories:
  - `food` (icon: "cart.fill", color: "#FF6B6B")
  - `transport` (icon: "car.fill", color: "#4ECDC4")
  - `shopping` (icon: "bag.fill", color: "#45B7D1")
  - `entertainment` (icon: "tv.fill", color: "#FFA07A")
  - `bills` (icon: "doc.text.fill", color: "#98D8C8")
  - `health` (icon: "heart.fill", color: "#FF6B9D")
  - `other` (icon: "ellipsis.circle.fill", color: "#95A5A6")
- [ ] Add properties: name, icon (SF Symbol), colorHex
- [ ] Create `BudgetTrackerTests/Domain/Entities/CategoryTests.swift`
- [ ] Write unit tests (5-10 test cases)
- [ ] Run tests and verify all pass
- [ ] Commit: "Add Category entity with predefined categories and tests"

#### Task 1.4: Create Transaction Entity
- [ ] Create `BudgetTracker/Domain/Entities/Transaction.swift`
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
- [ ] Create `BudgetTrackerTests/Domain/Entities/TransactionTests.swift`
- [ ] Write unit tests (20-25 test cases covering validation, edge cases)
- [ ] Run tests and verify all pass
- [ ] Commit: "Add Transaction entity with validation and tests"

#### Task 1.5: Create TransactionRepository Protocol
- [ ] Create `BudgetTracker/Domain/RepositoryProtocols/TransactionRepository.swift`
- [ ] Define protocol with methods:
  - `create(transaction: Transaction) async throws -> Transaction`
  - `findAll() async throws -> [Transaction]`
- [ ] Add repository errors: `RepositoryError` enum
- [ ] No tests needed (protocol only)
- [ ] Commit: "Add TransactionRepository protocol"

---

### Phase 2: Data Layer (0/4 complete)

#### Task 2.1: Create Core Data Model
- [ ] Create `BudgetTracker/Data/CoreData/BudgetTracker.xcdatamodeld`
- [ ] Add `TransactionEntity` with attributes:
  - `id: UUID`
  - `amount: Decimal`
  - `currencyCode: String`
  - `name: String`
  - `categoryRawValue: String`
  - `date: Date`
  - `transactionDescription: String?` (optional)
  - `createdAt: Date`
  - `updatedAt: Date`
- [ ] Add indexes on `date` and `categoryRawValue`
- [ ] Set code generation to "Manual/None"
- [ ] Generate NSManagedObject subclass manually
- [ ] Commit: "Add Core Data model with TransactionEntity"

#### Task 2.2: Create CoreDataStack
- [ ] Create `BudgetTracker/Data/CoreData/CoreDataStack.swift`
- [ ] Implement with NSPersistentContainer (local only, no CloudKit)
- [ ] Add error handling for store loading
- [ ] Add convenience properties: `viewContext`, `backgroundContext`
- [ ] Create `BudgetTrackerTests/Data/TestHelpers/InMemoryCoreDataStack.swift`
- [ ] Implement in-memory stack for testing
- [ ] Commit: "Add CoreDataStack with in-memory test helper"

#### Task 2.3: Create TransactionMapper
- [ ] Create `BudgetTracker/Data/Mappers/TransactionMapper.swift`
- [ ] Implement `toDomain(entity: TransactionEntity) throws -> Transaction`
- [ ] Implement `toEntity(transaction: Transaction, context: NSManagedObjectContext) -> TransactionEntity`
- [ ] Add mapping error handling
- [ ] Create `BudgetTrackerTests/Data/Mappers/TransactionMapperTests.swift`
- [ ] Write integration tests (10-15 test cases)
- [ ] Run tests and verify all pass
- [ ] Commit: "Add TransactionMapper with bidirectional mapping and tests"

#### Task 2.4: Implement CoreDataTransactionRepository
- [ ] Create `BudgetTracker/Data/Repositories/CoreDataTransactionRepository.swift`
- [ ] Implement `TransactionRepository` protocol
- [ ] Implement `create(transaction:)` method with Core Data save
- [ ] Implement `findAll()` method with fetch request (sorted by date descending)
- [ ] Add error handling and logging
- [ ] Create `BudgetTrackerTests/Data/Repositories/CoreDataTransactionRepositoryTests.swift`
- [ ] Write integration tests using in-memory stack (10-15 test cases)
- [ ] Run tests and verify all pass
- [ ] Commit: "Add CoreDataTransactionRepository implementation with tests"

---

### Phase 3: Application Layer (0/2 complete)

#### Task 3.1: Create CreateTransactionUseCase
- [ ] Create `BudgetTracker/Application/UseCases/Transaction/CreateTransactionUseCase.swift`
- [ ] Implement with dependency on `TransactionRepository`
- [ ] Add `execute(transaction: Transaction) async throws -> Transaction` method
- [ ] Add business logic validation (if any beyond domain)
- [ ] Create `BudgetTrackerTests/Application/UseCases/Transaction/CreateTransactionUseCaseTests.swift`
- [ ] Create `BudgetTrackerTests/Application/Mocks/MockTransactionRepository.swift`
- [ ] Write unit tests with mocked repository (10-15 test cases)
- [ ] Run tests and verify all pass
- [ ] Commit: "Add CreateTransactionUseCase with tests"

#### Task 3.2: Create GetTransactionsUseCase
- [ ] Create `BudgetTracker/Application/UseCases/Transaction/GetTransactionsUseCase.swift`
- [ ] Implement with dependency on `TransactionRepository`
- [ ] Add `execute() async throws -> [Transaction]` method
- [ ] Return transactions sorted by date (newest first)
- [ ] Create `BudgetTrackerTests/Application/UseCases/Transaction/GetTransactionsUseCaseTests.swift`
- [ ] Write unit tests with mocked repository (8-10 test cases)
- [ ] Run tests and verify all pass
- [ ] Commit: "Add GetTransactionsUseCase with tests"

---

### Phase 4: Infrastructure + Presentation (0/2 complete)

#### Task 4.1: Setup Infrastructure
- [ ] Create `BudgetTracker/Infrastructure/DependencyInjection/DependencyContainer.swift`
- [ ] Initialize CoreDataStack
- [ ] Create repository instances
- [ ] Create use case instances
- [ ] Expose via singleton or environment
- [ ] Create `BudgetTracker/Infrastructure/Seeding/CategorySeeder.swift`
- [ ] Add method to verify all predefined categories exist
- [ ] Update `BudgetTracker/BudgetTrackerApp.swift`:
  - Remove SwiftData imports
  - Initialize DependencyContainer
  - Inject dependencies into environment
  - Call CategorySeeder on first launch
- [ ] Verify app builds successfully
- [ ] Commit: "Setup infrastructure with DI container and app initialization"

#### Task 4.2: Create Presentation Layer
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
- **Domain Layer**: Zero dependencies, pure Swift, business logic
- **Data Layer**: Core Data persistence, mappers
- **Application Layer**: Use cases orchestrating domain + repositories
- **Presentation Layer**: SwiftUI views + ViewModels
- **Infrastructure Layer**: DI, seeding, app initialization

### Blocked
- None

### Risks
- None for Iteration 1 (minimal scope, well-defined)
