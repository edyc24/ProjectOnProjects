import React, {useState} from 'react';
import {
  View,
  StyleSheet,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  Image,
} from 'react-native';
import {TextInput, Button, Text, Snackbar} from 'react-native-paper';
import {useAuthStore} from '../../store/authStore';
import {NativeStackNavigationProp} from '@react-navigation/native-stack';
import {AuthStackParamList} from '../../navigation/AuthNavigator';

const logoImage = require('../../../assets/images/logo/Logo.PNG');

type LoginScreenNavigationProp = NativeStackNavigationProp<
  AuthStackParamList,
  'Login'
>;

interface Props {
  navigation: LoginScreenNavigationProp;
}

const LoginScreen: React.FC<Props> = ({navigation}) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [showError, setShowError] = useState(false);

  const {login} = useAuthStore();

  const handleLogin = async () => {
    if (!email || !password) {
      setError('Te rugăm să completezi toate câmpurile');
      setShowError(true);
      return;
    }

    try {
      setLoading(true);
      setError(null);
      await login(email, password);
      // Navigation will be handled by AppNavigator based on auth state
    } catch (err: any) {
      setError(err.response?.data?.message || 'Eroare la autentificare');
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
          <View style={styles.logoContainer}>
            <Image 
              source={logoImage} 
              style={styles.logo}
              resizeMode="contain"
            />
          </View>
          <Text variant="headlineMedium" style={styles.title}>
            Bine ai revenit!
          </Text>
          <Text variant="bodyMedium" style={styles.subtitle}>
            Autentifică-te pentru a continua
          </Text>

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
            label="Parolă"
            value={password}
            onChangeText={setPassword}
            mode="outlined"
            secureTextEntry
            style={styles.input}
          />

          <Button
            mode="contained"
            onPress={handleLogin}
            loading={loading}
            disabled={loading}
            style={styles.button}>
            Autentificare
          </Button>

          <Button
            mode="outlined"
            icon="phone"
            onPress={() => navigation.navigate('OtpLogin')}
            style={styles.otpButton}>
            Autentificare cu cod SMS
          </Button>

          <Button
            mode="text"
            onPress={() => navigation.navigate('Register')}
            style={styles.linkButton}>
            Nu ai cont? Înregistrează-te
          </Button>

          <Button
            mode="text"
            onPress={() => navigation.navigate('ForgotPassword')}
            style={styles.linkButton}>
            Ai uitat parola?
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
    marginBottom: 40,
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
  otpButton: {
    marginTop: 16,
    paddingVertical: 8,
    borderRadius: 12,
    borderColor: '#1976D2',
    borderWidth: 1.5,
  },
  linkButton: {
    marginTop: 12,
  },
});

export default LoginScreen;

