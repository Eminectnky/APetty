import SwiftUI

struct WelcomeView: View {
    @Binding var currentShowingView: String

    var body: some View {
        NavigationStack {
            ZStack {
                GeometryReader { geometry in
                    LinearGradient(gradient: Gradient(colors: [.customGreen, .white]),
                                   startPoint: .top,
                                   endPoint: .bottom)
                    .frame(width: geometry.size.width * 2, height: 410)
                    .rotationEffect(Angle(degrees: -22))
                    .position(x: geometry.size.width / 2, y: geometry.size.height + 10)
                    
                    Image("welcome")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 250, height: 250)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2 - 70)
                    
                    Button(action: {
                        withAnimation {
                            self.currentShowingView = "login"
                        }
                    }) {
                        Text("Giriş Yap")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(30)
                            .bold()
                    }
                    .padding(.horizontal)
                    .padding(.top, 230)
                    
                    Button(action: {
                        withAnimation {
                            self.currentShowingView = "register"
                        }
                    }) {
                        Text("Kayıt Ol")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(30)
                            .bold()
                    }
                    .padding(.horizontal)
                    .padding(.top, 300)
                    
                    Spacer()
                }
                .frame(height: 300)
            }
            .navigationTitle("")
            .navigationBarBackButtonHidden(true)
            .edgesIgnoringSafeArea(.all)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
    }
}

#Preview {
    WelcomeView(currentShowingView: .constant("welcome"))
}
