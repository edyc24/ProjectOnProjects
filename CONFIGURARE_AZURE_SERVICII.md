# 📋 GHID CONFIGURARE AZURE ȘI SERVICII EXTERNE

## ✅ CE ESTE DEJA IMPLEMENTAT (fără Azure)

| Componentă | Status | Descriere |
|------------|--------|-----------|
| **OtpService** | ✅ | Generare/verificare OTP, hash HMAC-SHA256, rate limiting |
| **SmsService** | ✅ | Integrare Brevo API (mock în dev) |
| **EmailService** | ✅ | Trimitere email verificare |
| **SubjectService** | ✅ | CNP mascat + Subject ID stabil 5 ani |
| **KycService** | ✅ | Upload selfie/documente, verificare, ștergere 30 zile |
| **PdfGenerationService** | ✅ | Generare PDF mandate cu hash SHA-256 |
| **SimpleEligibilityEngine** | ✅ | Calculator eligibilitate (guest + avansat) |
| **EligibilityConfigService** | ✅ | Configurare reguli DTI, rate, praguri |
| **BrokerDirectoryService** | ✅ | Import Excel ANPC, căutare brokeri |
| **MandateService** | ✅ | Creare/revocare mandate 30 zile |
| **ConsentService** | ✅ | Salvare consimțăminte GDPR, T&C |
| **API Endpoints** | ✅ | /otp/*, /mandate/*, /kyc/*, /consent/* |
| **Pagini Web** | ✅ | Register, VerifyOtp, Mandate, KYC |

---

## 🔧 CE TREBUIE SĂ CONFIGUREZI TU

### 1️⃣ AZURE SQL DATABASE

**Ce trebuie să faci:**
1. Creează Azure SQL Database în Azure Portal
2. Rulează script-urile de migrare pentru a crea tabelele

**Pași:**
```
1. Azure Portal → Create Resource → Azure SQL Database
2. Selectează: 
   - Resource Group: MoneyShop-RG
   - Database Name: MoneyShop-DB
   - Server: Creează nou (ex: moneyshop-sql-server)
   - Compute: Basic/Standard S0 (pentru development)
3. Networking: Allow Azure services + Add your IP
4. Copiază Connection String
```

**Actualizează `appsettings.json`:**
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=tcp:moneyshop-sql-server.database.windows.net,1433;Initial Catalog=MoneyShop-DB;Persist Security Info=False;User ID={your_admin_user};Password={your_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }
}
```

---

### 2️⃣ AZURE BLOB STORAGE

**Ce trebuie să faci:**
1. Creează Storage Account
2. Creează containere pentru PDF-uri și KYC
3. Configurează lifecycle rules pentru ștergere automată

**Pași:**
```
1. Azure Portal → Create Resource → Storage Account
2. Selectează:
   - Resource Group: MoneyShop-RG
   - Storage Account Name: moneyshopdocs
   - Performance: Standard
   - Redundancy: LRS (Local)
3. După creare, mergi la: Containers → + Container
   - Creează: "ms-docs" (pentru PDF-uri)
   - Creează: "ms-kyc" (pentru documente KYC)
```

**Lifecycle Management (pentru ștergere automată KYC 30 zile):**
```
1. Storage Account → Data management → Lifecycle management
2. Add rule:
   - Name: delete-kyc-30days
   - Scope: Limit to blobs with specific prefixes: ms-kyc/
   - Blob type: Block blobs
   - Action: Delete blob after 30 days from creation
```

**Actualizează `appsettings.json`:**
```json
{
  "AzureBlob": {
    "ConnectionString": "DefaultEndpointsProtocol=https;AccountName=moneyshopdocs;AccountKey={your_key};EndpointSuffix=core.windows.net",
    "ContainerDocs": "ms-docs",
    "ContainerKyc": "ms-kyc"
  }
}
```

---

### 3️⃣ AZURE KEY VAULT

**Ce trebuie să faci:**
1. Creează Key Vault
2. Adaugă secretele pentru aplicație
3. Configurează access policies

**Pași:**
```
1. Azure Portal → Create Resource → Key Vault
2. Selectează:
   - Resource Group: MoneyShop-RG
   - Key Vault Name: moneyshop-kv
   - Region: West Europe (sau aproape de tine)
3. Access configuration: Azure RBAC (recomandat)
```

**Secrete de adăugat:**
| Secret Name | Valoare | Descriere |
|------------|---------|-----------|
| `Otp-Pepper` | (generează un string random de 32+ caractere) | Pentru hash OTP |
| `Subject-Pepper1` | (generează un string random de 32+ caractere) | Pentru hash CNP |
| `Subject-Pepper2` | (generează un string random de 32+ caractere) | Pentru Subject ID |
| `Jwt-SecretKey` | (generează un string random de 64+ caractere) | Pentru semnare JWT |
| `Brevo-ApiKey` | (din contul Brevo) | Pentru SMS |
| `CertSign-ApiKey` | (de la CertSign) | Pentru semnare PDF |

**Actualizează `appsettings.json`:**
```json
{
  "KeyVault": {
    "VaultUri": "https://moneyshop-kv.vault.azure.net/"
  }
}
```

---

### 4️⃣ SMS PROVIDER (BREVO)

**Ce trebuie să faci:**
1. Creează cont Brevo (fost Sendinblue)
2. Activează SMS transactional
3. Obține API Key

**Pași:**
```
1. Mergi la https://www.brevo.com/
2. Creează cont → Verifică email
3. Mergi la: SMTP & API → API Keys → Create new key
4. Activează SMS: Contacts → Settings → SMS settings
5. Adaugă credit SMS (minim 10€ pentru test)
```

**Actualizează `appsettings.json`:**
```json
{
  "Brevo": {
    "ApiKey": "xkeysib-...",
    "SmsSenderName": "MoneyShop"
  }
}
```

---

### 5️⃣ CERTSIGN (SEMNĂTURĂ ELECTRONICĂ)

**Ce trebuie să faci:**
1. Contactează CertSign pentru contract
2. Solicită API access pentru semnare PAdES
3. Obține certificatul și credențialele

**Email template pentru CertSign:**
```
Subiect: Solicitare integrare API semnare PDF PAdES

Bună ziua,

Reprezentăm compania POPIX BROKERAGE CONSULTING S.R.L. și dorim să integrăm 
soluția CertSign pentru semnare electronică PDF în platforma noastră MoneyShop.

Solicităm:
1. API/SDK server-side pentru semnare PDF (PAdES)
2. Profil recomandat: PAdES Baseline B (minim), ideal T/LT/LTA
3. Modalitate autentificare aplicație (OAuth2 client credentials / mTLS)
4. Documentație tehnică pentru integrare
5. Informații despre pricing și contract

Întrebare specifică: Putem semna automat, server-to-server, PDF-uri generate 
de noi, cu certificatul companiei, pentru depunere în SPV/ANAF?

Mulțumim,
[Numele tău]
```

**După ce primești credențialele:**
```json
{
  "CertSign": {
    "ApiUrl": "https://api.certsign.ro/v1/",
    "ClientId": "...",
    "ClientSecret": "...",
    "CertificateThumbprint": "..."
  }
}
```

---

### 6️⃣ ANAF API

**Ce trebuie să faci:**
1. Înregistrează aplicația în portal ANAF
2. Obține OAuth credentials
3. Solicită acces la API-urile necesare

**Pași:**
```
1. Mergi la: https://api.anaf.ro/
2. Creează cont cu certificat digital
3. Înregistrează aplicație nouă
4. Solicită acces la:
   - Verificare venituri persoane fizice
   - Date fiscale
5. Așteaptă aprobarea (poate dura 2-4 săptămâni)
```

**Documente necesare pentru ANAF:**
- CUI firmă
- Certificat digital valid (e-Guvernare)
- Descrierea scopului aplicației
- Adresă de redirecționare OAuth

**Actualizează `appsettings.json`:**
```json
{
  "Anaf": {
    "ApiUrl": "https://api.anaf.ro/prod/",
    "OAuthUrl": "https://logincert.anaf.ro/anaf-oauth2/v1/",
    "ClientId": "...",
    "ClientSecret": "...",
    "RedirectUri": "https://moneyshop.ro/callback/anaf"
  }
}
```

---

### 7️⃣ AZURE SERVICE BUS (OPȚIONAL)

**Pentru ce e necesar:**
- Queue pentru joburi asincrone (generare PDF, ANAF queries)
- Procesare în background

**Pași:**
```
1. Azure Portal → Create Resource → Service Bus
2. Selectează:
   - Resource Group: MoneyShop-RG
   - Namespace: moneyshop-servicebus
   - Pricing tier: Basic
3. După creare, creează queues:
   - q_generate_mandate_pdf
   - q_sign_mandate_pdf
   - q_submit_anaf
   - q_poll_anaf_result
```

**Actualizează `appsettings.json`:**
```json
{
  "ServiceBus": {
    "ConnectionString": "Endpoint=sb://moneyshop-servicebus.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey={your_key}"
  }
}
```

---

### 8️⃣ AZURE FUNCTIONS (OPȚIONAL)

**Pentru ce e necesar:**
- Cron job pentru ștergere automată KYC (30 zile)
- Cron job pentru expirare mandate
- Procesare queue-uri

**Funcții de creat:**
```csharp
// 1. Cleanup KYC files - rulează zilnic la 2:00 AM
[FunctionName("CleanupExpiredKyc")]
public static async Task Run([TimerTrigger("0 0 2 * * *")] TimerInfo myTimer)
{
    // Șterge fișierele KYC expirate
}

// 2. Expire mandates - rulează zilnic la 3:00 AM
[FunctionName("ExpireMandates")]
public static async Task Run([TimerTrigger("0 0 3 * * *")] TimerInfo myTimer)
{
    // Marchează mandate expirate
}
```

---

## 📋 CHECKLIST FINAL

### Development (Local)
- [ ] SQL Server local instalat
- [ ] Connection string configurat în `appsettings.Development.json`
- [ ] Migrări rulate (`dotnet ef database update`)
- [ ] Aplicația pornește fără erori

### Staging
- [ ] Azure SQL Database creat
- [ ] Azure Blob Storage creat
- [ ] Azure Key Vault creat cu toate secretele
- [ ] Brevo API key obținut
- [ ] Connection strings actualizate

### Production
- [ ] Toate cele de la Staging
- [ ] CertSign contract semnat și API activ
- [ ] ANAF API acces aprobat
- [ ] Azure Service Bus configurat
- [ ] Azure Functions deployed
- [ ] WAF (Web Application Firewall) activat
- [ ] SSL Certificate configurat
- [ ] Backup policy configurat pentru SQL

---

## 💰 COSTURI ESTIMATE (AZURE)

| Serviciu | Tier | Cost/lună (estimat) |
|----------|------|---------------------|
| Azure SQL Database | Basic (5 DTU) | ~$5 |
| Azure Blob Storage | Standard LRS | ~$2-5 |
| Azure Key Vault | Standard | ~$1 |
| Azure Service Bus | Basic | ~$0.05/mil mesaje |
| Azure Functions | Consumption | ~$0 (free tier) |
| **TOTAL DEV** | | **~$10-15/lună** |

| Serviciu | Tier | Cost/lună (estimat) |
|----------|------|---------------------|
| Azure SQL Database | Standard S2 | ~$75 |
| Azure Blob Storage | Standard LRS | ~$10-20 |
| Azure Key Vault | Standard | ~$3 |
| Azure Service Bus | Standard | ~$10 |
| Azure Functions | Consumption | ~$5-10 |
| **TOTAL PROD** | | **~$100-120/lună** |

---

## 🔗 LINK-URI UTILE

- **Azure Portal**: https://portal.azure.com/
- **Brevo (SMS)**: https://www.brevo.com/
- **ANAF API Portal**: https://api.anaf.ro/
- **CertSign**: https://www.certsign.ro/
- **Lista brokeri ANPC**: https://asfromania.ro/registre-asf

---

## 📞 SUPORT

Pentru întrebări tehnice despre implementare, verifică:
1. Fișierele din `/BusinessLogic/Implementation/` pentru logica de business
2. Fișierele din `/Controllers/Api/` pentru endpoints
3. Fișierele din `/Views/` pentru interfețe

Toate serviciile sunt deja conectate și funcționale. Trebuie doar să configurezi conexiunile externe!

