# Deployment React Native App (Frontend) în Azure

## 📋 Status Actual

**Aplicația React Native NU este hostată în Azure.** Ea rulează doar local prin Expo.

## 🎯 Opțiuni de Deployment

### Opțiunea 1: Azure Static Web Apps (Recomandat pentru Web)

Deploy aplicația React Native ca web app static în Azure Static Web Apps.

#### Pași:

1. **Build aplicația pentru web:**
   ```bash
   cd MoneyShopMobile
   npm run build:web
   ```
   
   Acest lucru va genera un folder `web-build/` cu fișierele statice.

2. **Deploy în Azure Static Web Apps:**
   - Creează un Azure Static Web App
   - Conectează-l la repository-ul tău GitHub
   - Configurează build settings:
     - **App location:** `/MoneyShopMobile`
     - **Api location:** (lasă gol)
     - **Output location:** `web-build`

3. **Actualizează API URL-ul:**
   - În `MoneyShopMobile/src/utils/constants.ts`, setează URL-ul backend-ului Azure:
     ```typescript
     export const API_BASE_URL = 'https://[app-service-url]/api';
     ```

### Opțiunea 2: Azure Storage Static Website

Deploy aplicația ca static website în Azure Storage (similar cu Homework 1).

#### Pași:

1. **Build aplicația:**
   ```bash
   cd MoneyShopMobile
   npm run build:web
   ```

2. **Deploy în Azure Storage:**
   - Creează un Storage Account
   - Activează Static Website Hosting
   - Upload fișierele din `web-build/` în container-ul `$web`

3. **Script PowerShell pentru deployment:**
   Vezi `REACT_NATIVE_DEPLOYMENT.ps1` (va fi creat mai jos)

### Opțiunea 3: Azure App Service (Node.js)

Deploy aplicația ca Node.js app în Azure App Service.

#### Pași:

1. **Configurează `app.json` pentru production:**
   ```json
   {
     "expo": {
       "web": {
         "bundler": "metro",
         "output": "static"
       }
     }
   }
   ```

2. **Deploy în Azure App Service:**
   - Creează un App Service cu runtime Node.js
   - Configurează deployment din GitHub sau local
   - Setează start command: `npm run web`

## 🔧 Configurare API URL pentru Production

După deployment, trebuie să actualizezi URL-ul backend-ului în `MoneyShopMobile/src/utils/constants.ts`:

```typescript
// Development
const LOCAL_IP = ''; // Empty pentru localhost

// Production - setează URL-ul Azure App Service
export const API_BASE_URL = process.env.EXPO_PUBLIC_API_URL || 
  (LOCAL_IP ? `https://${LOCAL_IP}:7093/api` : 'https://localhost:7093/api');
```

Sau folosește environment variables:
```typescript
export const API_BASE_URL = process.env.EXPO_PUBLIC_API_URL || 
  'https://moneyshop20260107220205-adbnf8c7a2fec4d4.azurewebsites.net/api';
```

## 📝 Script de Deployment (Azure Storage)

Am creat scriptul `REACT_NATIVE_DEPLOYMENT.ps1` pentru deployment automat în Azure Storage.

## ⚠️ Note Importante

1. **CORS:** Asigură-te că backend-ul permite requests de la domeniul unde este hostată aplicația React Native.

2. **Environment Variables:** Pentru production, folosește environment variables pentru API URL.

3. **HTTPS:** Asigură-te că toate conexiunile folosesc HTTPS în production.

4. **Build Output:** Folder-ul `web-build/` conține fișierele statice generate de Expo.

## 🚀 Quick Start (Azure Static Web Apps)

```bash
# 1. Build aplicația
cd MoneyShopMobile
npm run build:web

# 2. Actualizează API URL în constants.ts
# 3. Deploy în Azure Static Web Apps prin Azure Portal sau GitHub Actions
```

## 📚 Resurse

- [Expo Web Build](https://docs.expo.dev/distribution/publishing-websites/)
- [Azure Static Web Apps](https://azure.microsoft.com/en-us/products/app-service/static)
- [React Native Web](https://necolas.github.io/react-native-web/)

