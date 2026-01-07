# MoneyShop - React Native Frontend Setup

## Arhitectură

- **Frontend**: React Native (Expo) - rulează pe Web, iOS, Android
- **Backend**: ASP.NET Core Web API - rulează pe `https://localhost:7093`
- **Comunicare**: REST API cu JWT Authentication

## Configurare

### 1. Backend (ASP.NET Core)

Backend-ul rulează pe:
- **HTTPS**: `https://localhost:7093`
- **HTTP**: `http://localhost:5259`
- **Swagger**: `https://localhost:7093/swagger`

### 2. Frontend (React Native)

React Native rulează pe:
- **Web**: `http://localhost:8081` (sau portul Expo)
- **iOS**: Simulator iOS
- **Android**: Emulator Android

### 3. Conectare

React Native se conectează la backend prin:
- **API Base URL**: `https://localhost:7093/api` (configurat în `src/utils/constants.ts`)

## Rulare

### Pasul 1: Pornește Backend-ul

```bash
cd MoneyShop
dotnet run
```

Backend-ul va rula pe `https://localhost:7093`

### Pasul 2: Pornește React Native

```bash
cd MoneyShopMobile
npm run web    # Pentru web
npm run ios    # Pentru iOS
npm run android # Pentru Android
```

React Native va rula pe `http://localhost:8081` (web) și se va conecta la backend.

## Notă Importantă

- **Backend-ul servește DOAR API-uri** (nu Views MVC)
- **React Native este frontend-ul complet** (web + mobile)
- Views MVC din backend sunt doar pentru Swagger UI și debugging

## Troubleshooting

### CORS Errors

Dacă vezi erori CORS, verifică că:
1. Backend-ul are CORS configurat pentru `http://localhost:8081`
2. React Native folosește URL-ul corect din `constants.ts`

### SSL Certificate Errors

Pentru development, am configurat `NODE_TLS_REJECT_UNAUTHORIZED=0` în `package.json`.

