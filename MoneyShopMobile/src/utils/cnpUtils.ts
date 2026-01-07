/**
 * Utility functions for CNP (Romanian Personal Numeric Code) handling
 * CNP is never stored in plain text - only masked versions are displayed
 */

/**
 * Masks CNP for display (e.g., ******5579)
 * @param cnpLast4 Last 4 digits of CNP
 * @returns Masked CNP string
 */
export const maskCnp = (cnpLast4?: string | null): string => {
  if (!cnpLast4 || cnpLast4.length !== 4) {
    return '******';
  }
  return `******${cnpLast4}`;
};

/**
 * Validates CNP format (basic validation)
 * @param cnp CNP string to validate
 * @returns true if format is valid
 */
export const isValidCnpFormat = (cnp: string): boolean => {
  // CNP should be 13 digits
  if (!cnp || cnp.length !== 13) {
    return false;
  }
  
  // Should contain only digits
  return /^\d{13}$/.test(cnp);
};

/**
 * Formats CNP for display (masked)
 * @param cnp CNP string (will be masked)
 * @returns Masked CNP
 */
export const formatCnpForDisplay = (cnp?: string | null): string => {
  if (!cnp) {
    return '******';
  }
  
  // If already masked, return as is
  if (cnp.includes('*')) {
    return cnp;
  }
  
  // Mask all but last 4 digits
  if (cnp.length >= 4) {
    return maskCnp(cnp.substring(cnp.length - 4));
  }
  
  return '******';
};

