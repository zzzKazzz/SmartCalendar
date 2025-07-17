import Foundation
import CoreData

@objc(Anniversary)
public class Anniversary: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var date: Date
    @NSManaged public var isRecurring: Bool
    @NSManaged public var reminderEnabled: Bool
    @NSManaged public var reminderDaysBefore: Int16
    @NSManaged public var createdAt: Date
}

extension Anniversary {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Anniversary> {
        return NSFetchRequest<Anniversary>(entityName: "Anniversary")
    }
    
    var daysUntil: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let targetDate = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: today, to: targetDate).day ?? 0
    }
    
    var daysSince: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let targetDate = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: targetDate, to: today).day ?? 0
    }
}