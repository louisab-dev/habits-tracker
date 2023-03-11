//
//  ContentView.swift
//  habit-tracker
//
//  Created by Louis AB on 27/02/2023.
//

import GoTrue
import SafariServices
import Supabase
import SwiftUI

struct SafariView: UIViewControllerRepresentable {
    @Binding var url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {}
}

struct LoginView: View {
    @EnvironmentObject var model: Model

    let client = SupabaseClient(supabaseURL: URL(string: Constants.supabaseUrl)!,
                                supabaseKey: Constants.supabaseKey)

    @State private var url: URL = .init(string: "https://randomUrl")!
    @State private var showSignup: Bool = false

    func loginInWithApple() {
        Task {
            do {
                url = try client.auth.getOAuthSignInURL(provider: Provider.apple, redirectTo: URL(string: "habits://auth-callback")!)
                model.showSafari = true
            } catch {
                print("### Google Sign in Error: \(error)")
            }
        }
    }

    func loginClassic(email: String, password: String, completion: @escaping (Bool, String) -> Void) {
        Task {
            do {
                try await client.auth.signIn(email: email, password: password)
                _ = try await client.auth.session
                model.loggedIn = true
                completion(true, "")
            } catch {
                print("### Login Error: \(error)")
                completion(false, error.localizedDescription)
            }
        }
    }

    func signupClassic(email: String, password: String, completion: @escaping (Bool, String) -> Void) {
        Task {
            do {
                try await client.auth.signUp(email: email, password: password)
                completion(true, "")
            } catch {
                print("### Sign Up Error: \(error)")
                completion(false, error.localizedDescription)
            }
        }
    }

    var body: some View {
        ZStack {
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .foregroundColor(Color("Background"))

            VStack {
                Spacer()

                if showSignup {
                    SignupClassic(signupClassic: signupClassic)
                } else {
                    LoginClassic(loginClassic: loginClassic)
                }

                Divider()
                    .padding(.horizontal)

                LoginInWithApple(loginInWithApple: loginInWithApple)

                Spacer()

                Button(action: {
                    showSignup = !showSignup
                }) {
                    if showSignup {
                        Text("Already have an account? Log in")
                    } else {
                        Text("Don't have an account? Sign up")
                    }
                }
                .accentColor(.white)
            }
            .sheet(isPresented: $model.showSafari) {
                SafariView(url: $url)
            }
            .padding()
        }
    }
}

struct LoginClassic: View {
    let loginClassic: (String, String, @escaping (Bool, String) -> Void) -> Void

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var error: String = ""
    @State private var success: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 5) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Email")
                        .font(.footnote)
                        .padding(.leading)
                        .foregroundColor(.white)

                        .padding(.top)
                    TextField("", text: $email)
                        .disableAutocorrection(true)
                        .foregroundColor(.white)
                        .frame(height: 50, alignment: .center)
                        .padding(.leading)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color("Purple"), lineWidth: 1)
                                .foregroundColor(.orange)
                        )
                        .padding(.horizontal)
                        .padding(.top, 2)
                        .autocapitalization(/*@START_MENU_TOKEN@*/ .none/*@END_MENU_TOKEN@*/)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("Password")
                        .font(.footnote)
                        .padding(.leading)
                        .foregroundColor(.white)

                        .padding(.top)
                    SecureField("", text: $password)
                        .disableAutocorrection(true)
                        .foregroundColor(.white)
                        .frame(height: 50, alignment: .center)
                        .padding(.leading)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color("Purple"), lineWidth: 1)
                                .foregroundColor(.orange)
                        )
                        .padding(.horizontal)
                        .padding(.top, 2)
                        .autocapitalization(/*@START_MENU_TOKEN@*/ .none/*@END_MENU_TOKEN@*/)
                }
            }

            if error != "" {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            } else if success {
                Text("Login success")
                    .foregroundColor(.green)
            }

            Button(action: {
                loginClassic(email, password) { successResult, errorMessage in
                    if successResult {
                        // Handle successful signup
                        success = true
                    } else {
                        // Handle signup error
                        error = errorMessage
                    }
                }
            }) {
                Text("Login")
                    .foregroundColor(.black)
            }
            .padding(.vertical)
            .accentColor(.white)
            .background(
                Rectangle()
                    .frame(width: 150)
                    .cornerRadius(15)
                    .foregroundColor(.white)
            )
        }
        .padding(.vertical)
        .background(
            Rectangle()
                .frame(maxWidth: .infinity)
                .foregroundColor(Color("Gray2"))
                .cornerRadius(15)
        )
    }
}

struct SignupClassic: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var success: Bool = false
    @State private var error: String = ""

    let signupClassic: (String, String, @escaping (Bool, String) -> Void) -> Void

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 5) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Email")
                        .font(.footnote)
                        .padding(.leading)
                        .foregroundColor(.white)

                        .padding(.top)
                    TextField("", text: $email)
                        .disableAutocorrection(true)
                        .foregroundColor(.white)
                        .frame(height: 50, alignment: .center)
                        .padding(.leading)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color("Purple"), lineWidth: 1)
                                .foregroundColor(.orange)
                        )
                        .padding(.horizontal)
                        .padding(.top, 2)
                        .autocapitalization(/*@START_MENU_TOKEN@*/ .none/*@END_MENU_TOKEN@*/)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("Password")
                        .font(.footnote)
                        .padding(.leading)
                        .foregroundColor(.white)

                        .padding(.top)
                    SecureField("", text: $password)
                        .disableAutocorrection(true)
                        .foregroundColor(.white)
                        .frame(height: 50, alignment: .center)
                        .padding(.leading)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color("Purple"), lineWidth: 1)
                                .foregroundColor(.orange)
                        )
                        .padding(.horizontal)
                        .padding(.top, 2)
                        .autocapitalization(/*@START_MENU_TOKEN@*/ .none/*@END_MENU_TOKEN@*/)
                }
            }

            if error != "" {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            } else if success {
                Text("Account created, confirm it by clicking the link sent to your email")
                    .foregroundColor(.green)
                    .padding(.horizontal)
            }

            Button(action: {
                signupClassic(email, password) { successResult, errorMessage in
                    if successResult {
                        // Handle successful signup
                        success = true
                    } else {
                        // Handle signup error
                        error = errorMessage
                    }
                }
            }) {
                Text("Create account")
                    .foregroundColor(.black)
            }
            .padding(.vertical)
            .accentColor(.white)
            .background(
                Rectangle()
                    .frame(width: 150)
                    .cornerRadius(15)
                    .foregroundColor(.white)
            )
        }
        .padding(.vertical)
        .background(
            Rectangle()
                .frame(maxWidth: .infinity)
                .foregroundColor(Color("Gray2"))
                .cornerRadius(15)
        )
    }
}

struct LoginInWithApple: View {
    let loginInWithApple: () -> Void

    var body: some View {
        Button(action: loginInWithApple) {
            HStack {
                HStack {
                    Image(systemName: "apple.logo")
                        .foregroundColor(.white)
                    Text("Sign in with Apple")
                        .foregroundColor(.white)
                }
            }
            .frame(height: 40)
            .padding(.horizontal)
            .background(
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .cornerRadius(15)
                    .foregroundColor(.black)
            )
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(Model())
    }
}
