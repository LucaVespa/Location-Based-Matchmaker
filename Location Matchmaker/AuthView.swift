//
//  AuthView.swift
//  Location Matchmaker
//
//  Created by Owner on 8/7/23.
//
import FirebaseAuth
import SwiftUI

struct AuthView: View {
    @State var email = ""
    @State var password = ""
    @State var errorMsg = " "
    @State var userIsLoggedIn = false
    @State var navigateToMain = false
    @State var isEmailVerified = false
    
    var body: some View {
        
        VStack {
            Spacer()
            Image("pinIcon").resizable().frame(width: 200, height: 300)
            
            TextField("", text: $email).frame(width: 300.0, height: 30.0).background(Color.white).multilineTextAlignment(.center).submitLabel(.done).foregroundColor(.black).overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray)).cornerRadius(8).overlay(
                Text("Enter your email").foregroundColor(.gray).opacity(email.isEmpty ? 1 : 0)
            )
            TextField("", text: $password).frame(width: 300.0, height: 30.0).background(Color.white).multilineTextAlignment(.center).submitLabel(.done).foregroundColor(.black).cornerRadius(8).overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray)).cornerRadius(8).overlay(
                Text("Enter your password").foregroundColor(.gray).opacity(password.isEmpty ? 1 : 0)
            )
            Text("\(errorMsg)").multilineTextAlignment(.center).font(.system(size: 10))
            Spacer()
            HStack{
                Spacer()
                Button{
                    register()
                } label:{ Text("Register")}
                    .padding(.horizontal).padding(.vertical).background(Color.red).foregroundColor(.white).bold().cornerRadius(8)
                Spacer()
                Button{
                    login()
                } label:{ Text(" Login  ")}
                    .padding(.horizontal).padding(.vertical).background(Color.red).foregroundColor(.white).bold().cornerRadius(8)
                Spacer()
            }
            
            Spacer()
            Spacer()

        }.ignoresSafeArea(.keyboard, edges: .vertical).onAppear {
            if Auth.auth().currentUser != nil {
                        navigateToMain = true
                    } else {
                        resetValues()
                    }
        }.background(
            NavigationLink(destination: MainView(), isActive: $navigateToMain, label: {EmptyView()})).background(Color.white).edgesIgnoringSafeArea(.all).preferredColorScheme(.light)
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    print(error.localizedDescription)
                    errorMsg = error.localizedDescription
                } else if let user = result?.user {
                    if user.isEmailVerified {
                        navigateToMain = true
                    } else {
                        errorMsg = "Please verify your email before logging in."
                    }
                }
            }
    }
    
    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    if let error = error {
                        print(error.localizedDescription)
                        errorMsg = error.localizedDescription
                    } else if let user = result?.user {
                        sendVerificationEmail(to: user)
                    }
                }
    }

    func sendVerificationEmail(to user: User) {
        user.sendEmailVerification { error in
            if let error = error {
                errorMsg = "Error sending verification email. Please try again later."
            } else {
                errorMsg = "Verification email sent. Please check your inbox and verify your email."
            }
        }
    }
        
    func resetValues() {
        email = ""
        password = ""
        errorMsg = " "
        userIsLoggedIn = false
        navigateToMain = false
        isEmailVerified = false
    }
    
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
