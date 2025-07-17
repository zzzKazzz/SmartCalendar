import SwiftUI

struct AddAnniversaryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var date = Date()
    @State private var isRecurring = true
    @State private var reminderEnabled = false
    @State private var reminderDaysBefore: Int = 1
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Anniversary Details")) {
                    TextField("Title (e.g., Dating Anniversary)", text: $title)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    Toggle("Recurring Annually", isOn: $isRecurring)
                }
                
                Section(header: Text("Reminders")) {
                    Toggle("Enable Reminder", isOn: $reminderEnabled)
                    
                    if reminderEnabled {
                        Stepper("Remind \(reminderDaysBefore) day\(reminderDaysBefore == 1 ? "" : "s") before", 
                               value: $reminderDaysBefore, in: 1...30)
                    }
                }
            }
            .navigationTitle("New Anniversary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveAnniversary()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveAnniversary() {
        let newAnniversary = Anniversary(context: viewContext)
        newAnniversary.id = UUID()
        newAnniversary.title = title
        newAnniversary.date = date
        newAnniversary.isRecurring = isRecurring
        newAnniversary.reminderEnabled = reminderEnabled
        newAnniversary.reminderDaysBefore = Int16(reminderDaysBefore)
        newAnniversary.createdAt = Date()
        
        try? viewContext.save()
        presentationMode.wrappedValue.dismiss()
    }
}