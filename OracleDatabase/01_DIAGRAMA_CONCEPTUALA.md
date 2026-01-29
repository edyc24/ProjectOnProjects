# 1. Diagrama Conceptuală - MoneyShop

## 1.1 Prezentarea Modelului

Modelul de date pentru aplicația **MoneyShop** gestionează un sistem de brokeraj de credite, unde utilizatorii pot aplica pentru credite, brokerii pot procesa cererile, iar administratorii pot gestiona întregul sistem.

### Scenariul de Business:
MoneyShop este o platformă de brokeraj de credite care conectează clienții cu băncile partenere. Clienții completează cereri de credit, brokerii le procesează și le trimit către bănci, iar sistemul gestionează documentele, consimțământurile GDPR și toate datele financiare sensibile.

---

## 1.2 Diagrama Conceptuală

```
┌─────────────────┐
│   UTILIZATORI   │
│  (IdUtilizator) │
│  Nume, Prenume  │
│  Email, Telefon │
│  CNP (criptat)  │
└────────┬────────┘
         │
         │ 1:N
         │
    ┌────┴─────────────────────────────────────┐
    │                                           │
    │                                           │
┌───▼────────┐                          ┌──────▼──────┐
│   ROLURI   │                          │  APLICATII  │
│ (IdRol)    │                          │   (Id)      │
│ NumeRol    │                          │  UserId     │
│ Descriere  │                          │  Status     │
└────────────┘                          │  TypeCredit │
                                        │  Scoring    │
                                        │  SumaAprobata│
                                        └──────┬──────┘
                                               │
                                               │ 1:N
                                               │
                    ┌──────────────────────────┼──────────────────────────┐
                    │                          │                          │
            ┌───────▼──────┐          ┌───────▼──────┐          ┌────────▼──────┐
            │  DOCUMENTE   │          │  AGREEMENTS  │          │ APPLICATION   │
            │   (Id)       │          │    (Id)       │          │    BANKS      │
            │ ApplicationId│          │ ApplicationId│          │   (Id)         │
            │ TipDocument  │          │ TipAcord     │          │ ApplicationId │
            │ Path         │          │ Status       │          │ BankId        │
            └──────────────┘          └──────────────┘          └───────┬────────┘
                                                                       │
                                                                       │ N:1
                                                                       │
                                                              ┌────────▼──────┐
                                                              │    BANCI      │
                                                              │   (Id)        │
                                                              │  Name         │
                                                              │  Commission   │
                                                              └──────────────┘

┌─────────────────┐
│     LEADURI     │
│    (Id)         │
│  Nume, Prenume  │
│  Email, Telefon │
│  Status         │
└─────────────────┘

┌─────────────────┐         ┌─────────────────┐
│   CONSENTURI    │         │    MANDATE      │
│    (Id)         │         │     (Id)         │
│  UserId         │         │  UserId         │
│  TipConsent     │         │  BrokerId       │
│  Status         │         │  Status         │
│  DataConsent    │         │  DataMandat     │
└─────────────────┘         └─────────────────┘

┌─────────────────┐
│ USER_FINANCIAL  │
│     _DATA       │
│    (Id)         │
│  UserId         │
│  SalariuNet     │
│  SoldTotal      │
│  DTI            │
└─────────────────┘
```

---

## 1.3 Reguli de Business

### R1: Utilizatori și Roluri
- Fiecare utilizator are un singur rol (CLIENT, BROKER, ADMIN)
- Utilizatorii pot avea multiple cereri de credit
- Email-ul și CNP-ul trebuie să fie unice

### R2: Aplicații de Credit
- O aplicație aparține unui singur utilizator
- O aplicație poate fi asociată cu mai multe bănci
- Statusul aplicației: INREGISTRAT → IN_PROCESARE → APROBAT/REFUZAT
- Scoring-ul se calculează automat pe baza datelor financiare

### R3: Documente
- Fiecare document este asociat cu o aplicație
- Documentele sunt stocate criptat
- Tipuri de documente: CI, Fluturas, ExtrasCont, Altele

### R4: Consimțământuri GDPR
- Fiecare utilizator trebuie să dea consimțământ pentru procesarea datelor
- Consimțământul trebuie să fie înregistrat cu timestamp
- Status: ACTIV, EXPIRAT, REVOCAT

### R5: Mandate Broker
- Un utilizator poate da mandate mai multor brokeri
- Mandatul trebuie să fie activ pentru ca brokerul să poată procesa aplicația
- Status: ACTIV, EXPIRAT, REVOCAT

### R6: Date Financiare
- Datele financiare sunt criptate la nivel de coloană
- DTI (Debt-to-Income) se calculează automat
- Scoring-ul se actualizează la fiecare modificare a datelor

### R7: Securitate
- CNP-ul este întotdeauna criptat
- Parolele sunt hash-uite (nu stocate în plain text)
- Toate accesările la date sensibile sunt auditate

---

## 1.4 Atribute Cheie

### UTILIZATORI
- **IdUtilizator** (PK) - Identificator unic
- **Email** (UK) - Email unic, validat
- **CNP** - Criptat, validat (13 cifre)
- **Parola** - Hash SHA-256, nu plain text

### APLICATII
- **Id** (PK) - Identificator unic
- **UserId** (FK) - Referință la utilizator
- **Status** - Enum: INREGISTRAT, IN_PROCESARE, APROBAT, REFUZAT
- **Scoring** - Calculat automat, între 300-850

### DOCUMENTE
- **Id** (PK) - Identificator unic
- **ApplicationId** (FK) - Referință la aplicație
- **Path** - Cale criptată către fișier
- **TipDocument** - Enum: CI, FLUTURAS, EXTRAS_CONT, ALTUL

---

## 1.5 Relații

| Entitate 1 | Cardinalitate | Relație | Cardinalitate | Entitate 2 |
|------------|---------------|---------|---------------|------------|
| UTILIZATORI | 1 | are | N | APLICATII |
| UTILIZATORI | 1 | are | 1 | ROLURI |
| APLICATII | 1 | are | N | DOCUMENTE |
| APLICATII | 1 | are | N | AGREEMENTS |
| APLICATII | N | asociat cu | M | BANCI |
| UTILIZATORI | 1 | are | N | CONSENTURI |
| UTILIZATORI | 1 | are | N | MANDATE |
| UTILIZATORI | 1 | are | 1 | USER_FINANCIAL_DATA |

---

## 1.6 Constrângeri de Integritate

1. **Integritate Referențială**: Toate cheile străine trebuie să existe în tabelele părinte
2. **Integritate Domeniu**: Toate valorile trebuie să respecte tipurile și constrângerile definite
3. **Integritate Entitate**: Fiecare entitate trebuie să aibă o cheie primară unică
4. **Integritate Utilizator**: Email-ul și CNP-ul trebuie să fie unice per utilizator

---

## 1.7 Note de Implementare

- Toate datele sensibile (CNP, email, telefon) sunt criptate
- Timestamp-urile sunt în UTC
- Soft delete pentru utilizatori (IsDeleted flag)
- Audit trail complet pentru toate modificările

