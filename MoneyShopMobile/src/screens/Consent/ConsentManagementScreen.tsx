import React, {useEffect, useState} from 'react';
import {View, StyleSheet, ScrollView, Alert} from 'react-native';
import {Card, Button, Text, Checkbox, ActivityIndicator} from 'react-native-paper';
import {useMutation, useQuery, useQueryClient} from '@tanstack/react-query';
import {consentApi, ConsentInfo} from '../../services/api/consentApi';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

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
      Alert.alert('Succes', 'Consimțământul a fost acordat cu succes');
    },
    onError: (error: any) => {
      Alert.alert('Eroare', error.message || 'Nu s-a putut acorda consimțământul');
    },
  });

  const revokeMutation = useMutation({
    mutationFn: consentApi.revokeConsent,
    onSuccess: () => {
      queryClient.invalidateQueries({queryKey: ['consents']});
      Alert.alert('Succes', 'Consimțământul a fost revocat cu succes');
    },
    onError: (error: any) => {
      Alert.alert('Eroare', error.message || 'Nu s-a putut revoca consimțământul');
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

  const handleGrantConsent = (consentType: string, docType: string, docVersion: string) => {
    const consentText = `Consimțământ pentru ${consentType}`;
    grantMutation.mutate({
      consentType,
      docType,
      docVersion,
      consentTextSnapshot: consentText,
      sourceChannel: 'web',
    });
  };

  const handleRevokeConsent = (consentId: string) => {
    Alert.alert(
      'Confirmare',
      'Sigur doriți să revocați acest consimțământ?',
      [
        {text: 'Anulează', style: 'cancel'},
        {
          text: 'Revocă',
          style: 'destructive',
          onPress: () => revokeMutation.mutate(consentId),
        },
      ],
    );
  };

  const consentTypes = [
    {
      type: 'TC_ACCEPT',
      docType: 'TC',
      docVersion: '1.0.0',
      title: 'Termeni și Condiții',
      description: 'Acceptarea termenilor și condițiilor de utilizare',
      icon: 'file-document',
    },
    {
      type: 'GDPR_ACCEPT',
      docType: 'GDPR',
      docVersion: '1.0.0',
      title: 'Politica de Confidențialitate',
      description: 'Consimțământ pentru prelucrarea datelor personale',
      icon: 'shield-lock',
    },
    {
      type: 'MANDATE_ANAF_BC',
      docType: 'MANDATE',
      docVersion: '1.0.0',
      title: 'Mandat ANAF & Biroul de Credit',
      description: 'Consimțământ pentru mandatarea ANAF și Biroul de Credit',
      icon: 'file-sign',
    },
    {
      type: 'COSTS_ACCEPT',
      docType: 'MANDATE',
      docVersion: '1.0.0',
      title: 'Acceptare Costuri',
      description: 'Consimțământ pentru acceptarea costurilor',
      icon: 'currency-usd',
    },
    {
      type: 'SHARE_TO_BROKER',
      docType: 'BROKER_TRANSFER',
      docVersion: '1.0.0',
      title: 'Transmitere Date Brokeri',
      description: 'Consimțământ pentru transmiterea datelor către brokeri',
      icon: 'file-send',
    },
  ];

  if (isLoading) {
    return (
      <View style={styles.centerContainer}>
        <ActivityIndicator size="large" color="#1976D2" />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <ScrollView style={styles.scrollView}>
        <View style={styles.content}>
          <Text variant="headlineSmall" style={styles.title}>
            Gestionare Consimțământ
          </Text>
          <Text variant="bodyMedium" style={styles.subtitle}>
            Acordă sau revocă consimțământul pentru diferite servicii
          </Text>

          {consentTypes.map((consent, index) => {
            const isGranted = acceptedConsents.has(consent.type);
            const existingConsent = data?.consents?.find(
              c => c.consentType === consent.type && c.status === 'granted',
            );

            return (
              <Card key={index} style={styles.card}>
                <Card.Content>
                  <View style={styles.consentHeader}>
                    <Icon name={consent.icon} size={32} color="#1976D2" />
                    <View style={styles.consentInfo}>
                      <Text variant="titleMedium">{consent.title}</Text>
                      <Text variant="bodySmall" style={styles.description}>
                        {consent.description}
                      </Text>
                    </View>
                    {isGranted && (
                      <View style={styles.statusBadge}>
                        <Icon name="check-circle" size={20} color="#4CAF50" />
                        <Text style={styles.statusText}>Acordat</Text>
                      </View>
                    )}
                  </View>

                  <View style={styles.actions}>
                    {!isGranted ? (
                      <Button
                        mode="contained"
                        onPress={() =>
                          handleGrantConsent(consent.type, consent.docType, consent.docVersion)
                        }
                        loading={grantMutation.isPending}
                        disabled={grantMutation.isPending}
                        style={styles.button}>
                        Acordă Consimțământ
                      </Button>
                    ) : (
                      <Button
                        mode="outlined"
                        onPress={() => existingConsent && handleRevokeConsent(existingConsent.consentId)}
                        loading={revokeMutation.isPending}
                        disabled={revokeMutation.isPending}
                        style={styles.button}
                        textColor="#D32F2F">
                        Revocă Consimțământ
                      </Button>
                    )}
                  </View>

                  {existingConsent && (
                    <Text variant="bodySmall" style={styles.dateText}>
                      Acordat la:{' '}
                      {new Date(existingConsent.grantedAt).toLocaleDateString('ro-RO')}
                    </Text>
                  )}
                </Card.Content>
              </Card>
            );
          })}
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
  consentHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 16,
  },
  consentInfo: {
    flex: 1,
    marginLeft: 12,
  },
  description: {
    color: '#666',
    marginTop: 4,
  },
  statusBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#E8F5E9',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 12,
  },
  statusText: {
    marginLeft: 4,
    color: '#4CAF50',
    fontSize: 12,
    fontWeight: '600',
  },
  actions: {
    marginTop: 8,
  },
  button: {
    marginTop: 8,
  },
  dateText: {
    marginTop: 8,
    color: '#999',
    fontStyle: 'italic',
  },
});

export default ConsentManagementScreen;

