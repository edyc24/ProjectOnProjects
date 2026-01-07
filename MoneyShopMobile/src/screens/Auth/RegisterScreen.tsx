import React, {useState} from 'react';
import {
  View,
  StyleSheet,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
} from 'react-native';
import {TextInput, Button, Text, Snackbar} from 'react-native-paper';
import {useAuthStore} from '../../store/authStore';
import {NativeStackNavigationProp} from '@react-navigation/native-stack';
import {AuthStackParamList} from '../../navigation/AuthNavigator';
import {kycApi} from '../../services/api/kycApi';
import {appInsightsService} from '../../services/telemetry/appInsightsService';

type RegisterScreenNavigationProp = NativeStackNavigationProp<
  AuthStackParamList,
  'Register'
>;

interface Props {
  navigation: RegisterScreenNavigationProp;
}

const RegisterScreen: React.FC<Props> = ({navigation}) => {
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [phone, setPhone] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [showError, setShowError] = useState(false);

  const {register} = useAuthStore();

  const handleRegister = async () => {
    // Track button click event
    appInsightsService.trackButtonClick('Register', 'submit', {
      screen: 'RegisterScreen',
    });

    if (!firstName || !lastName || !email || !password || !confirmPassword) {
      setError('Te rugăm să completezi toate câmpurile obligatorii');
      setShowError(true);
      return;
    }

    if (password !== confirmPassword) {
      setError('Parolele nu coincid');
      setShowError(true);
      return;
    }

    if (password.length < 6) {
      setError('Parola trebuie să aibă minim 6 caractere');
      setShowError(true);
      return;
    }

    try {
      setLoading(true);
      setError(null);
      await register(email, password, firstName, lastName, phone || undefined);
      
      // Track successful registration
      appInsightsService.trackEvent('UserRegistered', {
        email: email,
        hasPhone: phone ? 'true' : 'false',
      });
      
      // After successful registration, check KYC status
      // The app will navigate to Main, and DashboardScreen will check KYC
      // Navigation will be handled by AppNavigator
    } catch (err: any) {
      // Track registration error
      appInsightsService.trackError(err instanceof Error ? err : new Error(err?.message || 'Unknown error'), {
        screen: 'RegisterScreen',
        errorType: 'RegistrationError',
      });
      
      setError(err.response?.data?.message || 'Eroare la înregistrare');
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
            Înregistrare
          </Text>

          <TextInput
            label="Prenume"
            value={firstName}
            onChangeText={setFirstName}
            mode="outlined"
            style={styles.input}
            autoCapitalize="words"
          />

          <TextInput
            label="Nume"
            value={lastName}
            onChangeText={setLastName}
            mode="outlined"
            style={styles.input}
            autoCapitalize="words"
          />

          <TextInput
            label="Email"
            value={email}
            onChangeText={setEmail}
            mode="outlined"
            keyboardType="email-address"
            autoCapitalize="none"
            style={styles.input}
          />

          <TextInput
            label="Telefon (opțional)"
            value={phone}
            onChangeText={setPhone}
            mode="outlined"
            keyboardType="phone-pad"
            style={styles.input}
          />

          <TextInput
            label="Parolă"
            value={password}
            onChangeText={setPassword}
            mode="outlined"
            secureTextEntry
            style={styles.input}
          />

          <TextInput
            label="Confirmă parola"
            value={confirmPassword}
            onChangeText={setConfirmPassword}
            mode="outlined"
            secureTextEntry
            style={styles.input}
          />

          <Button
            mode="contained"
            onPress={handleRegister}
            loading={loading}
            disabled={loading}
            style={styles.button}>
            Înregistrare
          </Button>

          <Button
            mode="text"
            onPress={() => navigation.navigate('Login')}
            style={styles.linkButton}>
            Ai deja cont? Autentifică-te
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
    backgroundColor: '#fff',
  },
  scrollContent: {
    flexGrow: 1,
    justifyContent: 'center',
  },
  content: {
    padding: 20,
  },
  title: {
    textAlign: 'center',
    marginBottom: 30,
    fontWeight: 'bold',
  },
  input: {
    marginBottom: 15,
  },
  button: {
    marginTop: 10,
    paddingVertical: 5,
  },
  linkButton: {
    marginTop: 10,
  },
});

export default RegisterScreen;

