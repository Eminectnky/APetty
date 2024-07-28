import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoggedIn = false
    
    @Binding var currentShowingView: String
    @AppStorage("uid") var userID: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("APetty")
                    .font(.system(size: 50))
                    .bold()
                
                VStack(alignment: .leading) {
                    Text("E mail")
                        .font(.headline)
                    TextField("E mail girin", text: $email)
                        .padding()
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.black, lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                VStack(alignment: .leading) {
                    Text("Şifre")
                        .font(.headline)
                    SecureField("Şifre girin", text: $password)
                        .padding()
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.black, lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Button {
                    Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                        if let error = error {
                            alertMessage = "Hatalı e-mail veya şifre"
                            showAlert = true
                            print(error.localizedDescription)
                            return
                        }
                        
                        if let authResult = authResult {
                            print(authResult.user.uid)
                            withAnimation {
                                userID = authResult.user.uid
                                isLoggedIn = true
                            }
                        }
                    }
                } label: {
                    Text("Giriş Yap")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.customGreen)
                        .foregroundColor(.white)
                        .cornerRadius(30)
                }
                .padding(.horizontal)
                .padding(.top, 15)
                
                Spacer()
                
                Text("Buralarda yeni misin?")
                
                Button(action: {
                    withAnimation {
                        currentShowingView = "register"
                    }
                }) {
                    Text("Hesap oluştur")
                        .foregroundColor(.blue)
                }
                
     
                if isLoggedIn {
                    WelcomeView(currentShowingView: $currentShowingView)
                        .transition(.opacity)
                        .navigationBarBackButtonHidden(true)
                }
            }
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
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Hata"), message: Text(alertMessage), dismissButton: .default(Text("Tamam")))
            }
        }
    }
}
