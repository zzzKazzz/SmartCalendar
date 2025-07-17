import SwiftUI

struct DayView: View {
    let selectedDate: Date
    let events: [CalendarEvent]
    @State private var showingAddEvent = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE — MMM d, yyyy"
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            // Date header
            Text(dateFormatter.string(from: selectedDate))
                .font(.title3)
                .fontWeight(.medium)
                .padding()
            
            // Timeline
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(0..<24) { hour in
                        TimeSlot(hour: hour, events: eventsForHour(hour))
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddEvent) {
            AddEventView()
        }
    }
    
    private func eventsForHour(_ hour: Int) -> [CalendarEvent] {
        events.filter { event in
            Calendar.current.component(.hour, from: event.startDate) == hour
        }
    }
}

struct TimeSlot: View {
    let hour: Int
    let events: [CalendarEvent]
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Time label
            Text(timeString)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .trailing)
                .padding(.trailing, 8)
            
            // Divider line
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 1)
            
            // Events area
            VStack(alignment: .leading, spacing: 4) {
                if events.isEmpty {
                    Spacer()
                        .frame(height: 60)
                } else {
                    ForEach(events, id: \.id) { event in
                        EventBlock(event: event)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 8)
        }
        .frame(minHeight: 60)
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
        return formatter.string(from: date)
    }
}

struct EventBlock: View {
    let event: CalendarEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(event.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            if let notes = event.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue)
        .cornerRadius(4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
