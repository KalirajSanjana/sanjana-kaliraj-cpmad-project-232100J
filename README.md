# 👵 ElderCare+ : A Smart Health Companion for Enabled Ageing

**Module:** CPMAD  
**Name:** Kaliraj Sanjana  
**Admin Number:** 232100J  
**Key Domain:** Health & Enabled Ageing  

---

## 📌 Project Overview

ElderCare+ is a mobile application designed to support Singapore’s ageing population by providing accessible health management tools for seniors.

The application leverages **Firebase services** and **Open Government Data (data.gov.sg)** to enable elderly users to manage medications, track basic health records, and locate nearby subsidised CHAS clinics.

The goal is to promote **independent living, active ageing, and digital inclusion** under Singapore’s Smart Nation initiative.

---

## 🏥 Problem Statement

As Singapore’s population ages:
- Seniors require regular healthcare access.
- Medication management becomes critical.
- Many older adults struggle with remembering schedules.
- Finding subsidised clinics may not be straightforward.
- Health records are often manually tracked.

ElderCare+ provides a simple, user-friendly mobile solution to address these challenges.

---

## 🎯 Objectives

The application aims to:

- Assist elderly users in managing personal health information  
- Provide a simple and intuitive UI suitable for seniors  
- Enable users to locate nearby subsidised healthcare facilities  
- Promote independent and active ageing  
- Support Singapore’s Smart Nation initiative  

---

## 🚀 Key Features

### 🔐 1. User Authentication
- Email and password registration
- Login and logout functionality
- Firebase Authentication integration
- Persistent login state across app restarts

---

### 💊 2. Medication Reminder Management
- Add medication name, dosage, and reminder time
- Dynamic ListView display
- Edit and delete medication entries
- Data stored in Cloud Firestore

---

### ❤️ 3. Basic Health Log Tracking
- Record blood pressure
- Record heart rate
- Add health notes
- View historical logs
- Filter logs by date
- Secure storage in Cloud Firestore

---

### 🗺️ 4. Nearby CHAS Clinics (Dataset-Driven Map)
- Retrieve CHAS clinic dataset (GeoJSON) from data.gov.sg
- Display clinic markers on interactive map
- Search clinics by name or area
- View clinic details (name, address, contact)

---

## 🗄️ Data Architecture

### 📡 Data Sources
- CHAS Clinics GeoJSON dataset from data.gov.sg

### ☁️ Firebase Services Used

| Service | Purpose |
|----------|----------|
| Firebase Authentication | User login & registration |
| Cloud Firestore | Medication & health log storage |
| Firebase Storage | Profile image storage |
| SharedPreferences | Theme preference storage |

All data is dynamically stored.  
No hardcoded data is used in the application.

---

## 🔄 State Management

The application uses **Provider** for state management:

- Authentication state
- Medication data state
- Health log data state
- Theme state (light/dark mode)

Provider ensures reactive UI updates and clean architecture.

---

## 🧠 Technical Stack

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- SharedPreferences
- Provider (State Management)
- Google Maps / Flutter Map
- Open Government Data API (data.gov.sg)

---

## 📱 Target Users

- Elderly users (Primary)
- Caregivers (Secondary)

Designed with:
- Large fonts
- Simple navigation
- Clear layout
- Minimal complexity

---

## 🏗️ Additional Enhancements

- About Page
- Call and Email Features
- Add Reminder to HomePage


---

## 📚 References

- Data.gov.sg – Open Government Data Portal  
  https://developers.data.gov.sg  

- Ministry of Health (MOH) – Community Health Assist Scheme (CHAS)  
  https://www.moh.gov.sg  

- Firebase Documentation  
  https://firebase.google.com/docs  

---

## 👩‍💻 Author

**Kaliraj Sanjana**  
Diploma in Infocomm & Media Engineering  
Nanyang Polytechnic  

---

> ElderCare+ empowers seniors to manage their health confidently and independently through technology.
