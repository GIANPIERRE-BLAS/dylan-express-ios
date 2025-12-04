import Foundation

struct BookingData: Identifiable {
    let id: String
    let userId: String
    let origin: String
    let destination: String
    let date: Date
    let time: String
    let seatNumber: Int
    let status: String
    let price: Double
    let paymentMethod: String
    let createdAt: Date
    let isTouristPlace: Bool
    let travelType: String?
    let numberOfPeople: Int?
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
    
    init(id: String,
         userId: String,
         origin: String,
         destination: String,
         date: Date,
         time: String,
         seatNumber: Int,
         status: String,
         price: Double,
         paymentMethod: String,
         createdAt: Date,
         isTouristPlace: Bool = false,
         travelType: String? = nil,
         numberOfPeople: Int? = nil) {
        
        self.id = id
        self.userId = userId
        self.origin = origin
        self.destination = destination
        self.date = date
        self.time = time
        self.seatNumber = seatNumber
        self.status = status
        self.price = price
        self.paymentMethod = paymentMethod
        self.createdAt = createdAt
        self.isTouristPlace = isTouristPlace
        self.travelType = travelType
        self.numberOfPeople = numberOfPeople
    }
}
