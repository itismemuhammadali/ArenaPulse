# Platform Overview, Credentials & Suggested Brand Names

---

## 1. Booking System Status: 100% Created & Fully Operational

Yes, the sports facility and net booking system is **fully created, tested, and actively functioning**. 

Here is what is built and working:

### Customer Slot Booking Experience (`BookSlotScreen`)
* **Interactive Date Picker**: Select today, tomorrow, or future dates.
* **1-Hour Slot Grid (6:00 AM – 11:00 PM)**: Clean slot selector showing clear availability.
* **Collision Prevention**: Already-reserved slots are automatically disabled and grayed out in real time so double-bookings cannot occur.
* **Cash on Arrival**: Seamless reservation with zero online gateway or credit card friction.
* **Cost Summary**: Automatically calculates total PKR amount based on net hourly rate and duration.

### Customer Reservation Manager (`CustomerBookingsScreen` at `/#/my-bookings`)
* Lists all active upcoming bookings and past history.
* Displays venue name, net name, date, time slot, and cash amount to pay at the counter.
* Instant cancellation option for customers.

### Facility & Net Owner Management (`OwnerDashboardScreen` at `/#/owner`)
* **Nets Tab**: Manage court dimensions (Length, Width, Height in feet), shapes (Box, Rectangular, Circular), hourly rate in PKR, and photo gallery.
* **Bookings Tab**: Real-time list of reservations with player name, phone number, and exact cash to collect on arrival.
* **Revenue Tab**: Monthly sales totals, booking volume, and revenue analytics.

### Super Admin Platform Oversight (`SuperAdminDashboardScreen` at `/#/admin`)
* Platform-wide gross booking volume.
* Facility-wise monthly revenue breakdown charts.
* Venue inspector tracking profile visits (184 views recorded).
* User complaints and issue resolution hub.

---

## 2. Platform User Credentials

### Super Admin Account
* **Email**: `admin@sprintindex.com`
* **Password**: `Password123!`
* **Web Portal Link**: `http://localhost:3000/#/admin`
* **Role Key in Firestore**: `super_admin`
* **Access Scope**: Full platform executive control, gross booking volume, sales charts, facility inspector, complaints moderation.

### Facility / Net Owner Account
* **Email**: `owner@sprintindex.com`
* **Password**: `Password123!`
* **Web Portal Link**: `http://localhost:3000/#/owner`
* **Role Key in Firestore**: `facility_owner`
* **Access Scope**: Onboarding wizard, net dimension & rate editor (PKR/hr), bookings list with cash-to-collect details, and monthly revenue analytics.

### Customer / Player Account
* **Name**: Ali Ahmed
* **Email**: `player@sprintindex.com`
* **Password**: `Password123!`
* **Web Portal Link**: `http://localhost:3000/#/`
* **Role Key in Firestore**: `customer`
* **Access Scope**: Social community feed, OpenStreetMap venue discovery, net slot booking (Cash on Arrival), and my reservations manager (`/#/my-bookings`).

---

## 3. 20 Suggested Names for the Platform

If you are looking to rebrand the platform or give it a fresh consumer identity, here are 20 curated name suggestions categorized by style:

### Tech-Forward & Booking Focused
1. **TurfSync** — Modern, clean, implies real-time net and court availability synchronization.
2. **PitchPass** — Punchy and memorable; conveys instant pass/access to any sports pitch.
3. **SlotPlay** — Clear, self-explanatory, highlights easy slot booking and quick play.
4. **ArenaPulse** — Energetic and premium; represents the heartbeat of local sports arenas.
5. **FieldHQ** — Authoritative, central hub for all venues and player bookings.

### Action & Community Oriented
6. **PlaySphere** — Encompasses the entire sports ecosystem (community, chat, and booking).
7. **MatchGrid** — Focuses on finding open slots, organizing matches, and playing.
8. **NetVibe** — Young, social, and upbeat; great for cricket nets and padel courts.
9. **SportSpot** — Friendly, easy to remember, marks every venue on the map as a "spot".
10. **GamePoint** — Classic sports terminology that symbolizes readiness and booking.

### Local & Regional Focus (Twin Cities / Pakistan)
11. **TwinTurf** — Perfectly tailored for the Rawalpindi and Islamabad twin cities market.
12. **PlayHub PK** — Recognizable and patriotic, scalable across Pakistani cities.
13. **ProPitch** — Conveys quality, professional turf standards, and high-tier nets.
14. **UrbanArena** — Fits urban rooftop padel courts, commercial market cricket nets, and futsal turfs.
15. **NexCourt** — Sleek, modern name suited for next-generation padel, tennis, and badminton venues.

### Short, Modern & Brandable
16. **TurfX** — Short, futuristic, strong brand identity.
17. **Courtly** — Elegant, friendly app name ideal for racket sports and facility reservations.
18. **Netto** — Catchy two-syllable brand name specifically celebrating net sports.
19. **Playr** — Trendy tech spelling; puts the player at the center of the experience.
20. **Turfio** — Modern SaaS-style brand name that sounds approachable and smooth.

---

## 4. Crater Code Branding Integration

* **Brand Name**: Updated to **Crater Code** across the Splash screen, Login screen, Sign-up screen, and Flow Navigator.
* **Dark Theme Logo**: Integrated at `lib/assets/crater_code_dark.png` (Hexagonal reticle with orange accent).
* **Light Theme Logo**: Integrated at `lib/assets/crater_code_light.png` (Hexagonal mark with "CRATER CODE" typography).
* **Theme Awareness**: Both logos are loaded dynamically using `Theme.of(context).brightness == Brightness.dark`.
