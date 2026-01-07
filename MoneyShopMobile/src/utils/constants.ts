// API Configuration
// Backend runs on https://localhost:7093 (HTTPS) or http://localhost:5259 (HTTP)
// For physical devices, replace 'localhost' with your computer's local IP address
// Find your IP: Windows: ipconfig | findstr IPv4 | Mac/Linux: ifconfig | grep inet
// Example: 'https://192.168.1.100:7093/api'

// Set this to your computer's local IP when testing on physical device
// Leave empty to use localhost (works for web/simulator only)
// To find your IP: Windows: ipconfig | findstr IPv4
const LOCAL_IP = ''; // Example: '10.67.144.35' or leave empty for localhost

const getApiBaseUrl = () => {
  // Check for production API URL from environment variable
  // Set this in Azure Static Web Apps or deployment environment
  if (typeof process !== 'undefined' && process.env?.EXPO_PUBLIC_API_URL) {
    return process.env.EXPO_PUBLIC_API_URL;
  }

  // Production fallback (if not in dev mode)
  if (!__DEV__) {
    // Default production URL - update this with your Azure App Service URL
    return 'https://moneyshop20260107220205-adbnf8c7a2fec4d4.azurewebsites.net/api';
  }

  // If LOCAL_IP is set, use it (for physical devices)
  // Use HTTP instead of HTTPS for local IP to avoid SSL certificate issues
  if (LOCAL_IP) {
    return `http://${LOCAL_IP}:5259/api`;
  }

  // Default to localhost (works for web browser and simulators)
  return 'https://localhost:7093/api';
};

export const API_BASE_URL = getApiBaseUrl();

// Storage Keys
export const STORAGE_KEYS = {
  AUTH_TOKEN: '@moneyshop:auth_token',
  USER_DATA: '@moneyshop:user_data',
};

// Application Statuses
export const APPLICATION_STATUS = {
  INREGISTRAT: 'INREGISTRAT',
  IN_ANALIZA: 'IN_ANALIZA',
  NEVOIE_DOCUMENTE: 'NEVOIE_DOCUMENTE',
  PREAPROBAT: 'PREAPROBAT',
  RESPINS: 'RESPINS',
  OFERTA_TRANSMISA: 'OFERTA_TRANSMISA',
  ACCEPTAT_CLIENT: 'ACCEPTAT_CLIENT',
  TRIMIS_LA_BANCA: 'TRIMIS_LA_BANCA',
  APROBAT_BANCA: 'APROBAT_BANCA',
  DISBURSAT: 'DISBURSAT',
};

// Credit Types
export const CREDIT_TYPES = {
  IPOTECAR: 'ipotecar',
  NEVOI_PERSONALE: 'nevoi_personale',
};

// Operation Types
export const OPERATION_TYPES = {
  NOU: 'nou',
  REFINANTARE: 'refinantare',
};

