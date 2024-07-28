import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct Request: Identifiable {
    let id: String
    let name: String
    let description: String
    let fullName: String
}

struct RequestView: View {
    @State private var searchText = ""
    @State private var newNameText = ""
    @State private var newDescriptionText = ""
    @State private var requests: [Request] = []
    @State private var showNewRequestAlert = false

    private let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            VStack(spacing: 8) {
                TextField("Bir evcil hayvan veya bitki arayın", text: $searchText)
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
                    ForEach(requests) { request in
                        ZStack {
                            Color(.systemGray5)
                                .cornerRadius(10)
                        
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(request.fullName)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .padding([.leading, .top])
                                        Text(request.name)
                                            .bold()
                                            .font(.title3)
                                            .padding([.leading])
                                        Text(request.description)
                                            .padding([.leading, .bottom])
                                    }
                                    .padding(.leading, 8)
                                    Spacer()
                                }
                            
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: deleteRequest)
                }
                .listStyle(PlainListStyle())

                Spacer()
            }
            .navigationTitle("Talepler")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showNewRequestAlert = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 40, height: 40)
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .alert("Yeni Talep", isPresented: $showNewRequestAlert, actions: {
                TextField("Başlık", text: $newNameText)
                TextField("Açıklama", text: $newDescriptionText)
                Button("Vazgeç", role: .cancel, action: {
                    newNameText = ""
                    newDescriptionText = ""
                })
                Button("Ekle", action: {
                    if !newNameText.isEmpty && !newDescriptionText.isEmpty {
                        addRequest(name: newNameText, description: newDescriptionText)
                        newNameText = ""
                        newDescriptionText = ""
                    }
                })
            }, message: {
                Text("Bir talep girin...")
            })
            .onAppear {
                fetchRequests()
            }
        }
    }

    func addRequest(name: String, description: String) {
        // Get the user's full name from Firestore
        db.collection("users").document(Auth.auth().currentUser?.uid ?? "").getDocument { document, error in
            if let document = document, document.exists {
                let userData = document.data()
                let fullName = userData?["fullName"] as? String ?? "Unknown"
                
                let requestData: [String: Any] = [
                    "name": name,
                    "description": description,
                    "fullName": fullName,
                    "timestamp": Timestamp()
                ]
                
                db.collection("requests").addDocument(data: requestData) { error in
                    if let error = error {
                        print("Error adding request: \(error.localizedDescription)")
                    } else {
                        print("Request successfully added to Firestore")
                        fetchRequests()
                    }
                }
            } else {
                print("User document does not exist")
            }
        }
    }
    
    func deleteRequest(at offsets: IndexSet) {
        offsets.forEach { index in
            let request = requests[index]
            requests.remove(at: index)
            
            db.collection("requests").document(request.id).delete { error in
                if let error = error {
                    print("Error deleting request document: \(error.localizedDescription)")
                } else {
                    print("Request document successfully deleted from Firestore")
                }
            }
        }
    }

    func fetchRequests() {
        db.collection("requests").order(by: "timestamp").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching requests: \(error.localizedDescription)")
            } else {
                requests = snapshot?.documents.compactMap { document in
                    let data = document.data()
                    let id = document.documentID
                    let name = data["name"] as? String ?? ""
                    let description = data["description"] as? String ?? ""
                    let fullName = data["fullName"] as? String ?? "Unknown"
                    return Request(id: id, name: name, description: description, fullName: fullName)
                } ?? []
                print("Fetched requests: \(requests)") 
            }
        }
    }
}

struct RequestView_Previews: PreviewProvider {
    static var previews: some View {
        RequestView()
    }
}
