# Homework 3 - Application Telemetry with Azure Application Insights

## Date Student
**Nume:** Cristea Eduard Gabriel  
**URL:** https://moneyshop20260107220205-adbnf8c7a2fec4d4.canadacentral-01.azurewebsites.net 
**Tehnologii:** ASP.NET Core 6.0 (Backend), React Native cu Expo (Frontend)  
**Baza de date:** Azure SQL Database

## Despre Aplicație

MoneyShop e o platformă pentru intermediere credit unde utilizatorii pot:
- Să se înregistreze și să se autentifice
- Să creeze cereri de credit
- Să trimită leads (informații de contact)
- Să gestioneze mandate și documente
- Să folosească un simulator de credit

## Ce am integrat cu Application Insights

### 1. Configurare Backend

Am configurat Application Insights în `MoneyShop/Program.cs`:
- Am adăugat SDK-ul `Microsoft.ApplicationInsights.AspNetCore` v2.21.0
- Connection string-ul se citește din `appsettings.json` → `ApplicationInsights:ConnectionString`
- Telemetria automată pentru requests e activată pentru toate request-urile HTTP

### 2. Telemetrie Request Performance

Fiecare request HTTP include automat:
- **Timestamp**: Se înregistrează automat de SDK
- **HTTP method**: GET, POST, PUT, DELETE, etc.
- **Path/endpoint**: Path-ul complet cu query parameters
- **Status code**: 200, 400, 401, 500, etc.
- **Duration**: Măsurat în milisecunde

**Exemple de endpoint-uri track-uite:**
- `POST /api/leads` - Creare lead
- `POST /api/applications` - Creare aplicație
- `GET /api/health` - Health check
- `POST /api/auth/register` - Înregistrare utilizator

### 3. Business Logging

#### Creare Lead (`POST /api/leads`)
Când se creează un lead cu succes, se loghează:
- **Event Name**: `LeadSuccessfullyAdded`
- **Properties**:
  - `LeadId`: ID-ul lead-ului creat
  - `Email`: Email-ul lead-ului
  - `Name`: Numele lead-ului
  - `TypeCredit`: Tipul de credit cerut

**Locație**: `MoneyShop/Controllers/Api/LeadsController.cs` (linia ~60)

#### Creare Aplicație (`POST /api/applications`)
Când se creează o aplicație cu succes, se loghează:
- **Event Name**: `ApplicationSuccessfullyAdded`
- **Properties**:
  - `ApplicationId`: ID-ul aplicației create
  - `UserId`: ID-ul utilizatorului care a creat-o
  - `TypeCredit`: Tipul de credit
  - `Status`: Status-ul aplicației

**Locație**: `MoneyShop/Controllers/Api/ApplicationsController.cs` (linia ~90)

### 4. Error Handling și Logging

#### Eroare Duplicate Lead
**Când apare**: Când încerci să creezi un lead cu un email care există deja
- **Endpoint**: `POST /api/leads`
- **Error Type**: `DuplicateLead`
- **HTTP Status**: 409 Conflict
- **Exception track-uită**: `InvalidOperationException` cu email și error type

**Cum să o testezi:**
1. Creează un lead cu email: `test@example.com`
2. Încearcă să creezi alt lead cu același email
3. Primești 409 Conflict
4. Eroarea e logată în Application Insights

#### Eroare Duplicate Application
**Când apare**: Când încerci să creezi o aplicație de același tip când există deja una cu status "INREGISTRAT"
- **Endpoint**: `POST /api/applications`
- **Error Type**: `DuplicateApplication`
- **HTTP Status**: 409 Conflict
- **Exception track-uită**: `InvalidOperationException` cu user ID, type credit, și error type

**Cum să o testezi:**
1. Creează o aplicație cu `TypeCredit: "nevoi_personale"` și `Status: "INREGISTRAT"`
2. Încearcă să creezi altă aplicație cu același `TypeCredit` și `TipOperatiune`
3. Primești 409 Conflict
4. Eroarea e logată în Application Insights

#### Eroare Input Invalid
**Când apare**: Când lipsesc câmpuri obligatorii (Name sau Email pentru leads, date invalide pentru aplicații)
- **Endpoint**: `POST /api/leads` sau `POST /api/applications`
- **HTTP Status**: 400 Bad Request
- **Event track-uit**: `LeadValidationError` sau `ApplicationValidationError`

**Cum să o testezi:**
1. Trimite un POST la `/api/leads` fără câmpurile `name` sau `email`
2. Primești 400 Bad Request
3. Eroarea de validare e logată în Application Insights

### 5. Frontend Custom Events

#### Button Click Events
Am adăugat tracking pentru click-uri pe butoane în frontend:

**Buton Register** (`RegisterScreen.tsx`):
- **Event Name**: `ButtonClick`
- **Properties**:
  - `buttonName`: "Register"
  - `actionType`: "submit"
  - `screen`: "RegisterScreen"

**Buton Create Application** (`ApplicationWizardScreen.tsx`):
- **Event Name**: `ButtonClick`
- **Properties**:
  - `buttonName`: "CreateApplication"
  - `actionType`: "submit"
  - `screen`: "ApplicationWizardScreen"
  - `step`: Pasul curent din wizard
  - `typeCredit`: Tipul de credit selectat

**Locație**: 
- Frontend service: `MoneyShopMobile/src/services/telemetry/appInsightsService.ts`
- Backend endpoint: `POST /api/telemetry/track-event`

#### Event Înregistrare Utilizator
Când un utilizator se înregistrează cu succes:
- **Event Name**: `UserRegistered`
- **Properties**:
  - `email`: Email-ul utilizatorului
  - `hasPhone`: Dacă a furnizat număr de telefon

### 6. Health Endpoint

**Endpoint**: `GET /api/health` sau `GET /api/health/ping`

**Răspuns**:
```json
{
  "status": "healthy",
  "timestamp": "2025-01-07T12:00:00Z",
  "version": "1.0.0"
}
```

**Telemetrie**:
- Returnează HTTP 200 când e healthy
- Request-ul apare în Application Insights Logs
- Duration-ul request-ului e track-uit
- Metric custom `HealthCheck` e track-uit cu valoarea 1

**Locație**: `MoneyShop/Controllers/Api/HealthController.cs`

## KQL Queries pentru Analiză

### 1. Vezi Toate Request-urile cu Metrici de Performance
```kql
requests
| project timestamp, name, url, resultCode, duration, success
| order by timestamp desc
| take 100
```

### 2. Vezi Request-uri Reușite și Eșuate
```kql
requests
| summarize 
    Successful = countif(success == true),
    Failed = countif(success == false)
    by bin(timestamp, 1h)
| order by timestamp desc
```

### 3. Identifică Request-uri la Health Endpoint
```kql
requests
| where url contains "/api/health"
| project timestamp, name, url, duration, resultCode
| order by timestamp desc
```

### 4. Vezi Durata Request-urilor (Analiză Performance)
```kql
requests
| summarize 
    AvgDuration = avg(duration),
    MinDuration = min(duration),
    MaxDuration = max(duration),
    P95Duration = percentile(duration, 95)
    by name
| order by AvgDuration desc
```

### 5. Vezi Frontend Custom Events (Button Clicks)
```kql
customEvents
| where name == "ButtonClick"
| project timestamp, name, customDimensions
| order by timestamp desc
| take 50
```

### 6. Vezi Business Events (Item Added)
```kql
customEvents
| where name in ("LeadSuccessfullyAdded", "ApplicationSuccessfullyAdded")
| project timestamp, name, customDimensions
| order by timestamp desc
```

### 7. Vezi Erori și Excepții
```kql
exceptions
| project timestamp, type, message, customDimensions
| order by timestamp desc
| take 50
```

### 8. Vezi Erori Duplicate Specific
```kql
exceptions
| where customDimensions.ErrorType == "DuplicateLead" 
   or customDimensions.ErrorType == "DuplicateApplication"
| project timestamp, type, message, customDimensions
| order by timestamp desc
```

### 9. Vezi Erori de Validare
```kql
customEvents
| where name in ("LeadValidationError", "ApplicationValidationError")
| project timestamp, name, customDimensions
| order by timestamp desc
```

### 10. Performance Health Check Endpoint
```kql
requests
| where url contains "/api/health"
| summarize 
    Count = count(),
    AvgDuration = avg(duration),
    MaxDuration = max(duration)
    by bin(timestamp, 1h)
| order by timestamp desc
```

## Screenshots

### Application Insights Logs - Requests
[Include screenshot cu tabelul requests cu coloanele: timestamp, name, url, resultCode, duration]

### Application Insights Logs - Custom Events
[Include screenshot cu tabelul customEvents cu ButtonClick și business events]

### Application Insights Logs - Exceptions
[Include screenshot cu tabelul exceptions cu duplicate și validation errors]

### Application Insights Dashboard
[Include screenshot cu dashboard-ul Application Insights cu metrici și grafice]

## Configurare

### Backend (`appsettings.json`)
```json
{
  "ApplicationInsights": {
    "ConnectionString": "InstrumentationKey=YOUR_KEY;IngestionEndpoint=https://..."
  }
}
```

### Frontend
Service-ul de telemetrie din frontend (`appInsightsService.ts`) trimite event-uri la endpoint-ul backend `/api/telemetry/track-event`, care le forward-uiește la Application Insights.

## Instrucțiuni de Testare

1. **Test Health Endpoint**:
   - Navighează la: `https://your-app-url/api/health`
   - Ar trebui să returneze 200 OK cu JSON response
   - Verifică Application Insights Logs pentru request

2. **Test Creare Lead (Succes)**:
   - POST la `/api/leads` cu date valide
   - Verifică Application Insights pentru event `LeadSuccessfullyAdded`

3. **Test Eroare Duplicate Lead**:
   - Creează un lead cu email `test@example.com`
   - Încearcă să creezi alt lead cu același email
   - Ar trebui să primești 409 Conflict
   - Verifică Application Insights pentru exception cu `ErrorType: "DuplicateLead"`

4. **Test Creare Aplicație (Succes)**:
   - Login și POST la `/api/applications` cu date valide
   - Verifică Application Insights pentru event `ApplicationSuccessfullyAdded`

5. **Test Eroare Duplicate Application**:
   - Creează o aplicație cu `TypeCredit: "nevoi_personale"`
   - Încearcă să creezi altă aplicație cu același tip
   - Ar trebui să primești 409 Conflict
   - Verifică Application Insights pentru exception cu `ErrorType: "DuplicateApplication"`

6. **Test Frontend Button Click**:
   - Click pe butonul "Register" pe ecranul de înregistrare
   - Verifică Application Insights pentru event `ButtonClick` cu `buttonName: "Register"`

7. **Test Input Invalid**:
   - POST la `/api/leads` fără `name` sau `email`
   - Ar trebui să primești 400 Bad Request
   - Verifică Application Insights pentru event `LeadValidationError`

## Fișiere Modificate/Create

### Backend
- `MoneyShop/MoneyShop.csproj` - Am adăugat pachetul NuGet Application Insights
- `MoneyShop/Program.cs` - Am configurat Application Insights
- `MoneyShop/Controllers/Api/HealthController.cs` - Health endpoint
- `MoneyShop/Controllers/Api/LeadsController.cs` - Am adăugat telemetrie pentru creare lead
- `MoneyShop/Controllers/Api/ApplicationsController.cs` - Am adăugat telemetrie pentru creare aplicație
- `MoneyShop/Controllers/Api/TelemetryController.cs` - Endpoint pentru event-uri frontend
- `MoneyShop/appsettings.json` - Am adăugat configurarea Application Insights

### Frontend
- `MoneyShopMobile/src/services/telemetry/appInsightsService.ts` - Service de telemetrie
- `MoneyShopMobile/src/screens/Auth/RegisterScreen.tsx` - Am adăugat tracking pentru button click
- `MoneyShopMobile/src/screens/Application/ApplicationWizardScreen.tsx` - Am adăugat tracking pentru button click
