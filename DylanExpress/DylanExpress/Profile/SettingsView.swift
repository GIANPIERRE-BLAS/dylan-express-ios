import SwiftUI
import FirebaseFirestore

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: AuthViewModel
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @Binding var userData: UserData?
    
    @State private var editedName = ""
    @State private var editedDNI = ""
    @State private var editedPhone = ""
    @State private var showingSaveAlert = false
    @State private var isSaving = false
    
    var body: some View {
        NavigationView {
            ZStack {
                (isDarkMode ? Color.black : Color.white)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Text("Edita tu información personal")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, 10)
                        
                        VStack(spacing: 18) {
                            EditField(
                                icon: "person.fill",
                                title: "Nombre Completo",
                                placeholder: "Ingresa tu nombre",
                                text: $editedName,
                                isDarkMode: isDarkMode
                            )
                            
                            EditField(
                                icon: "creditcard.fill",
                                title: "DNI",
                                placeholder: "Ingresa tu DNI",
                                text: $editedDNI,
                                keyboardType: .numberPad,
                                isDarkMode: isDarkMode
                            )
                            
                            EditField(
                                icon: "phone.fill",
                                title: "Teléfono",
                                placeholder: "Ingresa tu teléfono",
                                text: $editedPhone,
                                keyboardType: .phonePad,
                                isDarkMode: isDarkMode
                            )
                        }
                        .padding(.horizontal, 24)
                        
                        Button(action: {
                            saveProfile()
                        }) {
                            ZStack {
                                if isSaving {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("GUARDAR CAMBIOS")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(primaryGradient)
                            .cornerRadius(16)
                        }
                        .disabled(isSaving || !hasChanges)
                        .opacity(hasChanges ? 1.0 : 0.6)
                        .padding(.horizontal, 24)
                        .padding(.top, 10)
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Editar Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .navigationBarItems(
                leading: Button("Cancelar") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.blue)
            )
            .alert(isPresented: $showingSaveAlert) {
                Alert(
                    title: Text("Perfil Actualizado"),
                    message: Text("Tus datos han sido guardados exitosamente"),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
            .onAppear {
                editedName = userData?.fullName ?? ""
                editedDNI = userData?.dni ?? ""
                editedPhone = userData?.phone ?? ""
            }
        }
    }
    
    private var hasChanges: Bool {
        editedName != userData?.fullName ||
        editedDNI != userData?.dni ||
        editedPhone != userData?.phone
    }
    
    private func saveProfile() {
        guard let uid = viewModel.userSession?.uid else { return }
        
        isSaving = true
        
        let updates: [String: Any] = [
            "fullName": editedName,
            "dni": editedDNI,
            "phone": editedPhone
        ]
        
        Firestore.firestore()
            .collection("users")
            .document(uid)
            .updateData(updates) { error in
                DispatchQueue.main.async {
                    self.isSaving = false
                    
                    if error == nil {
                        self.userData?.fullName = self.editedName
                        self.userData?.dni = self.editedDNI
                        self.userData?.phone = self.editedPhone
                        self.showingSaveAlert = true
                    }
                }
            }
    }
}

struct EditField: View {
    let icon: String
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    let isDarkMode: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(primaryGradient)
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
                
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .foregroundColor(isDarkMode ? .white : .black)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isDarkMode ? Color.gray.opacity(0.2) : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(primaryGradient, lineWidth: 2)
            )
        }
    }
}
