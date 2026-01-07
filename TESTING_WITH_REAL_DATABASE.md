# Testare Aplicație cu Baza de Date Reală

## ✅ Modificări Făcute

### 1. Backend (ASP.NET Core)
- ✅ **Dezactivat auto-login mock middleware** - aplicația folosește acum autentificare reală
- ✅ **Schimbat login path** - de la `/MockAccount/Login` la `/Account/Login`
- ✅ **Baza de date locală configurată** - `Server=localhost;Database=MoneyShop`

### 2. Frontend (React Native)
- ✅ **Dezactivat mock authentication** - aplicația folosește acum API-ul real
- ✅ **Configurat pentru IP local** - poți seta `LOCAL_IP` în `constants.ts` pentru testare pe iPhone

### 3. Baza de Date
- ✅ **23 de tabele create** - toate entitățile sunt în baza de date
- ✅ **Utilizator de test creat**:
  - **Email**: `test@moneyshop.ro`
  - **Parola**: `Test123!`
  - **ID**: 1

## 🚀 Cum să Testezi

### 1. Pornește Backend-ul

```powershell
cd MoneyShop
dotnet run
```

Backend-ul va rula pe:
- **HTTPS**: `https://localhost:7093`
- **HTTP**: `http://localhost:5259`
- **Swagger**: `https://localhost:7093/swagger`

### 2. Testează API-ul (Swagger sau Postman)

Deschide Swagger: `https://localhost:7093/swagger`

#### Test Login:
```json
POST /api/auth/login
{
  "email": "test@moneyshop.ro",
  "password": "Test123!"
}
```

#### Test Register:
```json
POST /api/auth/register
{
  "email": "newuser@moneyshop.ro",
  "password": "Password123!",
  "firstName": "New",
  "lastName": "User",
  "role": 1
}
```

### 3. Testează React Native (Web/iPhone)

#### Pentru Web:
```powershell
cd MoneyShopMobile
$env:NODE_TLS_REJECT_UNAUTHORIZED="0"
npm start
# Apasă 'w' pentru web
```

#### Pentru iPhone:
1. Găsește IP-ul local al computerului:
   ```powershell
   ipconfig | findstr IPv4
   ```

2. Actualizează `MoneyShopMobile/src/utils/constants.ts`:
   ```typescript
   const LOCAL_IP = '192.168.1.XXX'; // IP-ul tău
   ```

3. Pornește aplicația:
   ```powershell
   cd MoneyShopMobile
   $env:NODE_TLS_REJECT_UNAUTHORIZED="0"
   npm start
   ```

4. Scanează QR code cu Expo Go pe iPhone

### 4. Credențiale de Test

**Utilizator existent:**
- Email: `test@moneyshop.ro`
- Parola: `Test123!`

**Sau creează unul nou** prin API `/api/auth/register` sau prin interfața web.

## 🔍 Verificări

### Verifică conexiunea la baza de date:
```sql
-- În SSMS
USE MoneyShop;
SELECT COUNT(*) FROM Utilizatori;
SELECT * FROM Utilizatori;
```

### Verifică API-ul funcționează:
```powershell
# Test login cu curl
curl -X POST https://localhost:7093/api/auth/login `
  -H "Content-Type: application/json" `
  -d '{\"email\":\"test@moneyshop.ro\",\"password\":\"Test123!\"}' `
  -k
```

## 📝 Note Importante

1. **CORS** - Backend-ul este configurat să accepte conexiuni de la:
   - `http://localhost:8081` (Expo web)
   - `http://localhost:19006` (Expo default)
   - IP-ul tău local pentru dispozitive fizice

2. **HTTPS** - Pentru development, am configurat `NODE_TLS_REJECT_UNAUTHORIZED=0` în React Native pentru a ignora erorile de certificat SSL.

3. **Mock-urile** - Toate mock-urile au fost dezactivate. Aplicația folosește acum baza de date reală.

## 🐛 Troubleshooting

### Eroare: "Invalid email or password"
- Verifică că utilizatorul există în baza de date
- Verifică că parola este hash-uită corect (SHA256 + Base64)

### Eroare: "Cannot connect to database"
- Verifică că SQL Server rulează
- Verifică connection string-ul în `appsettings.Development.json`
- Verifică că baza de date `MoneyShop` există

### Eroare CORS în React Native
- Verifică că backend-ul rulează
- Verifică că IP-ul este corect în `constants.ts`
- Verifică că ambele (backend și mobile) sunt pe aceeași rețea

### Eroare: "Network request failed" pe iPhone
- Verifică că iPhone-ul și computerul sunt pe aceeași rețea Wi-Fi
- Verifică că firewall-ul permite conexiuni
- Verifică că folosești IP-ul local, nu `localhost`

