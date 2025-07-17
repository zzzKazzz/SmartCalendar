import Foundation
import CoreData

@objc(Expense)
public class Expense: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var amount: Double
    @NSManaged public var category: String
    @NSManaged public var payer: String
    @NSManaged public var participants: String? // JSON string
    @NSManaged public var isSettled: Bool
    @NSManaged public var createdAt: Date
    @NSManaged public var notes: String?
}

extension Expense {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Expense> {
        return NSFetchRequest<Expense>(entityName: "Expense")
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
    
    var amountPerPerson: Double {
        let count = max(participantsList.count, 1)
        return amount / Double(count)
    }
}
