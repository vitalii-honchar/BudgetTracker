import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TransactionListView()
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet")
                }

            ReportView()
                .tabItem {
                    Label("Reports", systemImage: "chart.bar.fill")
                }

            AIInsightsView()
                .tabItem {
                    Label("AI Insights", systemImage: "brain.head.profile")
                }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
