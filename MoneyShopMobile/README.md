# MoneyShop Mobile App

React Native mobile application for MoneyShop platform using Expo.

## Prerequisites

- Node.js >= 18
- npm or yarn
- Expo CLI (installed globally or via npx)
- For iOS: Xcode (Mac only)
- For Android: Android Studio

## Installation

1. Install dependencies:
```bash
npm install
```

2. If you encounter SSL certificate errors during installation, set the environment variable first:
```bash
# PowerShell
$env:NODE_TLS_REJECT_UNAUTHORIZED="0"
npm install

# Or use the batch file
start-dev.bat
```

3. Install web dependencies (if using web platform):
```bash
# PowerShell
$env:NODE_TLS_REJECT_UNAUTHORIZED="0"
npm install react-native-web@~0.19.6 react-dom@18.2.0 @expo/metro-runtime@~3.1.3 --save
```

## Running the App

### Development Mode

**Important**: On Windows, you cannot run iOS (requires Mac). Use Android or Web instead.

#### Option 1: Fix SSL Certificate Issue (Recommended)

If you encounter SSL certificate errors, set the environment variable:

**Windows (PowerShell):**
```powershell
$env:NODE_TLS_REJECT_UNAUTHORIZED="0"
npm start
```

**Windows (CMD):**
```cmd
set NODE_TLS_REJECT_UNAUTHORIZED=0
npm start
```

Or use the provided batch file:
```bash
start-dev.bat
```

#### Option 2: Offline Mode

If SSL issues persist, use offline mode:
```bash
npm run start:offline
```

This will open Expo DevTools in your browser. You can then:
- Press `a` to open Android emulator (requires Android Studio)
- Press `w` to open in web browser
- Scan QR code with Expo Go app on your physical device

### Platform-Specific Commands

```bash
# Android (Windows/Linux/Mac)
npm run android

# Web (All platforms)
npm run web

# iOS (Mac only - won't work on Windows)
npm run ios
```

## Building Native Projects

If you need to generate native iOS/Android projects:

```bash
npm run prebuild
```

This will create `ios/` and `android/` folders that you can then open in Xcode or Android Studio.

## Project Structure

```
MoneyShopMobile/
├── src/
│   ├── navigation/     # Navigation setup
│   ├── screens/        # Screen components
│   ├── services/       # API services
│   ├── store/          # State management (Zustand)
│   ├── types/          # TypeScript types
│   └── utils/          # Utility functions
├── App.tsx             # Root component
└── index.js            # Entry point
```

## Configuration

- API Base URL: Update `src/utils/constants.ts` with your backend URL
- App configuration: See `app.json`

## Troubleshooting

### iOS/Android folders not found
Run `npm run prebuild` to generate native projects.

### Metro bundler issues
Clear cache: `npx expo start -c`

### Dependencies issues
Delete `node_modules` and `package-lock.json`, then run `npm install` again.
