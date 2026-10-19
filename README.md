# iOS Firebase Crashlytics Test

This Flutter application verifies that an intentional native crash appears in your Firebase Crashlytics console while the Siprocal / DigitalReef SDK is integrated. The `crash-sdk` branch includes the SDK; `crash-without-sdk` provides a comparison with only Firebase Crashlytics.

The **Generate crash** button calls `FirebaseCrashlytics.instance.crash()` and deliberately closes the app. This tests crash reporting with the SDK present; it does not reproduce a crash caused by the SDK. Before crashing, the app adds `test_type=native_crash` and a log entry.

## Required configuration

These files are intentionally empty and remain at the paths already referenced by Xcode:

| File | Contents you must provide |
| --- | --- |
| `ios/Runner/GoogleService-Info.plist` | The complete Firebase configuration for your own iOS app. |
| `ios/Runner/LocalConfig.plist` | The complete Siprocal / DigitalReef configuration for your organization (`crash-sdk` only). |

Fill the required files and configure signing and App Groups before running. Empty files are delivery placeholders, not working configurations.

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

### SDK: LocalConfig.plist (`crash-sdk` only)

Paste the full SDK configuration supplied for your organization into `ios/Runner/LocalConfig.plist`. This is the Siprocal / DigitalReef configuration, not a second Firebase configuration.

The existing integration uses this structure. Replace the three `YOUR_...` values with the values supplied for your SDK account and confirm the remaining options against your integration settings:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>organizationType</key>
    <string>static</string>
    <key>organization</key>
    <string>YOUR_SDK_ORGANIZATION</string>
    <key>organizationId</key>
    <string>YOUR_SDK_ORGANIZATION_ID</string>
    <key>baseOrganization</key>
    <string>YOUR_SDK_BASE_ORGANIZATION</string>
    <key>orgSelection</key>
    <string>HOST_APP</string>
    <key>timerTriggerConfig</key>
    <string>86400</string>
    <key>version</key>
    <string>2</string>
    <key>buildType</key>
    <string>SDK</string>
    <key>variant</key>
    <string>chronos</string>
</dict>
</plist>
```

The `crash-without-sdk` branch does not use LocalConfig.plist or the SDK notification extension.

## Signing and App Groups

After installing dependencies, open **`ios/Runner.xcworkspace`** in Xcode. Select your Apple development **Team** and bundle identifiers for Runner and, on `crash-sdk`, RichNotification. The extension's identifier must use the app's identifier as its prefix, for example `com.yourcompany.crashtest.RichNotification`. Runner's identifier must match the Firebase plist.

On `crash-sdk`, register your own App Groups in your Apple Developer account and enable the same two groups for **Runner** and **RichNotification** under **Signing & Capabilities → App Groups**. The project retains its existing group values. Replace them with groups owned by your team when configuring your copy:

| Setting | Existing value to replace |
| --- | --- |
| `dbAppGroup` | `group.db.digitalreef.com` |
| `userDefaultsAppGroup` | `group.digitalreef.com` |

Keep the values consistent in all four files:

- `ios/Runner/Info.plist`: `dbAppGroup` and `userDefaultsAppGroup`.
- `ios/RichNotification/Info.plist`: the same two keys.
- `ios/Runner/Runner.entitlements`: both entries under `com.apple.security.application-groups`.
- `ios/RichNotification/RichNotification.entitlements`: the same two group entries.

Use provisioning profiles that support the existing capabilities, including App Groups and Push Notifications. This setup applies to the SDK branch.

## Install and run

Use macOS with Flutter, Xcode, and CocoaPods installed. Choose a device or simulator compatible with the deployment targets in Xcode; on `crash-sdk`, RichNotification currently targets iOS 27.

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

1. Launch the app and wait for **Crashlytics ready**.
2. Stop the Xcode or Flutter run session, then reopen the installed app from its icon with no debugger attached.
3. Tap **Generate crash**. The app closes intentionally.
4. Reopen the **same installation** with internet access and leave it open to upload the pending report. Do not uninstall between the crash and this restart.
5. Open **your Firebase project → Crashlytics**, select your iOS app, and wait a few minutes. Find the native crash and its `test_type=native_crash` custom key.

If no report appears, check your configuration, connectivity, matching bundle identifier, and restart without a debugger. If Firebase reports missing symbols, check Runner's existing **Crashlytics Upload Symbols** phase and the dSYM from the exact build that crashed.

The interface is in English. Tap **Retry** if initialization fails. Keep your completed configuration files local rather than committing your project data.
