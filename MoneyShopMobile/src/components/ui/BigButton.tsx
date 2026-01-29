import React from 'react';
import {
  TouchableOpacity,
  Text,
  StyleSheet,
  ActivityIndicator,
  View,
  ViewStyle,
  TextStyle,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import { colors, spacing, borderRadius, typography, shadows } from '../../theme/designSystem';

interface BigButtonProps {
  title: string;
  subtitle?: string;
  onPress: () => void;
  variant?: 'primary' | 'secondary' | 'success' | 'outline' | 'ghost';
  icon?: string;
  iconPosition?: 'left' | 'right';
  loading?: boolean;
  disabled?: boolean;
  fullWidth?: boolean;
  style?: ViewStyle;
  textStyle?: TextStyle;
}

/**
 * BigButton - Buton mare pentru UX accesibil (18-70 ani)
 * 
 * Principii:
 * - Țintă mare pentru atingere (min 56px)
 * - Text clar și lizibil
 * - Feedback vizual clar
 * - Subtitle opțional pentru clarificări
 */
const BigButton: React.FC<BigButtonProps> = ({
  title,
  subtitle,
  onPress,
  variant = 'primary',
  icon,
  iconPosition = 'left',
  loading = false,
  disabled = false,
  fullWidth = true,
  style,
  textStyle,
}) => {
  const getVariantStyles = () => {
    switch (variant) {
      case 'primary':
        return {
          container: styles.primaryContainer,
          text: styles.primaryText,
          iconColor: '#FFFFFF',
        };
      case 'secondary':
        return {
          container: styles.secondaryContainer,
          text: styles.secondaryText,
          iconColor: colors.primary[500],
        };
      case 'success':
        return {
          container: styles.successContainer,
          text: styles.successText,
          iconColor: '#FFFFFF',
        };
      case 'outline':
        return {
          container: styles.outlineContainer,
          text: styles.outlineText,
          iconColor: colors.primary[500],
        };
      case 'ghost':
        return {
          container: styles.ghostContainer,
          text: styles.ghostText,
          iconColor: colors.primary[500],
        };
      default:
        return {
          container: styles.primaryContainer,
          text: styles.primaryText,
          iconColor: '#FFFFFF',
        };
    }
  };

  const variantStyles = getVariantStyles();

  return (
    <TouchableOpacity
      onPress={onPress}
      disabled={disabled || loading}
      activeOpacity={0.8}
      style={[
        styles.container,
        variantStyles.container,
        fullWidth && styles.fullWidth,
        disabled && styles.disabled,
        style,
      ]}>
      {loading ? (
        <ActivityIndicator
          color={variantStyles.iconColor}
          size="small"
        />
      ) : (
        <View style={styles.content}>
          {icon && iconPosition === 'left' && (
            <Icon
              name={icon}
              size={24}
              color={variantStyles.iconColor}
              style={styles.iconLeft}
            />
          )}
          <View style={styles.textContainer}>
            <Text style={[styles.title, variantStyles.text, textStyle]}>
              {title}
            </Text>
            {subtitle && (
              <Text style={[styles.subtitle, { color: variantStyles.iconColor }]}>
                {subtitle}
              </Text>
            )}
          </View>
          {icon && iconPosition === 'right' && (
            <Icon
              name={icon}
              size={24}
              color={variantStyles.iconColor}
              style={styles.iconRight}
            />
          )}
        </View>
      )}
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    minHeight: 60,
    borderRadius: borderRadius.lg,
    paddingHorizontal: spacing.xl,
    paddingVertical: spacing.md,
    justifyContent: 'center',
    alignItems: 'center',
    ...shadows.md,
  },
  fullWidth: {
    width: '100%',
  },
  disabled: {
    opacity: 0.5,
  },
  content: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  textContainer: {
    alignItems: 'center',
  },
  title: {
    ...typography.labelLarge,
    textAlign: 'center',
  },
  subtitle: {
    ...typography.caption,
    marginTop: 2,
    opacity: 0.8,
  },
  iconLeft: {
    marginRight: spacing.sm,
  },
  iconRight: {
    marginLeft: spacing.sm,
  },
  // Variants
  primaryContainer: {
    backgroundColor: colors.primary[500],
  },
  primaryText: {
    color: '#FFFFFF',
  },
  secondaryContainer: {
    backgroundColor: colors.primary[50],
  },
  secondaryText: {
    color: colors.primary[700],
  },
  successContainer: {
    backgroundColor: colors.success[500],
  },
  successText: {
    color: '#FFFFFF',
  },
  outlineContainer: {
    backgroundColor: 'transparent',
    borderWidth: 2,
    borderColor: colors.primary[500],
  },
  outlineText: {
    color: colors.primary[500],
  },
  ghostContainer: {
    backgroundColor: 'transparent',
    elevation: 0,
    shadowOpacity: 0,
  },
  ghostText: {
    color: colors.primary[500],
  },
});

export default BigButton;

