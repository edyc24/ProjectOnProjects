# Prezentare Proiect - MoneyShop
## Baza de Date Oracle & Aplicație Web

---

## 📋 Introducere

**MoneyShop** este o platformă completă de intermediere creditare care conectează clienții cu băncile partenere, oferind servicii de brokeraj, calcul de eligibilitate și gestionare completă a procesului de creditare. Proiectul include o aplicație web modernă (.NET Core) și o bază de date Oracle robustă, implementând cele mai bune practici de securitate și conformitate GDPR.

---

## 🗄️ Baza de Date Oracle

### Arhitectură și Tehnologie

Baza de date este implementată pe **Oracle Database 19c+** folosind arhitectura **Multitenant (CDB/PDB)**, oferind:

- **Container Database (CDB)**: Gestionare centralizată a multiple pluggable databases
- **Pluggable Database (PDB)**: Izolare completă a datelor aplicației
- **Scalabilitate**: Suport pentru creștere viitoare și multiple medii (dev, test, prod)

### Structură de Date

Baza de date conține **15+ tabele principale** organizate logic:

#### Entități de Bază
- **ROLURI**: Definirea rolurilor sistemului (CLIENT, BROKER, ADMIN)
- **UTILIZATORI**: Gestionare utilizatori cu autentificare și verificare
- **BANCI**: Băncile partenere cu comisioane și configurații

#### Procese de Business
- **APLICATII**: Cereri de credit cu scoring, DTI, și status tracking
- **APPLICATION_BANKS**: Relații many-to-many între aplicații și bănci
- **DOCUMENTE**: Gestionare documente încărcate de clienți
- **LEADURI**: Capturarea și gestionarea lead-urilor

#### Conformitate și Legal
- **CONSENTURI**: Gestionare consimțământuri GDPR
- **MANDATE**: Mandate de brokeraj între clienți și brokeri
- **LEGAL_DOCS**: Documente legale (termeni, privacy policy)

#### Securitate și Audit
- **AUDIT_LOG**: Log complet al tuturor operațiunilor
- **USER_SESSIONS**: Gestionare sesiuni utilizatori
- **SUBJECT_MAP**: Pseudonimizare CNP pentru conformitate GDPR

#### Funcționalități Avansate
- **KYC_SESSIONS & KYC_FILES**: Procese KYC (Know Your Customer)
- **BROKER_DIRECTORY**: Director brokeri cu upload Excel
- **USER_FINANCIAL_DATA**: Date financiare utilizatori pentru simulator

---

## 🔒 Securitate - 7 Cerințe Implementate

### 1. Criptare Date (Data Encryption)

**Implementare:**
- **TDE (Transparent Data Encryption)**: Criptare automată la nivel de tabelă
- **Column-level Encryption**: Criptare AES-256 pentru date sensibile
  - Email-uri criptate în coloana `Email_Encrypted`
  - CNP-uri criptate în coloana `CNP_Encrypted`
- **Funcții de criptare/decriptare**: `fn_encrypt_column()` și `fn_decrypt_column()`

**Beneficii:**
- Protecție datelor la rest
- Conformitate cu GDPR și reglementări financiare
- Date sensibile inaccesibile chiar și pentru DBA

### 2. Auditare (Auditing)

**Implementare:**
- **Standard Oracle Auditing**: Auditare nativă Oracle
- **Trigger-based Auditing**: Trigger-uri AFTER pe tabele critice
  - `trg_audit_utilizatori`: Auditare modificări utilizatori
  - `trg_audit_aplicatii`: Auditare modificări aplicații
  - `trg_audit_documente`: Auditare modificări documente
  - `trg_audit_consenturi`: Auditare modificări consimțământuri
- **Fine-Grained Audit (FGA)**: Politici FGA pentru acces la date sensibile
- **Tabela AUDIT_LOG**: Log centralizat cu JSON pentru old/new values

**Beneficii:**
- Traciere completă a tuturor modificărilor
- Conformitate cu cerințele de audit financiar
- Detectare rapidă a activităților suspecte

### 3. Gestiune Utilizatori și Resurse

**Implementare:**
- **Matrici Proces-Utilizator**: Tabele `PROCESE`, `PROCES_UTILIZATOR`
- **Matrici Entitate-Proces**: Tabela `ENTITATE_PROCES`
- **Matrici Entitate-Utilizator**: Tabela `ENTITATE_UTILIZATOR`
- **Funcții de verificare**: 
  - `fn_utilizator_poate_proces()`: Verifică dacă utilizatorul poate executa un proces
  - `fn_utilizator_poate_entitate()`: Verifică accesul la entități
- **Proceduri stocate**: `sp_asignare_proces_utilizator()`, `sp_revocare_proces_utilizator()`

**Beneficii:**
- Control granular al accesului
- Principiul privilegiilor minime
- Gestionare flexibilă a permisiunilor

### 4. Privilegii și Roluri

**Implementare:**
- **Roluri Oracle ierarhice**:
  - `moneyshop_client_role`: Privilegii pentru clienți
  - `moneyshop_broker_role`: Privilegii pentru brokeri (moștenește CLIENT)
  - `moneyshop_admin_role`: Privilegii pentru admini (moștenește BROKER și CLIENT)
  - `moneyshop_readonly_role`: Rol pentru citire doar
- **View-uri cu privilegii restricționate**:
  - `vw_client_own_applications`: Clienții văd doar propriile aplicații
  - `vw_broker_all_applications`: Brokerii văd toate aplicațiile active
- **Proceduri stocate cu AUTHID DEFINER**: Execuție cu privilegiile creatorului

**Beneficii:**
- Separare clară a responsabilităților
- Securitate prin design
- Ușor de gestionat și extins

### 5. Prevenire SQL Injection

**Implementare:**
- **Parametrized Queries**: Toate interogările folosesc parametri
- **Stored Procedures**: Logica de business în proceduri stocate
  - `sp_autentificare_utilizator()`: Autentificare sigură
  - `sp_schimbare_parola()`: Schimbare parolă sigură
- **Input Validation**: Trigger-uri BEFORE cu validare regex
  - Validare format email: `REGEXP_LIKE(Email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$')`
  - Validare format telefon: `REGEXP_LIKE(NumarTelefon, '^[0-9]{10}$')`
- **Constraints**: Constrainte CHECK pentru validare la nivel de bază de date

**Beneficii:**
- Protecție completă împotriva SQL injection
- Validare la multiple niveluri
- Securitate la nivel de aplicație și bază de date

### 6. Mascare Date (Data Masking)

**Implementare:**
- **Funcții de mascare**:
  - `fn_mask_email()`: Mascare email (ex: `t***@example.com`)
  - `fn_mask_telefon()`: Mascare telefon (ex: `071***78`)
  - `fn_mask_cnp()`: Mascare CNP (ex: `12***23`)
  - `fn_mask_nume()`: Mascare nume (ex: `P***u`)
- **View-uri cu date mascate**:
  - `vw_utilizatori_masked`: Utilizatori cu date mascate
  - `vw_aplicatii_masked`: Aplicații cu salariu rotunjit
  - `vw_broker_clients_masked`: Clienți mascați pentru brokeri

**Beneficii:**
- Protecție datelor sensibile în rapoarte
- Conformitate GDPR pentru acces la date
- Utilizare sigură în medii de testare

### 7. Securitate la Nivel de Aplicație

**Implementare:**
- **Constraints de validare**:
  - Vârstă minimă 18 ani
  - Scoring între 300-850
  - DTI între 0-100%
  - Statusuri valide pentru aplicații
- **Trigger-uri de validare**: Validare înainte de INSERT/UPDATE
- **Parole hash-uite**: SHA-256 pentru toate parolele
- **Verificare email/telefon**: Flag-uri `EmailVerified` și `PhoneVerified`

**Beneficii:**
- Integritate datelor garantată
- Validare consistentă
- Securitate multi-nivel

---

## 💻 Aplicația Web - MoneyShop

### Tehnologii

- **Backend**: .NET Core 6.0 (C#)
- **Frontend**: React Native (mobile)
- **Baza de Date**: Oracle Database 19c+ (Entity Framework Core)
- **Autentificare**: JWT (JSON Web Tokens)
- **API**: RESTful API cu Swagger documentation

### Funcționalități Principale

#### 1. Autentificare și Autorizare
- **Login tradițional**: Email/username + parolă
- **OTP Login**: Autentificare prin SMS cu cod OTP
- **JWT Tokens**: Sesiuni securizate cu expirare
- **Role-based Access Control**: Acces bazat pe roluri (CLIENT, BROKER, ADMIN)

#### 2. Gestionare Aplicații Credit
- **Creare aplicație**: Formular complet cu validări
- **Tracking status**: INREGISTRAT → IN_PROCESARE → APROBAT/RESPINS
- **Scoring automat**: Calcul scoring bazat pe date financiare
- **Recomandări**: Nivel recomandat (RIDICAT, MEDIU, SCAZUT)

#### 3. Simulator Credit
- **Calcul eligibilitate**: Simulator interactiv
- **Acces public**: Disponibil fără autentificare
- **Salvare date**: Pentru utilizatori autentificați
- **Rezultate detaliate**: DTI, scoring, recomandări

#### 4. Gestionare Documente
- **Upload documente**: CI, fluturași salar, extras cont
- **Validare documente**: Procesare de către brokeri
- **Stocare securizată**: Azure Blob Storage
- **PDF Generation**: Generare mandate PDF cu hash SHA-256

#### 5. Conformitate GDPR
- **Consent Management**: Gestionare consimțământuri
- **Mandate Brokeraj**: Creare și revocare mandate
- **Pseudonimizare CNP**: Hash HMAC-SHA256 pentru CNP
- **Subject ID**: Generare ID-uri unice (MS- + BASE32)

#### 6. KYC (Know Your Customer)
- **Sesiuni KYC**: Procese de verificare identitate
- **Upload fișiere**: Documente KYC
- **Lifecycle Management**: Ștergere automată după 30 zile

#### 7. Broker Directory
- **Upload Excel**: Import brokeri din fișier Excel
- **Căutare brokeri**: Funcționalitate de search
- **Parsing automat**: Extragere date din Excel cu EPPlus

#### 8. Dashboard
- **Vizualizare aplicații**: Lista aplicațiilor active
- **Date financiare**: Box-uri cu venit, rate, etc.
- **Statistici**: Overview rapid al activității

---

## 📊 Caracteristici Tehnice

### Performanță
- **Indexuri optimizate**: Indexuri pe coloane frecvent interogate
- **View-uri materializate**: Pentru rapoarte complexe
- **Connection pooling**: Gestionare eficientă a conexiunilor
- **Caching**: Cache pentru date statice

### Scalabilitate
- **Arhitectură modulară**: Separare clară între layere
- **Repository Pattern**: Abstrahție pentru acces la date
- **Unit of Work**: Gestionare tranzacții
- **Dependency Injection**: IoC container pentru testare

### Monitorizare
- **Application Insights**: Telemetrie și logging
- **Audit Log**: Tracking complet al activităților
- **Error Handling**: Gestionare centralizată a erorilor
- **Health Checks**: Verificare status sistem

---

## 🎯 Rezultate și Beneficii

### Securitate
✅ **7 cerințe de securitate** implementate complet  
✅ **Criptare** pentru date sensibile  
✅ **Auditare** completă a activităților  
✅ **Mascare date** pentru rapoarte  
✅ **Prevenire SQL injection** la toate nivelurile  

### Conformitate
✅ **GDPR compliant**: Pseudonimizare, consent management  
✅ **Audit trail**: Log complet pentru verificări  
✅ **Data retention**: Politici clare de păstrare date  

### Funcționalitate
✅ **Platformă completă**: De la aplicație la aprobare  
✅ **User-friendly**: Interfață intuitivă  
✅ **Mobile-first**: Aplicație React Native  
✅ **API-first**: Arhitectură RESTful  

---

## 📈 Statistici Proiect

- **15+ tabele** principale în baza de date
- **20+ proceduri stocate** pentru logica de business
- **10+ funcții** pentru validare și procesare
- **5+ view-uri** pentru rapoarte și mascare date
- **7 cerințe de securitate** implementate complet
- **100% conformitate** cu GDPR și standardele financiare

---

## 🔮 Viitor și Extensibilitate

### Planuri de Dezvoltare
- **Machine Learning**: Predicție scoring mai precisă
- **Blockchain**: Audit trail imuabil
- **Microservices**: Migrare către arhitectură microservices
- **Real-time notifications**: Notificări push pentru status aplicații

### Scalabilitate
- **Horizontal scaling**: Suport pentru multiple instanțe
- **Database sharding**: Distribuire date pe multiple servere
- **CDN integration**: Optimizare pentru utilizatori globali

---

## 📝 Concluzie

**MoneyShop** reprezintă o soluție completă, securizată și conformă pentru intermedierea creditelor, combinând tehnologii moderne (.NET Core, React Native, Oracle Database) cu cele mai bune practici de securitate și conformitate. Baza de date Oracle implementează un sistem robust de securitate cu 7 cerințe complete, iar aplicația oferă o experiență utilizator excelentă cu funcționalități complete de la aplicare la aprobare credit.

Proiectul demonstrează:
- ✅ **Expertiză tehnică**: Implementare profesională a tehnologiilor moderne
- ✅ **Securitate**: 7 cerințe de securitate implementate complet
- ✅ **Conformitate**: GDPR și standarde financiare
- ✅ **Calitate cod**: Arhitectură curată, testabilă, extensibilă

---

**Proiect realizat de:** Cristea Eduard  
**Tehnologii:** Oracle Database 19c+, .NET Core 6.0, React Native  
**An:** 2024-2025

