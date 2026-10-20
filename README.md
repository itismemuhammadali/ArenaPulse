<div align="center">

<p align="center">
  <img src="assets/branding/logo.jpg" alt="ArenaPulse Sports & Community Chat Logo" width="180" style="border-radius: 24px; box-shadow: 0 8px 32px rgba(249, 115, 22, 0.35);" />
</p>

# ArenaPulse

### Sports Turf & Court Reservation, Athletic Club Hub & Team Matchmaking Ecosystem

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20FCM-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Google Maps](https://img.shields.io/badge/Maps-Google%20%26%20OSM-4285F4?style=for-the-badge&logo=google-maps&logoColor=white)](https://cloud.google.com/maps-platform)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)

<p align="center">
  <b>ArenaPulse</b> is a modern, cross-platform sports networking and venue booking ecosystem designed for recreational athletes, local sports clubs, and facility owners. Seamlessly coordinate turf bookings, join neighborhood teams, vote in match polls, and coordinate game days in real time.
</p>

</div>

---

## 🌟 Platform Capabilities

ArenaPulse addresses the friction of organizing casual and competitive sports games by uniting facility scheduling with community matchmaking:

```mermaid
graph TD
    subgraph ArenaPulse Ecosystem
        direction TB
        App[ArenaPulse Unified Engine]
        App --> P[Player / Athlete Role]
        App --> O[Facility & Venue Owner Role]
        App --> A[Platform Super Admin]
    end

    subgraph Player Experience
        P --> P1[Turf & Court Discovery on Map]
        P --> P2[Slot Reservation & Split Booking]
        P --> P3[Sports Club Group Chats]
        P --> P4[Interactive Match Polls & Events]
        P --> P5[Discover Local Players & Opponents]
    end

    subgraph Facility Owner Experience
        O --> O1[Venue & Court Onboarding]
        O --> O2[Dynamic Pricing & Slot Schedules]
        O --> O3[Booking Pipeline & Attendance]
        O --> O4[Customer Communication Channel]
    end

    subgraph Platform Governance
        A --> A1[Global Facility Verification]
        A --> A2[Content & Community Moderation]
        A --> A3[User Block & Report Safeguards]
    end
```

---

## ⚽ Booking & Match Coordination Flow

```mermaid
sequenceDiagram
    autonumber
    actor Player as Team Captain / Player
    participant App as ArenaPulse Platform
    actor Owner as Turf / Facility Owner
    participant Firebase as Firebase Realtime Cloud

    Player->>App: Browse Nearby Turfs via Interactive Map
    App->>Firebase: Fetch Available Time Slots & Court Amenities
    Player->>App: Select Date, Time Slot & Confirm Booking
    App->>Owner: Instant Push Notification of New Reservation
    Owner->>App: Acknowledge & Lock Court Slot
    Player->>App: Share Match Event to Club Group Chat
    App->>Firebase: Broadcast Roster Invite & Polling Widget
    Note over Player: Squad votes on setlists, positions, and headcount
    App-->>Player: Automated Game Day Reminder Notification
```

---

## ✨ Core Features

### 🏟️ 1. Venue & Slot Booking
- **Dual Map Support:** Integrated Google Maps and OpenStreetMap (OSM) for seamless global and local location discovery.
- **Granular Scheduling:** Reserve cricket pitches, football turfs, padel courts, tennis courts, and basketball arenas by the hour.
- **Dynamic Slot States:** Real-time visibility into open, held, and confirmed reservations to eliminate double-booking.

### 💬 2. Community & Club Hub
- **Sports Clubs:** Create public or private sports clubs (e.g. "Downtown Futsal Club", "Sunday Morning Cricket").
- **Real-Time Group Chat:** Instant messaging with media sharing, match coordination, and push notifications.
- **Interactive Match Polls:** Create headcounts and RSVP polls to finalize player rosters before match day.

### 🛡️ 3. Safety, Security & Admin
- **Community Moderation:** Built-in reporting and user blocking mechanisms with admin review tools.
- **Facility Owner Dashboard:** View earnings, peak hour utilization, and booking history in a dedicated owner view.
- **Cross-Platform Support:** Native experience across iOS, Android, Web, macOS, Linux, and Windows.

---

## 📁 Repository Structure

```
ArenaPulse/
├── assets/
│   └── branding/
│       └── logo.png               # Official brand asset
├── backend/                       # PHP media upload & storage service
├── functions/                     # Firebase Cloud Functions (Push notifications, auto-cleanup)
├── lib/
│   ├── main.dart                  # Application bootstrap
│   ├── firebase_options.dart      # Multi-platform Firebase configuration
│   └── src/
│       ├── screens/               # 38+ Application Screens (Book slot, club profile, maps)
│       ├── services/              # 28+ Business Services (Auth, bookings, clubs, locations)
│       ├── tabs/                  # Feed tabs (Polls, events, media posts, comments)
│       ├── utils/                 # Engagement & calculation helpers
│       └── widgets/               # Turn-by-turn overlay, dialogs, bottom nav
├── test/                          # Unit and widget test suite
├── firestore.rules                # Hardened Firestore security rules
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK:** `>= 3.9.0`
- **Firebase Project:** (Authentication, Firestore, Cloud Messaging, Storage)
- **Google Maps API Key:** (Optional for Google Maps rendering; OSM works out of the box)

### Quick Start
```bash
# Clone the repository
git clone https://github.com/itismemuhammadali/ArenaPulse.git
cd ArenaPulse

# Install dependencies
flutter pub get

# Launch on connected mobile device or simulator
flutter run
```

---

## 🔒 Confidentiality & White-Label Notice
This repository is an open-source demonstration and portfolio showcase. All proprietary client data, commercial vendor contracts, live API tokens, and client credentials have been sanitized and decoupled.

---

## 👨‍💻 Author
**Muhammad Ali**
- GitHub: [@itismemuhammadali](https://github.com/itismemuhammadali)
- Portfolio & Engineering Showcase
