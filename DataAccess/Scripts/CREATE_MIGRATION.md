# Cum să creezi o migrare nouă în Entity Framework

## Comanda de bază

```powershell
dotnet ef migrations add <NumeMigrare> --project DataAccess --startup-project MoneyShop
```

## Exemple

### 1. Migrare pentru modificări generale
```powershell
dotnet ef migrations add UpdateUserTable --project DataAccess --startup-project MoneyShop
```

### 2. Migrare pentru adăugare de coloană
```powershell
dotnet ef migrations add AddEmailToUsers --project DataAccess --startup-project MoneyShop
```

### 3. Migrare pentru creare de tabel nou
```powershell
dotnet ef migrations add CreateProductsTable --project DataAccess --startup-project MoneyShop
```

### 4. Migrare pentru modificare de index
```powershell
dotnet ef migrations add AddIndexToUsersEmail --project DataAccess --startup-project MoneyShop
```

## Pași completi

### 1. Modifică entitățile în `Entities/Entities/`
Adaugă sau modifică proprietăți în clasele de entități.

### 2. Actualizează `MoneyShopContext.cs` (dacă e necesar)
Dacă ai adăugat entități noi, adaugă-le în `DbSet`.

### 3. Creează migrarea
```powershell
cd C:\Users\eduardcr\source\repos\MoneyShop
dotnet ef migrations add <NumeMigrare> --project DataAccess --startup-project MoneyShop
```

### 4. Verifică migrarea creată
Migrarea va fi creată în `DataAccess/Migrations/` cu numele:
- `<Timestamp>_<NumeMigrare>.cs` - codul migrației
- `<Timestamp>_<NumeMigrare>.Designer.cs` - metadata

### 5. Aplică migrarea la baza de date
```powershell
dotnet ef database update --project DataAccess --startup-project MoneyShop
```

## Opțiuni utile

### Verifică statusul migrațiilor
```powershell
dotnet ef migrations list --project DataAccess --startup-project MoneyShop
```

### Șterge ultima migrare (dacă nu a fost aplicată)
```powershell
dotnet ef migrations remove --project DataAccess --startup-project MoneyShop
```

### Generează script SQL pentru migrare (fără a aplica)
```powershell
dotnet ef migrations script --project DataAccess --startup-project MoneyShop --output migration.sql
```

### Generează script SQL pentru o migrare specifică
```powershell
dotnet ef migrations script <FromMigration> <ToMigration> --project DataAccess --startup-project MoneyShop --output migration.sql
```

## Exemple practice

### Adaugă o coloană nouă la tabelul Users

1. **Modifică entitatea** (`Entities/Entities/Utilizatori.cs`):
```csharp
public string? PhoneNumber { get; set; }
```

2. **Creează migrarea**:
```powershell
dotnet ef migrations add AddPhoneNumberToUsers --project DataAccess --startup-project MoneyShop
```

3. **Aplică migrarea**:
```powershell
dotnet ef database update --project DataAccess --startup-project MoneyShop
```

### Creează un tabel nou

1. **Creează entitatea** (`Entities/Entities/Product.cs`):
```csharp
public class Product
{
    public int Id { get; set; }
    public string Name { get; set; }
    public decimal Price { get; set; }
}
```

2. **Adaugă în DbContext** (`DataAccess/EntityFramework/MoneyShopContext.cs`):
```csharp
public virtual DbSet<Product> Products { get; set; }
```

3. **Configurează în OnModelCreating** (dacă e necesar)

4. **Creează migrarea**:
```powershell
dotnet ef migrations add CreateProductsTable --project DataAccess --startup-project MoneyShop
```

5. **Aplică migrarea**:
```powershell
dotnet ef database update --project DataAccess --startup-project MoneyShop
```

## Troubleshooting

### Eroare: "No DbContext was found"
- Verifică că `MoneyShopContext` este în proiectul `DataAccess`
- Verifică că folosești `--startup-project MoneyShop`

### Eroare: "Unable to create an object of type 'MoneyShopContext'"
- Verifică connection string-ul în `appsettings.Development.json`
- Asigură-te că baza de date există

### Eroare: "Build failed"
- Rulează `dotnet build` pentru a vedea erorile
- Rezolvă erorile de compilare înainte de a crea migrarea

### Vrei să modifici o migrare deja aplicată
1. Șterge migrarea: `dotnet ef migrations remove`
2. Modifică entitățile
3. Creează migrarea din nou: `dotnet ef migrations add <Nume>`
4. Aplică: `dotnet ef database update`

**NOTĂ**: Dacă migrarea a fost deja aplicată în producție, NU o șterge. Creează o migrare nouă care să o modifice.

