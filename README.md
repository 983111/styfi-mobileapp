# Styfi 🛍️✨

**Styfi** is a next-generation fashion marketplace mobile application built with **Flutter**. It integrates advanced AI features—such as virtual try-ons, trend detection, and outfit composition—directly into the shopping experience, bridging the gap between e-commerce and personal styling.

The app serves two distinct user roles: **Buyers**, who discover and try products virtually, and **Sellers**, who manage inventory and leverage AI to enhance product listings.

---

## 🚀 Features

### 🛒 For Buyers
* **Virtual Try-On:** Upload a personal photo and select a product to visualize how it looks on you using AI-powered image synthesis.
* **Outfit Composer:** Select a product and receive AI-generated recommendations for matching items to create a complete look (including prices and color coordination).
* **Trend Detector:** Search for fashion categories (e.g., "Summer Dresses") to discover real-time trends, popularity scores, and key fashion keywords.
* **Marketplace:** Browse the "Latest Drops" in a visual grid layout and view detailed product information.
* **Seamless Checkout:** Integrated flow for purchasing products directly within the app.

### 📦 For Sellers
* **Seller Dashboard:** A dedicated interface to manage product listings and view incoming orders.
* **Image Enhancer:** Upload raw product photos and use AI to automatically enhance quality, lighting, and appeal before listing.
* **Order Management:** Track order status and sales performance.

### 🔐 Core System
* **Dual Role System:** Users can switch between "Buyer" and "Seller" roles, with tailored interfaces for each.
* **Secure Authentication:** Powered by **Firebase Authentication** for secure sign-up and login.
* **Real-time Database:** Utilizes **Cloud Firestore** for instant updates on products, orders, and user profiles.
* **Cloud Storage:** Uses **Supabase** for efficient and scalable storage of product images.

---

## 🛠️ Tech Stack

### Frontend
* **Framework:** Flutter (Dart)
* **UI/UX:** Material Design 3, Google Fonts (`inter`).

### Backend & Services
* **Authentication:** Firebase Auth.
* **Database:** Cloud Firestore.
* **Storage:** Supabase Storage (for product images).
* **AI Backend:** Custom API hosted on Cloudflare Workers.

### Key Packages
| Package | Purpose |
| :--- | :--- |
| `firebase_core`, `firebase_auth`, `cloud_firestore` | Backend infrastructure |
| `supabase_flutter` | Image storage management |
| `http` | API communication with AI services |
| `image_picker` | Selecting images for try-on and uploads |
| `cached_network_image` | Efficient image loading and caching |
| `google_fonts` | Custom typography |

---

## 📂 Project Structure

```text
lib/
├── main.dart                 # App entry point, Firebase/Supabase initialization
├── models.dart               # Data models (Product, Order, TrendReport, etc.)
├── mock_data.dart            # Static data for UI testing
├── screens/
│   ├── checkout_screen.dart      # Purchase completion interface
│   ├── home_screen.dart          # Main landing screen (Buyer view)
│   ├── login_screen.dart         # User authentication screen
│   ├── marketplace_screen.dart   # Product feed and details
│   ├── virtual_try_on_screen.dart# AI Try-On feature
│   ├── outfit_composer_screen.dart # AI Outfit recommendation feature
│   ├── trend_detector_screen.dart # AI Trend analysis feature
│   ├── image_enhancer_screen.dart # Seller tool for photo enhancement
│   ├── seller_dashboard.dart     # Seller management interface
│   └── role_selection_screen.dart # Role switching logic
└── services/
    ├── api_service.dart          # HTTP calls to AI endpoints
    ├── auth_service.dart         # Authentication logic wrapper
    └── database_service.dart     # Firestore and Supabase interactions
