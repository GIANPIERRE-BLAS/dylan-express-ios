import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import FirebaseCore

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var verificationID: String?
    @Published var codeSent = false
    @Published var registrationSuccess = false
    
    init() {
        self.userSession = Auth.auth().currentUser
    }
    
    func login(email: String, password: String) {
        isLoading = true
        errorMessage = ""
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                self?.userSession = result?.user
            }
        }
    }
    
    func register(email: String, password: String, fullName: String, dni: String, phone: String) {
        isLoading = true
        errorMessage = ""
        registrationSuccess = false
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                guard let user = result?.user else { return }
                let data: [String: Any] = [
                    "uid": user.uid,
                    "email": email,
                    "fullName": fullName,
                    "dni": dni,
                    "phone": phone,
                    "createdAt": Timestamp()
                ]
                Firestore.firestore().collection("users").document(user.uid).setData(data) { error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    
                    try? Auth.auth().signOut()
                    self?.registrationSuccess = true
           
                }
            }
        }
    }
    
    func sendVerificationCode(phoneNumber: String) {
        isLoading = true
        errorMessage = ""
        var cleanPhone = phoneNumber.replacingOccurrences(of: " ", with: "")
        if !cleanPhone.hasPrefix("+") {
            cleanPhone = "+51" + cleanPhone
        }
        PhoneAuthProvider.provider().verifyPhoneNumber(cleanPhone, uiDelegate: nil) { [weak self] verificationID, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                self?.verificationID = verificationID
                self?.codeSent = true
            }
        }
    }
    
    func verifyCode(code: String) {
        guard let verificationID = verificationID else {
            errorMessage = "No se ha enviado un código de verificación"
            return
        }
        isLoading = true
        errorMessage = ""
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: code
        )
        Auth.auth().signIn(with: credential) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                guard let user = result?.user else { return }
                self?.userSession = user
                self?.saveUserIfNeeded(user: user)
            }
        }
    }
    
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else { return }
        isLoading = true
        errorMessage = ""
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.isLoading = false
                    self?.errorMessage = error.localizedDescription
                    return
                }
                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString else {
                    self?.isLoading = false
                    return
                }
                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: user.accessToken.tokenString
                )
                Auth.auth().signIn(with: credential) { authResult, error in
                    self?.isLoading = false
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        return
                    }
                    guard let firebaseUser = authResult?.user else { return }
                    self?.userSession = firebaseUser
                    self?.saveUserIfNeeded(user: firebaseUser)
                }
            }
        }
    }
    
    private func saveUserIfNeeded(user: FirebaseAuth.User) {
        let userRef = Firestore.firestore().collection("users").document(user.uid)
        userRef.getDocument { document, error in
            if let document = document, document.exists { return }
            let data: [String: Any] = [
                "uid": user.uid,
                "email": user.email ?? "",
                "fullName": user.displayName ?? "",
                "phone": user.phoneNumber ?? "",
                "createdAt": Timestamp()
            ]
            userRef.setData(data) { error in
                if let error = error { print(error.localizedDescription) }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            self.userSession = nil
            codeSent = false
            print("Sesión cerrada correctamente")
        } catch {
            print(error.localizedDescription)
        }
    }
}
