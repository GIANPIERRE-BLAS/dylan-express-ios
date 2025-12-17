import SwiftUI
import FirebaseFirestore

struct ComplaintsView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var complaintType = "Servicio"
    @State private var ticketNumber = ""
    @State private var fullName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var complaintDescription = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSubmitting = false
    
    let complaintTypes = ["Servicio", "Personal", "Vehículo", "Reembolso", "Equipaje", "Otro"]
    let db = Firestore.firestore()
    
    var body: some View {
        ZStack {
            (isDarkMode ? Color.black : Color.white)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    headerSection
                    
                    infoSection
                    
                    complaintDataSection
                    
                    personalDataSection
                    
                    descriptionSection
                    
                    submitButton
                    
                    privacySection
                }
                .padding(.vertical, 30)
            }
        }
        .navigationTitle("Reclamos")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                Text("Volver")
                    .font(.body)
            }
            .foregroundColor(.blue)
        })
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Reclamo Enviado"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    clearForm()
                }
            )
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 15) {
            ZStack {
                Circle()
                    .foregroundColor(Color.red.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "exclamationmark.bubble.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
            }
            
            Text("Libro de Reclamaciones")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(isDarkMode ? .white : .black)
            
            Text("Tu opinión es importante para nosotros")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
                
                Text("Información Importante")
                    .font(.headline)
                    .foregroundColor(isDarkMode ? .white : .black)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                infoRow(text: "Respuesta en 24-48 horas hábiles")
                infoRow(text: "Todos los campos son obligatorios")
                infoRow(text: "Recibirás una copia por correo")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .foregroundColor(isDarkMode ? Color.gray.opacity(0.2) : Color.blue.opacity(0.05))
        )
        .padding(.horizontal, 20)
    }
    
    private func infoRow(text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.blue)
                .font(.caption)
            
            Text(text)
                .font(.caption)
                .foregroundColor(isDarkMode ? .gray : .secondary)
        }
    }
    
    private var complaintDataSection: some View {
        VStack(spacing: 20) {
            Text("Datos del Reclamo")
                .font(.headline)
                .foregroundColor(isDarkMode ? .white : .black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Tipo de Reclamo")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(isDarkMode ? .white : .black)
                
                Menu {
                    ForEach(complaintTypes, id: \.self) { type in
                        Button(action: {
                            complaintType = type
                        }) {
                            HStack {
                                Text(type)
                                if complaintType == type {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(complaintType)
                            .foregroundColor(isDarkMode ? .white : .black)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(isDarkMode ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
                    )
                }
            }
            .padding(.horizontal, 20)
            
            textFieldView(
                icon: "ticket.fill",
                title: "Número de Ticket (Opcional)",
                placeholder: "Ej: TK-12345",
                text: $ticketNumber
            )
        }
    }
    
    private var personalDataSection: some View {
        VStack(spacing: 20) {
            Divider()
                .padding(.horizontal, 20)
            
            Text("Datos Personales")
                .font(.headline)
                .foregroundColor(isDarkMode ? .white : .black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            
            textFieldView(
                icon: "person.fill",
                title: "Nombre Completo",
                placeholder: "Ingresa tu nombre completo",
                text: $fullName
            )
            
            textFieldView(
                icon: "envelope.fill",
                title: "Correo Electrónico",
                placeholder: "ejemplo@correo.com",
                text: $email,
                keyboardType: .emailAddress
            )
            
            textFieldView(
                icon: "phone.fill",
                title: "Teléfono",
                placeholder: "+51 999 999 999",
                text: $phone,
                keyboardType: .phonePad
            )
        }
    }
    
    private var descriptionSection: some View {
        VStack(spacing: 20) {
            Divider()
                .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Descripción del Reclamo")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(isDarkMode ? .white : .black)
                
                ZStack(alignment: .topLeading) {
                    if complaintDescription.isEmpty {
                        Text("Describe tu reclamo de manera detallada...")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.6))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                    }
                    
                    TextEditor(text: $complaintDescription)
                        .font(.subheadline)
                        .foregroundColor(isDarkMode ? .white : .black)
                        .frame(height: 150)
                        .padding(8)
                        .background(Color.clear)
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(isDarkMode ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isDarkMode ? Color.gray.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var submitButton: some View {
        Button(action: {
            submitComplaint()
        }) {
            HStack(spacing: 10) {
                if isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18))
                    Text("Enviar Reclamo")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .foregroundColor(isFormValid() && !isSubmitting ? .red : .gray)
            )
            .shadow(color: isFormValid() && !isSubmitting ? .red.opacity(0.3) : .clear, radius: 10, x: 0, y: 5)
        }
        .disabled(!isFormValid() || isSubmitting)
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var privacySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "shield.fill")
                    .foregroundColor(.green)
                Text("Protección de Datos")
                    .font(.headline)
                    .foregroundColor(isDarkMode ? .white : .black)
            }
            
            Text("Tus datos serán tratados conforme a la Ley de Protección de Datos Personales. Solo serán utilizados para dar seguimiento a tu reclamo.")
                .font(.caption)
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .foregroundColor(isDarkMode ? Color.gray.opacity(0.2) : Color.green.opacity(0.05))
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
    
    private func textFieldView(
        icon: String,
        title: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(isDarkMode ? .white : .black)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                    .frame(width: 20)
                
                TextField(placeholder, text: text)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .foregroundColor(isDarkMode ? .white : .black)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(isDarkMode ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isDarkMode ? Color.gray.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
    }
    
    func isFormValid() -> Bool {
        return !fullName.isEmpty &&
               !email.isEmpty &&
               !phone.isEmpty &&
               !complaintDescription.isEmpty &&
               email.contains("@")
    }
    
    func submitComplaint() {
        isSubmitting = true
        
        let complaintNumber = "RCL-\(Int.random(in: 10000...99999))"
        let timestamp = Timestamp(date: Date())
        
        let complaintData: [String: Any] = [
            "complaintNumber": complaintNumber,
            "type": complaintType,
            "ticketNumber": ticketNumber,
            "fullName": fullName,
            "email": email,
            "phone": phone,
            "description": complaintDescription,
            "timestamp": timestamp,
            "status": "Pendiente"
        ]
        
        db.collection("complaints").addDocument(data: complaintData) { error in
            DispatchQueue.main.async {
                isSubmitting = false
                
                if let error = error {
                    alertMessage = "Error al enviar el reclamo: \(error.localizedDescription)"
                } else {
                    alertMessage = "Tu reclamo ha sido registrado con el número: \(complaintNumber). Recibirás una respuesta en tu correo dentro de 24-48 horas hábiles."
                }
                
                showingAlert = true
            }
        }
    }
    
    func clearForm() {
        fullName = ""
        email = ""
        phone = ""
        ticketNumber = ""
        complaintDescription = ""
        complaintType = "Servicio"
    }
}

struct ComplaintsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ComplaintsView()
        }
    }
}
