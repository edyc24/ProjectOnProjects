import React from 'react';
import {View, Text, StyleSheet, TouchableOpacity, ViewStyle} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import {colors, spacing, borderRadius, typography, shadows} from '../../theme/designSystem';

interface InfoCardProps {
  title: string;
  value: string | number;
  subtitle?: string;
  icon?: string;
  iconColor?: string;
  iconBackgroundColor?: string;
  variant?: 'default' | 'success' | 'warning' | 'error' | 'primary';
  onPress?: () => void;
  style?: ViewStyle;
  large?: boolean;
}

/**
 * InfoCard - Card informativ clar și vizibil
 * 
 * Folosit pentru afișarea metricilor și informațiilor importante
 * într-un format ușor de înțeles pentru toate vârstele.
 */
const InfoCard: React.FC<InfoCardProps> = ({
  title,
  value,
  subtitle,
  icon,
  iconColor,
  iconBackgroundColor,
  variant = 'default',
  onPress,
  style,
  large = false,
}) => {
  const getVariantStyles = () => {
    switch (variant) {
      case 'success':
        return {
          borderColor: colors.success[200],
          backgroundColor: colors.success[50],
          valueColor: colors.success[700],
          defaultIconBg: colors.success[100],
          defaultIconColor: colors.success[600],
        };
      case 'warning':
        return {
          borderColor: colors.warning[200],
          backgroundColor: colors.warning[50],
          valueColor: colors.warning[700],
          defaultIconBg: colors.warning[100],
          defaultIconColor: colors.warning[600],
        };
      case 'error':
        return {
          borderColor: colors.error[200],
          backgroundColor: colors.error[50],
          valueColor: colors.error[700],
          defaultIconBg: colors.error[100],
          defaultIconColor: colors.error[600],
        };
      case 'primary':
        return {
          borderColor: colors.primary[200],
          backgroundColor: colors.primary[50],
          valueColor: colors.primary[700],
          defaultIconBg: colors.primary[100],
          defaultIconColor: colors.primary[600],
        };
      default:
        return {
          borderColor: colors.neutral[200],
          backgroundColor: colors.neutral[0],
          valueColor: colors.neutral[900],
          defaultIconBg: colors.neutral[100],
          defaultIconColor: colors.neutral[600],
        };
    }
  };

  const variantStyles = getVariantStyles();

  const CardContent = (
    <View
      style={[
        styles.container,
        large && styles.containerLarge,
        {
          backgroundColor: variantStyles.backgroundColor,
          borderColor: variantStyles.borderColor,
        },
        style,
      ]}>
      {icon && (
        <View
          style={[
            styles.iconContainer,
            large && styles.iconContainerLarge,
            {
              backgroundColor: iconBackgroundColor || variantStyles.defaultIconBg,
            },
          ]}>
          <Icon
            name={icon}
            size={large ? 28 : 24}
            color={iconColor || variantStyles.defaultIconColor}
          />
        </View>
      )}
      <View style={styles.textContainer}>
        <Text style={[styles.title, large && styles.titleLarge]}>{title}</Text>
        <Text
          style={[
            styles.value,
            large && styles.valueLarge,
            {color: variantStyles.valueColor},
          ]}>
          {value}
        </Text>
        {subtitle && (
          <Text style={[styles.subtitle, large && styles.subtitleLarge]}>
            {subtitle}
          </Text>
        )}
      </View>
      {onPress && (
        <Icon
          name="chevron-right"
          size={24}
          color={colors.neutral[400]}
          style={styles.chevron}
        />
      )}
    </View>
  );

  if (onPress) {
    return (
      <TouchableOpacity onPress={onPress} activeOpacity={0.7}>
        {CardContent}
      </TouchableOpacity>
    );
  }

  return CardContent;
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: spacing.lg,
    borderRadius: borderRadius.xl,
    borderWidth: 1,
    ...shadows.sm,
  },
  containerLarge: {
    padding: spacing.xl,
  },
  iconContainer: {
    width: 48,
    height: 48,
    borderRadius: borderRadius.lg,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: spacing.md,
  },
  iconContainerLarge: {
    width: 64,
    height: 64,
    borderRadius: borderRadius.xl,
    marginRight: spacing.lg,
  },
  textContainer: {
    flex: 1,
  },
  title: {
    ...typography.labelMedium,
    color: colors.neutral[600],
    marginBottom: 4,
  },
  titleLarge: {
    ...typography.labelLarge,
    marginBottom: 6,
  },
  value: {
    ...typography.h4,
  },
  valueLarge: {
    ...typography.h3,
  },
  subtitle: {
    ...typography.caption,
    color: colors.neutral[500],
    marginTop: 4,
  },
  subtitleLarge: {
    ...typography.bodySmall,
    marginTop: 6,
  },
  chevron: {
    marginLeft: spacing.sm,
  },
});

export default InfoCard;

