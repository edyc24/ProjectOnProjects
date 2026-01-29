import React from 'react';
import {View, Text, StyleSheet} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import {colors, spacing, borderRadius, typography} from '../../theme/designSystem';

interface ProgressStepsProps {
  currentStep: number;
  totalSteps: number;
  stepTitles?: string[];
  showNumbers?: boolean;
  variant?: 'horizontal' | 'compact';
}

/**
 * ProgressSteps - Indicator de progres clar și vizibil
 * 
 * Arată utilizatorului unde se află în proces și câți pași mai are.
 * Design simplu și ușor de înțeles pentru toate vârstele.
 */
const ProgressSteps: React.FC<ProgressStepsProps> = ({
  currentStep,
  totalSteps,
  stepTitles,
  showNumbers = true,
  variant = 'compact',
}) => {
  const progress = (currentStep / totalSteps) * 100;

  if (variant === 'compact') {
    return (
      <View style={styles.compactContainer}>
        <View style={styles.compactHeader}>
          <View style={styles.stepIndicator}>
            <Text style={styles.stepNumber}>{currentStep}</Text>
            <Text style={styles.stepSeparator}>/</Text>
            <Text style={styles.stepTotal}>{totalSteps}</Text>
          </View>
          {stepTitles && stepTitles[currentStep - 1] && (
            <Text style={styles.currentStepTitle} numberOfLines={1}>
              {stepTitles[currentStep - 1]}
            </Text>
          )}
        </View>
        <View style={styles.progressBarContainer}>
          <View style={[styles.progressBarFill, {width: `${progress}%`}]} />
        </View>
        <Text style={styles.progressText}>
          {progress < 100 
            ? `Mai ai ${totalSteps - currentStep} ${totalSteps - currentStep === 1 ? 'pas' : 'pași'}`
            : 'Ultimul pas!'}
        </Text>
      </View>
    );
  }

  // Horizontal variant
  return (
    <View style={styles.horizontalContainer}>
      <View style={styles.stepsRow}>
        {Array.from({length: totalSteps}, (_, index) => {
          const stepNumber = index + 1;
          const isCompleted = stepNumber < currentStep;
          const isCurrent = stepNumber === currentStep;
          const isUpcoming = stepNumber > currentStep;

          return (
            <React.Fragment key={index}>
              <View style={styles.stepItem}>
                <View
                  style={[
                    styles.stepCircle,
                    isCompleted && styles.stepCircleCompleted,
                    isCurrent && styles.stepCircleCurrent,
                    isUpcoming && styles.stepCircleUpcoming,
                  ]}>
                  {isCompleted ? (
                    <Icon name="check" size={16} color="#FFFFFF" />
                  ) : (
                    showNumbers && (
                      <Text
                        style={[
                          styles.stepCircleText,
                          isCurrent && styles.stepCircleTextCurrent,
                        ]}>
                        {stepNumber}
                      </Text>
                    )
                  )}
                </View>
                {stepTitles && stepTitles[index] && (
                  <Text
                    style={[
                      styles.stepTitle,
                      isCurrent && styles.stepTitleCurrent,
                      isCompleted && styles.stepTitleCompleted,
                    ]}
                    numberOfLines={2}>
                    {stepTitles[index]}
                  </Text>
                )}
              </View>
              {index < totalSteps - 1 && (
                <View
                  style={[
                    styles.connector,
                    isCompleted && styles.connectorCompleted,
                  ]}
                />
              )}
            </React.Fragment>
          );
        })}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  // Compact variant
  compactContainer: {
    backgroundColor: colors.neutral[0],
    padding: spacing.lg,
    borderRadius: borderRadius.xl,
    marginBottom: spacing.lg,
  },
  compactHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.sm,
  },
  stepIndicator: {
    flexDirection: 'row',
    alignItems: 'baseline',
    backgroundColor: colors.primary[50],
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.xs,
    borderRadius: borderRadius.md,
  },
  stepNumber: {
    ...typography.h4,
    color: colors.primary[700],
  },
  stepSeparator: {
    ...typography.bodyMedium,
    color: colors.primary[400],
    marginHorizontal: 2,
  },
  stepTotal: {
    ...typography.bodyMedium,
    color: colors.primary[500],
  },
  currentStepTitle: {
    ...typography.labelMedium,
    color: colors.neutral[700],
    marginLeft: spacing.md,
    flex: 1,
  },
  progressBarContainer: {
    height: 8,
    backgroundColor: colors.neutral[200],
    borderRadius: 4,
    overflow: 'hidden',
    marginBottom: spacing.sm,
  },
  progressBarFill: {
    height: '100%',
    backgroundColor: colors.primary[500],
    borderRadius: 4,
  },
  progressText: {
    ...typography.caption,
    color: colors.neutral[500],
    textAlign: 'center',
  },
  
  // Horizontal variant
  horizontalContainer: {
    backgroundColor: colors.neutral[0],
    padding: spacing.lg,
    borderRadius: borderRadius.xl,
    marginBottom: spacing.lg,
  },
  stepsRow: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    justifyContent: 'center',
  },
  stepItem: {
    alignItems: 'center',
    maxWidth: 80,
  },
  stepCircle: {
    width: 36,
    height: 36,
    borderRadius: 18,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: spacing.xs,
  },
  stepCircleCompleted: {
    backgroundColor: colors.success[500],
  },
  stepCircleCurrent: {
    backgroundColor: colors.primary[500],
  },
  stepCircleUpcoming: {
    backgroundColor: colors.neutral[200],
  },
  stepCircleText: {
    ...typography.labelMedium,
    color: colors.neutral[500],
  },
  stepCircleTextCurrent: {
    color: '#FFFFFF',
  },
  stepTitle: {
    ...typography.caption,
    color: colors.neutral[500],
    textAlign: 'center',
  },
  stepTitleCurrent: {
    color: colors.primary[700],
    fontWeight: '600',
  },
  stepTitleCompleted: {
    color: colors.success[700],
  },
  connector: {
    flex: 1,
    height: 2,
    backgroundColor: colors.neutral[200],
    marginTop: 17,
    marginHorizontal: spacing.xs,
    maxWidth: 40,
  },
  connectorCompleted: {
    backgroundColor: colors.success[500],
  },
});

export default ProgressSteps;

