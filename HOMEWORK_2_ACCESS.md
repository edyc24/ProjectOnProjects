# Cum să Accesezi Pagina Homework 2

## 📍 URL-ul Paginii

După ce ai deployat aplicația în Azure App Service, pagina simplă pentru Homework 2 este accesibilă la:

```
https://[app-service-url]/Home/Simple
```

**Exemplu:**
```
https://moneyshop20260107220205-adbnf8c7a2fec4d4.azurewebsites.net/Home/Simple
```

## 🔍 Explicație

### Ce vezi când accesezi URL-ul App Service?

Când accesezi direct URL-ul App Service (ex: `https://moneyshop20260107220205-adbnf8c7a2fec4d4.azurewebsites.net`), vei vedea:

1. **Pagina principală** (`/Home/Index`) - aceasta este pagina CSHTML cu informații despre MoneyShop
2. **Swagger UI** (`/swagger`) - documentația API-ului

### Pentru Homework 2 - Pagina Simplă

**URL complet:** `https://[app-service-url]/Home/Simple`

Această pagină include:
- ✅ Input text field
- ✅ "Enter" button
- ✅ Listă persistentă de items (salvate în Azure SQL Database)
- ✅ Acces public (fără autentificare necesară)

## 🎯 Diferența dintre Frontend-uri

### 1. **Backend MVC (CSHTML)** - Pentru Homework 2
- **Locație:** `MoneyShop/Views/`
- **URL:** `https://[app-url]/Home/Simple`
- **Tehnologie:** ASP.NET Core MVC cu Razor Views
- **Folosit pentru:** Pagini web tradiționale, Homework 2

### 2. **React Native Mobile App** - Pentru aplicația mobilă
- **Locație:** `MoneyShopMobile/`
- **Tehnologie:** React Native (Expo)
- **Rulare:** Separată, pe device mobil sau prin Expo
- **Conectare:** Se conectează la backend prin API (`/api/*`)

## ✅ Verificare

1. **Accesează pagina simplă:**
   ```
   https://[app-service-url]/Home/Simple
   ```

2. **Ar trebui să vezi:**
   - Un câmp de input
   - Un buton "Enter"
   - O listă de items (dacă există deja)

3. **Testează funcționalitatea:**
   - Introdu un text (ex: "Test Item 1")
   - Click pe "Enter"
   - Item-ul ar trebui să apară în listă
   - Refresh pagina - item-ul ar trebui să rămână

## 🔧 Dacă Pagina Nu Se Încarcă

### Verifică:
1. **URL-ul este corect:** `https://[app-url]/Home/Simple` (cu majuscule)
2. **Aplicația este deployată:** Verifică în Azure Portal că App Service rulează
3. **Database connection:** Verifică că connection string-ul este corect în App Settings
4. **Migrații aplicate:** Rulează migrațiile EF Core la baza de date Azure

### Debug:
- Accesează: `https://[app-url]/swagger` - ar trebui să vezi Swagger UI
- Accesează: `https://[app-url]/api/health` - ar trebui să returneze JSON cu status "healthy"

## 📝 Note

- **Pagina `/Home/Simple` este o pagină web tradițională (CSHTML)**, nu React Native
- **React Native** este pentru aplicația mobile separată și rulează pe device-ul tău, nu pe Azure
- Pentru Homework 2, pagina CSHTML este exact ce trebuie - o pagină simplă cu input + button + listă

