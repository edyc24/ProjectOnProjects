import React, {useState, useEffect} from 'react';
import {
  View,
  StyleSheet,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
} from 'react-native';
import {TextInput, Button, Text, Snackbar, ActivityIndicator} from 'react-native-paper';
import {authApi} from '../../services/api/authApi';
import {NativeStackNavigationProp} from '@react-navigation/native-stack';
import {AuthStackParamList} from '../../navigation/AuthNavigator';

type VerificationScreenNavigationProp = NativeStackNavigationProp<
  AuthStackParamList,
  'Verification'
>;

interface Props {
  navigation: VerificationScreenNavigationProp;
  route: {
    params: {
      type: 'email' | 'phone';
      email?: string;
      phone?: string;
    };
  };
}

const VerificationScreen: React.FC<Props> = ({navigation, route}) => {
  const {type, email, phone} = route.params;
  const [code, setCode] = useState('');
  const [loading, setLoading] = useState(false);
  const [sending, setSending] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [showError, setShowError] = useState(false);
  const [success, setSuccess] = useState<string | null>(null);
  const [showSuccess, setShowSuccess] = useState(false);
  const [otpId, setOtpId] = useState<string | null>(null);
  const [countdown, setCountdown] = useState(0);

  useEffect(() => {
    // Auto-send verification code on mount
    sendVerificationCode();
  }, []);

  useEffect(() => {
    if (countdown > 0) {
      const timer = setTimeout(() => setCountdown(countdown - 1), 1000);
      return () => clearTimeout(timer);
    }
  }, [countdown]);

  const sendVerificationCode = async () => {
    try {
      setSending(true);
      setError(null);
      
      let result;
      if (type === 'email') {
        result = await authApi.sendEmailVerification(email);
      } else {
        result = await authApi.sendPhoneVerification(phone);
      }
      
      setOtpId(result.otpId);
      setCountdown(Math.floor(result.expiresInSeconds / 60)); // Convert to minutes
      setSuccess('Codul de verificare a fost trimis');
      setShowSuccess(true);
    } catch (err: any) {
      setError(err.response?.data?.message || 'Eroare la trimiterea codului');
      setShowError(true);
    } finally {
      setSending(false);
    }
  };

  const handleVerify = async () => {
    if (!code || code.length !== 6) {
      setError('Te rugăm să introduci codul de 6 cifre');
      setShowError(true);
      return;
    }

    if (!otpId) {
      setError('Te rugăm să trimiți mai întâi codul de verificare');
      setShowError(true);
      return;
    }

    try {
      setLoading(true);
      setError(null);
      
      let result;
      if (type === 'email') {
        result = await authApi.verifyEmail(otpId, code, email);
      } else {
        result = await authApi.verifyPhone(otpId, code, phone);
      }
      
      setSuccess(result.message);
      setShowSuccess(true);
      
      // Navigate back after 1 second
      setTimeout(() => {
        navigation.goBack();
      }, 1000);
    } catch (err: any) {
      setError(err.response?.data?.message || 'Cod invalid');
      setShowError(true);
    } finally {
      setLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <View style={styles.content}>
          <Text variant="headlineLarge" style={styles.title}>
            Verificare {type === 'email' ? 'Email' : 'Telefon'}
          </Text>
          
          <Text variant="bodyMedium" style={styles.subtitle}>
            {type === 'email'
              ? `Am trimis un cod de verificare la ${email}`
              : `Am trimis un cod de verificare la ${phone}`}
          </Text>

          <TextInput
            label="Cod de verificare (6 cifre)"
            value={code}
            onChangeText={setCode}
            mode="outlined"
            keyboardType="number-pad"
            maxLength={6}
            style={styles.input}
            disabled={loading || sending}
          />

          <Button
            mode="contained"
            onPress={handleVerify}
            loading={loading}
            disabled={loading || sending || !code || code.length !== 6}
            style={styles.button}>
            Verifică
          </Button>

          <Button
            mode="text"
            onPress={sendVerificationCode}
            loading={sending}
            disabled={sending || countdown > 0}
            style={styles.resendButton}>
            {countdown > 0
              ? `Retrimite codul (${countdown} min)`
              : 'Retrimite codul'}
          </Button>

          <Snackbar
            visible={showError}
            onDismiss={() => setShowError(false)}
            duration={3000}
            action={{
              label: 'OK',
              onPress: () => setShowError(false),
            }}>
            {error}
          </Snackbar>

          <Snackbar
            visible={showSuccess}
            onDismiss={() => setShowSuccess(false)}
            duration={2000}
            style={styles.successSnackbar}>
            {success}
          </Snackbar>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  scrollContent: {
    flexGrow: 1,
  },
  content: {
    flex: 1,
    padding: 20,
    justifyContent: 'center',
  },
  title: {
    marginBottom: 10,
    textAlign: 'center',
    fontWeight: 'bold',
  },
  subtitle: {
    marginBottom: 30,
    textAlign: 'center',
    color: '#666',
  },
  input: {
    marginBottom: 20,
  },
  button: {
    marginTop: 10,
    paddingVertical: 5,
  },
  resendButton: {
    marginTop: 10,
  },
  successSnackbar: {
    backgroundColor: '#4caf50',
  },
});

export default VerificationScreen;

