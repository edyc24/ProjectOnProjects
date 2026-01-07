# MoneyShop - Arhitectură

## Structură Generală

```
MoneyShop/
├── MoneyShop/              # Backend - ASP.NET Core Web API
│   ├── Controllers/
│   │   └── Api/            # API Controllers (pentru React Native)
│   ├── Services/           # Business Logic Services
│   └── Program.cs         # Configurare API + CORS
│
└── MoneyShopMobile/        # Frontend - React Native (Expo)
    ├── src/
    │   ├── screens/        # Ecrane React Native
    │   ├── services/       # API Client
    │   └── utils/          # Configurare (API_BASE_URL)
    └── package.json
```

## Comunicare

### Backend (ASP.NET Core)
- **Port**: `https://localhost:7093` (HTTPS) sau `http://localhost:5259` (HTTP)
- **Swagger**: `https://localhost:7093/swagger`
- **API Endpoints**: `https://localhost:7093/api/*`
- **CORS**: Configurat pentru React Native

### Frontend (React Native)
- **Web**: `http://localhost:8081` (Expo web)
- **iOS**: Simulator iOS
- **Android**: Emulator Android
- **API Client**: Se conectează la `https://localhost:7093/api`

## Flux de Date

1. **React Native** face request la `https://localhost:7093/api/*`
2. **Backend** procesează request-ul și returnează JSON
3. **React Native** afișează datele în UI

## Important

- **Backend-ul servește DOAR API-uri** (JSON responses)
- **React Native este frontend-ul complet** (web + mobile)
- **Views MVC** din backend sunt doar pentru Swagger UI (debugging)

## Rulare

### 1. Backend
```bash
cd MoneyShop
dotnet run
```
→ Rulează pe `https://localhost:7093`

### 2. Frontend
```bash
cd MoneyShopMobile
npm run web    # Web
npm run ios    # iOS
npm run android # Android
```
→ Rulează pe `http://localhost:8081` (web) și se conectează la backend

## Notă

Dacă vezi Views MVC când accesezi `https://localhost:7093`, acestea sunt doar pentru Swagger și debugging. Frontend-ul real este React Native care rulează separat.

