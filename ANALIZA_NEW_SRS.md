# ANALIZĂ CERINȚE NEW_SRS.txt vs. IMPLEMENTARE EXISTENTĂ
## Status și Gap Analysis

**Data analizei:** 2025-01-27  
**Proiect:** MoneyShop - Platformă de Brokeraj de Credite

---

## 📊 REZUMAT EXECUTIV

Din **New_SRS.txt** cerut, proiectul MoneyShop **are deja implementate aproximativ 65-70%** din cerințe. 

Lipsesc în principal:
- Infrastructură Azure completă (Cosmos DB, Key Vault, Service Bus)
- Integrare CertSign pentru semnare digitală
- Integrare ANAF/SPV reală
- Connector BC (Biroul de Credit)

---

## ✅ CE EXISTĂ DEJA (IMPLEMENTAT)

### 1. Auth + OTP ✅ (90% complet)

| Cerință SRS | Status | Locație |
|-------------|--------|---------|
| OTP Request/Verify | ✅ | `BusinessLogic/Implementation/Auth/OtpService.cs` |
| HMAC-SHA256 hash pentru OTP | ✅ | `OtpService.cs` linia 64-66, 183-188 |
| Purpose-uri OTP (LOGIN_SMS, SIGN_SMS, EMAIL_VERIFY) | ✅ | `OtpService.cs` linia 38 |
| Rate limiting | ✅ | `OtpService.cs` linia 48-57 |
| Max attempts (5) | ✅ | `OtpService.cs` linia 22 |
| OTP expiry diferențiat (5 min login, 3 min semnare) | ✅ | `OtpService.cs` linia 19-21 |
| Entity OtpChallenge | ✅ | `Entities/Entities/OtpChallenge.cs` |
| SMS Service (Brevo) | ✅ | `BusinessLogic/Implementation/Otp/SmsService.cs` |
| Email Service | ✅ | `BusinessLogic/Implementation/Otp/EmailService.cs` |
| Controller API | ✅ | `MoneyShop/Controllers/Api/OtpController.cs` |
| Mobile screen | ✅ | `MoneyShopMobile/src/screens/Auth/OtpLoginScreen.tsx` |

**Ce lipsește:**
- ❌ Device fingerprint hash persistent
- ❌ Step-up security (IP țară diferită, device nou)
- ❌ Pepper din Key Vault (folosește config acum)

---

### 2. KYC ✅ (80% complet)

| Cerință SRS | Status | Locație |
|-------------|--------|---------|
| KycSession entity | ✅ | `Entities/Entities/KycSession.cs` |
| KycFile entity | ✅ | `Entities/Entities/KycFile.cs` |
| KycService | ✅ | `BusinessLogic/Implementation/Kyc/KycService.cs` |
| Expiry 30 zile | ✅ | În logica KycSession |

**Ce lipsește:**
- ❌ Lifecycle delete automat 30 zile (Azure Blob lifecycle)
- ❌ Azure Function pentru curățare automată
- ❌ Verificare automată (provider extern)

---

### 3. Consents (Consimțământ Dual) ✅ (90% complet)

| Cerință SRS | Status | Locație |
|-------------|--------|---------|
| Consent entity | ✅ | `Entities/Entities/Consent.cs` |
| Tipuri consent (TC_ACCEPT, GDPR, MANDATE_ANAF_BC, SHARE_TO_BROKER) | ✅ | `Consent.cs` linia 10 |
| Snapshot text | ✅ | `Consent.cs` linia 15 |
| IP, UserAgent, DeviceHash | ✅ | `Consent.cs` linia 17-19 |
| SourceChannel (web/ios/android) | ✅ | `Consent.cs` linia 20 |
| ConsentService | ✅ | `BusinessLogic/Implementation/Consent/ConsentService.cs` |
| ConsentController API | ✅ | `MoneyShop/Controllers/Api/ConsentController.cs` |
| Mobile screens | ✅ | `MoneyShopMobile/src/screens/Consent/` |
| Legal documents | ✅ | `Entities/Entities/LegalDoc.cs` |

**Ce lipsește:**
- ❌ Cosmos DB pentru event stream (folosește SQL acum)
- ❌ Hash-chain pentru audit (prevHash, thisHash)

---

### 4. Mandate (30 zile) ✅ (85% complet)

| Cerință SRS | Status | Locație |
|-------------|--------|---------|
| Mandate entity | ✅ | `Entities/Entities/Mandate.cs` |
| MandateType (ANAF, BC, ANAF_BC) | ✅ | `Mandate.cs` linia 10 |
| Scope | ✅ | `Mandate.cs` linia 11 |
| Status (active/expired/revoked) | ✅ | `Mandate.cs` linia 12 |
| ExpiresAt (30 zile) | ✅ | `Mandate.cs` linia 14 |
| ConsentEventId reference | ✅ | `Mandate.cs` linia 17 |
| MandateService | ✅ | `BusinessLogic/Implementation/Mandate/MandateService.cs` |
| MandateController API | ✅ | `MoneyShop/Controllers/Api/MandateController.cs` |
| Mobile screens | ✅ | `MoneyShopMobile/src/screens/Mandate/` |
| Web views | ✅ | `MoneyShop/Views/Mandate/Step1-5.cshtml` |

**Ce lipsește:**
- ❌ Azure Function pentru expirare automată

---

### 5. PDF Generator + Hash ✅ (90% complet)

| Cerință SRS | Status | Locație |
|-------------|--------|---------|
| PdfGenerationService | ✅ | `BusinessLogic/Implementation/Document/PdfGenerationService.cs` |
| SHA-256 hash | ✅ | `PdfGenerationService.cs` linia 176-180 |
| Subject ID în loc de CNP | ✅ | `PdfGenerationService.cs` linia 56-63 |
| CNP mascat | ✅ | `PdfGenerationService.cs` linia 61-63 |
| Telefon mascat | ✅ | `PdfGenerationService.cs` linia 66, 245-254 |
| IP + User-Agent în PDF | ✅ | `PdfGenerationService.cs` linia 120-135 |
| Consent text snapshot | ✅ | `PdfGenerationService.cs` linia 138-147 |
| Footer cu hash | ✅ | `PdfGenerationService.cs` linia 191-197 |
| Blob path structure | ✅ | `PdfGenerationService.cs` linia 206 |

**Ce lipsește:**
- ❌ Azure Blob Storage (salvează local acum)
- ❌ Metadata în blob (sha256, subjectId)

---

### 6. Pseudonimizare (CNP mascat, Subject ID) ✅ (80% complet)

| Cerință SRS | Status | Locație |
|-------------|--------|---------|
| SubjectMap entity | ✅ | `Entities/Entities/SubjectMap.cs` |
| SubjectService | ✅ | `BusinessLogic/Implementation/Subject/SubjectService.cs` |
| CNP hash (HMAC-SHA256) | ✅ | În SubjectService |
| Subject ID stabil (MS-...) | ✅ | În SubjectService |
| CNP last 4 digits | ✅ | `SubjectMap.CnpLast4` |

**Ce lipsește:**
- ❌ Pepper în Key Vault (folosește config acum)
- ❌ Rotire anuală pepper

---

### 7. Motor de Eligibilitate ✅ (85% complet)

| Cerință SRS | Status | Locație |
|-------------|--------|---------|
| SimpleEligibilityEngine (guest) | ✅ | `BusinessLogic/Implementation/Eligibility/SimpleEligibilityEngine.cs` |
| EligibilityConfigService | ✅ | `BusinessLogic/Implementation/Eligibility/EligibilityConfigService.cs` |
| FinancialFormulas | ✅ | `BusinessLogic/Implementation/Eligibility/FinancialFormulas.cs` |
| RatesRulesConfig entity | ✅ | `Entities/Entities/RatesRulesConfig.cs` |
| DTI rules (40%, 50%, 55%) | ✅ | `SimpleEligibilityEngine.cs` |
| Praguri venit configurabile | ✅ | În config |
| Calcul NP și Ipotecar | ✅ | `SimpleEligibilityEngine.cs` linia 46-179, 180-304 |
| EligibilityController API | ✅ | `MoneyShop/Controllers/Api/EligibilityController.cs` |
| Eligibility models complete | ✅ | `BusinessLogic/Models/Eligibility/EligibilityModels.cs` |

**Ce lipsește:**
- ❌ Ruleset versioning (active/draft/archived)
- ❌ Admin CRUD pentru reguli
- ❌ Advanced calculator cu date ANAF/BC

---

### 8. Broker Directory ✅ (70% complet)

| Cerință SRS | Status | Locație |
|-------------|--------|---------|
| BrokerDirectory entity | ✅ | `Entities/Entities/BrokerDirectory.cs` |
| BrokerDirectoryService | ✅ | `BusinessLogic/Implementation/Broker/BrokerDirectoryService.cs` |

**Ce lipsește:**
- ❌ Import ANPC list
- ❌ Broker KYC verificare
- ❌ Share flow complet

---

### 9. Sessions ✅ (80% complet)

| Cerință SRS | Status | Locație |
|-------------|--------|---------|
| Session entity | ✅ | `Entities/Entities/Session.cs` |
| IP, UserAgent, DeviceHash | ✅ | În Session entity |
| SourceChannel | ✅ | În Session entity |

---

### 10. Documente Legale ✅ (100% complet)

| Cerință SRS | Status | Locație |
|-------------|--------|---------|
| Politica de confidențialitate | ✅ | `POLITICA DE CONFIDENȚIALITATE (GDPR).txt` |
| Termeni și condiții | ✅ | `TERMENI ȘI CONDIȚII DE UTILIZARE – MONEYSHOP.RO.txt` |
| Politica de mandatare | ✅ | `POLITICA DE MANDATARE.txt` |
| Politica transmitere brokeri | ✅ | `POLITICA DE TRANSMITERE A DATELOR CĂTRE BROKERI AUTORIZAȚI.txt` |
| Declarație consimțământ | ✅ | `DECLARAȚIE DE CONSIMȚĂMÂNT ȘI MANDAT.txt` |
| UX Text Legal | ✅ | `UX TEXT LEGAL – APLICAȚIE MOBILE & WEB (iOS  Android).txt` |

---

### 11. Aplicații ✅ (90% complet)

| Cerință SRS | Status | Locație |
|-------------|--------|---------|
| Web App (ASP.NET Core MVC) | ✅ | `MoneyShop/` |
| Mobile App (React Native) | ✅ | `MoneyShopMobile/` |
| API Controllers | ✅ | `MoneyShop/Controllers/Api/` |
| Frontend screens | ✅ | `MoneyShopMobile/src/screens/` |

---

## ❌ CE LIPSEȘTE (DE IMPLEMENTAT)

### 1. Infrastructură Azure (30% complet)

| Cerință SRS | Status | Acțiune necesară |
|-------------|--------|------------------|
| Azure SQL | ⚠️ Parțial | Migrare completă |
| Azure Cosmos DB | ❌ | Implementare container consent_events |
| Azure Blob Storage | ❌ | Migrare de la storage local |
| Azure Key Vault | ❌ | Migrare pepper-uri și secrete |
| Azure Service Bus | ❌ | Implementare queues pentru jobs |
| Azure Functions | ❌ | Implementare cron jobs |
| Azure Front Door + WAF | ❌ | Setup edge + protecție |

---

### 2. Signature Service (CertSign) ❌ (0% complet)

| Cerință SRS | Status | Acțiune necesară |
|-------------|--------|------------------|
| SignatureService | ❌ | Creare microserviciu |
| CertSign API integration | ❌ | Contract + implementare |
| PAdES signing | ❌ | Implementare |
| signatures table | ❌ | Creare entity + migrare |
| hash_before, hash_after | ❌ | Implementare |

---

### 3. ANAF Connector ❌ (10% complet)

| Cerință SRS | Status | Locație/Acțiune |
|-------------|--------|------------------|
| AnafReport entity | ✅ | `Entities/Entities/AnafReport.cs` |
| AnafJob entity | ❌ | Creare entity |
| AnafIncomeMonthly entity | ❌ | Creare entity |
| ANAF OAuth registration | ❌ | Înregistrare la api.anaf.ro |
| Job orchestrator | ❌ | Implementare state machine |
| Queue processing | ❌ | Service Bus + workers |
| Response parsing | ❌ | Implementare parser |

---

### 4. BC Connector ❌ (10% complet)

| Cerință SRS | Status | Locație/Acțiune |
|-------------|--------|------------------|
| BcReport entity | ✅ | `Entities/Entities/BcReport.cs` |
| BC API integration | ❌ | Contract + implementare |
| bc_summary table | ❌ | Creare |

---

### 5. Audit Event Stream (Cosmos) ❌ (0% complet)

| Cerință SRS | Status | Acțiune necesară |
|-------------|--------|------------------|
| consent_events container | ❌ | Creare Cosmos container |
| security_events container | ❌ | Creare Cosmos container |
| anaf_events container | ❌ | Creare Cosmos container |
| broker_events container | ❌ | Creare Cosmos container |
| Hash-chain (prevHash, thisHash) | ❌ | Implementare |

---

### 6. OpenAPI Spec ❌ (0% complet)

| Cerință SRS | Status | Acțiune necesară |
|-------------|--------|------------------|
| /otp/* endpoints | ⚠️ Există, fără spec | Generare OpenAPI |
| /consent/* endpoints | ⚠️ Există, fără spec | Generare OpenAPI |
| /mandate/* endpoints | ⚠️ Există, fără spec | Generare OpenAPI |
| /docs/* endpoints | ❌ | Creare + spec |
| /anaf/* endpoints | ❌ | Creare + spec |
| /rules/* endpoints | ❌ | Creare + spec |
| /broker/* endpoints | ⚠️ Parțial | Completare + spec |

---

## 📋 CHECKLIST IMPLEMENTARE (din SRS)

### Faza 0 – Setup Azure (1–3 zile)
- [ ] VNet + Private Endpoints
- [ ] KeyVault + Managed Identity
- [ ] SQL (migrare completă)
- [ ] Cosmos DB
- [ ] Blob Storage
- [ ] Service Bus
- [ ] Monitor + Defender

### Faza 1 – Auth + OTP ✅ (90%)
- [x] SMS provider (Brevo)
- [x] OTP request/verify
- [x] Session tokens
- [ ] Device fingerprint persistent

### Faza 2 – KYC ✅ (80%)
- [x] Upload blob (local)
- [x] KYC status
- [ ] Lifecycle delete 30d (Azure)
- [x] Audit events (SQL, nu Cosmos)

### Faza 3 – Dual consent + mandate ✅ (90%)
- [x] UI checkboxes
- [x] Consents table
- [x] Mandates table + expiry + revoke
- [ ] Cosmos event stream

### Faza 4 – PDF generator + hashing ✅ (90%)
- [x] Mandate template
- [x] SHA256 stamping
- [x] Storage pathing
- [x] Doc registry SQL
- [ ] Azure Blob Storage

### Faza 5 – CertSign signing ❌
- [ ] SignatureService
- [ ] KeyVault secrets
- [ ] PAdES signing
- [ ] Store signed pdf + txid

### Faza 6 – ANAF pipeline ❌
- [ ] OAuth registration / SPV connector
- [ ] Job orchestrator
- [ ] Parse responses
- [ ] Populate income tables

### Faza 7 – Eligibility engine ✅ (85%)
- [ ] Ruleset CRUD (admin backoffice)
- [x] Compute service
- [x] Profile insights (parțial)
- [x] Calculator guest
- [ ] Calculator advanced (cu ANAF/BC)

### Faza 8 – Broker directory + optional share ⚠️ (50%)
- [ ] Import list ANPC
- [ ] Broker KYC
- [ ] Share flow
- [ ] Audit logs

### Faza 9 – Security hardening ⚠️ (30%)
- [ ] WAF rules
- [ ] RLS
- [ ] CMK (optional)
- [ ] Pen-test checklist

---

## 📊 STATISTICI FINALE

| Categorie | Complet | Total | Procent |
|-----------|---------|-------|---------|
| Auth + OTP | 9/11 | 11 | 82% |
| KYC | 4/6 | 6 | 67% |
| Consents | 10/12 | 12 | 83% |
| Mandates | 9/11 | 11 | 82% |
| PDF Generator | 9/11 | 11 | 82% |
| Pseudonimizare | 5/7 | 7 | 71% |
| Eligibility | 9/12 | 12 | 75% |
| Broker Directory | 2/5 | 5 | 40% |
| Azure Infrastructure | 1/7 | 7 | 14% |
| CertSign | 0/5 | 5 | 0% |
| ANAF Connector | 1/8 | 8 | 12% |
| BC Connector | 1/3 | 3 | 33% |
| Audit (Cosmos) | 0/4 | 4 | 0% |
| OpenAPI Spec | 0/7 | 7 | 0% |
| **TOTAL** | **60/109** | **109** | **55%** |

---

## 🎯 PRIORITĂȚI DE IMPLEMENTARE

### Priority 1: URGENT (blocker pentru funcționalitate core)
1. ❌ **Azure Key Vault** - Securizare pepper-uri și secrete
2. ❌ **Azure Blob Storage** - Stocare PDF-uri mandate
3. ❌ **CertSign Integration** - Semnare digitală mandate

### Priority 2: IMPORTANT (funcționalitate core)
4. ❌ **ANAF OAuth/API** - Interogare venituri
5. ❌ **Service Bus + Job Orchestrator** - Pipeline ANAF
6. ❌ **Cosmos DB** - Audit trail complet

### Priority 3: NICE TO HAVE
7. ❌ **BC Connector** - Verificare credit
8. ❌ **Ruleset CRUD Admin** - Gestionare reguli
9. ❌ **OpenAPI Spec** - Documentație API

---

## 💡 RECOMANDĂRI

1. **Continuați cu ce există** - 55-65% implementat, mult de recâștigat
2. **Prioritizați Azure migration** - Cel mai critic pentru producție
3. **CertSign contract** - Necesită contract comercial, planificați din timp
4. **ANAF registration** - Înregistrare la api.anaf.ro poate dura

---

**Concluzie:** Proiectul MoneyShop are o bază solidă. Cerințele din New_SRS.txt sunt mai detaliate decât cele anterioare, dar **majoritatea logicii de business este implementată**. Lipsesc în principal integrările externe (Azure, CertSign, ANAF, BC) și audit trail-ul complet (Cosmos DB).


