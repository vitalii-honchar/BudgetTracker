# Budget Tracker iOS

A privacy-first iOS expense tracking application built with Clean Architecture, SwiftUI, and Core Data.

[![Tests](https://github.com/YOUR_USERNAME/budget-tracker-ios/workflows/Tests/badge.svg)](https://github.com/YOUR_USERNAME/budget-tracker-ios/actions)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-iOS%2015.0+-lightgrey.svg)](https://www.apple.com/ios)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## Features

- 📊 Track expenses with categories (predefined + custom)
- 📈 Visual spending reports and analytics
- 🤖 AI-powered spending insights (on-device)
- ☁️ iCloud sync across devices (CloudKit)
- 🔒 Privacy-first, local-only storage
- 🏗️ Clean Architecture + DDD for maintainability
- ✅ Comprehensive test coverage (>80%)

## Architecture

This project follows **Clean Architecture** principles with strict layer separation:

```
Domain Layer (Pure Swift)
    ↓ depends on
Application Layer (Use Cases)
    ↓ depends on
Presentation Layer (SwiftUI + ViewModels)

Domain Layer
    ↑ implements
Data Layer (Core Data Repositories)
    ↑ uses
Infrastructure (CloudKit, DI, Seeding)
```

See [docs/002-architecture.md](BudgetTracker/docs/002-architecture.md) for details.

## Getting Started

### Prerequisites

- Xcode 15.0+
- iOS 15.0+ target device or simulator
- macOS 13.0+ (for development)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/budget-tracker-ios.git
   cd budget-tracker-ios/BudgetTracker
   ```

2. Open the project:
   ```bash
   open BudgetTracker.xcodeproj
   ```

3. Build and run:
   - Select your target device/simulator
   - Press ⌘R or click the Run button

## Testing

This project follows the **Testing Pyramid** approach with comprehensive test coverage.

### Running Tests

#### All Tests
```bash
xcodebuild test \
  -scheme BudgetTracker \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

#### Unit Tests Only (Domain + Application Layers)
```bash
xcodebuild test \
  -scheme BudgetTracker \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:BudgetTrackerTests
```

#### Integration Tests Only (Data Layer)
```bash
xcodebuild test \
  -scheme BudgetTracker \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:BudgetTrackerTests/Data
```

#### UI Tests Only (E2E)
```bash
xcodebuild test \
  -scheme BudgetTracker \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:BudgetTrackerUITests
```

#### Specific Test Class
```bash
xcodebuild test \
  -scheme BudgetTracker \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:BudgetTrackerTests/MoneyTests
```

### In Xcode

- **Run all tests**: ⌘U
- **Run single test**: Click diamond icon next to test method
- **Run test class**: Click diamond icon next to class name
- **Debug test**: Right-click test → "Debug [Test Name]"

### Test Coverage

View code coverage in Xcode:
1. Run tests with coverage enabled (⌘U)
2. Show the Report Navigator (⌘9)
3. Select the latest test run
4. Click the Coverage tab

**Target Coverage**:
- Domain Layer: >90%
- Application Layer: >85%
- Data Layer: >75%
- Presentation Layer: >80%
- **Overall: >80%**

### Continuous Integration

Tests run automatically on every push to `main` via GitHub Actions. See [.github/workflows/tests.yml](.github/workflows/tests.yml).

## Project Structure

```
BudgetTracker/
├── Domain/                   # Pure Swift, zero dependencies
│   ├── Entities/            # Business entities
│   ├── ValueObjects/        # Immutable value types
│   └── RepositoryProtocols/ # Data access contracts
├── Application/
│   └── UseCases/            # Business logic orchestration
├── Data/
│   ├── Repositories/        # Core Data implementations
│   ├── CoreData/            # Core Data models
│   └── Mappers/             # Domain ↔ Data mapping
├── Presentation/
│   ├── Screens/             # SwiftUI views
│   └── Components/          # Reusable UI components
└── Infrastructure/
    ├── DependencyInjection/ # DI container
    ├── Sync/                # CloudKit coordination
    └── Seeding/             # Initial data setup
```

## Documentation

Comprehensive documentation is available in the `docs/` folder:

- [Requirements](BudgetTracker/docs/001-requirements.md) - Product requirements and features
- [Architecture](BudgetTracker/docs/002-architecture.md) - Clean Architecture design
- [Database Schema](BudgetTracker/docs/003-database-schema.md) - Core Data model
- [UI Design](BudgetTracker/docs/004-ui-design.md) - Design system and components
- [Testing Strategy](BudgetTracker/docs/005-testing.md) - Test pyramid and conventions
- [Current TODO](BudgetTracker/docs/CURRENT_TODO.md) - Active development tasks
- [History](BudgetTracker/docs/HISTORY_TODO.md) - Completed work log

## Development

### Code Style

- Follow Swift naming conventions
- Use SwiftLint for code quality (configuration pending)
- Follow Clean Architecture principles (see docs)
- Write tests for all new features (TDD encouraged)

### Test Naming Convention

```swift
test_[methodName]_[scenario]_[expectedBehavior]
```

Examples:
```swift
test_add_withSameCurrency_returnsCorrectSum()
test_create_withValidData_savesTransaction()
test_findById_withNonexistentId_returnsNil()
```

### Git Workflow

1. Create feature branch from `main`
2. Implement feature with tests
3. Ensure all tests pass locally
4. Create pull request
5. CI runs tests automatically
6. Merge after approval and passing tests

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Clean Architecture by Robert C. Martin
- Domain-Driven Design by Eric Evans
- SwiftUI and Core Data documentation by Apple

## Contact

For questions or suggestions, please open an issue on GitHub.

---

**Built with ❤️ and Clean Architecture principles**
