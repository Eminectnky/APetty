import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ChatView: View {
    @State private var users: [User] = []
    private let db = Firestore.firestore()
    @AppStorage("uid") var currentUserID: String = ""

    var body: some View {
        NavigationView {
            List(users) { user in
                NavigationLink(destination: ChatDetailView(contactName: user.fullName, contactImageURL: user.profileImageURL, contactID: user.id ?? "")) {
                    HStack {
                        ProfileImageView(urlString: user.profileImageURL, name: user.fullName)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(user.fullName)
                                .font(.headline)
                            Text(user.lastMessage)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Sohbetler")
            .onAppear {
                fetchUsers()
            }
        }
    }

    private func fetchUsers() {
        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching users: \(error.localizedDescription)")
            } else if let snapshot = snapshot {
                var fetchedUsers: [User] = []
                for document in snapshot.documents {
                    let data = document.data()
                    print("Fetched document data: \(data)")
                    if let fullName = data["fullName"] as? String,
                       let profileImageURL = data["profileImageURL"] as? String {
                        let lastMessage = data["lastMessage"] as? String ?? "Merhaba!"
                        let user = User(id: document.documentID, fullName: fullName, profileImageURL: profileImageURL, lastMessage: lastMessage)
                        
                        // Exclude current user
                        if user.id != currentUserID {
                            fetchedUsers.append(user)
                        }
                    } else {
                        print("Document is missing required fields: \(document.documentID)")
                        if data["fullName"] == nil { print("Missing field: fullName") }
                        if data["profileImageURL"] == nil { print("Missing field: profileImageURL") }
                    }
                }
                self.users = fetchedUsers
                print("Fetched users: \(self.users)")
            }
        }
    }
}

struct User: Identifiable {
    var id: String?
    var fullName: String
    var profileImageURL: String
    var lastMessage: String
    
    init(id: String? = nil, fullName: String = "", profileImageURL: String = "", lastMessage: String = "Merhaba!") {
        self.id = id
        self.fullName = fullName
        self.profileImageURL = profileImageURL
        self.lastMessage = lastMessage
    }
}

struct ProfileImageView: View {
    @ObservedObject var imageLoader: ImageLoader
    private let placeholderText: String

    init(urlString: String, name: String) {
        imageLoader = ImageLoader(urlString: urlString)
        placeholderText = String(name.prefix(2)).uppercased()
    }

    var body: some View {
        Group {
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Text(placeholderText)
                    .font(.headline)
                    .frame(width: 50, height: 50)
                    .background(Color.gray.opacity(0.3))
                    .clipShape(Circle())
            }
        }
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage? = nil
    private var urlString: String = ""
    private var imageCache = NSCache<NSString, UIImage>()

    init(urlString: String) {
        self.urlString = urlString
        loadImage()
    }

    private func loadImage() {
        if loadImageFromCache() {
            return
        }
        
        guard let url = URL(string: urlString) else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async {
                self.imageCache.setObject(image, forKey: self.urlString as NSString)
                self.image = image
            }
        }.resume()
    }

    private func loadImageFromCache() -> Bool {
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return true
        }
        return false
    }
}


struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
