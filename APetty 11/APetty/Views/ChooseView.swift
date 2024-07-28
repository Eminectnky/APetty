import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ChooseView: View {
    @AppStorage("uid") var userID: String = ""
    @State private var navigateToAnimals = false
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
              
                    NavigationLink(destination: AnimalsView(), isActive: $navigateToAnimals) {
                        Image("animals")
                            .resizable()
                            .frame(width: 150, height: 150)
                            .onTapGesture {
                                updateUserAttribute("animals")
                            }
                    }
                    .padding()
                    
  
                    Button(action: {
                        updateUserAttribute("plants")
                    }) {
                        Image("plants")
                            .resizable()
                            .frame(width: 150, height: 150)
                    }
                    .padding()
                }
                .padding(.bottom, 100)
                .navigationTitle("Hangisine Sahipsin?")
            }
        }
    }
    
    func updateUserAttribute(_ attribute: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userID).updateData([
            "chosenAttribute": attribute
        ]) { error in
            if let error = error {
                print("Error updating document: \(error.localizedDescription)")
            } else {
                print("Document successfully updated")
                
                if attribute == "animals" {
                  
                    navigateToAnimals = true
                } else {
                    print("Seçimler kayıt olmadı")
                        }
                    }
                }
            }
        }


#Preview {
    ChooseView()
}
