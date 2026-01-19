# Integrare Oblio API pentru Generare Facturi

Această documentație descrie integrarea API-ului Oblio în aplicația MoneyShop pentru generarea de facturi, proforme și avize.

## Configurare

### 1. Obținere Credențiale Oblio

1. Accesează contul tău Oblio: https://www.oblio.eu
2. Mergi la **Setări** > **Date Cont**
3. Copiază **Client ID** (email-ul cu care te autentifici) și **Client Secret** (token-ul generat)

### 2. Configurare Backend

Editează `MoneyShop/appsettings.json` și adaugă credențialele Oblio:

```json
{
  "Oblio": {
    "ClientId": "email@exemplu.com",
    "ClientSecret": "token-ul-tau-oblio"
  }
}
```

**Notă:** Token-ul `ClientSecret` se regenerează automat când resetezi parola în Oblio. Va trebui să actualizezi configurația după resetarea parolei.

## Funcționalități Disponibile

### Backend API Endpoints

Toate endpoint-urile necesită autentificare (JWT token).

#### Nomenclatoare

- `GET /api/oblio/companies` - Obține lista de companii asociate cu contul
- `GET /api/oblio/vat-rates?cif=RO12345678` - Obține cotele TVA pentru o firmă
- `GET /api/oblio/clients?cif=RO12345678&name=Client&offset=0` - Obține lista de clienți
- `GET /api/oblio/products?cif=RO12345678&name=Produs&offset=0` - Obține lista de produse

#### Documente

- `POST /api/oblio/invoice?cif=RO12345678` - Emite o factură
- `POST /api/oblio/proforma?cif=RO12345678` - Emite o proformă
- `GET /api/oblio/document?cif=RO12345678&seriesName=FCT&number=1&type=pdf` - Descarcă documentul (PDF)
- `DELETE /api/oblio/document?cif=RO12345678&seriesName=FCT&number=1&type=invoice` - Anulează un document
- `POST /api/oblio/document/restore?cif=RO12345678&seriesName=FCT&number=1&type=invoice` - Restaurează un document anulat
- `DELETE /api/oblio/document/delete?cif=RO12345678&seriesName=FCT&number=1&type=invoice` - Șterge un document

### Frontend (React Native)

Serviciul `oblioApi` este disponibil în `MoneyShopMobile/src/services/api/oblioApi.ts`.

#### Exemplu de utilizare:

```typescript
import {oblioApi} from '../services/api/oblioApi';

// Obține companiile
const companies = await oblioApi.getCompanies();

// Obține clienții
const clients = await oblioApi.getClients('RO12345678', 'Nume Client');

// Creează o factură
const invoice = await oblioApi.createInvoice('RO12345678', {
  cachedName: {name: 'Client Test'},
  client: {
    cif: 'RO12345678',
    name: 'Client Test SRL',
    address: 'Str. Exemplu, Nr. 1',
    city: 'București',
    state: 'București',
    country: 'România',
    vatPayer: true
  },
  issueDate: '2026-01-15',
  dueDate: '2026-02-15',
  deliveryDate: '2026-01-15',
  collectDate: '2026-01-15',
  seriesName: 'FCT',
  language: 'RO',
  currency: 'RON',
  products: [
    {
      name: 'Serviciu Test',
      price: 1000,
      vatPercentage: 19,
      quantity: 1,
      measuringUnit: 'buc'
    }
  ]
});

// Descarcă factura PDF
const pdfBlob = await oblioApi.getDocument('RO12345678', 'FCT', invoice.data.number);
```

## Limitări API Oblio

Conform documentației Oblio:
- **30 de cereri la 100 de secunde** pentru cererile care genereaza documente (facturi, proforme etc.)
- **30 de cereri la 10 secunde** pentru orice tip de cerere care nu presupune generarea unui document

Token-ul de acces OAuth 2.0 expiră după 3600 de secunde (1 oră) și este reînnoit automat de serviciu.

## Documentație Completă

Pentru documentația completă a API-ului Oblio, vezi: https://www.oblio.eu/api

Pentru exemple de implementare, vezi: https://github.com/OblioSoftware

## Securitate

- Credențialele Oblio (`ClientId` și `ClientSecret`) trebuie păstrate în siguranță
- Nu comite aceste valori în repository-ul Git
- Folosește Azure Key Vault sau variabile de mediu pentru producție
- Toate endpoint-urile API necesită autentificare JWT

## Suport

Pentru probleme tehnice cu API-ul Oblio, contactează:
- Email: contact@oblio.eu
- Telefon: 0800 831 333
- Documentație: https://www.oblio.eu/api

