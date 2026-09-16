import Foundation

// MARK: - Guest Model
struct Guest: Identifiable, Codable {
    let id: String
    var name: String
    var email: String
    var phone: String
    var rsvpStatus: RSVPStatus = .pending
    var numberOfGuests: Int = 1
    var dietaryRestrictions: String = ""
    var notes: String = ""
    var addedDate: Date = Date()
    
    enum RSVPStatus: String, Codable {
        case pending = "Pending"
        case accepted = "Accepted"
        case declined = "Declined"
        case maybeAttending = "Maybe"
    }
}

// MARK: - Budget Model
struct BudgetItem: Identifiable, Codable {
    let id: String
    var category: BudgetCategory
    var description: String
    var amount: Double
    var isPaid: Bool = false
    var dueDate: Date?
    var notes: String = ""
    var createdDate: Date = Date()
    
    enum BudgetCategory: String, Codable, CaseIterable {
        case venue = "Venue"
        case catering = "Catering"
        case photography = "Photography"
        case flowers = "Flowers"
        case music = "Music & DJ"
        case decorations = "Decorations"
        case clothing = "Clothing & Accessories"
        case invitations = "Invitations"
        case transportation = "Transportation"
        case accommodations = "Accommodations"
        case other = "Other"
    }
}

// MARK: - Timeline Model
struct TimelineEvent: Identifiable, Codable {
    let id: String
    var title: String
    var description: String
    var date: Date
    var category: TimelineCategory
    var isCompleted: Bool = false
    var priority: Priority = .medium
    var reminderDate: Date?
    var notes: String = ""
    
    enum TimelineCategory: String, Codable, CaseIterable {
        case planning = "Planning"
        case vendor = "Vendor Booking"
        case payment = "Payment"
        case preparation = "Preparation"
        case other = "Other"
    }
    
    enum Priority: String, Codable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
    }
}

// MARK: - Photo Model
struct WeddingPhoto: Identifiable, Codable {
    let id: String
    var imageUrl: String
    var thumbnail: String?
    var caption: String = ""
    var uploadedBy: String
    var uploadedDate: Date = Date()
    var album: String = "General"
}

// MARK: - Chat Message Model
struct ChatMessage: Identifiable, Codable {
    let id: String
    var senderId: String
    var senderName: String
    var message: String
    var timestamp: Date = Date()
    var attachmentUrl: String?
    var isRead: Bool = false
}

// MARK: - Seating Arrangement Model
struct Table: Identifiable, Codable {
    let id: String
    var tableNumber: Int
    var capacity: Int
    var guests: [String] = [] // Guest IDs
    var notes: String = ""
}

struct SeatingArrangement: Codable {
    var tables: [Table] = []
    var unassignedGuests: [String] = [] // Guest IDs
    var createdDate: Date = Date()
    var lastModified: Date = Date()
}
