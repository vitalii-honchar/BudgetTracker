# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Budget Tracker is a native iOS application for tracking personal expenses.

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
xcodebuild -scheme BudgetTracker -project BudgetTracker.xcodeproj -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
```

### Run Tests
```bash
xcodebuild -scheme BudgetTracker -project BudgetTracker.xcodeproj -destination 'platform=iOS Simulator,name=iPhone 16 Pro' test
```

## Key Technologies

- **SwiftUI** for UI
- **Core Data** for persistence
- **On-device AI** for spending insights (no external APIs)