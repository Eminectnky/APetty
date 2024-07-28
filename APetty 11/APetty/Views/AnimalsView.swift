import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct Animal: Identifiable {
    var id = UUID()
    var name: String
    var iconName: String
}

struct AnimalsView: View {

    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var animals = [
        Animal(name: "Köpek", iconName: "dog"),
        Animal(name: "Kedi", iconName: "cat"),
        Animal(name: "Kuş", iconName: "bird"),
        Animal(name: "Balık", iconName: "fish")
    ]
    @State private var selectedAnimals: Set<String> = []
    @AppStorage("uid") var userID: String = ""
    
  
    @State private var isNavigating = false

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Hayvan ara", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(8)
                    .padding(.leading, 30)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .overlay(
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .padding(.leading, 8)
                            Spacer()
                        }
                    )
                    .padding(.horizontal)
                
                List {
                    ForEach(filteredAnimals, id: \.name) { animal in
                        HStack {
                            Image(systemName: animal.iconName)
                                .foregroundColor(.blue)
                            Text(animal.name)
                            Spacer()
                            if selectedAnimals.contains(animal.name) {
                                ZStack {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 25, height: 25)
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            toggleSelection(of: animal)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .navigationTitle("Hayvanlar")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            dismiss()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color("customColor"))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                Spacer()
                
                NavigationLink(destination: RequestView(), isActive: $isNavigating) {
                    Button(action: {
                        saveSelectedAnimals()
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color("customColor"))
                                .frame(width: 100, height: 40)
                            
                            HStack {
                                Text("İleri")
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding()
                }
            }
            .padding()
        }
    }

    var filteredAnimals: [Animal] {
        if searchText.isEmpty {
            return animals
        } else {
            return animals.filter { $0.name.contains(searchText) }
        }
    }

    func toggleSelection(of animal: Animal) {
        if selectedAnimals.contains(animal.name) {
            selectedAnimals.remove(animal.name)
        } else {
            selectedAnimals.insert(animal.name)
        }
    }

    func saveSelectedAnimals() {
        guard !selectedAnimals.isEmpty else {
            print("No animals selected.")
            return
        }
        
        let db = Firestore.firestore()
        let selectedAnimalNames = Array(selectedAnimals)
        
        db.collection("users").document(userID).updateData([
            "chosenAnimals": selectedAnimalNames
        ]) { error in
            if let error = error {
                print("Error updating document: \(error.localizedDescription)")
            } else {
                print("Document successfully updated")
                isNavigating = true
            }
        }
    }
}


#Preview {
    AnimalsView()
}
