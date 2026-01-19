# Azure OpenAI Plugin - MoneyShop

## Descriere

Acest plugin implementează un serviciu Azure OpenAI compatibil cu specificația OpenAI Plugin pentru Homework 4. Plugin-ul oferă funcționalitate de sumarizare text folosind Azure OpenAI.

**IMPORTANT**: Acest plugin este complet separat de funcționalitatea existentă de chat (ChatController) și nu interferează cu codul existent.

## Funcționalitate

Plugin-ul este un **Text Summarizer** care:
- Acceptă text lung prin prompt
- Folosește Azure OpenAI pentru generarea răspunsului
- Returnează un rezumat clar și concis al textului

## Accesare Plugin

### Interfață Web (Recomandat pentru testare)

Pentru testare ușoară, există o pagină web disponibilă la:

```
/openai-plugin
```

Această pagină oferă:
- Buton pentru a obține informații despre plugin
- Formular pentru testarea prompt-urilor
- Afișare rezultate și erori
- Interfață prietenoasă, fără necesitatea de a folosi Swagger sau Postman

### Endpoint-uri API

### 1. GET /api/openai-plugin/info

Returnează informații despre plugin.

**Request:**
```http
GET /api/openai-plugin/info
```

**Response (200 OK):**
```json
{
  "name": "MoneyShop Text Summarizer Plugin",
  "description": "Summarizes the text received through the prompt using Azure OpenAI",
  "version": "1.0.0"
}
```

### 2. POST /api/openai-plugin/prompt

Procesează un prompt și returnează răspunsul generat de Azure OpenAI.

**Request:**
```http
POST /api/openai-plugin/prompt
Content-Type: application/json

{
  "prompt": "Textul lung pe care vrei să-l sumarizezi aici..."
}
```

**Response (200 OK):**
```json
{
  "result": "Rezumatul generat de Azure OpenAI...",
  "model": "gpt-4o-mini",
  "success": true
}
```

## Configurare Azure OpenAI

### 1. Obținere Credențiale Azure OpenAI

1. Accesează Azure Portal: https://portal.azure.com
2. Creează sau accesează un **Azure OpenAI** resource
3. Obține:
   - **Endpoint**: URL-ul resource-ului (ex: `https://your-resource.openai.azure.com`)
   - **API Key**: Cheia API din secțiunea "Keys and Endpoint"
   - **Deployment Name**: Numele deployment-ului modelului (ex: `gpt-4o-mini`)

### 2. Configurare în appsettings.json

Editează `MoneyShop/appsettings.json` sau `MoneyShop/appsettings.Development.json`:

```json
{
  "AzureOpenAI": {
    "Endpoint": "https://your-resource.openai.azure.com",
    "ApiKey": "your-api-key-here",
    "DeploymentName": "gpt-4o-mini",
    "ApiVersion": "2024-02-15-preview"
  }
}
```

**IMPORTANT**: Nu hardcode-uiți secretele în cod! Folosește:
- Azure App Settings pentru deployment
- Azure Key Vault pentru producție
- User Secrets pentru development local

### 3. Configurare Azure App Service (pentru deployment)

Dacă aplicația este deployată pe Azure App Service, adaugă următoarele App Settings:

```
AzureOpenAI__Endpoint = https://your-resource.openai.azure.com
AzureOpenAI__ApiKey = your-api-key-here
    AzureOpenAI__DeploymentName = gpt-4o-mini
AzureOpenAI__ApiVersion = 2024-02-15-preview
```

## Model și Deployment Azure OpenAI

- **Model folosit**: `gpt-4o-mini` (configurabil prin `DeploymentName`) - cel mai ieftin model disponibil
- **API Version**: `2024-02-15-preview` (configurabil prin `ApiVersion`)
- **Max Tokens**: 500 (hardcoded în serviciu, poate fi făcut configurabil)
- **Temperature**: 0.7 (hardcoded în serviciu, poate fi făcut configurabil)

## Error Handling

Plugin-ul implementează error handling complet pentru următoarele cazuri:

### 1. Invalid or Empty Prompt

**Status Code**: `400 Bad Request`

**Response:**
```json
{
  "error": "Invalid request",
  "message": "Prompt cannot be empty or null. Please provide a valid prompt in the request body."
}
```

**Cum să declanșezi**: Trimite un request cu `prompt` gol sau null:
```json
{
  "prompt": ""
}
```

### 2. Azure OpenAI Request Failure

**Status Code**: `502 Bad Gateway`

**Response:**
```json
{
  "error": "Azure OpenAI request failed",
  "message": "Failed to communicate with Azure OpenAI service. Please check the configuration and try again."
}
```

**Cum să declanșezi**: 
- Configurează un endpoint invalid în appsettings
- Sau folosește un API key invalid

### 3. Configuration Error

**Status Code**: `500 Internal Server Error`

**Response:**
```json
{
  "error": "Configuration error",
  "message": "Azure OpenAI is not configured. Please set AzureOpenAI:Endpoint and AzureOpenAI:ApiKey in appsettings.json"
}
```

**Cum să declanșezi**: Lasă `Endpoint` sau `ApiKey` gol în appsettings

### 4. Internal Server Error

**Status Code**: `500 Internal Server Error`

**Response:**
```json
{
  "error": "Internal server error",
  "message": "An unexpected error occurred while processing your request."
}
```

## Deployment

### Deployment pe Azure App Service

1. **Creează Azure OpenAI Resource** (dacă nu există deja)
2. **Configurează App Settings** în Azure Portal cu credențialele Azure OpenAI
3. **Deploy aplicația** folosind Azure DevOps, GitHub Actions, sau Azure CLI

### Deployment Script (Azure CLI)

Exemplu de script pentru deployment:

```bash
#!/bin/bash

# Variables
RESOURCE_GROUP="moneyshop-rg"
APP_SERVICE_NAME="moneyshop-app"
AZURE_OPENAI_ENDPOINT="https://your-resource.openai.azure.com"
AZURE_OPENAI_API_KEY="your-api-key"

# Set App Settings
az webapp config appsettings set \
  --resource-group $RESOURCE_GROUP \
  --name $APP_SERVICE_NAME \
  --settings \
    AzureOpenAI__Endpoint=$AZURE_OPENAI_ENDPOINT \
    AzureOpenAI__ApiKey=$AZURE_OPENAI_API_KEY \
    AzureOpenAI__DeploymentName="gpt-4o-mini" \
    AzureOpenAI__ApiVersion="2024-02-15-preview"

# Deploy (exemplu cu zip deploy)
# az webapp deployment source config-zip \
#   --resource-group $RESOURCE_GROUP \
#   --name $APP_SERVICE_NAME \
#   --src app.zip
```

## Public API URL

După deployment, API-ul va fi accesibil la:

```
https://your-app-service.azurewebsites.net/api/openai-plugin/info
https://your-app-service.azurewebsites.net/api/openai-plugin/prompt
```

## Exemple de Request/Response

### Exemplu 1: Info Endpoint

**Request:**
```bash
curl -X GET https://your-app.azurewebsites.net/api/openai-plugin/info
```

**Response:**
```json
{
  "name": "MoneyShop Text Summarizer Plugin",
  "description": "Summarizes the text received through the prompt using Azure OpenAI",
  "version": "1.0.0"
}
```

### Exemplu 2: Prompt Endpoint - Succes

**Request:**
```bash
curl -X POST https://your-app.azurewebsites.net/api/openai-plugin/prompt \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Azure OpenAI este un serviciu cloud care oferă acces la modele de inteligență artificială dezvoltate de OpenAI. Acesta permite dezvoltatorilor să integreze capabilități de AI în aplicațiile lor folosind infrastructura Azure. Serviciul oferă modele precum GPT-4, GPT-3.5, și DALL-E pentru generare de text și imagini."
  }'
```

**Response:**
```json
{
  "result": "Azure OpenAI este un serviciu cloud care permite dezvoltatorilor să integreze modele AI (precum GPT-4, GPT-3.5, DALL-E) în aplicațiile lor folosind infrastructura Azure pentru generare de text și imagini.",
  "model": "gpt-4o-mini",
  "success": true
}
```

### Exemplu 3: Prompt Endpoint - Eroare (Prompt gol)

**Request:**
```bash
curl -X POST https://your-app.azurewebsites.net/api/openai-plugin/prompt \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": ""
  }'
```

**Response (400 Bad Request):**
```json
{
  "error": "Invalid request",
  "message": "Prompt cannot be empty or null. Please provide a valid prompt in the request body."
}
```

## Arhitectură

Plugin-ul este implementat ca un modul separat:

```
BusinessLogic/Implementation/OpenAIPlugin/
  └── AzureOpenAIPluginService.cs    # Serviciu pentru Azure OpenAI

MoneyShop/Controllers/
  ├── Api/
  │   └── OpenAIPluginController.cs      # API Controller cu endpoint-urile /info și /prompt
  └── OpenAIPluginWebController.cs       # Web Controller pentru interfața web

MoneyShop/Views/OpenAIPlugin/
  └── Index.cshtml                       # Pagină web pentru testare
```

**Separare de codul existent:**
- Nu interferează cu `ChatController` existent
- Nu interferează cu `OpenAIChatService` existent
- Folosește configurare separată (`AzureOpenAI` vs `OpenAI`)
- Endpoint-uri separate (`/api/openai-plugin/*` vs `/api/chat`)

## Testing

### Test Local

1. Configurează `appsettings.Development.json` cu credențialele Azure OpenAI
2. Rulează aplicația: `dotnet run`
3. **Opțiune 1 - Interfață Web (Recomandat):**
   - Accesează: `https://localhost:7093/openai-plugin`
   - Folosește interfața web pentru a testa plugin-ul
4. **Opțiune 2 - API Direct:**
   - Testează endpoint-urile:
     - `GET http://localhost:5000/api/openai-plugin/info`
     - `POST http://localhost:5000/api/openai-plugin/prompt`

### Test cu Postman/curl

Vezi exemplele de mai sus pentru request-uri complete.

## Securitate

- **API Key**: Nu este hardcodat, folosește configurare prin environment variables
- **HTTPS**: Folosește HTTPS în producție
- **Error Messages**: Nu expune detalii sensibile în mesajele de eroare
- **Rate Limiting**: Poate fi adăugat dacă este necesar

## Limitări

- Nu necesită autentificare (poate fi adăugată dacă este necesar)
- Max tokens este hardcoded la 500 (poate fi făcut configurabil)
- Temperature este hardcoded la 0.7 (poate fi făcut configurabil)

## Dezvoltări Viitoare

- Adăugare autentificare (JWT, API Key)
- Configurare max_tokens și temperature prin appsettings
- Rate limiting
- Logging mai detaliat
- Metrics și monitoring

## Suport

Pentru probleme sau întrebări:
- Verifică logurile aplicației
- Verifică configurarea Azure OpenAI în appsettings
- Verifică că Azure OpenAI resource-ul este activ și accesibil

---

**Data**: 2026-01-15  
**Versiune**: 1.0.0  
**Status**: Implementat și gata pentru deployment

