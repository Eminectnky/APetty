import SwiftUI
import PhotosUI
import AVFoundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ChatDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var message = ""
    @State private var messages = [Message]()
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isCameraPermissionGranted = false
    @State private var currentUserProfileImageURL: String = ""
    @AppStorage("uid") var currentUserID: String = ""
    var contactName: String
    var contactImageURL: String
    var contactID: String
    
    private let db = Firestore.firestore()
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.gray)
                }
                
                HStack {
                    AsyncImage(url: URL(string: contactImageURL)) { image in
                        image.resizable()
                             .frame(width: 40, height: 40)
                             .clipShape(Circle())
                    } placeholder: {
                        ProgressView()
                            .frame(width: 40, height: 40)
                    }
                    Text(contactName)
                        .font(.headline)
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding()
            .background(Color.white)
            .shadow(radius: 1)
            
            ScrollViewReader { scrollViewProxy in
                List(messages) { msg in
                    MessageRow(message: msg, currentUserProfileImageURL: currentUserProfileImageURL, contactImageURL: contactImageURL)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .id(msg.id)
                }
                .listStyle(PlainListStyle())
                .onChange(of: messages) { _ in
                    if let lastMessage = messages.last {
                        withAnimation {
                            scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            HStack {
                TextField("Mesajınızı yazın", text: $message)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 30)
                
                Button(action: {
                    checkCameraPermission()
                }) {
                    Image(systemName: "camera")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                }
                .foregroundColor(.gray)
                .padding(.leading, 10)
                .sheet(isPresented: $isImagePickerPresented) {
                    ImagePicker(image: $selectedImage, sourceType: .camera)
                }
                
                Button(action: sendMessage) {
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color("customColor"))
                        .overlay(
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.white)
                        )
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            fetchMessages()
            fetchCurrentUserProfileImageURL()
        }
        .onChange(of: selectedImage) { newImage in
            if let image = newImage {
                sendImageMessage(image: image)
                selectedImage = nil
            }
        }
        .background(Color.white)
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
    
    private func fetchCurrentUserProfileImageURL() {
        db.collection("users").document(currentUserID).getDocument { document, error in
            if let document = document, document.exists {
                if let profileImageURL = document.data()?["profileImageURL"] as? String {
                    self.currentUserProfileImageURL = profileImageURL
                }
            } else {
                print("User document does not exist")
            }
        }
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isCameraPermissionGranted = true
            isImagePickerPresented = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.isCameraPermissionGranted = true
                        self.isImagePickerPresented = true
                    }
                }
            }
        case .denied, .restricted:
            isCameraPermissionGranted = false
            // Display an alert to the user
        @unknown default:
            isCameraPermissionGranted = false
        }
    }
    
    private func sendMessage() {
        guard !message.isEmpty else { return }
        let newMessage = Message(id: UUID().uuidString, text: message, imageURL: nil, isUserMessage: true, timestamp: Date(), isRead: false)
        let messageData: [String: Any] = [
            "id": newMessage.id,
            "text": newMessage.text ?? "",
            "timestamp": newMessage.timestamp,
            "senderID": currentUserID,
            "isRead": newMessage.isRead
        ]
        db.collection("chats").document(currentUserID).collection(contactID).addDocument(data: messageData)
        db.collection("chats").document(contactID).collection(currentUserID).addDocument(data: messageData)
        message = ""
    }
    
    private func sendImageMessage(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let storageRef = Storage.storage().reference().child("images/\(UUID().uuidString).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: metadata) { metadata, error in
            guard metadata != nil else {
                print("Error uploading image: \(String(describing: error))")
                return
            }
            
            storageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    print("Error getting download URL: \(String(describing: error))")
                    return
                }
                
                let newMessage = Message(id: UUID().uuidString, text: nil, imageURL: downloadURL.absoluteString, isUserMessage: true, timestamp: Date(), isRead: false)
                let messageData: [String: Any] = [
                    "id": newMessage.id,
                    "imageURL": newMessage.imageURL ?? "",
                    "timestamp": newMessage.timestamp,
                    "senderID": currentUserID,
                    "isRead": newMessage.isRead
                ]
                db.collection("chats").document(currentUserID).collection(contactID).addDocument(data: messageData)
                db.collection("chats").document(contactID).collection(currentUserID).addDocument(data: messageData)
            }
        }
    }
    
    private func fetchMessages() {
        db.collection("chats").document(currentUserID).collection(contactID).order(by: "timestamp").addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }
            self.messages = documents.compactMap { doc -> Message? in
                let data = doc.data()
                let id = data["id"] as? String ?? UUID().uuidString
                let text = data["text"] as? String
                let imageURL = data["imageURL"] as? String
                let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                let senderID = data["senderID"] as? String ?? ""
                let isRead = data["isRead"] as? Bool ?? false
                return Message(id: id, text: text, imageURL: imageURL, isUserMessage: senderID == currentUserID, timestamp: timestamp, isRead: isRead)
            }
        }
    }
}

struct Message: Identifiable, Hashable {
    let id: String
    let text: String?
    let imageURL: String?
    let isUserMessage: Bool
    let timestamp: Date
    let isRead: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct MessageRow: View {
    var message: Message
    var currentUserProfileImageURL: String
    var contactImageURL: String
    
    var body: some View {
        HStack {
            if !message.isUserMessage {
                Spacer()
            }
            
            VStack(alignment: message.isUserMessage ? .trailing : .leading) {
                if let text = message.text {
                    Text(text)
                        .padding(10)
                        .background(message.isUserMessage ? Color.customGreen : Color.gray.opacity(0.2))
                        .foregroundColor(message.isUserMessage ? .white : .black)
                        .cornerRadius(10)
                } else if let imageURL = message.imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                             .scaledToFit()
                             .frame(maxWidth: 200, maxHeight: 200)
                             .cornerRadius(10)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 200, height: 200)
                    }
                }
            }
            .padding(10)
            
            if message.isUserMessage {
                Spacer()
            }
        }
        .padding(.horizontal, 20) 
    }
}


