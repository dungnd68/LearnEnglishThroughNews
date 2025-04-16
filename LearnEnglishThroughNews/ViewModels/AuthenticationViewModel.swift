import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Foundation
import GoogleSignIn
import GoogleSignInSwift

enum AuthenticationState {
    case unauthenticated
    case authenticating
    case authenticated
}

enum AuthenticationFlow {
    case login
    case signUp
}

@MainActor
class AuthenticationViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var flow: AuthenticationFlow = .login
    @Published var isValid: Bool = false
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var errorMessage: String = ""
    @Published var user: User?
    @Published var displayName: String = ""
    
    let db = Firestore.firestore()

    init() {
        registerAuthStateHandler()

        $flow // nếu kh rỗng, isValid = true
            .combineLatest($email, $password, $confirmPassword)
            .map { flow, email, password, confirmPassword in
                flow == .login
                    ? !(email.isEmpty || password.isEmpty)
                    : !(email.isEmpty || password.isEmpty
                        || confirmPassword.isEmpty)
            }
            .assign(to: &$isValid)
    }

    private var authStateHandler: AuthStateDidChangeListenerHandle?

    func registerAuthStateHandler() {
        if authStateHandler == nil {
            authStateHandler = Auth.auth().addStateDidChangeListener {
                auth, user in
                self.user = user
                self.authenticationState = user == nil ? .unauthenticated : .authenticated
                self.displayName = user?.email ?? ""
            }
        }
    }

    func switchFlow() {
        flow = flow == .login ? .signUp : .login
        errorMessage = ""
    }

    private func wait() async {
        do {
            print("Wait")
            try await Task.sleep(nanoseconds: 1_000_000_000)
            print("Done")
        } catch {}
    }

    func reset() {
        flow = .login
        email = ""
        password = ""
        confirmPassword = ""
    }
}

extension AuthenticationViewModel {
    func signInWithEmailPassword() async -> Bool {
        authenticationState = .authenticating
        do {
            try await Auth.auth().signIn(withEmail: self.email, password: self.password)
            return true
        } catch {
            print(error)
            errorMessage = error.localizedDescription
            authenticationState = .unauthenticated
            return false
        }
    }

    func signUpWithEmailPassword() async -> Bool {
        authenticationState = .authenticating
        do {
            let authResult = try await Auth.auth().createUser(
                withEmail: email, password: password)
            let user = authResult.user
            
            let userData: [String: Any] = [
                "id": user.uid,
                "email": user.email ?? "",
//                "name": "",
//                "created_at": "",
//                "updated_at": "",
//                "deleted_at": "",
            ]
            print(userData)
            try await db.collection("ql_uid").document(user.uid).setData(userData)
            authenticationState = .authenticated
            return true
        } catch {
            print("Lỗi đăng ký: \(error)")
            errorMessage = error.localizedDescription
            authenticationState = .unauthenticated
            return false
        }
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
            errorMessage = error.localizedDescription
        }
    }

    func deleteAccount() async -> Bool {
        do {
            try await user?.delete()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}

enum AuthenticationError: Error {
    case tokenError(message: String)
}

extension AuthenticationViewModel {
    func signInWithGoogle() async -> Bool {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("No client ID found in Firebase configuration")
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard
            let windowScene = UIApplication.shared.connectedScenes.first
                as? UIWindowScene,
            let window = windowScene.windows.first,
            let rootViewController = window.rootViewController
        else {
            print("There is no root view controller!")
            return false
        }

        do {
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(
                withPresenting: rootViewController)

            let user = userAuthentication.user
            guard let idToken = user.idToken else {
                throw AuthenticationError.tokenError(
                    message: "ID token missing")
            }
            let accessToken = user.accessToken

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken.tokenString,
                accessToken: accessToken.tokenString)

            let result = try await Auth.auth().signIn(with: credential)
            let firebaseUser = result.user
            print(
                "User \(firebaseUser.uid) signed in with email \(firebaseUser.email ?? "unknown")"
            )
            
            let userData: [String: Any] = [
                "id": firebaseUser.uid,
                "email": firebaseUser.email!,
                "name": firebaseUser.displayName!,
//                "created_at": "",
//                "updated_at": "",
//                "deleted_at": "",
            ]
            print(userData)
            try await db.collection("ql_uid").document(firebaseUser.uid).setData(
                userData)
            return true
        } catch {
            print(error.localizedDescription)
            self.errorMessage = error.localizedDescription
            return false
        }
    }
}
