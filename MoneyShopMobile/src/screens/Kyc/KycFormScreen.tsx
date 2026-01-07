import React, {useState, useEffect} from 'react';
import {
  View,
  StyleSheet,
  ScrollView,
  Alert,
  Image,
  Platform,
} from 'react-native';
import {
  TextInput,
  Button,
  Text,
  Card,
  ActivityIndicator,
  Snackbar,
} from 'react-native-paper';
import * as ImagePicker from 'expo-image-picker';
import {NativeStackNavigationProp} from '@react-navigation/native-stack';
import {kycApi, KycSession} from '../../services/api/kycApi';
import {isValidCnpFormat} from '../../utils/cnpUtils';
import CustomHeader from '../../components/CustomHeader';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import {useAuthStore} from '../../store/authStore';

type KycFormScreenNavigationProp = NativeStackNavigationProp<any>;

interface Props {
  navigation: KycFormScreenNavigationProp;
}

interface KycFormData {
  cnp: string;
  address: string;
  city: string;
  county: string;
  postalCode: string;
}

const KycFormScreen: React.FC<Props> = ({navigation}) => {
  const {user} = useAuthStore();
  const [loading, setLoading] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [kycSession, setKycSession] = useState<KycSession | null>(null);
  const [idCardImage, setIdCardImage] = useState<string | null>(null);
  const [snackbarVisible, setSnackbarVisible] = useState(false);
  const [snackbarMessage, setSnackbarMessage] = useState('');

  const [formData, setFormData] = useState<KycFormData>({
    cnp: '',
    address: '',
    city: '',
    county: '',
    postalCode: '',
  });

  const [errors, setErrors] = useState<Partial<KycFormData>>({});

  // Redirect admins away from KYC form
  useEffect(() => {
    if (user?.role === 'Administrator') {
      Alert.alert(
        'Nu este necesar',
        'Conturile de administrator nu necesită verificare KYC.',
        [{text: 'OK', onPress: () => navigation.goBack()}],
      );
    }
  }, [user, navigation]);

  useEffect(() => {
    // Don't load KYC status for admins
    if (user?.role === 'Administrator') {
      return;
    }
    
    // Only load KYC status if user is authenticated
    if (user && user.id) {
      console.log('[KycFormScreen] Loading KYC status for user:', user.id);
      loadKycStatus();
    } else {
      console.warn('[KycFormScreen] User not authenticated, cannot load KYC status');
    }
  }, [user]);

  const loadKycStatus = async () => {
    try {
      setLoading(true);
      const status = await kycApi.getStatus();
      setKycSession(status);

      if (status.status === 'verified') {
        Alert.alert(
          'KYC Verificat',
          'Verificarea ta KYC a fost aprobată cu succes!',
          [{text: 'OK', onPress: () => navigation.goBack()}],
        );
        return;
      }

      if (status.status === 'rejected') {
        Alert.alert(
          'KYC Respins',
          status.rejectionReason || 'Verificarea ta KYC a fost respinsă.',
          [{text: 'OK'}],
        );
      }
    } catch (error: any) {
      if (error.response?.status !== 404) {
        showSnackbar('Eroare la încărcarea statusului KYC');
      }
    } finally {
      setLoading(false);
    }
  };

  const startKycSession = async () => {
    try {
      setLoading(true);
      const session = await kycApi.startSession();
      setKycSession(session);
    } catch (error) {
      showSnackbar('Eroare la pornirea sesiunii KYC');
    } finally {
      setLoading(false);
    }
  };

  const validateForm = (): boolean => {
    const newErrors: Partial<KycFormData> = {};

    if (!formData.cnp || !isValidCnpFormat(formData.cnp)) {
      newErrors.cnp = 'CNP-ul trebuie să fie format din 13 cifre';
    }

    if (!formData.address || formData.address.trim().length < 5) {
      newErrors.address = 'Adresa trebuie să aibă minim 5 caractere';
    }

    if (!formData.city || formData.city.trim().length < 2) {
      newErrors.city = 'Orașul este obligatoriu';
    }

    if (!formData.county || formData.county.trim().length < 2) {
      newErrors.county = 'Județul este obligatoriu';
    }

    if (!formData.postalCode || !/^\d{6}$/.test(formData.postalCode)) {
      newErrors.postalCode = 'Codul poștal trebuie să fie format din 6 cifre';
    }

    if (!idCardImage) {
      Alert.alert('Eroare', 'Trebuie să încarci o poză cu buletinul');
      return false;
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const pickIdCardImage = async () => {
    console.log('pickIdCardImage called');
    try {
      // Request library permissions first (most common use case)
      const libraryStatus = await ImagePicker.requestMediaLibraryPermissionsAsync();
      console.log('Library permission status:', libraryStatus.status);
      
      if (libraryStatus.status !== 'granted') {
        Alert.alert(
          'Permisiune necesară',
          'Ai nevoie de permisiune pentru a accesa galeria foto.',
        );
        return;
      }

      // On web, use native file input (ImagePicker doesn't work well on web)
      // On mobile, use ImagePicker
      if (Platform.OS === 'web') {
        console.log('Opening file input for web');
        // Use native file input for web - more reliable
        if (typeof document !== 'undefined') {
          const input = document.createElement('input');
          input.type = 'file';
          input.accept = 'image/*';
          input.onchange = (e: any) => {
            const file = e.target.files?.[0];
            if (file) {
              const reader = new FileReader();
              reader.onload = (event) => {
                const dataUrl = event.target?.result as string;
                setIdCardImage(dataUrl);
                console.log('Image selected from file input:', dataUrl.substring(0, 50) + '...');
              };
              reader.onerror = () => {
                console.error('Error reading file');
                showSnackbar('Eroare la citirea fișierului');
              };
              reader.readAsDataURL(file);
            }
          };
          input.click();
        } else {
          showSnackbar('Eroare la deschiderea selectorului de imagini');
        }
      } else {
        // On mobile, show action sheet
        console.log('Showing action sheet for mobile');
        Alert.alert(
          'Selectează poza',
          'De unde vrei să selectezi poza?',
          [
            {
              text: 'Anulează',
              style: 'cancel',
            },
            {
              text: 'Galerie',
              onPress: async () => {
                try {
                  console.log('Opening gallery');
                  const result = await ImagePicker.launchImageLibraryAsync({
                    mediaTypes: ImagePicker.MediaType.Images,
                    allowsEditing: true,
                    aspect: [4, 3],
                    quality: 0.8,
                  });

                  if (!result.canceled && result.assets && result.assets[0]) {
                    setIdCardImage(result.assets[0].uri);
                    console.log('Image selected from gallery:', result.assets[0].uri);
                  }
                } catch (error) {
                  console.error('Gallery error:', error);
                  showSnackbar('Eroare la deschiderea galeriei');
                }
              },
            },
            {
              text: 'Cameră',
              onPress: async () => {
                try {
                  const cameraStatus = await ImagePicker.requestCameraPermissionsAsync();
                  if (cameraStatus.status !== 'granted') {
                    Alert.alert('Permisiune necesară', 'Ai nevoie de permisiune pentru a accesa camera.');
                    return;
                  }
                  console.log('Opening camera');
                  const result = await ImagePicker.launchCameraAsync({
                    mediaTypes: ImagePicker.MediaType.Images,
                    allowsEditing: true,
                    aspect: [4, 3],
                    quality: 0.8,
                  });

                  if (!result.canceled && result.assets && result.assets[0]) {
                    setIdCardImage(result.assets[0].uri);
                    console.log('Image selected from camera:', result.assets[0].uri);
                  }
                } catch (error) {
                  console.error('Camera error:', error);
                  showSnackbar('Eroare la deschiderea camerei');
                }
              },
            },
          ],
        );
      }
    } catch (error) {
      console.error('Error picking image:', error);
      showSnackbar('Eroare la selectarea imaginii: ' + (error as Error).message);
    }
  };

  const submitKyc = async () => {
    if (!validateForm()) {
      return;
    }

    try {
      setSubmitting(true);

      // Start session if needed
      let currentSession = kycSession;
      if (!currentSession) {
        console.log('Starting new KYC session...');
        try {
          const newSession = await kycApi.startSession();
          console.log('KYC session created:', newSession);
          console.log('KYC session kycId:', newSession?.kycId);
          
          if (!newSession || !newSession.kycId) {
            console.error('Invalid KYC session response:', newSession);
            showSnackbar('Eroare: Sesiunea KYC nu a fost creată corect');
            setSubmitting(false);
            return;
          }
          
          setKycSession(newSession);
          currentSession = newSession;
        } catch (error: any) {
          console.error('Error starting KYC session:', error);
          showSnackbar(
            error.response?.data?.message ||
              'Eroare la crearea sesiunii KYC. Te rugăm să încerci din nou.',
          );
          setSubmitting(false);
          return;
        }
      }

      if (!currentSession || !currentSession.kycId) {
        console.error('No KYC session or kycId missing:', {
          currentSession,
          hasKycId: !!currentSession?.kycId,
          kycIdValue: currentSession?.kycId,
        });
        showSnackbar('Eroare la crearea sesiunii KYC');
        setSubmitting(false);
        return;
      }

      console.log('Updating KYC form data with kycId:', currentSession.kycId);
      console.log('Form data:', formData);

      // Update KYC form data (CNP, address, etc.) - do this first
      try {
        await kycApi.updateFormData(currentSession.kycId, {
          cnp: formData.cnp,
          address: formData.address,
          city: formData.city,
          county: formData.county,
          postalCode: formData.postalCode,
        });
        console.log('KYC form data updated successfully');
      } catch (formDataError: any) {
        console.error('Error updating KYC form data:', formDataError);
        showSnackbar(
          formDataError.response?.data?.message ||
            'Eroare la salvarea datelor formularului',
        );
        setSubmitting(false);
        return; // Stop here if form data update fails
      }

      // Upload ID card image
      if (idCardImage) {
        try {
          // Determine file extension and MIME type from URI
          let fileExtension = 'jpg';
          let mimeType = 'image/jpeg';
          
          if (idCardImage.includes('.png') || idCardImage.startsWith('data:image/png')) {
            fileExtension = 'png';
            mimeType = 'image/png';
          } else if (idCardImage.includes('.jpg') || idCardImage.includes('.jpeg') || idCardImage.startsWith('data:image/jpeg')) {
            fileExtension = 'jpg';
            mimeType = 'image/jpeg';
          }
          
          const fileName = `id_card.${fileExtension}`;

          console.log('[KycForm] Uploading ID card image:', {
            kycId: currentSession.kycId,
            fileName,
            mimeType,
            uriPreview: idCardImage.substring(0, 50) + '...',
          });

          await kycApi.uploadFile(currentSession.kycId, 'id_front', {
            uri: idCardImage,
            type: mimeType,
            name: fileName,
          });

          console.log('[KycForm] Image uploaded successfully');
        } catch (uploadError: any) {
          console.error('[KycForm] Image upload failed:', uploadError);
          const errorMessage = 
            uploadError.response?.data?.message ||
            uploadError.response?.data?.errors?.File?.[0] ||
            uploadError.message ||
            'Eroare la încărcarea imaginii';
          
          showSnackbar(
            `Datele au fost salvate, dar încărcarea imaginii a eșuat: ${errorMessage}`,
          );
        }
      }

      // Reload status to show pending state
      await loadKycStatus();

      showSnackbar('Cererea KYC a fost trimisă cu succes!');
    } catch (error: any) {
      console.error('KYC submit error:', error);
      showSnackbar(
        error.response?.data?.message || 'Eroare la trimiterea cererii KYC',
      );
    } finally {
      setSubmitting(false);
    }
  };

  const showSnackbar = (message: string) => {
    setSnackbarMessage(message);
    setSnackbarVisible(true);
  };

  if (loading && !kycSession) {
    return (
      <View style={styles.center}>
        <ActivityIndicator size="large" />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <ScrollView style={styles.scrollView}>
        <View style={styles.content}>
          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleLarge" style={styles.sectionTitle}>
                Verificare Identitate (KYC)
              </Text>
              <Text variant="bodyMedium" style={styles.description}>
                Completează datele de mai jos și încarcă o poză cu buletinul
                pentru verificare.
              </Text>
            </Card.Content>
          </Card>

          <Card style={styles.card}>
            <Card.Content>
              <TextInput
                label="CNP *"
                value={formData.cnp}
                onChangeText={text => {
                  setFormData({...formData, cnp: text});
                  if (errors.cnp) {
                    setErrors({...errors, cnp: undefined});
                  }
                }}
                error={!!errors.cnp}
                keyboardType="numeric"
                maxLength={13}
                style={styles.input}
                mode="outlined"
              />
              {errors.cnp && (
                <Text style={styles.errorText}>{errors.cnp}</Text>
              )}

              <TextInput
                label="Adresă *"
                value={formData.address}
                onChangeText={text => {
                  setFormData({...formData, address: text});
                  if (errors.address) {
                    setErrors({...errors, address: undefined});
                  }
                }}
                error={!!errors.address}
                style={styles.input}
                mode="outlined"
                multiline
                numberOfLines={2}
              />
              {errors.address && (
                <Text style={styles.errorText}>{errors.address}</Text>
              )}

              <View style={styles.row}>
                <View style={styles.halfWidth}>
                  <TextInput
                    label="Oraș *"
                    value={formData.city}
                    onChangeText={text => {
                      setFormData({...formData, city: text});
                      if (errors.city) {
                        setErrors({...errors, city: undefined});
                      }
                    }}
                    error={!!errors.city}
                    style={styles.input}
                    mode="outlined"
                  />
                  {errors.city && (
                    <Text style={styles.errorText}>{errors.city}</Text>
                  )}
                </View>

                <View style={styles.halfWidth}>
                  <TextInput
                    label="Județ *"
                    value={formData.county}
                    onChangeText={text => {
                      setFormData({...formData, county: text});
                      if (errors.county) {
                        setErrors({...errors, county: undefined});
                      }
                    }}
                    error={!!errors.county}
                    style={styles.input}
                    mode="outlined"
                  />
                  {errors.county && (
                    <Text style={styles.errorText}>{errors.county}</Text>
                  )}
                </View>
              </View>

              <TextInput
                label="Cod Poștal *"
                value={formData.postalCode}
                onChangeText={text => {
                  setFormData({...formData, postalCode: text});
                  if (errors.postalCode) {
                    setErrors({...errors, postalCode: undefined});
                  }
                }}
                error={!!errors.postalCode}
                keyboardType="numeric"
                maxLength={6}
                style={styles.input}
                mode="outlined"
              />
              {errors.postalCode && (
                <Text style={styles.errorText}>{errors.postalCode}</Text>
              )}
            </Card.Content>
          </Card>

          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                Poza cu Buletinul *
              </Text>
              <Text variant="bodySmall" style={styles.description}>
                Încarcă o poză clară cu fața buletinului tău
              </Text>

              {idCardImage ? (
                <View style={styles.imageContainer}>
                  <Image
                    source={{uri: idCardImage}}
                    style={styles.image}
                    resizeMode="contain"
                  />
                  <Button
                    mode="outlined"
                    onPress={() => {
                      console.log('Change image button pressed');
                      pickIdCardImage();
                    }}
                    style={styles.changeImageButton}>
                    Schimbă imaginea
                  </Button>
                </View>
              ) : (
                <Button
                  mode="outlined"
                  icon="camera"
                  onPress={() => {
                    console.log('Select image button pressed');
                    pickIdCardImage();
                  }}
                  style={styles.uploadButton}>
                  Selectează poza cu buletinul
                </Button>
              )}
            </Card.Content>
          </Card>

          {kycSession?.status === 'pending' && (
            <Card style={styles.card}>
              <Card.Content>
                <View style={styles.statusContainer}>
                  <Icon name="clock-outline" size={24} color="#FF9800" />
                  <Text variant="bodyMedium" style={styles.statusText}>
                    Cererea ta KYC este în așteptare de verificare
                  </Text>
                </View>
              </Card.Content>
            </Card>
          )}

          {kycSession?.status === 'rejected' && (
            <Card style={[styles.card, styles.rejectedCard]}>
              <Card.Content>
                <View style={styles.statusContainer}>
                  <Icon name="close-circle" size={24} color="#F44336" />
                  <View style={styles.rejectionContainer}>
                    <Text variant="bodyMedium" style={styles.rejectionTitle}>
                      Cererea ta KYC a fost respinsă
                    </Text>
                    {kycSession.rejectionReason && (
                      <Text variant="bodySmall" style={styles.rejectionReason}>
                        {kycSession.rejectionReason}
                      </Text>
                    )}
                  </View>
                </View>
              </Card.Content>
            </Card>
          )}

          <Button
            mode="contained"
            onPress={submitKyc}
            loading={submitting}
            disabled={submitting || kycSession?.status === 'pending'}
            style={styles.submitButton}>
            {kycSession?.status === 'pending'
              ? 'Cerere în așteptare'
              : 'Trimite cererea KYC'}
          </Button>

          {kycSession?.status === 'pending' && (
            <Button
              mode="outlined"
              onPress={() => navigation.goBack()}
              style={styles.backButton}>
              Înapoi la Dashboard
            </Button>
          )}
        </View>
      </ScrollView>

      <Snackbar
        visible={snackbarVisible}
        onDismiss={() => setSnackbarVisible(false)}
        duration={3000}>
        {snackbarMessage}
      </Snackbar>
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
  card: {
    marginBottom: 16,
    borderRadius: 16,
    elevation: 1,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 1},
    shadowOpacity: 0.05,
    shadowRadius: 8,
    backgroundColor: '#FFFFFF',
  },
  sectionTitle: {
    fontWeight: '700',
    marginBottom: 8,
    color: '#1A1A1A',
  },
  description: {
    color: '#6B7280',
    marginTop: 4,
  },
  input: {
    marginBottom: 8,
  },
  errorText: {
    color: '#F44336',
    fontSize: 12,
    marginBottom: 8,
    marginLeft: 12,
  },
  row: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  halfWidth: {
    width: '48%',
  },
  imageContainer: {
    marginTop: 16,
    alignItems: 'center',
  },
  image: {
    width: '100%',
    height: 200,
    borderRadius: 12,
    marginBottom: 12,
  },
  uploadButton: {
    marginTop: 16,
  },
  changeImageButton: {
    marginTop: 8,
  },
  submitButton: {
    marginTop: 8,
    marginBottom: 12,
    borderRadius: 16,
    paddingVertical: 6,
  },
  backButton: {
    marginBottom: 24,
    borderRadius: 16,
    paddingVertical: 6,
  },
  statusContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  statusText: {
    flex: 1,
    color: '#FF9800',
  },
  rejectedCard: {
    borderLeftWidth: 4,
    borderLeftColor: '#F44336',
  },
  rejectionContainer: {
    flex: 1,
  },
  rejectionTitle: {
    fontWeight: '600',
    color: '#F44336',
    marginBottom: 4,
  },
  rejectionReason: {
    color: '#666',
    marginTop: 4,
  },
});

export default KycFormScreen;

