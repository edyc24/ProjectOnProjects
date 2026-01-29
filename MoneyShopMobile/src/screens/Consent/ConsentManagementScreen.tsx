import React, {useEffect, useState} from 'react';
import {View, StyleSheet, ScrollView, Alert, TouchableOpacity} from 'react-native';
import {Text, ActivityIndicator} from 'react-native-paper';
import {useMutation, useQuery, useQueryClient} from '@tanstack/react-query';
import {consentApi, ConsentInfo} from '../../services/api/consentApi';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import {colors, spacing, borderRadius, typography, shadows} from '../../theme/designSystem';
import {BigButton, StatusBadge} from '../../components/ui';

/**
 * ConsentManagementScreen - Gestionare Consimțământ Redesign
 * 
 * Principii UX conform SRS:
 * - Consimțământuri clare și vizibile
 * - Opțional vs Obligatoriu clar marcat
 * - Toggle OFF by default pentru opționale
 * - Fără dark patterns
 */

const ConsentManagementScreen = ({navigation}: any) => {
  const queryClient = useQueryClient();
  const [acceptedConsents, setAcceptedConsents] = useState<Set<string>>(new Set());

  const {data, isLoading, error} = useQuery({
    queryKey: ['consents'],
    queryFn: () => consentApi.listConsents(),
  });

  const grantMutation = useMutation({
    mutationFn: consentApi.grantConsent,
    onSuccess: () => {
      queryClient.invalidateQueries({queryKey: ['consents']});
      Alert.alert(
        '✅ Consimțământ Acordat',
        'Consimțământul tău a fost înregistrat cu succes.',
        [{text: 'OK'}]
      );
    },
    onError: (error: any) => {
      Alert.alert(
        '❌ Eroare',
        error.message || 'Nu am putut înregistra consimțământul. Te rugăm să încerci din nou.',
        [{text: 'OK'}]
      );
    },
  });

  const revokeMutation = useMutation({
    mutationFn: consentApi.revokeConsent,
    onSuccess: () => {
      queryClient.invalidateQueries({queryKey: ['consents']});
      Alert.alert(
        '✅ Consimțământ Revocat',
        'Consimțământul a fost revocat cu succes. Modificarea are efect imediat.',
        [{text: 'OK'}]
      );
    },
    onError: (error: any) => {
      Alert.alert(
        '❌ Eroare',
        error.message || 'Nu am putut revoca consimțământul. Te rugăm să încerci din nou.',
        [{text: 'OK'}]
      );
    },
  });

  useEffect(() => {
    if (data?.consents) {
      const granted = new Set(
        data.consents
          .filter(c => c.status === 'granted')
          .map(c => c.consentType),
      );
      setAcceptedConsents(granted);
    }
  }, [data]);

  const handleGrantConsent = (consentType: string, docType: string, docVersion: string, title: string) => {
    Alert.alert(
      '📋 Confirmare Consimțământ',
      `Dorești să acorzi consimțământul pentru "${title}"?\n\nPoți revoca oricând acest consimțământ.`,
      [
        {text: 'Anulează', style: 'cancel'},
        {
          text: 'Acordă',
          onPress: () => {
            const consentText = `Consimțământ pentru ${title}`;
            grantMutation.mutate({
              consentType,
              docType,
              docVersion,
              consentTextSnapshot: consentText,
              sourceChannel: 'ios',
            });
          },
        },
      ],
    );
  };

  const handleRevokeConsent = (consentId: string, title: string) => {
    Alert.alert(
      '⚠️ Revocare Consimțământ',
      `Ești sigur că dorești să revoci consimțământul pentru "${title}"?\n\nAceastă acțiune poate afecta funcționalitatea unor servicii.`,
      [
        {text: 'Păstrează', style: 'cancel'},
        {
          text: 'Revocă',
          style: 'destructive',
          onPress: () => revokeMutation.mutate(consentId),
        },
      ],
    );
  };

  // Grupare consimțământuri pe categorii
  const consentCategories = [
    {
      category: 'obligatoriu',
      title: 'Consimțământuri Obligatorii',
      subtitle: 'Necesare pentru utilizarea serviciului',
      consents: [
        {
          type: 'TC_ACCEPT',
          docType: 'TC',
          docVersion: '1.0.0',
          title: 'Termeni și Condiții',
          description: 'Acceptarea termenilor și condițiilor de utilizare a platformei MoneyShop.',
          icon: 'file-document-outline',
          iconBg: colors.primary[100],
          iconColor: colors.primary[600],
        },
        {
          type: 'GDPR_ACCEPT',
          docType: 'GDPR',
          docVersion: '1.0.0',
          title: 'Politica de Confidențialitate',
          description: 'Consimțământ pentru prelucrarea datelor personale conform GDPR.',
          icon: 'shield-lock-outline',
          iconBg: colors.primary[100],
          iconColor: colors.primary[600],
        },
        {
          type: 'COSTS_ACCEPT',
          docType: 'MANDATE',
          docVersion: '1.0.0',
          title: 'Informare Costuri',
          description: 'Confirm că am fost informat despre costurile serviciilor.',
          icon: 'cash-check',
          iconBg: colors.warning[100],
          iconColor: colors.warning[600],
        },
      ],
    },
    {
      category: 'mandate',
      title: 'Mandate de Acces',
      subtitle: 'Pentru analiza eligibilității tale',
      consents: [
        {
          type: 'MANDATE_ANAF_BC',
          docType: 'MANDATE',
          docVersion: '1.0.0',
          title: 'Mandat ANAF & Biroul de Credit',
          description: 'Autorizez accesul la datele mele din ANAF și Biroul de Credit pentru analiza de credit.',
          icon: 'file-sign',
          iconBg: colors.success[100],
          iconColor: colors.success[600],
        },
      ],
    },
    {
      category: 'optional',
      title: 'Consimțământuri Opționale',
      subtitle: 'Nu sunt obligatorii pentru serviciu',
      consents: [
        {
          type: 'SHARE_TO_BROKER',
          docType: 'BROKER_TRANSFER',
          docVersion: '1.0.0',
          title: 'Transmitere Date către Brokeri',
          description: 'Accept ca datele mele să fie transmise către brokerii parteneri pentru oferte personalizate.',
          icon: 'share-variant-outline',
          iconBg: colors.neutral[100],
          iconColor: colors.neutral[600],
          optional: true,
        },
      ],
    },
  ];

  if (isLoading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color={colors.primary[500]} />
        <Text style={styles.loadingText}>Se încarcă...</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <ScrollView 
        style={styles.scrollView}
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.scrollContent}>
        
        {/* Header */}
        <View style={styles.header}>
          <Text style={styles.headerTitle}>Consimțământuri</Text>
          <Text style={styles.headerSubtitle}>
            Gestionează acordurile tale pentru prelucrarea datelor personale
          </Text>
        </View>

        {/* Info Box */}
        <View style={styles.infoBox}>
          <Icon name="information-outline" size={22} color={colors.primary[500]} />
          <View style={styles.infoContent}>
            <Text style={styles.infoTitle}>Drepturile tale</Text>
            <Text style={styles.infoText}>
              Poți revoca orice consimțământ în orice moment. Datele tale sunt protejate conform GDPR.
            </Text>
          </View>
        </View>

        {/* Consent Categories */}
        {consentCategories.map((category, categoryIndex) => (
          <View key={categoryIndex} style={styles.categorySection}>
            <View style={styles.categoryHeader}>
              <Text style={styles.categoryTitle}>{category.title}</Text>
              <Text style={styles.categorySubtitle}>{category.subtitle}</Text>
            </View>

            {category.consents.map((consent, index) => {
              const isGranted = acceptedConsents.has(consent.type);
              const existingConsent = data?.consents?.find(
                c => c.consentType === consent.type && c.status === 'granted',
              );

              return (
                <View 
                  key={index} 
                  style={[
                    styles.consentCard,
                    isGranted && styles.consentCardGranted,
                  ]}>
                  
                  {/* Optional Badge */}
                  {(consent as any).optional && (
                    <View style={styles.optionalBadge}>
                      <Text style={styles.optionalBadgeText}>Opțional</Text>
                    </View>
                  )}

                  <View style={styles.consentHeader}>
                    <View style={[styles.consentIcon, {backgroundColor: consent.iconBg}]}>
                      <Icon name={consent.icon} size={24} color={consent.iconColor} />
                    </View>
                    <View style={styles.consentInfo}>
                      <Text style={styles.consentTitle}>{consent.title}</Text>
                      <Text style={styles.consentDescription}>{consent.description}</Text>
                    </View>
                  </View>

                  {/* Status & Date */}
                  {existingConsent && (
                    <View style={styles.statusRow}>
                      <StatusBadge status="active" label="Acordat" size="small" />
                      <Text style={styles.dateText}>
                        {new Date(existingConsent.grantedAt).toLocaleDateString('ro-RO')}
                      </Text>
                    </View>
                  )}

                  {/* Actions */}
                  <View style={styles.consentActions}>
                    {!isGranted ? (
                      <BigButton
                        title="Acordă Consimțământ"
                        icon="check"
                        variant="primary"
                        onPress={() => handleGrantConsent(
                          consent.type, 
                          consent.docType, 
                          consent.docVersion,
                          consent.title
                        )}
                        loading={grantMutation.isPending}
                      />
                    ) : (
                      <TouchableOpacity
                        onPress={() => existingConsent && handleRevokeConsent(
                          existingConsent.consentId,
                          consent.title
                        )}
                        disabled={revokeMutation.isPending}
                        style={styles.revokeButton}>
                        <Icon name="close-circle-outline" size={20} color={colors.error[500]} />
                        <Text style={styles.revokeButtonText}>Revocă Consimțământ</Text>
                      </TouchableOpacity>
                    )}
                  </View>
                </View>
              );
            })}
          </View>
        ))}

        {/* Footer Info */}
        <View style={styles.footer}>
          <Icon name="shield-check" size={20} color={colors.success[500]} />
          <Text style={styles.footerText}>
            Toate consimțământurile sunt înregistrate cu dată, oră și adresă IP conform cerințelor GDPR.
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
  infoContent: {
    flex: 1,
    marginLeft: spacing.md,
  },
  infoTitle: {
    ...typography.labelLarge,
    color: colors.primary[700],
    marginBottom: spacing.xs,
  },
  infoText: {
    ...typography.bodySmall,
    color: colors.primary[600],
    lineHeight: 20,
  },

  // Category Section
  categorySection: {
    marginBottom: spacing.xl,
  },
  categoryHeader: {
    marginBottom: spacing.md,
  },
  categoryTitle: {
    ...typography.h4,
    color: colors.neutral[800],
    marginBottom: 4,
  },
  categorySubtitle: {
    ...typography.bodySmall,
    color: colors.neutral[500],
  },

  // Consent Card
  consentCard: {
    backgroundColor: colors.neutral[0],
    borderRadius: borderRadius.xl,
    padding: spacing.lg,
    marginBottom: spacing.md,
    borderWidth: 1,
    borderColor: colors.neutral[200],
    ...shadows.sm,
    position: 'relative',
    overflow: 'hidden',
  },
  consentCardGranted: {
    borderColor: colors.success[200],
    backgroundColor: colors.success[50],
  },
  optionalBadge: {
    position: 'absolute',
    top: 0,
    right: 0,
    backgroundColor: colors.neutral[200],
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.xs,
    borderBottomLeftRadius: borderRadius.md,
  },
  optionalBadgeText: {
    ...typography.caption,
    color: colors.neutral[600],
    fontWeight: '600',
  },
  consentHeader: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    marginBottom: spacing.md,
  },
  consentIcon: {
    width: 48,
    height: 48,
    borderRadius: borderRadius.lg,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: spacing.md,
  },
  consentInfo: {
    flex: 1,
    paddingRight: spacing.lg,
  },
  consentTitle: {
    ...typography.labelLarge,
    color: colors.neutral[900],
    marginBottom: spacing.xs,
  },
  consentDescription: {
    ...typography.bodySmall,
    color: colors.neutral[600],
    lineHeight: 20,
  },

  // Status Row
  statusRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingTop: spacing.md,
    paddingBottom: spacing.sm,
    borderTopWidth: 1,
    borderTopColor: colors.success[100],
    marginBottom: spacing.sm,
  },
  dateText: {
    ...typography.caption,
    color: colors.neutral[500],
  },

  // Actions
  consentActions: {
    marginTop: spacing.sm,
  },
  revokeButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: spacing.md,
    paddingHorizontal: spacing.lg,
    borderRadius: borderRadius.lg,
    borderWidth: 1,
    borderColor: colors.error[200],
    backgroundColor: colors.error[50],
  },
  revokeButtonText: {
    ...typography.labelMedium,
    color: colors.error[600],
    marginLeft: spacing.sm,
  },

  // Footer
  footer: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    backgroundColor: colors.neutral[100],
    borderRadius: borderRadius.xl,
    padding: spacing.lg,
    marginTop: spacing.lg,
  },
  footerText: {
    ...typography.bodySmall,
    color: colors.neutral[600],
    flex: 1,
    marginLeft: spacing.md,
    lineHeight: 20,
  },
});

export default ConsentManagementScreen;
