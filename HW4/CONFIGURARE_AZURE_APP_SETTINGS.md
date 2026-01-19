# Configurare Rapidă Azure App Settings

## ⚠️ Eroare: "Azure OpenAI is not configured"

Dacă vezi această eroare, urmează acești pași:

## Pași Rapizi (5 minute)

### 1. Azure Portal → App Service

1. https://portal.azure.com
2. Caută App Service-ul tău (ex: `moneyshop-app`)
3. Click pe el

### 2. Configuration → Application settings

1. Meniu stânga → **Configuration**
2. Tab **Application settings**
3. Click **+ New application setting**

### 3. Adaugă 4 Setări

Adaugă fiecare setare (click **+ New application setting** pentru fiecare):

| Name | Value |
|------|-------|
| `AzureOpenAI__Endpoint` | `https://openaimoneyshop.openai.azure.com` |
| `AzureOpenAI__ApiKey` | `[cheia ta API]` |
| `AzureOpenAI__DeploymentName` | `gpt-4o-mini` |
| `AzureOpenAI__ApiVersion` | `2024-02-15-preview` |

**⚠️ IMPORTANT:** Folosește `__` (două underscore-uri), NU `:`!

### 4. Salvează și Restart

1. Click **Save** (sus)
2. Click **Continue** pentru restart
3. Așteaptă 1-2 minute

### 5. Testează

Accesează: `https://your-app.azurewebsites.net/openai-plugin`

## Obținere API Key

1. Azure Portal → **Azure OpenAI** → Resource-ul tău
2. **Keys and Endpoint** → Copiază **KEY 1**

## Vezi `AZURE_CONFIGURATION_GUIDE.md` pentru detalii complete

