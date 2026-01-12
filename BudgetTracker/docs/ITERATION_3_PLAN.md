# Iteration 3: Expense Periods - Implementation Plan

## Gap Analysis

### ✅ Completed (Iterations 1 & 2)
- Basic Transaction CRUD (create, read, update, delete)
- Transaction fields: amount, currency, name, category, date, description
- Predefined categories (Food, Shopping, Transport, Entertainment, Health, Bills)
- Multi-currency support (EUR, USD, GBP, JPY, UAH)
- Clean Architecture + DDD implementation
- Core Data persistence
- Comprehensive test coverage (161 tests total)

### ❌ Missing from Initial Requirements

**CRITICAL - Iteration 3:**
1. **Expense Periods** - Top-level organizational abstraction (highest priority!)
   - Create, read, update, delete periods
   - Link transactions to periods
   - Period-based transaction filtering
   - Auto-generate reports per period

**Future Iterations:**
2. **Spending Reports** - Dedicated reporting screen
3. **Visualizations** - Charts and graphs
4. **Custom Categories** - User-created categories
5. **iCloud Sync** - CloudKit integration
6. **Dark Mode** - System appearance support

---

## Iteration 3 Scope: Expense Periods

**Goal**: Implement the fundamental "Expense Period" abstraction that organizes transactions into logical groups (e.g., "March 2024", "Vacation Budget", "Q1 Expenses").

**Why Periods First?**
- Requirements state: "Top-level organizational abstraction"
- Enables meaningful reports and analytics
- Foundation for all reporting features
- Database schema already designed for it

---

## Implementation Plan

### Phase 1: Domain Layer

**New Entity: ExpensePeriod**
```swift
struct ExpensePeriod {
    let id: UUID
    let name: String
    let startDate: Date
    let endDate: Date?
    let createdAt: Date
    let updatedAt: Date
}
```

**Business Rules:**
- Name must be 1-100 characters
- Start date required
- End date optional (nil = ongoing period)
- If end date exists, must be after start date
- Validation errors for invalid data

**Tests:** 15+ unit tests
- Creation with valid data
- Validation: empty name, invalid dates, end before start
- Equality and comparison
- Edge cases

---

### Phase 2: Application Layer

**New Use Cases:**
1. `CreateExpensePeriodUseCase` - Create new period
2. `GetExpensePeriodsUseCase` - List all periods
3. `UpdateExpensePeriodUseCase` - Edit period
4. `DeleteExpensePeriodUseCase` - Delete period (unlinks transactions)
5. `GetTransactionsByPeriodUseCase` - Filter transactions by period

**Repository Protocol:**
```swift
protocol ExpensePeriodRepository {
    func create(period: ExpensePeriod) async throws -> ExpensePeriod
    func findAll() async throws -> [ExpensePeriod]
    func findById(id: UUID) async throws -> ExpensePeriod?
    func update(period: ExpensePeriod) async throws -> ExpensePeriod
    func delete(id: UUID) async throws
}
```

**Update TransactionRepository:**
- Add `assignToPeriod(transactionId: UUID, periodId: UUID?)` method
- Add `findByPeriod(periodId: UUID)` method

**Tests:** 25+ unit tests (5 tests per use case minimum)

---

### Phase 3: Infrastructure Layer

**Core Data Updates:**

1. **Create ExpensePeriodEntity** (Core Data model)
   - Attributes: id, name, startDate, endDate, createdAt, updatedAt
   - Relationship: transactions (one-to-many)

2. **Update TransactionEntity**
   - Add relationship: period (many-to-one, optional, nullify on delete)

3. **Create ExpensePeriodMapper**
   - Domain ↔ Entity conversion

4. **Implement CoreDataExpensePeriodRepository**
   - All CRUD operations
   - Relationship management

5. **Update CoreDataTransactionRepository**
   - Implement period assignment
   - Implement period-based filtering

**Tests:** 20+ integration tests
- Repository CRUD operations
- Period-transaction relationships
- Cascade behavior (delete period → unlink transactions)
- Query performance

---

### Phase 4: Presentation Layer

**New ViewModels:**
1. `PeriodListViewModel` - Display all periods
2. `PeriodFormViewModel` - Create/edit period
3. `PeriodDetailViewModel` - Period details + transactions

**Update Existing:**
- `TransactionFormViewModel` - Add period selection
- `TransactionListViewModel` - Add period filtering

**New Views:**
1. `PeriodListView` - List of expense periods
2. `PeriodFormView` - Create/edit period form
3. `PeriodDetailView` - Period details with transaction list
4. `PeriodRowView` - Single period row component

**Update Existing:**
- `TransactionFormView` - Add period picker
- `TransactionListView` - Add period filter dropdown
- Update navigation structure

**UI Features:**
- Tap period to see its transactions
- Create period button
- Edit/delete periods
- Assign transaction to period during creation
- Filter transactions by period
- "All Transactions" option (no period filter)
- Show period summary (total spend, transaction count, date range)

---

### Phase 5: E2E Testing

**New Test Files:**
1. `CreateExpensePeriodUITests` (10+ tests)
   - Create period with valid data
   - Validation errors
   - Cancel workflow

2. `GetExpensePeriodsUITests` (8+ tests)
   - List periods
   - Empty state
   - Navigation to period details

3. `UpdateExpensePeriodUITests` (10+ tests)
   - Edit period fields
   - Save changes
   - Cancel discards changes

4. `DeleteExpensePeriodUITests` (8+ tests)
   - Delete period
   - Confirmation dialog
   - Transactions unlinked (not deleted)

5. `PeriodTransactionLinkingUITests` (12+ tests)
   - Assign transaction to period
   - Filter by period
   - Unassign transaction
   - Period with no transactions

**Total E2E Tests:** 48+ tests (all with zero mocks)

---

## Database Migration

**Migration Strategy:**
1. Add ExpensePeriodEntity to Core Data model
2. Add period relationship to TransactionEntity (optional, nullify)
3. Create lightweight migration (automatic)
4. All existing transactions start with period = nil

**Migration Steps:**
```swift
// Core Data migration from version 1 to version 2
// 1. Add ExpensePeriodEntity
// 2. Add TransactionEntity.period relationship
// 3. Set default: all existing transactions have nil period
```

---

## Estimated Test Count

**New Tests in Iteration 3:**
- Domain: 15+ tests
- Application: 25+ tests
- Infrastructure: 20+ tests
- E2E: 48+ tests
- **Total: ~108 new tests**

**Running Total:** 161 (current) + 108 (new) = **269 tests**

---

## Success Criteria

✅ All 5 expense period use cases implemented
✅ Period CRUD operations working in UI
✅ Transactions can be assigned to periods
✅ Transactions can be filtered by period
✅ Deleting period unlinks (doesn't delete) transactions
✅ All tests pass (unit, integration, E2E)
✅ App builds and runs on device
✅ Database migration successful

---

## Implementation Order

1. Domain Layer: ExpensePeriod entity + tests
2. Application Layer: Use cases + repository protocol + tests
3. Infrastructure Layer: Core Data entities + repository + migration + tests
4. Presentation Layer: ViewModels + Views
5. E2E Testing: All UI test files
6. Device Testing: Verify on physical device

**Timeline:** This is a complete vertical slice through all layers.

---

## Next Iterations (Future)

**Iteration 4:** Spending Reports & Visualizations
- Dedicated reports screen
- Charts (bar, pie, line)
- Category breakdown
- Time-based trends
- Export capabilities

**Iteration 5:** Advanced Features
- Custom categories
- Budget goals
- Recurring transactions
- Search functionality

**Iteration 6:** iCloud Synchronization
- CloudKit integration
- Conflict resolution
- Offline-first sync
- Multi-device testing

**Iteration 7:** Polish & Release
- Dark mode
- Accessibility
- Localization
- App Store submission
