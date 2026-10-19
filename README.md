# iOS Firebase Crashlytics Test (without Siprocal SDK)

This Flutter application verifies that an intentional native crash appears in your Firebase Crashlytics console. This `crash-without-sdk` branch is the comparison variant without the Siprocal / DigitalReef SDK. Use `crash-sdk` to repeat the test with that SDK integrated.

The **Generar crash** button calls `FirebaseCrashlytics.instance.crash()` and deliberately closes the app. Before crashing, the app adds `test_type=native_crash` and a log entry.

## Required configuration

`ios/Runner/GoogleService-Info.plist` is intentionally empty and remains at the path already referenced by Xcode. Fill it with the complete Firebase configuration for your own iOS app before building or running. The empty file is a delivery placeholder, not a working configuration.

This branch does not use LocalConfig.plist, the SDK notification extension, or SDK App Groups.

### Firebase: GoogleService-Info.plist

1. Open your project in the [Firebase console](https://console.firebase.google.com/).
2. Under **Project settings → General → Your apps**, register or select an iOS app whose bundle identifier matches **Runner → Signing & Capabilities → Bundle Identifier** in Xcode. If you use a different identifier, update Runner in Debug, Profile, and Release and register that identifier in Firebase.
3. Download that iOS app's **GoogleService-Info.plist**.
4. Paste the **entire contents** of the downloaded file, including its XML structure, into `ios/Runner/GoogleService-Info.plist`. Alternatively, copy the downloaded file over the empty one:

   ```sh
   cp /path/to/your/GoogleService-Info.plist ios/Runner/GoogleService-Info.plist
   ```

Use all fields supplied by Firebase, including `API_KEY`, `GOOGLE_APP_ID`, `GCM_SENDER_ID`, `PROJECT_ID`, and `BUNDLE_ID`. They must belong to your project and iOS app. Keep the exact filename `GoogleService-Info.plist`.

Firebase initialization and the Xcode resource reference are already configured. See [Firebase's Apple configuration instructions](https://firebase.google.com/docs/ios/setup).

## Signing and App Groups

After installing dependencies, open **`ios/Runner.xcworkspace`** in Xcode. Under **Runner → Signing & Capabilities**, select your Apple development **Team** and a bundle identifier owned by your team. Runner's identifier must match `BUNDLE_ID` in your Firebase plist in Debug, Profile, and Release.

No App Groups are configured on this branch. When testing `crash-sdk`, configure your own App Groups for Runner and RichNotification as described in that branch's README. Update `dbAppGroup` and `userDefaultsAppGroup` in both targets' Info.plist files and the matching `com.apple.security.application-groups` entries in both entitlements files. The existing App Group values in the SDK code are retained for the client to configure.

## Install and run

Use macOS with Flutter, Xcode, and CocoaPods installed. This branch targets iOS 15 or later. Choose a compatible device or simulator.

After completing your configuration:

```sh
flutter pub get
cd ios
pod install
cd ..
open ios/Runner.xcworkspace
flutter devices
flutter run --release -d <iphone-device-id>
```

For a compatible simulator, use `flutter run --debug -d <simulator-device-id>`. Use Release on a physical iPhone so the installed app can be reopened from its icon for the crash test.

## Verify the crash in your Firebase console

1. Launch the app and wait for **Crashlytics listo** (Crashlytics ready).
2. Stop the Xcode or Flutter run session, then reopen the installed app from its icon with no debugger attached.
3. Tap **Generar crash** (generate crash). The app closes intentionally.
4. Reopen the **same installation** with internet access and leave it open to upload the pending report. Do not uninstall between the crash and this restart.
5. Open **your Firebase project → Crashlytics**, select your iOS app, and wait a few minutes. Find the native crash and its `test_type=native_crash` custom key.

If no report appears, check your configuration, connectivity, matching bundle identifier, and restart without a debugger. If Firebase reports missing symbols, check Runner's existing **Crashlytics Upload Symbols** phase and the dSYM from the exact build that crashed.

The interface is in Spanish. **Reintentar** means retry if initialization fails. Keep your completed configuration files local rather than committing your project data.
