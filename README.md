# Technician Service Marketplace App

![Status](https://img.shields.io/badge/Status-Ongoing_Project-orange)
![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Firebase](https://img.shields.io/badge/Firebase-Backend-yellow)

A cross-platform mobile application built with Flutter and Firebase that connects customers with skilled local technicians (plumbers, electricians, cleaners, etc.). 

This project features a dual-role system where Customers can discover and book services, while Technicians have a dedicated command center to manage their jobs, earnings, and professional profiles.

---

## Current Features

### For Customers
* **Role-Based Authentication:** Secure login and registration flow.
* **Discover Technicians:** Browse professionals via categories or a "Near Me" map view.
* **Dynamic Profiles:** View real-time technician profiles, including their bio, verified badges, and dynamic service pricing.
* **Live Booking Engine:** Select a specific service, pick a date from the calendar, set a time, and send a direct booking request to the technician.
* **Reviews & Ratings:** Read transparent, 5-star reviews left by previous customers.

### For Technicians
* **Professional Onboarding:** Upload ID/Certificates (PDF, JPG, DOC) via Firebase Storage for Admin verification.
* **Unverified Sandbox:** Unverified technicians experience a secure blurred dashboard until approved.
* **Custom Command Center (5-Tab Dashboard):**
  * **Home:** View daily earnings and pending request summaries.
  * **Jobs Manager:** Accept or decline new "Pending" requests and manage "Upcoming" active jobs.
  * **History:** Keep track of "Completed" and "Declined" jobs.
  * **Messages:** Dedicated inbox for customer communication *(UI built, backend in progress)*.
  * **Profile Editor:** Dynamically add/remove offered services, set custom hourly rates, upload profile pictures, and write a bio.

---

## Tech Stack
* **Frontend:** Flutter & Dart
* **Backend:** Firebase (Authentication, Cloud Firestore, Firebase Storage)
* **Key Packages:** * `file_picker` & `image_picker` (Native device file handling)
  * `cloud_firestore` (Real-time NoSQL database)
  * `firebase_storage` (Secure document & image hosting)
  * `intl` (Date and time formatting)

---

## Getting Started

### Prerequisites
* Flutter SDK (v3.0.0 or higher)
* A Firebase Project with Authentication, Firestore, and Storage enabled.

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/ParakramaWelipitiya/technician_service_app.git
