import SwiftUI
import FirebaseFirestore

struct YapePaymentView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    let bookingId: String
    let origin: String
    let destination: String
    let date: Date
    let time: String
    let seatNumber: Int
    let price: Double
    
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var phoneNumber = ""
    @State private var operationNumber = ""
    @State private var showConfirmation = false
    @State private var isProcessing = false
    @State private var paymentCompleted = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            (isDarkMode ? Color.black : Color.white)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 30) {
                    
                    Image("yapelogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .padding(.top, 30)
                    
                    Text("Pago con Yape")
                        .font(.title.bold())
                        .foregroundColor(isDarkMode ? .white : .black)
                    
                    Text("S/ \(String(format: "%.2f", price))")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.purple)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Número de teléfono")
                            .font(.subheadline.bold())
                            .foregroundColor(.gray)
                        
                        HStack {
                            Image(systemName: "phone.fill")
                                .foregroundColor(.purple)
                            TextField("999 999 999", text: $phoneNumber)
                                .keyboardType(.numberPad)
                                .foregroundColor(isDarkMode ? .white : .black)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.purple, lineWidth: 1.7)
                        )
                    }
                    .padding(.horizontal, 25)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Número de operación")
                            .font(.subheadline.bold())
                            .foregroundColor(.gray)
                        
                        HStack {
                            Image(systemName: "number")
                                .foregroundColor(.purple)
                            TextField("Ej: 123456789", text: $operationNumber)
                                .keyboardType(.numberPad)
                                .foregroundColor(isDarkMode ? .white : .black)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.purple, lineWidth: 1.7)
                        )
                    }
                    .padding(.horizontal, 25)
                    
                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("Yapea al número 987 654 321")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        HStack(spacing: 8) {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.orange)
                            Text("Ingresa el número de operación")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Confirma tu pago para continuar")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 25)
                    
                    Button(action: {
                        processPayment()
                    }) {
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("CONFIRMAR PAGO")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background((phoneNumber.count >= 9 && operationNumber.count >= 6) ? Color.purple : Color.gray)
                    .cornerRadius(16)
                    .padding(.horizontal, 25)
                    .disabled(phoneNumber.count < 9 || operationNumber.count < 6 || isProcessing)
                    
                    Spacer(minLength: 30)
                }
            }
            .blur(radius: (isProcessing || paymentCompleted) ? 3 : 0)
            
            if isProcessing {
                ZStack {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                            .scaleEffect(1.5)
                        
                        Text("Procesando pago...")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .foregroundColor(isDarkMode ? Color.gray.opacity(0.95) : Color.white)
                            .shadow(radius: 20)
                    )
                }
                .transition(.opacity)
            }
            
            if paymentCompleted {
                ZStack {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                        
                        Text("¡Pago realizado!")
                            .font(.title.bold())
                            .foregroundColor(isDarkMode ? .white : .black)
                        
                        Text("Tu reserva ha sido confirmada")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .foregroundColor(isDarkMode ? Color.gray.opacity(0.95) : Color.white)
                            .shadow(radius: 20)
                    )
                }
                .transition(.opacity)
            }
        }
        .navigationTitle("Yape")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .navigationBarBackButtonHidden(isProcessing || paymentCompleted)
    }
    
    func processPayment() {
        isProcessing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            Firestore.firestore().collection("bookings").document(bookingId).updateData([
                "status": "paid",
                "paymentMethod": "yape",
                "yapePhone": phoneNumber,
                "yapeOperationNumber": operationNumber
            ]) { error in
                isProcessing = false
                
                if error == nil {
                    paymentCompleted = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
