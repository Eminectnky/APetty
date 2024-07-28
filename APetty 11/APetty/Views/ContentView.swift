import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ContentView: View {
    
    @AppStorage("uid") var userID: String = ""
    @StateObject private var userManager = UserManager()
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if userID.isEmpty {
                AuthView()
            } else {
                if isLoading {
                    ProgressView("Yükleniyor...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .onAppear {
                            userManager.fetchUserData(userID: userID) {
                                isLoading = false
                            }
                        }
                } else {
                    VStack {
                        if userManager.chosenAttribute.isEmpty {
                            ChooseView()
                        } else {
                            NavigationStack {
                                if userManager.chosenAnimals.isEmpty {
                                    AnimalsView()
                                } else {
                                    MainTabView()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    class UserManager: ObservableObject {
        @Published var chosenAttribute: String = ""
        @Published var chosenAnimals: [String] = []
        
        func fetchUserData(userID: String, completion: @escaping () -> Void) {
            let db = Firestore.firestore()
            db.collection("users").document(userID).getDocument { snapshot, error in
                if let error = error {
                    print("Error fetching user data: \(error.localizedDescription)")
                } else if let data = snapshot?.data() {
                    print("Data fetched from Firestore: \(data)")
                    if let attribute = data["chosenAttribute"] as? String {
                        self.chosenAttribute = attribute
                        print("Fetched chosenAttribute: \(self.chosenAttribute)")
                    } else {
                        print("chosenAttribute is not of expected type or not found.")
                    }
                    
                    if let animals = data["chosenAnimals"] as? [String] {
                        self.chosenAnimals = animals
                        print("Fetched chosenAnimals: \(self.chosenAnimals)")
                    } else {
                        print("chosenAnimals is not of expected type or not found.")
                    }
                } else {
                    print("No data found.")
                }
                completion()
            }
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}

struct MainTabView: View {
    var body: some View {
      tabView()
    }
}
