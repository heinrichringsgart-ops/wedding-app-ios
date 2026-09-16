import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage

// MARK: - Firebase Service Protocol
protocol FirebaseServiceProtocol {
    associatedtype T
    func fetchAll() async throws -> [T]
    func add(_ item: T) async throws
    func update(_ item: T) async throws
    func delete(_ item: T) async throws
}

// MARK: - Firestore Service
class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    // MARK: - Guest Methods
    func fetchGuests() async throws -> [Guest] {
        let snapshot = try await db.collection("guests").getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Guest.self)
        }
    }
    
    func addGuest(_ guest: Guest) async throws {
        try db.collection("guests").document(guest.id).setData(from: guest)
    }
    
    func updateGuest(_ guest: Guest) async throws {
        try db.collection("guests").document(guest.id).setData(from: guest, merge: true)
    }
    
    func deleteGuest(_ guestId: String) async throws {
        try await db.collection("guests").document(guestId).delete()
    }
    
    // MARK: - Budget Methods
    func fetchBudgetItems() async throws -> [BudgetItem] {
        let snapshot = try await db.collection("budget").getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: BudgetItem.self)
        }
    }
    
    func addBudgetItem(_ item: BudgetItem) async throws {
        try db.collection("budget").document(item.id).setData(from: item)
    }
    
    func updateBudgetItem(_ item: BudgetItem) async throws {
        try db.collection("budget").document(item.id).setData(from: item, merge: true)
    }
    
    func deleteBudgetItem(_ itemId: String) async throws {
        try await db.collection("budget").document(itemId).delete()
    }
    
    // MARK: - Timeline Methods
    func fetchTimelineEvents() async throws -> [TimelineEvent] {
        let snapshot = try await db.collection("timeline").getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: TimelineEvent.self)
        }
    }
    
    func addTimelineEvent(_ event: TimelineEvent) async throws {
        try db.collection("timeline").document(event.id).setData(from: event)
    }
    
    func updateTimelineEvent(_ event: TimelineEvent) async throws {
        try db.collection("timeline").document(event.id).setData(from: event, merge: true)
    }
    
    func deleteTimelineEvent(_ eventId: String) async throws {
        try await db.collection("timeline").document(eventId).delete()
    }
    
    // MARK: - Photo Methods
    func fetchPhotos() async throws -> [WeddingPhoto] {
        let snapshot = try await db.collection("photos").getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: WeddingPhoto.self)
        }
    }
    
    func addPhoto(_ photo: WeddingPhoto) async throws {
        try db.collection("photos").document(photo.id).setData(from: photo)
    }
    
    func deletePhoto(_ photoId: String) async throws {
        try await db.collection("photos").document(photoId).delete()
    }
    
    // MARK: - Chat Methods
    func fetchMessages() async throws -> [ChatMessage] {
        let snapshot = try await db.collection("chat").order(by: "timestamp").getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: ChatMessage.self)
        }
    }
    
    func addMessage(_ message: ChatMessage) async throws {
        try db.collection("chat").document(message.id).setData(from: message)
    }
    
    func deleteMessage(_ messageId: String) async throws {
        try await db.collection("chat").document(messageId).delete()
    }
    
    // MARK: - Seating Methods
    func fetchSeatingArrangement() async throws -> SeatingArrangement {
        let snapshot = try await db.collection("seating").document("main").getDocument()
        return try snapshot.data(as: SeatingArrangement.self)
    }
    
    func updateSeatingArrangement(_ arrangement: SeatingArrangement) async throws {
        try db.collection("seating").document("main").setData(from: arrangement, merge: true)
    }
}

// MARK: - Storage Service
class StorageService {
    static let shared = StorageService()
    private let storage = Storage.storage()
    
    func uploadPhoto(_ imageData: Data, fileName: String) async throws -> String {
        let ref = storage.reference().child("photos/\(fileName)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let _ = try await ref.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await ref.downloadURL()
        return downloadURL.absoluteString
    }
    
    func deletePhoto(_ fileName: String) async throws {
        let ref = storage.reference().child("photos/\(fileName)")
        try await ref.delete()
    }
}

// MARK: - Authentication Service
class AuthService {
    static let shared = AuthService()
    
    var currentUser: User? {
        Auth.auth().currentUser
    }
    
    var isLoggedIn: Bool {
        Auth.auth().currentUser != nil
    }
    
    func signUp(email: String, password: String) async throws -> AuthDataResult {
        return try await Auth.auth().createUser(withEmail: email, password: password)
    }
    
    func signIn(email: String, password: String) async throws -> AuthDataResult {
        return try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
}

// MARK: - Realtime Database Service (for real-time chat)
class RealtimeDatabaseService {
    static let shared = RealtimeDatabaseService()
    private let database = Database.database().reference()
    
    func startListeningToMessages(completion: @escaping ([ChatMessage]) -> Void) {
        database.child("chat").observe(.value) { snapshot in
            var messages: [ChatMessage] = []
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let value = snapshot.value as? [String: Any] {
                    // Convert dictionary to ChatMessage
                    if let message = ChatMessage.from(dictionary: value) {
                        messages.append(message)
                    }
                }
            }
            
            completion(messages)
        }
    }
    
    func sendMessage(_ message: ChatMessage) throws {
        try database.child("chat").child(message.id).setValue(message.toDictionary())
    }
}

// MARK: - ChatMessage Extension for Dictionary conversion
extension ChatMessage {
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "senderId": senderId,
            "senderName": senderName,
            "message": message,
            "timestamp": ISO8601DateFormatter().string(from: timestamp),
            "attachmentUrl": attachmentUrl ?? "",
            "isRead": isRead
        ]
    }
    
    static func from(dictionary: [String: Any]) -> ChatMessage? {
        guard let id = dictionary["id"] as? String,
              let senderId = dictionary["senderId"] as? String,
              let senderName = dictionary["senderName"] as? String,
              let message = dictionary["message"] as? String else {
            return nil
        }
        
        let timestampString = dictionary["timestamp"] as? String ?? ""
        let timestamp = ISO8601DateFormatter().date(from: timestampString) ?? Date()
        let attachmentUrl = dictionary["attachmentUrl"] as? String
        let isRead = dictionary["isRead"] as? Bool ?? false
        
        return ChatMessage(
            id: id,
            senderId: senderId,
            senderName: senderName,
            message: message,
            timestamp: timestamp,
            attachmentUrl: attachmentUrl,
            isRead: isRead
        )
    }
}

// MARK: - Analytics Service
class AnalyticsService {
    static let shared = AnalyticsService()
    
    func logEvent(name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
    }
    
    func setUserProperty(_ value: String, forName name: String) {
        Analytics.setUserProperty(value, forName: name)
    }
    
    // Wedding-specific analytics
    func logGuestAdded() {
        logEvent(name: "guest_added")
    }
    
    func logBudgetItemAdded(category: String) {
        logEvent(name: "budget_item_added", parameters: ["category": category])
    }
    
    func logTimelineEventAdded() {
        logEvent(name: "timeline_event_added")
    }
    
    func logRSVPUpdated(status: String) {
        logEvent(name: "rsvp_updated", parameters: ["status": status])
    }
}
