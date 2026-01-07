import SwiftUI

struct AddTransactionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var amount = ""
    @State private var selectedCategory: TransactionCategory = .food
    @State private var selectedCurrency: Currency = .eur
    @State private var selectedDate = Date()
    @State private var notes = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details").foregroundColor(.gray)) {
                    TextField("Transaction name", text: $name)
                        .foregroundColor(.white)

                    HStack {
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                            .foregroundColor(.white)

                        Picker("Currency", selection: $selectedCurrency) {
                            ForEach(Currency.allCases) { currency in
                                Text(currency.symbol).tag(currency)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                .listRowBackground(Color(white: 0.15))

                Section(header: Text("Category").foregroundColor(.gray)) {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(TransactionCategory.allCases) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .listRowBackground(Color(white: 0.15))

                Section(header: Text("Date").foregroundColor(.gray)) {
                    DatePicker("Transaction date", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                        .foregroundColor(.white)
                }
                .listRowBackground(Color(white: 0.15))

                Section(header: Text("Notes (Optional)").foregroundColor(.gray)) {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                        .foregroundColor(.white)
                }
                .listRowBackground(Color(white: 0.15))
            }
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .navigationTitle("New Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.gray)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTransaction()
                    }
                    .foregroundColor(.blue)
                    .disabled(name.isEmpty || amount.isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func saveTransaction() {
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
            return
        }

        let transaction = Transaction(context: viewContext)
        transaction.id = UUID()
        transaction.name = name
        transaction.amount = amountValue
        transaction.category = selectedCategory.rawValue
        transaction.currency = selectedCurrency.rawValue
        transaction.date = selectedDate
        transaction.notes = notes.isEmpty ? nil : notes

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving transaction: \(error.localizedDescription)")
        }
    }
}

#Preview {
    AddTransactionView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
