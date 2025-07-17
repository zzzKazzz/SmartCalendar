import SwiftUI

struct DayView: View {
    let selectedDate: Date
    let events: [CalendarEvent]
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(dateFormatter.string(from: selectedDate))
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            if events.isEmpty {
                VStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No events today")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(events, id: \.id) { event in
                    EventRow(event: event)
                }
            }
        }
    }
}

struct EventRow: View {
    let event: CalendarEvent
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(event.title)
                    .font(.headline)
                Spacer()
                Text(timeFormatter.string(from: event.startDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let notes = event.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !event.participantsList.isEmpty {
                Text("Participants: \(event.participantsList.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}