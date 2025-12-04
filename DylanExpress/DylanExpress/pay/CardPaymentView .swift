import SwiftUI
import FirebaseFirestore

struct CardPaymentView: View {
    let bookingId: String
    let origin: String
    let destination: String
    let date: Date
    let time: String
    let seatNumber: Int
    let price: Double
    
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var cardNumber = ""
    @State private var cardName = ""
    @State private var expiryDate = ""
    @State private var cvv = ""
    @State private var showConfirmation = false
    @State private var isProcessing = false
    @State private var paymentCompleted = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                        .padding(.top, 30)
                    
                    Text("Pago con Tarjeta")
                        .font(.title.bold())
                    
                    Text("S/ \(String(format: "%.2f", price))")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.blue)
                    
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Número de tarjeta")
                                .font(.subheadline.bold())
                                .foregroundColor(.gray)
                            
                            HStack {
                                Image(systemName: "creditcard.fill")
                                    .foregroundStyle(primaryGradient)
                                TextField("1234 5678 9012 3456", text: $cardNumber)
                                    .keyboardType(.numberPad)
                                    .onChange(of: cardNumber) { newValue in
                                        if newValue.count > 16 {
                                            cardNumber = String(newValue.prefix(16))
                                        }
                                    }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(primaryGradient, lineWidth: 1.7)
                            )
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nombre en la tarjeta")
                                .font(.subheadline.bold())
                                .foregroundColor(.gray)
                            
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundStyle(primaryGradient)
                                TextField("JUAN PEREZ", text: $cardName)
                                    .textInputAutocapitalization(.characters)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(primaryGradient, lineWidth: 1.7)
                            )
                        }
                        
                        HStack(spacing: 15) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Vencimiento")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.gray)
                                
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundStyle(primaryGradient)
                                    TextField("MM/AA", text: $expiryDate)
                                        .keyboardType(.numberPad)
                                        .onChange(of: expiryDate) { newValue in
                                            if newValue.count > 5 {
                                                expiryDate = String(newValue.prefix(5))
                                            }
                                        }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(primaryGradient, lineWidth: 1.7)
                                )
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("CVV")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.gray)
                                
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundStyle(primaryGradient)
                                    SecureField("123", text: $cvv)
                                        .keyboardType(.numberPad)
                                        .onChange(of: cvv) { newValue in
                                            if newValue.count > 3 {
                                                cvv = String(newValue.prefix(3))
                                            }
                                        }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(primaryGradient, lineWidth: 1.7)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 25)
                    
                    Button {
                        processPayment()
                    } label: {
                        if isProcessing {
                            ProgressView()
                                .tint(.white)
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
                    .background(isFormValid ? Color.blue : Color.gray)
                    .cornerRadius(16)
                    .padding(.horizontal, 25)
                    .disabled(!isFormValid || isProcessing)
                    
                    Spacer(minLength: 30)
                }
            }
            .blur(radius: (isProcessing || paymentCompleted) ? 3 : 0)
            
            if isProcessing {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.blue)
                        
                        Text("Procesando pago...")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white)
                            .shadow(radius: 20)
                    )
                }
                .transition(.opacity)
            }
            
            if paymentCompleted {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                            .scaleEffect(paymentCompleted ? 1 : 0.5)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: paymentCompleted)
                        
                        Text("¡Pago realizado!")
                            .font(.title.bold())
                            .foregroundColor(.black)
                        
                        Text("Tu reserva ha sido confirmada")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white)
                            .shadow(radius: 20)
                    )
                }
                .transition(.opacity)
            }
        }
        .navigationTitle("Tarjeta")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isProcessing || paymentCompleted)
    }
    
    var isFormValid: Bool {
        cardNumber.count >= 16 && !cardName.isEmpty && expiryDate.count >= 4 && cvv.count >= 3
    }
    
    func processPayment() {
        withAnimation {
            isProcessing = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            Firestore.firestore().collection("bookings").document(bookingId).updateData([
                "status": "paid",
                "paymentMethod": "card"
            ]) { error in
                withAnimation {
                    isProcessing = false
                }
                
                if error == nil {
                    withAnimation {
                        paymentCompleted = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        dismiss()
                    }
                }
            }
        }
    }
}
