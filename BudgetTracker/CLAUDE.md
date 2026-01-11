# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Budget Tracker is a native iOS application for tracking personal expenses.

## Documentation

All project documentation is located in `docs/`:
- **001-requirements.md**: Product requirements and feature specifications
- **002-architecture.md**: Clean Architecture + DDD design with layer structure
- **003-database-schema.md**: Core Data schema, relationships, and migrations
- **004-ui-design.md**: UI/UX design guidelines and components
- **005-testing.md**: Testing strategy, naming conventions, and test pyramid approach
- **CURRENT_TODO.md**: Active work and tasks (working memory)
- **HISTORY_TODO.md**: Completed work log (project timeline)

When starting work, read `docs/CURRENT_TODO.md` to understand current tasks and context.

## Task Management

**IMPORTANT**: All todo items MUST be tracked in `docs/CURRENT_TODO.md`, NOT in the TodoWrite tool.

### Implementation Rules

**ALL implementation must be done ONLY from the `docs/CURRENT_TODO.md` list.**

### Iterative Development Approach

**Development follows vertical-slice iterations:**

- Each iteration delivers a **working app** testable on a physical device
- Each iteration goes through **ALL layers**: Domain → Data → Application → Infrastructure → Presentation
- Each iteration adds **ONE focused capability** (e.g., "Add Transaction", "Edit Transaction")
- **Must test on device** after each iteration before moving to next
- Following **Continuous Delivery (CD)** principles: every iteration is deployable

**Example Iterations:**
- Iteration 1: Add Transaction + View List → Working app with basic functionality
- Iteration 2: Edit Transaction → Working app with CRUD (partial)
- Iteration 3: Delete Transaction → Working app with full CRUD
- Iteration 4+: Reports, Analytics, Advanced Features

**Key Principle:** After each iteration, you have a working application that can be deployed and used, even if it has limited features.

### Workflow for New Features

When asked to implement a new feature:

1. **Analyze** the feature requirements
2. **Design** the solution following Clean Architecture principles
3. **Create** a detailed todo list in `docs/CURRENT_TODO.md` (organized by iterations)
4. **ONLY THEN** start implementing iteration by iteration

### Implementation Scheme (Per Todo Item)

Follow this scheme strictly for EACH item in the todo list:

1. **Implement** the specified feature from the todo list
2. **Write Tests** covering the implemented feature according to `docs/005-testing.md`:
   - Unit tests for Domain/Application layers
   - Integration tests for Data layer
   - E2E tests for critical flows (if applicable)
3. **Run Tests** and ensure nothing is broken:
   ```bash
   xcodebuild test -scheme BudgetTracker -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
   ```
   - If tests fail, fix them immediately
   - **IMPORTANT**: If tests unrelated to the feature fail, they ARE related - the new feature may have broken them. Fix all failing tests.
4. **Commit** the changes with a descriptive message
5. **Move to next** todo item

### Daily Workflow

1. **Read** `docs/CURRENT_TODO.md` at the start of work
2. **CRITICAL: Keep `docs/CURRENT_TODO.md` updated continuously:**
   - Mark completed items with `[x]` checkbox IMMEDIATELY after completion
   - Update "Currently Working On" section to show active task
   - Update progress percentages after each task
   - This provides explicit visibility of progress
3. **Run tests** after each completion to verify:
   - New code works as expected
   - Existing functionality is not broken
4. **Completion Criteria**: A task is ONLY considered complete when:
   - Implementation is finished
   - Unit/integration tests are written
   - All tests pass successfully
   - Code follows Clean Architecture principles
   - Changes are committed
   - **`docs/CURRENT_TODO.md` is updated**

### Test Execution

After completing each task, run appropriate tests:
```bash
# Run all tests
xcodebuild test -scheme BudgetTracker -destination 'platform=iOS Simulator,name=iPhone 16e'

# Run specific test suite
xcodebuild test -scheme BudgetTracker -destination 'platform=iOS Simulator,name=iPhone 16e' -only-testing:BudgetTrackerTests/Domain

# Run specific test class
xcodebuild test -scheme BudgetTracker -destination 'platform=iOS Simulator,name=iPhone 16e' -only-testing:BudgetTrackerTests/MoneyTests
```

### Documentation Updates

When completing major phases, update:
- `docs/CURRENT_TODO.md`: Move completed items to history
- `docs/HISTORY_TODO.md`: Record what was accomplished with timestamps
- This file (CLAUDE.md): If workflow changes

## Testing

Follow the testing pyramid approach documented in `docs/005-testing.md`:
- **Unit Tests** (80%): Domain and Application layers, fast execution (<10ms)
- **Integration Tests** (15%): Data layer with in-memory Core Data
- **E2E Tests** (5%): Critical user flows only

**Test Naming**: `test_[methodName]_[scenario]_[expectedBehavior]`

**Run Tests**:
```bash
# All tests
xcodebuild test -scheme BudgetTracker -destination 'platform=iOS Simulator,name=iPhone 16e'

# Unit tests only
xcodebuild test -scheme BudgetTracker -destination 'platform=iOS Simulator,name=iPhone 16e' -only-testing:BudgetTrackerTests

# UI tests only
xcodebuild test -scheme BudgetTracker -destination 'platform=iOS Simulator,name=iPhone 16e' -only-testing:BudgetTrackerUITests
```

**Physical Device**: iPhone 16 Pro (Vitalii's iPhone 16)

## Building and Running

### Build the Project
```bash
xcodebuild -scheme BudgetTracker -project BudgetTracker.xcodeproj build
```

### Run on Connected iPhone
Use the `/run-on-device` command to get your device ID and build instructions.

Or open in Xcode and run (Cmd+R) after selecting your device:
```bash
open BudgetTracker.xcodeproj
```

### Run in Simulator
```bash
xcodebuild -scheme BudgetTracker -project BudgetTracker.xcodeproj -destination 'platform=iOS Simulator,name=iPhone 16e' build
```

### Run Tests
```bash
xcodebuild -scheme BudgetTracker -project BudgetTracker.xcodeproj -destination 'platform=iOS Simulator,name=iPhone 16e' test
```

## Key Technologies

- **SwiftUI** for UI
- **Core Data** for persistence
- **On-device AI** for spending insights (no external APIs)