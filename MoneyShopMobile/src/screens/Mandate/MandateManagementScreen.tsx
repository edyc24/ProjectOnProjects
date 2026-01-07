import React, {useState} from 'react';
import {View, StyleSheet, ScrollView, Alert} from 'react-native';
import {Card, Button, Text, ActivityIndicator, Chip} from 'react-native-paper';
import {useMutation, useQuery, useQueryClient} from '@tanstack/react-query';
import {mandateApi, MandateInfo} from '../../services/api/mandateApi';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

const MandateManagementScreen = ({navigation}: any) => {
  const queryClient = useQueryClient();
  const [selectedType, setSelectedType] = useState<string>('ANAF_BC');

  const {data, isLoading, error} = useQuery({
    queryKey: ['mandates'],
    queryFn: () => mandateApi.listMandates(),
  });

  const createMutation = useMutation({
    mutationFn: mandateApi.createMandate,
    onSuccess: () => {
      queryClient.invalidateQueries({queryKey: ['mandates']});
      Alert.alert('Succes', 'Mandatul a fost creat cu succes');
    },
    onError: (error: any) => {
      Alert.alert('Eroare', error.message || 'Nu s-a putut crea mandatul');
    },
  });

  const revokeMutation = useMutation({
    mutationFn: ({mandateId, reason}: {mandateId: string; reason?: string}) =>
      mandateApi.revokeMandate(mandateId, reason),
    onSuccess: () => {
      queryClient.invalidateQueries({queryKey: ['mandates']});
      Alert.alert('Succes', 'Mandatul a fost revocat cu succes');
    },
    onError: (error: any) => {
      Alert.alert('Eroare', error.message || 'Nu s-a putut revoca mandatul');
    },
  });

  const handleCreateMandate = (mandateType: string) => {
    Alert.alert(
      'Confirmare',
      `Doriți să creați un mandat de tip ${mandateType}?`,
      [
        {text: 'Anulează', style: 'cancel'},
        {
          text: 'Creează',
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
      'Confirmare',
      'Sigur doriți să revocați acest mandat?',
      [
        {text: 'Anulează', style: 'cancel'},
        {
          text: 'Revocă',
          style: 'destructive',
          onPress: () => revokeMutation.mutate({mandateId}),
        },
      ],
    );
  };

  const mandateTypes = [
    {type: 'ANAF', title: 'ANAF', description: 'Mandat pentru ANAF', icon: 'office-building'},
    {type: 'BC', title: 'Biroul de Credit', description: 'Mandat pentru Biroul de Credit', icon: 'bank'},
    {
      type: 'ANAF_BC',
      title: 'ANAF & Biroul de Credit',
      description: 'Mandat pentru ANAF și Biroul de Credit',
      icon: 'file-document-multiple',
    },
  ];

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active':
        return '#4CAF50';
      case 'expired':
        return '#FF9800';
      case 'revoked':
        return '#D32F2F';
      default:
        return '#999';
    }
  };

  const getStatusText = (status: string) => {
    switch (status) {
      case 'active':
        return 'Activ';
      case 'expired':
        return 'Expirat';
      case 'revoked':
        return 'Revocat';
      default:
        return status;
    }
  };

  if (isLoading) {
    return (
      <View style={styles.centerContainer}>
        <ActivityIndicator size="large" color="#1976D2" />
      </View>
    );
  }

  const activeMandates = data?.mandates?.filter(m => m.status === 'active') || [];
  const allMandates = data?.mandates || [];

  return (
    <View style={styles.container}>
      <ScrollView style={styles.scrollView}>
        <View style={styles.content}>
          <Text variant="headlineSmall" style={styles.title}>
            Gestionare Mandate
          </Text>
          <Text variant="bodyMedium" style={styles.subtitle}>
            Creează sau gestionează mandatele pentru ANAF și Biroul de Credit
          </Text>

          {/* Create New Mandate Section */}
          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                Creează Mandat Nou
              </Text>
              {mandateTypes.map((mandateType, index) => {
                const hasActive = activeMandates.some(m => m.mandateType === mandateType.type);
                return (
                  <View key={index} style={styles.mandateTypeRow}>
                    <View style={styles.mandateTypeInfo}>
                      <Icon name={mandateType.icon} size={24} color="#1976D2" />
                      <View style={styles.mandateTypeText}>
                        <Text variant="titleSmall">{mandateType.title}</Text>
                        <Text variant="bodySmall" style={styles.description}>
                          {mandateType.description}
                        </Text>
                      </View>
                    </View>
                    {hasActive ? (
                      <Chip icon="check-circle" style={styles.activeChip}>
                        Activ
                      </Chip>
                    ) : (
                      <Button
                        mode="contained"
                        compact
                        onPress={() => handleCreateMandate(mandateType.type)}
                        loading={createMutation.isPending}
                        disabled={createMutation.isPending}>
                        Creează
                      </Button>
                    )}
                  </View>
                );
              })}
            </Card.Content>
          </Card>

          {/* Existing Mandates Section */}
          {allMandates.length > 0 && (
            <Card style={styles.card}>
              <Card.Content>
                <Text variant="titleMedium" style={styles.sectionTitle}>
                  Mandate Existente
                </Text>
                {allMandates.map((mandate: MandateInfo) => (
                  <View key={mandate.mandateId} style={styles.mandateItem}>
                    <View style={styles.mandateHeader}>
                      <View style={styles.mandateInfo}>
                        <Text variant="titleSmall">{mandate.mandateType}</Text>
                        <Text variant="bodySmall" style={styles.description}>
                          Creat: {new Date(mandate.grantedAt).toLocaleDateString('ro-RO')}
                        </Text>
                        <Text variant="bodySmall" style={styles.description}>
                          Expiră: {new Date(mandate.expiresAt).toLocaleDateString('ro-RO')}
                        </Text>
                      </View>
                      <Chip
                        style={[
                          styles.statusChip,
                          {backgroundColor: getStatusColor(mandate.status) + '20'},
                        ]}
                        textStyle={{color: getStatusColor(mandate.status)}}>
                        {getStatusText(mandate.status)}
                      </Chip>
                    </View>
                    {mandate.status === 'active' && (
                      <Button
                        mode="outlined"
                        compact
                        onPress={() => handleRevokeMandate(mandate.mandateId)}
                        loading={revokeMutation.isPending}
                        disabled={revokeMutation.isPending}
                        style={styles.revokeButton}
                        textColor="#D32F2F">
                        Revocă
                      </Button>
                    )}
                  </View>
                ))}
              </Card.Content>
            </Card>
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
  },
  title: {
    marginBottom: 8,
    fontWeight: '600',
    color: '#333',
  },
  subtitle: {
    marginBottom: 24,
    color: '#666',
  },
  card: {
    marginBottom: 16,
    borderRadius: 16,
    elevation: 0,
    shadowOpacity: 0,
    backgroundColor: '#FFFFFF',
    borderWidth: 0,
  },
  sectionTitle: {
    marginBottom: 16,
    fontWeight: '600',
    color: '#333',
  },
  mandateTypeRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 16,
    paddingBottom: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#E0E0E0',
  },
  mandateTypeInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  mandateTypeText: {
    marginLeft: 12,
    flex: 1,
  },
  description: {
    color: '#666',
    marginTop: 4,
  },
  activeChip: {
    backgroundColor: '#E8F5E9',
  },
  mandateItem: {
    marginBottom: 16,
    paddingBottom: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#E0E0E0',
  },
  mandateHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 8,
  },
  mandateInfo: {
    flex: 1,
  },
  statusChip: {
    marginLeft: 8,
  },
  revokeButton: {
    marginTop: 8,
    alignSelf: 'flex-start',
  },
});

export default MandateManagementScreen;

