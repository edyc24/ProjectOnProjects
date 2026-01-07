import {apiClient} from './apiClient';
import {Platform} from 'react-native';

export interface KycSession {
  kycId: string;
  status: 'pending' | 'verified' | 'rejected' | 'expired';
  createdAt: string;
  expiresAt: string;
  verifiedAt?: string;
  rejectionReason?: string;
  files?: KycFile[];
}

export interface KycFile {
  fileId: string;
  fileType: string;
  fileName: string;
  createdAt: string;
}

export interface KycPending {
  kycId: string;
  userId: number;
  userName: string;
  userEmail: string;
  kycType: string;
  createdAt: string;
  expiresAt: string;
  fileCount: number;
}

export interface KycDetails {
  kycId: string;
  userId: number;
  userName: string;
  userEmail: string;
  status: string;
  createdAt: string;
  expiresAt: string;
  rejectionReason?: string;
  files: KycFileDetail[];
}

export interface KycFileDetail {
  fileId: string;
  fileType: string;
  fileName: string;
  blobPath?: string; // Deprecated, kept for backward compatibility
  fileContentBase64?: string; // Base64 encoded file content
  mimeType: string;
  dataUri?: string; // data:image/jpeg;base64,... format for easy display
  createdAt: string;
}

export const kycApi = {
  // Start a new KYC session
  startSession: async (kycType: string = 'USER_KYC'): Promise<KycSession> => {
    console.log('startSession called with kycType:', kycType);
    try {
      const response = await apiClient.post('/kyc/start', {kycType});
      console.log('startSession response:', {
        status: response.status,
        data: response.data,
        kycId: response.data?.kycId,
      });
      
      // Ensure kycId is present
      if (!response.data || !response.data.kycId) {
        console.error('Invalid startSession response:', response.data);
        throw new Error('Failed to start KYC session: kycId missing in response');
      }
      
      return response.data;
    } catch (error: any) {
      console.error('startSession error:', error);
      console.error('Error details:', {
        status: error.response?.status,
        data: error.response?.data,
        message: error.message,
      });
      throw error;
    }
  },

  // Upload a file for KYC
  uploadFile: async (
    kycId: string,
    fileType: string,
    file: {
      uri: string;
      type: string;
      name: string;
    },
  ): Promise<KycFile> => {
    console.log('[kycApi] uploadFile - Starting upload', {
      kycId,
      fileType,
      fileName: file.name,
      mimeType: file.type,
      uriType: file.uri.startsWith('data:') ? 'data-uri' : file.uri.startsWith('file://') ? 'file-uri' : 'url',
    });

    const formData = new FormData();
    formData.append('kycId', kycId);
    formData.append('fileType', fileType);
    
    // Prepare file for upload
    // Web: Convert data URI to File object (FormData requirement)
    // Mobile: Use URI directly (React Native FormData handles it)
    let fileToUpload: any;
    
    if (Platform.OS === 'web') {
      // Web platform
      if (file.uri.startsWith('data:')) {
        // Data URI - convert to File object
        const match = file.uri.match(/^data:([^;]+);base64,(.+)$/);
        if (!match) {
          throw new Error('Invalid data URI format');
        }
        
        const mimeType = match[1] || file.type || 'image/jpeg';
        const base64Data = match[2];
        
        // Decode base64 to binary
        const binaryString = atob(base64Data);
        const bytes = new Uint8Array(binaryString.length);
        for (let i = 0; i < binaryString.length; i++) {
          bytes[i] = binaryString.charCodeAt(i);
        }
        
        // Create File object
        fileToUpload = new File([bytes], file.name || 'image.jpg', { type: mimeType });
        console.log('[kycApi] Web: Converted data URI to File object');
      } else {
        // Regular URL - fetch and create File
        try {
          const response = await fetch(file.uri);
          const blob = await response.blob();
          fileToUpload = new File([blob], file.name || 'image.jpg', {
            type: file.type || 'image/jpeg',
          });
          console.log('[kycApi] Web: Created File from URL');
        } catch (error) {
          console.error('[kycApi] Web: Failed to fetch URL:', error);
          throw new Error('Failed to process image file');
        }
      }
    } else {
      // Mobile platform (iOS/Android)
      // React Native FormData accepts {uri, type, name} directly
      fileToUpload = {
        uri: file.uri,
        type: file.type || 'image/jpeg',
        name: file.name || 'image.jpg',
      };
      console.log('[kycApi] Mobile: Using URI object directly');
    }
    
    formData.append('file', fileToUpload);

    try {
      console.log('[kycApi] Sending FormData to backend');
      const response = await apiClient.post('/kyc/upload', formData);
      console.log('[kycApi] Upload successful:', response.data);
      return response.data;
    } catch (error: any) {
      console.error('[kycApi] Upload failed:', {
        message: error.message,
        status: error.response?.status,
        data: error.response?.data,
      });
      throw error;
    }
  },

  // Get KYC status for current user
  getStatus: async (kycType: string = 'USER_KYC'): Promise<KycSession> => {
    const response = await apiClient.get(`/kyc/status?kycType=${kycType}`);
    return response.data;
  },

  // Update KYC form data
  updateFormData: async (
    kycId: string,
    formData: {
      cnp?: string;
      address?: string;
      city?: string;
      county?: string;
      postalCode?: string;
    },
  ): Promise<void> => {
    console.log('updateFormData called with:', {kycId, formData});
    
    // Validate kycId
    if (!kycId || kycId === 'undefined' || kycId === 'null') {
      console.error('Invalid kycId:', kycId);
      throw new Error('KycId is required');
    }
    
    try {
      const requestData = {
        kycId: kycId, // Ensure it's sent as string, backend will parse it as Guid
        cnp: formData.cnp,
        address: formData.address,
        city: formData.city,
        county: formData.county,
        postalCode: formData.postalCode,
      };
      
      console.log('Sending request data:', requestData);
      
      const response = await apiClient.post('/kyc/update-form-data', requestData);
      
      console.log('updateFormData response:', {
        status: response.status,
        statusText: response.statusText,
        data: response.data,
        headers: response.headers,
      });
      
      // Check if response is empty (204 No Content)
      if (response.status === 204 || !response.data) {
        console.warn('Received 204 No Content or empty response');
      }
    } catch (error: any) {
      console.error('updateFormData error:', error);
      console.error('Error details:', {
        status: error.response?.status,
        statusText: error.response?.statusText,
        data: error.response?.data,
        message: error.message,
        config: {
          url: error.config?.url,
          method: error.config?.method,
          data: error.config?.data,
        },
      });
      throw error;
    }
  },

  // Admin: Get all pending KYC sessions
  getAllPending: async (): Promise<KycPending[]> => {
    const response = await apiClient.get('/kyc/pending');
    // Ensure we always return an array
    return Array.isArray(response.data) ? response.data : [];
  },

  // Admin: Get KYC details
  getDetails: async (kycId: string): Promise<KycDetails> => {
    const response = await apiClient.get(`/kyc/details/${kycId}`);
    return response.data;
  },

  // Admin: Get KYC file (returns base64 data)
  getFile: async (fileId: string): Promise<{fileContentBase64: string; dataUri: string; mimeType: string; fileName: string}> => {
    const response = await apiClient.get(`/kyc/file/${fileId}`);
    return response.data;
  },

  // Admin: Update KYC status
  updateStatus: async (
    kycId: string,
    status: 'verified' | 'rejected',
    rejectionReason?: string,
  ): Promise<void> => {
    console.log('[kycApi] updateStatus called:', { kycId, status, rejectionReason });
    try {
      const response = await apiClient.post('/kyc/update-status', {
        kycId,
        status,
        rejectionReason,
      });
      console.log('[kycApi] updateStatus response:', response.data);
    } catch (error: any) {
      console.error('[kycApi] updateStatus error:', {
        message: error.message,
        status: error.response?.status,
        data: error.response?.data,
      });
      throw error;
    }
  },
};

