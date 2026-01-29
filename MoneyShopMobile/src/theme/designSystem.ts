/**
 * MoneyShop Design System
 * 
 * Principii UX (conform SRS):
 * - 1 ecran = 1 decizie
 * - Text mare, butoane mari
 * - Nu arăta tehnic (hash, logs)
 * - Confirmări clare
 * - UX super simplu (18-70 ani)
 */

// Culori principale - Paleta modernă și profesională
export const colors = {
  // Primary - Albastru profesional
  primary: {
    50: '#E3F2FD',
    100: '#BBDEFB',
    200: '#90CAF9',
    300: '#64B5F6',
    400: '#42A5F5',
    500: '#1976D2', // Main
    600: '#1565C0',
    700: '#0D47A1',
    800: '#0A3D8F',
    900: '#072D6B',
  },
  
  // Success - Verde pentru confirmări pozitive
  success: {
    50: '#E8F5E9',
    100: '#C8E6C9',
    200: '#A5D6A7',
    300: '#81C784',
    400: '#66BB6A',
    500: '#4CAF50', // Main
    600: '#43A047',
    700: '#388E3C',
    800: '#2E7D32',
    900: '#1B5E20',
  },
  
  // Warning - Portocaliu pentru atenție
  warning: {
    50: '#FFF3E0',
    100: '#FFE0B2',
    200: '#FFCC80',
    300: '#FFB74D',
    400: '#FFA726',
    500: '#FF9800', // Main
    600: '#FB8C00',
    700: '#F57C00',
    800: '#EF6C00',
    900: '#E65100',
  },
  
  // Error - Roșu pentru erori
  error: {
    50: '#FFEBEE',
    100: '#FFCDD2',
    200: '#EF9A9A',
    300: '#E57373',
    400: '#EF5350',
    500: '#F44336', // Main
    600: '#E53935',
    700: '#D32F2F',
    800: '#C62828',
    900: '#B71C1C',
  },
  
  // Neutral - Griuri pentru text și fundal
  neutral: {
    0: '#FFFFFF',
    50: '#FAFAFA',
    100: '#F5F5F5',
    200: '#EEEEEE',
    300: '#E0E0E0',
    400: '#BDBDBD',
    500: '#9E9E9E',
    600: '#757575',
    700: '#616161',
    800: '#424242',
    900: '#212121',
  },
  
  // Gradiente pentru fundal
  gradients: {
    primary: ['#1976D2', '#0D47A1'],
    success: ['#4CAF50', '#2E7D32'],
    dark: ['#0B1120', '#1a2332'],
  },
};

// Spațiere consistentă
export const spacing = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
  xxl: 48,
  xxxl: 64,
};

// Fonturi cu dimensiuni mari pentru accesibilitate
export const typography = {
  // Titluri - mari și clare
  h1: {
    fontSize: 32,
    fontWeight: '700' as const,
    lineHeight: 40,
    letterSpacing: -0.5,
  },
  h2: {
    fontSize: 28,
    fontWeight: '700' as const,
    lineHeight: 36,
    letterSpacing: -0.3,
  },
  h3: {
    fontSize: 24,
    fontWeight: '600' as const,
    lineHeight: 32,
    letterSpacing: -0.2,
  },
  h4: {
    fontSize: 20,
    fontWeight: '600' as const,
    lineHeight: 28,
    letterSpacing: 0,
  },
  
  // Body text - lizibil
  bodyLarge: {
    fontSize: 18,
    fontWeight: '400' as const,
    lineHeight: 28,
  },
  bodyMedium: {
    fontSize: 16,
    fontWeight: '400' as const,
    lineHeight: 24,
  },
  bodySmall: {
    fontSize: 14,
    fontWeight: '400' as const,
    lineHeight: 20,
  },
  
  // Labels și butoane
  labelLarge: {
    fontSize: 16,
    fontWeight: '600' as const,
    lineHeight: 24,
    letterSpacing: 0.2,
  },
  labelMedium: {
    fontSize: 14,
    fontWeight: '600' as const,
    lineHeight: 20,
    letterSpacing: 0.1,
  },
  labelSmall: {
    fontSize: 12,
    fontWeight: '600' as const,
    lineHeight: 16,
    letterSpacing: 0.3,
  },
  
  // Caption
  caption: {
    fontSize: 12,
    fontWeight: '400' as const,
    lineHeight: 16,
    letterSpacing: 0.2,
  },
};

// Border radius consistent
export const borderRadius = {
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  xxl: 24,
  full: 999,
};

// Shadows pentru elevație
export const shadows = {
  sm: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 1,
  },
  md: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 8,
    elevation: 3,
  },
  lg: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.12,
    shadowRadius: 16,
    elevation: 6,
  },
  xl: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.16,
    shadowRadius: 24,
    elevation: 12,
  },
};

// Stiluri pentru componente comune
export const componentStyles = {
  // Carduri
  card: {
    backgroundColor: colors.neutral[0],
    borderRadius: borderRadius.xl,
    padding: spacing.lg,
    ...shadows.md,
  },
  
  // Carduri evidențiate
  cardHighlighted: {
    backgroundColor: colors.primary[50],
    borderRadius: borderRadius.xl,
    padding: spacing.lg,
    borderWidth: 2,
    borderColor: colors.primary[200],
    ...shadows.md,
  },
  
  // Butoane mari (pentru 18-70 ani)
  buttonLarge: {
    minHeight: 56,
    borderRadius: borderRadius.lg,
    paddingHorizontal: spacing.xl,
    paddingVertical: spacing.md,
  },
  
  // Butoane medii
  buttonMedium: {
    minHeight: 48,
    borderRadius: borderRadius.md,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.sm,
  },
  
  // Input-uri mari și lizibile
  inputLarge: {
    minHeight: 56,
    borderRadius: borderRadius.lg,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
    fontSize: 18,
  },
  
  // Container pentru ecran
  screenContainer: {
    flex: 1,
    backgroundColor: colors.neutral[50],
  },
  
  // Content padding
  contentPadding: {
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.xl,
  },
  
  // Header section
  headerSection: {
    marginBottom: spacing.xl,
  },
};

// Statusuri vizuale
export const statusColors = {
  active: colors.success[500],
  pending: colors.warning[500],
  expired: colors.warning[600],
  revoked: colors.error[500],
  approved: colors.success[500],
  rejected: colors.error[500],
  processing: colors.primary[500],
};

// Iconuri pentru diferite stări
export const statusIcons = {
  active: 'check-circle',
  pending: 'clock-outline',
  expired: 'calendar-remove',
  revoked: 'close-circle',
  approved: 'check-decagram',
  rejected: 'close-octagon',
  processing: 'progress-clock',
};

// Helper pentru a obține culoarea statusului
export const getStatusColor = (status: string): string => {
  return statusColors[status as keyof typeof statusColors] || colors.neutral[500];
};

// Helper pentru a obține iconul statusului
export const getStatusIcon = (status: string): string => {
  return statusIcons[status as keyof typeof statusIcons] || 'help-circle';
};

export default {
  colors,
  spacing,
  typography,
  borderRadius,
  shadows,
  componentStyles,
  statusColors,
  statusIcons,
  getStatusColor,
  getStatusIcon,
};

