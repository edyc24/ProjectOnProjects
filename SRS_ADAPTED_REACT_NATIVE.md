# 🚀 MoneyShop.ro – SRS ADAPTAT PENTRU REACT NATIVE + .NET CORE

**Versiune:** Faza 1 - Adaptată pentru React Native + ASP.NET Core Web API  
**Data:** 2025  
**Status:** Propunere pentru aprobare

---

## 📋 REZUMAT AL ADAPTĂRILOR

### Tehnologii Finale (după adaptare):
- **Backend:** ASP.NET Core 6.0 Web API (convertit din MVC actual)
- **Frontend Web:** React / Next.js (pentru site public + portal client web)
- **Mobile:** React Native (iOS + Android - un singur cod)
- **Database:** Azure SQL (păstrăm SQL Server)
- **Storage:** Azure Blob Storage (documente, PDF-uri, semnături)
- **Authentication:** JWT pentru mobile + Cookie pentru web (dual auth)

---

## 🟦 0. CONTEXT TEHNIC ȘI DE BUSINESS (ADAPTAT)

### 0.1. Brand & Companie
- **Brand:** MoneyShop®
- **Companie:** Popix Brokerage Consulting SRL
- **Activitate:** broker autorizat ANPC/BNR

### 0.2. Infrastructură (NEMODIFICAT)
- ✅ Azure App Services pentru backend API
- ✅ Azure SQL pentru DB
- ✅ Azure Blob Storage pentru documente, OCR, semnături, PDF-uri
- ✅ Cloudflare Free Plan pentru DNS, SSL, proxy, caching
- ✅ Microsoft 365 SMTP pentru email

### 0.3. Output Faza 1 (ADAPTAT)
- ✅ **Website complet** (React/Next.js)
- ✅ **Portal client web** (React/Next.js)
- ✅ **Panou Admin complet** (React/Next.js sau React Native Web)
- ✅ **Aplicații mobile iOS + Android** (React Native - un singur cod)
- ✅ **Backend API REST** (.NET Core Web API cu Swagger)
- ✅ **Simulator credit + scoring logic** (backend + frontend)
- ✅ **OCR CI + generare PDF acorduri + semnătură touchscreen** (mobile + web)
- ✅ **Lead Rapid + Social Login** (Google, Apple, Yahoo)
- ✅ **Structură pregătită pentru Faza 2** (KYC, ANAF, BC, scoring automat)

---

## 🟦 1. ARHITECTURĂ GENERALĂ (ADAPTATĂ)

### 1.1. Stack Tehnologic Final

#### Backend:
- **ASP.NET Core 6.0 Web API** (convertit din MVC actual)
- **Entity Framework Core 7.0** (păstrăm)
- **JWT Authentication** (pentru mobile)
- **Cookie Authentication** (pentru web - opțional)
- **Swagger/OpenAPI** (documentație API)
- **AutoMapper** (păstrăm)
- **FluentValidation** (păstrăm)

#### Frontend Web:
- **React 18+ / Next.js 14+** (SSR pentru SEO)
- **TypeScript**
- **Tailwind CSS** sau **Material-UI**
- **React Query / SWR** (pentru API calls)
- **Zustand / Redux Toolkit** (state management)

#### Mobile (React Native):
- **React Native 0.72+**
- **TypeScript**
- **React Navigation 6+** (navigation)
- **React Native Paper** sau **NativeBase** (UI components)
- **Zustand** (state management - lightweight)
- **React Query** (API calls + caching)
- **React Native Reanimated** (animations)
- **React Native Gesture Handler** (gestures)

#### Librării Mobile Especifice:
- **@react-native-firebase/messaging** (push notifications)
- **react-native-camera** sau **expo-camera** (pentru OCR CI)
- **react-native-pdf** (vizualizare PDF)
- **react-native-html-to-pdf** (generare PDF)
- **react-native-signature-canvas** (semnătură touchscreen)
- **@react-native-async-storage/async-storage** (local storage)
- **react-native-biometrics** (Face ID / Touch ID)
- **react-native-chart-kit** sau **victory-native** (grafice scoring)

---

## 🟦 2. ARHITECTURĂ BACKEND API (NOU)

### 2.1. Structură Proiect Backend

```
MoneyShop.API/
├── Controllers/
│   ├── AuthController.cs          (JWT + Social Login)
│   ├── UsersController.cs
│   ├── ApplicationsController.cs   (cereri credit)
│   ├── SimulatorController.cs     (scoring calculator)
│   ├── DocumentsController.cs      (upload/download)
│   ├── AgreementsController.cs     (PDF generation + signing)
│   ├── LeadsController.cs
│   ├── BanksController.cs
│   ├── OCRController.cs            (OCR CI processing)
│   └── AdminController.cs
├── Services/
│   ├── AuthService.cs
│   ├── ApplicationService.cs
│   ├── ScoringService.cs           (DTI calculation)
│   ├── OCRService.cs               (Azure Computer Vision / Tesseract)
│   ├── PDFService.cs               (iTextSharp/iText7)
│   └── BlobStorageService.cs       (Azure Blob)
├── Models/
│   ├── Requests/                   (DTOs pentru request)
│   └── Responses/                  (DTOs pentru response)
└── Middleware/
    ├── JwtMiddleware.cs
    └── ErrorHandlingMiddleware.cs
```

### 2.2. Endpointuri API Principale

#### Authentication (`/api/auth`)
```
POST   /api/auth/register           - Înregistrare nou user
POST   /api/auth/login              - Login (returnează JWT)
POST   /api/auth/refresh            - Refresh token
POST   /api/auth/logout              - Logout
POST   /api/auth/social/google       - Social login Google
POST   /api/auth/social/apple        - Social login Apple
POST   /api/auth/social/yahoo        - Social login Yahoo
POST   /api/auth/forgot-password     - Reset parolă
POST   /api/auth/reset-password      - Confirmare reset
```

#### Applications (`/api/applications`)
```
GET    /api/applications             - Lista cereri user curent
GET    /api/applications/{id}        - Detalii cerere
POST   /api/applications             - Creare cerere nouă
PUT    /api/applications/{id}        - Update cerere
DELETE /api/applications/{id}        - Ștergere cerere
GET    /api/applications/{id}/status - Status cerere
```

#### Simulator (`/api/simulator`)
```
POST   /api/simulator/calculate      - Calculare scoring DTI
GET    /api/simulator/banks          - Lista bănci disponibile
```

#### Documents (`/api/documents`)
```
POST   /api/documents/upload         - Upload document (multipart/form-data)
GET    /api/documents/{id}           - Download document
DELETE /api/documents/{id}           - Ștergere document
GET    /api/documents/application/{applicationId} - Lista documente cerere
```

#### OCR (`/api/ocr`)
```
POST   /api/ocr/process-id           - Procesare CI (image -> JSON)
```

#### Agreements (`/api/agreements`)
```
POST   /api/agreements/generate      - Generare PDF acorduri
POST   /api/agreements/sign          - Semnare acord (signature image)
GET    /api/agreements/{id}          - Download PDF semnat
```

#### Leads (`/api/leads`)
```
POST   /api/leads                     - Creare lead rapid
GET    /api/leads                     - Lista leads (admin only)
PUT    /api/leads/{id}/convert        - Convertire lead -> user (admin)
```

#### Banks (`/api/banks`)
```
GET    /api/banks                     - Lista bănci active
GET    /api/banks/{id}                - Detalii bancă
```

#### Admin (`/api/admin`)
```
GET    /api/admin/applications        - Lista toate cererile
PUT    /api/admin/applications/{id}/status - Schimbare status
GET    /api/admin/reports/monthly     - Raport lunar
POST   /api/admin/reports/export     - Export XLS/Oblio
```

### 2.3. Autentificare Duală

**Pentru Mobile (React Native):**
- JWT Bearer Token
- Token refresh mechanism
- Biometric authentication (Face ID/Touch ID) pentru local storage

**Pentru Web (React/Next.js):**
- Opțiune 1: JWT (same as mobile)
- Opțiune 2: Cookie-based (pentru compatibilitate cu SSR)

---

## 🟦 3. STRUCTURĂ REACT NATIVE MOBILE APP

### 3.1. Structură Proiect

```
MoneyShopMobile/
├── src/
│   ├── screens/
│   │   ├── Auth/
│   │   │   ├── LoginScreen.tsx
│   │   │   ├── RegisterScreen.tsx
│   │   │   └── ForgotPasswordScreen.tsx
│   │   ├── Dashboard/
│   │   │   ├── DashboardScreen.tsx
│   │   │   └── ApplicationListScreen.tsx
│   │   ├── Application/
│   │   │   ├── ApplicationWizardScreen.tsx
│   │   │   ├── Step1PersonalDataScreen.tsx
│   │   │   ├── Step2IncomeScreen.tsx
│   │   │   ├── Step3ExistingLoansScreen.tsx
│   │   │   ├── Step4CreditTypeScreen.tsx
│   │   │   ├── Step5DocumentsScreen.tsx
│   │   │   ├── Step6AgreementsScreen.tsx
│   │   │   └── Step7ConfirmationScreen.tsx
│   │   ├── Simulator/
│   │   │   ├── SimulatorScreen.tsx
│   │   │   └── SimulatorResultScreen.tsx
│   │   ├── Documents/
│   │   │   ├── DocumentUploadScreen.tsx
│   │   │   ├── OCRScanScreen.tsx
│   │   │   └── DocumentViewScreen.tsx
│   │   ├── Agreements/
│   │   │   ├── AgreementListScreen.tsx
│   │   │   ├── AgreementSignScreen.tsx
│   │   │   └── AgreementViewScreen.tsx
│   │   └── Profile/
│   │       ├── ProfileScreen.tsx
│   │       └── SettingsScreen.tsx
│   ├── components/
│   │   ├── common/
│   │   │   ├── Button.tsx
│   │   │   ├── Input.tsx
│   │   │   ├── Card.tsx
│   │   │   └── LoadingSpinner.tsx
│   │   ├── forms/
│   │   │   ├── CreditCardForm.tsx
│   │   │   ├── OverdraftForm.tsx
│   │   │   └── CoDebtorForm.tsx
│   │   └── charts/
│   │       └── ScoringChart.tsx
│   ├── navigation/
│   │   ├── AppNavigator.tsx
│   │   ├── AuthNavigator.tsx
│   │   └── MainNavigator.tsx
│   ├── services/
│   │   ├── api/
│   │   │   ├── apiClient.ts        (Axios instance cu interceptors)
│   │   │   ├── authApi.ts
│   │   │   ├── applicationsApi.ts
│   │   │   ├── simulatorApi.ts
│   │   │   ├── documentsApi.ts
│   │   │   └── ocrApi.ts
│   │   ├── storage/
│   │   │   └── tokenStorage.ts      (AsyncStorage pentru JWT)
│   │   └── notifications/
│   │       └── pushNotifications.ts
│   ├── store/
│   │   ├── authStore.ts            (Zustand store)
│   │   ├── applicationStore.ts
│   │   └── simulatorStore.ts
│   ├── hooks/
│   │   ├── useAuth.ts
│   │   ├── useApplications.ts
│   │   └── useSimulator.ts
│   ├── utils/
│   │   ├── validation.ts
│   │   ├── formatters.ts
│   │   └── constants.ts
│   └── types/
│       ├── api.types.ts
│       ├── application.types.ts
│       └── user.types.ts
├── assets/
│   ├── images/
│   ├── fonts/
│   └── icons/
├── android/                        (Android native config)
├── ios/                           (iOS native config)
├── app.json                        (Expo config - dacă folosim Expo)
└── package.json
```

### 3.2. Funcționalități Mobile Especifice

#### OCR CI (Camera Integration)
```typescript
// Folosind react-native-camera sau expo-camera
import { Camera } from 'expo-camera';

// Flow:
1. User deschide camera
2. Face poza CI
3. Trimite image la /api/ocr/process-id
4. Backend procesează cu Azure Computer Vision / Tesseract
5. Returnează JSON cu date extrase
6. Auto-complete formular
```

#### Semnătură Touchscreen
```typescript
// Folosind react-native-signature-canvas
import SignatureCanvas from 'react-native-signature-canvas';

// Flow:
1. User desenează semnătura pe ecran
2. Se salvează ca image (base64 sau blob)
3. Se trimite la /api/agreements/sign
4. Backend atașează semnătura în PDF
5. PDF final salvat în Azure Blob
```

#### Push Notifications
```typescript
// Folosind @react-native-firebase/messaging
import messaging from '@react-native-firebase/messaging';

// Configurare:
- Firebase Cloud Messaging (FCM) pentru Android
- Apple Push Notification Service (APNs) pentru iOS
- Backend trimite notificări când status cerere se schimbă
```

---

## 🟦 4. ADAPTĂRI SPECIFICE SRS

### 4.1. Modul Site Web Public (NEMODIFICAT)
- ✅ Pagini obligatorii rămân la fel
- ✅ Integrare Social Login (Google, Apple, Yahoo)
- ✅ Tracking GA4

### 4.2. Portal Client (ADAPTAT)
- **Web:** React/Next.js cu SSR
- **Mobile:** React Native app
- **Backend comun:** .NET Core Web API

### 4.3. Creare Cerere (ADAPTAT)
- **Web:** Wizard în React cu form steps
- **Mobile:** Wizard în React Native cu navigation stack
- **Backend:** Același API pentru ambele

### 4.4. OCR ID + Acorduri (ADAPTAT)
- **Mobile:** Camera nativă + signature canvas
- **Web:** File upload + HTML5 canvas pentru semnătură
- **Backend:** Același servicii OCR și PDF

### 4.5. Simulator Credit (ADAPTAT)
- **Backend:** `/api/simulator/calculate` (logica DTI)
- **Frontend:** React Native charts pentru vizualizare
- **Web:** React charts (Chart.js / Recharts)

### 4.6. Back-Office Admin (ADAPTAT)
- **Opțiune 1:** React/Next.js web app (recomandat)
- **Opțiune 2:** React Native Web (dacă vrem să folosim același cod)

---

## 🟦 5. PLAN DE IMPLEMENTARE

### Faza 1.1: Backend API Conversion (2-3 săptămâni)
1. ✅ Convertire MVC controllers → Web API controllers
2. ✅ Adăugare JWT authentication
3. ✅ Implementare endpointuri conform SRS
4. ✅ Adăugare Swagger/OpenAPI
5. ✅ Testare API cu Postman/Thunder Client

### Faza 1.2: Database Schema (1 săptămână)
1. ✅ Creare tabele conform ERD din SRS:
   - Users (adaptat din Utilizatori)
   - Applications
   - Documents
   - Banks
   - Application_Banks
   - Agreements
   - Leads
2. ✅ Migrations EF Core
3. ✅ Seed data (bănci, roluri)

### Faza 1.3: React Native Setup (1 săptămână)
1. ✅ Inițializare proiect React Native
2. ✅ Configurare navigation
3. ✅ Setup API client
4. ✅ Setup state management (Zustand)
5. ✅ Configurare build iOS/Android

### Faza 1.4: Mobile App Core Features (3-4 săptămâni)
1. ✅ Authentication (Login, Register, Social)
2. ✅ Dashboard
3. ✅ Simulator credit
4. ✅ Application wizard (7 steps)
5. ✅ Document upload
6. ✅ OCR CI
7. ✅ Agreement signing

### Faza 1.5: Web Frontend (2-3 săptămâni)
1. ✅ Next.js setup
2. ✅ Site public (Home, About, Contact)
3. ✅ Portal client web
4. ✅ Admin panel

### Faza 1.6: Integrări & Polish (1-2 săptămâni)
1. ✅ Push notifications
2. ✅ PDF generation & signing
3. ✅ OCR processing
4. ✅ Testing & bug fixes
5. ✅ App Store / Play Store preparation

---

## 🟦 6. CONSIDERENTE TEHNICE

### 6.1. Securitate
- ✅ JWT tokens cu refresh mechanism
- ✅ HTTPS obligatoriu
- ✅ Input validation (FluentValidation)
- ✅ Rate limiting pentru API
- ✅ CORS configurat corect

### 6.2. Performance
- ✅ API response caching (React Query)
- ✅ Image optimization (Azure CDN)
- ✅ Lazy loading pentru mobile
- ✅ Code splitting pentru web

### 6.3. Deployment
- ✅ Backend: Azure App Service
- ✅ Frontend Web: Azure Static Web Apps sau Vercel
- ✅ Mobile: App Store Connect + Google Play Console
- ✅ CI/CD: GitHub Actions sau Azure DevOps

---

## 🟦 7. LIVRABILE FINALE

1. ✅ **Backend API** (.NET Core Web API cu Swagger)
2. ✅ **Website complet** (React/Next.js)
3. ✅ **Portal client web** (React/Next.js)
4. ✅ **Panou Admin** (React/Next.js)
5. ✅ **Aplicație mobile iOS** (React Native - App Store ready)
6. ✅ **Aplicație mobile Android** (React Native - Play Store ready)
7. ✅ **Simulator credit + scoring**
8. ✅ **OCR CI + semnături PDF**
9. ✅ **Lead Rapid + Social Login**
10. ✅ **Modul bănci + comisioane**
11. ✅ **Rapoarte lunare + Export Oblio**
12. ✅ **Documentație tehnică completă**
13. ✅ **Arhitectură Azure gata de producție**

---

## ✅ APROBARE NECESARĂ

**Înainte de a începe implementarea, te rog să confirmi:**

1. ✅ Stack-ul propus (React Native + .NET Core Web API) este OK?
2. ✅ Structura proiectului React Native este OK?
3. ✅ Endpointurile API propuse sunt suficiente?
4. ✅ Planul de implementare este realist?
5. ✅ Există alte cerințe specifice care trebuie adăugate?

**După aprobare, voi începe cu:**
1. Convertirea backend-ului la Web API
2. Crearea structurii React Native
3. Implementarea feature-urilor conform SRS adaptat

---

**Document creat:** 2025  
**Status:** ⏳ Așteaptă aprobare

