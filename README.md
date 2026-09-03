# Smart Radar & Speed Camera Warning Navigation App (Flutter)

A modern, high-performance Flutter navigation application designed to assist drivers with real-time speed camera detection, police radar alerts, AI-driven traffic predictions, route optimization ("Fastest" vs "Safest"), and crowdsourced hazard reporting.

---

## 🌟 Key Features

### 1. 🗺️ Real-time OpenStreetMap (OSM) & Radar Warning Engine
- **Dark Mode HUD Map**: Built with `flutter_map` (OpenStreetMap / CartoDB raster tiles) optimized for low battery usage and zero Google Maps API costs.
- **Proximity Alerts**: Continuously monitors the driver's location relative to fixed speed cameras, mobile police radars, and road hazards.
- **Speedometer HUD**: Real-time speed gauge showing current speed vs speed limit, pulsing warning glow when approaching speed traps above the limit.
- **Next Radar Banner**: Live distance countdown and one-tap community confirmation sheet (+5 Karma points).
- **TTS Audio Alerts**: Multilingual text-to-speech voice announcements for speed cameras and hazard alerts via `flutter_tts`.

### 2. ⚡ Route Planning & Turn-by-Turn Navigation
- **Route Comparison**: Interactive side-by-side comparison of **Fastest** vs **Safest** routes (risk score, camera counts, time, and distance).
- **Turn-by-Turn HUD**: Step-by-step maneuver guidance with clear directional banners and real-time remaining distance.
- **Dynamic Re-Routing**: Auto-detects speed traps or sudden hazards along your path and prompts you to switch to a safer bypass route.

### 3. 🤖 AI Driving Copilot & Voice Assistant
- **Conversational Traffic Intelligence**: Ask the AI copilot about road outlook, radar hotspots, route advice, or weekly driving analysis.
- **Speech-to-Text Voice Input**: Hands-free voice recognition via `speech_to_text` with an animated voice wave indicator.
- **Rich Structured Insight Cards**: Interactive UI cards for weekly summaries, radar hotspot sector breakdowns, and risk forecasts.

### 4. 📢 Crowdsourced Road Hazard Reporting
- **One-Tap Reporting**: 6 hazard categories: Speed Camera, Police Radar (GAY), Car Accident, Road Works, Traffic Jam, and Pothole/Hazard.
- **Community Feed & Verification**: Drivers upvote and verify active hazards to maintain high data accuracy (+2 Karma points per confirmation).

### 5. 🏆 Gamification & Driver Profile
- **Safety Score Gauge**: Dynamic circular rating (0–100) based on speed limit adherence and safe driving habits.
- **Achievements & Badges**: Unlockable achievements (e.g., *Safe Master*, *Zero Speeding Week*, *Hazard Spotter*, *Night Owl*).
- **Community Leaderboard**: Compete with other drivers in your city.

### 6. 🌐 Multilingual & Settings
- **Trilingual Support**: English (EN), Russian (RU), and Uzbek (UZ) with instant runtime switching.
- **Offline / Mock-First Architecture**: 100% functional out-of-the-box with mock repositories and an integrated **Drive Simulator** for testing without driving.
- **REST API Switcher**: In-app developer dialog to switch between Mock mode and a real REST backend URL.

---

## 🏗️ Architecture & Folder Structure

The project strictly follows **Clean Architecture** principles separated into feature-driven modules with `flutter_riverpod`:

```text
lib/
├── core/
│   ├── constants/
│   │   ├── api_endpoints.dart    # Catalog of all REST API endpoints
│   │   ├── app_colors.dart       # Neon HUD dark/light color palettes
│   │   └── app_typography.dart   # Digital HUD monospace & typography hierarchy
│   ├── localization/
│   │   └── app_localizations.dart# Trilingual engine (EN, RU, UZ)
│   ├── network/
│   │   ├── api_client.dart       # Dio HTTP client wrapper with interceptors
│   │   └── api_response.dart     # Generic ApiResponse<T> and ApiException models
│   ├── services/
│   │   ├── audio_alert_service.dart # TTS voice synthesis & audio alert player
│   │   ├── location_service.dart    # Geolocator stream & route drive simulator
│   │   └── storage_service.dart     # SharedPreferences persistence
│   └── theme/
│       └── app_theme.dart        # Material 3 dark/light themes
│
├── features/
│   ├── onboarding/               # Splash screen, language selector, permission flow
│   ├── map_radar/                # Live OSM map, speedometer HUD, radar proximity alerts
│   ├── navigation/               # Route planning (Fastest vs Safest), turn-by-turn navigation
│   ├── ai_agent/                 # AI driving copilot, voice recognition, insight cards
│   ├── reports/                  # Hazard reporting & community verification feed
│   ├── profile/                  # Driver safety score gauge, badges grid, leaderboard
│   └── settings/                 # Units, voice toggles, language, mock/REST switcher
│
├── main.dart                     # App entry point with ProviderScope
└── main_screen_wrapper.dart      # Bottom navigation bar controller (5 tabs)
```

---

## 🔌 Connecting to a Real Backend API

The app uses an **Interface-First Repository Pattern**. Every feature defines an abstract repository interface in `domain/repositories/` with two implementations in `data/`:
1. `Mock...Repository` — Offline, zero-dependency data for testing and development.
2. `Rest...Repository` — Live HTTP requests using `Dio` via `ApiClient`.

### Dynamic Switcher:
You can toggle between **Mock Data** and **Real REST API** directly inside the app:
1. Open the **Profile** tab and tap the **Settings** icon in the top-right corner.
2. Under *Developer & Backend*, tap **API & Network Configuration**.
3. Toggle off **Use Mock Data**, enter your server's **Base URL** (e.g., `https://api.yourdomain.com/v1`), and tap **Save & Apply**.

All Riverpod providers will automatically swap to the `Rest...Repository` implementations without restarting the app!

### REST API Endpoints Catalog:
Refer to [`lib/core/constants/api_endpoints.dart`](lib/core/constants/api_endpoints.dart) for the complete list of backend endpoints:
- `GET /api/v1/radars/nearby` — Get speed cameras near coordinate
- `POST /api/v1/radars/{id}/confirm` — Confirm camera presence
- `POST /api/v1/navigation/plan` — Plan fastest and safest routes
- `POST /api/v1/ai/chat` — AI copilot conversational chat
- `GET /api/v1/ai/insights` — Weekly driving insights
- `POST /api/v1/reports` — Submit crowdsourced road hazard
- `GET /api/v1/user/profile` — Fetch driver profile and badges

---

## 🚗 Built-in Drive Simulator

To test speed camera warnings, turn-by-turn HUD, and dynamic re-routing without driving a vehicle:
1. Tap the **Simulate Drive (68 km/h)** floating chip on the **Home / Map** screen, or start navigation along a route.
2. The `LocationService` simulator interpolates coordinates along route polylines every 500ms, broadcasting live location, speed, and heading.
3. Proximity voice alerts and speedometer speed traps will trigger dynamically.

---

## 🚀 Getting Started

### Prerequisites:
- **Flutter SDK:** `>=3.47.0` (Dart `>=3.13.0`)
- **Android Studio / Xcode** (for simulator/device runs)

### Setup & Run:
```bash
# 1. Clone repository
git clone https://github.com/your-username/navigator.git
cd navigator

# 2. Install dependencies
flutter pub get

# 3. Analyze code (zero errors/warnings)
flutter analyze

# 4. Run automated test suite
flutter test

# 5. Launch the application
flutter run
```

---

## 🧪 Testing

The project includes unit tests for repositories, AI services, and localization, as well as widget tests for custom HUD components:
```bash
flutter test
```
All tests are located in the `test/` directory (`test/unit/` and `test/widget_test.dart`).
