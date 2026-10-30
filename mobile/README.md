# tracelens

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Google Sign-In setup

Google Sign-In is integrated through Flutter's `google_sign_in` plugin. To enable it:

1. Create an OAuth 2.0 **Web application** client ID in Google Cloud Console and configure the OAuth consent screen.
2. For web testing, replace the `YOUR_GOOGLE_SIGN_IN_OAUTH_CLIENT_ID.apps.googleusercontent.com` value in `web/index.html` with the client ID. Add `http://localhost` and `http://localhost:7357` as authorized JavaScript origins.
3. Start the browser build on that origin:

   ```powershell
   flutter run -d chrome --web-hostname localhost --web-port 7357
   ```

4. In the **same Google Cloud project**, create both a Web application OAuth client and an Android OAuth client. For Android, use:

   - Package name: `com.example.tracelens` (from `android/app/build.gradle.kts`)
   - SHA-1: the certificate used to sign the APK installed on the phone

   This project currently signs release APKs with the debug keystore. On this development machine its SHA-1 is `9D:3E:F2:CF:DA:F9:D0:9A:A8:E4:8D:FE:3B:09:6E:D6:F8:7B:AB:0A`. If you switch to a private release key or Google Play App Signing, create another Android OAuth client using that signing certificate's SHA-1.

The app now uses the Web client ID in `web/index.html` as the Android `serverClientId` by default. You can override it when building if needed:

   ```powershell
   flutter build apk --release --dart-define=GOOGLE_WEB_CLIENT_ID=your-web-client-id.apps.googleusercontent.com
   ```

If the Google consent screen is in **Testing** mode, add the Google account used on the phone to its test users. The Android OAuth client uses the package name and signing SHA-1; the Web client ID is passed by the Flutter app as `serverClientId`.

The app stores Google profile fields locally to personalize the interface. Scan history also remains device-local; accounts and history do not sync between devices. A production deployment should verify Google ID tokens on a backend and use server-managed sessions.
