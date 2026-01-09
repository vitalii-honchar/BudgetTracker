# Budget Tracker iOS - Database Schema

## Overview

Budget Tracker uses **Core Data** with **NSPersistentCloudKitContainer** for local persistence and iCloud synchronization. This document defines the complete database schema, relationships, indexes, and migration strategy.

**Storage Technology:**
- **Local Storage**: SQLite database via Core Data
- **Cloud Sync**: CloudKit private database (automatic via NSPersistentCloudKitContainer)
- **Location**: `~/Library/Application Support/BudgetTracker/BudgetTracker.sqlite`

**Key Characteristics:**
- Relational database with foreign key relationships
- Automatic iCloud sync with conflict resolution
- Offline-first with eventual consistency
- Optimized indexes for query performance

---

## Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    Core Data Schema (ERD)                        │
│                                                                  │
│                                                                  │
│   ┌──────────────────────┐                                      │
│   │  ExpensePeriodEntity │                                      │
│   ├──────────────────────┤                                      │
│   │ PK: id (UUID)        │                                      │
│   │     name             │                                      │
│   │     startDate        │                                      │
│   │     endDate?         │                                      │
│   │     createdAt        │                                      │
│   │     updatedAt        │                                      │
│   └──────────┬───────────┘                                      │
│              │                                                  │
│              │ 1                                                │
│              │                                                  │
│              │                                                  │
│              │ *                                                │
│   ┌──────────▼───────────┐         ┌─────────────────────┐    │
│   │  TransactionEntity   │         │  CategoryEntity     │    │
│   ├──────────────────────┤         ├─────────────────────┤    │
│   │ PK: id (UUID)        │         │ PK: id (UUID)       │    │
│   │ FK: periodID         │◄────┐   │     name            │    │
│   │ FK: categoryID       │─────┼──→│     icon            │    │
│   │     amount           │     │   │     colorHex        │    │
│   │     currency         │     │   │     isCustom        │    │
│   │     name             │     │   │     sortOrder       │    │
│   │     transactionDate  │     │   │     createdAt       │    │
│   │     descriptionText? │     │   │     updatedAt       │    │
│   │     createdAt        │     │   └─────────────────────┘    │
│   │     updatedAt        │     │                              │
│   └──────────────────────┘     │ *                            │
│              │                 │                              │
│              └─────────────────┘                              │
│                                                                │
│  Cardinality:                                                  │
│  • ExpensePeriod 1 ──→ * Transaction (one period, many trans) │
│  • Category 1 ──→ * Transaction (one category, many trans)    │
│  • Transaction belongs to exactly 1 Category (required)       │
│  • Transaction may belong to 0 or 1 ExpensePeriod (optional)  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Schema Definitions

### 1. TransactionEntity

Represents a single financial transaction (expense or income).

**Table Name**: `ZTRANSACTIONENTITY` (Core Data adds Z prefix)

| Attribute | Type | Nullable | Default | Description |
|-----------|------|----------|---------|-------------|
| `id` | UUID | NO | `UUID()` | Primary key, unique identifier |
| `amount` | Decimal(19,4) | NO | - | Transaction amount (supports 15 digits + 4 decimals) |
| `currency` | String | NO | `"USD"` | ISO 4217 currency code (USD, EUR, etc.) |
| `name` | String | NO | - | Transaction name/title (e.g., "Grocery Shopping") |
| `transactionDate` | Date | NO | `Date()` | Date/time of transaction |
| `descriptionText` | String | YES | `nil` | Optional detailed description |
| `createdAt` | Date | NO | `Date()` | Record creation timestamp |
| `updatedAt` | Date | NO | `Date()` | Last modification timestamp |

**Relationships:**

| Relationship | Destination | Type | Delete Rule | Inverse | Description |
|--------------|-------------|------|-------------|---------|-------------|
| `category` | CategoryEntity | To-One | Nullify | `transactions` | Required category assignment |
| `period` | ExpensePeriodEntity | To-One | Nullify | `transactions` | Optional period assignment |

**Indexes:**

```
Index 1: transactionDate (DESC)
  - Purpose: Fast sorting by date for transaction lists
  - Query: "Show recent transactions"

Index 2: categoryID, transactionDate (COMPOUND)
  - Purpose: Fast filtering by category + sorting
  - Query: "Show all 'Food' transactions in date order"

Index 3: periodID
  - Purpose: Fast filtering by expense period
  - Query: "Show all transactions for 'March 2024' period"
```

**Constraints:**

```swift
// Validation rules (enforced in Domain Entity)
- amount must be > 0
- currency must be valid ISO 4217 code
- name must be 1-100 characters
- transactionDate cannot be in future
- category relationship is required (NOT NULL foreign key)
```

**Example Row:**

```
id:               123e4567-e89b-12d3-a456-426614174000
amount:           42.50
currency:         USD
name:             Coffee at Starbucks
transactionDate:  2024-03-15 14:30:00
descriptionText:  Grande latte with extra shot
categoryID:       (FK) → CategoryEntity.id (Food & Dining)
periodID:         (FK) → ExpensePeriodEntity.id (March 2024)
createdAt:        2024-03-15 14:30:05
updatedAt:        2024-03-15 14:30:05
```

---

### 2. CategoryEntity

Represents transaction categories (both pre-defined and user-created).

**Table Name**: `ZCATEGORYENTITY`

| Attribute | Type | Nullable | Default | Description |
|-----------|------|----------|---------|-------------|
| `id` | UUID | NO | `UUID()` | Primary key, unique identifier |
| `name` | String | NO | - | Category display name (e.g., "Food", "Transport") |
| `icon` | String | NO | - | SF Symbol name (e.g., "cart.fill", "car.fill") |
| `colorHex` | String | NO | - | Hex color code (e.g., "#FF5733") |
| `isCustom` | Bool | NO | `false` | `true` if user-created, `false` if pre-defined |
| `sortOrder` | Int16 | NO | `0` | Display order (lower = appears first) |
| `createdAt` | Date | NO | `Date()` | Record creation timestamp |
| `updatedAt` | Date | NO | `Date()` | Last modification timestamp |

**Relationships:**

| Relationship | Destination | Type | Delete Rule | Inverse | Description |
|--------------|-------------|------|-------------|---------|-------------|
| `transactions` | TransactionEntity | To-Many | Deny | `category` | All transactions using this category |

**Indexes:**

```
Index 1: sortOrder (ASC)
  - Purpose: Fast retrieval in display order
  - Query: "Show categories in order for picker"

Index 2: name (ASC)
  - Purpose: Fast alphabetical lookup
  - Query: "Search category by name"
```

**Delete Rule: Deny**
- Categories cannot be deleted if they have transactions
- Ensures referential integrity (no orphaned transactions)

**Pre-defined Categories (seeded on first launch):**

```
┌────────┬────────────────┬──────────────┬──────────┬──────────┐
│ Order  │ Name           │ Icon         │ Color    │ isCustom │
├────────┼────────────────┼──────────────┼──────────┼──────────┤
│ 1      │ Food           │ cart.fill    │ #FF6B6B  │ false    │
│ 2      │ Restaurants    │ fork.knife   │ #FFA07A  │ false    │
│ 3      │ Transport      │ car.fill     │ #4ECDC4  │ false    │
│ 4      │ Shopping       │ bag.fill     │ #95E1D3  │ false    │
│ 5      │ Entertainment  │ ticket.fill  │ #A8E6CF  │ false    │
│ 6      │ Health         │ heart.fill   │ #FFD93D  │ false    │
│ 7      │ Sport          │ figure.run   │ #6BCB77  │ false    │
│ 8      │ Bills          │ doc.text     │ #4D96FF  │ false    │
└────────┴────────────────┴──────────────┴──────────┴──────────┘
```

**Example Row (Custom Category):**

```
id:          789e4567-e89b-12d3-a456-426614174000
name:        Crypto Investments
icon:        bitcoinsign.circle.fill
colorHex:    #F7931A
isCustom:    true
sortOrder:   100
createdAt:   2024-03-20 10:15:00
updatedAt:   2024-03-20 10:15:00
```

---

### 3. ExpensePeriodEntity

Represents time periods for grouping transactions and generating reports.

**Table Name**: `ZEXPENSEPERIODENTITY`

| Attribute | Type | Nullable | Default | Description |
|-----------|------|----------|---------|-------------|
| `id` | UUID | NO | `UUID()` | Primary key, unique identifier |
| `name` | String | NO | - | Period display name (e.g., "March 2024", "Vacation") |
| `startDate` | Date | NO | - | Period start date (inclusive) |
| `endDate` | Date | YES | `nil` | Period end date (inclusive); `nil` = ongoing |
| `createdAt` | Date | NO | `Date()` | Record creation timestamp |
| `updatedAt` | Date | NO | `Date()` | Last modification timestamp |

**Relationships:**

| Relationship | Destination | Type | Delete Rule | Inverse | Description |
|--------------|-------------|------|-------------|---------|-------------|
| `transactions` | TransactionEntity | To-Many | Nullify | `period` | All transactions in this period |

**Indexes:**

```
Index 1: startDate (DESC)
  - Purpose: Fast sorting by start date (most recent first)
  - Query: "Show recent expense periods"

Index 2: endDate (ASC, NULL LAST)
  - Purpose: Find active (ongoing) periods
  - Query: "Show current period (endDate = NULL)"
```

**Delete Rule: Nullify**
- When period is deleted, transactions remain but `periodID` becomes `NULL`
- Transactions aren't deleted, just unassigned from period

**Constraints:**

```swift
// Validation rules (enforced in Domain Entity)
- name must be 1-50 characters
- startDate must be <= endDate (if endDate is set)
- Cannot have overlapping periods (business rule, not DB constraint)
```

**Example Rows:**

```
// Ongoing period
id:          456e4567-e89b-12d3-a456-426614174000
name:        March 2024
startDate:   2024-03-01 00:00:00
endDate:     NULL (ongoing)
createdAt:   2024-03-01 08:00:00
updatedAt:   2024-03-15 14:30:00

// Completed period
id:          456e4567-e89b-12d3-a456-426614174001
name:        February 2024
startDate:   2024-02-01 00:00:00
endDate:     2024-02-29 23:59:59
createdAt:   2024-02-01 08:00:00
updatedAt:   2024-02-29 20:00:00
```

---

## CloudKit Integration

When using `NSPersistentCloudKitContainer`, Core Data automatically adds CloudKit-specific fields to each entity.

**Automatic CloudKit Fields (Hidden from App Code):**

```
Every entity gets these additional columns:
┌─────────────────────────────┬──────────┬────────────────────────┐
│ Field                       │ Type     │ Description            │
├─────────────────────────────┼──────────┼────────────────────────┤
│ CD_ckRecordID               │ String   │ CloudKit record ID     │
│ CD_ckRecordSystemFields     │ Binary   │ CloudKit metadata      │
│ CD_ckModificationDate       │ Date     │ Last cloud sync time   │
│ CD_ckOwnerName              │ String   │ iCloud account owner   │
└─────────────────────────────┴──────────┴────────────────────────┘
```

**Sync Behavior:**

```
Local SQLite                CloudKit Private Database
     │                              │
     │  1. User creates transaction │
     ├─────────────────────────────→│
     │     (automatic background)   │
     │                              │
     │  2. Another device modifies  │
     │←─────────────────────────────┤
     │     (automatic fetch)        │
     │                              │
     │  3. Conflict detected        │
     │     (same record modified)   │
     │←────────────────────────────→│
     │  4. Resolve (last-write-wins)│
     │                              │
```

**Conflict Resolution Strategy:**

```
Default: Last-Write-Wins (based on updatedAt timestamp)

Example:
  Device A: Update transaction amount at 14:30:00
  Device B: Update same transaction at 14:30:05

  Result: Device B's change wins (newer updatedAt)
```

---

## Database Migrations

### Migration Strategy

**Version 1.0.0 (Initial Schema)**

This is our baseline schema with all three entities.

```
BudgetTracker.xcdatamodeld/
  └── BudgetTracker.xcdatamodel (Current Version)
      ├── TransactionEntity
      ├── CategoryEntity
      └── ExpensePeriodEntity
```

**Enabling Lightweight Migration:**

```swift
// CoreDataStack.swift
class CoreDataStack {
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "BudgetTracker")

        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve store description")
        }

        // Enable automatic lightweight migrations
        description.setOption(
            true as NSNumber,
            forKey: NSMigratePersistentStoresAutomaticallyOption
        )
        description.setOption(
            true as NSNumber,
            forKey: NSInferMappingModelAutomaticallyOption
        )

        // Enable CloudKit sync
        description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: "iCloud.com.yourcompany.BudgetTracker"
        )

        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // Handle error appropriately in production
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        // Automatically merge changes from CloudKit
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        return container
    }()
}
```

### Future Migration Examples

**Version 1.1.0: Add Tags Support**

```
Changes:
  - Add new entity: TagEntity
  - Add many-to-many relationship: Transaction ←→ Tag

Migration Type: Lightweight (automatic)

BudgetTracker.xcdatamodeld/
  ├── BudgetTracker.xcdatamodel (v1.0.0)
  └── BudgetTracker v2.xcdatamodel (v1.1.0) ← Current
```

**Version 2.0.0: Add Recurring Transactions**

```
Changes:
  - Add RecurringTransactionEntity
  - Add attributes: recurrenceRule, nextOccurrence
  - Add relationship: Transaction → RecurringTransaction (optional)

Migration Type: Lightweight (automatic)
```

**Version 3.0.0: Change Amount Precision**

```
Changes:
  - Change amount from Decimal(19,4) to Decimal(19,2)
  - Requires data transformation

Migration Type: Manual (custom mapping model required)

Manual Migration Code:
  - Create NSMappingModel
  - Implement NSEntityMigrationPolicy subclass
  - Transform amount values (round to 2 decimals)
```

### Migration Testing Checklist

Before releasing a schema change:

```
□ Create new model version in .xcdatamodeld
□ Set new version as current
□ Test migration with existing data
  □ Small dataset (10 records)
  □ Large dataset (10,000+ records)
  □ Empty database (fresh install)
□ Test CloudKit sync after migration
□ Test rollback scenario (if possible)
□ Verify indexes still perform well
□ Check migration performance on older devices
```

---

## Query Optimization

### Common Queries and Indexes

**Query 1: Recent Transactions List**

```swift
// Fetch 50 most recent transactions
let fetchRequest: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
fetchRequest.sortDescriptors = [
    NSSortDescriptor(key: "transactionDate", ascending: false)
]
fetchRequest.fetchLimit = 50

// ✅ Uses Index: transactionDate (DESC)
// Performance: O(log n) + 50 rows
```

**Query 2: Transactions by Category and Date Range**

```swift
// Fetch all "Food" transactions in March 2024
let fetchRequest: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()

let categoryPredicate = NSPredicate(
    format: "category.id == %@",
    categoryID as CVarArg
)
let datePredicate = NSPredicate(
    format: "transactionDate >= %@ AND transactionDate <= %@",
    startDate as NSDate,
    endDate as NSDate
)
fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
    categoryPredicate,
    datePredicate
])
fetchRequest.sortDescriptors = [
    NSSortDescriptor(key: "transactionDate", ascending: false)
]

// ✅ Uses Compound Index: categoryID + transactionDate
// Performance: O(log n) + matching rows
```

**Query 3: Category Spending Totals (Aggregation)**

```swift
// Calculate total spending per category
let fetchRequest: NSFetchRequest<NSDictionary> = NSFetchRequest<NSDictionary>(
    entityName: "TransactionEntity"
)

let sumExpression = NSExpression(forFunction: "sum:", arguments: [
    NSExpression(forKeyPath: "amount")
])
let sumDescription = NSExpressionDescription()
sumDescription.name = "totalAmount"
sumDescription.expression = sumExpression
sumDescription.expressionResultType = .decimalAttributeType

fetchRequest.propertiesToFetch = ["category", sumDescription]
fetchRequest.propertiesToGroupBy = ["category"]
fetchRequest.resultType = .dictionaryResultType

// ✅ Uses Index: categoryID
// Returns: [{ category: CategoryEntity, totalAmount: Decimal }]
```

**Query 4: Active Expense Period**

```swift
// Find the current ongoing period (endDate = NULL)
let fetchRequest: NSFetchRequest<ExpensePeriodEntity> =
    ExpensePeriodEntity.fetchRequest()

fetchRequest.predicate = NSPredicate(format: "endDate == NULL")
fetchRequest.fetchLimit = 1

// ✅ Uses Index: endDate (NULL values indexed separately)
// Performance: O(1) - typically only one active period
```

### Index Performance Impact

```
Without Indexes:
  Query 1000 transactions: ~50ms (full table scan)
  Filter by category: ~80ms (full scan + filter)

With Indexes:
  Query 1000 transactions: ~2ms (index scan)
  Filter by category: ~3ms (index seek)

Rule of Thumb:
  - Index columns used in WHERE clauses
  - Index columns used in ORDER BY
  - Index foreign keys for JOIN performance
  - Avoid over-indexing (slows INSERT/UPDATE)
```

---

## Data Seeding

### Initial Categories Seed Data

On first app launch, populate pre-defined categories:

```swift
// CategorySeeder.swift
class CategorySeeder {
    static func seedDefaultCategories(context: NSManagedObjectContext) async throws {
        // Check if already seeded
        let fetchRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        let count = try context.count(for: fetchRequest)

        guard count == 0 else { return } // Already seeded

        let defaultCategories = [
            ("Food", "cart.fill", "#FF6B6B", 1),
            ("Restaurants", "fork.knife", "#FFA07A", 2),
            ("Transport", "car.fill", "#4ECDC4", 3),
            ("Shopping", "bag.fill", "#95E1D3", 4),
            ("Entertainment", "ticket.fill", "#A8E6CF", 5),
            ("Health", "heart.fill", "#FFD93D", 6),
            ("Sport", "figure.run", "#6BCB77", 7),
            ("Bills", "doc.text", "#4D96FF", 8),
        ]

        for (name, icon, color, order) in defaultCategories {
            let category = CategoryEntity(context: context)
            category.id = UUID()
            category.name = name
            category.icon = icon
            category.colorHex = color
            category.sortOrder = Int16(order)
            category.isCustom = false
            category.createdAt = Date()
            category.updatedAt = Date()
        }

        try context.save()
    }
}
```

---

## Database File Structure

### Local Storage Location

```
App Container/
└── Library/
    └── Application Support/
        └── BudgetTracker/
            ├── BudgetTracker.sqlite           (Main database file)
            ├── BudgetTracker.sqlite-shm       (Shared memory file)
            └── BudgetTracker.sqlite-wal       (Write-ahead log)
```

**File Sizes (Estimates):**

```
Initial (empty):          ~100 KB
With 100 transactions:    ~150 KB
With 1,000 transactions:  ~500 KB
With 10,000 transactions: ~3 MB
With 100,000 transactions: ~30 MB
```

### Backup and Export

**iCloud Backup:**
- Automatic via NSPersistentCloudKitContainer
- User's private CloudKit database
- No size limits (reasonable use)

**Manual Backup Strategy (Future Enhancement):**

```swift
// Export to JSON for backup
func exportDatabase() async throws -> URL {
    let transactions = try await fetchAllTransactions()
    let categories = try await fetchAllCategories()
    let periods = try await fetchAllExpensePeriods()

    let exportData = DatabaseExport(
        version: "1.0",
        exportDate: Date(),
        transactions: transactions,
        categories: categories,
        periods: periods
    )

    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let jsonData = try encoder.encode(exportData)

    let fileURL = FileManager.default.temporaryDirectory
        .appendingPathComponent("budget-backup-\(Date().ISO8601Format()).json")
    try jsonData.write(to: fileURL)

    return fileURL
}
```

---

## Schema Validation Rules

### Entity-Level Validation

Validation is enforced in **Domain Layer** entities, NOT in Core Data:

```swift
// Domain/Entities/Transaction.swift
struct Transaction {
    let id: UUID
    let money: Money
    let name: String
    let category: Category
    let date: Date
    let description: String?

    init(id: UUID = UUID(),
         money: Money,
         name: String,
         category: Category,
         date: Date,
         description: String? = nil) throws {

        // Validation rules
        guard money.amount > 0 else {
            throw ValidationError.invalidAmount("Amount must be positive")
        }

        guard name.count >= 1 && name.count <= 100 else {
            throw ValidationError.invalidName("Name must be 1-100 characters")
        }

        guard date <= Date() else {
            throw ValidationError.futureDate("Transaction date cannot be in future")
        }

        if let desc = description {
            guard desc.count <= 500 else {
                throw ValidationError.descriptionTooLong("Max 500 characters")
            }
        }

        self.id = id
        self.money = money
        self.name = name
        self.category = category
        self.date = date
        self.description = description
    }
}
```

**Why validation in Domain, not Core Data?**

- Core Data entities are just DTOs (data transfer objects)
- Domain entities enforce business rules
- Keeps data layer simple (just storage)
- Validation testable without database

---

## Summary

### Schema Overview

| Entity | Purpose | Relationships | Indexes | Sync |
|--------|---------|---------------|---------|------|
| **TransactionEntity** | Financial transactions | Category (required), Period (optional) | date, category+date, period | ✅ CloudKit |
| **CategoryEntity** | Transaction categorization | Transactions (many) | sortOrder, name | ✅ CloudKit |
| **ExpensePeriodEntity** | Grouping time periods | Transactions (many) | startDate, endDate | ✅ CloudKit |

### Key Design Decisions

✅ **Relational Schema**: Proper foreign keys and relationships
✅ **Indexed for Performance**: Fast queries on common operations
✅ **CloudKit-Ready**: Automatic iCloud sync enabled
✅ **Migration-Friendly**: Lightweight migrations for schema evolution
✅ **Validation in Domain**: Business rules enforced in Domain layer
✅ **Soft Deletes Not Used**: Hard deletes with proper cascade rules

### Next Steps

1. **Create .xcdatamodeld file** in Xcode with visual editor
2. **Define entities** as specified in this document
3. **Configure indexes** for optimal query performance
4. **Implement CoreDataStack** with CloudKit container
5. **Create seed data** for default categories
6. **Write migration tests** for future schema changes
7. **Implement repositories** to map between Domain and Data layers

---

## Appendix: Core Data Configuration Code

### Complete CoreDataStack Implementation

```swift
import CoreData
import CloudKit

class CoreDataStack {
    static let shared = CoreDataStack()

    private init() {}

    // MARK: - Persistent Container

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "BudgetTracker")

        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve store description")
        }

        // CloudKit Configuration
        let cloudKitContainerIdentifier = "iCloud.com.yourcompany.BudgetTracker"
        description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: cloudKitContainerIdentifier
        )

        // Enable lightweight migrations
        description.setOption(
            true as NSNumber,
            forKey: NSMigratePersistentStoresAutomaticallyOption
        )
        description.setOption(
            true as NSNumber,
            forKey: NSInferMappingModelAutomaticallyOption
        )

        // Load persistent stores
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 Production error handling:
                 - Log error to crash reporting service
                 - Present user-friendly error message
                 - Potentially delete and recreate store (last resort)
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        // View context configuration
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        return container
    }()

    // MARK: - Contexts

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }

    // MARK: - Save

    func saveContext() {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
```

### Entity Configuration Example

```swift
// In Xcode Data Model Editor, configure:

TransactionEntity:
  Class: TransactionEntity
  Module: BudgetTracker
  Codegen: Manual/None (we'll create our own classes)

  Attributes:
    id: UUID
      - Default Value: (leave empty, set in code)
      - Optional: NO
      - Indexed: YES

    amount: Decimal
      - Default Value: 0
      - Optional: NO
      - Min Value: 0.01
      - Max Value: 9999999999999.9999

    transactionDate: Date
      - Default Value: (leave empty, set in code)
      - Optional: NO
      - Indexed: YES

  Relationships:
    category:
      - Destination: CategoryEntity
      - Inverse: transactions
      - Type: To One
      - Delete Rule: Nullify
      - Optional: NO

    period:
      - Destination: ExpensePeriodEntity
      - Inverse: transactions
      - Type: To One
      - Delete Rule: Nullify
      - Optional: YES

  Fetched Properties: (none)

  Indexes:
    Index 1: transactionDate
    Index 2: category, transactionDate (compound)
```

This schema provides a **solid, performant foundation** for the Budget Tracker app with proper relationships, indexes, and CloudKit sync support.
