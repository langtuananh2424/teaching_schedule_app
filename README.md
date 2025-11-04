
# Teaching Schedule - Figma -> Flutter

This repository contains a Flutter app (compatible with Flutter 3.35.7) reproducing 5 screens from your Figma designs: Login, Home, Request List, Request Detail, and Report.

## How to run
1. Copy these files into a Flutter project (or unzip and open this folder in your editor).
2. Ensure `assets/images/logo_dhtl.png` exists (included here).
3. Run:

   flutter pub get

   flutter run


## Notes
- API base URL in `lib/services/api_service.dart` is set to `http://10.0.2.2:8080/api` (Android emulator). Change if needed.
- Token is stored via SharedPreferences for auto-login.
