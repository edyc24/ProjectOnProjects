# Proiect Oracle Database - MoneyShop
## Securitatea Bazelor de Date

---

## 📋 Structura Proiectului

Acest proiect implementează o bază de date Oracle completă pentru aplicația MoneyShop, respectând toate cerințele de securitate și management.

### Fișiere Proiect:

1. **01_DIAGRAMA_CONCEPTUALA.md** - Diagrama conceptuală și regulile modelului
2. **02_SCHEME_RELATIONALE.md** - Schemele relaționale normalizate
3. **03_CREATE_TABLES.sql** - Script-uri pentru crearea tabelelor
4. **04_SECURITATE.sql** - Reguli de securitate (constraints, checks, validations)
5. **05_CRIPTARE.sql** - Criptarea datelor (TDE și column-level encryption)
6. **06_AUDITARE.sql** - Auditarea activităților (standard, trigger-i, politici)
7. **07_GESTIUNE_UTILIZATORI.sql** - Gestiunea utilizatorilor și resurselor computaționale
8. **08_PRIVILEGII_ROLURI.sql** - Privilegii sistem, obiect și ierarhii
9. **09_SQL_INJECTION.md** - Context aplicație și protecție SQL Injection
10. **10_MASCARE_DATE.sql** - Mascarea datelor (Data Masking)

---

## 🚀 Instalare și Configurare

### Cerințe:
- Oracle Database 19c sau superior
- Privilegii DBA pentru configurarea inițială
- Oracle Wallet pentru TDE

### Ordinea de Executare:

```sql
-- 1. Conectare ca SYS sau utilizator cu privilegii DBA
CONNECT sys AS SYSDBA;

-- 2. Executare script-uri în ordine:
@03_CREATE_TABLES.sql
@04_SECURITATE.sql
@05_CRIPTARE.sql
@06_AUDITARE.sql
@07_GESTIUNE_UTILIZATORI.sql
@08_PRIVILEGII_ROLURI.sql
@10_MASCARE_DATE.sql
```

---

## 📊 Modelul de Date

### Entități Principale:
- **UTILIZATORI** - Utilizatorii aplicației (clienți, brokeri, admini)
- **ROLURI** - Rolurile utilizatorilor
- **APLICATII** - Cererile de credit
- **BANCI** - Băncile partenere
- **DOCUMENTE** - Documentele încărcate
- **LEADURI** - Lead-urile capturate
- **CONSENTURI** - Consimțământurile GDPR
- **MANDATE** - Mandatele de brokeraj

---

## 🔒 Funcționalități de Securitate

### 1. Criptare
- **TDE (Transparent Data Encryption)** pentru datele sensibile
- **Column-level encryption** pentru CNP, numere de telefon, email-uri
- **Oracle Wallet** pentru managementul cheilor

### 2. Auditare
- **Standard Audit** pentru operațiuni critice
- **Trigger-based Audit** pentru modificări de date
- **Fine-Grained Audit Policies** pentru acces la date sensibile

### 3. Gestiune Utilizatori
- **Matrici proces-utilizator** pentru controlul accesului
- **Matrici entitate-proces** pentru izolarea datelor
- **Matrici entitate-utilizator** pentru privilegii granulare

### 4. Privilegii și Roluri
- **Roluri ierarhice** (CLIENT, BROKER, ADMIN)
- **Privilegii obiect** granulare
- **Privilegii sistem** minimale

### 5. Protecție SQL Injection
- **Parametrizație** obligatorie în aplicație
- **Validare input** la nivel de bază de date
- **Proceduri stocate** pentru operațiuni critice

### 6. Mascare Date
- **Data Masking** pentru datele sensibile în medii non-producție
- **Dynamic Data Masking** pentru utilizatori neautorizați

---

## 📝 Documentație Suplimentară

Pentru detalii despre fiecare componentă, consultați fișierele individuale din acest director.

---

## 👤 Autor
Proiect realizat pentru cerințele cursului de Securitatea Bazelor de Date.

---

## 📅 Data
2025

