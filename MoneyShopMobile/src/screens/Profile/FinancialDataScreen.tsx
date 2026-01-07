import React from 'react';
import {View, StyleSheet, ScrollView, RefreshControl} from 'react-native';
import {
  Card,
  Text,
  ActivityIndicator,
  Chip,
  Divider,
} from 'react-native-paper';
import {useQuery} from '@tanstack/react-query';
import {userFinancialDataApi} from '../../services/api/userFinancialDataApi';
import CustomHeader from '../../components/CustomHeader';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

const FinancialDataScreen = ({navigation}: any) => {
  const {
    data: financialData,
    isLoading,
    refetch,
    isRefetching,
  } = useQuery({
    queryKey: ['userFinancialData'],
    queryFn: userFinancialDataApi.getMyData,
    retry: false,
  });

  const formatCurrency = (value?: number) => {
    if (value == null) return 'N/A';
    return `${value.toLocaleString('ro-RO')} lei`;
  };

  const formatPercentage = (value?: number) => {
    if (value == null) return 'N/A';
    return `${(value * 100).toFixed(1)}%`;
  };

  const getScoringColor = (level?: string) => {
    switch (level?.toLowerCase()) {
      case 'foarte_ridicat':
      case 'ridicat':
        return '#4CAF50';
      case 'mediu':
        return '#FF9800';
      case 'scazut':
      case 'foarte_scazut':
        return '#F44336';
      default:
        return '#9E9E9E';
    }
  };

  const getScoringLabel = (level?: string) => {
    switch (level?.toLowerCase()) {
      case 'foarte_ridicat':
        return 'Foarte Ridicat';
      case 'ridicat':
        return 'Ridicat';
      case 'mediu':
        return 'Mediu';
      case 'scazut':
        return 'Scăzut';
      case 'foarte_scazut':
        return 'Foarte Scăzut';
      default:
        return 'N/A';
    }
  };

  if (isLoading) {
    return (
      <View style={styles.container}>
        <CustomHeader navigation={navigation} title="Date Financiare" />
        <View style={styles.centerContainer}>
          <ActivityIndicator size="large" color="#1976D2" />
        </View>
      </View>
    );
  }

  if (!financialData) {
    return (
      <View style={styles.container}>
        <CustomHeader navigation={navigation} title="Date Financiare" />
        <View style={styles.centerContainer}>
          <Icon name="chart-line" size={64} color="#999" />
          <Text variant="titleMedium" style={styles.emptyText}>
            Nu ai date financiare salvate
          </Text>
          <Text variant="bodySmall" style={styles.emptySubtext}>
            Completează simulatorul pentru a salva datele tale
          </Text>
        </View>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <CustomHeader navigation={navigation} title="Date Financiare" />
      <ScrollView
        style={styles.scrollView}
        refreshControl={
          <RefreshControl refreshing={isRefetching} onRefresh={refetch} />
        }>
        <View style={styles.content}>
          {/* Venituri Section */}
          <Card style={styles.card}>
            <Card.Content>
              <View style={styles.cardHeader}>
                <Icon name="cash-multiple" size={24} color="#4CAF50" />
                <Text variant="titleLarge" style={styles.cardTitle}>
                  Venituri
                </Text>
              </View>
              <Divider style={styles.divider} />
              <View style={styles.dataRow}>
                <Text variant="bodyMedium" style={styles.label}>
                  Salariu Net
                </Text>
                <Text variant="titleMedium" style={styles.value}>
                  {formatCurrency(financialData.salariuNet)}
                </Text>
              </View>
              {financialData.bonuriMasa && (
                <View style={styles.dataRow}>
                  <Text variant="bodyMedium" style={styles.label}>
                    Bonuri de masă
                  </Text>
                  <Text variant="titleMedium" style={styles.value}>
                    {formatCurrency(financialData.sumaBonuriMasa)}
                  </Text>
                </View>
              )}
              <View style={[styles.dataRow, styles.totalRow]}>
                <Text variant="titleMedium" style={styles.totalLabel}>
                  Venit Total
                </Text>
                <Text variant="headlineSmall" style={styles.totalValue}>
                  {formatCurrency(financialData.venitTotal)}
                </Text>
              </View>
            </Card.Content>
          </Card>

          {/* Credite Section */}
          <Card style={styles.card}>
            <Card.Content>
              <View style={styles.cardHeader}>
                <Icon name="credit-card" size={24} color="#FF9800" />
                <Text variant="titleLarge" style={styles.cardTitle}>
                  Credite Existente
                </Text>
              </View>
              <Divider style={styles.divider} />
              <View style={styles.dataRow}>
                <Text variant="bodyMedium" style={styles.label}>
                  Sold Total
                </Text>
                <Text variant="titleMedium" style={styles.value}>
                  {formatCurrency(financialData.soldTotal)}
                </Text>
              </View>
              <View style={styles.dataRow}>
                <Text variant="bodyMedium" style={styles.label}>
                  Rata Totală Lunară
                </Text>
                <Text variant="titleMedium" style={styles.value}>
                  {formatCurrency(financialData.rataTotalaLunara)}
                </Text>
              </View>
              <View style={styles.dataRow}>
                <Text variant="bodyMedium" style={styles.label}>
                  Număr Credite Bănci
                </Text>
                <Text variant="titleMedium" style={styles.value}>
                  {financialData.nrCrediteBanci ?? 'N/A'}
                </Text>
              </View>
              <View style={styles.dataRow}>
                <Text variant="bodyMedium" style={styles.label}>
                  Număr IFN
                </Text>
                <Text variant="titleMedium" style={styles.value}>
                  {financialData.nrIfn ?? 'N/A'}
                </Text>
              </View>
            </Card.Content>
          </Card>

          {/* Scoring Section */}
          <Card style={styles.card}>
            <Card.Content>
              <View style={styles.cardHeader}>
                <Icon name="chart-bar" size={24} color="#1976D2" />
                <Text variant="titleLarge" style={styles.cardTitle}>
                  Scoring & Eligibilitate
                </Text>
              </View>
              <Divider style={styles.divider} />
              <View style={styles.dataRow}>
                <Text variant="bodyMedium" style={styles.label}>
                  DTI (Debt-to-Income)
                </Text>
                <Text variant="titleMedium" style={styles.value}>
                  {formatPercentage(financialData.dti)}
                </Text>
              </View>
              <View style={styles.dataRow}>
                <Text variant="bodyMedium" style={styles.label}>
                  Nivel Scoring
                </Text>
                <Chip
                  style={[
                    styles.chip,
                    {
                      backgroundColor: getScoringColor(
                        financialData.scoringLevel,
                      ) + '20',
                    },
                  ]}
                  textStyle={{
                    color: getScoringColor(financialData.scoringLevel),
                    fontWeight: '600',
                  }}>
                  {getScoringLabel(financialData.scoringLevel)}
                </Chip>
              </View>
              <View style={styles.dataRow}>
                <Text variant="bodyMedium" style={styles.label}>
                  Nivel Recomandat
                </Text>
                <Text variant="titleMedium" style={styles.value}>
                  {financialData.recommendedLevel ?? 'N/A'}
                </Text>
              </View>
            </Card.Content>
          </Card>

          {/* Status Section */}
          <Card style={styles.card}>
            <Card.Content>
              <View style={styles.cardHeader}>
                <Icon name="alert-circle" size={24} color="#F44336" />
                <Text variant="titleLarge" style={styles.cardTitle}>
                  Status
                </Text>
              </View>
              <Divider style={styles.divider} />
              <View style={styles.dataRow}>
                <Text variant="bodyMedium" style={styles.label}>
                  Poprire
                </Text>
                <Chip
                  style={[
                    styles.chip,
                    {
                      backgroundColor: financialData.poprire
                        ? '#F4433620'
                        : '#4CAF5020',
                    },
                  ]}
                  textStyle={{
                    color: financialData.poprire ? '#F44336' : '#4CAF50',
                  }}>
                  {financialData.poprire ? 'Da' : 'Nu'}
                </Chip>
              </View>
              <View style={styles.dataRow}>
                <Text variant="bodyMedium" style={styles.label}>
                  Întârzieri
                </Text>
                <Chip
                  style={[
                    styles.chip,
                    {
                      backgroundColor: financialData.intarzieri
                        ? '#F4433620'
                        : '#4CAF5020',
                    },
                  ]}
                  textStyle={{
                    color: financialData.intarzieri ? '#F44336' : '#4CAF50',
                  }}>
                  {financialData.intarzieri
                    ? `Da (${financialData.intarzieriNumar ?? 0})`
                    : 'Nu'}
                </Chip>
              </View>
            </Card.Content>
          </Card>

          {/* Last Updated */}
          {financialData.lastUpdated && (
            <Text variant="bodySmall" style={styles.lastUpdated}>
              Ultima actualizare:{' '}
              {new Date(financialData.lastUpdated).toLocaleString('ro-RO')}
            </Text>
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
    padding: 20,
  },
  centerContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 32,
  },
  emptyText: {
    marginTop: 16,
    color: '#666',
    textAlign: 'center',
  },
  emptySubtext: {
    marginTop: 8,
    color: '#999',
    textAlign: 'center',
  },
  card: {
    marginBottom: 16,
    borderRadius: 16,
    elevation: 0,
    shadowOpacity: 0,
    backgroundColor: '#FFFFFF',
    borderWidth: 0,
  },
  cardHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  cardTitle: {
    marginLeft: 12,
    fontWeight: '600',
    color: '#333',
  },
  divider: {
    marginBottom: 16,
  },
  dataRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  label: {
    color: '#666',
    flex: 1,
  },
  value: {
    fontWeight: '600',
    color: '#333',
  },
  totalRow: {
    marginTop: 8,
    paddingTop: 16,
    borderTopWidth: 1,
    borderTopColor: '#E0E0E0',
  },
  totalLabel: {
    fontWeight: '600',
    color: '#333',
  },
  totalValue: {
    fontWeight: '700',
    color: '#4CAF50',
  },
  chip: {
    height: 32,
  },
  lastUpdated: {
    textAlign: 'center',
    color: '#999',
    marginTop: 8,
    marginBottom: 16,
  },
});

export default FinancialDataScreen;

