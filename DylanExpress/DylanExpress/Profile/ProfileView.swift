import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct UserData {
    var fullName: String
    var email: String
    var dni: String
    var phone: String
}

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State private var userData: UserData?
    @State private var isLoading = true
    @State private var isEditing = false
    @State private var editedName = ""
    @State private var editedDNI = ""
    @State private var editedPhone = ""
    @State private var showingSaveAlert = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            if isLoading {
                ProgressView()
            } else {
                ScrollView {
                    VStack(spacing: 30) {
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(primaryGradient)
                                    .frame(width: 110, height: 110)
                                
                                Text(userData?.fullName.prefix(1).uppercased() ?? "U")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Text(userData?.fullName ?? "Usuario")
                                .font(.title2.bold())
                                .foregroundColor(.black)
                            
                            Text(userData?.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 18) {
                            ProfileFieldGradient(
                                title: "Nombre Completo",
                                value: isEditing ? $editedName : .constant(userData?.fullName ?? ""),
                                icon: "person.fill",
                                isEditing: isEditing
                            )
                            
                            ProfileFieldGradient(
                                title: "DNI",
                                value: isEditing ? $editedDNI : .constant(userData?.dni ?? ""),
                                icon: "creditcard.fill",
                                isEditing: isEditing
                            )
                            
                            ProfileFieldGradient(
                                title: "Teléfono",
                                value: isEditing ? $editedPhone : .constant(userData?.phone ?? ""),
                                icon: "phone.fill",
                                isEditing: isEditing
                            )
                            
                            ProfileFieldGradient(
                                title: "Correo Electrónico",
                                value: .constant(userData?.email ?? ""),
                                icon: "envelope.fill",
                                isEditing: false
                            )
                        }
                        .padding(.horizontal, 24)
                        
                        VStack(spacing: 14) {
                            if isEditing {
                                Button {
                                    saveProfile()
                                } label: {
                                    Text("GUARDAR CAMBIOS")
                                        .foregroundColor(.white)
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 56)
                                        .background(primaryGradient)
                                        .cornerRadius(16)
                                }
                                
                                Button {
                                    cancelEditing()
                                } label: {
                                    Text("Cancelar")
                                        .foregroundColor(.blue)
                                        .font(.headline)
                                }
                            } else {
                                Button {
                                    startEditing()
                                } label: {
                                    Text("EDITAR PERFIL")
                                        .foregroundColor(.white)
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 56)
                                        .background(primaryGradient)
                                        .cornerRadius(16)
                                }
                            }
                            
                            Button {
                                viewModel.signOut()
                            } label: {
                                Text("CERRAR SESIÓN")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color.red)
                                    .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationTitle("Mi Perfil")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Perfil Actualizado", isPresented: $showingSaveAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Tus datos han sido guardados exitosamente")
        }
        .onAppear {
            loadUserData()
        }
    }
    
    private func loadUserData() {
        guard let uid = viewModel.userSession?.uid else {
            isLoading = false
            return
        }
        
        Firestore.firestore()
            .collection("users")
            .document(uid)
            .getDocument { snapshot, _ in
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let data = snapshot?.data() {
                        self.userData = UserData(
                            fullName: data["fullName"] as? String ?? "",
                            email: data["email"] as? String ?? "",
                            dni: data["dni"] as? String ?? "",
                            phone: data["phone"] as? String ?? ""
                        )
                    }
                }
            }
    }
    
    private func startEditing() {
        editedName = userData?.fullName ?? ""
        editedDNI = userData?.dni ?? ""
        editedPhone = userData?.phone ?? ""
        isEditing = true
    }
    
    private func cancelEditing() {
        isEditing = false
    }
    
    private func saveProfile() {
        guard let uid = viewModel.userSession?.uid else { return }
        
        let updates: [String: Any] = [
            "fullName": editedName,
            "dni": editedDNI,
            "phone": editedPhone
        ]
        
        Firestore.firestore()
            .collection("users")
            .document(uid)
            .updateData(updates) { error in
                if error == nil {
                    DispatchQueue.main.async {
                        self.userData?.fullName = self.editedName
                        self.userData?.dni = self.editedDNI
                        self.userData?.phone = self.editedPhone
                        self.isEditing = false
                        self.showingSaveAlert = true
                    }
                }
            }
    }
}

struct ProfileFieldGradient: View {
    let title: String
    @Binding var value: String
    let icon: String
    let isEditing: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            HStack {
                if isEditing {
                    TextField("", text: $value)
                        .keyboardType(title == "Teléfono" ? .phonePad : .default)
                        .autocapitalization(title.contains("Correo") ? .none : .words)
                } else {
                    Text(value)
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Image(systemName: icon)
                    .foregroundStyle(primaryGradient)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(primaryGradient, lineWidth: isEditing ? 2 : 1.7)
                    .background(Color.white.cornerRadius(16))
            )
        }
    }
}
