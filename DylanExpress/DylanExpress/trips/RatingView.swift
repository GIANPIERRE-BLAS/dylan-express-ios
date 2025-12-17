import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct RatingView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    let booking: BookingData
    
    @State private var rating: Int = 0
    @State private var comment: String = ""
    @State private var isSubmitting: Bool = false
    @State private var showSuccess: Bool = false
    @State private var selectedQuickComments: Set<String> = []
    
    private let quickComments = [
        "Excelente servicio",
        "Conductor amable",
        "Puntual",
        "Vehículo limpio",
        "Viaje cómodo",
        "Buena música"
    ]
    
    var body: some View {
        ZStack {
            (isDarkMode ? Color.black : Color.white)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 30) {
                    headerSection
                    
                    starsSection
                    
                    quickCommentsSection
                    
                    commentSection
                    
                    submitButton
                    
                    skipButton
                }
                .padding(.vertical, 30)
            }
            
            if showSuccess {
                successOverlay
            }
        }
        .navigationBarTitle("Calificar Viaje", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
    }
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .foregroundColor(.clear)
                    .background(primaryGradient)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                
                Image(systemName: "star.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                Text("¿Cómo estuvo tu viaje?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(isDarkMode ? .white : .black)
                
                HStack(spacing: 8) {
                    Text(booking.origin)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text(booking.destination)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Text(booking.dateString)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var starsSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                ForEach(1...5, id: \.self) { index in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            rating = index
                        }
                    }) {
                        Image(systemName: index <= rating ? "star.fill" : "star")
                            .font(.system(size: 40))
                            .foregroundColor(index <= rating ? Color(red: 1.0, green: 0.85, blue: 0.0) : .gray.opacity(0.3))
                            .scaleEffect(index <= rating ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6))
                    }
                }
            }
            
            if rating > 0 {
                Text(ratingText)
                    .font(.headline)
                    .foregroundColor(ratingColor)
            }
        }
        .padding(.vertical, 10)
    }
    
    private var quickCommentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("¿Qué te gustó?")
                .font(.headline)
                .foregroundColor(isDarkMode ? .white : .black)
                .padding(.horizontal, 24)
            
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    ForEach(Array(quickComments.prefix(3)), id: \.self) { quickComment in
                        quickCommentButton(quickComment)
                    }
                }
                HStack(spacing: 8) {
                    ForEach(Array(quickComments.suffix(3)), id: \.self) { quickComment in
                        quickCommentButton(quickComment)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    private func quickCommentButton(_ quickComment: String) -> some View {
        Button(action: {
            toggleQuickComment(quickComment)
        }) {
            HStack(spacing: 6) {
                if selectedQuickComments.contains(quickComment) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
                
                Text(quickComment)
                    .font(.caption)
                    .foregroundColor(selectedQuickComments.contains(quickComment) ? .white : (isDarkMode ? .white : .black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                selectedQuickComments.contains(quickComment) ?
                AnyView(primaryGradient) :
                AnyView(Color.gray.opacity(isDarkMode ? 0.2 : 0.1))
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(selectedQuickComments.contains(quickComment) ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private var commentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cuéntanos más (opcional)")
                .font(.headline)
                .foregroundColor(isDarkMode ? .white : .black)
                .padding(.horizontal, 24)
            
            ZStack(alignment: .topLeading) {
                if comment.isEmpty {
                    Text("Comparte tu experiencia...")
                        .font(.subheadline)
                        .foregroundColor(.gray.opacity(0.6))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                }
                
                TextEditor(text: $comment)
                    .font(.subheadline)
                    .foregroundColor(isDarkMode ? .white : .black)
                    .frame(height: 120)
                    .padding(8)
                    .background(Color.clear)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .foregroundColor(isDarkMode ? Color.gray.opacity(0.2) : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal, 24)
        }
    }
    
    private var submitButton: some View {
        Button(action: {
            submitRating()
        }) {
            HStack(spacing: 10) {
                if isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18))
                    Text("Enviar Calificación")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(rating > 0 ? primaryGradient : LinearGradient(gradient: Gradient(colors: [Color.gray, Color.gray]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(16)
            .shadow(color: rating > 0 ? Color.blue.opacity(0.3) : Color.clear, radius: 10, x: 0, y: 5)
        }
        .disabled(rating == 0 || isSubmitting)
        .padding(.horizontal, 24)
    }
    
    private var skipButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Text("Omitir por ahora")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
        }
    }
    
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .foregroundColor(.clear)
                        .background(LinearGradient(gradient: Gradient(colors: [.green, Color(red: 0.0, green: 0.6, blue: 0.3)]), startPoint: .leading, endPoint: .trailing))
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text("¡Gracias por tu opinión!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Tu calificación nos ayuda a mejorar")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(isDarkMode ? Color.gray.opacity(0.95) : Color.white)
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 40)
        }
    }
    
    private var ratingText: String {
        switch rating {
        case 1: return "Malo"
        case 2: return "Regular"
        case 3: return "Bueno"
        case 4: return "Muy bueno"
        case 5: return "¡Excelente!"
        default: return ""
        }
    }
    
    private var ratingColor: Color {
        switch rating {
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return Color(red: 0.5, green: 0.8, blue: 0.3)
        case 5: return .green
        default: return .gray
        }
    }
    
    private func toggleQuickComment(_ quickComment: String) {
        if selectedQuickComments.contains(quickComment) {
            selectedQuickComments.remove(quickComment)
        } else {
            selectedQuickComments.insert(quickComment)
        }
    }
    
    private func submitRating() {
        guard rating > 0, let userId = Auth.auth().currentUser?.uid else { return }
        
        isSubmitting = true
        
        let commentText = selectedQuickComments.joined(separator: ", ") + (comment.isEmpty ? "" : (selectedQuickComments.isEmpty ? comment : ", " + comment))
        
        let ratingData: [String: Any] = [
            "bookingId": booking.id,
            "userId": userId,
            "rating": rating,
            "comment": commentText,
            "origin": booking.origin,
            "destination": booking.destination,
            "date": Timestamp(date: booking.date),
            "createdAt": Timestamp(date: Date())
        ]
        
        Firestore.firestore()
            .collection("ratings")
            .addDocument(data: ratingData) { error in
                DispatchQueue.main.async {
                    isSubmitting = false
                    
                    if error == nil {
                        withAnimation {
                            showSuccess = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
    }
}
