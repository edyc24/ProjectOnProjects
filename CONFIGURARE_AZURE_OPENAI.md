# Configurare Azure OpenAI pentru Plugin

## Eroare Actuală

Dacă vezi eroarea:
```
Status 500: Azure OpenAI is not configured. Please set AzureOpenAI:Endpoint and AzureOpenAI:ApiKey in appsettings.json
```

Înseamnă că trebuie să configurezi credențialele Azure OpenAI.

## Pași de Configurare

### 1. Obținere Credențiale Azure OpenAI

1. Accesează **Azure Portal**: https://portal.azure.com
2. Creează sau accesează un **Azure OpenAI** resource
3. Mergi la **Keys and Endpoint** în resource-ul tău
4. Copiază:
   - **Endpoint**: URL-ul complet (ex: `https://your-resource.openai.azure.com`)
   - **Key 1** sau **Key 2**: Una dintre cheile API

### 2. Obținere Deployment Name

1. În Azure Portal, mergi la **Deployments** în resource-ul Azure OpenAI
2. Notează numele deployment-ului (ex: `gpt-35-turbo`, `gpt-4`, etc.)
3. Dacă nu ai un deployment, creează unul:
   - Click pe **Create** sau **Deploy model**
   - Alege un model (recomandat: `gpt-35-turbo` pentru costuri mai mici)
   - Dă-i un nume (ex: `gpt-35-turbo`)
   - Așteaptă până când deployment-ul este gata

### 3. Configurare în appsettings.Development.json

Editează fișierul `MoneyShop/appsettings.Development.json` și adaugă:

```json
{
  "AzureOpenAI": {
    "Endpoint": "https://your-resource.openai.azure.com",
    "ApiKey": "your-api-key-here",
    "DeploymentName": "gpt-35-turbo",
    "ApiVersion": "2024-02-15-preview"
  }
}
```

**Exemplu complet:**
```json
{
  "DetailedErrors": true,
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "ConnectionStrings": {
    "DefaultConnection": "..."
  },
  "Brevo": {
    "ApiKey": "",
    "FromEmail": "",
    "FromName": "MoneyShop",
    "SmsSenderName": "MoneyShop"
  },
  "Otp": {
    "Pepper": "default-pepper-change-in-production"
  },
  "ApplicationInsights": {
    "ConnectionString": ""
  },
  "AzureOpenAI": {
    "Endpoint": "https://moneyshop-openai.openai.azure.com",
    "ApiKey": "abc123def456ghi789jkl012mno345pqr678stu901vwx234yz",
    "DeploymentName": "gpt-35-turbo",
    "ApiVersion": "2024-02-15-preview"
  }
}
```

### 4. Verificare Configurare

După ce ai adăugat configurarea:

1. **Repornește aplicația** (dacă rulează)
2. Accesează din nou: `https://localhost:7093/openai-plugin`
3. Testează cu butonul "Get Plugin Info" - ar trebui să funcționeze
4. Testează cu un prompt - ar trebui să primești un rezumat

## Structura Configurării

```json
"AzureOpenAI": {
  "Endpoint": "https://your-resource.openai.azure.com",  // REQUIRED - URL-ul resource-ului
  "ApiKey": "your-api-key",                              // REQUIRED - Cheia API
  "DeploymentName": "gpt-35-turbo",                      // REQUIRED - Numele deployment-ului
  "ApiVersion": "2024-02-15-preview"                     // OPTIONAL - Versiunea API (default: 2024-02-15-preview)
}
```

## Note Importante

⚠️ **Securitate:**
- Nu commit-ui configurația cu API keys în Git!
- Pentru producție, folosește Azure Key Vault sau App Settings
- Pentru development, folosește User Secrets sau appsettings.Development.json (care nu ar trebui să fie commit-uit)

⚠️ **Costuri:**
- Azure OpenAI are costuri asociate
- Modelul `gpt-35-turbo` este mai ieftin decât `gpt-4`
- Monitorizează utilizarea în Azure Portal

## Troubleshooting

### Eroare: "Invalid endpoint"
- Verifică că Endpoint-ul este corect (trebuie să înceapă cu `https://`)
- Verifică că nu ai spații la început/sfârșit

### Eroare: "Invalid API key"
- Verifică că ai copiat corect cheia API
- Verifică că nu ai spații la început/sfârșit
- Încearcă cu cealaltă cheie (Key 1 sau Key 2)

### Eroare: "Deployment not found"
- Verifică că deployment-ul există în Azure Portal
- Verifică că numele deployment-ului este corect (case-sensitive)
- Așteaptă câteva minute dacă tocmai ai creat deployment-ul

### Eroare: "Rate limit exceeded"
- Ai depășit limita de request-uri
- Așteaptă câteva minute sau verifică limitele în Azure Portal

## Testare Rapidă

După configurare, testează cu:

1. **Get Plugin Info** - Ar trebui să returneze:
```json
{
  "name": "MoneyShop Text Summarizer Plugin",
  "description": "Summarizes the text received through the prompt using Azure OpenAI",
  "version": "1.0.0"
}
```

2. **Test Prompt** - Introdu text și verifică că primești un rezumat

## Suport

Dacă întâmpini probleme:
1. Verifică logurile aplicației
2. Verifică configurarea în appsettings.Development.json
3. Verifică că Azure OpenAI resource-ul este activ în Azure Portal

