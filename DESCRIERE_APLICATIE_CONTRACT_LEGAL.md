# DESCRIERE DETALIATĂ A APLICAȚIEI MONEYSHOP
## Document pentru Contract Legal

---

## 1. PREZENTARE GENERALĂ

**MoneyShop** este o platformă digitală complexă de intermediere financiară care oferă utilizatorilor servicii de evaluare a eligibilității pentru credite, simulare de credite, gestionare de aplicații, consultanță virtuală și facilitare a procesului de obținere a creditelor prin intermedierea brokerilor autorizați.

Aplicația este dezvoltată ca o soluție full-stack, constând din:
- **Backend**: ASP.NET Core Web API (C#)
- **Frontend Web**: Interfață web responsive
- **Aplicație Mobile**: React Native (iOS și Android)
- **Bază de Date**: Azure SQL Database
- **Storage**: Azure Blob Storage
- **Infrastructură Cloud**: Microsoft Azure

---

## 2. FUNCȚIONALITĂȚI PRINCIPALE

### 2.1. Sistem de Autentificare și Securitate

#### 2.1.1. Autentificare Multi-Factor (OTP)
- **Autentificare prin SMS**: Sistem OTP (One-Time Password) pentru login și verificare telefon
- **Autentificare prin Email**: Verificare adresă de email prin coduri OTP
- **Rate Limiting**: Protecție împotriva atacurilor brute-force (max 5 încercări, blocare 30 minute)
- **Step-up Security**: Verificare suplimentară pentru IP-uri sau dispozitive noi
- **Expirare Coduri**: 
  - 5 minute pentru login
  - 3 minute pentru semnare documente
  - 10 minute pentru verificare email/telefon

#### 2.1.2. Gestionare Sesiuni
- JWT (JSON Web Tokens) pentru autentificare stateless
- Tracking sesiuni utilizator cu hash dispozitiv
- Audit trail complet pentru toate acțiunile utilizatorului

#### 2.1.3. Protecție Date Personale
- **Pseudonimizare CNP**: CNP-ul nu este stocat în clar, ci ca hash HMAC-SHA256
- **Subject ID Stabil**: Identificator unic generat pe baza CNP-ului, stabil 5 ani
- **Mascare Date**: CNP și telefon afișate parțial în interfață (ex: ******5579)
- **Pepper Keys**: Chei de criptare stocate în Azure Key Vault cu rotație anuală

---

### 2.2. Verificare Identitate (KYC - Know Your Customer)

#### 2.2.1. Proces KYC
- **Încărcare Documente**: 
  - Carte de identitate (față și verso)
  - Selfie pentru verificare facială
  - Alte documente necesare pentru verificare
- **Validare Documente**: Verificare automată și manuală
- **Retenție Date**: 
  - Imagini/documente: 30 zile (șterse automat)
  - Metadate KYC (fără imagini): 5 ani pentru audit

#### 2.2.2. Conformitate GDPR
- Ștergere automată a documentelor KYC după 30 zile
- Păstrare doar a metadatelor necesare pentru audit
- Consimțământ explicit pentru procesarea datelor

---

### 2.3. Sistem de Consimțământ și Mandate

#### 2.3.1. Consimțământ Dual
Aplicația implementează un sistem de consimțământ separat pentru:
1. **Mandat BC** (obligatoriu pentru interogare)
   - Consimțământ pentru interogarea Biroului de Credit
2. **Acceptare Costuri** (obligatoriu)
   - Informare despre costurile serviciilor
   - Acceptare explicită a costurilor
3. **Transmitere către Broker** (opțional)
   - Consimțământ explicit pentru partajarea datelor cu brokeri autorizați
   - Implicit dezactivat, necesită acțiune explicită a utilizatorului

#### 2.3.2. Gestionare Mandate
- **Creare Mandate**: Generare automată de mandate pentru Biroul de Credit
- **Valabilitate**: Mandate active pentru 30 de zile
- **Revocare**: Posibilitate de revocare a mandatelor în orice moment
- **Tracking**: Audit trail complet pentru toate mandatelor

#### 2.3.3. Documente Legale
- **Generare PDF Automată**: Mandate generate automat cu toate detaliile necesare
- **Hash și Timestamp**: Fiecare document include hash SHA-256 și timestamp pentru integritate
- **Stocare Securizată**: Documente stocate în Azure Blob Storage cu acces controlat

---

### 2.4. Evaluare Eligibilitate Credit

#### 2.4.1. Motor de Reguli Configurabil
- **Reguli de Eligibilitate**: Motor de reguli versionat și configurabil
- **Parametri Evaluare**:
  - Grad de îndatorare (DTI - Debt-to-Income)
  - Venit net lunar
  - Credite active și sold total
  - Istoric plăți (întârzieri, popriri)
  - Verificare Birou de Credit
- **Praguri Configurabile**: Praguri minime și maxime configurabile pentru fiecare criteriu

#### 2.4.2. Calculatoare Financiare
- **Calculator Grad Îndatorare**: Calcul automat DTI
- **Calculator Rata Lunara**: Estimare rate lunare pentru diferite sume și perioade
- **Simulator Credit**: Simulare completă cu toate costurile
- **Mod Guest**: Utilizare fără cont pentru calcule rapide
- **Mod Account**: Calcule persistate pentru utilizatori înregistrați

#### 2.4.3. Integrare Birou de Credit
- **Interogare BC**: Verificare istoric credit prin API Birou de Credit
- **Rapoarte**: Generare rapoarte de eligibilitate bazate pe date BC

---

### 2.5. Gestionare Aplicații Credit

#### 2.5.1. Creare și Gestionare Aplicații
- **Formulare Aplicații**: Formulare complete pentru aplicații de credit
- **Tracking Status**: Urmărire status aplicații (în așteptare, în procesare, aprobată, respinsă)
- **Documente Atașate**: Posibilitate de atașare documente necesare
- **Notificări**: Notificări pentru actualizări de status

#### 2.5.2. Asociere Bănci
- **Listă Bănci**: Director de bănci disponibile
- **Aplicații Multi-Bancă**: Posibilitate de aplicare la multiple bănci
- **Tracking Aplicații**: Urmărire aplicații separate pentru fiecare bancă

---

### 2.6. Asistent Virtual (Chatbot)

#### 2.6.1. Chatbot Educațional
- **Tehnologie**: Integrare OpenAI (GPT-3.5-turbo și GPT-4o-mini)
- **Funcționalități**:
  - Răspunsuri la întrebări despre credite
  - Explicații despre eligibilitate
  - Ghidare prin procesul de aplicare
  - Informații educaționale despre produse financiare

#### 2.6.2. Protecții Conformitate
- **Filtru Nume Bănci**: Detectare și înlocuire automată a numelor de bănci
- **Topic Guard**: Blocare cereri cu date sensibile (CNP, CI, card, OTP)
- **Refuz Recomandări**: Botul nu recomandă bănci specifice
- **Disclaimer Legal**: Toate răspunsurile includ disclaimer de conformitate

#### 2.6.3. Optimizare Costuri
- **FAQ Cache**: Sistem de cache pentru întrebări frecvente (reducere costuri 30-50%)
- **Rate Limiting**: 20 cereri/minut, 200 cereri/zi per utilizator
- **Cost Control**: Buget lunar configurabil (default 150 USD)
- **Fallback Logic**: Folosire model mai ieftin când este posibil

---

### 2.7. Capturare Lead-uri

#### 2.7.1. Formulare Lead
- **Capturare Directă**: Formular complet pentru capturare lead-uri
- **Conversație Pas cu Pas**: State machine cu 8 pași pentru colectare progresivă
- **Validare Date**: Validare completă a datelor introduse
- **Sesiuni Persistente**: Sesiuni salvate în baza de date (TTL 7 zile)

#### 2.7.2. Calificare Lead-uri
- **Date Colectate**:
  - Nume și prenume
  - Telefon și email
  - Oraș
  - Credite active și sold total
  - Tip creditor (BANCA/IFN/LEASING)
  - Istoric întârzieri
  - Venit net lunar
  - Istoric popriri/executori
- **Scoring**: Evaluare automată a calității lead-ului

---

### 2.8. Director Brokeri

#### 2.8.1. Listă Brokeri Autorizați
- **Integrare ANPC**: Listă brokeri autorizați de Autoritatea Națională pentru Protecția Consumatorilor
- **Verificare KYC Broker**: Verificare status autorizație pentru fiecare broker
- **Informații Broker**: Detalii despre brokeri (nume, contact, autorizații)

#### 2.8.2. Partajare Date cu Brokeri
- **Consimțământ Explicit**: Partajare doar cu consimțământ explicit al utilizatorului
- **Tracking**: Audit trail pentru toate partajările de date
- **Securitate**: Transmitere securizată a datelor către brokeri

---

### 2.9. Generare Documente

#### 2.9.1. Generare PDF
- **Mandate**: Generare automată PDF pentru mandate BC
- **Rapoarte**: Generare rapoarte de eligibilitate
- **Documente Aplicație**: Generare documente pentru aplicații
- **Template-uri**: Template-uri configurabile pentru toate documentele

---

### 2.10. Integrare Oblio (Facturare)

#### 2.10.1. Generare Facturi
- **Facturi**: Generare facturi pentru servicii
- **Proforme**: Generare proforme
- **Avize**: Generare avize
- **Integrare API**: Conectare la API Oblio pentru facturare automată

#### 2.10.2. Gestionare Documente Fiscale
- **Nomenclatoare**: Gestionare clienți, produse, cote TVA
- **Descărcare PDF**: Descărcare facturi în format PDF
- **Anulare/Restaurare**: Gestionare documente fiscale

---

### 2.11. Gestionare Utilizatori

#### 2.11.1. Conturi Utilizatori
- **Profil Utilizator**: Gestionare profil complet
- **Adrese**: Gestionare adrese multiple
- **Date Financiare**: Stocare date financiare utilizator
- **Istoric**: Istoric complet al activităților utilizatorului

#### 2.11.2. Favorite
- **Listă Favorite**: Salvare bănci și produse favorite
- **Proiecte Salvate**: Salvare simulări și calcule

---

### 2.12. Raportare și Analytics

#### 2.12.1. Telemetrie
- **Tracking Evenimente**: Urmărire evenimente utilizator
- **Analytics**: Analiză comportament utilizatori
- **Rapoarte**: Generare rapoarte pentru management

#### 2.12.2. Audit Trail
- **Logging Complet**: Toate acțiunile sunt logate
- **Event Stream**: Evenimente stocate în Azure Cosmos DB
- **Hash Chain**: Verificare integritate prin hash chain
- **Retenție**: Păstrare evenimente pentru audit (5 ani)

---

## 3. ARHITECTURĂ TEHNICĂ

### 3.1. Componente Backend

#### 3.1.1. Servicii Business Logic
- **AccountService**: Gestionare conturi utilizatori
- **AuthService/OtpService**: Autentificare și OTP
- **KycService**: Verificare identitate
- **ConsentService**: Gestionare consimțământ
- **MandateService**: Gestionare mandate
- **EligibilityConfigService**: Configurare reguli eligibilitate
- **SimpleEligibilityEngine**: Motor evaluare eligibilitate
- **ApplicationService**: Gestionare aplicații
- **BankService**: Gestionare bănci
- **BrokerDirectoryService**: Director brokeri
- **LeadService/LeadCaptureService**: Capturare lead-uri
- **ChatService**: Asistent virtual
- **DocumentService**: Generare documente
- **OblioApiService**: Integrare facturare
- **ScoringService**: Calcul scoring

#### 3.1.2. Servicii Securitate
- **EmailService**: Trimitere email (Brevo)
- **SmsService**: Trimitere SMS (Brevo)
- **JwtService**: Generare și validare JWT tokens
- **SubjectService**: Pseudonimizare și gestionare Subject ID

### 3.2. Baza de Date

#### 3.2.1. Tabele Principale
- **Utilizatori**: Date utilizatori
- **Consent**: Consimțământuri utilizatori
- **Mandate**: Mandate BC
- **OtpChallenge**: Provocări OTP
- **KycSession/KycFile**: Date KYC
- **Application**: Aplicații credit
- **ApplicationBank**: Asociere aplicații-bănci
- **Bank**: Director bănci
- **BrokerDirectory**: Director brokeri
- **Lead/LeadCapture/LeadSession**: Lead-uri
- **Document**: Documente generate
- **Agreement**: Acorduri
- **BcReport**: Rapoarte BC
- **SubjectMap**: Mapare CNP hash la Subject ID
- **UserFinancialData**: Date financiare utilizatori
- **ChatRateLimit/ChatUsage**: Rate limiting și costuri chat
- **FaqItem**: FAQ-uri pentru cache

#### 3.2.2. Storage
- **Azure Blob Storage**: 
  - Documente PDF (mandate, rapoarte)
  - Imagini KYC (TTL 30 zile)
  - Documente semnate
  - Rapoarte BC

### 3.3. Integrări Externe

#### 3.3.1. Servicii Cloud
- **Brevo (Sendinblue)**: Email și SMS
- **OpenAI**: Chatbot AI
- **Oblio**: Facturare
- **Birou de Credit API**: Interogare istoric credit (planificat)

#### 3.3.2. Azure Services
- **Azure SQL Database**: Baza de date principală
- **Azure Cosmos DB**: Event stream și audit trail
- **Azure Blob Storage**: Storage documente
- **Azure Key Vault**: Gestionare chei și secrete
- **Azure Service Bus**: Queue pentru job-uri asincrone
- **Azure Functions**: Funcții serverless (cron jobs)
- **Azure Monitor**: Monitoring și logging
- **Application Insights**: Telemetrie aplicație

---

## 4. CONFORMITATE ȘI SECURITATE

### 4.1. Conformitate GDPR

#### 4.1.1. Principii GDPR
- **Minimizare Date**: Colectare doar date necesare
- **Limitare Scop**: Date folosite doar pentru scopuri declarate
- **Retenție Limită**: Ștergere automată după perioada necesară
- **Pseudonimizare**: CNP și date sensibile pseudonimizate
- **Consimțământ Explicit**: Consimțământ clar și separabil pentru fiecare scop

#### 4.1.2. Drepturi Utilizator
- **Acces Date**: Utilizatorul poate accesa datele sale
- **Rectificare**: Posibilitate corectare date
- **Ștergere**: Posibilitate ștergere cont și date
- **Portabilitate**: Export date în format structurat
- **Opoziție**: Posibilitate opoziție procesare

### 4.2. Securitate Date

#### 4.2.1. Măsuri Tehnice
- **Criptare în Tranzit**: HTTPS pentru toate comunicările
- **Criptare la Repaus**: Date sensibile criptate în baza de date
- **Hash Passwords**: Parole hash-uite cu algoritmi securi
- **OTP Securizat**: Coduri OTP hash-uite, nu stocate în clar
- **Rate Limiting**: Protecție împotriva atacurilor brute-force

#### 4.2.2. Măsuri Organizaționale
- **Acces Controlat**: Acces la date doar pentru personal autorizat
- **Audit Logging**: Toate accesările la date sunt logate
- **Training Personal**: Personal instruit despre protecția datelor
- **Incident Response**: Plan de răspuns la incidente de securitate

### 4.3. Conformitate Reglementări Financiare

#### 4.3.1. Reglementări Aplicabile
- **GDPR**: Regulamentul General privind Protecția Datelor
- **ANPC**: Autoritatea Națională pentru Protecția Consumatorilor
- **ASF**: Autoritatea de Supraveghere Financiară (pentru brokeri)

#### 4.3.2. Documente Legale
- **Termeni și Condiții**: Termeni de utilizare aplicație
- **Politică Confidențialitate**: Politică GDPR completă
- **Politică Mandatare**: Informații despre mandate
- **Politică Transmitere Date**: Politică pentru partajare cu brokeri
- **Declarație Consimțământ**: Declarații de consimțământ pentru fiecare scop

---

## 5. FUNCȚIONALITĂȚI MOBILE

### 5.1. Aplicație React Native

#### 5.1.1. Platforme
- **iOS**: Aplicație nativă pentru iPhone și iPad
- **Android**: Aplicație nativă pentru dispozitive Android
- **Web**: Versiune web responsive

#### 5.1.2. Funcționalități Mobile
- Toate funcționalitățile web disponibile în aplicație mobile
- Notificări push pentru actualizări
- Offline mode pentru anumite funcționalități
- Sincronizare automată când conexiunea este restabilită

---

## 6. SCALABILITATE ȘI PERFORMANȚĂ

### 6.1. Arhitectură Scalabilă
- **Microservicii**: Arhitectură modulară pentru scalare independentă
- **Load Balancing**: Distribuire sarcină pentru performanță optimă
- **Caching**: Cache pentru date frecvent accesate
- **CDN**: Content Delivery Network pentru asset-uri statice

### 6.2. Monitoring și Observabilitate
- **Application Insights**: Telemetrie detaliată
- **Log Analytics**: Analiză log-uri centralizată
- **Alerting**: Alerte automate pentru probleme
- **Performance Metrics**: Metrici de performanță în timp real

---

## 7. SUSTENABILITATE ȘI MENTENANȚĂ

### 7.1. Versionare
- **API Versioning**: Versionare API pentru compatibilitate
- **Database Migrations**: Migrări baza de date versionate
- **Code Versioning**: Git pentru versionare cod

### 7.2. Testing
- **Unit Tests**: Teste unitare pentru logica de business
- **Integration Tests**: Teste de integrare pentru API-uri
- **End-to-End Tests**: Teste complete pentru fluxuri utilizator

### 7.3. Documentație
- **API Documentation**: Swagger/OpenAPI pentru documentație API
- **Code Documentation**: Comentarii și documentație în cod
- **User Guides**: Ghiduri utilizator pentru fiecare funcționalitate

---

## 8. ROADMAP ȘI DEZVOLTĂRI VIITOARE

### 8.1. Funcționalități Planificate
- **Integrare Birou de Credit**: Interogare automată istoric credit
- **Notificări Push**: Notificări în timp real pentru utilizatori
- **Multi-Language**: Suport pentru mai multe limbi
- **Advanced Analytics**: Dashboard-uri avansate pentru utilizatori

### 8.2. Îmbunătățiri Tehnice
- **Performance Optimization**: Optimizări pentru performanță
- **Security Enhancements**: Îmbunătățiri securitate
- **UI/UX Improvements**: Îmbunătățiri interfață utilizator

---

## 9. CONCLUZII

Aplicația **MoneyShop** este o platformă complexă și completă de intermediere financiară care oferă utilizatorilor un set complet de servicii pentru evaluarea eligibilității credit, gestionarea aplicațiilor și obținerea de consultanță financiară. 

Aplicația respectă toate reglementările aplicabile (GDPR, ANPC, ASF) și implementează măsuri de securitate avansate pentru protecția datelor utilizatorilor. Arhitectura aplicației este scalabilă, modulară și pregătită pentru dezvoltări viitoare.

Toate funcționalitățile sunt documentate, testate și pregătite pentru utilizare în producție, cu suport complet pentru platformele web, iOS și Android.

---

**Data documentului**: 2026-01-15  
**Versiune**: 1.0  
**Status**: Final

