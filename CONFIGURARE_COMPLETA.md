# Configurare Completă MoneyShop - Checklist

Acest document conține toate configurările necesare pentru a rula aplicația MoneyShop în producție.

## 📋 Status Configurare

Folosește acest checklist pentru a marca ce ai configurat:

- [ ] Azure SQL Database Connection String
- [ ] OpenAI API Key (Chatbot)
- [ ] Oblio API Credentials (Facturi)
- [ ] Application Insights Connection String
- [ ] Email/SMTP Configuration
- [ ] Twilio SMS (opțional)
- [ ] JWT Secret Key (Production)
- [ ] Subject/Pepper Keys (Production)
- [ ] React Native API URLs

---

## 1. 🗄️ Azure SQL Database

### Connection String

**Fișier:** `MoneyShop/appsettings.json` și `MoneyShop/appsettings.Development.json`

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=tcp:moneyshop.database.windows.net,1433;Initial Catalog=moneyshop;Persist Security Info=False;User ID=alexmoore;Password=Moneyshop2026?;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }
}
```

**✅ Status:** Deja configurat

**⚠️ Acțiuni necesare:**
- [ ] Verifică că parola este corectă și securizată
- [ ] Pentru producție, folosește Azure Key Vault în loc de hardcoding
- [ ] Verifică că firewall-ul Azure SQL permite conexiuni din Azure App Service

---

## 2. 🤖 OpenAI API (Chatbot Virtual)

### Obținere API Key

1. Accesează: https://platform.openai.com
2. Creează cont sau autentifică-te
3. Mergi la **API Keys** → **Create new secret key**
4. Copiază cheia (începe cu `sk-...`)
5. **IMPORTANT:** Salvează cheia imediat, nu o vei mai putea vedea!

### Configurare

**Fișier:** `MoneyShop/appsettings.json`

```json
{
  "OpenAI": {
    "ApiKey": "sk-tokenul-tau-openai-aici",
    "ModelPrimary": "gpt-3.5-turbo",
    "ModelFallback": "gpt-4o-mini",
    "MaxOutputTokens": 350,
    "BudgetUsdMonth": 150,
    "SystemPrompt": "Esti Asistentul Virtual MoneyShop pentru POPIX BROKERAGE CONSULTING S.R.L. (broker de credite / intermediar, NU institutie de credit). Rolul tau este sa explici pe intelesul tuturor concepte de creditare, eligibilitate, documente, pasi de urmat si sa ajuti utilizatorii sa inteleaga rezultatele calculatoarelor MoneyShop. REGULI OBLIGATORII (nu ai voie sa le incalci): 1) NU ai voie niciodata sa mentionezi, sa listezi, sa compari sau sa recomanzi nume de banci, IFN-uri sau branduri financiare. 2) NU promite aprobari si NU garanta dobanzi. 3) NU solicita si NU afisa date sensibile: CNP, serie/numar CI, numar complet card, parole, OTP. 4) Raspunsurile trebuie sa fie in romana fara diacritice, clare, scurte, structurate. 5) Daca nu esti sigur, spune ce informatie minima lipseste si pune 1-2 intrebari scurte."
  },
  "Chat": {
    "RateLimitPerMinute": 20,
    "RateLimitPerDay": 200,
    "FaqCacheEnabled": true
  }
}
```

**✅ Status:** ⚠️ NECESITĂ CONFIGURARE

**⚠️ Acțiuni necesare:**
- [ ] Adaugă `ApiKey` în `appsettings.json`
- [ ] Verifică că bugetul lunar (150 USD) este suficient pentru nevoile tale
- [ ] Pentru producție, folosește Azure Key Vault sau App Settings din Azure Portal
- [ ] Rulează scripturile SQL pentru tabelele de chat:
  - `DataAccess/Scripts/CreateChatTables.sql`
  - `DataAccess/Scripts/CreateFaqTable.sql`
  - `DataAccess/Scripts/SeedFaqItems.sql`
  - `DataAccess/Scripts/CreateLeadTables.sql`

**📚 Documentație:** Vezi `CHAT_ASSISTENT_VIRTUAL.md`

---

## 3. 📄 Oblio API (Generare Facturi)

### Obținere Credențiale

1. Accesează: https://www.oblio.eu
2. Autentifică-te în contul tău
3. Mergi la **Setări** → **Date Cont**
4. Copiază:
   - **Client ID** (email-ul cu care te autentifici)
   - **Client Secret** (token-ul generat)

### Configurare

**Fișier:** `MoneyShop/appsettings.json`

```json
{
  "Oblio": {
    "ClientId": "email@exemplu.com",
    "ClientSecret": "token-ul-tau-oblio-aici"
  }
}
```

**✅ Status:** ⚠️ NECESITĂ CONFIGURARE

**⚠️ Acțiuni necesare:**
- [ ] Adaugă `ClientId` și `ClientSecret` în `appsettings.json`
- [ ] **IMPORTANT:** Token-ul `ClientSecret` se regenerează când resetezi parola în Oblio
- [ ] Pentru producție, folosește Azure Key Vault
- [ ] Verifică că contul Oblio este activ și are planul necesar

**📚 Documentație:** Vezi `OBLIO_INTEGRATION.md`

**📞 Suport Oblio:**
- Email: contact@oblio.eu
- Telefon: 0800 831 333
- API Docs: https://www.oblio.eu/api

---

## 4. 📊 Azure Application Insights (Telemetrie)

### Obținere Connection String

1. Accesează Azure Portal: https://portal.azure.com
2. Navighează la **Application Insights** resource
3. Mergi la **Overview** → **Connection String**
4. Copiază connection string-ul complet

### Configurare

**Fișier:** `MoneyShop/appsettings.json`

```json
{
  "ApplicationInsights": {
    "ConnectionString": "InstrumentationKey=xxxx-xxxx-xxxx;IngestionEndpoint=https://xxxx.applicationinsights.azure.com/;LiveEndpoint=https://xxxx.livediagnostics.monitor.azure.com/"
  }
}
```

**✅ Status:** ⚠️ NECESITĂ CONFIGURARE

**⚠️ Acțiuni necesare:**
- [ ] Creează un Application Insights resource în Azure (dacă nu există)
- [ ] Adaugă `ConnectionString` în `appsettings.json`
- [ ] Pentru producție, folosește App Settings din Azure Portal
- [ ] Verifică că telemetria este activă în cod (vezi `HOMEWORK_3_README.md`)

**📚 Documentație:** Vezi `HOMEWORK_3_README.md`

---

## 5. 📧 Email/SMTP Configuration

### Configurare pentru Outlook/Hotmail

**Fișier:** `MoneyShop/appsettings.Development.json`

```json
{
  "Email": {
    "SmtpHost": "smtp-mail.outlook.com",
    "SmtpPort": "587",
    "SmtpUsername": "email@outlook.com",
    "SmtpPassword": "parola-ta-aici",
    "FromEmail": "email@outlook.com",
    "FromName": "MoneyShop"
  }
}
```

**✅ Status:** ⚠️ NECESITĂ CONFIGURARE

**⚠️ Acțiuni necesare:**
- [ ] Adaugă credențialele SMTP în `appsettings.Development.json`
- [ ] Pentru Outlook/Hotmail, poate fi necesar să activezi "App Passwords" (2FA)
- [ ] Pentru Gmail, folosește:
  - `SmtpHost`: `smtp.gmail.com`
  - `SmtpPort`: `587`
  - `SmtpUsername`: email-ul tău Gmail
  - `SmtpPassword`: App Password (nu parola normală)
- [ ] Pentru producție, folosește Azure Communication Services sau SendGrid

**🔐 Securitate:**
- Nu folosi parola normală pentru Gmail/Outlook
- Folosește "App Passwords" sau "Application Passwords"
- Pentru producție, folosește Azure Key Vault

---

## 6. 📱 Twilio SMS (Opțional)

### Obținere Credențiale

1. Accesează: https://www.twilio.com
2. Creează cont sau autentifică-te
3. Mergi la **Console** → **Account** → **API Keys & Tokens**
4. Copiază:
   - **Account SID**
   - **Auth Token**
   - **Phone Number** (din Twilio)

### Configurare

**Fișier:** `MoneyShop/appsettings.Development.json`

```json
{
  "Twilio": {
    "AccountSid": "ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
    "AuthToken": "token-ul-tau-twilio",
    "FromPhoneNumber": "+1234567890"
  }
}
```

**✅ Status:** ⚠️ OPȚIONAL (doar dacă folosești SMS)

**⚠️ Acțiuni necesare:**
- [ ] Adaugă credențialele Twilio (doar dacă folosești SMS)
- [ ] Verifică că numărul Twilio este verificat
- [ ] Pentru producție, folosește Azure Key Vault

---

## 7. 🔐 JWT Authentication (Production)

### Generare Secret Key

**IMPORTANT:** Pentru producție, generează un secret key puternic și sigur!

**Opțiune 1: PowerShell**
```powershell
$bytes = New-Object byte[] 32
[System.Security.Cryptography.RandomNumberGenerator]::Fill($bytes)
[Convert]::ToBase64String($bytes)
```

**Opțiune 2: Online**
- Accesează: https://www.grc.com/passwords.htm
- Generează un password de 64+ caractere

### Configurare

**Fișier:** `MoneyShop/appsettings.json`

```json
{
  "JwtSettings": {
    "SecretKey": "GENEREAZA-UN-SECRET-KEY-PUTERNIC-MINIM-32-CARACTERE-PENTRU-PRODUCTIE",
    "Issuer": "MoneyShop",
    "Audience": "MoneyShopUsers",
    "ExpirationMinutes": 1440
  }
}
```

**✅ Status:** ⚠️ NECESITĂ SCHIMBARE PENTRU PRODUCȚIE

**⚠️ Acțiuni necesare:**
- [ ] **SCHIMBĂ** `SecretKey` cu un secret puternic generat
- [ ] Minim 32 caractere, recomandat 64+
- [ ] Pentru producție, folosește Azure Key Vault
- [ ] Nu comite secret key-ul în Git!

---

## 8. 🔒 Subject/Pepper Keys (Criptare CNP)

### Generare Pepper Keys

Folosește aceeași metodă ca pentru JWT Secret Key.

### Configurare

**Fișier:** `MoneyShop/appsettings.json`

```json
{
  "Subject": {
    "Pepper1": "GENEREAZA-UN-PEPPER-KEY-PUTERNIC-PENTRU-CNP-1",
    "Pepper2": "GENEREAZA-UN-PEPPER-KEY-PUTERNIC-PENTRU-CNP-2",
    "DefaultPepper": "GENEREAZA-UN-PEPPER-KEY-PUTERNIC-DEFAULT"
  }
}
```

**✅ Status:** ⚠️ NECESITĂ SCHIMBARE PENTRU PRODUCȚIE

**⚠️ Acțiuni necesare:**
- [ ] **SCHIMBĂ** toate pepper keys cu valori puternice generate
- [ ] Minim 32 caractere fiecare
- [ ] Pentru producție, folosește Azure Key Vault
- [ ] Nu comite pepper keys în Git!

---

## 9. 📱 React Native - API URLs

### Configurare pentru Development

**Fișier:** `MoneyShopMobile/src/utils/constants.ts`

```typescript
const LOCAL_IP = '192.168.1.100'; // IP-ul tău local
const API_BASE_URL = __DEV__
  ? `http://${LOCAL_IP}:5259/api` // Development
  : 'https://api.moneyshop.ro/api'; // Production
```

**✅ Status:** ⚠️ NECESITĂ CONFIGURARE

**⚠️ Acțiuni necesare:**
- [ ] Actualizează `LOCAL_IP` cu IP-ul tău local pentru development
- [ ] Actualizează URL-ul de producție cu domeniul real
- [ ] Verifică că backend-ul rulează pe portul corect (5259 pentru development)

---

## 10. 🗃️ Baza de Date - Scripturi SQL

### Verificare Tabele

Rulează scriptul pentru a verifica ce tabele lipsesc:

```sql
-- Rulează: DataAccess/Scripts/VerifyAllTables.sql
```

### Scripturi de Creare

Dacă lipsesc tabele, rulează scripturile corespunzătoare:

1. **Tabele de bază:**
   - `DataAccess/Scripts/Complete_Database_Setup_Azure.sql`

2. **Tabele pentru Chat:**
   - `DataAccess/Scripts/CreateChatTables.sql`
   - `DataAccess/Scripts/CreateFaqTable.sql`
   - `DataAccess/Scripts/SeedFaqItems.sql`

3. **Tabele pentru Lead Capture:**
   - `DataAccess/Scripts/CreateLeadTables.sql`

4. **Tabele pentru Eligibility:**
   - `DataAccess/Scripts/CreateEligibilityTables.sql`

**📚 Documentație:** Vezi `DataAccess/Scripts/README_SCRIPTS.md`

---

## 11. 🚀 Azure App Service - App Settings

### Configurare pentru Producție

În Azure Portal, pentru App Service, adaugă următoarele **App Settings**:

```
ConnectionStrings__DefaultConnection = [connection-string]
OpenAI__ApiKey = [openai-key]
Oblio__ClientId = [oblio-client-id]
Oblio__ClientSecret = [oblio-secret]
ApplicationInsights__ConnectionString = [app-insights-connection]
JwtSettings__SecretKey = [jwt-secret]
Subject__Pepper1 = [pepper1]
Subject__Pepper2 = [pepper2]
Subject__DefaultPepper = [default-pepper]
Email__SmtpHost = [smtp-host]
Email__SmtpPort = [smtp-port]
Email__SmtpUsername = [smtp-username]
Email__SmtpPassword = [smtp-password]
Email__FromEmail = [from-email]
Email__FromName = MoneyShop
```

**⚠️ IMPORTANT:**
- Folosește dublu underscore (`__`) pentru nested properties
- Nu comite valori sensibile în Git
- Activează "Application Insights" în App Service

---

## 12. 🔐 Azure Key Vault (Recomandat pentru Producție)

### Configurare Key Vault

1. Creează un Azure Key Vault
2. Adaugă toate secret-urile:
   - `OpenAI-ApiKey`
   - `Oblio-ClientId`
   - `Oblio-ClientSecret`
   - `Jwt-SecretKey`
   - `Subject-Pepper1`
   - `Subject-Pepper2`
   - `Subject-DefaultPepper`
   - `Email-SmtpPassword`
   - `Twilio-AuthToken` (dacă folosești)

3. Configurează App Service să citească din Key Vault:
   - Mergi la **App Service** → **Configuration** → **Identity**
   - Activează **System assigned managed identity**
   - În Key Vault, adaugă access policy pentru App Service identity

4. În App Settings, folosește referințe Key Vault:
   ```
   @Microsoft.KeyVault(SecretUri=https://vault-name.vault.azure.net/secrets/secret-name/)
   ```

---

## 13. ✅ Checklist Final

### Înainte de Deploy în Producție

- [ ] Toate API keys sunt configurate
- [ ] Toate connection strings sunt corecte
- [ ] Secret keys sunt schimbate (JWT, Pepper)
- [ ] Tabelele din baza de date sunt create
- [ ] Application Insights este configurat
- [ ] Email/SMTP funcționează (testează!)
- [ ] React Native API URLs sunt corecte
- [ ] Azure App Service App Settings sunt configurate
- [ ] Azure Key Vault este configurat (recomandat)
- [ ] Firewall-ul Azure SQL permite conexiuni din App Service
- [ ] CORS este configurat corect pentru frontend
- [ ] SSL/TLS este activat pentru API

---

## 14. 🧪 Testare Configurare

### Test OpenAI Chatbot

```bash
# Test endpoint
curl -X POST https://api.moneyshop.ro/api/chat \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"message": "Ce este gradul de indatorare?"}'
```

### Test Oblio API

```bash
# Test endpoint
curl -X GET https://api.moneyshop.ro/api/oblio/companies \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Test Application Insights

1. Accesează Azure Portal → Application Insights
2. Verifică că telemetria apare în **Live Metrics** sau **Logs**

---

## 15. 📞 Suport și Resurse

### Documentație Internă

- `CHAT_ASSISTENT_VIRTUAL.md` - Chatbot OpenAI
- `OBLIO_INTEGRATION.md` - Integrare Oblio
- `HOMEWORK_3_README.md` - Application Insights
- `DataAccess/Scripts/README_SCRIPTS.md` - Scripturi SQL

### Resurse Externe

- **OpenAI:** https://platform.openai.com/docs
- **Oblio:** https://www.oblio.eu/api
- **Azure Application Insights:** https://docs.microsoft.com/azure/azure-monitor/app/app-insights-overview
- **Azure Key Vault:** https://docs.microsoft.com/azure/key-vault/

---

## 16. ⚠️ Securitate - Best Practices

1. **NU comite** valori sensibile în Git
2. **Folosește** `.gitignore` pentru `appsettings.json` cu valori reale
3. **Schimbă** toate secret keys înainte de producție
4. **Folosește** Azure Key Vault pentru producție
5. **Activează** HTTPS pentru toate endpoint-urile
6. **Configurează** CORS corect (doar domeniile necesare)
7. **Monitorizează** logurile pentru accesuri neautorizate
8. **Rotatează** secret keys periodic
9. **Folosește** Managed Identity pentru Azure services
10. **Activează** Application Insights pentru monitoring

---

## 📝 Notițe

- Toate valorile din `appsettings.json` sunt placeholder-uri
- Pentru development, poți folosi valori de test
- Pentru producție, **OBLIGATORIU** să folosești valori reale și securizate
- Verifică periodic că toate serviciile externe sunt active și funcționale

---

**Ultima actualizare:** 2026-01-07

