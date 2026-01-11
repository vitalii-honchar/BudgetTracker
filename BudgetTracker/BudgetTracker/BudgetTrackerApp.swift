//
//  BudgetTrackerApp.swift
//  BudgetTracker
//
//  Created by Vitalii Honchar on 2026-01-09.
//

import SwiftUI

@main
struct BudgetTrackerApp: App {
    private let dependencies = DependencyContainer.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.dependencies, dependencies)
        }
    }
}

// MARK: - Environment Key

private struct DependencyContainerKey: EnvironmentKey {
    static let defaultValue = DependencyContainer.shared
}

extension EnvironmentValues {
    var dependencies: DependencyContainer {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}
