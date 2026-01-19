# Asistent Virtual MoneyShop - Documentație

## Prezentare Generală

Asistentul Virtual MoneyShop este un chatbot integrat care oferă informații educaționale despre credite, eligibilitate și procesul de aplicare. Este construit folosind OpenAI API cu fallback automat și include protecții pentru conformitate și costuri.

## Configurare

### 1. Obținere OpenAI API Key

1. Accesează https://platform.openai.com
2. Creează un cont sau autentifică-te
3. Mergi la **API Keys** și generează o cheie nouă
4. Copiază cheia (începe cu `sk-...`)

### 2. Configurare Backend

Editează `MoneyShop/appsettings.json` și adaugă:

```json
{
  "OpenAI": {
    "ApiKey": "sk-tokenul-tau-openai",
    "ModelPrimary": "gpt-3.5-turbo",
    "ModelFallback": "gpt-4o-mini",
    "MaxOutputTokens": 350,
    "BudgetUsdMonth": 150,
    "SystemPrompt": "Esti Asistentul Virtual MoneyShop..."
  },
  "Chat": {
    "RateLimitPerMinute": 20,
    "RateLimitPerDay": 200,
    "FaqCacheEnabled": true
  }
}
```

### 3. Creare Tabele în Baza de Date

Rulează următoarele scripturi SQL pentru a crea tabelele necesare:

```sql
-- Tabel pentru rate limiting
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ChatRateLimits' AND type = 'U')
BEGIN
    CREATE TABLE ChatRateLimits (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        RateLimitKey NVARCHAR(255) NOT NULL UNIQUE,
        Count INT NOT NULL DEFAULT 1,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ExpiresAt DATETIME2 NULL
    );
    
    CREATE INDEX IX_ChatRateLimits_RateLimitKey ON ChatRateLimits(RateLimitKey);
    CREATE INDEX IX_ChatRateLimits_ExpiresAt ON ChatRateLimits(ExpiresAt);
END

-- Tabel pentru cost control
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ChatUsages' AND type = 'U')
BEGIN
    CREATE TABLE ChatUsages (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        MonthKey NVARCHAR(10) NOT NULL UNIQUE, -- YYYY-MM
        UsdSpent DECIMAL(10,4) NOT NULL DEFAULT 0,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        MetaLast NVARCHAR(1000) NULL
    );
    
    CREATE INDEX IX_ChatUsages_MonthKey ON ChatUsages(MonthKey);
END
```

**FAQ Cache Table:**
```sql
-- Rulează scriptul: DataAccess/Scripts/CreateFaqTable.sql
```

**Lead Capture Tables:**
```sql
-- Rulează scriptul pentru Lead Capture
-- DataAccess/Scripts/CreateLeadTables.sql
```

**Populare FAQ:**
```sql
-- Rulează scriptul pentru a popula FAQ-urile cu întrebări frecvente
-- DataAccess/Scripts/SeedFaqItems.sql
```

Sau rulează migrații Entity Framework Core:

```bash
dotnet ef migrations add AddChatAndLeadTables
dotnet ef database update
```

## Funcționalități

### Backend API Endpoints

#### POST /api/chat
Trimite un mesaj către asistentul virtual.

**Request:**
```json
{
  "message": "Ce este gradul de indatorare?",
  "conversation_id": "optional-conversation-id",
  "context": {
    "eligibility_result": {...}
  }
}
```

**Response:**
```json
{
  "raspuns": "Gradul de indatorare (DTI) arata cat din venitul tau lunar...",
  "model_folosit": "gpt-3.5-turbo",
  "upgraded": false,
  "incredere": 0.85,
  "siguranta": {
    "bank_name_scrubbed": false
  },
  "nota": "Rezultatele sunt estimative; aprobarea finala apartine creditorului."
}
```

#### GET /api/chat/initial
Obține mesajul inițial al botului și disclaimer-ul.

**Response:**
```json
{
  "mesaj": "Salut! Sunt Asistentul Virtual MoneyShop...",
  "disclaimer": "Asistentul virtual MoneyShop ofera informatii generale..."
}
```

### Rate Limiting

- **20 cereri pe minut** per utilizator
- **200 cereri pe zi** per utilizator
- Răspuns: `429 Too Many Requests` cu detalii despre fereastra limitată

### Cost Control

- **Buget lunar**: 150 USD (configurabil)
- Tracking automat al costurilor pe lună
- Răspuns: `402 Payment Required` când bugetul este depășit

### Protecții de Conformitate

1. **Filtru nume bănci**: Detectează și înlocuiește automat numele de bănci cu "o institutie financiara"
2. **Topic Guard**: Blochează cereri care conțin:
   - Date sensibile (CNP, serie/numar CI, card, OTP)
   - Fraude / bypass verificări
   - Conținut ilegal
3. **Refuz recomandări bănci**: Dacă utilizatorul cere recomandări de bănci, botul refuză politicos și oferă criterii generale

### Fallback Logic

1. **Model primar**: `gpt-3.5-turbo` (ieftin, rapid)
   - Cere răspuns în format JSON cu `necesita_upgrade`
   - Dacă `incredere < 0.65` sau detectează nume bănci → fallback
2. **Model fallback**: `gpt-4o-mini` (mai bun, mai scump)
   - Folosit doar când modelul primar nu este sigur

## Frontend (React Native)

### Serviciu API

Serviciul `chatApi` este disponibil în `MoneyShopMobile/src/services/api/chatApi.ts`.

### Utilizare

```typescript
import {chatApi} from '../services/api/chatApi';

// Obține mesajul inițial
const initial = await chatApi.getInitialMessage();

// Trimite mesaj
const response = await chatApi.sendMessage({
  message: 'Ce este gradul de indatorare?',
  conversation_id: 'user-123'
});
```

### UI Chat

Ecranul `ChatScreen` este disponibil în `MoneyShopMobile/src/screens/Chat/ChatScreen.tsx` și este integrat în navigația principală ca tab "Chat".

## Reguli și Conformitate

### Prompt System

Botul respectă următoarele reguli obligatorii:

1. **NU menționează nume de bănci/IFN/branduri financiare**
2. **NU promite aprobări sau garantează dobânzi**
3. **NU solicită sau afișează date sensibile** (CNP, CI, card, OTP)
4. **Răspunsuri în română fără diacritice**
5. **Clare, scurte, structurate** (liste/bullets)
6. **Notă de conformitate** la final: "Rezultatele sunt estimative; aprobarea finala apartine creditorului."

### Disclaimer Legal

Toate răspunsurile includ un disclaimer care clarifică că:
- Asistentul oferă informații generale și educaționale
- NU reprezintă consultanță financiară/juridică personalizată
- NU garantează aprobarea unui credit sau o dobândă anume
- MoneyShop este broker/intermediar, NU instituție de credit

## Limitări și Costuri

### Limitări OpenAI API

- Rate limiting: 30 cereri / 100 secunde pentru generare documente
- Rate limiting: 30 cereri / 10 secunde pentru alte cereri
- Token limit: 350 tokens output (configurabil)

### Estimare Costuri

- **gpt-3.5-turbo**: ~$3.00 / 1M tokens input, ~$6.00 / 1M tokens output
- **gpt-4o-mini**: ~$0.25 / 1M tokens input, ~$1.00 / 1M tokens output

Bugetul lunar este monitorizat automat și blocat când este depășit.

## Funcționalități Avansate

### FAQ Cache System ✅ IMPLEMENTAT

Sistem implementat pentru a reduce costurile cu 30-50% prin răspunsuri locale la întrebări frecvente:

- **Cache local** pentru 20-30 întrebări frecvente
- **Matching exact** + **fuzzy** (Jaccard similarity)
- **Prag minim**: 0.55 pentru match
- **Priority bonus**: FAQ-urile cu prioritate mai mare au șanse mai mari de match

**Populare FAQ:**
```sql
-- Rulează scriptul pentru a popula FAQ-urile
-- DataAccess/Scripts/SeedFaqItems.sql
```

FAQ-urile sunt verificate **înainte** de apelul către OpenAI, reducând costurile semnificativ.

### Lead Capture System ✅ IMPLEMENTAT

Sistem pentru colectarea datelor de contact și calificare leads:

#### Endpoint-uri:

**POST /api/lead/capture** - Capturare lead direct (formular complet)
```json
{
  "numePrenume": "Ion Popescu",
  "telefon": "0712345678",
  "email": "ion@example.com",
  "oras": "Bucuresti",
  "crediteActive": true,
  "soldTotalAprox": 50000,
  "tipCreditor": "BANCA",
  "intarzieri": false,
  "venitNetLunar": 5000,
  "poprireSauExecutorUltimii5Ani": false
}
```

**POST /api/lead/next** - Conversation state machine (pas cu pas)
```json
{
  "action": "start", // sau "answer", "reset"
  "conversationId": "abc123",
  "answer": "Ion Popescu" // doar pentru action=answer
}
```

#### Caracteristici:

- **State machine** cu 8 pași pentru colectare progresivă
- **Sesiuni persistente** în baza de date (TTL 7 zile)
- **Parsing inteligent** al răspunsurilor (DA/NU, numere, zile)
- **Validare completă** la finalizare
- **Fără nume bănci** - doar tip creditor (BANCA/IFN/LEASING)

#### Tabele necesare:

```sql
-- Rulează scriptul pentru a crea tabelele
-- DataAccess/Scripts/CreateLeadTables.sql
```

## Suport

Pentru probleme tehnice:
- Verifică logurile în Application Insights
- Verifică rate limiting și cost control în baza de date
- Verifică configurarea OpenAI API key

Pentru întrebări despre conformitate:
- Consultă documentația legală din aplicație
- Contactează echipa de conformitate

