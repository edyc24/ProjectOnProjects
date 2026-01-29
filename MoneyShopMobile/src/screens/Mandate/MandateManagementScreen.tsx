import React, {useState} from 'react';
import {View, StyleSheet, ScrollView, Alert, Animated} from 'react-native';
import {Card, Text, ActivityIndicator} from 'react-native-paper';
import {useMutation, useQuery, useQueryClient} from '@tanstack/react-query';
import {mandateApi, MandateInfo} from '../../services/api/mandateApi';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import {colors, spacing, borderRadius, typography, shadows} from '../../theme/designSystem';
import {BigButton, StatusBadge, InfoCard} from '../../components/ui';

/**
 * MandateManagementScreen - Gestionare Mandate
 * 
 * Design UX simplu conform SRS:
 * - 1 ecran = 1 decizie
 * - Text mare și clar
 * - Butoane mari pentru toate vârstele
 * - Confirmări clare
 * - Informații vizuale despre mandate
 */

const MandateManagementScreen = ({navigation}: any) => {
  const queryClient = useQueryClient();

  const {data, isLoading, error} = useQuery({
    queryKey: ['mandates'],
    queryFn: () => mandateApi.listMandates(),
  });

  const createMutation = useMutation({
    mutationFn: mandateApi.createMandate,
    onSuccess: () => {
      queryClient.invalidateQueries({queryKey: ['mandates']});
      Alert.alert(
        '✅ Mandat Creat!',
        'Mandatul tău a fost creat cu succes și este activ pentru 30 de zile.',
        [{text: 'OK', style: 'default'}]
      );
    },
    onError: (error: any) => {
      Alert.alert(
        '❌ Eroare',
        error.message || 'Nu am putut crea mandatul. Te rugăm să încerci din nou.',
        [{text: 'OK', style: 'default'}]
      );
    },
  });

  const revokeMutation = useMutation({
    mutationFn: ({mandateId, reason}: {mandateId: string; reason?: string}) =>
      mandateApi.revokeMandate(mandateId, reason),
    onSuccess: () => {
      queryClient.invalidateQueries({queryKey: ['mandates']});
      Alert.alert(
        '✅ Mandat Revocat',
        'Mandatul a fost revocat cu succes. Nu mai avem acces la datele tale.',
        [{text: 'OK', style: 'default'}]
      );
    },
    onError: (error: any) => {
      Alert.alert(
        '❌ Eroare', 
        error.message || 'Nu am putut revoca mandatul. Te rugăm să încerci din nou.',
        [{text: 'OK', style: 'default'}]
      );
    },
  });

  const handleCreateMandate = (mandateType: string, title: string) => {
    Alert.alert(
      '📋 Confirmare Mandat',
      `Dorești să creezi un mandat pentru ${title}?\n\nMandatul va fi activ 30 de zile și îl poți revoca oricând.`,
      [
        {text: 'Anulează', style: 'cancel'},
        {
          text: 'Creează Mandat',
          onPress: () => {
            createMutation.mutate({
              mandateType,
              expiresInDays: 30,
            });
          },
        },
      ],
    );
  };

  const handleRevokeMandate = (mandateId: string) => {
    Alert.alert(
      '⚠️ Revocare Mandat',
      'Sigur dorești să revoci acest mandat?\n\nDupă revocare, nu vom mai putea accesa datele tale pentru analiza de credit.',
      [
        {text: 'Păstrează Mandatul', style: 'cancel'},
        {
          text: 'Revocă',
          style: 'destructive',
          onPress: () => revokeMutation.mutate({mandateId}),
        },
      ],
    );
  };

  const mandateTypes = [
    {
      type: 'ANAF',
      title: 'ANAF',
      description: 'Acces la datele de venit din ANAF pentru verificarea veniturilor tale.',
      icon: 'file-document-outline',
      iconBg: colors.primary[100],
      iconColor: colors.primary[600],
    },
    {
      type: 'BC',
      title: 'Biroul de Credit',
      description: 'Acces la istoricul tău de credit pentru a evalua eligibilitatea.',
      icon: 'bank-outline',
      iconBg: colors.warning[100],
      iconColor: colors.warning[600],
    },
    {
      type: 'ANAF_BC',
      title: 'ANAF + Biroul de Credit',
      description: 'Acces complet pentru o analiză detaliată și cele mai bune oferte.',
      icon: 'shield-check-outline',
      iconBg: colors.success[100],
      iconColor: colors.success[600],
      recommended: true,
    },
  ];

  const getRemainingDays = (expiresAt: string) => {
    const expiry = new Date(expiresAt);
    const now = new Date();
    const diffTime = expiry.getTime() - now.getTime();
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return diffDays;
  };

  if (isLoading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color={colors.primary[500]} />
        <Text style={styles.loadingText}>Se încarcă mandatele...</Text>
      </View>
    );
  }

  const activeMandates = data?.mandates?.filter(m => m.status === 'active') || [];
  const allMandates = data?.mandates || [];

  return (
    <View style={styles.container}>
      <ScrollView 
        style={styles.scrollView}
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.scrollContent}>
        
        {/* Header */}
        <View style={styles.header}>
          <Text style={styles.headerTitle}>Mandate</Text>
          <Text style={styles.headerSubtitle}>
            Mandatele îți permit să ne autorizezi să accesăm datele tale pentru analiza de credit.
          </Text>
        </View>

        {/* Info Card - Explicație simplă */}
        <View style={styles.infoBox}>
          <Icon name="information-outline" size={24} color={colors.primary[500]} />
          <View style={styles.infoTextContainer}>
            <Text style={styles.infoTitle}>Ce este un mandat?</Text>
            <Text style={styles.infoDescription}>
              Un mandat ne autorizează să verificăm datele tale pentru a-ți găsi cele mai bune oferte de credit. Este valabil 30 de zile și îl poți revoca oricând.
            </Text>
          </View>
        </View>

        {/* Active Mandates Summary */}
        {activeMandates.length > 0 && (
          <View style={styles.summaryCard}>
            <View style={styles.summaryHeader}>
              <Icon name="check-circle" size={28} color={colors.success[500]} />
              <View style={styles.summaryTextContainer}>
                <Text style={styles.summaryTitle}>
                  {activeMandates.length === 1 ? '1 Mandat Activ' : `${activeMandates.length} Mandate Active`}
                </Text>
                <Text style={styles.summarySubtitle}>
                  Poți analiza datele pentru credit
                </Text>
              </View>
            </View>
          </View>
        )}

        {/* Mandate Types - Create New */}
        <Text style={styles.sectionTitle}>Tipuri de Mandate</Text>
        
        {mandateTypes.map((mandateType, index) => {
          const hasActive = activeMandates.some(m => m.mandateType === mandateType.type);
          const activeMandate = activeMandates.find(m => m.mandateType === mandateType.type);
          const remainingDays = activeMandate ? getRemainingDays(activeMandate.expiresAt) : 0;

          return (
            <View key={index} style={[
              styles.mandateCard,
              mandateType.recommended && styles.mandateCardRecommended,
            ]}>
              {mandateType.recommended && (
                <View style={styles.recommendedBadge}>
                  <Icon name="star" size={12} color="#FFFFFF" />
                  <Text style={styles.recommendedText}>Recomandat</Text>
                </View>
              )}
              
              <View style={styles.mandateCardContent}>
                <View style={[styles.mandateIcon, {backgroundColor: mandateType.iconBg}]}>
                  <Icon name={mandateType.icon} size={28} color={mandateType.iconColor} />
                </View>
                
                <View style={styles.mandateInfo}>
                  <Text style={styles.mandateTitle}>{mandateType.title}</Text>
                  <Text style={styles.mandateDescription}>{mandateType.description}</Text>
                  
                  {hasActive && (
                    <View style={styles.activeInfo}>
                      <StatusBadge status="active" size="small" />
                      <Text style={styles.daysRemaining}>
                        {remainingDays > 0 ? `${remainingDays} zile rămase` : 'Expiră azi'}
                      </Text>
                    </View>
                  )}
                </View>
              </View>

              <View style={styles.mandateActions}>
                {hasActive ? (
                  <BigButton
                    title="Revocă"
                    variant="outline"
                    icon="close"
                    onPress={() => handleRevokeMandate(activeMandate!.mandateId)}
                    loading={revokeMutation.isPending}
                    style={styles.revokeButton}
                  />
                ) : (
                  <BigButton
                    title="Creează Mandat"
                    subtitle="Valabil 30 de zile"
                    variant={mandateType.recommended ? 'success' : 'primary'}
                    icon="plus"
                    onPress={() => handleCreateMandate(mandateType.type, mandateType.title)}
                    loading={createMutation.isPending}
                  />
                )}
              </View>
            </View>
          );
        })}

        {/* All Mandates History */}
        {allMandates.length > 0 && (
          <View style={styles.historySection}>
            <Text style={styles.sectionTitle}>Istoric Mandate</Text>
            
            {allMandates.map((mandate: MandateInfo) => {
              const remainingDays = getRemainingDays(mandate.expiresAt);
              
              return (
                <View key={mandate.mandateId} style={styles.historyCard}>
                  <View style={styles.historyHeader}>
                    <View style={styles.historyInfo}>
                      <Text style={styles.historyType}>{mandate.mandateType}</Text>
                      <StatusBadge status={mandate.status} size="small" />
                    </View>
                  </View>
                  
                  <View style={styles.historyDates}>
                    <View style={styles.historyDateItem}>
                      <Icon name="calendar-plus" size={16} color={colors.neutral[500]} />
                      <Text style={styles.historyDateText}>
                        Creat: {new Date(mandate.grantedAt).toLocaleDateString('ro-RO')}
                      </Text>
                    </View>
                    <View style={styles.historyDateItem}>
                      <Icon name="calendar-clock" size={16} color={colors.neutral[500]} />
                      <Text style={styles.historyDateText}>
                        Expiră: {new Date(mandate.expiresAt).toLocaleDateString('ro-RO')}
                      </Text>
                    </View>
                  </View>

                  {mandate.status === 'active' && remainingDays > 0 && (
                    <View style={styles.progressContainer}>
                      <View style={styles.progressBar}>
                        <View 
                          style={[
                            styles.progressFill, 
                            {width: `${Math.min(100, (remainingDays / 30) * 100)}%`}
                          ]} 
                        />
                      </View>
                      <Text style={styles.progressText}>
                        {remainingDays} zile rămase
                      </Text>
                    </View>
                  )}
                </View>
              );
            })}
          </View>
        )}

        {/* Empty State */}
        {allMandates.length === 0 && (
          <View style={styles.emptyState}>
            <Icon name="file-document-outline" size={64} color={colors.neutral[300]} />
            <Text style={styles.emptyTitle}>Niciun mandat creat</Text>
            <Text style={styles.emptyDescription}>
              Creează un mandat pentru a ne permite să analizăm datele tale și să-ți găsim cele mai bune oferte de credit.
            </Text>
          </View>
        )}

        {/* Footer Info */}
        <View style={styles.footer}>
          <Icon name="shield-check" size={20} color={colors.success[500]} />
          <Text style={styles.footerText}>
            Datele tale sunt protejate și securizate conform GDPR.{'\n'}
            Poți revoca mandatele oricând din această pagină.
          </Text>
        </View>
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.neutral[50],
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    padding: spacing.lg,
    paddingBottom: spacing.xxxl,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: colors.neutral[50],
  },
  loadingText: {
    ...typography.bodyMedium,
    color: colors.neutral[600],
    marginTop: spacing.md,
  },
  
  // Header
  header: {
    marginBottom: spacing.xl,
  },
  headerTitle: {
    ...typography.h2,
    color: colors.neutral[900],
    marginBottom: spacing.sm,
  },
  headerSubtitle: {
    ...typography.bodyMedium,
    color: colors.neutral[600],
    lineHeight: 24,
  },
  
  // Info Box
  infoBox: {
    flexDirection: 'row',
    backgroundColor: colors.primary[50],
    borderRadius: borderRadius.xl,
    padding: spacing.lg,
    marginBottom: spacing.xl,
    borderWidth: 1,
    borderColor: colors.primary[100],
  },
  infoTextContainer: {
    flex: 1,
    marginLeft: spacing.md,
  },
  infoTitle: {
    ...typography.labelLarge,
    color: colors.primary[700],
    marginBottom: spacing.xs,
  },
  infoDescription: {
    ...typography.bodySmall,
    color: colors.primary[600],
    lineHeight: 20,
  },
  
  // Summary Card
  summaryCard: {
    backgroundColor: colors.success[50],
    borderRadius: borderRadius.xl,
    padding: spacing.lg,
    marginBottom: spacing.xl,
    borderWidth: 1,
    borderColor: colors.success[200],
  },
  summaryHeader: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  summaryTextContainer: {
    marginLeft: spacing.md,
  },
  summaryTitle: {
    ...typography.h4,
    color: colors.success[700],
  },
  summarySubtitle: {
    ...typography.bodySmall,
    color: colors.success[600],
    marginTop: 2,
  },
  
  // Section Title
  sectionTitle: {
    ...typography.h4,
    color: colors.neutral[800],
    marginBottom: spacing.lg,
  },
  
  // Mandate Card
  mandateCard: {
    backgroundColor: colors.neutral[0],
    borderRadius: borderRadius.xxl,
    padding: spacing.lg,
    marginBottom: spacing.lg,
    ...shadows.md,
    position: 'relative',
    overflow: 'hidden',
  },
  mandateCardRecommended: {
    borderWidth: 2,
    borderColor: colors.success[300],
  },
  recommendedBadge: {
    position: 'absolute',
    top: 0,
    right: 0,
    backgroundColor: colors.success[500],
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.xs,
    borderBottomLeftRadius: borderRadius.md,
  },
  recommendedText: {
    ...typography.labelSmall,
    color: '#FFFFFF',
    marginLeft: 4,
  },
  mandateCardContent: {
    flexDirection: 'row',
    marginBottom: spacing.lg,
  },
  mandateIcon: {
    width: 56,
    height: 56,
    borderRadius: borderRadius.lg,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: spacing.md,
  },
  mandateInfo: {
    flex: 1,
  },
  mandateTitle: {
    ...typography.h4,
    color: colors.neutral[900],
    marginBottom: spacing.xs,
  },
  mandateDescription: {
    ...typography.bodySmall,
    color: colors.neutral[600],
    lineHeight: 20,
  },
  activeInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: spacing.sm,
    gap: spacing.sm,
  },
  daysRemaining: {
    ...typography.caption,
    color: colors.success[600],
  },
  mandateActions: {
    marginTop: spacing.sm,
  },
  revokeButton: {
    backgroundColor: 'transparent',
    borderColor: colors.error[300],
  },
  
  // History Section
  historySection: {
    marginTop: spacing.xl,
  },
  historyCard: {
    backgroundColor: colors.neutral[0],
    borderRadius: borderRadius.xl,
    padding: spacing.lg,
    marginBottom: spacing.md,
    ...shadows.sm,
  },
  historyHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: spacing.md,
  },
  historyInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.sm,
  },
  historyType: {
    ...typography.labelLarge,
    color: colors.neutral[800],
  },
  historyDates: {
    gap: spacing.xs,
  },
  historyDateItem: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.sm,
  },
  historyDateText: {
    ...typography.bodySmall,
    color: colors.neutral[600],
  },
  progressContainer: {
    marginTop: spacing.md,
    paddingTop: spacing.md,
    borderTopWidth: 1,
    borderTopColor: colors.neutral[200],
  },
  progressBar: {
    height: 6,
    backgroundColor: colors.neutral[200],
    borderRadius: 3,
    overflow: 'hidden',
    marginBottom: spacing.xs,
  },
  progressFill: {
    height: '100%',
    backgroundColor: colors.success[500],
    borderRadius: 3,
  },
  progressText: {
    ...typography.caption,
    color: colors.success[600],
    textAlign: 'right',
  },
  
  // Empty State
  emptyState: {
    alignItems: 'center',
    padding: spacing.xxl,
  },
  emptyTitle: {
    ...typography.h4,
    color: colors.neutral[600],
    marginTop: spacing.lg,
    marginBottom: spacing.sm,
  },
  emptyDescription: {
    ...typography.bodyMedium,
    color: colors.neutral[500],
    textAlign: 'center',
    lineHeight: 24,
  },
  
  // Footer
  footer: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    backgroundColor: colors.neutral[100],
    borderRadius: borderRadius.xl,
    padding: spacing.lg,
    marginTop: spacing.xl,
  },
  footerText: {
    ...typography.bodySmall,
    color: colors.neutral[600],
    flex: 1,
    marginLeft: spacing.md,
    lineHeight: 20,
  },
});

export default MandateManagementScreen;
