<div align="center">

# 🚐 Dylan Express

### iOS Mobile Application for Interprovincial Transportation

![Swift](https://img.shields.io/badge/Swift-5.9-FA7343?style=for-the-badge&logo=swift&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-15.0+-000000?style=for-the-badge&logo=apple&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-0066CC?style=for-the-badge&logo=swift&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Status](https://img.shields.io/badge/Status-Production-success?style=for-the-badge)

**Transforming Interprovincial Transportation in La Libertad, Peru**

[📥 Download App](#-download) • [✨ Features](#-key-features) • [🛠️ Tech Stack](#️-technical-stack) • [📸 Screenshots](#-screenshots) • [📞 Contact](#-contact)

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
- ✅ **Travel History**  
  Complete booking records
- ✅ **Smart Notifications**  
  24h & 2h travel reminders
- ✅ **Profile Management**  
  Customizable preferences
- ✅ **In-app Support**  
  Direct customer service

</td>
</tr>
</table>

### 📞 24/7 Customer Support
- 📚 **Comprehensive FAQ** - Self-service knowledge base
- 💬 **Multi-channel Contact** - Phone, WhatsApp, in-app messaging
- 📋 **Clear Policies** - Transparent cancellation and refund guidelines
- 🌐 **Always Available** - Round-the-clock support for travelers

---

## 🛠️ Technical Stack

<div align="center">

| Category | Technology | Description |
|:--------:|:----------:|:------------|
| **Language** | Swift 5.9 | Modern, safe, and fast |
| **UI Framework** | SwiftUI | Declarative UI for iOS 15.0+ |
| **Backend** | Firebase | Scalable cloud infrastructure |
| **Authentication** | Firebase Auth | Secure user management |
| **Database** | Cloud Firestore | Real-time NoSQL database |
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
└── Firebase SDK → Backend services
```

---

## 📱 Project Structure

```
DylanExpress/
│
├── 📂 App/
│   └── DylanExpressApp.swift              # Application entry point
│
├── 📂 Core/
│   ├── Models/                            # Data models & entities
│   ├── Services/                          # Business logic & API services
│   ├── Utilities/                         # Helper functions & extensions
│   └── Extensions/                        # Swift standard library extensions
│
├── 📂 Features/
│   ├── 🏠 Home/                           # Main dashboard & navigation
│   ├── 🔐 Authentication/                 # Login & user registration
│   │   └── login/
│   ├── 🎫 Booking/                        # Ticket search & booking flow
│   ├── 💳 Payment/                        # Payment processing
│   │   └── pay/
│   ├── 👤 Profile/                        # User profile management
│   ├── 🗺️ Tourism/                        # Tourism packages & destinations
│   │   └── Tourist/
│   ├── 📞 Support/                        # Customer service features
│   │   └── Customersupport/
│   └── 🎬 Animation/                      # Splash screens & transitions
│       └── animation/
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

- ✅ **Authentication** - Email/Password provider enabled
- ✅ **Firestore Database** - Production mode configured
- ✅ **Cloud Messaging** - APNs certificates uploaded
- ✅ **Cloud Functions** - Payment webhooks deployed
- ✅ **Analytics** - Data collection activated

---

## 📸 Screenshots

<div align="center">

### 🔐 Authentication & Onboarding

<img src="screenshots/iniciodylan.png" width="28%" alt="Splash Screen"/>
<img src="screenshots/logindylan.png" width="28%" alt="Login"/>
<img src="screenshots/registrodylan.png" width="28%" alt="Registration"/>

*Splash Screen • Secure Login • User Registration*

---

### 🏠 Main Interface & Navigation

<img src="screenshots/homedylan.png" width="28%" alt="Home"/>
<img src="screenshots/turistdylan.png" width="28%" alt="Tourism"/>
<img src="screenshots/minivansdyaln.png" width="28%" alt="Vehicles"/>

*Home Dashboard • Tourism Packages • Vehicle Selection*

---

### 🎫 Booking Experience

<img src="screenshots/ticketdylan.png" width="28%" alt="Ticket Search"/>

*Real-time Ticket Search & Booking*

---

### 💳 Payment Methods

<img src="screenshots/yapedylan.png" width="28%" alt="Yape"/>
<img src="screenshots/carddylan.png" width="28%" alt="Card"/>
<img src="screenshots/cahsdylan.png" width="28%" alt="Cash"/>

*Yape Digital Wallet • Card Payment • Cash Options*

---

### 👤 User Services

<img src="screenshots/soport.png" width="28%" alt="Support"/>
<img src="screenshots/profiledylan.png" width="28%" alt="Profile"/>

*24/7 Customer Support • Profile Management*

</div>

---

## 🎯 Project Impact

<div align="center">

### 🌟 Digital Transformation Initiative

*Bringing modern technology to traditionally underserved transportation sectors in Peru's highland regions*

</div>

### Key Objectives

| Objective | Impact |
|-----------|--------|
| 🔄 **Digitalize Operations** | Transform manual booking to automated systems |
| ⏱️ **Reduce Wait Times** | Eliminate long queues at physical agencies |
| 📊 **Real-time Updates** | Provide instant seat availability information |
| 🏛️ **Tourism Promotion** | Showcase La Libertad's cultural heritage |
| ♿ **Improve Accessibility** | Make services available to all communities |

### 🌍 Social Impact

<table>
<tr>
<td width="50%">

**Community Development**
- 🤝 Bridging urban-rural divides
- 💼 Supporting local economies
- 🚐 Reliable transportation access
- 📱 Digital inclusion initiatives

</td>
<td width="50%">

**Cultural Preservation**
- 🏔️ Promoting highland communities
- 🎭 Preserving local traditions
- 🌾 Supporting rural tourism
- 🏛️ Cultural heritage awareness

</td>
</tr>
</table>

---

## 👥 Target Audience

| 👤 User Segment | 🎯 Needs & Benefits |
|----------------|---------------------|
| **Local Residents** | Reliable daily transportation between Trujillo and rural communities with digital convenience |
| **Tourists** | Easy access to explore La Libertad's cultural and natural attractions with guided routes |
| **Business Travelers** | Professional, punctual service for regional business needs with confirmed bookings |
| **Families** | Safe, comfortable travel for visiting relatives in highland areas with group discounts |

---

## 🗺️ Development Roadmap

### ✅ Phase 1: Core Platform (Completed)

- [x] User authentication system with Firebase Auth
- [x] Comprehensive ticket search and booking functionality
- [x] Yape payment gateway integration
- [x] QR code generation and validation system
- [x] Tourism packages catalog and discovery
- [x] Push notification infrastructure (FCM)
- [x] User profile management dashboard
- [x] Customer support integration (multi-channel)

### 🚧 Phase 2: Enhanced Features (In Progress)

- [ ] **Multi-language Support** - Spanish, English, Quechua
- [ ] **Apple Pay Integration** - Native iOS payment method
- [ ] **Offline Booking** - Limited offline functionality
- [ ] **Analytics Dashboard** - User behavior insights
- [ ] **Rating System** - Trip and driver reviews

### 🔮 Phase 3: Advanced Features (Planned)

- [ ] **AI Route Recommendations** - Machine learning-powered suggestions
- [ ] **Real-time GPS Tracking** - Live vehicle location
- [ ] **In-app Driver Chat** - Direct communication channel
- [ ] **Loyalty Program** - Points and rewards system
- [ ] **Additional Payment Providers** - Plin, Tunki, cards
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
