# Release Crash Fixes – Coin Celler Wallet App

## Root Causes Identified & Fixed

### 1. **Missing INTERNET Permission (CRITICAL)**
**Problem:** The app makes HTTP requests via `ApiService` (login, signup, wallet operations) but `AndroidManifest.xml` was missing the `INTERNET` permission. In release builds, this permission is strictly enforced and causes immediate crash on first network access.

**Fix Applied:**
- Added `<uses-permission android:name="android.permission.INTERNET" />` to AndroidManifest.xml
- Added `<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />`

**File Modified:** `android/app/src/main/AndroidManifest.xml`

---

### 2. **Missing Network Security Configuration**
**Problem:** Android 9+ requires explicit network security policies. HTTPS connections may fail in release if the app doesn't properly declare security settings.

**Fix Applied:**
- Created `network_security_config.xml` to configure HTTPS trust anchors
- Updated AndroidManifest to reference the network security config via `android:networkSecurityConfig`

**File Created:** `android/app/src/main/res/xml/network_security_config.xml`
**File Modified:** `android/app/src/main/AndroidManifest.xml`

---

### 3. **Unhandled Asset Loading Failures**
**Problem:** In release builds, asset loading is stricter. If `Image.asset("assets/images/logo.png")` fails (missing file, wrong path, or build issue), the app crashes with no fallback.

**Fix Applied:**
- Added `errorBuilder` parameter to both image loads in `AuthScreen` and `SplashScreen`
- Provides safe fallback icon if asset fails to load

**Files Modified:**
- `lib/screens/auth_screen.dart`
- `lib/screens/splash_screen.dart`

---

### 4. **Missing Error Handling in ApiService**
**Problem:** Network timeouts and request failures were silently caught with bare `catch (_)` clauses. In release, unlogged exceptions and race conditions can cause crashes.

**Fix Applied:**
- Added `.timeout(const Duration(seconds: 30))` to all HTTP requests to prevent indefinite hangs
- Implemented proper error logging via `debugPrintStack`
- Added try-catch blocks to instance methods (`flashCrypto`, `getWalletBalance`, `transferCrypto`)
- Maintained silent failures for login/signup (returns false) but now logs errors

**File Modified:** `lib/services/api_service.dart`

---

### 5. **Unprotected setState() After Navigation**
**Problem:** In `ProfileScreen.loadCurrency()` and `changeCurrency()`, the app called `setState()` without checking if the widget was still mounted. In release, async operations can complete after the screen is popped, causing "setState on disposed widget" crashes.

**Fix Applied:**
- Added `if (mounted)` checks before all `setState()` calls
- Wrapped async operations in try-catch to prevent unhandled promise rejections

**File Modified:** `lib/screens/profile_screen.dart`

---

### 6. **Missing Guarded Main Entry Point**
**Problem:** Unhandled exceptions during startup (before any UI is rendered) would crash the app silently in release mode without logging.

**Fix Applied:**
- Added `WidgetsFlutterBinding.ensureInitialized()` at app startup
- Wrapped `runApp()` in `runZonedGuarded()` to capture unhandled zone errors
- Added `FlutterError.onError` handler to forward Flutter errors to zone handler
- All errors are now logged via `debugPrint` and visible in logcat

**File Modified:** `lib/main.dart`

---

## Summary of Changes

| File | Change | Impact |
|------|--------|--------|
| `android/app/src/main/AndroidManifest.xml` | Added INTERNET & NETWORK_STATE permissions + network security config reference | **CRITICAL** – Fixes permission denial crashes |
| `android/app/src/main/res/xml/network_security_config.xml` | Created new file with HTTPS trust configuration | Ensures HTTPS connections work in release |
| `lib/main.dart` | Added `WidgetsFlutterBinding`, `FlutterError.onError`, `runZonedGuarded` | Captures and logs all startup errors |
| `lib/screens/auth_screen.dart` | Added `errorBuilder` to logo image | Gracefully handles asset load failures |
| `lib/screens/splash_screen.dart` | Added `errorBuilder` to logo image | Gracefully handles asset load failures |
| `lib/screens/profile_screen.dart` | Added `mounted` checks + try-catch in async callbacks | Prevents setState on disposed widget crashes |
| `lib/services/api_service.dart` | Added timeouts, error logging, exception handling | Prevents hanging requests and logs failures |

---

## Testing the Fix

### 1. **Build Release APK**
```powershell
cd "C:\Users\USER\Desktop\Plotter Apps\Celler\celler_app"
flutter build apk --release
```

### 2. **Install on Device**
```powershell
adb install -r build\app\outputs\flutter-apk\app-release.apk
```

### 3. **Capture Startup Logs**
```powershell
adb logcat -c
adb logcat | findstr "Flutter|Dart|FATAL|Uncaught"
```

### 4. **Test the App**
- Launch the app and verify it starts without crashing
- Attempt login (will fail without backend, but should not crash)
- Navigate between screens
- Check logcat for any "Uncaught zone error" messages

---

## What Was Crashing Your App

The **primary crash** was the **missing INTERNET permission** in release mode. When the app tried to make its first network request (login screen appears immediately), the system denied the connection, causing an unhandled exception that crashed the app.

Secondary issues (asset loading, network timeouts, setState on disposed widgets) could have caused secondary crashes after the first fix was applied.

All fixes are defensive, backward-compatible, and follow Flutter best practices for release builds.

---

## Next Steps (Optional)

1. **Add local authentication** to `LocalStorageService` for secure credential storage (currently stores in memory)
2. **Implement token-based auth** with refresh token rotation
3. **Add certificate pinning** to prevent man-in-the-middle attacks
4. **Wrap all UI updates** in `if (mounted)` consistently across all screens
