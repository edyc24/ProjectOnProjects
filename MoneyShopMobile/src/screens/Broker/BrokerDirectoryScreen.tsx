import React, {useState, useEffect, useMemo} from 'react';
import {View, StyleSheet, FlatList, Alert} from 'react-native';
import {
  Card,
  Button,
  Text,
  ActivityIndicator,
  Chip,
  Searchbar,
} from 'react-native-paper';
import {useMutation, useQuery, useQueryClient} from '@tanstack/react-query';
import {brokerApi, BrokerInfo} from '../../services/api/brokerApi';
import {useAuthStore} from '../../store/authStore';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import * as DocumentPicker from 'expo-document-picker';

// Custom hook for debouncing
const useDebounce = (value: string, delay: number) => {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    return () => {
      clearTimeout(handler);
    };
  }, [value, delay]);

  return debouncedValue;
};

const ITEMS_PER_PAGE = 20;

const BrokerDirectoryScreen = ({navigation}: any) => {
  const queryClient = useQueryClient();
  const {user} = useAuthStore();
  const [searchQuery, setSearchQuery] = useState('');
  const [currentPage, setCurrentPage] = useState(1);
  const isAdmin = user?.role === 'Administrator';

  // Debounce search query (wait 500ms after user stops typing)
  const debouncedSearchQuery = useDebounce(searchQuery, 500);

  const {data: directoryData, isLoading: isLoadingDirectory} = useQuery({
    queryKey: ['brokerDirectory'],
    queryFn: () => brokerApi.getLatestDirectory(),
    retry: false,
    throwOnError: false,
  });

  // Fetch all brokers (no limit) - backend will return all
  const {data: brokersData, isLoading: isLoadingBrokers} = useQuery({
    queryKey: ['brokers', debouncedSearchQuery],
    queryFn: () => brokerApi.searchBrokers(debouncedSearchQuery || undefined, undefined), // No limit - get all
    enabled: !!directoryData,
  });

  // Reset to page 1 when search changes
  useEffect(() => {
    setCurrentPage(1);
  }, [debouncedSearchQuery]);

  // Paginate brokers on client side
  const brokers = brokersData?.brokers || [];
  const paginatedBrokers = useMemo(() => {
    const startIndex = (currentPage - 1) * ITEMS_PER_PAGE;
    const endIndex = startIndex + ITEMS_PER_PAGE;
    return brokers.slice(startIndex, endIndex);
  }, [brokers, currentPage]);

  const totalPages = Math.ceil(brokers.length / ITEMS_PER_PAGE);

  const uploadMutation = useMutation({
    mutationFn: ({file, notes}: {file: File; notes?: string}) =>
      brokerApi.uploadExcel(file, notes),
    onSuccess: () => {
      queryClient.invalidateQueries({queryKey: ['brokerDirectory']});
      queryClient.invalidateQueries({queryKey: ['brokers']});
      Alert.alert('Succes', 'Fișierul Excel a fost încărcat cu succes');
    },
    onError: (error: any) => {
      Alert.alert('Eroare', error.message || 'Nu s-a putut încărca fișierul');
    },
  });

  const handleUploadExcel = async () => {
    try {
      const result = await DocumentPicker.getDocumentAsync({
        type: [
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          'application/vnd.ms-excel',
        ],
        copyToCacheDirectory: true,
      });

      if (result.canceled) {
        return;
      }

      const file = result.assets[0];
      if (!file) {
        return;
      }

      // Convert to File object for API
      const response = await fetch(file.uri);
      const blob = await response.blob();
      const fileObj = new File([blob], file.name, {type: file.mimeType || 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'});

      uploadMutation.mutate({file: fileObj});
    } catch (error: any) {
      Alert.alert('Eroare', error.message || 'Nu s-a putut selecta fișierul');
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.content}>
          <Text variant="headlineSmall" style={styles.title}>
            Director Brokeri
          </Text>
          <Text variant="bodyMedium" style={styles.subtitle}>
            Încarcă un fișier Excel cu brokeri și caută în listă
          </Text>

          {/* Upload Section - Only for Admin */}
          {isAdmin && (
            <Card style={styles.card}>
              <Card.Content>
                <View style={styles.uploadSection}>
                  <Icon name="file-excel" size={48} color="#217346" />
                  <Text variant="titleMedium" style={styles.uploadTitle}>
                    Încarcă Excel
                  </Text>
                  <Text variant="bodySmall" style={styles.uploadDescription}>
                    {directoryData
                      ? `Ultimul fișier: ${directoryData.fileName}`
                      : 'Nu există fișier încărcat'}
                  </Text>
                  {directoryData && (
                    <Text variant="bodySmall" style={styles.uploadDate}>
                      Încărcat: {new Date(directoryData.uploadedAt).toLocaleDateString('ro-RO')}
                    </Text>
                  )}
                  <Button
                    mode="contained"
                    onPress={handleUploadExcel}
                    loading={uploadMutation.isPending}
                    disabled={uploadMutation.isPending}
                    style={styles.uploadButton}
                    icon="upload">
                    {directoryData ? 'Actualizează Excel' : 'Încarcă Excel'}
                  </Button>
                </View>
              </Card.Content>
            </Card>
          )}

          {/* Info Card for non-admin users */}
          {!isAdmin && directoryData && (
            <Card style={styles.infoCard}>
              <Card.Content>
                <View style={styles.infoRow}>
                  <Icon name="information" size={24} color="#1976D2" />
                  <View style={styles.infoTextContainer}>
                    <Text variant="bodySmall" style={styles.infoTitle}>
                      Director Brokeri
                    </Text>
                    <Text variant="bodySmall" style={styles.infoText}>
                      Ultimul fișier: {directoryData.fileName}
                    </Text>
                    <Text variant="bodySmall" style={styles.infoText}>
                      Încărcat: {new Date(directoryData.uploadedAt).toLocaleDateString('ro-RO')}
                    </Text>
                  </View>
                </View>
              </Card.Content>
            </Card>
          )}

          {/* Search Section */}
          {directoryData && (
            <Card style={styles.card}>
              <Card.Content>
                <Searchbar
                  placeholder="Caută broker (nume, firmă, CUI, email, telefon)..."
                  onChangeText={setSearchQuery}
                  value={searchQuery}
                  style={styles.searchbar}
                />
              </Card.Content>
            </Card>
          )}

          {/* Brokers List with Pagination */}
          {isLoadingBrokers ? (
            <View style={styles.centerContainer}>
              <ActivityIndicator size="large" color="#1976D2" />
            </View>
          ) : directoryData && brokers.length > 0 ? (
            <>
              <View style={styles.listHeader}>
                <Text variant="titleMedium" style={styles.listTitle}>
                  Brokeri ({brokers.length})
                  {debouncedSearchQuery && (
                    <Text variant="bodySmall" style={styles.searchInfo}>
                      {' '}pentru "{debouncedSearchQuery}"
                    </Text>
                  )}
                </Text>
              </View>
              <FlatList
                data={paginatedBrokers}
                keyExtractor={(item) => item.brokerId}
                renderItem={({item: broker}) => (
                  <Card style={styles.brokerCard}>
                  <Card.Content>
                    <View style={styles.brokerHeader}>
                      <View style={styles.brokerInfo}>
                        <Text variant="titleMedium" style={styles.brokerName}>
                          {broker.fullName}
                        </Text>
                        {broker.firmName && (
                          <Text variant="bodyMedium" style={styles.brokerFirm}>
                            {broker.firmName}
                          </Text>
                        )}
                      </View>
                      <Chip
                        style={[
                          styles.statusChip,
                          {
                            backgroundColor:
                              broker.status === 'verified'
                                ? '#E8F5E9'
                                : broker.status === 'suspended'
                                ? '#FFEBEE'
                                : '#FFF9E6',
                          },
                        ]}
                        textStyle={{
                          color:
                            broker.status === 'verified'
                              ? '#4CAF50'
                              : broker.status === 'suspended'
                              ? '#D32F2F'
                              : '#FF9800',
                        }}>
                        {broker.status === 'verified'
                          ? 'Verificat'
                          : broker.status === 'suspended'
                          ? 'Suspendat'
                          : 'Pending'}
                      </Chip>
                    </View>

                    <View style={styles.brokerDetails}>
                      {broker.firmCui && (
                        <View style={styles.detailRow}>
                          <Icon name="identifier" size={16} color="#666" />
                          <Text variant="bodySmall" style={styles.detailText}>
                            CUI: {broker.firmCui}
                          </Text>
                        </View>
                      )}
                      {broker.publicEmail && (
                        <View style={styles.detailRow}>
                          <Icon name="email" size={16} color="#666" />
                          <Text variant="bodySmall" style={styles.detailText}>
                            {broker.publicEmail}
                          </Text>
                        </View>
                      )}
                      {broker.publicPhone && (
                        <View style={styles.detailRow}>
                          <Icon name="phone" size={16} color="#666" />
                          <Text variant="bodySmall" style={styles.detailText}>
                            {broker.publicPhone}
                          </Text>
                        </View>
                      )}
                    </View>
                  </Card.Content>
                </Card>
                )}
                ListFooterComponent={
                  totalPages > 1 ? (
                    <View style={styles.paginationContainer}>
                      <Button
                        mode="outlined"
                        onPress={() => setCurrentPage(prev => Math.max(1, prev - 1))}
                        disabled={currentPage === 1}
                        style={styles.paginationButton}
                        icon="chevron-left">
                        Anterior
                      </Button>
                      <Text variant="bodyMedium" style={styles.paginationText}>
                        Pagina {currentPage} din {totalPages}
                      </Text>
                      <Button
                        mode="outlined"
                        onPress={() => setCurrentPage(prev => Math.min(totalPages, prev + 1))}
                        disabled={currentPage === totalPages}
                        style={styles.paginationButton}
                        icon="chevron-right">
                        Următor
                      </Button>
                    </View>
                  ) : null
                }
              />
            </>
          ) : directoryData && brokers.length === 0 ? (
            <Card style={styles.card}>
              <Card.Content>
                <View style={styles.centerContainer}>
                  <Icon name="magnify" size={48} color="#999" />
                  <Text variant="bodyMedium" style={styles.emptyText}>
                    {debouncedSearchQuery
                      ? `Nu s-au găsit brokeri pentru "${debouncedSearchQuery}"`
                      : 'Nu există brokeri în fișierul Excel'}
                  </Text>
                </View>
              </Card.Content>
            </Card>
          ) : !directoryData ? (
            <Card style={styles.card}>
              <Card.Content>
                <View style={styles.centerContainer}>
                  <Icon name="file-upload-outline" size={48} color="#999" />
                  <Text variant="bodyMedium" style={styles.emptyText}>
                    Încarcă un fișier Excel pentru a începe
                  </Text>
                </View>
              </Card.Content>
            </Card>
          ) : null}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FAFAFA',
  },
  content: {
    flex: 1,
    padding: 16,
  },
  listHeader: {
    marginBottom: 16,
    marginTop: 8,
  },
  searchInfo: {
    color: '#64748B',
    fontWeight: '400',
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
  uploadSection: {
    alignItems: 'center',
    paddingVertical: 16,
  },
  uploadTitle: {
    marginTop: 12,
    fontWeight: '600',
    color: '#333',
  },
  uploadDescription: {
    marginTop: 8,
    color: '#666',
    textAlign: 'center',
  },
  uploadDate: {
    marginTop: 4,
    color: '#999',
    fontSize: 12,
  },
  uploadButton: {
    marginTop: 16,
  },
  searchbar: {
    marginBottom: 0,
  },
  centerContainer: {
    alignItems: 'center',
    paddingVertical: 32,
  },
  brokersList: {
    marginTop: 8,
  },
  listTitle: {
    marginBottom: 16,
    fontWeight: '600',
    color: '#333',
  },
  brokerCard: {
    marginBottom: 12,
    borderRadius: 12,
    elevation: 0,
    shadowOpacity: 0,
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: '#E0E0E0',
  },
  brokerHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 12,
  },
  brokerInfo: {
    flex: 1,
    marginRight: 8,
  },
  brokerName: {
    fontWeight: '600',
    color: '#333',
    marginBottom: 4,
  },
  brokerFirm: {
    color: '#666',
  },
  statusChip: {
    marginLeft: 8,
  },
  brokerDetails: {
    marginTop: 8,
  },
  detailRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 8,
  },
  detailText: {
    marginLeft: 8,
    color: '#666',
  },
  emptyText: {
    marginTop: 16,
    color: '#999',
    textAlign: 'center',
  },
  infoCard: {
    marginBottom: 16,
    borderRadius: 20,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 2},
    shadowOpacity: 0.08,
    shadowRadius: 8,
    backgroundColor: '#FFFFFF',
    borderWidth: 0,
  },
  infoTextContainer: {
    flex: 1,
    marginLeft: 12,
  },
  infoTitle: {
    fontWeight: '600',
    color: '#1A1A1A',
    marginBottom: 6,
    fontSize: 14,
  },
  paginationContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: 20,
    gap: 16,
  },
  paginationButton: {
    minWidth: 100,
  },
  paginationText: {
    color: '#64748B',
    fontWeight: '500',
  },
});

export default BrokerDirectoryScreen;

