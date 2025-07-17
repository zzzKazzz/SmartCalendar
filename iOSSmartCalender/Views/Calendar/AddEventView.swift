import SwiftUI

struct AddEventView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var notes = ""
    @State private var participants = ""
    @State private var isShared = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Details")) {
                    TextField("Title", text: $title)
                    
                    DatePicker("Start", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("End", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                    
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Sharing")) {
                    Toggle("Shared Event", isOn: $isShared)
                    
                    if isShared {
                        TextField("Participants (comma separated)", text: $participants)
                    }
                }
            }
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEvent()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveEvent() {
        let newEvent = CalendarEvent(context: viewContext)
        newEvent.id = UUID()
        newEvent.title = title
        newEvent.startDate = startDate
        newEvent.endDate = endDate
        newEvent.notes = notes.isEmpty ? nil : notes
        newEvent.isShared = isShared
        newEvent.createdAt = Date()
        
        if isShared && !participants.isEmpty {
            let participantList = participants.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            newEvent.participantsList = participantList
        }
        
        try? viewContext.save()
        presentationMode.wrappedValue.dismiss()
    }
}