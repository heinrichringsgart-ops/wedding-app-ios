import Foundation

// MARK: - Guest List ViewModel
class GuestListViewModel: ObservableObject {
    @Published var guests: [Guest] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // RSVP Statistics
    var acceptedCount: Int {
        guests.filter { $0.rsvpStatus == .accepted }.count
    }
    
    var declinedCount: Int {
        guests.filter { $0.rsvpStatus == .declined }.count
    }
    
    var pendingCount: Int {
        guests.filter { $0.rsvpStatus == .pending }.count
    }
    
    var totalGuests: Int {
        guests.reduce(0) { $0 + $1.numberOfGuests }
    }
    
    var attendingGuests: Int {
        guests.filter { $0.rsvpStatus == .accepted }.reduce(0) { $0 + $1.numberOfGuests }
    }
    
    // MARK: - Methods
    func addGuest(_ guest: Guest) {
        guests.append(guest)
    }
    
    func updateGuest(_ guest: Guest) {
        if let index = guests.firstIndex(where: { $0.id == guest.id }) {
            guests[index] = guest
        }
    }
    
    func deleteGuest(_ guest: Guest) {
        guests.removeAll { $0.id == guest.id }
    }
    
    func updateRSVP(guestId: String, status: Guest.RSVPStatus) {
        if let index = guests.firstIndex(where: { $0.id == guestId }) {
            guests[index].rsvpStatus = status
        }
    }
    
    func filterGuests(by status: Guest.RSVPStatus) -> [Guest] {
        guests.filter { $0.rsvpStatus == status }
    }
}

// MARK: - Budget ViewModel
class BudgetViewModel: ObservableObject {
    @Published var budgetItems: [BudgetItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Budget Statistics
    var totalBudget: Double {
        budgetItems.reduce(0) { $0 + $1.amount }
    }
    
    var totalPaid: Double {
        budgetItems.filter { $0.isPaid }.reduce(0) { $0 + $1.amount }
    }
    
    var totalRemaining: Double {
        totalBudget - totalPaid
    }
    
    var percentagePaid: Double {
        totalBudget == 0 ? 0 : (totalPaid / totalBudget) * 100
    }
    
    // MARK: - Methods
    func addBudgetItem(_ item: BudgetItem) {
        budgetItems.append(item)
    }
    
    func updateBudgetItem(_ item: BudgetItem) {
        if let index = budgetItems.firstIndex(where: { $0.id == item.id }) {
            budgetItems[index] = item
        }
    }
    
    func deleteBudgetItem(_ item: BudgetItem) {
        budgetItems.removeAll { $0.id == item.id }
    }
    
    func markAsPaid(itemId: String) {
        if let index = budgetItems.firstIndex(where: { $0.id == itemId }) {
            budgetItems[index].isPaid = true
        }
    }
    
    func budgetByCategory() -> [BudgetItem.BudgetCategory: Double] {
        var result: [BudgetItem.BudgetCategory: Double] = [:]
        for item in budgetItems {
            result[item.category, default: 0] += item.amount
        }
        return result
    }
}

// MARK: - Timeline ViewModel
class TimelineViewModel: ObservableObject {
    @Published var events: [TimelineEvent] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Timeline Statistics
    var upcomingEvents: [TimelineEvent] {
        events.filter { $0.date > Date() }.sorted { $0.date < $1.date }
    }
    
    var completedEvents: [TimelineEvent] {
        events.filter { $0.isCompleted }
    }
    
    var pendingEvents: [TimelineEvent] {
        events.filter { !$0.isCompleted && $0.date <= Date() }
    }
    
    // MARK: - Methods
    func addEvent(_ event: TimelineEvent) {
        events.append(event)
    }
    
    func updateEvent(_ event: TimelineEvent) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
        }
    }
    
    func deleteEvent(_ event: TimelineEvent) {
        events.removeAll { $0.id == event.id }
    }
    
    func markAsCompleted(eventId: String) {
        if let index = events.firstIndex(where: { $0.id == eventId }) {
            events[index].isCompleted = true
        }
    }
    
    func eventsByCategory() -> [TimelineEvent.TimelineCategory: [TimelineEvent]] {
        var result: [TimelineEvent.TimelineCategory: [TimelineEvent]] = [:]
        for event in events {
            if result[event.category] == nil {
                result[event.category] = []
            }
            result[event.category]?.append(event)
        }
        return result
    }
}

// MARK: - Photo ViewModel
class PhotoViewModel: ObservableObject {
    @Published var photos: [WeddingPhoto] = []
    @Published var albums: [String] = ["General", "Ceremony", "Reception", "Details"]
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Methods
    func addPhoto(_ photo: WeddingPhoto) {
        photos.append(photo)
    }
    
    func deletePhoto(_ photo: WeddingPhoto) {
        photos.removeAll { $0.id == photo.id }
    }
    
    func photosByAlbum(_ albumName: String) -> [WeddingPhoto] {
        photos.filter { $0.album == albumName }
    }
    
    func addAlbum(_ name: String) {
        if !albums.contains(name) {
            albums.append(name)
        }
    }
    
    func updatePhotoCaption(photoId: String, caption: String) {
        if let index = photos.firstIndex(where: { $0.id == photoId }) {
            photos[index].caption = caption
        }
    }
}

// MARK: - Chat ViewModel
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUserId: String = ""
    
    var unreadCount: Int {
        messages.filter { !$0.isRead && $0.senderId != currentUserId }.count
    }
    
    // MARK: - Methods
    func addMessage(_ message: ChatMessage) {
        messages.append(message)
    }
    
    func markAsRead(messageId: String) {
        if let index = messages.firstIndex(where: { $0.id == messageId }) {
            messages[index].isRead = true
        }
    }
    
    func deleteMessage(_ message: ChatMessage) {
        messages.removeAll { $0.id == message.id }
    }
    
    func messagesByUser(userId: String) -> [ChatMessage] {
        messages.filter { $0.senderId == userId }
    }
}

// MARK: - Seating ViewModel
class SeatingViewModel: ObservableObject {
    @Published var seatingArrangement: SeatingArrangement = SeatingArrangement()
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var unassignedGuestCount: Int {
        seatingArrangement.unassignedGuests.count
    }
    
    var tablesWithAvailableSeats: [Table] {
        seatingArrangement.tables.filter { $0.guests.count < $0.capacity }
    }
    
    // MARK: - Methods
    func addTable(_ table: Table) {
        seatingArrangement.tables.append(table)
    }
    
    func assignGuestToTable(guestId: String, tableId: String) {
        if let tableIndex = seatingArrangement.tables.firstIndex(where: { $0.id == tableId }) {
            seatingArrangement.tables[tableIndex].guests.append(guestId)
            seatingArrangement.unassignedGuests.removeAll { $0 == guestId }
        }
    }
    
    func removeGuestFromTable(guestId: String, tableId: String) {
        if let tableIndex = seatingArrangement.tables.firstIndex(where: { $0.id == tableId }) {
            seatingArrangement.tables[tableIndex].guests.removeAll { $0 == guestId }
            seatingArrangement.unassignedGuests.append(guestId)
        }
    }
    
    func updateTableNotes(tableId: String, notes: String) {
        if let index = seatingArrangement.tables.firstIndex(where: { $0.id == tableId }) {
            seatingArrangement.tables[index].notes = notes
        }
    }
}
