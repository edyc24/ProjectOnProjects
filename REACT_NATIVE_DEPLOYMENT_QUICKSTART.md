# 🚀 Quick Start - Deploy React Native App în Azure

## Status Actual

**Aplicația React Native NU este hostată în Azure.** Ea rulează doar local prin Expo.

## Pași Rapizi pentru Deployment

### 1. Build Aplicația

```bash
cd MoneyShopMobile
npm run build:web
```

Aceasta va genera folder-ul `web-build/` cu fișierele statice.

### 2. Actualizează API URL (Opțional)

Dacă vrei să folosești backend-ul Azure, actualizează `src/utils/constants.ts`:

```typescript
// Production fallback
if (!__DEV__) {
  return 'https://[app-service-url]/api';
}
```

Sau folosește environment variable `EXPO_PUBLIC_API_URL`.

### 3. Deploy în Azure Storage

Rulează scriptul PowerShell:

```powershell
.\REACT_NATIVE_DEPLOYMENT.ps1
```

Scriptul va:
- ✅ Verifica dacă aplicația este buildată
- ✅ Build aplicația dacă nu există `web-build/`
- ✅ Crea Storage Account în Azure
- ✅ Upload toate fișierele
- ✅ Returnează URL-ul aplicației

### 4. Verifică CORS în Backend

Asigură-te că backend-ul permite requests de la domeniul aplicației React Native.

În `MoneyShop/Program.cs`, verifică că CORS include URL-ul aplicației:

```csharp
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowReactNative", policy =>
    {
        policy.WithOrigins(
            "https://[storage-account].z[location].web.core.windows.net",
            "http://localhost:8081",
            "http://localhost:19006"
        )
        .AllowAnyMethod()
        .AllowAnyHeader()
        .AllowCredentials();
    });
});
```

## 📍 URL-uri

După deployment, vei avea:

- **Frontend (React Native):** `https://[storage-account].z[location].web.core.windows.net`
- **Backend (ASP.NET Core):** `https://[app-service-url]`
- **API:** `https://[app-service-url]/api`

## 🔧 Alternative: Azure Static Web Apps

Pentru deployment automat cu CI/CD:

1. Creează Azure Static Web App
2. Conectează-l la GitHub repository
3. Configurează:
   - **App location:** `/MoneyShopMobile`
   - **Output location:** `web-build`
4. Setează environment variable `EXPO_PUBLIC_API_URL` în Azure Portal

## ⚠️ Note

- Aplicația React Native rulează ca **web app static** (HTML/CSS/JS)
- Pentru mobile apps (iOS/Android), folosește Expo EAS Build sau build local
- Backend-ul trebuie să permită CORS pentru domeniul frontend-ului

## 📚 Documentație Completă

Vezi `REACT_NATIVE_DEPLOYMENT.md` pentru detalii complete.

