import SwiftUI

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var guestListVM = GuestListViewModel()
    @StateObject private var budgetVM = BudgetViewModel()
    @StateObject private var timelineVM = TimelineViewModel()
    @StateObject private var photoVM = PhotoViewModel()
    @StateObject private var chatVM = ChatViewModel()
    @StateObject private var seatingVM = SeatingViewModel()
    
    var body: some View {
        TabView {
            // Dashboard
            DashboardView(
                guestListVM: guestListVM,
                budgetVM: budgetVM,
                timelineVM: timelineVM
            )
            .tabItem {
                Label("Dashboard", systemImage: "house.fill")
            }
            
            // Guests
            GuestListView(viewModel: guestListVM)
                .tabItem {
                    Label("Guests", systemImage: "person.2.fill")
                }
            
            // Budget
            BudgetView(viewModel: budgetVM)
                .tabItem {
                    Label("Budget", systemImage: "dollarsign.circle.fill")
                }
            
            // Timeline
            TimelineView(viewModel: timelineVM)
                .tabItem {
                    Label("Timeline", systemImage: "calendar")
                }
            
            // Photos
            PhotoGalleryView(viewModel: photoVM)
                .tabItem {
                    Label("Photos", systemImage: "photo.fill")
                }
            
            // Chat
            ChatView(viewModel: chatVM)
                .tabItem {
                    Label("Chat", systemImage: "bubble.left.fill")
                }
            
            // Seating
            SeatingView(viewModel: seatingVM)
                .tabItem {
                    Label("Seating", systemImage: "square.grid.2x2")
                }
        }
    }
}

// MARK: - Dashboard View
struct DashboardView: View {
    @ObservedObject var guestListVM: GuestListViewModel
    @ObservedObject var budgetVM: BudgetViewModel
    @ObservedObject var timelineVM: TimelineViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Wedding Dashboard")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    // RSVP Status Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("RSVP Status")
                            .font(.headline)
                        
                        HStack(spacing: 20) {
                            StatCard(
                                title: "Accepted",
                                count: guestListVM.acceptedCount,
                                color: .green
                            )
                            StatCard(
                                title: "Pending",
                                count: guestListVM.pendingCount,
                                color: .blue
                            )
                            StatCard(
                                title: "Declined",
                                count: guestListVM.declinedCount,
                                color: .red
                            )
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Budget Overview
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Budget Overview")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Total Budget:")
                                Spacer()
                                Text("$\(String(format: "%.2f", budgetVM.totalBudget))")
                                    .fontWeight(.bold)
                            }
                            
                            HStack {
                                Text("Paid:")
                                Spacer()
                                Text("$\(String(format: "%.2f", budgetVM.totalPaid))")
                                    .foregroundColor(.green)
                            }
                            
                            HStack {
                                Text("Remaining:")
                                Spacer()
                                Text("$\(String(format: "%.2f", budgetVM.totalRemaining))")
                                    .foregroundColor(.orange)
                            }
                            
                            ProgressView(value: budgetVM.percentagePaid / 100)
                                .padding(.top, 8)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Upcoming Events
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Upcoming Tasks")
                            .font(.headline)
                        
                        if timelineVM.upcomingEvents.isEmpty {
                            Text("No upcoming events")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(timelineVM.upcomingEvents.prefix(3)) { event in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(event.title)
                                            .fontWeight(.semibold)
                                        Text(event.date, style: .date)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Image(systemName: "checkmark.circle")
                                        .foregroundColor(.blue)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("Wedding Planning")
        }
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(String(count))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }
}

// MARK: - Guest List View
struct GuestListView: View {
    @ObservedObject var viewModel: GuestListViewModel
    @State private var showingAddGuest = false
    @State private var selectedGuest: Guest?
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.guests.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.2")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No Guests Yet")
                            .font(.headline)
                        
                        Text("Add your first guest to get started")
                            .foregroundColor(.gray)
                    }
                } else {
                    List {
                        ForEach(viewModel.guests) { guest in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(guest.name)
                                    .fontWeight(.semibold)
                                
                                HStack(spacing: 12) {
                                    Label(guest.email, systemImage: "envelope")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    Spacer()
                                    
                                    Text(guest.rsvpStatus.rawValue)
                                        .font(.caption2)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(statusColor(guest.rsvpStatus))
                                        .cornerRadius(4)
                                        .foregroundColor(.white)
                                }
                            }
                            .onTapGesture {
                                selectedGuest = guest
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.deleteGuest(viewModel.guests[index])
                            }
                        }
                    }
                }
            }
            .navigationTitle("Guest List (\(viewModel.guests.count))")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddGuest = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddGuest) {
                AddGuestView(viewModel: viewModel)
            }
        }
    }
    
    func statusColor(_ status: Guest.RSVPStatus) -> Color {
        switch status {
        case .accepted:
            return .green
        case .declined:
            return .red
        case .pending:
            return .blue
        case .maybeAttending:
            return .orange
        }
    }
}

// MARK: - Add Guest View
struct AddGuestView: View {
    @ObservedObject var viewModel: GuestListViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var numberOfGuests = 1
    
    var body: some View {
        NavigationView {
            Form {
                Section("Guest Details") {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                    TextField("Phone", text: $phone)
                    Stepper("Number of Guests: \(numberOfGuests)", value: $numberOfGuests, in: 1...10)
                }
            }
            .navigationTitle("Add Guest")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let newGuest = Guest(
                            id: UUID().uuidString,
                            name: name,
                            email: email,
                            phone: phone,
                            numberOfGuests: numberOfGuests
                        )
                        viewModel.addGuest(newGuest)
                        dismiss()
                    }
                    .disabled(name.isEmpty || email.isEmpty)
                }
            }
        }
    }
}

// MARK: - Budget View
struct BudgetView: View {
    @ObservedObject var viewModel: BudgetViewModel
    @State private var showingAddItem = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.budgetItems.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "dollarsign.circle")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No Budget Items")
                            .font(.headline)
                        
                        Text("Start tracking your wedding expenses")
                            .foregroundColor(.gray)
                    }
                } else {
                    List {
                        Section("Budget Summary") {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Total:")
                                    Spacer()
                                    Text("$\(String(format: "%.2f", viewModel.totalBudget))")
                                        .fontWeight(.bold)
                                }
                                
                                HStack {
                                    Text("Paid:")
                                    Spacer()
                                    Text("$\(String(format: "%.2f", viewModel.totalPaid))")
                                        .foregroundColor(.green)
                                }
                                
                                HStack {
                                    Text("Remaining:")
                                    Spacer()
                                    Text("$\(String(format: "%.2f", viewModel.totalRemaining))")
                                        .foregroundColor(.orange)
                                }
                                
                                ProgressView(value: viewModel.percentagePaid / 100)
                            }
                            .padding(.vertical, 8)
                        }
                        
                        Section("Expenses") {
                            ForEach(viewModel.budgetItems) { item in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.category.rawValue)
                                            .fontWeight(.semibold)
                                        Text(item.description)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("$\(String(format: "%.2f", item.amount))")
                                            .fontWeight(.semibold)
                                        Text(item.isPaid ? "Paid" : "Pending")
                                            .font(.caption2)
                                            .foregroundColor(item.isPaid ? .green : .orange)
                                    }
                                }
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    viewModel.deleteBudgetItem(viewModel.budgetItems[index])
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Budget")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddItem = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddBudgetItemView(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Add Budget Item View
struct AddBudgetItemView: View {
    @ObservedObject var viewModel: BudgetViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var category: BudgetItem.BudgetCategory = .venue
    @State private var description = ""
    @State private var amount = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Budget Item") {
                    Picker("Category", selection: $category) {
                        ForEach(BudgetItem.BudgetCategory.allCases, id: \.self) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    
                    TextField("Description", text: $description)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        if let amountDouble = Double(amount), !description.isEmpty {
                            let newItem = BudgetItem(
                                id: UUID().uuidString,
                                category: category,
                                description: description,
                                amount: amountDouble
                            )
                            viewModel.addBudgetItem(newItem)
                            dismiss()
                        }
                    }
                    .disabled(amount.isEmpty || description.isEmpty)
                }
            }
        }
    }
}

// MARK: - Timeline View
struct TimelineView: View {
    @ObservedObject var viewModel: TimelineViewModel
    @State private var showingAddEvent = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Upcoming") {
                    if viewModel.upcomingEvents.isEmpty {
                        Text("No upcoming events")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(viewModel.upcomingEvents) { event in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(event.title)
                                        .fontWeight(.semibold)
                                    Text(event.date, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: event.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(event.isCompleted ? .green : .blue)
                            }
                        }
                    }
                }
                
                Section("Completed") {
                    if viewModel.completedEvents.isEmpty {
                        Text("No completed events")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(viewModel.completedEvents) { event in
                            HStack {
                                Text(event.title)
                                    .strikethrough()
                                    .foregroundColor(.gray)
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Timeline")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddEvent = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                AddTimelineEventView(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Add Timeline Event View
struct AddTimelineEventView: View {
    @ObservedObject var viewModel: TimelineViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var date = Date()
    @State private var category: TimelineEvent.TimelineCategory = .planning
    
    var body: some View {
        NavigationView {
            Form {
                Section("Event Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    Picker("Category", selection: $category) {
                        ForEach(TimelineEvent.TimelineCategory.allCases, id: \.self) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                }
            }
            .navigationTitle("Add Event")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        if !title.isEmpty {
                            let newEvent = TimelineEvent(
                                id: UUID().uuidString,
                                title: title,
                                description: description,
                                date: date,
                                category: category
                            )
                            viewModel.addEvent(newEvent)
                            dismiss()
                        }
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

// MARK: - Photo Gallery View
struct PhotoGalleryView: View {
    @ObservedObject var viewModel: PhotoViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section("Albums") {
                    ForEach(viewModel.albums, id: \.self) { album in
                        NavigationLink(destination: AlbumDetailView(viewModel: viewModel, albumName: album)) {
                            HStack {
                                Text(album)
                                Spacer()
                                Text("\(viewModel.photosByAlbum(album).count)")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Photos")
        }
    }
}

// MARK: - Album Detail View
struct AlbumDetailView: View {
    @ObservedObject var viewModel: PhotoViewModel
    let albumName: String
    
    var photos: [WeddingPhoto] {
        viewModel.photosByAlbum(albumName)
    }
    
    var body: some View {
        VStack {
            if photos.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "photo")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("No Photos Yet")
                        .font(.headline)
                    
                    Text("Add your first wedding photo")
                        .foregroundColor(.gray)
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                        ForEach(photos) { photo in
                            VStack {
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.blue)
                                    .frame(height: 150)
                                    .frame(maxWidth: .infinity)
                                    .background(Color(.systemGray6))
                                
                                if !photo.caption.isEmpty {
                                    Text(photo.caption)
                                        .font(.caption)
                                        .lineLimit(2)
                                        .padding(.vertical, 8)
                                }
                            }
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(albumName)
    }
}

// MARK: - Chat View
struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel
    @State private var messageText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.messages.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No Messages")
                            .font(.headline)
                        
                        Text("Start chatting with your guests")
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                HStack(alignment: .top, spacing: 12) {
                                    if message.senderId == viewModel.currentUserId {
                                        Spacer()
                                    }
                                    
                                    VStack(alignment: message.senderId == viewModel.currentUserId ? .trailing : .leading) {
                                        Text(message.senderName)
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                        
                                        Text(message.message)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(message.senderId == viewModel.currentUserId ? Color.blue : Color(.systemGray6))
                                            .foregroundColor(message.senderId == viewModel.currentUserId ? .white : .black)
                                            .cornerRadius(12)
                                    }
                                    
                                    if message.senderId != viewModel.currentUserId {
                                        Spacer()
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
                
                HStack(spacing: 12) {
                    TextField("Message", text: $messageText)
                        .textFieldStyle(.roundedBorder)
                    
                    Button(action: {
                        if !messageText.isEmpty {
                            let newMessage = ChatMessage(
                                id: UUID().uuidString,
                                senderId: viewModel.currentUserId,
                                senderName: "You",
                                message: messageText
                            )
                            viewModel.addMessage(newMessage)
                            messageText = ""
                        }
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
            }
            .navigationTitle("Chat")
        }
    }
}

// MARK: - Seating View
struct SeatingView: View {
    @ObservedObject var viewModel: SeatingViewModel
    @State private var showingAddTable = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.seatingArrangement.tables.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No Tables Yet")
                            .font(.headline)
                        
                        Text("Create your seating arrangement")
                            .foregroundColor(.gray)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(viewModel.seatingArrangement.tables) { table in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Table \(table.tableNumber)")
                                        .fontWeight(.semibold)
                                    
                                    Text("Guests: \(table.guests.count)/\(table.capacity)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    if !table.notes.isEmpty {
                                        Text(table.notes)
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    ProgressView(value: Double(table.guests.count) / Double(table.capacity))
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Seating Arrangement")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTable = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddTable) {
                AddTableView(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Add Table View
struct AddTableView: View {
    @ObservedObject var viewModel: SeatingViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var tableNumber = 1
    @State private var capacity = 8
    
    var body: some View {
        NavigationView {
            Form {
                Section("Table Details") {
                    Stepper("Table Number: \(tableNumber)", value: $tableNumber, in: 1...100)
                    Stepper("Capacity: \(capacity)", value: $capacity, in: 1...20)
                }
            }
            .navigationTitle("Add Table")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let newTable = Table(
                            id: UUID().uuidString,
                            tableNumber: tableNumber,
                            capacity: capacity
                        )
                        viewModel.addTable(newTable)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
