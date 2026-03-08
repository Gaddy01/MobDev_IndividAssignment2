# Kigali City Services & Places Directory

A Flutter mobile application for locating essential public services and leisure locations in Kigali City.

## Features

### Authentication
- Sign up with email and password using Firebase Authentication
- Email verification required before accessing the app
- Secure login/logout functionality
- User profile management in Firestore

### Location Listings (CRUD)
- Create new service/place listings
- View all listings in a shared directory
- Update your own listings
- Delete your own listings
- Real-time updates using Firestore

### Search and Filtering
- Search listings by name or description
- Filter by category (Hospital, Police Station, Library, Restaurant, Café, Park, Tourist Attraction)
- Dynamic filtering with real-time results

### Map Integration
- Google Maps integration with location markers
- View all places on an interactive map
- Navigate to any location with turn-by-turn directions
- Color-coded markers by category

### Navigation
- Bottom navigation bar with 4 screens:
  - **Home/Directory**: Browse all listings
  - **My Listings**: Manage your listings
  - **Map View**: See all places on a map
  - **Settings**: Profile and app settings

### State Management
- Provider pattern for clean architecture
- Separation of business logic from UI
- Automatic UI updates on data changes

## Setup Instructions

### 1. Prerequisites
- Flutter SDK (3.10.4 or higher)
- Android Studio / VS Code
- Firebase account
- Google Maps API key

### 2. Firebase Setup

#### Create a Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project named "Kigali City Services"
3. Enable Firebase Authentication (Email/Password provider)
4. Create a Cloud Firestore database

#### Android Configuration
1. In Firebase Console, add an Android app
2. Package name: `com.example.kc_services_places`
3. Download `google-services.json`
4. Place it in `android/app/`

#### iOS Configuration (Optional)
1. In Firebase Console, add an iOS app
2. Bundle ID: `com.example.kcServicesPlaces`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/`

### 3. Google Maps Setup

#### Get API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create/select a project
3. Enable Maps SDK for Android and iOS
4. Create API credentials

#### Android Configuration
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest ...>
  <application ...>
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="YOUR_API_KEY_HERE"/>
  </application>
</manifest>
```

#### iOS Configuration (Optional)
Add to `ios/Runner/AppDelegate.swift`:
```swift
import GoogleMaps

GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
```

### 4. Install Dependencies
```bash
cd kc_services_places
flutter pub get
```

### 5. Run the App
```bash
flutter run
```

## Project Structure

```
lib/
├── models/
│   ├── user_profile.dart
│   └── place_listing.dart
├── services/
│   ├── auth_service.dart
│   └── firestore_service.dart
├── providers/
│   ├── auth_provider.dart
│   ├── listings_provider.dart
│   └── settings_provider.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── email_verification_screen.dart
│   ├── directory_screen.dart
│   ├── my_listings_screen.dart
│   ├── map_view_screen.dart
│   ├── settings_screen.dart
│   ├── place_detail_screen.dart
│   ├── place_form_screen.dart
│   └── main_screen.dart
├── widgets/
│   ├── place_card.dart
│   └── category_chip.dart
└── main.dart
```

## Firestore Data Structure

### Collections

#### users
```json
{
  "uid": "string",
  "email": "string",
  "displayName": "string",
  "emailVerified": "boolean",
  "createdAt": "timestamp"
}
```

#### listings
```json
{
  "name": "string",
  "category": "string",
  "address": "string",
  "contactNumber": "string",
  "description": "string",
  "latitude": "number",
  "longitude": "number",
  "createdBy": "string (user UID)",
  "timestamp": "timestamp"
}
```

## Usage

### Sign Up
1. Launch the app
2. Click "Sign Up"
3. Enter your details
4. Verify your email

### Add a Listing
1. Navigate to "My Listings"
2. Tap the "Add" button
3. Fill in the details
4. Tap on the map to select location
5. Save the listing

### Search for Places
1. Go to "Home/Directory"
2. Use the search bar or category filters
3. Tap on a place to view details
4. Get directions using Google Maps

## Technologies Used

- **Flutter**: Cross-platform mobile framework
- **Firebase Authentication**: User authentication
- **Cloud Firestore**: NoSQL database
- **Google Maps**: Location and navigation
- **Provider**: State management
- **Geolocator**: Location services

## Requirements Met

✅ Firebase Authentication with email/password  
✅ Email verification  
✅ Full CRUD operations on listings  
✅ Real-time Firestore updates  
✅ Search and category filtering  
✅ Google Maps integration  
✅ Turn-by-turn navigation  
✅ Provider state management  
✅ Clean architecture (separate service layer)  
✅ Bottom navigation with 4 screens  
✅ Settings with notification toggle  
✅ User profile display  

## Notes

- Make sure to replace placeholder API keys with your actual keys
- Enable location permissions on your device
- Ensure internet connectivity for Firebase and Maps
- Email verification is required to access the app

## Author

Developed for Mobile Application Development Individual Assignment 2
