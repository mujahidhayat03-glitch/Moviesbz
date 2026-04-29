# 🔥 moviesbz Firebase Deployment Guide

## Kya Kya Add Kiya Gaya:
- ✅ `lib/firebase_options.dart` → Aapka Firebase config
- ✅ `lib/main.dart` → Firebase.initializeApp() add kiya
- ✅ `pubspec.yaml` → firebase_core, cloud_firestore, firebase_storage packages
- ✅ `firebase.json` → Hosting config
- ✅ `.firebaserc` → Project ID: moviesbz-1

---

## Deploy Karne ke Steps:

### Step 1 — Flutter packages install karo
```bash
flutter pub get
```

### Step 2 — Web support enable karo
```bash
flutter config --enable-web
```

### Step 3 — Web build banao
```bash
flutter build web --release
```

### Step 4 — Firebase CLI install karo
```bash
npm install -g firebase-tools
```

### Step 5 — Firebase login karo
```bash
firebase login
```

### Step 6 — Deploy karo! 🚀
```bash
firebase deploy --only hosting
```

### ✅ App Live URL:
```
https://moviesbz-1.web.app
https://moviesbz-1.firebaseapp.com
```

---

## Android APK ke liye:
```bash
flutter build apk --release
# File: build/app/outputs/flutter-apk/app-release.apk
```

---

## ⚠️ Note:
Agar Android pe Google Services chahiye to Firebase Console se
`google-services.json` download karke `android/app/` folder mein rakhein.
