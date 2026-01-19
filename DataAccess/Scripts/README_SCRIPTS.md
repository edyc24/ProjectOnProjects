# Scripturi SQL pentru MoneyShop

Acest document descrie toate scripturile SQL disponibile și ordinea în care trebuie rulate.

## Scripturi de Verificare

### VerifyAllTables.sql ⭐ RECOMANDAT
**Verifică existența TUTUROR tabelelor din aplicație**

Rulează acest script pentru a vedea ce tabele lipsesc:
```sql
-- Rulează: DataAccess/Scripts/VerifyAllTables.sql
```

Acest script verifică **30 de tabele**:
- Tabele de bază (legacy): BacDocuments, Proiectes, Roluri, SavedProjects, Utilizatori, Favorites
- MoneyShop Core: Applications, Documents, Banks, ApplicationBanks, Agreements, Leads
- OTP & Session: OtpChallenges, Sessions
- Consent & Mandate: LegalDocs, Consents, Mandates
- Subject Map: SubjectMaps
- KYC: KycSessions, KycFiles
- Broker Directory: BrokerDirectories
- User Financial Data: UserFinancialData
- Eligibility: RatesRulesConfigs, AnafReports, BcReports
- Chat: ChatRateLimits, ChatUsages, FaqItems
- Lead Capture: LeadCaptures, LeadSessions

### VerifyChatTables.sql
**Verifică doar tabelele pentru Chat Asistent Virtual**

Rulează dacă vrei să verifici doar tabelele de chat:
```sql
-- Rulează: DataAccess/Scripts/VerifyChatTables.sql
```

## Scripturi de Creare Tabele

### Complete_Database_Setup_Azure.sql ⭐ PRINCIPAL
**Script complet pentru toate tabelele de bază**

Acest script creează majoritatea tabelelor necesare pentru aplicație:
- Tabele de bază (Utilizatori, Roluri, etc.)
- MoneyShop Core (Applications, Documents, Banks, etc.)
- OTP & Session
- Consent & Mandate
- Subject Map
- KYC
- Broker Directory
- User Financial Data
- Eligibility

**IMPORTANT:** Rulează acest script PRIMUL pentru tabelele de bază.

### CreateChatTables.sql
**Creează tabelele pentru Chat Asistent Virtual**

Creează:
- `ChatRateLimits` - pentru rate limiting
- `ChatUsages` - pentru cost control

**Rulează după:** Complete_Database_Setup_Azure.sql

### CreateFaqTable.sql
**Creează tabela pentru FAQ Cache**

Creează:
- `FaqItems` - pentru cache-ul de întrebări frecvente

**Rulează după:** Complete_Database_Setup_Azure.sql

### CreateLeadTables.sql
**Creează tabelele pentru Lead Capture**

Creează:
- `LeadCaptures` - pentru lead-uri capturate
- `LeadSessions` - pentru state machine de lead capture

**Rulează după:** Complete_Database_Setup_Azure.sql

### CreateEligibilityTables.sql
**Creează tabelele pentru Eligibility (Eligibilitate Credit)**

Creează:
- `RatesRulesConfigs` - configurație rates & rules (JSON)
- `AnafReports` - rapoarte ANAF (venituri)
- `BcReports` - rapoarte Birou Credit (scor FICO, obligații)

**Rulează după:** Complete_Database_Setup_Azure.sql

## Scripturi de Populare Date

### SeedFaqItems.sql
**Populează tabela FaqItems cu întrebări frecvente**

Adaugă 15 FAQ-uri predefinite pentru chat.

**Rulează după:** CreateFaqTable.sql

## Ordine Recomandată de Rulare

### Pentru setup complet (prima dată):

1. **Complete_Database_Setup_Azure.sql** - Creează toate tabelele de bază
2. **CreateEligibilityTables.sql** - Creează tabelele pentru eligibilitate (RatesRulesConfigs, AnafReports, BcReports)
3. **CreateChatTables.sql** - Creează tabelele de chat
4. **CreateFaqTable.sql** - Creează tabela FAQ
5. **CreateLeadTables.sql** - Creează tabelele de lead capture
6. **SeedFaqItems.sql** - Populează FAQ-urile

### Pentru verificare:

1. **VerifyAllTables.sql** - Verifică toate tabelele și arată ce lipsește

## Note Importante

- Toate scripturile sunt **idempotente** - pot fi rulate de mai multe ori fără erori
- Scripturile folosesc `IF NOT EXISTS` pentru a evita erorile dacă tabelele există deja
- După rularea scripturilor, rulează **VerifyAllTables.sql** pentru a confirma că totul este în regulă

## Alternative: Entity Framework Migrations

În loc de scripturi SQL, poți folosi migrații Entity Framework Core:

```bash
# Creează o migrație pentru toate schimbările
dotnet ef migrations add AddAllTables

# Aplică migrațiile în baza de date
dotnet ef database update
```

**Avantaje:**
- Automatizează crearea tabelelor
- Păstrează istoricul schimbărilor
- Mai ușor de gestionat în timp

**Dezavantaje:**
- Trebuie să ai .NET SDK instalat
- Trebuie să configurezi connection string corect

