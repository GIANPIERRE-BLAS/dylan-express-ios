import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct UserData {
    var fullName: String
    var email: String
    var dni: String
    var phone: String
    var profileImageBase64: String?
}

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @State private var userData: UserData?
    @State private var isLoading = true
    @State private var showingSettings = false
    @State private var showingImagePicker = false
    @State private var profileImage: UIImage?
    
    // Estadísticas
    @State private var totalTrips = 0
    @State private var favoriteTripsCount = 0
    
    var body: some View {
        ZStack {
            (isDarkMode ? Color.black : Color.white)
                .edgesIgnoringSafeArea(.all)
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.primaryGreen))
            } else {
                ScrollView {
                    VStack(spacing: 25) {
                        // SECCIÓN: Foto de Perfil
                        profileHeader
                        
                        // SECCIÓN: Estadísticas
                        statsSection
                        
                        // SECCIÓN: Viajes Favoritos Preview
                        favoritesPreview
                        
                        // SECCIÓN: Información Personal
                        personalInfoSection
                        
                        // SECCIÓN: Configuración
                        settingsSection
                        
                        // SECCIÓN: Cerrar Sesión
                        signOutButton
                    }
                    .padding(.vertical, 20)
                }
            }
        }
        .navigationTitle("Mi Perfil")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .sheet(isPresented: $showingSettings) {
            SettingsView(userData: $userData)
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $profileImage, onImageSelected: { image in
                if let image = image {
                    saveProfileImage(image)
                }
            })
        }
        .onAppear {
            loadUserData()
            loadStats()
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                if let image = profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(primaryGradient, lineWidth: 4)
                        )
                } else {
                    ZStack {
                        Circle()
                            .foregroundColor(.clear)
                            .background(primaryGradient)
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                        
                        Text(userData?.fullName.prefix(1).uppercased() ?? "U")
                            .font(.system(size: 52, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                Button(action: {
                    showingImagePicker = true
                }) {
                    ZStack {
                        Circle()
                            .foregroundColor(isDarkMode ? Color.gray.opacity(0.9) : Color.white)
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "camera.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                    }
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
            }
            
            VStack(spacing: 6) {
                Text(userData?.fullName ?? "Usuario")
                    .font(.title2.bold())
                    .foregroundColor(isDarkMode ? .white : .black)
                
                Text(userData?.email ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.top, 10)
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        HStack(spacing: 0) {
            StatCard(
                title: "Mis Viajes",
                value: "\(totalTrips)",
                icon: "bus.fill",
                isDarkMode: isDarkMode
            )
            
            Divider()
                .frame(height: 60)
                .background(Color.gray.opacity(0.3))
            
            StatCard(
                title: "Favoritos",
                value: "\(favoriteTripsCount)",
                icon: "heart.fill",
                isDarkMode: isDarkMode
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(isDarkMode ? Color.gray.opacity(0.2) : Color.white)
                .shadow(color: isDarkMode ? .clear : .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(primaryGradient, lineWidth: 1.5)
        )
        .padding(.horizontal, 24)
    }
    
    // MARK: - Favorites Preview
    private var favoritesPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                
                Text("Viajes Favoritos")
                    .font(.headline)
                    .foregroundColor(isDarkMode ? .white : .black)
                
                Spacer()
                
                NavigationLink(destination: FavoriteTripsView().environmentObject(viewModel)) {
                    HStack(spacing: 4) {
                        Text("Ver todos")
                            .font(.subheadline)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 24)
            
            if favoriteTripsCount > 0 {
                Text("Tienes \(favoriteTripsCount) viaje\(favoriteTripsCount == 1 ? "" : "s") guardado\(favoriteTripsCount == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 24)
            } else {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("Aún no tienes favoritos")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundColor(isDarkMode ? Color.gray.opacity(0.1) : Color.gray.opacity(0.05))
                )
                .padding(.horizontal, 24)
            }
        }
    }
    
    // MARK: - Personal Info Section
    private var personalInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Información Personal")
                .font(.headline)
                .foregroundColor(isDarkMode ? .white : .black)
                .padding(.horizontal, 24)
            
            VStack(spacing: 14) {
                InfoRowView(icon: "person.fill", title: "Nombre", value: userData?.fullName ?? "", isDarkMode: isDarkMode)
                InfoRowView(icon: "envelope.fill", title: "Correo", value: userData?.email ?? "", isDarkMode: isDarkMode)
                InfoRowView(icon: "creditcard.fill", title: "DNI", value: userData?.dni ?? "", isDarkMode: isDarkMode)
                InfoRowView(icon: "phone.fill", title: "Teléfono", value: userData?.phone ?? "", isDarkMode: isDarkMode)
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Configuración")
                .font(.headline)
                .foregroundColor(isDarkMode ? .white : .black)
                .padding(.horizontal, 24)
            
            VStack(spacing: 14) {
                Button(action: {
                    showingSettings = true
                }) {
                    SettingRowView(
                        icon: "person.crop.circle",
                        title: "Editar Perfil",
                        hasChevron: true,
                        isDarkMode: isDarkMode
                    )
                }
                
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .foregroundColor(.clear)
                            .background(LinearGradient(
                                gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                        
                        Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                    
                    Text("Modo Oscuro")
                        .font(.subheadline)
                        .foregroundColor(isDarkMode ? .white : .black)
                    
                    Spacer()
                    
                    Toggle("", isOn: $isDarkMode)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: Color.primaryGreen))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundColor(isDarkMode ? Color.gray.opacity(0.2) : Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                
                SettingRowView(
                    icon: "bell.fill",
                    title: "Notificaciones",
                    hasChevron: true,
                    isDarkMode: isDarkMode
                )
                
                SettingRowView(
                    icon: "globe",
                    title: "Idioma",
                    subtitle: "Español",
                    hasChevron: true,
                    isDarkMode: isDarkMode
                )
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Sign Out Button
    private var signOutButton: some View {
        Button(action: {
            viewModel.signOut()
        }) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.headline)
                
                Text("CERRAR SESIÓN")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.red)
            .cornerRadius(16)
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
        .padding(.bottom, 30)
    }
    
    // MARK: - Functions
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
                            phone: data["phone"] as? String ?? "",
                            profileImageBase64: data["profileImageBase64"] as? String
                        )
                        
                        // Load profile image from base64
                        if let base64String = self.userData?.profileImageBase64,
                           let imageData = Data(base64Encoded: base64String),
                           let image = UIImage(data: imageData) {
                            self.profileImage = image
                        }
                    }
                }
            }
    }
    
    private func loadStats() {
        guard let uid = viewModel.userSession?.uid else { return }
        
        // Load total trips
        Firestore.firestore()
            .collection("bookings")
            .whereField("userId", isEqualTo: uid)
            .getDocuments { snapshot, _ in
                DispatchQueue.main.async {
                    self.totalTrips = snapshot?.documents.count ?? 0
                }
            }
        
        // Load favorite trips count
        Firestore.firestore()
            .collection("favorites")
            .whereField("userId", isEqualTo: uid)
            .getDocuments { snapshot, _ in
                DispatchQueue.main.async {
                    self.favoriteTripsCount = snapshot?.documents.count ?? 0
                }
            }
    }
    
    private func saveProfileImage(_ image: UIImage) {
        guard let uid = viewModel.userSession?.uid,
              let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        
        let base64String = imageData.base64EncodedString()
        
        Firestore.firestore()
            .collection("users")
            .document(uid)
            .updateData(["profileImageBase64": base64String]) { error in
                if error == nil {
                    DispatchQueue.main.async {
                        self.userData?.profileImageBase64 = base64String
                    }
                }
            }
    }
}

// MARK: - Supporting Views
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let isDarkMode: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .foregroundColor(.clear)
                    .background(primaryGradient)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }
            
            Text(value)
                .font(.title.bold())
                .foregroundColor(isDarkMode ? .white : .black)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct InfoRowView: View {
    let icon: String
    let title: String
    let value: String
    let isDarkMode: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .foregroundColor(.clear)
                    .background(primaryGradient)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(isDarkMode ? .white : .black)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .foregroundColor(isDarkMode ? Color.gray.opacity(0.2) : Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

struct SettingRowView: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    let hasChevron: Bool
    let isDarkMode: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .foregroundColor(.clear)
                    .background(primaryGradient)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(isDarkMode ? .white : .black)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            if hasChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .foregroundColor(isDarkMode ? Color.gray.opacity(0.2) : Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Image Picker for iOS 14
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onImageSelected: (UIImage?) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
                parent.onImageSelected(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
