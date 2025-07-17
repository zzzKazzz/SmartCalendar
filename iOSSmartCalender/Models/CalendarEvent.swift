import Foundation
import CoreData

@objc(CalendarEvent)
public class CalendarEvent: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date
    @NSManaged public var notes: String?
    @NSManaged public var participants: String? // JSON string of participant names
    @NSManaged public var isShared: Bool
    @NSManaged public var createdAt: Date
}

extension CalendarEvent {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CalendarEvent> {
        return NSFetchRequest<CalendarEvent>(entityName: "CalendarEvent")
    }
    
    var participantsList: [String] {
        get {
            guard let participants = participants,
                  let data = participants.data(using: .utf8),
                  let list = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return list
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let string = String(data: data, encoding: .utf8) {
                participants = string
            }
        }
    }
}