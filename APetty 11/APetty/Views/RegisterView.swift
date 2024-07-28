import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RegisterView: View {
    @State private var fullName = ""
    @State private var email = ""
    @State private var blockNumber = ""
    @State private var floorNumber = ""
    @State private var password = ""
    
    @Binding var currentShowingView: String
    @AppStorage("uid") var userID: String = ""
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("Hesap Oluştur")
                        .font(.system(size: 38))
                        .bold()
                        .padding(.top, 20)
                    
                    Text("Bilgilerinizi giriniz")
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                
                VStack {
                    VStack(alignment: .leading) {
                        Text("Ad Soyad")
                            .font(.headline)
                        
                        TextField("Ad Soyad giriniz", text: $fullName)
                            .padding()
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("E mail")
                            .font(.headline)
                        
                        TextField("E mail giriniz", text: $email)
                            .padding()
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    HStack(spacing: -20) {
                        VStack(alignment: .leading) {
                            Text("Blok No")
                                .font(.headline)
                            
                            TextField("Blok giriniz", text: $blockNumber)
                                .padding()
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading) {
                            Text("Kat No")
                                .font(.headline)
                            
                            TextField("Kat giriniz", text: $floorNumber)
                                .padding()
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                        }
                        .padding(.horizontal)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Şifre")
                            .font(.headline)
                        
                        SecureField("Şifre giriniz", text: $password)
                            .padding()
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                }
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        if !fullName.isValidFullname() {
                            alertMessage = "Geçerli bir ad soyad giriniz."
                            showAlert = true
                            return
                        }
                        if !email.isValidEmail() {
                            alertMessage = "Geçerli bir e-posta adresi giriniz."
                            showAlert = true
                            return
                        }
                        if !blockNumber.isValidBlockNumber() {
                            alertMessage = "Blok numarası boş olmamalı."
                            showAlert = true
                            return
                        }
                        if !floorNumber.isValidFloorNumber() {
                            alertMessage = "Kat numarası boş olmamalı."
                            showAlert = true
                            return
                        }
                        if !password.isValidPassword() {
                            alertMessage = "Şifre minimum 6 karakter olmalı."
                            showAlert = true
                            return
                        }
                        
                  
                        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                            if let error = error {
                                alertMessage = error.localizedDescription
                                showAlert = true
                                return
                            }
                            
                            if let authResult = authResult {
                                userID = authResult.user.uid
                                saveAdditionalUserInfo(uid: authResult.user.uid, fullName: fullName, blockNumber: blockNumber, floorNumber: floorNumber)
                        
                             
                                withAnimation {
                                    self.currentShowingView = "animals"
                                }
                            }
                        }
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
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Hata"), message: Text(alertMessage), dismissButton: .default(Text("Tamam")))
                    }
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation {
                                self.currentShowingView = "login"
                            }
                        }) {
                            Text("Bir hesabınız var mı?")
                                .foregroundColor(.blue)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                withAnimation {
                                    currentShowingView = "welcome"
                                }
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
                }
            }
        }
    }
    
    func saveAdditionalUserInfo(uid: String, fullName: String, blockNumber: String, floorNumber: String) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).setData([
            "fullName": fullName,
            "blockNumber": blockNumber,
            "floorNumber": floorNumber
        ]) { error in
            if let error = error {
                print("Error saving additional user info: \(error.localizedDescription)")
            } else {
                print("Additional user info saved successfully!")
            }
        }
    }
}


