@echo off
set NODE_TLS_REJECT_UNAUTHORIZED=0
echo Starting Expo with SSL verification disabled...
echo.
echo Available options:
echo   - Press 'w' for web browser
echo   - Press 'a' for Android emulator
echo   - Scan QR code with Expo Go app
echo.
npm start

