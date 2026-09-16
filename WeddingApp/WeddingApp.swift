import SwiftUI
import Firebase

@main
struct WeddingApp: App {
    @StateObject private var guestListVM = GuestListViewModel()
    @StateObject private var budgetVM = BudgetViewModel()
    @StateObject private var timelineVM = TimelineViewModel()
    @StateObject private var photoVM = PhotoViewModel()
    @StateObject private var chatVM = ChatViewModel()
    @StateObject private var seatingVM = SeatingViewModel()
    
    @State private var isLoggedIn = false
    @State private var isLoading = true
    
    init() {
        // Configure Firebase
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                ContentView()
                    .environmentObject(guestListVM)
                    .environmentObject(budgetVM)
                    .environmentObject(timelineVM)
                    .environmentObject(photoVM)
                    .environmentObject(chatVM)
                    .environmentObject(seatingVM)
                    .onAppear {
                        loadWeddingData()
                    }
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
            }
        }
    }
    
    // MARK: - Load Wedding Data
    private func loadWeddingData() {
        Task {
            do {
                // Load all data from Firebase
                let guests = try await FirestoreService.shared.fetchGuests()
                DispatchQueue.main.async {
                    self.guestListVM.guests = guests
                }
                
                let budgetItems = try await FirestoreService.shared.fetchBudgetItems()
                DispatchQueue.main.async {
                    self.budgetVM.budgetItems = budgetItems
                }
                
                let timelineEvents = try await FirestoreService.shared.fetchTimelineEvents()
                DispatchQueue.main.async {
                    self.timelineVM.events = timelineEvents
                }
                
                let photos = try await FirestoreService.shared.fetchPhotos()
                DispatchQueue.main.async {
                    self.photoVM.photos = photos
                }
                
                let messages = try await FirestoreService.shared.fetchMessages()
                DispatchQueue.main.async {
                    self.chatVM.messages = messages
                }
                
                let seatingArrangement = try await FirestoreService.shared.fetchSeatingArrangement()
                DispatchQueue.main.async {
                    self.seatingVM.seatingArrangement = seatingArrangement
                }
                
                // Log analytics
                AnalyticsService.shared.logEvent(name: "app_opened")
                
            } catch {
                print("Error loading data: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Login View
struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var isSigningUp = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.pink)
                    
                    Text("Wedding Planner")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Plan your perfect day")
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 30)
                
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                }
                
                Button(action: handleLogin) {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(isSigningUp ? "Sign Up" : "Sign In")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isLoading || email.isEmpty || password.isEmpty)
                
                Button(action: { isSigningUp.toggle() }) {
                    Text(isSigningUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Welcome")
        }
    }
    
    private func handleLogin() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                if isSigningUp {
                    _ = try await AuthService.shared.signUp(email: email, password: password)
                    AnalyticsService.shared.logEvent(name: "user_signed_up")
                } else {
                    _ = try await AuthService.shared.signIn(email: email, password: password)
                    AnalyticsService.shared.logEvent(name: "user_signed_in")
                }
                
                DispatchQueue.main.async {
                    isLoading = false
                    isLoggedIn = true
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    WeddingApp()
}
