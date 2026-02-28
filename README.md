<div align="center">

# 🛡️ App Guardian

### Parental Control & App Blocker for Android

**Stop gambling / unecessary apps. Protect your loved ones.**

[![Flutter](https://img.shields.io/badge/Flutter-3.7+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Android](https://img.shields.io/badge/Android-8.0+-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://developer.android.com)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)
[![YouTube](https://img.shields.io/badge/GlaceYT-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/@GlaceYT)
[![Discord](https://img.shields.io/badge/Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/xQF9f9yUEM)

---

App Guardian is a **stealth parental control app** that blocks access to gambling and harmful apps like TeenPatti, Rummy, and others. It disguises itself as a **"Device Hub"** utility app, making it undetectable to the person being monitored.

When a blocked app is opened, it shows a fake **"Server Unavailable"** error screen with a random estimated wait time — the user thinks the app is down, not blocked! 😈

</div>

---

## ✨ Key Features

| Feature | Description |
|---------|-------------|
| 🎭 **Stealth Mode** | App disguises itself as "Device Hub" — a device tips utility |
| 🚫 **App Blocking** | Blocks any selected app with a fake "server down" screen |
| 📌 **PIN Protection** | 4-digit PIN to access the real settings |
| 🔒 **Device Admin** | Prevents easy uninstallation |
| 🔄 **Boot Persistent** | Survives device restarts automatically |
| 🎯 **Smart Detection** | Auto-suggests gambling apps to block |
| ⏰ **Fake ETA** | Shows random "expected availability" times (2-12 hours) |
| 🏠 **No Bypass** | Back button is intercepted — only option is "Try Again Later" |

---

## 📱 How It Works

1. **Open the app** → Looks like a normal "Device Hub" utility with performance tips
2. **Long-press the header** (or tap logo 5 times) → Secret entry to the real app
3. **Set up PIN** → Protects all settings
4. **Select apps to block** → Gambling apps are auto-detected
5. **Enable protection** → Blocks the selected apps
6. **When a blocked app opens** → Shows a convincing "Server Unavailable" error

---

## 🚀 Installation Guide

### Prerequisites

Before installing App Guardian, you need to **disable Google Play Protect** so it doesn't flag the app as potentially harmful (since it uses Accessibility Service and Device Admin).

### Step 1: Disable Play Protect

Open the **Google Play Store** → Tap your **profile icon** (top right) → Go to **Play Protect** → Tap the **⚙️ Settings gear** → **Turn off** "Scan apps with Play Protect".

<p align="center">
  <img src="Images/001.jpeg" width="180" />
  <img src="Images/002.jpeg" width="180" />
  <img src="Images/003.jpeg" width="180" />
</p>
<p align="center">
  <img src="Images/004.jpeg" width="180" />
  <img src="Images/005.jpeg" width="180" />
  <img src="Images/006.jpeg" width="180" />
</p>

> **Why?** Play Protect may flag apps that use Accessibility Services and Device Admin as potentially harmful. This is a false positive — our app only uses these permissions to detect and block selected apps.

---

### Step 2: Download & Install the APK

Download the latest APK from [**Releases**](https://github.com/GlaceYT/AppGuardian/releases) or receive it via WhatsApp/Telegram. Then install it on the target device.

<p align="center">
  <img src="Images/11.jpeg" width="180" />
  <img src="Images/12.jpeg" width="180" />
  <img src="Images/13.jpeg" width="180" />
  <img src="Images/14.jpeg" width="180" />
</p>

> If prompted, tap **"Install anyway"** and allow installation from unknown sources.

---

### Step 3: App Setup

When you first open the app, you'll see the **Device Hub** decoy screen. **Long-press the "Device Hub" title** at the top (or tap it 5 times quickly) to enter the real app.

The setup wizard will guide you through:

#### 3a. Welcome & Accessibility Service

Enable the Accessibility Service — this is how the app detects when a blocked app is launched.

<p align="center">
  <img src="Images/21.jpeg" width="180" />
  <img src="Images/22.jpeg" width="180" />
  <img src="Images/23.jpeg" width="180" />
  <img src="Images/24.jpeg" width="180" />
</p>

#### 3b. Device Admin & PIN Setup

Activate Device Admin (prevents uninstallation) and create your 4-digit PIN.

<p align="center">
  <img src="Images/25.jpeg" width="180" />
  <img src="Images/26.jpeg" width="180" />
  <img src="Images/27.jpeg" width="180" />
  <img src="Images/28.jpeg" width="180" />
</p>

#### 3c. Complete Setup

Finish setting up the PIN and confirm everything is working.

<p align="center">
  <img src="Images/29.jpeg" width="180" />
  <img src="Images/30.jpeg" width="180" />
  <img src="Images/31.jpeg" width="180" />
</p>
<p align="center">
  <img src="Images/32.jpeg" width="180" />
  <img src="Images/33.jpeg" width="180" />
</p>

---

### Step 4: Select Apps & Enable Protection

Choose which apps to block (gambling apps are automatically highlighted), then turn on protection from the dashboard.

<p align="center">
  <img src="Images/34.jpeg" width="180" />
  <img src="Images/35.jpeg" width="180" />
  <img src="Images/36.jpeg" width="180" />
  <img src="Images/37.jpeg" width="180" />
</p>

---

### Step 5: Done! 🎉 See It In Action

When the blocked app is opened, a **"Server Unavailable"** screen appears with the app's icon, a realistic error message, and a random estimated wait time. The user can only go back to the home screen.

<p align="center">
  <img src="Images/final1.jpeg" width="220" />
  <img src="Images/final2.jpeg" width="220" />
</p>

---

### Settings & More Options

Tap the **⋮ menu** (top right) on the dashboard to access settings — change PIN, manage blocked apps, check permissions, and find social links.

<p align="center">
  <img src="Images/more.jpeg" width="250" />
</p>

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────┐
│                 Flutter UI Layer                 │
│  ┌──────────┐ ┌──────────┐ ┌──────────────────┐ │
│  │  Splash  │ │   PIN    │ │   Home Screen    │ │
│  │ (Decoy)  │ │  Screen  │ │   (Dashboard)    │ │
│  └──────────┘ └──────────┘ └──────────────────┘ │
│              MethodChannel Bridge                │
├─────────────────────────────────────────────────┤
│              Native Android Layer                │
│  ┌──────────────────┐  ┌──────────────────────┐ │
│  │ AccessibilityService │  │  BlockerActivity  │ │
│  │ (Monitors apps)  │  │  (Server Down UI)    │ │
│  └──────────────────┘  └──────────────────────┘ │
│  ┌──────────────────┐  ┌──────────────────────┐ │
│  │  DeviceAdmin     │  │   BootReceiver       │ │
│  │ (Uninstall lock) │  │   (Auto-restart)     │ │
│  └──────────────────┘  └──────────────────────┘ │
└─────────────────────────────────────────────────┘
```

---

## 🛠️ Development Setup

### Requirements

- **Flutter** 3.7+ ([Install Flutter](https://docs.flutter.dev/get-started/install))
- **Android SDK** with API 26+ (Android 8.0+)
- **Android Studio** or VS Code with Flutter extension
- A physical Android device (recommended) or emulator

### Build from Source

```bash
# Clone the repository
git clone https://github.com/GlaceYT/AppGuardian.git
cd AppGuardian

# Install dependencies
flutter pub get

# Run on connected device
flutter run

# Build release APK
flutter build apk --release
```

The release APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Project Structure

```
├── android/
│   └── app/src/main/
│       ├── kotlin/com/predator/app_guardian/
│       │   ├── MainActivity.kt          # Flutter ↔ Native bridge
│       │   ├── AppBlockerService.kt      # Accessibility Service
│       │   ├── BlockerActivity.kt        # "Server Down" overlay
│       │   ├── AppGuardianDeviceAdmin.kt # Device admin receiver
│       │   └── BootReceiver.kt           # Auto-start on boot
│       ├── res/
│       │   ├── xml/                      # Service configs
│       │   └── values/                   # Strings, styles
│       └── AndroidManifest.xml
├── lib/
│   ├── main.dart                         # Entry point
│   ├── app.dart                          # Theme & MaterialApp
│   ├── models/
│   │   └── app_info.dart                 # App data model
│   ├── services/
│   │   ├── native_bridge.dart            # MethodChannel API
│   │   └── storage_service.dart          # SharedPreferences
│   ├── screens/
│   │   ├── splash_screen.dart            # Decoy "Device Hub" UI
│   │   ├── pin_screen.dart               # PIN entry
│   │   ├── setup_screen.dart             # Setup wizard
│   │   ├── home_screen.dart              # Dashboard
│   │   └── app_selection_screen.dart     # App picker
│   └── widgets/
│       ├── glass_card.dart               # Glassmorphism card
│       ├── gradient_button.dart          # Gradient button
│       └── app_tile.dart                 # App list item
├── assets/
│   └── logo.png                          # App logo
└── pubspec.yaml
```

---

## ⚠️ Important Notes

- **Android 8.0+ required** (API level 26)
- The Accessibility Service runs independently of the app — clearing the app from recents does NOT stop the blocker
- Device Admin prevents uninstallation unless explicitly deactivated from Settings → Security → Device Admin Apps
- The app does **not** violate any Android policies — it uses only official Android APIs
- This tool is intended for **parental control purposes only**

---

## 🤝 Connect & Support

<div align="center">

| Platform | Link |
|----------|------|
| 🎬 YouTube | [@GlaceYT](https://www.youtube.com/@GlaceYT) |
| 💬 Discord | [Join Server](https://discord.gg/xQF9f9yUEM) |
| 💖 Support | [PayPal](https://paypal.me/GlaceYT) |

**Made with ❤️ by [GlaceYT](https://www.youtube.com/@GlaceYT)**

</div>

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
