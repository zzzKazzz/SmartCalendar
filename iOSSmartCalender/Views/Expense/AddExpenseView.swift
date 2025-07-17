import SwiftUI

struct AddExpenseView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var amount = ""
    @State private var category = "Food"
    @State private var payer = ""
    @State private var participants = ""
    @State private var notes = ""
    
    private let categories = ["Food", "Transportation", "Entertainment", "Shopping", "Bills", "Other"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Expense Details")) {
                    TextField("Title", text: $title)
                    
                    HStack {
                        Text("$")
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section(header: Text("Payment & Splitting")) {
                    TextField("Who paid?", text: $payer)
                    TextField("Participants (comma separated)", text: $participants)
                        .help("Include the payer in this list")
                }
            }
            .navigationTitle("New Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveExpense()
                    }
                    .disabled(title.isEmpty || amount.isEmpty || payer.isEmpty)
                }
            }
        }
    }
    
    private func saveExpense() {
        guard let amountValue = Double(amount) else { return }
        
        let newExpense = Expense(context: viewContext)
        newExpense.id = UUID()
        newExpense.title = title
        newExpense.amount = amountValue
        newExpense.category = category
        newExpense.payer = payer
        newExpense.isSettled = false
        newExpense.createdAt = Date()
        newExpense.notes = notes.isEmpty ? nil : notes
        
        if !participants.isEmpty {
            let participantList = participants.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            newExpense.participantsList = participantList
        } else {
            newExpense.participantsList = [payer]
        }
        
        try? viewContext.save()
        presentationMode.wrappedValue.dismiss()
    }
}