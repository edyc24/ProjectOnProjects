import React, {useState} from 'react';
import {View, StyleSheet, KeyboardAvoidingView, Platform} from 'react-native';
import {TextInput, Button, Text, Snackbar} from 'react-native-paper';
import {NativeStackNavigationProp} from '@react-navigation/native-stack';
import {AuthStackParamList} from '../../navigation/AuthNavigator';

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
      <View style={styles.content}>
        <Text variant="headlineLarge" style={styles.title}>
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
    backgroundColor: '#fff',
  },
  content: {
    flex: 1,
    padding: 20,
    justifyContent: 'center',
  },
  title: {
    textAlign: 'center',
    marginBottom: 10,
    fontWeight: 'bold',
  },
  subtitle: {
    textAlign: 'center',
    marginBottom: 30,
    color: '#666',
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

export default ForgotPasswordScreen;

