# Rezumat Homework 1, 2 și 3 - MoneyShop

## 📋 Overview

Acest document rezumă implementarea cerințelor pentru **Homework 1**, **Homework 2** și **Homework 3** folosind aplicația existentă **MoneyShop**.

---

## 🟦 HOMEWORK 1 - Static Web Page on Azure Storage

### ✅ Implementare Completă

**Locație:** `TEMA-1/`

**Fișiere create:**
- `index.html` - Pagină statică despre MoneyShop
- `styles.css` - Stiluri CSS responsive
- `404.html` - Pagină de eroare 404
- `deploy.ps1` - Script PowerShell pentru deployment automat
- `README.md` - Documentație

**Cerințe îndeplinite:**
- ✅ Pagină statică publică
- ✅ Script Azure CLI pentru deployment (`deploy.ps1`)
- ✅ README cu nume, URL, descriere

**Deployment:**
```powershell
cd TEMA-1
.\deploy.ps1
```

**URL generat:** `https://[storage-account-name].z[location].web.core.windows.net`

---

## 🟦 HOMEWORK 2 - Simple Web App in Azure App Service

### ✅ Implementare Completă

**Locație:** `MoneyShop/` (aplicația existentă)

**Fișiere modificate/adaugate:**
- `MoneyShop/Controllers/HomeController.cs` - Adăugat `Simple()` action și `AddItem()` API
- `MoneyShop/Views/Home/Simple.cshtml` - Pagină simplă cu input + button + listă
- `TEMA-2/deploy.ps1` - Script PowerShell pentru deployment automat
- `TEMA-2/README.md` - Documentație

**Cerințe îndeplinite:**
- ✅ Homepage public accesibilă (fără autentificare)
- ✅ Input text field
- ✅ "Enter" button
- ✅ Listă persistentă de items (folosește tabelul `Leads` existent)
- ✅ Items salvate în Azure SQL Database
- ✅ Lista rămâne consistentă după restart/refresh
- ✅ Database NU este public accesibilă (doar App Service IPs permise)
- ✅ Script deployment automat (`deploy.ps1`)

**Pagina simplă:**
- **URL:** `https://[app-service-url]/Home/Simple`
- **API Endpoint:** `POST /api/simple/add`

**Deployment:**
```powershell
cd TEMA-2
.\deploy.ps1
```

**Security:**
- SQL Server Firewall: DOAR App Service outbound IPs permise
- "Allow Azure Services": DEZACTIVAT
- Personal IP: NU permis (doar temporar pentru debugging)

---

## 🟦 HOMEWORK 3 - Application Telemetry with Azure Application Insights

### ✅ Implementare Completă

**Locație:** `MoneyShop/` și `MoneyShopMobile/`

**Cerințe îndeplinite:**

#### 1. Application Insights Integration ✅
- ✅ SDK: `Microsoft.ApplicationInsights.AspNetCore` v2.21.0
- ✅ Configurat în `MoneyShop/Program.cs`
- ✅ Connection string din `appsettings.json`
- ✅ Telemetry vizibil în Azure Portal

#### 2. Request Performance Telemetry ✅
- ✅ Automat pentru toate HTTP requests
- ✅ Include: timestamp, HTTP method, path, status code, duration
- ✅ Vizibil în Application Insights Logs

#### 3. Business Logging ✅
- ✅ **Item successfully added:**
  - `LeadSuccessfullyAdded` event (când se creează un lead)
  - `ApplicationSuccessfullyAdded` event (când se creează o aplicație)
- ✅ **Error Handling:**
  - `DuplicateLead` error (409 Conflict) - când se încearcă duplicate email
  - `DuplicateApplication` error (409 Conflict) - când se încearcă duplicate aplicație
  - `LeadValidationError` / `ApplicationValidationError` (400 Bad Request) - input invalid
- ✅ Toate erorile înregistrate în Application Insights

#### 4. Frontend Custom Event ✅
- ✅ Event `ButtonClick` emis din frontend
- ✅ Apare ca custom event în Application Insights
- ✅ Include proprietăți: `buttonName`, `actionType`, `screen`
- ✅ Implementat în:
  - `RegisterScreen.tsx` - buton "Register"
  - `ApplicationWizardScreen.tsx` - buton "CreateApplication"

#### 5. Health Endpoint ✅
- ✅ `GET /api/health` sau `GET /api/health/ping`
- ✅ Returnează HTTP 200 când app este healthy
- ✅ Apare în Application Insights
- ✅ Request duration observabil în telemetry
- ✅ Custom metric `HealthCheck` tracked

#### 6. Portal Verification ✅
- ✅ KQL queries pentru:
  - View successful and failed requests
  - Observe request durations
  - Identify requests to health endpoint
  - See frontend custom events

**Fișiere relevante:**
- `MoneyShop/Program.cs` - Configurare Application Insights
- `MoneyShop/Controllers/Api/HealthController.cs` - Health endpoint
- `MoneyShop/Controllers/Api/LeadsController.cs` - Business logging pentru leads
- `MoneyShop/Controllers/Api/ApplicationsController.cs` - Business logging pentru applications
- `MoneyShop/Controllers/Api/TelemetryController.cs` - Endpoint pentru frontend events
- `MoneyShopMobile/src/services/telemetry/appInsightsService.ts` - Frontend telemetry service
- `HOMEWORK_3_README.md` - Documentație completă cu KQL queries

---

## 📊 Status Implementare

| Homework | Status | Locație | URL/Endpoint |
|----------|--------|---------|--------------|
| **Homework 1** | ✅ Complet | `TEMA-1/` | `https://[storage].web.core.windows.net` |
| **Homework 2** | ✅ Complet | `MoneyShop/` | `https://[app-service]/Home/Simple` |
| **Homework 3** | ✅ Complet | `MoneyShop/` + `MoneyShopMobile/` | Application Insights Portal |

---

## 🚀 Deployment Instructions

### Homework 1
```powershell
cd TEMA-1
.\deploy.ps1
```

### Homework 2
```powershell
cd TEMA-2
.\deploy.ps1
# După deployment, aplică migrațiile:
cd ..\MoneyShop
dotnet ef database update --project ../DataAccess
```

### Homework 3
Application Insights este deja configurat. Doar adaugă connection string-ul în `appsettings.json`:
```json
{
  "ApplicationInsights": {
    "ConnectionString": "InstrumentationKey=YOUR_KEY;IngestionEndpoint=https://..."
  }
}
```

---

## 📝 Deliverables

### Homework 1
- ✅ Source Code: `TEMA-1/index.html`, `styles.css`, `404.html`
- ✅ Deployment Script: `TEMA-1/deploy.ps1`
- ✅ README: `TEMA-1/README.md`

### Homework 2
- ✅ Source Code: `MoneyShop/` (aplicația existentă)
- ✅ Deployment Script: `TEMA-2/deploy.ps1`
- ✅ README: `TEMA-2/README.md`

### Homework 3
- ✅ Source Code: `MoneyShop/` + `MoneyShopMobile/`
- ✅ Application Insights Configuration: `MoneyShop/Program.cs`, `appsettings.json`
- ✅ README: `HOMEWORK_3_README.md` (cu KQL queries și screenshots)

---

## 🔍 Testing

### Homework 1
1. Rulează `deploy.ps1`
2. Accesează URL-ul generat
3. Verifică că pagina se încarcă corect

### Homework 2
1. Rulează `deploy.ps1`
2. Accesează `https://[app-url]/Home/Simple`
3. Adaugă un item
4. Refresh pagina - item-ul ar trebui să rămână
5. Verifică că SQL Database nu este accesibilă din afara App Service

### Homework 3
1. Configurează Application Insights connection string
2. Testează health endpoint: `GET /api/health`
3. Creează un lead: `POST /api/leads`
4. Încearcă duplicate lead (eroare)
5. Click buton "Register" în frontend
6. Verifică Application Insights Portal pentru telemetry

---

## 📚 Documentație

- **Homework 1:** `TEMA-1/README.md`
- **Homework 2:** `TEMA-2/README.md`
- **Homework 3:** `HOMEWORK_3_README.md`
- **Rezumat General:** `HOMEWORK_1_2_SUMMARY.md` (pentru ce a fost implementat anterior)

---

## ⚠️ Note Importante

1. **Homework 1** - Pagină statică separată, nu modifică aplicația existentă
2. **Homework 2** - Folosește aplicația existentă, adaugă doar pagina `/Home/Simple`
3. **Homework 3** - Deja implementat complet, doar verifică și actualizează README-ul
4. **Database** - Homework 2 folosește tabelul `Leads` existent (nu modifică schema)
5. **Security** - Pentru Homework 2, asigură-te că SQL Firewall permite DOAR App Service IPs

