## 🎱 Snooker Club Booking App - Melaka

A complete digital booking and table management system designed for a real snooker store located in Melaka, Malaysia. 

This application bridges the gap between online reservations and physical in-store gameplay. Users can book time slots in advance, see which tables are currently occupied in real-time, and scan a physical QR code at the table to start their session.

## ✨ Key Features

* **Live Table Dashboard:** A grid view showing the real-time status of all tables (Available = Green, Occupied = Red).
* **Time-Slot Booking:** Users can select a specific table and reserve future time slots.
* **In-Store QR Code Integration:** Physical tables have QR codes containing JSON data. Users scan the QR code via the app upon arrival to activate their pre-booked session or start a new walk-in session.
* **User Authentication:** Secure sign-up and login flow.
* **Cloud Database:** Powered by Supabase for secure, real-time data syncing.

## 🛠 Tech Stack

* **Frontend:** [Flutter](https://flutter.dev/) (Dart)
* **Backend as a Service:** [Supabase](https://supabase.com/)
* **Database:** PostgreSQL (via Supabase)
* **Key Flutter Packages:** * `supabase_flutter` (Database & Auth)
  * `mobile_scanner` (QR Code reading)
  * `intl` (Date/Time formatting)

## 📱 How the QR System Works

To prevent scanning errors and tampering, the physical QR codes on the tables in the Melaka store contain JSON payloads rather than simple text or URLs. 

**Example QR Code Data:**
