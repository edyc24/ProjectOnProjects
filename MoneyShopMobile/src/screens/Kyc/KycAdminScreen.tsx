import React, {useState, useEffect} from 'react';
import {
  View,
  StyleSheet,
  ScrollView,
  RefreshControl,
  Image,
  Alert,
  Modal,
  TextInput as RNTextInput,
  TouchableOpacity,
  Platform,
  Pressable,
} from 'react-native';
import {
  Card,
  Text,
  Button,
  ActivityIndicator,
  Dialog,
  Portal,
  Paragraph,
} from 'react-native-paper';
import {useQuery, useMutation, useQueryClient} from '@tanstack/react-query';
import {kycApi, KycPending, KycDetails} from '../../services/api/kycApi';
import CustomHeader from '../../components/CustomHeader';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import {NativeStackNavigationProp} from '@react-navigation/native-stack';

type KycAdminScreenNavigationProp = NativeStackNavigationProp<any>;

interface Props {
  navigation: KycAdminScreenNavigationProp;
}

// Type declaration for window on web
declare const window: {
  confirm?: (message?: string) => boolean;
  prompt?: (message?: string, defaultValue?: string) => string | null;
} | undefined;

const KycAdminScreen: React.FC<Props> = ({navigation}) => {
  const queryClient = useQueryClient();
  const [selectedKyc, setSelectedKyc] = useState<KycDetails | null>(null);
  const [showDetailsModal, setShowDetailsModal] = useState(false);
  const [showRejectDialog, setShowRejectDialog] = useState(false);
  const [rejectionReason, setRejectionReason] = useState('');
  const [selectedKycId, setSelectedKycId] = useState<string | null>(null);
  const [viewingFile, setViewingFile] = useState<string | null>(null);

  const {
    data: pendingKyc,
    isLoading,
    refetch,
    isRefetching,
  } = useQuery({
    queryKey: ['kyc-pending'],
    queryFn: () => kycApi.getAllPending(),
    select: (data) => Array.isArray(data) ? data : [], // Ensure it's always an array
  });

  const approveMutation = useMutation({
    mutationFn: (kycId: string) => {
      console.log('[KycAdmin] Approving KYC:', kycId);
      return kycApi.updateStatus(kycId, 'verified');
    },
    onSuccess: () => {
      console.log('[KycAdmin] KYC approved successfully');
      queryClient.invalidateQueries({queryKey: ['kyc-pending']});
      setShowDetailsModal(false);
      setSelectedKyc(null);
      Alert.alert('Succes', 'KYC-ul a fost aprobat cu succes!');
    },
    onError: (error: any) => {
      console.error('[KycAdmin] Error approving KYC:', error);
      Alert.alert(
        'Eroare',
        error.response?.data?.message || error.message || 'Eroare la aprobarea KYC-ului',
      );
    },
  });

  const rejectMutation = useMutation({
    mutationFn: ({kycId, reason}: {kycId: string; reason: string}) => {
      console.log('[KycAdmin] Rejecting KYC:', kycId, 'Reason:', reason);
      return kycApi.updateStatus(kycId, 'rejected', reason);
    },
    onSuccess: () => {
      console.log('[KycAdmin] KYC rejected successfully');
      queryClient.invalidateQueries({queryKey: ['kyc-pending']});
      setShowRejectDialog(false);
      setShowDetailsModal(false);
      setSelectedKyc(null);
      setRejectionReason('');
      Alert.alert('Succes', 'KYC-ul a fost respins!');
    },
    onError: (error: any) => {
      console.error('[KycAdmin] Error rejecting KYC:', error);
      Alert.alert(
        'Eroare',
        error.response?.data?.message || error.message || 'Eroare la respingerea KYC-ului',
      );
    },
  });

  const loadKycDetails = async (kycId: string) => {
    try {
      const details = await kycApi.getDetails(kycId);
      setSelectedKyc(details);
      setShowDetailsModal(true);
    } catch (error: any) {
      Alert.alert(
        'Eroare',
        error.response?.data?.message || 'Eroare la încărcarea detaliilor',
      );
    }
  };

  const handleApprove = (kycId: string) => {
    console.log('[KycAdmin] handleApprove called with kycId:', kycId);
    
    // On web, use window.confirm; on mobile, use Alert.alert
    if (Platform.OS === 'web') {
      const win = typeof window !== 'undefined' ? window : null;
      const confirmed = win?.confirm?.('Ești sigur că vrei să aprobi acest KYC? Pozele vor fi șterse permanent.') ?? false;
      if (confirmed) {
        console.log('[KycAdmin] Approve confirmed (web), calling mutation with kycId:', kycId);
        approveMutation.mutate(kycId);
      } else {
        console.log('[KycAdmin] Approve cancelled (web)');
      }
    } else {
      Alert.alert(
        'Confirmare',
        'Ești sigur că vrei să aprobi acest KYC? Pozele vor fi șterse permanent.',
        [
          {text: 'Anulează', style: 'cancel', onPress: () => console.log('[KycAdmin] Approve cancelled')},
          {
            text: 'Aprobă',
            style: 'default',
            onPress: () => {
              console.log('[KycAdmin] Approve confirmed, calling mutation with kycId:', kycId);
              approveMutation.mutate(kycId);
            },
          },
        ],
      );
    }
  };

  const handleReject = (kycId: string) => {
    console.log('[KycAdmin] handleReject called with kycId:', kycId);
    
    // On web, use prompt; on mobile, use Dialog
    if (Platform.OS === 'web') {
      const win = typeof window !== 'undefined' ? window : null;
      const reason = win?.prompt?.('Introdu motivul pentru care respingi acest KYC. Mesajul va fi vizibil utilizatorului.') ?? null;
      if (reason && reason.trim()) {
        console.log('[KycAdmin] Reject confirmed (web), calling mutation with kycId:', kycId, 'reason:', reason.trim());
        rejectMutation.mutate({
          kycId: kycId,
          reason: reason.trim(),
        });
      } else if (reason !== null) {
        // User pressed OK but didn't enter a reason
        Alert.alert('Eroare', 'Trebuie să introduci un motiv pentru respingere');
      } else {
        console.log('[KycAdmin] Reject cancelled (web)');
      }
    } else {
      setSelectedKycId(kycId);
      setRejectionReason('');
      setShowRejectDialog(true);
      console.log('[KycAdmin] Reject dialog should be visible now');
    }
  };

  const submitRejection = () => {
    console.log('[KycAdmin] submitRejection called, selectedKycId:', selectedKycId, 'reason:', rejectionReason);
    if (!rejectionReason.trim()) {
      Alert.alert('Eroare', 'Trebuie să introduci un motiv pentru respingere');
      return;
    }

    if (!selectedKycId) {
      console.error('[KycAdmin] No selectedKycId for rejection');
      Alert.alert('Eroare', 'Nu s-a selectat un KYC pentru respingere');
      return;
    }

    console.log('[KycAdmin] Calling rejectMutation with:', { kycId: selectedKycId, reason: rejectionReason.trim() });
    rejectMutation.mutate({
      kycId: selectedKycId,
      reason: rejectionReason.trim(),
    });
  };

  const viewFile = async (fileId: string) => {
    try {
      const fileData = await kycApi.getFile(fileId);
      // Use dataUri if available, otherwise construct from base64
      const imageUri = fileData.dataUri || `data:${fileData.mimeType};base64,${fileData.fileContentBase64}`;
      setViewingFile(imageUri);
    } catch (error) {
      console.error('Error loading file:', error);
      Alert.alert('Eroare', 'Nu s-a putut încărca fișierul');
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
          <Card style={styles.headerCard}>
            <Card.Content>
              <Text variant="headlineSmall" style={styles.title}>
                Verificări KYC în Așteptare
              </Text>
              <Text variant="bodyMedium" style={styles.subtitle}>
                {pendingKyc?.length || 0} cereri în așteptare
              </Text>
            </Card.Content>
          </Card>

          {!pendingKyc || pendingKyc.length === 0 ? (
            <Card style={styles.card}>
              <Card.Content>
                <View style={styles.emptyContainer}>
                  <Icon name="check-circle" size={64} color="#4CAF50" />
                  <Text variant="titleMedium" style={styles.emptyText}>
                    Nu există cereri KYC în așteptare
                  </Text>
                </View>
              </Card.Content>
            </Card>
          ) : (
            (Array.isArray(pendingKyc) ? pendingKyc : []).map(kyc => (
              <Card
                key={kyc.kycId}
                style={styles.card}
                onPress={() => loadKycDetails(kyc.kycId)}>
                <Card.Content>
                  <View style={styles.kycItem}>
                    <View style={styles.kycInfo}>
                      <Text variant="titleMedium" style={styles.userName}>
                        {kyc.userName}
                      </Text>
                      <Text variant="bodySmall" style={styles.userEmail}>
                        {kyc.userEmail}
                      </Text>
                      <View style={styles.metaRow}>
                        <Icon name="file-document" size={16} color="#666" />
                        <Text variant="bodySmall" style={styles.metaText}>
                          {kyc.fileCount} fișier(e)
                        </Text>
                        <Icon name="clock" size={16} color="#666" />
                        <Text variant="bodySmall" style={styles.metaText}>
                          {new Date(kyc.createdAt).toLocaleDateString('ro-RO')}
                        </Text>
                      </View>
                    </View>
                    <Icon name="chevron-right" size={24} color="#999" />
                  </View>
                </Card.Content>
              </Card>
            ))
          )}
        </View>
      </ScrollView>

      {/* Details Modal */}
      <Modal
        visible={showDetailsModal}
        animationType="slide"
        onRequestClose={() => {
          setShowDetailsModal(false);
          setSelectedKyc(null);
        }}>
        <View style={styles.modalContainer}>
          <CustomHeader
            title="Detalii KYC"
            onBack={() => {
              setShowDetailsModal(false);
              setSelectedKyc(null);
            }}
            showLogo={false}
          />
          <ScrollView 
            style={styles.modalContent}
            contentContainerStyle={{paddingBottom: 24}}
            keyboardShouldPersistTaps="handled">
            {selectedKyc && (
              <>
                <Card style={styles.card}>
                  <Card.Content>
                    <Text variant="titleMedium" style={styles.sectionTitle}>
                      Informații Utilizator
                    </Text>
                    <Text variant="bodyMedium">
                      <Text style={styles.label}>Nume: </Text>
                      {selectedKyc.userName}
                    </Text>
                    <Text variant="bodyMedium">
                      <Text style={styles.label}>Email: </Text>
                      {selectedKyc.userEmail}
                    </Text>
                    <Text variant="bodyMedium">
                      <Text style={styles.label}>Status: </Text>
                      <Text
                        style={[
                          styles.statusBadge,
                          selectedKyc.status === 'pending'
                            ? styles.statusPending
                            : styles.statusRejected,
                        ]}>
                        {selectedKyc.status === 'pending'
                          ? 'În așteptare'
                          : 'Respins'}
                      </Text>
                    </Text>
                    <Text variant="bodySmall" style={styles.dateText}>
                      Creat: {new Date(selectedKyc.createdAt).toLocaleString('ro-RO')}
                    </Text>
                  </Card.Content>
                </Card>

                <Card style={styles.card}>
                  <Card.Content>
                    <Text variant="titleMedium" style={styles.sectionTitle}>
                      Fișiere încărcate
                    </Text>
                    {selectedKyc.files.map(file => (
                      <View key={file.fileId} style={styles.fileItem}>
                        <Icon
                          name="file-image"
                          size={24}
                          color="#1976D2"
                          style={styles.fileIcon}
                        />
                        <View style={styles.fileInfo}>
                          <Text variant="bodyMedium">{file.fileName}</Text>
                          <Text variant="bodySmall" style={styles.fileType}>
                            {file.fileType}
                          </Text>
                        </View>
                        <Button
                          mode="outlined"
                          compact
                          onPress={() => viewFile(file.fileId)}>
                          Vezi
                        </Button>
                      </View>
                    ))}
                  </Card.Content>
                </Card>
              </>
            )}
          </ScrollView>
          {/* Action buttons outside ScrollView to ensure they work */}
          {selectedKyc && (
            <View style={styles.actionButtonsContainer}>
              <Button
                mode="contained"
                icon="check-circle"
                onPress={() => {
                  console.log('[KycAdmin] ===== APPROVE BUTTON PRESSED =====');
                  console.log('[KycAdmin] selectedKyc:', selectedKyc);
                  console.log('[KycAdmin] kycId:', selectedKyc?.kycId);
                  if (selectedKyc?.kycId) {
                    handleApprove(selectedKyc.kycId);
                  }
                }}
                loading={approveMutation.isPending}
                disabled={approveMutation.isPending || rejectMutation.isPending || !selectedKyc?.kycId}
                style={[styles.actionButton, styles.approveButton]}>
                Aprobă
              </Button>
              <Button
                mode="outlined"
                icon="close-circle"
                onPress={() => {
                  console.log('[KycAdmin] ===== REJECT BUTTON PRESSED =====');
                  console.log('[KycAdmin] selectedKyc:', selectedKyc);
                  console.log('[KycAdmin] kycId:', selectedKyc?.kycId);
                  if (selectedKyc?.kycId) {
                    handleReject(selectedKyc.kycId);
                  }
                }}
                loading={rejectMutation.isPending}
                disabled={approveMutation.isPending || rejectMutation.isPending || !selectedKyc?.kycId}
                style={[styles.actionButton, styles.rejectButton]}
                textColor="#F44336">
                Respinge
              </Button>
            </View>
          )}
        </View>
      </Modal>

      {/* Image Viewer Modal */}
      <Modal
        visible={!!viewingFile}
        animationType="fade"
        onRequestClose={() => setViewingFile(null)}>
        <View style={styles.imageModalContainer}>
          <CustomHeader
            title="Vizualizare Imagine"
            onBack={() => setViewingFile(null)}
            showLogo={false}
          />
          {viewingFile && (
            <Image
              source={{uri: viewingFile}}
              style={styles.fullImage}
              resizeMode="contain"
            />
          )}
        </View>
      </Modal>

      {/* Rejection Dialog - Only for mobile */}
      {Platform.OS !== 'web' && (
        <Portal>
          <Dialog
            visible={showRejectDialog}
            onDismiss={() => {
              setShowRejectDialog(false);
              setRejectionReason('');
            }}>
            <Dialog.Title>Respinge KYC</Dialog.Title>
            <Dialog.Content>
              <Paragraph>
                Introdu motivul pentru care respingi acest KYC. Mesajul va fi
                vizibil utilizatorului.
              </Paragraph>
              <RNTextInput
                style={styles.rejectionInput}
                placeholder="Motivul respingerii..."
                value={rejectionReason}
                onChangeText={setRejectionReason}
                multiline
                numberOfLines={4}
              />
            </Dialog.Content>
            <Dialog.Actions>
              <Button
                onPress={() => {
                  setShowRejectDialog(false);
                  setRejectionReason('');
                }}>
                Anulează
              </Button>
              <Button
                onPress={submitRejection}
                loading={rejectMutation.isPending}
                textColor="#F44336">
                Respinge
              </Button>
            </Dialog.Actions>
          </Dialog>
        </Portal>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F5F7FA',
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
  headerCard: {
    marginBottom: 16,
    borderRadius: 16,
    backgroundColor: '#FFFFFF',
    elevation: 1,
  },
  title: {
    fontWeight: '700',
    color: '#1A1A1A',
    marginBottom: 4,
  },
  subtitle: {
    color: '#6B7280',
  },
  card: {
    marginBottom: 12,
    borderRadius: 16,
    elevation: 1,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 1},
    shadowOpacity: 0.05,
    shadowRadius: 8,
    backgroundColor: '#FFFFFF',
  },
  kycItem: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  kycInfo: {
    flex: 1,
  },
  userName: {
    fontWeight: '600',
    color: '#1A1A1A',
    marginBottom: 4,
  },
  userEmail: {
    color: '#6B7280',
    marginBottom: 8,
  },
  metaRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  metaText: {
    color: '#666',
    marginRight: 12,
  },
  emptyContainer: {
    alignItems: 'center',
    paddingVertical: 32,
  },
  emptyText: {
    marginTop: 16,
    color: '#666',
  },
  modalContainer: {
    flex: 1,
    backgroundColor: '#F5F7FA',
  },
  modalContent: {
    flex: 1,
    padding: 16,
  },
  sectionTitle: {
    fontWeight: '700',
    marginBottom: 12,
    color: '#1A1A1A',
  },
  label: {
    fontWeight: '600',
  },
  statusBadge: {
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 8,
    fontSize: 12,
    fontWeight: '600',
  },
  statusPending: {
    backgroundColor: '#FFF3E0',
    color: '#FF9800',
  },
  statusRejected: {
    backgroundColor: '#FFEBEE',
    color: '#F44336',
  },
  dateText: {
    color: '#666',
    marginTop: 8,
  },
  fileItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#E0E0E0',
  },
  fileIcon: {
    marginRight: 12,
  },
  fileInfo: {
    flex: 1,
  },
  fileType: {
    color: '#666',
    marginTop: 4,
    textTransform: 'capitalize',
  },
  actionButtonsContainer: {
    flexDirection: 'row',
    gap: 12,
    padding: 16,
    backgroundColor: '#F5F7FA',
    borderTopWidth: 1,
    borderTopColor: '#E0E0E0',
  },
  actionButtons: {
    flexDirection: 'row',
    gap: 12,
    marginTop: 16,
    marginBottom: 24,
  },
  actionButton: {
    flex: 1,
    borderRadius: 16,
    paddingVertical: 6,
  },
  approveButton: {
    backgroundColor: '#00C853',
  },
  rejectButton: {
    borderColor: '#F44336',
  },
  imageModalContainer: {
    flex: 1,
    backgroundColor: '#000',
  },
  fullImage: {
    flex: 1,
    width: '100%',
  },
  rejectionInput: {
    marginTop: 12,
    borderWidth: 1,
    borderColor: '#E0E0E0',
    borderRadius: 8,
    padding: 12,
    minHeight: 100,
    textAlignVertical: 'top',
    backgroundColor: '#FFFFFF',
  },
});

export default KycAdminScreen;

