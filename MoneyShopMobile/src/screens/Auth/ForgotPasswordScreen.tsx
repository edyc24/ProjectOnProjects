import React, {useState} from 'react';
import {View, StyleSheet, KeyboardAvoidingView, Platform, Image, ScrollView} from 'react-native';
import {TextInput, Button, Text, Snackbar} from 'react-native-paper';
import {NativeStackNavigationProp} from '@react-navigation/native-stack';
import {AuthStackParamList} from '../../navigation/AuthNavigator';

const logoImage = require('../../../assets/images/logo/Logo.PNG');

type ForgotPasswordScreenNavigationProp = NativeStackNavigationProp<
  AuthStackParamList,
  'ForgotPassword'
>;

interface Props {
  navigation: ForgotPasswordScreenNavigationProp;
}

const ForgotPasswordScreen: React.FC<Props> = ({navigation}) => {
  const [email, setEmail] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [showError, setShowError] = useState(false);
  const [success, setSuccess] = useState(false);

  const handleResetPassword = async () => {
    if (!email) {
      setError('Te rugăm să introduci adresa de email');
      setShowError(true);
      return;
    }

    try {
      setLoading(true);
      setError(null);
      // TODO: Implement password reset API call
      // await authApi.forgotPassword(email);
      setSuccess(true);
      setTimeout(() => {
        navigation.navigate('Login');
      }, 2000);
    } catch (err: any) {
      setError(err.response?.data?.message || 'Eroare la resetarea parolei');
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
            Resetare parolă
          </Text>
          <Text variant="bodyMedium" style={styles.subtitle}>
            Introdu adresa ta de email și vei primi instrucțiuni pentru resetarea
            parolei.
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

        <Button
          mode="contained"
          onPress={handleResetPassword}
          loading={loading}
          disabled={loading}
          style={styles.button}>
          Trimite email
        </Button>

        <Button
          mode="text"
          onPress={() => navigation.navigate('Login')}
          style={styles.linkButton}>
          Înapoi la autentificare
        </Button>
        </View>
      </ScrollView>

      <Snackbar
        visible={showError}
        onDismiss={() => setShowError(false)}
        duration={3000}>
        {error || 'Eroare'}
      </Snackbar>

      <Snackbar
        visible={success}
        onDismiss={() => setSuccess(false)}
        duration={3000}
        style={{backgroundColor: '#4caf50'}}>
        Email trimis cu succes!
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
    lineHeight: 24,
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
});

export default ForgotPasswordScreen;

