import Foundation
import FirebaseAuth

class FirebaseAuthService {
    
    static let shared = FirebaseAuthService()
    
    private init() {}
    
    func login(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            
            completion(true, nil)
        }
    }
    
    func register(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            
            completion(true, nil)
        }
    }
}

