# Ghid Configurare Azure App Service pentru Azure OpenAI Plugin

## Eroare Curentă

Dacă vezi eroarea:
```
Status 500: Azure OpenAI is not configured. Please set AzureOpenAI:Endpoint and AzureOpenAI:ApiKey in appsettings.json
```

Aceasta înseamnă că aplicația hostată în Azure nu are configurate Azure App Settings.

## Soluție: Configurare Azure App Settings

### Pasul 1: Accesează Azure Portal

1. Mergi la: https://portal.azure.com
2. Autentifică-te cu contul tău Azure

### Pasul 2: Găsește App Service-ul

1. În bara de căutare din partea de sus, caută numele App Service-ului (ex: `moneyshop-app`)
2. Click pe App Service-ul tău din rezultate

**SAU**

1. Click pe **App Services** din meniul din stânga
2. Găsește și click pe App Service-ul tău din listă

### Pasul 3: Accesează Configuration

1. În meniul din stânga al App Service-ului, click pe **Configuration**
2. Sau click pe **Settings** → **Configuration**

### Pasul 4: Adaugă Application Settings

1. Click pe tab-ul **Application settings** (dacă nu este deja selectat)
2. Click pe butonul **+ New application setting** (sau **+ Add new application setting**)

### Pasul 5: Adaugă Fiecare Setare

Adaugă următoarele 4 setări (una câte una):

#### Setarea 1: Endpoint

1. Click **+ New application setting**
2. **Name:** `AzureOpenAI__Endpoint`
   - ⚠️ **IMPORTANT:** Folosește `__` (două underscore-uri), NU `:`
3. **Value:** `https://openaimoneyshop.openai.azure.com`
   - (sau endpoint-ul tău Azure OpenAI)
4. Click **OK**

#### Setarea 2: API Key

1. Click **+ New application setting**
2. **Name:** `AzureOpenAI__ApiKey`
   - ⚠️ **IMPORTANT:** Folosește `__` (două underscore-uri)
3. **Value:** Cheia ta API Azure OpenAI
   - Obține-o din: Azure Portal → Azure OpenAI resource → Keys and Endpoint
4. Click **OK**

#### Setarea 3: Deployment Name

1. Click **+ New application setting**
2. **Name:** `AzureOpenAI__DeploymentName`
3. **Value:** `gpt-4o-mini`
4. Click **OK**

#### Setarea 4: API Version

1. Click **+ New application setting**
2. **Name:** `AzureOpenAI__ApiVersion`
3. **Value:** `2024-02-15-preview`
4. Click **OK**

### Pasul 6: Salvează Configurarea

1. După ce ai adăugat toate cele 4 setări, click pe butonul **Save** din partea de sus
2. Apare un popup care te întreabă dacă vrei să restartezi aplicația
3. Click **Continue** pentru a restarta aplicația
4. Așteaptă 1-2 minute pentru ca aplicația să se repornească

### Pasul 7: Verifică Configurarea

După restart, ar trebui să vezi în lista de Application settings:

```
AzureOpenAI__Endpoint = https://openaimoneyshop.openai.azure.com
AzureOpenAI__ApiKey = [hidden]
AzureOpenAI__DeploymentName = gpt-4o-mini
AzureOpenAI__ApiVersion = 2024-02-15-preview
```

## Verificare Finală

1. Accesează aplicația: `https://your-app-name.azurewebsites.net/openai-plugin`
2. Click pe "Get Plugin Info" - ar trebui să funcționeze
3. Testează un prompt - ar trebui să returneze un rezumat

## Obținere Azure OpenAI API Key

Dacă nu ai cheia API:

1. Mergi la Azure Portal: https://portal.azure.com
2. Caută **Azure OpenAI** în bara de căutare
3. Selectează resource-ul tău Azure OpenAI
4. În meniul din stânga, click pe **Keys and Endpoint**
5. Copiază **KEY 1** sau **KEY 2**
6. Folosește-o ca valoare pentru `AzureOpenAI__ApiKey`

## Troubleshooting

### Eroarea persistă după configurare?

1. **Verifică că ai folosit `__` (două underscore-uri) în loc de `:`**
   - ✅ Corect: `AzureOpenAI__Endpoint`
   - ❌ Greșit: `AzureOpenAI:Endpoint`

2. **Verifică că ai salvat și restartat aplicația**
   - Azure Portal → App Service → Overview → **Restart**

3. **Verifică că endpoint-ul este corect**
   - Trebuie să fie de forma: `https://your-resource.openai.azure.com`
   - Fără trailing slash (`/`)

4. **Verifică că API Key-ul este valid**
   - Testează-l direct în Azure Portal → Azure OpenAI → Keys and Endpoint

5. **Verifică logurile aplicației**
   - Azure Portal → App Service → **Log stream**
   - Sau: **Monitoring** → **Log stream**

### Eroare 502 Bad Gateway?

- Verifică că deployment-ul `gpt-4o-mini` există în Azure OpenAI
- Azure Portal → Azure OpenAI → **Deployments**
- Dacă nu există, creează-l:
  - Click **+ Create**
  - **Model:** `gpt-4o-mini`
  - **Deployment name:** `gpt-4o-mini`
  - Click **Create**

## Configurare Rapidă cu Azure CLI

Dacă preferi să folosești Azure CLI în loc de UI:

```bash
# Setează variabilele
RESOURCE_GROUP="MoneyShop"
APP_SERVICE_NAME="moneyshop-app"
AZURE_OPENAI_ENDPOINT="https://openaimoneyshop.openai.azure.com"
AZURE_OPENAI_API_KEY="your-api-key-here"

# Configurează App Settings
az webapp config appsettings set \
  --resource-group "$RESOURCE_GROUP" \
  --name "$APP_SERVICE_NAME" \
  --settings \
    AzureOpenAI__Endpoint="$AZURE_OPENAI_ENDPOINT" \
    AzureOpenAI__ApiKey="$AZURE_OPENAI_API_KEY" \
    AzureOpenAI__DeploymentName="gpt-4o-mini" \
    AzureOpenAI__ApiVersion="2024-02-15-preview"

# Restart aplicația
az webapp restart \
  --resource-group "$RESOURCE_GROUP" \
  --name "$APP_SERVICE_NAME"
```

## Structura Finală a App Settings

După configurare, în Azure Portal ar trebui să vezi:

| Name | Value |
|------|-------|
| `AzureOpenAI__Endpoint` | `https://openaimoneyshop.openai.azure.com` |
| `AzureOpenAI__ApiKey` | `[hidden]` |
| `AzureOpenAI__DeploymentName` | `gpt-4o-mini` |
| `AzureOpenAI__ApiVersion` | `2024-02-15-preview` |

---

**Notă:** După configurare și restart, aplicația ar trebui să funcționeze corect!

