# KC Services & Places Directory

A modern, feature-rich Flutter mobile application for discovering and managing local places and services in Kigali City. This app allows users to find hospitals, restaurants, cafes, libraries, parks, tourist attractions, and police stations, with integrated Google Maps functionality for easy navigation.

## 📱 Features

### Authentication
- **Email & Password Authentication** via Firebase Auth
- **Email Verification** requirement for new accounts
- Secure user session management
- Modern gradient-based login and signup screens

### Place Discovery
- **Browse All Listings** with animated card layouts
- **Category Filtering** (Hospital, Restaurant, Cafe, Library, Park, Police Station, Tourist Attraction)
- **Real-time Search** by name or description
- **Detailed Place Information** including contact details, address, and description
- **Staggered Animations** for smooth card loading

### Mapping & Navigation
- **Interactive Google Maps** integration
- **Location Markers** with category-specific colors
- **Navigate with Map** button for turn-by-turn directions
- **Current Location** detection and display
- **Tap to Browse** any location on the map

### User Listings Management
- **Create New Listings** with form validation
- **Edit Existing Listings** you've created
- **Delete Listings** with confirmation dialog
- **Multi-Category Selection** for each place
- **Visual Map Picker** for precise location selection
- **Coordinate Input** option (Latitude/Longitude)

### Modern UI/UX
- **Gradient Themes** with purple-blue primary colors
- **Card-Based Design** with shadows and rounded corners
- **Smooth Animations** throughout the app
- **SliverAppBar** with expandable headers
- **Pill-Shaped Navigation** with active state indicators
- **Responsive Layouts** optimized for mobile devices

## 🛠️ Tech Stack

### Frontend
- **Flutter** - Cross-platform mobile framework
- **Material 3** - Modern design components
- **Custom Theme System** - Consistent styling across all screens

### Backend & Services
- **Firebase Authentication** - User authentication
- **Cloud Firestore** - Real-time NoSQL database
- **Google Maps Flutter** - Interactive maps
- **Geolocator** - Location services
- **URL Launcher** - External navigation

### State Management
- **Provider** - Efficient state management
- **ChangeNotifier** - Reactive data updates
- **Consumer Widgets** - UI reactivity

### Key Dependencies
```yaml
firebase_core: ^3.6.0
firebase_auth: ^5.3.1
cloud_firestore: ^5.4.4
provider: ^6.1.2
google_maps_flutter: ^2.9.0
geolocator: ^13.0.1
url_launcher: ^6.3.1
```

## 🎨 UI Highlights

### Design System
- **Primary Colors**: Purple (#6C5CE7) to Blue (#0984E3) gradient
- **Accent Colors**: Pink (#FF6B9D) to Orange (#FFB347) gradient
- **Typography**: Custom text styles with proper hierarchy
- **Shadows**: Carefully crafted elevation for depth
- **Border Radius**: Consistent rounded corners (8px, 12px, 16px)

### Screen Animations
- **Fade Transitions** - Smooth screen entries
- **Slide Animations** - Content reveal effects
- **Scale Feedback** - Interactive button presses
- **Staggered Lists** - Delayed card animations

## 📋 Prerequisites

Before running this app, ensure you have:

- **Flutter SDK** (3.10.4 or higher)
- **Dart** (3.10.4 or higher)
- **Android Studio** or **VS Code** with Flutter extensions
- **Android Device/Emulator** or **iOS Device/Simulator**
- **Firebase Account** for backend services
- **Google Cloud Account** for Maps API

## 🚀 Installation & Setup

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/MobDev_IndividAssignment2.git
cd MobDev_IndividAssignment2/kc_services_places
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Configuration

#### Android Setup
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use existing one
3. Add an Android app with package name: `com.example.kc_services_places`
4. Download `google-services.json`
5. Place it in `android/app/`

#### Enable Firebase Services
1. **Authentication**: Enable Email/Password sign-in method
2. **Firestore Database**: Create database in production mode
3. Set up Firestore rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /listings/{listing} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null 
        && request.auth.uid == resource.data.createdBy;
    }
  }
}
```

### 4. Google Maps API Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Enable **Maps SDK for Android**
3. Create API credentials (API Key)
4. Add your API key to `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

### 5. Update Firebase Options
The app includes `firebase_options.dart`. If you created a new Firebase project, regenerate it:
```bash
flutterfire configure
```

## ▶️ Running the App

### Development Mode
```bash
flutter run
```

### Release Build (Android)
```bash
flutter build apk --release
```

### Release Build (iOS)
```bash
flutter build ios --release
```

## 📂 Project Structure

```
kc_services_places/
├── lib/
│   ├── config/
│   │   └── app_theme.dart           # Centralized theme configuration
│   ├── models/
│   │   └── place_listing.dart       # Place data model
│   ├── providers/
│   │   ├── auth_provider.dart       # Authentication state management
│   │   ├── listings_provider.dart   # Listings data management
│   │   └── settings_provider.dart   # App settings
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart    # User login
│   │   │   ├── signup_screen.dart   # User registration
│   │   │   └── email_verification_screen.dart
│   │   ├── directory_screen.dart    # Browse all places
│   │   ├── place_detail_screen.dart # Single place details
│   │   ├── place_form_screen.dart   # Create/Edit listings
│   │   ├── my_listings_screen.dart  # User's listings
│   │   ├── map_view_screen.dart     # Google Maps view
│   │   ├── settings_screen.dart     # User settings
│   │   └── main_screen.dart         # Bottom navigation
│   ├── services/
│   │   └── firestore_service.dart   # Firestore operations
│   ├── widgets/
│   │   ├── place_card.dart          # Listing card component
│   │   └── category_chip.dart       # Category filter chip
│   ├── firebase_options.dart        # Firebase configuration
│   └── main.dart                    # App entry point
├── android/                         # Android-specific files
├── ios/                             # iOS-specific files
└── pubspec.yaml                     # Dependencies
```

## 🖥️ Key Screens

### 1. Authentication Flow
- **Login Screen**: Email/password authentication with gradient design
- **Signup Screen**: New user registration with validation
- **Email Verification**: Verification prompt with resend option

### 2. Main Application
- **Directory Screen**: Browse all places with search and filters
- **Place Details**: Detailed information with map preview
- **My Listings**: Manage your created listings
- **Map View**: Full-screen map with all locations
- **Settings**: User profile and app preferences

### 3. Create/Edit Listing
- **Place Form**: Multi-step form with:
  - Name, categories, address, contact, description
  - Interactive map picker
  - Coordinate input option
  - Form validation

## 🔧 State Management

### Providers
- **AuthProvider**: Manages authentication state, login, signup, logout
- **ListingsProvider**: Handles CRUD operations for places, filtering, search
- **SettingsProvider**: Manages app settings and preferences

### Data Flow
```
User Action → Provider Method → Firestore Service → Firebase
                ↓
         notifyListeners()
                ↓
         Consumer Widget → UI Update
```

## 🌟 Key Features Implementation

### Real-time Updates
All listings are synchronized in real-time using Firestore streams, ensuring users always see the latest data.

### Category-Based Theming
Each category has a unique color scheme for visual distinction:
- 🏥 Hospital - Red
- 👮 Police Station - Blue
- 📚 Library - Violet
- 🍽️ Restaurant - Orange
- ☕ Cafe - Yellow
- 🌳 Park - Green
- 🗿 Tourist Attraction - Cyan

### Location Services
- Auto-detect current location for new listings
- Manual coordinate entry option
- Map tap to select location
- Google Maps integration for navigation

## 🔐 Security

- Firebase Authentication for secure user management
- Email verification required
- Firestore rules enforce user ownership for edit/delete
- Environment-based configuration

## 🐛 Troubleshooting

### Common Issues

**Firebase not connecting:**
- Verify `google-services.json` is in `android/app/`
- Check package name matches Firebase console
- Run `flutter clean` and rebuild

**Google Maps not showing:**
- Verify API key in `AndroidManifest.xml`
- Enable Maps SDK in Google Cloud Console
- Check billing is enabled on Google Cloud

**Location not working:**
- Grant location permissions in device settings
- Check GPS is enabled
- Verify geolocator package is properly configured

## 🤝 Contributing

This is an individual assignment project. For educational purposes only.

## 📄 License

This project is created for academic purposes as part of Mobile Application Development coursework.

## 👨‍💻 Developer

Developed by: Gaddiel Irakoze
Institution: African Leadership University  
Course: Mobile Application Development  
Date: March 2026

---

**Note**: This application is designed for Kigali City and uses Kigali coordinates as default location (-1.9441, 30.0619).