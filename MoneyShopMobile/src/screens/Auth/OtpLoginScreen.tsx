import React, {useState, useEffect, useRef} from 'react';
import {
  View,
  StyleSheet,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  TextInput as RNTextInput,
  Image,
} from 'react-native';
import {TextInput, Button, Text, Snackbar} from 'react-native-paper';
import {otpApi} from '../../services/api/otpApi';
import {useAuthStore} from '../../store/authStore';
import {NativeStackNavigationProp} from '@react-navigation/native-stack';
import {AuthStackParamList} from '../../navigation/AuthNavigator';

const logoImage = require('../../../assets/images/logo/Logo.PNG');

type OtpLoginScreenNavigationProp = NativeStackNavigationProp<
  AuthStackParamList,
  'OtpLogin'
>;

interface Props {
  navigation: OtpLoginScreenNavigationProp;
}

const OtpLoginScreen: React.FC<Props> = ({navigation}) => {
  const [phone, setPhone] = useState('');
  const [otpId, setOtpId] = useState<string | null>(null);
  const [otpCode, setOtpCode] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [showError, setShowError] = useState(false);
  const [countdown, setCountdown] = useState(0);
  const [otpFromServer, setOtpFromServer] = useState<string | null>(null);
  const otpInputRef = useRef<RNTextInput>(null);
  const {loginWithToken} = useAuthStore();

  useEffect(() => {
    let timer: NodeJS.Timeout;
    if (countdown > 0) {
      timer = setTimeout(() => setCountdown(countdown - 1), 1000);
    }
    return () => clearTimeout(timer);
  }, [countdown]);

  const handleRequestOtp = async () => {
    if (!phone || phone.length < 10) {
      setError('Te rugăm să introduci un număr de telefon valid');
      setShowError(true);
      return;
    }

    try {
      setLoading(true);
      setError(null);
      const response = await otpApi.requestOtp({
        phone: phone.startsWith('+') ? phone : `+40${phone}`,
        purpose: 'LOGIN_SMS',
      });

      setOtpId(response.otpId);
      setCountdown(300); // 5 minutes
      if (response.otpCode) {
        // Development mode - show OTP
        setOtpFromServer(response.otpCode);
      }
      otpInputRef.current?.focus();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Eroare la trimiterea codului OTP');
      setShowError(true);
    } finally {
      setLoading(false);
    }
  };

  const handleVerifyOtp = async () => {
    if (!otpId || !otpCode || otpCode.length !== 6) {
      setError('Te rugăm să introduci codul OTP de 6 cifre');
      setShowError(true);
      return;
    }

    try {
      setLoading(true);
      setError(null);
      const response = await otpApi.verifyOtp({
        otpId,
        code: otpCode,
        phone: phone.startsWith('+') ? phone : `+40${phone}`,
        purpose: 'LOGIN_SMS',
      });

      if (response.accessToken && response.user) {
        // Login successful
        await loginWithToken(response.accessToken, response.user);
        // Navigation will be handled by AppNavigator
      } else {
        setError(response.message || 'Eroare la verificarea codului');
        setShowError(true);
      }
    } catch (err: any) {
      setError(err.response?.data?.message || 'Cod OTP invalid');
      setShowError(true);
    } finally {
      setLoading(false);
    }
  };

  const formatCountdown = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <View style={styles.content}>
          <View style={styles.logoContainer}>
            <Image 
              source={logoImage} 
              style={styles.logo}
              resizeMode="contain"
            />
          </View>
          <Text variant="headlineMedium" style={styles.title}>
            Autentificare cu cod SMS
          </Text>
          <Text variant="bodyMedium" style={styles.subtitle}>
            Introdu numărul de telefon pentru a primi codul
          </Text>

          {!otpId ? (
            <>
              <TextInput
                label="Număr de telefon"
                value={phone}
                onChangeText={setPhone}
                mode="outlined"
                keyboardType="phone-pad"
                placeholder="0712345678"
                style={styles.input}
                left={<TextInput.Icon icon="phone" />}
              />

              <Button
                mode="contained"
                onPress={handleRequestOtp}
                loading={loading}
                disabled={loading}
                style={styles.button}>
                Trimite cod SMS
              </Button>

              {otpFromServer && (
                <View style={styles.devOtpContainer}>
                  <Text style={styles.devOtpLabel}>Cod OTP (Development):</Text>
                  <Text style={styles.devOtpCode}>{otpFromServer}</Text>
                </View>
              )}
            </>
          ) : (
            <>
              <Text variant="bodyMedium" style={styles.infoText}>
                Am trimis un cod SMS la {phone}
              </Text>

              <TextInput
                ref={otpInputRef}
                label="Cod OTP"
                value={otpCode}
                onChangeText={setOtpCode}
                mode="outlined"
                keyboardType="number-pad"
                maxLength={6}
                style={styles.input}
                left={<TextInput.Icon icon="lock" />}
              />

              {countdown > 0 && (
                <Text style={styles.countdownText}>
                  Codul expiră în: {formatCountdown(countdown)}
                </Text>
              )}

              <Button
                mode="contained"
                onPress={handleVerifyOtp}
                loading={loading}
                disabled={loading || otpCode.length !== 6}
                style={styles.button}>
                Verifică cod
              </Button>

              <Button
                mode="text"
                onPress={() => {
                  setOtpId(null);
                  setOtpCode('');
                  setOtpFromServer(null);
                  setCountdown(0);
                }}
                style={styles.linkButton}>
                Schimbă numărul
              </Button>
            </>
          )}

          <Button
            mode="text"
            onPress={() => navigation.navigate('Login')}
            style={styles.linkButton}>
            Autentificare cu email/parolă
          </Button>
        </View>
      </ScrollView>

      <Snackbar
        visible={showError}
        onDismiss={() => setShowError(false)}
        duration={3000}>
        {error || 'Eroare'}
      </Snackbar>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
  scrollContent: {
    flexGrow: 1,
    justifyContent: 'center',
    paddingVertical: 40,
  },
  content: {
    padding: 24,
    maxWidth: 450,
    alignSelf: 'center',
    width: '100%',
  },
  logoContainer: {
    alignItems: 'center',
    marginBottom: 32,
  },
  logo: {
    width: 560,
    height: 200,
  },
  title: {
    textAlign: 'center',
    marginBottom: 8,
    color: '#212121',
    fontWeight: '700',
    fontSize: 28,
  },
  subtitle: {
    textAlign: 'center',
    marginBottom: 32,
    color: '#757575',
    fontSize: 16,
  },
  input: {
    marginBottom: 16,
    backgroundColor: '#FFFFFF',
  },
  button: {
    marginTop: 8,
    paddingVertical: 8,
    borderRadius: 12,
    backgroundColor: '#1976D2',
    elevation: 2,
    shadowColor: '#1976D2',
    shadowOffset: {width: 0, height: 2},
    shadowOpacity: 0.2,
    shadowRadius: 4,
  },
  linkButton: {
    marginTop: 12,
  },
  infoText: {
    textAlign: 'center',
    marginBottom: 24,
    color: '#757575',
    fontSize: 15,
  },
  countdownText: {
    textAlign: 'center',
    marginBottom: 16,
    color: '#FF9800',
    fontWeight: '600',
    fontSize: 14,
  },
  devOtpContainer: {
    marginTop: 16,
    padding: 16,
    backgroundColor: '#E3F2FD',
    borderRadius: 12,
    borderWidth: 1,
    borderColor: '#1976D2',
  },
  devOtpLabel: {
    fontSize: 12,
    color: '#1976D2',
    marginBottom: 8,
    fontWeight: '600',
  },
  devOtpCode: {
    fontSize: 24,
    fontWeight: '700',
    color: '#1976D2',
    textAlign: 'center',
    letterSpacing: 4,
  },
});

export default OtpLoginScreen;

