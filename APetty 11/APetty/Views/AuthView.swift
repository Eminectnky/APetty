import SwiftUI

struct AuthView: View {
    @State private var currentViewShowing: String = "welcome"
        
    var body: some View {
        
        if currentViewShowing == "login" {
            LoginView(currentShowingView: $currentViewShowing)
                .transition(.move(edge: .trailing))
                .preferredColorScheme(.light)
        } else if currentViewShowing == "register" {
            RegisterView(currentShowingView: $currentViewShowing)
                .preferredColorScheme(.light)
                .transition(.move(edge: .trailing))
        } else {
            WelcomeView(currentShowingView: $currentViewShowing)
                .preferredColorScheme(.light)
                
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
