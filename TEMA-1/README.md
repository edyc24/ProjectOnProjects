# Homework 1 - Static Web Page on Azure Storage

## Date Student
**Nume:** [Numele tău complet]  
**URL:** [URL-ul paginii după deployment - se generează automat când rulezi scriptul]

## Despre Proiect

Am creat o pagină statică simplă care prezintă platforma MoneyShop. Pagina include informații despre:
- Ce face aplicația (intermediere credit)
- Funcționalitățile principale (mobile app, simulator, documente, securitate)
- Tehnologiile folosite (ASP.NET Core, React Native, Azure SQL, etc.)
- Cum să ne contactezi

Am făcut pagina responsive și am folosit un design modern cu gradient-uri și card-uri care arată bine pe orice device.

## Cum am deployat

Am creat un script PowerShell care face totul automat:

```powershell
cd TEMA-1
.\deploy.ps1
```

Scriptul face următoarele:
1. Creează un Resource Group în Azure
2. Creează un Storage Account (cu nume generat automat)
3. Activează Static Website Hosting
4. Upload toate fișierele (index.html, styles.css, 404.html)

După ce rulezi scriptul, primești URL-ul paginii în format:
`https://[nume-storage-account].z[location].web.core.windows.net`

## Fișiere

- `index.html` - Pagina principală
- `styles.css` - Stilurile CSS
- `404.html` - Pagina de eroare 404
- `deploy.ps1` - Scriptul pentru deployment

## Ce ai nevoie

- Azure CLI instalat (dacă nu ai, poți instala de aici: https://aka.ms/installazurecliwindows)
- Să fii autentificat în Azure (`az login`)
- Să ai permisiuni să creezi resurse în Azure

## Ștergere resurse

Dacă vrei să ștergi tot ce am creat (pentru a nu plăti pentru resursele nefolosite):

```powershell
az group delete --name moneyshop-hw1-rg --yes
```
