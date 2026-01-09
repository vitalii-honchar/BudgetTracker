# Budget Tracker iOS - Architecture

## 1. Architecture Overview

Budget Tracker follows **Clean Architecture** principles combined with **Domain-Driven Design (DDD)** to achieve a maintainable, testable, and extensible codebase. The architecture is **local-first** with offline capabilities and iCloud synchronization.

**Core Design Principles**:
- **Dependency Rule**: Dependencies point inward. Domain layer has ZERO dependencies
- **Separation of Concerns**: Clear boundaries between business logic, UI, and infrastructure
- **Protocol-Oriented Design**: Domain defines contracts; outer layers implement them
- **SOLID Principles**: Single responsibility, open/closed, dependency injection throughout
- **Offline-First**: All operations work without connectivity; sync happens in background

**System Context Diagram**:

```
                         ┌─────────────────────────────┐
                         │                             │
                         │   Budget Tracker iOS App    │
                         │                             │
                         │  ┌────────────────────────┐ │
                         │  │   SwiftUI Interface    │ │
                         │  └────────────────────────┘ │
                         │  ┌────────────────────────┐ │
                         │  │   Domain Logic         │ │
                         │  └────────────────────────┘ │
                         │  ┌────────────────────────┐ │
                         │  │   Core Data Storage    │ │
                         │  └────────────────────────┘ │
                         │                             │
                         └──────────┬──────────────────┘
                                    │
                                    │ iCloud Sync
                                    ↓
                         ┌──────────────────────────────┐
                         │                              │
                         │      Apple CloudKit          │
                         │   (User's Private Database)  │
                         │                              │
                         └──────────────────────────────┘

                         ┌──────────────────────────────┐
                         │                              │
                         │      User's iOS Devices      │
                         │   (iPhone, iPad via sync)    │
                         │                              │
                         └──────────────────────────────┘
```

## 2. Architecture Layers

The application follows Clean Architecture with **strict dependency rules**:

```
        ┌─────────────────────────────────────────────────┐
        │     Presentation Layer (SwiftUI Views)          │
        │                                                 │
        └────────────┬────────────────────────────────────┘
                     │ depends on
        ┌────────────▼────────────────────────────────────┐
        │     Application Layer (Use Cases)               │
        │                                                 │
        └────────────┬────────────────────────────────────┘
                     │ depends on
        ┌────────────▼────────────────────────────────────┐
        │     Domain Layer (Entities + Protocols)         │
        │          ⚠️  ZERO DEPENDENCIES ⚠️                │
        └────────────▲────────────────────────────────────┘
                     │ implements protocols
        ┌────────────┴────────────────────────────────────┐
        │     Data Layer (Repository Implementations)     │
        │                                                 │
        └────────────▲────────────────────────────────────┘
                     │ uses
        ┌────────────┴────────────────────────────────────┐
        │     Infrastructure (CloudKit, DI, Config)       │
        │                                                 │
        └─────────────────────────────────────────────────┘
```

**Dependency Flow**:
- **Presentation** → **Application** → **Domain** ← **Data** ← **Infrastructure**
- Domain is the center with NO outward dependencies
- All layers depend on Domain (directly or indirectly)
- Outer layers implement interfaces defined in Domain

### 2.1 Domain Layer (Core Business Logic)

**Purpose**: Contains pure business logic, completely independent of frameworks, UI, and infrastructure.

**Responsibilities**:
- Define domain entities with business rules
- Define value objects for domain concepts
- Define repository contracts (protocols only, no implementations)
- Define domain services for complex business logic
- Validate business invariants

**Key Components**:

**Entities**:
- `Transaction`: Represents a financial transaction with validation rules
- `ExpensePeriod`: Groups transactions into logical periods
- `Category`: Transaction categorization
- `SpendingReport`: Aggregated spending analytics

**Value Objects**:
- `Money`: Immutable value combining amount (Decimal) + currency
- `DateRange`: Start and end dates with validation
- `TransactionCategory`: Type-safe category representation

**Repository Protocols** (contracts only):
- `TransactionRepository`: CRUD operations for transactions
- `ExpensePeriodRepository`: CRUD operations for expense periods
- `CategoryRepository`: CRUD operations for categories

**Domain Services** (if needed):
- `ReportGenerator`: Complex report calculation logic
- `CurrencyConverter`: Currency conversion rules

**Dependencies**: **NONE** - This is pure Swift with no framework dependencies

**Technology**: Pure Swift (structs, protocols, enums only)

### 2.2 Application Layer (Use Cases)

**Purpose**: Orchestrates business logic by coordinating domain entities and repositories.

**Responsibilities**:
- Implement use cases (business operations)
- Coordinate multiple repositories
- Enforce business workflows
- Handle application-specific logic
- Transform data between layers

**Key Components**:

**Transaction Use Cases**:
- `CreateTransactionUseCase`: Validates and creates transactions
- `UpdateTransactionUseCase`: Updates existing transactions
- `DeleteTransactionUseCase`: Removes transactions
- `GetTransactionsByPeriodUseCase`: Fetches filtered transactions

**Expense Period Use Cases**:
- `CreateExpensePeriodUseCase`: Creates new periods
- `GetActiveExpensePeriodUseCase`: Retrieves current period
- `GenerateReportUseCase`: Generates spending reports for periods

**Category Use Cases**:
- `GetAllCategoriesUseCase`: Retrieves all categories
- `CreateCustomCategoryUseCase`: Creates user-defined categories

**Sync Use Cases**:
- `SyncDataUseCase`: Triggers manual sync operations

**Dependencies**: Domain layer only (uses entities and repository protocols)

**Technology**: Pure Swift, may use Combine for reactive flows

### 2.3 Data Layer (Repository Implementations)

**Purpose**: Implements data persistence and retrieval strategies defined by Domain.

**Responsibilities**:
- Implement repository protocols from Domain layer
- Manage Core Data stack and operations
- Map between domain entities and data models (DTOs)
- Handle data querying, filtering, and caching
- Manage database migrations

**Key Components**:

**Repository Implementations**:
- `CoreDataTransactionRepository`: Implements `TransactionRepository`
- `CoreDataExpensePeriodRepository`: Implements `ExpensePeriodRepository`
- `CoreDataCategoryRepository`: Implements `CategoryRepository`

**Core Data Models** (DTOs):
- `TransactionEntity`: Core Data managed object
- `ExpensePeriodEntity`: Core Data managed object
- `CategoryEntity`: Core Data managed object

**Data Mappers**:
- `TransactionMapper`: Converts `Transaction` ↔ `TransactionEntity`
- `ExpensePeriodMapper`: Converts `ExpensePeriod` ↔ `ExpensePeriodEntity`
- `CategoryMapper`: Converts `Category` ↔ `CategoryEntity`

**Core Data Stack**:
- `CoreDataStack`: Manages NSPersistentCloudKitContainer and contexts

**Dependencies**: Domain layer (implements protocols, maps to entities)

**Technology**: Core Data, NSPersistentCloudKitContainer

### 2.4 Presentation Layer (UI)

**Purpose**: Handles UI rendering and user interactions.

**Responsibilities**:
- Render SwiftUI views
- Handle user input and navigation
- Present data from Application layer
- Manage view state through ViewModels
- Handle UI-specific formatting and localization

**Key Components**:

**Views**:
- `TransactionListView`: Displays list of transactions
- `TransactionFormView`: Form for creating/editing transactions
- `ExpensePeriodView`: Shows expense period details
- `ReportView`: Visualizes spending reports
- `CategoryPickerView`: Category selection

**ViewModels**:
- `TransactionListViewModel`: Manages transaction list state
- `TransactionFormViewModel`: Handles form validation and submission
- `ReportViewModel`: Prepares report data for visualization
- `ExpensePeriodViewModel`: Manages period state

**Navigation**:
- `AppCoordinator`: Manages app-wide navigation
- `Router`: Handles deep linking and navigation logic

**Reusable Components**:
- `GlassmorphicButton`: Custom button with glass-morphism effect
- `CategoryIcon`: Category icon display
- `MoneyTextField`: Formatted currency input
- `ChartView`: Spending chart visualization

**Dependencies**: Application layer (uses use cases), Domain layer (uses entities)

**Technology**: SwiftUI, Combine for reactive bindings

### 2.5 Infrastructure Layer (External Services)

**Purpose**: Provides external services and cross-cutting concerns.

**Responsibilities**:
- CloudKit synchronization coordination
- Dependency injection container
- App configuration and environment setup
- Logging and error handling
- Feature flags

**Key Components**:

**Sync Engine**:
- `CloudKitSyncCoordinator`: Monitors and coordinates iCloud sync
- `ConflictResolver`: Handles sync conflicts

**Dependency Injection**:
- `DependencyContainer`: Creates and wires dependencies
- `DIContext`: Provides dependencies to views via Environment

**Configuration**:
- `AppConfiguration`: App settings and feature flags
- `EnvironmentConfig`: Development/Production configuration

**Error Handling**:
- `ErrorLogger`: Privacy-preserving error logging
- `ErrorPresenter`: User-friendly error messages

**Dependencies**: All other layers (orchestrates everything)

**Technology**: CloudKit, Foundation, Combine

## 3. Component Design

### 3.1 Domain Model (Zero Dependencies)

```
┌─────────────────────────────────────────────────────────────┐
│                   Domain Layer (Pure Swift)                  │
│                   ⚠️  NO DEPENDENCIES ⚠️                      │
│                                                              │
│  ┌──────────────────────┐                                   │
│  │      Entities        │                                   │
│  ├──────────────────────┤                                   │
│  │                      │                                   │
│  │  ┌────────────────┐  │         ┌──────────────────┐     │
│  │  │ ExpensePeriod  │  │         │   Transaction    │     │
│  │  ├────────────────┤  │◄────────┤──────────────────┤     │
│  │  │ - id: UUID     │  │  1    * │ - id: UUID       │     │
│  │  │ - name: String │  │         │ - money: Money   │     │
│  │  │ - dateRange    │  │         │ - name: String   │     │
│  │  │ + addTrans()   │  │         │ - category       │──┐  │
│  │  │ + genReport()  │  │         │ - date: Date     │  │  │
│  │  └────────────────┘  │         │ - description?   │  │  │
│  │                      │         │ + validate()     │  │  │
│  │  ┌────────────────┐  │         └──────────────────┘  │  │
│  │  │SpendingReport  │  │                               │  │
│  │  ├────────────────┤  │                               │  │
│  │  │ - totalAmount  │  │         ┌──────────────────┐  │  │
│  │  │ - byCategory   │  │         │    Category      │◄─┘  │
│  │  │ - dateRange    │  │         ├──────────────────┤     │
│  │  │ - transactions │  │         │ - id: UUID       │     │
│  │  └────────────────┘  │         │ - name: String   │     │
│  └──────────────────────┘         │ - icon: String   │     │
│                                   │ - color: Color   │     │
│  ┌──────────────────────┐         │ - isCustom: Bool │     │
│  │   Value Objects      │         └──────────────────┘     │
│  ├──────────────────────┤                                  │
│  │ Money                │                                  │
│  │ ├─────────────────   │                                  │
│  │ │ amount: Decimal    │                                  │
│  │ │ currency: Currency │                                  │
│  │ │ + add()            │                                  │
│  │ │ + subtract()       │                                  │
│  │                      │                                  │
│  │ DateRange            │                                  │
│  │ ├─────────────────   │                                  │
│  │ │ start: Date        │                                  │
│  │ │ end: Date          │                                  │
│  │ │ + contains()       │                                  │
│  └──────────────────────┘                                  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │   Repository Protocols (Contracts Only)              │  │
│  ├──────────────────────────────────────────────────────┤  │
│  │                                                       │  │
│  │  protocol TransactionRepository {                    │  │
│  │    func create(transaction: Transaction) async throws│  │
│  │    func findById(id: UUID) async throws -> Trans?   │  │
│  │    func findByPeriod(id: UUID) async throws -> [T]  │  │
│  │    func update(transaction: Transaction) async throws│  │
│  │    func delete(id: UUID) async throws               │  │
│  │  }                                                    │  │
│  │                                                       │  │
│  │  protocol ExpensePeriodRepository { ... }            │  │
│  │  protocol CategoryRepository { ... }                 │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 Dependency Flow

```
┌────────────────────────────────────────────────────────────┐
│                    Dependency Inversion                     │
│                                                             │
│  ┌──────────────────┐                                      │
│  │   ViewModel      │ (Presentation Layer)                 │
│  └────────┬─────────┘                                      │
│           │ uses                                           │
│           ▼                                                │
│  ┌──────────────────┐                                      │
│  │    Use Case      │ (Application Layer)                  │
│  └────────┬─────────┘                                      │
│           │ depends on interface                           │
│           ▼                                                │
│  ┌────────────────────────────────┐                        │
│  │  TransactionRepository         │ (Domain - Protocol)    │
│  │  (protocol/interface)          │                        │
│  └────────────────────────────────┘                        │
│           ▲                                                │
│           │ implements                                     │
│           │                                                │
│  ┌────────┴─────────┐                                      │
│  │ CoreDataTrans... │ (Data Layer - Implementation)        │
│  │ Repository       │                                      │
│  └──────────────────┘                                      │
│           │ uses                                           │
│           ▼                                                │
│  ┌──────────────────┐                                      │
│  │   Core Data      │ (Infrastructure)                     │
│  │   Store          │                                      │
│  └──────────────────┘                                      │
└────────────────────────────────────────────────────────────┘

Key: Domain defines interface (protocol)
     Data layer implements it
     Application layer uses the interface (not implementation)
     Presentation layer uses Application layer
```

### 3.3 Use Case Flow Example

Creating a Transaction:

```
User Input
    │
    ▼
┌──────────────────┐
│ TransactionForm  │ (View)
│      View        │
└────────┬─────────┘
         │ user taps save
         ▼
┌──────────────────┐
│ TransactionForm  │ (ViewModel)
│   ViewModel      │
└────────┬─────────┘
         │ call use case
         ▼
┌──────────────────────────────┐
│ CreateTransactionUseCase     │ (Application Layer)
├──────────────────────────────┤
│ 1. Validate input            │
│ 2. Create Transaction entity │
│ 3. Call repository.create()  │
└────────┬─────────────────────┘
         │ depends on protocol
         ▼
┌──────────────────────────────┐
│ TransactionRepository        │ (Domain - Protocol)
│ protocol {                   │
│   func create(...) async     │
│ }                            │
└──────────────────────────────┘
         ▲
         │ implemented by
         │
┌────────┴─────────────────────┐
│ CoreDataTransactionRepo      │ (Data Layer)
├──────────────────────────────┤
│ 1. Map Transaction → Entity  │
│ 2. Save to Core Data         │
│ 3. Map Entity → Transaction  │
│ 4. Return result             │
└────────┬─────────────────────┘
         │ persist
         ▼
┌──────────────────┐
│   Core Data      │
│   SQLite Store   │
└──────────────────┘
```

### 3.4 Dependency Injection

```
┌─────────────────────────────────────────────────────────────┐
│          DependencyContainer (Infrastructure)                │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  class DependencyContainer {                           │ │
│  │                                                         │ │
│  │    // Infrastructure                                   │ │
│  │    private lazy var coreDataStack = CoreDataStack()    │ │
│  │                                                         │ │
│  │    // Data Layer (Repository Implementations)          │ │
│  │    private lazy var transactionRepo:                   │ │
│  │       TransactionRepository =                          │ │
│  │         CoreDataTransactionRepository(stack: ...)      │ │
│  │                                                         │ │
│  │    // Application Layer (Use Cases)                    │ │
│  │    func makeCreateTransactionUseCase() ->              │ │
│  │         CreateTransactionUseCase {                     │ │
│  │      return CreateTransactionUseCase(                  │ │
│  │        repository: transactionRepo                     │ │
│  │      )                                                  │ │
│  │    }                                                    │ │
│  │                                                         │ │
│  │    // Presentation Layer (ViewModels)                  │ │
│  │    func makeTransactionFormViewModel() ->              │ │
│  │         TransactionFormViewModel {                     │ │
│  │      return TransactionFormViewModel(                  │ │
│  │        createUseCase: makeCreateTransactionUseCase(),  │ │
│  │        updateUseCase: makeUpdateTransactionUseCase()   │ │
│  │      )                                                  │ │
│  │    }                                                    │ │
│  │  }                                                      │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  Usage in SwiftUI:                                           │
│  @Environment(\.container) var container                     │
│  @StateObject var viewModel = container.makeViewModel()      │
└─────────────────────────────────────────────────────────────┘
```

## 4. Data Architecture

### 4.1 Core Data Model

```
┌────────────────────────────────────────────────────────────┐
│                   Core Data Schema                         │
│                                                             │
│  ┌──────────────────────┐        ┌─────────────────────┐  │
│  │ ExpensePeriodEntity  │        │  TransactionEntity  │  │
│  ├──────────────────────┤        ├─────────────────────┤  │
│  │ id: UUID             │◄───────┤ id: UUID            │  │
│  │ name: String         │ 1    * │ amount: Decimal     │  │
│  │ startDate: Date      │        │ currency: String    │  │
│  │ endDate: Date?       │        │ name: String        │  │
│  │ createdAt: Date      │        │ transactionDate     │  │
│  │ updatedAt: Date      │        │ categoryID: UUID    │  │
│  │ iCloudID: String?    │        │ periodID: UUID?     │  │
│  │ transactions (rel)   │        │ descriptionText     │  │
│  └──────────────────────┘        │ createdAt: Date     │  │
│                                  │ updatedAt: Date     │  │
│  ┌──────────────────────┐        │ iCloudID: String?   │  │
│  │   CategoryEntity     │        │ period (rel)        │──┘
│  ├──────────────────────┤        │ category (rel)      │──┐
│  │ id: UUID             │◄───────┘                     │  │
│  │ name: String         │ 1    *                       │  │
│  │ icon: String         │                              │  │
│  │ colorHex: String     │                              │  │
│  │ isCustom: Bool       │                              │  │
│  │ sortOrder: Int16     │                              │  │
│  │ createdAt: Date      │                              │  │
│  │ updatedAt: Date      │                              │  │
│  │ iCloudID: String?    │                              │  │
│  │ transactions (rel)   │──────────────────────────────┘  │
│  └──────────────────────┘                                 │
│                                                            │
│  Indexes:                                                  │
│  - TransactionEntity: transactionDate, categoryID         │
│  - ExpensePeriodEntity: startDate, endDate                │
│  - CategoryEntity: sortOrder                              │
└────────────────────────────────────────────────────────────┘
```

### 4.2 Domain-to-Data Mapping

```
┌──────────────────┐                    ┌─────────────────────┐
│ Domain Entity    │                    │ Core Data Entity    │
│  (Domain Layer)  │                    │   (Data Layer)      │
│                  │                    │                     │
│  Transaction     │  ◄────Mapper────►  │ TransactionEntity   │
│  ├─────────────  │                    │  ├────────────────  │
│  │ id: UUID      │ ──────1:1───────→  │  │ id: UUID        │
│  │ money: Money  │ ──────split──────→ │  │ amount: Decimal │
│  │               │                    │  │ currency: String│
│  │ category: Cat │ ──────flatten────→ │  │ categoryID: UUID│
│  │ date: Date    │ ──────1:1───────→  │  │ date: Date      │
│  └─────────────  │                    │  └────────────────  │
└──────────────────┘                    └─────────────────────┘

Mapping Rules:
• Value objects (Money) → flattened to primitives
• Entity references → UUID foreign keys
• Relationships → Core Data relationships (lazy loaded)
• Domain entities → immutable; Data entities → mutable
```

### 4.3 Data Synchronization Flow

```
┌─────────────────────────────────────────────────────────────┐
│              iCloud Sync via NSPersistentCloudKitContainer  │
│                                                              │
│  Device A                CloudKit            Device B        │
│                                                              │
│  ┌──────────┐           ┌──────────┐        ┌──────────┐   │
│  │Core Data │           │ CloudKit │        │Core Data │   │
│  │  Store   │◄─────────→│ Private  │◄──────→│  Store   │   │
│  │          │   sync    │ Database │  sync  │          │   │
│  └──────────┘           └──────────┘        └──────────┘   │
│       │                                           │         │
│       │ NSPersistentCloudKitContainer             │         │
│       │ (automatic background sync)               │         │
│       │                                           │         │
│  ┌────▼─────┐                              ┌─────▼────┐    │
│  │ Local    │                              │ Local    │    │
│  │ Changes  │                              │ Changes  │    │
│  └──────────┘                              └──────────┘    │
│                                                             │
│  Conflict Resolution Strategy:                              │
│  • Last-write-wins (based on updatedAt timestamp)          │
│  • CloudKit CKRecord metadata for sync state               │
│  • Custom resolver for complex conflicts (future)          │
└─────────────────────────────────────────────────────────────┘
```

## 5. Technology Stack

### 5.1 Core Technologies

**Language & Frameworks**:
- **Swift 5.9+**: Modern Swift with async/await, actors, property wrappers
- **SwiftUI**: Declarative UI for iOS 15+
- **Combine**: Reactive programming for data binding
- **Core Data**: Local persistence with CloudKit integration
- **CloudKit**: iCloud synchronization (NSPersistentCloudKitContainer)

### 5.2 Layer-Specific Technologies

**Domain Layer**:
- Pure Swift (no frameworks)
- Protocols for repository contracts
- Structs for entities and value objects (immutability)

**Application Layer**:
- Pure Swift
- Combine (for reactive use case results)
- Async/await for asynchronous operations

**Data Layer**:
- Core Data framework
- NSFetchRequest for querying
- NSPredicate for filtering
- NSPersistentCloudKitContainer for iCloud sync

**Presentation Layer**:
- SwiftUI
- `@StateObject`, `@ObservedObject` for state management
- `@Environment` for dependency injection
- Combine for reactive data binding

**Infrastructure Layer**:
- CloudKit (via NSPersistentCloudKitContainer)
- Foundation (UserDefaults for preferences)
- Combine for sync coordination

## 6. Architecture Decision Records (ADRs)

### ADR-001: Clean Architecture with Strict Dependency Rule

**Context**: Need maintainable, testable architecture. Domain layer must be framework-independent.

**Options Considered**:
1. MVC (Model-View-Controller)
2. MVVM (Model-View-ViewModel)
3. Clean Architecture with DDD (strict dependency inversion)

**Decision**: Clean Architecture with Domain layer having ZERO dependencies

**Rationale**:
- **Independence**: Domain logic completely isolated from frameworks
- **Testability**: Pure domain logic tests without mocks
- **Maintainability**: Changes to UI/DB don't affect domain
- **Extensibility**: Easy to add features or swap infrastructure
- **Business Focus**: Domain reflects business concepts, not technical details

**Trade-offs**:
- ✅ Pros: Maximum flexibility, testability, longevity
- ❌ Cons: More layers/files, requires discipline to maintain boundaries

---

### ADR-002: Separate Application Layer for Use Cases

**Context**: Use Cases orchestrate domain entities and repositories. Where should they live?

**Options Considered**:
1. Put Use Cases in Domain layer
2. Put Use Cases in Presentation layer (fat ViewModels)
3. Separate Application layer between Domain and Presentation

**Decision**: Separate Application Layer for Use Cases

**Rationale**:
- **Domain Purity**: Domain remains dependency-free with only entities/protocols
- **Single Responsibility**: Use Cases coordinate; Entities enforce rules
- **Reusability**: Use Cases shared across multiple ViewModels
- **Clean Architecture**: Standard pattern in Clean Architecture
- **Testability**: Test use cases separately from domain and presentation

**Trade-offs**:
- ✅ Pros: Clear separation, reusable, testable
- ❌ Cons: One more layer to understand

---

### ADR-003: Core Data with NSPersistentCloudKitContainer

**Context**: Need local persistence with iCloud sync, offline-first.

**Options Considered**:
1. CloudKit only (direct API)
2. Core Data + manual CloudKit sync
3. Core Data with NSPersistentCloudKitContainer
4. SwiftData (iOS 17+)

**Decision**: Core Data with NSPersistentCloudKitContainer

**Rationale**:
- **Automatic Sync**: Container handles bidirectional sync automatically
- **Offline-First**: Core Data provides robust local storage
- **Battle-Tested**: Mature technology with extensive documentation
- **Conflict Resolution**: Built-in conflict handling
- **Query Power**: Complex queries with NSFetchRequest
- **iOS 15 Support**: Broader compatibility than SwiftData

**Trade-offs**:
- ✅ Pros: Automatic sync, mature, powerful queries
- ❌ Cons: Requires mapping to domain entities, more verbose than SwiftData

---

### ADR-004: Repository Pattern with Protocols in Domain

**Context**: Need to abstract data access while maintaining dependency inversion.

**Options Considered**:
1. Direct Core Data access from Use Cases
2. Repository pattern with protocols in Application layer
3. Repository pattern with protocols in Domain layer

**Decision**: Repository protocols defined in Domain, implemented in Data layer

**Rationale**:
- **Dependency Inversion**: Domain defines contract; Data implements it
- **Testability**: Mock repositories for testing use cases
- **Flexibility**: Swap implementations (e.g., in-memory for tests)
- **Domain Independence**: Domain doesn't know about Core Data
- **Clean Architecture**: Outer layers depend on inner interfaces

**Trade-offs**:
- ✅ Pros: Perfect dependency inversion, highly testable
- ❌ Cons: Requires mappers between domain and data entities

---

### ADR-005: Value Objects for Domain Concepts

**Context**: How to represent money, dates, and other domain concepts?

**Options Considered**:
1. Primitive types (Double, String, Date)
2. Type aliases
3. Value Objects (immutable structs)

**Decision**: Value Objects (Money, DateRange, etc.)

**Rationale**:
- **Type Safety**: Can't accidentally mix amounts and currencies
- **Encapsulation**: Validation and behavior bundled with data
- **Immutability**: Prevents accidental modification
- **Domain-Driven Design**: Value Objects are core DDD concept
- **Self-Documenting**: Code expresses intent clearly

**Trade-offs**:
- ✅ Pros: Type-safe, self-documenting, encapsulated
- ❌ Cons: Requires mapping to/from primitives for persistence

---

### ADR-006: SwiftUI with MVVM for Presentation

**Context**: Need modern, declarative UI with reactive data binding.

**Options Considered**:
1. UIKit with MVVM
2. SwiftUI with MVVM
3. SwiftUI with Composable Architecture (TCA)

**Decision**: SwiftUI with MVVM

**Rationale**:
- **Declarative**: Less boilerplate than UIKit
- **Reactive**: Native data binding with `@Published`
- **Modern**: Apple's recommended approach
- **Design System**: Easy glass-morphism effects
- **Accessibility**: Built-in VoiceOver, Dynamic Type support
- **Simplicity**: MVVM simpler than TCA for this use case

**Trade-offs**:
- ✅ Pros: Modern, less code, great animations
- ❌ Cons: Less mature than UIKit, occasional limitations

---

### ADR-007: Lightweight DI Container

**Context**: Need dependency management without external frameworks.

**Options Considered**:
1. Singletons
2. Manual dependency passing
3. Lightweight custom DI container
4. Third-party framework (Swinject)

**Decision**: Custom lightweight DI container

**Rationale**:
- **Zero Dependencies**: No external frameworks
- **Full Control**: Understand entire dependency graph
- **SwiftUI Integration**: Works with `@Environment`
- **Simplicity**: Easy to understand and modify
- **Sufficient**: Meets all current needs

**Trade-offs**:
- ✅ Pros: No dependencies, simple, full control
- ❌ Cons: Manual setup, fewer features than mature frameworks

---

### ADR-008: Offline-First with Background Sync

**Context**: App must work without internet; sync when available.

**Options Considered**:
1. Online-only (require internet)
2. Offline-first with manual sync
3. Offline-first with automatic background sync

**Decision**: Offline-first with automatic background sync

**Rationale**:
- **User Experience**: Always functional, no blocking
- **Privacy**: Data local by default
- **Reliability**: No single point of failure
- **Performance**: Instant local operations
- **NSPersistentCloudKitContainer**: Handles sync automatically

**Trade-offs**:
- ✅ Pros: Best UX, reliable, privacy-focused
- ❌ Cons: Sync conflicts possible (resolved via strategy)

## 7. Module Structure

Recommended project organization following Clean Architecture layers:

```
BudgetTracker/
├── Domain/                          # ⚠️ ZERO DEPENDENCIES
│   ├── Entities/
│   │   ├── Transaction.swift
│   │   ├── ExpensePeriod.swift
│   │   ├── Category.swift
│   │   └── SpendingReport.swift
│   ├── ValueObjects/
│   │   ├── Money.swift
│   │   ├── Currency.swift
│   │   ├── DateRange.swift
│   │   └── TransactionCategory.swift
│   ├── RepositoryProtocols/
│   │   ├── TransactionRepository.swift
│   │   ├── ExpensePeriodRepository.swift
│   │   └── CategoryRepository.swift
│   └── DomainServices/              # (if needed)
│       └── ReportGenerator.swift
│
├── Application/                     # Depends on: Domain
│   └── UseCases/
│       ├── Transaction/
│       │   ├── CreateTransactionUseCase.swift
│       │   ├── UpdateTransactionUseCase.swift
│       │   ├── DeleteTransactionUseCase.swift
│       │   └── GetTransactionsByPeriodUseCase.swift
│       ├── ExpensePeriod/
│       │   ├── CreateExpensePeriodUseCase.swift
│       │   ├── UpdateExpensePeriodUseCase.swift
│       │   └── GenerateReportUseCase.swift
│       ├── Category/
│       │   ├── GetAllCategoriesUseCase.swift
│       │   └── CreateCustomCategoryUseCase.swift
│       └── Sync/
│           └── SyncDataUseCase.swift
│
├── Data/                            # Depends on: Domain
│   ├── Repositories/                # Implements protocols
│   │   ├── CoreDataTransactionRepository.swift
│   │   ├── CoreDataExpensePeriodRepository.swift
│   │   └── CoreDataCategoryRepository.swift
│   ├── CoreData/
│   │   ├── BudgetTracker.xcdatamodeld
│   │   ├── Entities/
│   │   │   ├── TransactionEntity+CoreDataClass.swift
│   │   │   ├── TransactionEntity+CoreDataProperties.swift
│   │   │   ├── ExpensePeriodEntity+CoreDataClass.swift
│   │   │   ├── ExpensePeriodEntity+CoreDataProperties.swift
│   │   │   ├── CategoryEntity+CoreDataClass.swift
│   │   │   └── CategoryEntity+CoreDataProperties.swift
│   │   └── CoreDataStack.swift
│   └── Mappers/
│       ├── TransactionMapper.swift
│       ├── ExpensePeriodMapper.swift
│       └── CategoryMapper.swift
│
├── Presentation/                    # Depends on: Application, Domain
│   ├── Screens/
│   │   ├── TransactionList/
│   │   │   ├── TransactionListView.swift
│   │   │   ├── TransactionListViewModel.swift
│   │   │   └── Components/
│   │   │       └── TransactionRowView.swift
│   │   ├── TransactionForm/
│   │   │   ├── TransactionFormView.swift
│   │   │   └── TransactionFormViewModel.swift
│   │   ├── ExpensePeriod/
│   │   │   ├── ExpensePeriodListView.swift
│   │   │   ├── ExpensePeriodDetailView.swift
│   │   │   └── ExpensePeriodViewModel.swift
│   │   └── Reports/
│   │       ├── ReportView.swift
│   │       ├── ReportViewModel.swift
│   │       └── Components/
│   │           ├── ChartView.swift
│   │           └── CategoryBreakdownView.swift
│   ├── Components/                  # Reusable UI components
│   │   ├── GlassmorphicButton.swift
│   │   ├── CategoryIcon.swift
│   │   ├── MoneyTextField.swift
│   │   └── DateRangePicker.swift
│   └── Navigation/
│       ├── AppCoordinator.swift
│       └── Router.swift
│
├── Infrastructure/                  # Depends on: All other layers
│   ├── DependencyInjection/
│   │   ├── DependencyContainer.swift
│   │   └── DIEnvironmentKey.swift
│   ├── Sync/
│   │   ├── CloudKitSyncCoordinator.swift
│   │   └── ConflictResolver.swift
│   ├── Configuration/
│   │   ├── AppConfiguration.swift
│   │   └── EnvironmentConfig.swift
│   └── ErrorHandling/
│       ├── ErrorLogger.swift
│       └── ErrorPresenter.swift
│
└── App/
    ├── BudgetTrackerApp.swift       # App entry point
    ├── Info.plist
    └── Assets.xcassets
```

## 8. Security & Privacy Architecture

**Local-First Security**:
- All financial data on-device (Core Data SQLite)
- iOS Data Protection (encryption when locked)
- iCloud: TLS in transit, encrypted at rest (Apple)
- No custom backend = no server attack surface

**Privacy Guarantees**:
- Zero telemetry for financial data
- No third-party SDKs with network access
- User data → private iCloud container only
- Full user control (owns iCloud account)

**Future Enhancements**:
- Biometric auth (Face ID/Touch ID)
- Additional encryption for sensitive fields

## 9. Performance Considerations

**Target Metrics**:
- 60 FPS UI rendering
- Transaction creation < 2 seconds
- Efficient queries for 10,000+ transactions

**Optimization Strategies**:

**Core Data**:
- Batch fetch size: 50
- Indexes on date, category
- Prefetch relationships
- Background context for heavy operations

**SwiftUI**:
- `@StateObject` for owned models
- `@ObservedObject` for passed models
- `.equatable()` to prevent re-renders
- LazyVStack/LazyHStack for lists

**Async Operations**:
- Background threads for heavy work
- Async/await for repository ops
- `@MainActor` for UI updates

**Caching**:
- In-memory category cache
- Report data cached until invalidated
- Core Data automatic row cache

## 10. Testing Strategy

**Unit Tests** (Domain Layer):
- Test entities and value objects (pure Swift)
- No mocks needed (zero dependencies)
- Validate business rules

**Unit Tests** (Application Layer):
- Test use cases with mock repositories
- Verify orchestration logic
- Test error handling

**Integration Tests** (Data Layer):
- Test repositories with in-memory Core Data
- Validate mappers (Domain ↔ Data)
- Test query logic

**UI Tests** (Presentation Layer):
- Critical user flows
- Accessibility (VoiceOver, Dynamic Type)
- Snapshot tests for consistency

**Mock Strategy**:
- Protocol-based mocking (no framework)
- In-memory Core Data for integration tests
- Mock use cases for ViewModel tests

## Summary

This architecture provides a **solid, maintainable foundation** with:

✅ **Strict Dependency Rule**: Domain layer has ZERO dependencies
✅ **Testability**: Pure domain logic, protocol-based abstractions
✅ **Scalability**: Add features without modifying existing code
✅ **Privacy**: Local-first, offline-capable design
✅ **Performance**: Optimized Core Data + SwiftUI
✅ **Maintainability**: Clear boundaries, SOLID principles

The architecture is **framework-independent at the core**, leveraging iOS-native technologies (SwiftUI, Core Data, CloudKit) in outer layers while keeping business logic pure and portable.
