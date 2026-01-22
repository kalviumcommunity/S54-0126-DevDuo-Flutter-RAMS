# S54-0126-DevDuo-Flutter-RAMS

## Project Overview

**RAMS (Rural Academic Management System)** is a Flutter-based mobile application designed to help rural coaching centers digitally manage student attendance and academic progress.
The app replaces error-prone paper records with a simple, secure, and real-time digital system for teachers.

---

## Firebase Setup

* Created and configured a Firebase project using **FlutterFire CLI**
* Added platform-specific configuration for Android, iOS, and Web
* Initialized Firebase in `main.dart` using generated `firebase_options.dart`
* Managed Firebase configuration securely via Firebase Console

---

## Authentication

* Implemented **Email/Password authentication** using Firebase Authentication
* Enabled secure teacher login and session persistence
* Restricted app access to authenticated users only

---

## Cloud Firestore (Real-Time Database)

* Used **Cloud Firestore** to store and manage:

  * Student profiles
  * Attendance records
  * Academic performance data
* Implemented **real-time data synchronization** using Firestore snapshot streams
* UI updates automatically when attendance or academic data changes, without manual refresh

---

## System Design & Assumptions

* Frontend built using **Flutter and Dart**
* Backend powered by **Firebase Authentication and Cloud Firestore**
* **State management (Provider/Riverpod)** handles auth state and Firestore streams
* **Firebase Storage** is planned for future features such as student profile images and assignment uploads
* CI/CD is assumed via **GitHub Actions** for build and release
* Security is enforced using **Firestore Security Rules** and authentication guards

---

## Reflection

Integrating Firebase significantly simplified backend development for RAMS.
Firebase Authentication ensures secure access for teachers, while Cloud Firestore enables real-time synchronization of attendance and academic records across devices.
This architecture improves scalability, reliability, and usability, making the application suitable for rural coaching environments with limited digital infrastructure.

---

## Future Enhancements

* Firebase Storage for media uploads
* Offline-first support for low-connectivity areas
* Parent access and analytics dashboard

