# DailyPad — App Store Submission Checklist

## Before You Submit

### Apple Developer Account
- [ ] Enroll in the [Apple Developer Program](https://developer.apple.com/programs/)
- [ ] Create an App ID for bundle ID **`com.dailypad.note`** (must match `ios/Runner.xcodeproj`)
- [ ] Create the app record in [App Store Connect](https://appstoreconnect.apple.com)

### Signing & Build
- [ ] Open `ios/Runner.xcworkspace` in Xcode
- [ ] Set your **Team** under Signing & Capabilities
- [ ] Confirm **Bundle Identifier**: `com.dailypad.note`
- [ ] Build release: `flutter build ipa --release`
- [ ] Upload via Xcode Organizer or `xcrun altool` / Transporter

### App Store Connect Metadata
- [ ] **Name**: DailyPad
- [ ] **Subtitle**: Offline notes & daily tasks
- [ ] **Description**: Use the text in `lib/utils/constants.dart` (`AppStrings.appDescription`) as a base
- [ ] **Keywords**: notes, tasks, offline, planner, organizer, todo
- [ ] **Category**: Productivity
- [ ] **Screenshots**: 6.7", 6.5", and 5.5" iPhone sizes (required)
- [ ] **Support URL**: Page or mailto for `support@dailypad.app` (update email in `constants.dart`)
- [ ] **Privacy Policy URL**: Host the in-app policy text on your website, or use App Store “Privacy Policy” field with the same content as `PrivacyPolicyScreen`

### Privacy (App Store Connect → App Privacy)
- [ ] Select **Data Not Collected** (app stores notes/tasks only on device)
- [ ] No tracking, no third-party analytics SDKs in this project

### Export Compliance
- [ ] **ITSAppUsesNonExemptEncryption** is `false` in `Info.plist` (standard HTTPS only / no custom encryption)
- [ ] Answer “No” for proprietary encryption in App Store Connect unless you add custom crypto

### Age Rating
- [ ] Complete the questionnaire — expect **4+** (no restricted content)

### Review Notes (recommended)
```
DailyPad is fully offline. No login, no server, no notifications.
Notes and tasks are stored locally with Hive on the device.
Settings → Privacy Policy describes data handling.
Settings → Delete All Data removes all user content.
```

## In-App Compliance (already implemented)
- No login, ads, IAP, notifications, camera, mic, location, or biometrics
- In-app Privacy Policy (`Settings → Privacy Policy`)
- Delete All Data (`Settings → Delete All Data`)
- `PrivacyInfo.xcprivacy` manifest in the iOS target
- Portrait-only on iPhone

## Replace Before Production
1. **`AppStrings.supportEmail`** in `lib/utils/constants.dart`
2. Host a **privacy policy URL** on your domain (copy from `lib/screens/privacy_policy_screen.dart`)
3. Optional: change **`com.dailypad.note`** if you use a different bundle ID in App Store Connect

## Versioning
Update in `pubspec.yaml`:
```yaml
version: 1.0.0+1  # name+build
```
