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
import Logo from '../../components/Logo';

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
            <Logo size="large" showTagline />
          </View>
          <Text variant="titleLarge" style={styles.subtitle}>
            Autentificare
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
    backgroundColor: '#FAFAFA',
  },
  scrollContent: {
    flexGrow: 1,
    justifyContent: 'center',
  },
  content: {
    padding: 24,
    maxWidth: 400,
    alignSelf: 'center',
    width: '100%',
  },
  logoContainer: {
    alignItems: 'center',
    marginBottom: 32,
  },
  subtitle: {
    textAlign: 'center',
    marginBottom: 32,
    color: '#666',
    fontWeight: '500',
  },
  input: {
    marginBottom: 16,
    backgroundColor: '#FFFFFF',
  },
  button: {
    marginTop: 8,
    paddingVertical: 6,
    borderRadius: 12,
  },
  otpButton: {
    marginTop: 16,
    paddingVertical: 6,
    borderRadius: 12,
  },
  linkButton: {
    marginTop: 12,
  },
});

export default LoginScreen;

