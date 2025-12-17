<div align="center">

# 🚐 Dylan Express

### iOS Mobile Application for Interprovincial Transportation

![Swift](https://img.shields.io/badge/Swift-5.9-FA7343?style=for-the-badge&logo=swift&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-15.0+-000000?style=for-the-badge&logo=apple&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-0066CC?style=for-the-badge&logo=swift&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Status](https://img.shields.io/badge/Status-Production-success?style=for-the-badge)

**Transforming Interprovincial Transportation in La Libertad, Peru**

[📥 Download App](#-download) • [✨ Features](#-key-features) • [🛠️ Tech Stack](#️-technical-stack) • [📞 Contact](#-contact)

---

[![Download Dylan Express](https://img.shields.io/badge/📥_Download_App-iOS_15.0+-0066CC?style=for-the-badge&logo=apple&logoColor=white)](https://github.com/GIANPIERRE-BLAS/dylan-express-ios/blob/main/Releases/DylanExpress.app.zip)

</div>

---

## 📥 Download

<div align="center">

### Get Dylan Express for iOS

[![Download Latest Release](https://img.shields.io/badge/Download_v1.0.0-iOS_Application-blue?style=for-the-badge&logo=apple&logoColor=white)](https://github.com/GIANPIERRE-BLAS/dylan-express-ios/blob/main/Releases/DylanExpress.app.zip)

**Current Version:** 1.0.0 | **Size:** ~50 MB | **Requires:** iOS 15.0+

</div>

### Installation Instructions

1. **Download** the app from the link above
2. **Extract** the ZIP file on your Mac
3. **Drag** the app to your iOS Simulator or install via Xcode
4. For physical devices, requires Apple Developer provisioning

> **Note:** This is a development build. For App Store or TestFlight distribution, contact the developer.

---

## 📖 Overview

**Dylan Express** is a comprehensive iOS mobile solution revolutionizing interprovincial minivan transportation services in La Libertad, Peru. The application seamlessly connects Trujillo with rural and urban communities across the region, streamlining the entire booking process while promoting sustainable local tourism development.

<div align="center">

### 🎯 Our Mission

*Bridging the transportation gap between urban centers and highland communities through technology, providing safe, efficient, and accessible services while fostering economic and social development.*

</div>

---

## ✨ Key Features

<table>
<tr>
<td width="50%">

### 🎫 Smart Booking System
- ✅ **Real-time Seat Management**  
  Live availability with instant sync
- ✅ **Interactive Seat Selection**  
  Visual seat map interface
- ✅ **Multi-destination Support**  
  Flexible routing across La Libertad
- ✅ **Advanced Scheduling**  
  Calendar-based date/time selection
- ✅ **Instant Confirmation**  
  Immediate booking verification

</td>
<td width="50%">

### 💳 Secure Payment Solutions
- ✅ **Yape Integration**  
  Peru's leading digital wallet
- ✅ **Multi-payment Options**  
  Card, cash, and digital methods
- ✅ **Automated Verification**  
  Real-time payment confirmation
- ✅ **QR Ticketing**  
  Secure digital ticket validation
- ✅ **Digital Receipts**  
  Complete transaction history

</td>
</tr>
<tr>
<td width="50%">

### 🗺️ Tourism & Exploration
- ✅ **Curated Packages**  
  Hand-selected heritage routes
- ✅ **Destination Guides**  
  Cultural and natural attractions
- ✅ **Group Bookings**  
  Special rates for groups
- ✅ **Custom Quotes**  
  Personalized trip planning
- ✅ **Route Discovery**  
  Explore La Libertad highlands

</td>
<td width="50%">

### 👤 Enhanced User Experience
- ✅ **Secure Authentication**  
  Firebase-powered security
- ✅ **Travel History & Favorites**  
  Complete booking records with favorites
- ✅ **Smart Notifications**  
  24h & 2h travel reminders
- ✅ **Profile Management**  
  Photo upload and statistics
- ✅ **Real-time Trip Tracking**  
  Live GPS journey monitoring

</td>
</tr>
</table>

### 🆕 Advanced Trip Management
- 📊 **Trip Status Tracking** - Automatic categorization (paid, pending, completed, cancelled)
- ⭐ **Favorites System** - Save preferred routes with instant sync
- 🚫 **Professional Cancellation** - Status-based system with full audit trail
- 📜 **History Toggle** - View active and cancelled trips separately
- 🎯 **Contextual Actions** - Dynamic buttons based on trip status
- ⏱️ **Real-time Tracking** - Live trip simulation with ETA calculation
- ⭐ **Trip Rating System** - Post-trip evaluation and feedback

### 📞 24/7 Customer Support
- 📚 **Comprehensive FAQ** - Self-service knowledge base
- 💬 **Multi-channel Contact** - Phone, WhatsApp, in-app messaging
- 📋 **Complaint Management** - Digital complaints book with tracking
- 🌐 **Always Available** - Round-the-clock support for travelers

---

## 🛠️ Technical Stack

<div align="center">

| Category | Technology | Description |
|:--------:|:----------:|:------------|
| **Language** | Swift 5.9 | Modern, safe, and fast |
| **UI Framework** | SwiftUI | Declarative UI for iOS 15.0+ |
| **Backend** | Firebase | Scalable cloud infrastructure |
| **Authentication** | Firebase Auth | Secure user management with Google Sign-In |
| **Database** | Cloud Firestore | Real-time NoSQL database with listeners |
| **Storage** | Firebase Storage | Profile photos and media |
| **Maps** | MapKit | Native iOS mapping and location |
| **Payments** | Yape API | Peru's #1 digital wallet |
| **QR Codes** | Core Image | Native iOS framework |
| **Notifications** | FCM | Firebase Cloud Messaging |
| **Analytics** | Firebase Analytics | User behavior tracking |
| **Dependencies** | CocoaPods | Dependency management |

</div>

### 🏗️ Architecture Pattern
```
MVVM (Model-View-ViewModel)
├── Combine Framework → Reactive programming
├── SwiftUI → Declarative UI development
├── @AppStorage → Theme persistence
└── Firebase SDK → Backend services with real-time sync
```

---

## 📱 Project Structure
```
DylanExpress/
│
├── 📂 App/
│   └── DylanExpressApp.swift              # Application entry point with Firebase
│
├── 📂 Core/
│   ├── Models/                            # Data models & entities
│   │   ├── BookingData.swift             # Booking model with status management
│   │   ├── User.swift                    # User model with statistics
│   │   └── TouristPlace.swift            # Tourism destinations
│   ├── Services/                          # Business logic & API services
│   │   ├── FirebaseService.swift         # Firestore operations
│   │   ├── AuthService.swift             # Authentication flow
│   │   └── PaymentService.swift          # Payment processing
│   ├── Utilities/                         # Helper functions & extensions
│   │   ├── QRGenerator.swift             # Native QR code generation
│   │   └── DateFormatter+Extensions.swift
│   └── Extensions/                        # Swift standard library extensions
│       └── Color+Extensions.swift         # Theme colors
│
├── 📂 Features/
│   ├── 🏠 Home/                           # Main dashboard & navigation
│   │   ├── HomeView.swift                # Tab Bar with 4 tabs
│   │   ├── SearchView.swift              # Real-time route search
│   │   └── MyTripsView.swift             # Trip management with history
│   ├── 🔐 Authentication/                 # Login & user registration
│   │   ├── LoginView.swift               # Email/Password & Google Sign-In
│   │   ├── RegisterView.swift            # User registration with validation
│   │   └── AuthViewModel.swift           # Authentication logic
│   ├── 🎫 Booking/                        # Ticket search & booking flow
│   │   ├── SeatMapView.swift             # Interactive 4x4 seat selection
│   │   ├── BookingConfirmationView.swift # Booking summary
│   │   └── TicketDetailView.swift        # QR code ticket display
│   ├── 💳 Payment/                        # Payment processing
│   │   ├── PaymentMethodsView.swift      # Payment options selector
│   │   ├── YapePaymentView.swift         # Yape simulation
│   │   ├── CardPaymentView.swift         # Card payment form
│   │   └── CashPaymentView.swift         # Cash reservation system
│   ├── 👤 Profile/                        # User profile management
│   │   ├── ProfileView.swift             # Profile with photo & statistics
│   │   ├── EditProfileView.swift         # Profile editing
│   │   ├── FavoritesView.swift           # Favorite trips management
│   │   └── ThemeToggle.swift             # Dark/Light mode control
│   ├── 🗺️ Tourism/                        # Tourism packages & destinations
│   │   ├── TouristPlacesView.swift       # Curated destinations gallery
│   │   ├── TouristDetailView.swift       # Destination information
│   │   └── QuoteRequestView.swift        # Custom tour quotes
│   ├── 📍 Tracking/                       # Real-time trip tracking
│   │   ├── TripSimulationView.swift      # Live GPS tracking simulation
│   │   ├── MapView.swift                 # MapKit integration
│   │   └── TripRatingView.swift          # Post-trip evaluation
│   ├── 📞 Support/                        # Customer service features
│   │   ├── SupportView.swift             # FAQ and contact options
│   │   ├── ComplaintsBookView.swift      # Digital complaints form
│   │   └── LocationView.swift            # Agency location with map
│   └── 🎬 Animation/                      # Splash screens & transitions
│       └── SplashScreenView.swift        # Animated splash
│
├── 📂 Resources/
│   ├── Assets.xcassets/                   # Images, icons & color assets
│   └── GoogleService-Info.plist           # Firebase configuration
│
├── 📂 Releases/                           # 📦 Distribution builds
│   └── DylanExpress.app.zip              # Latest iOS build
│
└── 📂 Tests/
    ├── UnitTests/                         # Unit test suite
    └── UITests/                           # UI automation tests
```

---

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have:

- ✅ **macOS** 13.0+ (Ventura or later)
- ✅ **Xcode** 15.0+ with Command Line Tools
- ✅ **iOS Device/Simulator** running iOS 15.0+
- ✅ **CocoaPods** installed (`sudo gem install cocoapods`)
- ✅ **Firebase Account** with active project
- ✅ **Apple Developer Account** (for device deployment)

### Installation Steps
```bash
# 1️⃣ Clone the Repository
git clone https://github.com/GIANPIERRE-BLAS/dylan-express-ios.git
cd dylan-express-ios

# 2️⃣ Install Dependencies
pod install

# 3️⃣ Open Workspace (NOT the .xcodeproj)
open DylanExpress.xcworkspace

# 4️⃣ Build and Run
# Press ⌘ + R in Xcode
```

### ⚙️ Configuration

#### Firebase Setup

1. Download `GoogleService-Info.plist` from [Firebase Console](https://console.firebase.google.com/)
2. Drag into Xcode project (ensure "Copy items if needed" is checked)
3. Verify initialization in `DylanExpressApp.swift`

#### Yape Integration

1. Obtain Yape API credentials from [Yape Developer Portal](https://yape.com.pe/)
2. Add credentials to project configuration
3. Update payment service settings

#### Firebase Checklist

- ✅ **Authentication** - Email/Password & Google Sign-In enabled
- ✅ **Firestore Database** - Production mode with indexes configured
- ✅ **Firestore Collections** - bookings, favorites, ratings, users, complaints
- ✅ **Cloud Storage** - Profile photos bucket configured
- ✅ **Cloud Messaging** - APNs certificates uploaded
- ✅ **Cloud Functions** - Payment webhooks deployed
- ✅ **Analytics** - Data collection activated

---

## 🎯 Core Functionalities

### 1. **Complete Authentication System**
Registration and login via Firebase Authentication with form validation, active session management with automatic persistence, Google Sign-In integration, and password recovery module with email confirmation. Real-time validations with regex, custom error messages in Spanish, and loading states with native ProgressView. All screens fully adapt to light and dark themes, configurable from user profile with instant global updates.

### 2. **Real-time Search and Booking Engine**
Dynamic Firestore queries for available routes from Trujillo-Agency to 15 destinations in La Libertad, with date selector and hourly scheduling every 2 hours from 06:00 AM to 08:00 PM. Interactive 4x4 seat map with color coding. Instant availability synchronization between multiple users via Firestore listeners. Special discounts section with visual cards and confirmation panel with seat number and total price. Interface adaptable to light and dark themes, configurable from profile.

### 3. **Simulated Payment System (Three Methods)**
Simulated Yape with official flow interface, card simulation with format validation, and cash with pending reservation system, unique 8-character alphanumeric reservation code, and automatic 24-hour expiration management. All screens display trip summary and price, adapted to light/dark theme configurable from profile.

### 4. **Native QR Code Generator**
Implementation using Swift Core Image for local QR generation without external dependencies, encrypting complete trip information in JSON format. "My Ticket" screen with route header, trip data with iconography, visible alphanumeric reservation code, high-quality QR optimized for scanning, differentiated status badge, and native iOS share sheet functionality.

### 5. **Tourism Services Module**
Professional gallery of La Libertad tourist destinations with high-quality image cards, visual discount badges, complete tourist information including location and description. Transparent pricing table showing original price, discount, and final price per person. Comprehensive quote request form with DatePicker, TimePicker, people selector, and optional comments, with structured Firestore storage. Requested tours appear in "My Trips" as separate category.

### 6. **Trip Management System**
Vista "Mis Viajes" con sistema de categorización automática por estados: confirmados, pendientes, completados y cancelados. Toggle "Historial" en barra de navegación para visualizar viajes cancelados. Cards informativas con badge de estado visual, botón de favorito con sincronización instantánea, y botón "Cancelar Viaje" exclusivo para reservas pendientes con alerta de confirmación. Funcionalidad de cancelación profesional que actualiza el estado a "cancelled" y registra timestamp de cancelación en lugar de eliminar el documento, manteniendo trazabilidad completa. Viajes cancelados se visualizan con opacidad reducida, borde distintivo, y sin botones de acción. Botones contextuales según estado: Ver Boleto, Compartir, Pagar Ahora, Pagar en Agencia, Iniciar Viaje, con actualización en tiempo real mediante Firestore y empty state diferenciado para viajes activos y cancelados.

### 7. **Real-time Trip Simulation System**
Advanced tracking module via MapKit with custom markers for origin, destination, and vehicle with pulse animation. Double route line implementation: complete dotted line and progressive solid line for current travel. Floating header with glassmorphism effect showing total distance and time, information card with real-time ETA chips and visual progress bar. Smooth 15-second animation with 33 FPS update via 150 interpolation points, precise real-time calculations with CLLocation for distance and ETA, floating zoom controls, and completion panel with animated checkmark and "Rate Trip" button. Interface adaptable to light/dark theme with adjusted glassmorphism, configurable from profile.

### 8. **Trip Rating System**
Post-trip screen with interactive 5-star system with scale animation and dynamic text according to rating with color coding. Selectable quick comment chips for agile evaluation. Optional free comment field via TextEditor for detailed feedback. Structured Firebase storage with complete evaluation information, animated success overlay with 2-second auto-close, and permanent trip status update after rating to avoid duplicates.

### 9. **Customer Support System**
Comprehensive support module with FAQ section presenting frequent questions about app usage and payment methods in expandable accordion format. Formal digital Complaints Book with complete form including complaint type categorization, optional reference number, user identification data, and detailed description field with Firestore storage for administrative traceability. Direct contact buttons implemented with native iOS systems for communication via WhatsApp, phone call, and email. Physical location section with main agency address, complete business hours, integrated interactive map, and direct access to maps app with automatic navigation.

### 10. **Routes Information Portal**
Comprehensive informational catalog of 15 operational routes available from Trujillo-Agency to strategic destinations distributed in La Libertad. Each route presents detailed commercial information: destination identification, approximate distance, estimated travel time, available departure schedules, and fare per passenger. Search system via native selector with complete list of destinations with fluid scroll and visual selection confirmation. Direct integration with main search module and special discounts system for optimized booking flow.

### 11. **Profile Management System**
Professional profile screen allowing full visualization and editing of user personal information with immediate bidirectional synchronization to Firebase Authentication and Firestore. Profile photo management with change functionality via native image picker and optimized storage. Statistics card with dynamic counters of total trips and favorites updated in real-time from database. Favorites trips section with preview and access to complete collection. Configuration panel with access to profile editing via pre-loaded forms with validation, visual theme control with instant global update, notifications and language management, and logout functionality with confirmation and secure stored data cleanup.

### 12. **Favorites Trips View**
Dedicated screen accessible from profile showing personalized collection of trips marked as favorites via interactive selection system. Presentation via cards with design consistent with general history but specifically filtered by favorites collection in Firestore. Each entry shows distinctive visual identification, control to remove from favorites, complete route and trip information, temporal metadata of addition, and differentiated action buttons for digital ticket access or new booking generation with same route configuration. Automatic favorites synchronization system with instant UI update and persistence between related views, with appropriate visual state when collection is empty.

---

## 🗺️ Development Roadmap

### ✅ Phase 1: Core Platform (Completed)

- [x] User authentication system with Firebase Auth & Google Sign-In
- [x] Comprehensive ticket search and booking functionality
- [x] Multi-payment gateway integration (Yape, Card, Cash)
- [x] QR code generation and validation system
- [x] Tourism packages catalog and discovery
- [x] Push notification infrastructure (FCM)
- [x] User profile management with photo upload
- [x] Customer support integration with complaints book
- [x] Trip favorites system with real-time sync
- [x] Professional cancellation with audit trail
- [x] Real-time trip tracking simulation
- [x] Post-trip rating and evaluation system
- [x] Dark/Light theme with global persistence

### 🚧 Phase 2: Enhanced Features (In Progress)

- [ ] **Multi-language Support** - Spanish, English, Quechua
- [ ] **Apple Pay Integration** - Native iOS payment method
- [ ] **Offline Booking** - Limited offline functionality
- [ ] **Analytics Dashboard** - User behavior insights
- [ ] **Advanced Rating Insights** - Driver and route analytics

### 🔮 Phase 3: Advanced Features (Planned)

- [ ] **AI Route Recommendations** - Machine learning-powered suggestions
- [ ] **Real-time GPS Tracking** - Live vehicle location with actual GPS
- [ ] **In-app Driver Chat** - Direct communication channel
- [ ] **Loyalty Program** - Points and rewards system
- [ ] **Additional Payment Providers** - Plin, Tunki, international cards
- [ ] **AR Tourism Guides** - Augmented reality experiences
- [ ] **Carbon Footprint Tracking** - Environmental impact metrics

---

## 🧪 Testing & Quality Assurance

### Running Tests
```bash
# Unit Tests
xcodebuild test -workspace DylanExpress.xcworkspace \
  -scheme DylanExpress \
  -destination 'platform=iOS Simulator,name=iPhone 15'

# UI Tests
xcodebuild test -workspace DylanExpress.xcworkspace \
  -scheme DylanExpressUITests \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Quality Metrics

| Metric | Target | Status |
|--------|--------|--------|
| Code Coverage | 80%+ | 🟡 In Progress |
| UI Test Coverage | 70%+ | 🟡 In Progress |
| Crash-free Rate | 99.5%+ | 🟢 Production Ready |
| Performance | < 2s load time | 🟢 Optimized |

---

## 🤝 Contributing

This is a **private proprietary project**. For collaboration inquiries:

### Development Standards

- ✅ Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- ✅ Maintain comprehensive inline documentation
- ✅ Write unit tests for all new features (80%+ coverage)
- ✅ Adhere to MVVM architecture pattern
- ✅ Use SwiftLint for code consistency
- ✅ Submit detailed pull requests with screenshots

### Code Style
```swift
// Example: Follow these conventions
class BookingViewModel: ObservableObject {
    @Published private(set) var bookings: [Booking] = []
    
    func fetchBookings() async throws {
        // Implementation
    }
}
```

---

## 📄 License

<div align="center">

**Private & Proprietary License**

This project is the intellectual property of **Dylan Express** and **Gianpierre Blas**.  
All rights reserved. Unauthorized copying, distribution, or use is strictly prohibited.

© 2025 Dylan Express. All Rights Reserved.

</div>

---

## 👨‍💻 Developer

<div align="center">

<img src="https://github.com/GIANPIERRE-BLAS.png" width="120" height="120" style="border-radius: 50%; border: 3px solid #0066CC;" alt="Gianpierre Blas"/>

### Gianpierre Blas
**iOS Developer | Software Engineer**

*Passionate about creating impactful mobile solutions that bridge technology and social development.*

[![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/GIANPIERRE-BLAS)
[![Email](https://img.shields.io/badge/Email-EA4335?style=for-the-badge&logo=gmail&logoColor=white)](mailto:gianpierreblasflores235@gmail.com)
[![WhatsApp](https://img.shields.io/badge/WhatsApp-25D366?style=for-the-badge&logo=whatsapp&logoColor=white)](https://wa.me/51928489371)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/gianpierre-blas)

</div>

---

## 📞 Contact

<div align="center">

### 🚐 Dylan Express Transportation Services

</div>

<table>
<tr>
<td width="50%">

**Corporate Inquiries**
- 📧 **Email:** gianpierreblasflores235@gmail.com
- 📱 **Phone:** +51 928 489 371
- 📍 **Location:** Trujillo, La Libertad, Peru

</td>
<td width="50%">

**Customer Support**
- 💬 **In-app Support** - Available 24/7
- 📞 **Hotline** - +51 928 489 371
- 💬 **WhatsApp** - [Click to Chat](https://wa.me/51928489371)
- 📧 **Email** - support@dylanexpress.pe

</td>
</tr>
</table>

---

## 🙏 Acknowledgments

Special recognition to:

- 🏔️ **Highland Communities** of La Libertad for their trust and collaboration
- 🚐 **Dylan Express Team** for operational excellence and dedication
- 🧪 **Beta Testers** for invaluable feedback during development
- 🔥 **Firebase Community** for technical support and resources
- 🍎 **Apple Developer Community** for iOS development guidance

---

<div align="center">

### Made with ❤️ in Trujillo, La Libertad, Peru

*Connecting Communities • Empowering Tourism • Building Futures*

![Peru](https://img.shields.io/badge/🇵🇪_Peru-Proud-D91023?style=for-the-badge)
![La Libertad](https://img.shields.io/badge/La_Libertad-Region-1E40AF?style=for-the-badge)

---

**⭐ Star this repository if you find it helpful!**

[![Download App](https://img.shields.io/badge/📥_Download-Dylan_Express-0066CC?style=for-the-badge)](https://github.com/GIANPIERRE-BLAS/dylan-express-ios/blob/main/Releases/DylanExpress.app.zip)

---

**Dylan Express** • Version 1.0.0 • iOS 15.0+ • © 2025 All Rights Reserved

</div>
