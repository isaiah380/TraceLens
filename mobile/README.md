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

4. For Android, add an Android OAuth client using package name `com.example.tracelens` and your development signing certificate SHA-1. Pass the Web client ID as `GOOGLE_WEB_CLIENT_ID` when launching:

   ```powershell
   flutter run --dart-define=GOOGLE_WEB_CLIENT_ID=your-web-client-id.apps.googleusercontent.com
   ```

The app stores Google profile fields locally to personalize the interface. Scan history also remains device-local; accounts and history do not sync between devices. A production deployment should verify Google ID tokens on a backend and use server-managed sessions.
