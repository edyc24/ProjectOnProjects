import React, {useEffect, useState} from 'react';
import {View, StyleSheet, ScrollView, RefreshControl} from 'react-native';
import {Card, Text, Button, ActivityIndicator} from 'react-native-paper';
import {useQuery} from '@tanstack/react-query';
import {applicationsApi} from '../../services/api/applicationsApi';
import {userFinancialDataApi} from '../../services/api/userFinancialDataApi';
import {kycApi} from '../../services/api/kycApi';
import {NativeStackNavigationProp} from '@react-navigation/native-stack';
import {useAuthStore} from '../../store/authStore';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

type DashboardScreenNavigationProp = NativeStackNavigationProp<any, 'DashboardHome'>;

interface Props {
  navigation: DashboardScreenNavigationProp;
}

const DashboardScreen: React.FC<Props> = ({navigation}) => {
  const {user} = useAuthStore();
  const [kycChecked, setKycChecked] = useState(false);
  
  const {
    data: applications,
    isLoading,
    refetch,
    isRefetching,
  } = useQuery({
    queryKey: ['applications'],
    queryFn: applicationsApi.getAll,
  });

  const {data: financialData} = useQuery({
    queryKey: ['userFinancialData'],
    queryFn: userFinancialDataApi.getMyData,
    retry: false,
    enabled: !!user, // Only fetch if user is authenticated
  });

  // Check KYC status on mount and focus
  useEffect(() => {
    const checkKycStatus = async () => {
      // Don't check KYC for administrators
      if (!user) {
        setKycChecked(true);
        return;
      }

      // Skip KYC check for administrators
      if (user.role === 'Administrator') {
        setKycChecked(true);
        return;
      }

      try {
        const kycStatus = await kycApi.getStatus();
        // If KYC doesn't exist or is not verified, redirect to KYC form
        if (!kycStatus || kycStatus.status !== 'verified') {
          // Small delay to allow screen to render first
          setTimeout(() => {
            navigation.navigate('KycForm');
          }, 500);
        }
      } catch (error: any) {
        // If 404, no KYC exists - redirect to form
        if (error.response?.status === 404) {
          setTimeout(() => {
            navigation.navigate('KycForm');
          }, 500);
        }
      } finally {
        setKycChecked(true);
      }
    };

    // Only check if user is loaded (not null or undefined)
    if (user != null) {
      checkKycStatus();
    } else {
      // If user is not loaded yet, mark as checked to prevent navigation
      setKycChecked(true);
    }
  }, [user, navigation]);

  useEffect(() => {
    const unsubscribe = navigation.addListener('focus', () => {
      refetch();
      // Re-check KYC status when screen comes into focus
      if (user && user.role !== 'Administrator') {
        kycApi.getStatus().catch(() => {
          // Ignore errors on focus check
        });
      }
    });
    return unsubscribe;
  }, [navigation, refetch, user]);

  // Ensure applications is always an array
  const applicationsList = Array.isArray(applications) ? applications : [];
  const activeApplications = applicationsList.filter(
    app => app.status !== 'RESPINS' && app.status !== 'DISBURSAT',
  );

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'INREGISTRAT':
        return '#2196F3';
      case 'IN_ANALIZA':
        return '#FF9800';
      case 'PREAPROBAT':
        return '#4CAF50';
      case 'RESPINS':
        return '#F44336';
      case 'DISBURSAT':
        return '#9C27B0';
      default:
        return '#757575';
    }
  };

  if (isLoading) {
    return (
      <View style={styles.center}>
        <ActivityIndicator size="large" />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <ScrollView
        style={styles.scrollView}
        refreshControl={
          <RefreshControl refreshing={isRefetching} onRefresh={refetch} />
        }>
        <View style={styles.content}>
          <View style={styles.headerSection}>
            <Text variant="headlineSmall" style={styles.welcomeText}>
              Bine ai venit, {user?.name?.split(' ')[0]}! 👋
            </Text>
            <Text variant="bodyMedium" style={styles.subtitleText}>
              Iată un rezumat al activității tale
            </Text>
          </View>

          {/* Simulator Card - Prominent and Large */}
          <Card 
            style={styles.simulatorCard}
            onPress={() => navigation.getParent()?.navigate('Simulator')}>
            <Card.Content style={styles.simulatorCardContent}>
              <View style={styles.simulatorHeader}>
                <View style={styles.simulatorIconContainer}>
                  <Icon name="calculator-variant" size={40} color="#FFFFFF" />
                </View>
                <View style={styles.simulatorTextContainer}>
                  <Text variant="headlineSmall" style={styles.simulatorTitle}>
                    Simulator Credit
                  </Text>
                  <Text variant="bodyMedium" style={styles.simulatorDescription}>
                    Calculează rata ta lunară și vezi ofertele disponibile
                  </Text>
                </View>
              </View>
              <View style={styles.simulatorFooter}>
                <Text variant="bodySmall" style={styles.simulatorActionText}>
                  Începe simularea →
                </Text>
              </View>
            </Card.Content>
          </Card>

          {/* Stats Grid */}
          <View style={styles.statsGrid}>
            <Card style={styles.statCardSmall}>
              <Card.Content style={styles.statCardSmallContent}>
                <View style={[styles.statIconContainerSmall, {backgroundColor: '#E3F2FD'}]}>
                  <Icon name="file-document" size={24} color="#1976D2" />
                </View>
                <Text variant="headlineMedium" style={styles.statNumberSmall}>
                  {activeApplications.length}
                </Text>
                <Text variant="bodySmall" style={styles.statLabelSmall}>
                  Cereri active
                </Text>
              </Card.Content>
            </Card>

            <Card style={styles.statCardSmall}>
              <Card.Content style={styles.statCardSmallContent}>
                <View style={[styles.statIconContainerSmall, {backgroundColor: '#FFF3E0'}]}>
                  <Icon name="check-circle" size={24} color="#FF9800" />
                </View>
                <Text variant="headlineMedium" style={styles.statNumberSmall}>
                  {applicationsList.filter(app => app.status === 'PREAPROBAT').length}
                </Text>
                <Text variant="bodySmall" style={styles.statLabelSmall}>
                  Preaprobate
                </Text>
              </Card.Content>
            </Card>
          </View>

          {/* Quick Actions */}
          <View style={styles.quickActionsSection}>
            <Text variant="titleMedium" style={styles.sectionTitle}>
              Acțiuni rapide
            </Text>
            <View style={styles.quickActionsGrid}>
              <Card 
                style={styles.quickActionCard}
                onPress={() => navigation.navigate('ApplicationWizard')}>
                <Card.Content style={styles.quickActionContent}>
                  <View style={[styles.quickActionIcon, {backgroundColor: '#E8F5E9'}]}>
                    <Icon name="plus-circle" size={28} color="#4CAF50" />
                  </View>
                  <Text variant="bodySmall" style={styles.quickActionText}>
                    Cerere nouă
                  </Text>
                </Card.Content>
              </Card>

              <Card 
                style={styles.quickActionCard}
                onPress={() => navigation.navigate('ApplicationList')}>
                <Card.Content style={styles.quickActionContent}>
                  <View style={[styles.quickActionIcon, {backgroundColor: '#E3F2FD'}]}>
                    <Icon name="file-document-multiple" size={28} color="#1976D2" />
                  </View>
                  <Text variant="bodySmall" style={styles.quickActionText}>
                    Toate cererile
                  </Text>
                </Card.Content>
              </Card>

              <Card 
                style={styles.quickActionCard}
                onPress={() => navigation.getParent()?.navigate('Profile')}>
                <Card.Content style={styles.quickActionContent}>
                  <View style={[styles.quickActionIcon, {backgroundColor: '#F3E5F5'}]}>
                    <Icon name="account" size={28} color="#9C27B0" />
                  </View>
                  <Text variant="bodySmall" style={styles.quickActionText}>
                    Profil
                  </Text>
                </Card.Content>
              </Card>

              {user?.role === 'Administrator' && (
                <Card 
                  style={styles.quickActionCard}
                  onPress={() => navigation.navigate('KycAdmin')}>
                  <Card.Content style={styles.quickActionContent}>
                    <View style={[styles.quickActionIcon, {backgroundColor: '#FFEBEE'}]}>
                      <Icon name="shield-check" size={28} color="#F44336" />
                    </View>
                    <Text variant="bodySmall" style={styles.quickActionText}>
                      KYC Admin
                    </Text>
                  </Card.Content>
                </Card>
              )}
            </View>
          </View>

        {activeApplications.length > 0 && (
          <View style={styles.section}>
            <Text variant="titleMedium" style={styles.sectionTitle}>
              Cereri recente
            </Text>
            {activeApplications.slice(0, 3).map(app => (
              <Card
                key={app.id}
                style={styles.applicationCard}
                onPress={() =>
                  navigation.navigate('ApplicationList', {applicationId: app.id})
                }>
                <Card.Content>
                  <View style={styles.applicationHeader}>
                    <Text variant="titleMedium">
                      {app.typeCredit === 'ipotecar'
                        ? 'Credit Ipotecar'
                        : 'Credit Nevoi Personale'}
                    </Text>
                    <View
                      style={[
                        styles.statusBadge,
                        {backgroundColor: getStatusColor(app.status)},
                      ]}>
                      <Text style={styles.statusText}>{app.status}</Text>
                    </View>
                  </View>
                  <Text variant="bodySmall" style={styles.dateText}>
                    {new Date(app.createdAt).toLocaleDateString('ro-RO')}
                  </Text>
                </Card.Content>
              </Card>
            ))}
          </View>
        )}
        </View>
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FAFAFA',
  },
  scrollView: {
    flex: 1,
  },
  content: {
    padding: 16,
  },
  center: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  headerSection: {
    marginBottom: 20,
    paddingTop: 8,
  },
  welcomeText: {
    fontWeight: '700',
    color: '#212121',
    fontSize: 28,
    letterSpacing: -0.5,
    marginBottom: 6,
  },
  subtitleText: {
    color: '#757575',
    fontSize: 15,
    fontWeight: '400',
  },
  // Simulator Card - Large and Prominent
  simulatorCard: {
    marginBottom: 20,
    borderRadius: 24,
    elevation: 4,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 4},
    shadowOpacity: 0.1,
    shadowRadius: 12,
    backgroundColor: '#FFFFFF',
    borderWidth: 0,
    overflow: 'hidden',
  },
  simulatorCardContent: {
    padding: 24,
  },
  simulatorHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 16,
  },
  simulatorIconContainer: {
    width: 72,
    height: 72,
    borderRadius: 20,
    backgroundColor: '#1976D2',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  simulatorTextContainer: {
    flex: 1,
  },
  simulatorTitle: {
    fontWeight: '700',
    color: '#212121',
    fontSize: 22,
    marginBottom: 4,
  },
  simulatorDescription: {
    color: '#757575',
    fontSize: 14,
    lineHeight: 20,
  },
  simulatorFooter: {
    borderTopWidth: 1,
    borderTopColor: '#E0E0E0',
    paddingTop: 16,
    marginTop: 8,
  },
  simulatorActionText: {
    color: '#1976D2',
    fontWeight: '600',
    fontSize: 14,
  },
  // Stats Grid
  statsGrid: {
    flexDirection: 'row',
    gap: 12,
    marginBottom: 20,
  },
  statCardSmall: {
    flex: 1,
    borderRadius: 20,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 2},
    shadowOpacity: 0.08,
    shadowRadius: 8,
    backgroundColor: '#FFFFFF',
    borderWidth: 0,
  },
  statCardSmallContent: {
    padding: 16,
    alignItems: 'center',
  },
  statIconContainerSmall: {
    width: 48,
    height: 48,
    borderRadius: 16,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 12,
  },
  statNumberSmall: {
    fontWeight: '700',
    color: '#212121',
    fontSize: 24,
    marginBottom: 4,
  },
  statLabelSmall: {
    color: '#757575',
    fontSize: 12,
    textAlign: 'center',
  },
  // Quick Actions
  quickActionsSection: {
    marginBottom: 24,
  },
  quickActionsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 12,
  },
  quickActionCard: {
    width: '47%',
    borderRadius: 20,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 2},
    shadowOpacity: 0.08,
    shadowRadius: 8,
    backgroundColor: '#FFFFFF',
    borderWidth: 0,
  },
  quickActionContent: {
    padding: 20,
    alignItems: 'center',
  },
  quickActionIcon: {
    width: 56,
    height: 56,
    borderRadius: 16,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 12,
  },
  quickActionText: {
    color: '#212121',
    fontWeight: '600',
    fontSize: 13,
    textAlign: 'center',
  },
  section: {
    marginTop: 8,
  },
  sectionTitle: {
    marginBottom: 16,
    fontWeight: '600',
    color: '#212121',
    fontSize: 18,
  },
  applicationCard: {
    marginBottom: 12,
    borderRadius: 16,
    elevation: 1,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 1},
    shadowOpacity: 0.05,
    shadowRadius: 8,
    backgroundColor: '#FFFFFF',
    borderWidth: 0,
  },
  applicationHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  statusBadge: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 16,
  },
  statusText: {
    color: '#fff',
    fontSize: 11,
    fontWeight: '600',
    textTransform: 'uppercase',
  },
  dateText: {
    color: '#999',
    fontSize: 12,
  },
  featuresSection: {
    marginTop: 24,
  },
  featureCard: {
    marginBottom: 12,
    borderRadius: 16,
    elevation: 1,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 1},
    shadowOpacity: 0.05,
    shadowRadius: 8,
    backgroundColor: '#FFFFFF',
    borderWidth: 0,
  },
  featureRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  featureIconContainer: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: '#E3F2FD',
    justifyContent: 'center',
    alignItems: 'center',
  },
  featureContent: {
    flex: 1,
    marginLeft: 16,
  },
  featureTitle: {
    fontWeight: '600',
    color: '#333',
    marginBottom: 4,
  },
  featureDescription: {
    color: '#666',
  },
  featureBadge: {
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 12,
    backgroundColor: '#E8F5E9',
  },
  featureBadgeText: {
    fontSize: 10,
    fontWeight: '600',
    color: '#4CAF50',
  },
  financialSection: {
    marginBottom: 32,
  },
  financialGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    marginBottom: 16,
  },
  financialCard: {
    width: '48%',
    marginBottom: 12,
    borderRadius: 16,
    elevation: 0,
    shadowOpacity: 0,
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: '#E0E0E0',
  },
  financialCardContent: {
    alignItems: 'center',
    paddingVertical: 8,
  },
  financialLabel: {
    marginTop: 8,
    color: '#666',
    textAlign: 'center',
    fontSize: 12,
  },
  financialValue: {
    marginTop: 4,
    fontWeight: '700',
    color: '#333',
    textAlign: 'center',
    fontSize: 18,
  },
  viewDetailsButton: {
    marginTop: 8,
    borderRadius: 12,
  },
  adminButton: {
    backgroundColor: '#1A237E',
  },
});

export default DashboardScreen;

