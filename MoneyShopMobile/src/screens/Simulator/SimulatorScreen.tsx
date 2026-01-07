import React from 'react';
import {View, StyleSheet, ScrollView} from 'react-native';
import {Text, Button, Card} from 'react-native-paper';
import {NativeStackNavigationProp} from '@react-navigation/native-stack';
import {useAuthStore} from '../../store/authStore';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

type SimulatorScreenNavigationProp = NativeStackNavigationProp<any, 'Simulator'>;

interface Props {
  navigation: SimulatorScreenNavigationProp;
}

const SimulatorScreen: React.FC<Props> = ({navigation}) => {
  const {isAuthenticated} = useAuthStore();

  return (
    <ScrollView style={styles.container}>
      <View style={styles.content}>
        <View style={styles.headerSection}>
          <Text variant="headlineSmall" style={styles.welcomeText}>
            MoneyShop<Text style={styles.superscript}>®</Text>
          </Text>
          <Text variant="bodyMedium" style={styles.tagline}>
            Simplu. Rapid. Transparent.
          </Text>
          <Text variant="bodyMedium" style={styles.description}>
            Platformă digitală de intermediere credite. Analizează eligibilitatea ta de credit în câteva minute, cu transparență totală.
          </Text>
        </View>

        {/* Simulator Card - Large and Prominent */}
        <Card 
          style={styles.simulatorCard}
          onPress={() => navigation.navigate('SimulatorForm')}>
          <Card.Content style={styles.simulatorCardContent}>
            <View style={styles.simulatorHeader}>
              <View style={styles.simulatorIconContainer}>
                <Icon name="calculator-variant" size={40} color="#FFFFFF" />
              </View>
              <View style={styles.simulatorTextContainer}>
                <Text variant="headlineSmall" style={styles.simulatorTitle}>
                  Simulator Credit
                </Text>
                <Text variant="bodyMedium" style={styles.simulatorDescription}>
                  Calculează rata ta lunară și vezi ofertele disponibile
                </Text>
              </View>
            </View>
            <View style={styles.simulatorFooter}>
              <Text variant="bodySmall" style={styles.simulatorActionText}>
                Începe simularea →
              </Text>
            </View>
          </Card.Content>
        </Card>

        {/* Info Card */}
        <Card style={styles.infoCard}>
          <Card.Content style={styles.infoCardContent}>
            <View style={styles.infoRow}>
              <View style={styles.infoIconContainer}>
                <Icon name="information" size={24} color="#1976D2" />
              </View>
              <View style={styles.infoTextContainer}>
                <Text variant="bodySmall" style={styles.infoTitle}>
                  Gratuit și fără înregistrare
                </Text>
                <Text variant="bodySmall" style={styles.infoText}>
                  Simulatorul este complet gratuit. Pentru a salva datele și a vedea istoricul, te poți autentifica.
                </Text>
              </View>
            </View>
          </Card.Content>
        </Card>

        {/* Auth Actions for non-authenticated users */}
        {!isAuthenticated && (
          <View style={styles.authSection}>
            <Text variant="titleMedium" style={styles.authSectionTitle}>
              Ai deja cont?
            </Text>
            <View style={styles.authButtons}>
              <Card 
                style={styles.authCard}
                onPress={() => navigation.navigate('Login')}>
                <Card.Content style={styles.authCardContent}>
                  <View style={[styles.authIcon, {backgroundColor: '#E3F2FD'}]}>
                    <Icon name="login" size={28} color="#1976D2" />
                  </View>
                  <Text variant="bodySmall" style={styles.authCardText}>
                    Autentificare
                  </Text>
                </Card.Content>
              </Card>

              <Card 
                style={styles.authCard}
                onPress={() => navigation.navigate('Register')}>
                <Card.Content style={styles.authCardContent}>
                  <View style={[styles.authIcon, {backgroundColor: '#E8F5E9'}]}>
                    <Icon name="account-plus" size={28} color="#4CAF50" />
                  </View>
                  <Text variant="bodySmall" style={styles.authCardText}>
                    Înregistrare
                  </Text>
                </Card.Content>
              </Card>
            </View>
          </View>
        )}
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F8F9FA',
  },
  content: {
    padding: 16,
  },
  headerSection: {
    marginBottom: 24,
    paddingTop: 8,
    alignItems: 'center',
  },
  welcomeText: {
    fontWeight: '700',
    color: '#1A1A1A',
    fontSize: 32,
    letterSpacing: -0.5,
    marginBottom: 8,
    textAlign: 'center',
  },
  superscript: {
    fontSize: 16,
    fontWeight: '400',
  },
  tagline: {
    color: '#1976D2',
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 12,
    textAlign: 'center',
  },
  description: {
    color: '#64748B',
    fontSize: 15,
    lineHeight: 22,
    textAlign: 'center',
    paddingHorizontal: 8,
  },
  // Simulator Card - Large and Prominent
  simulatorCard: {
    marginBottom: 20,
    borderRadius: 24,
    elevation: 4,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 4},
    shadowOpacity: 0.12,
    shadowRadius: 16,
    backgroundColor: '#FFFFFF',
    borderWidth: 0,
    overflow: 'hidden',
  },
  simulatorCardContent: {
    padding: 24,
  },
  simulatorHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 16,
  },
  simulatorIconContainer: {
    width: 72,
    height: 72,
    borderRadius: 20,
    backgroundColor: '#1976D2',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  simulatorTextContainer: {
    flex: 1,
  },
  simulatorTitle: {
    fontWeight: '700',
    color: '#1A1A1A',
    fontSize: 22,
    marginBottom: 4,
  },
  simulatorDescription: {
    color: '#64748B',
    fontSize: 14,
    lineHeight: 20,
  },
  simulatorFooter: {
    borderTopWidth: 1,
    borderTopColor: '#E5E7EB',
    paddingTop: 16,
    marginTop: 8,
  },
  simulatorActionText: {
    color: '#1976D2',
    fontWeight: '600',
    fontSize: 14,
  },
  // Info Card
  infoCard: {
    marginBottom: 24,
    borderRadius: 20,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 2},
    shadowOpacity: 0.08,
    shadowRadius: 8,
    backgroundColor: '#FFFFFF',
    borderWidth: 0,
  },
  infoCardContent: {
    padding: 20,
  },
  infoRow: {
    flexDirection: 'row',
    alignItems: 'flex-start',
  },
  infoIconContainer: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: '#E3F2FD',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  infoTextContainer: {
    flex: 1,
  },
  infoTitle: {
    fontWeight: '600',
    color: '#1A1A1A',
    marginBottom: 6,
    fontSize: 14,
  },
  infoText: {
    color: '#64748B',
    lineHeight: 20,
    fontSize: 13,
  },
  // Auth Section
  authSection: {
    marginTop: 8,
  },
  authSectionTitle: {
    marginBottom: 16,
    fontWeight: '600',
    color: '#1A1A1A',
    fontSize: 18,
    textAlign: 'center',
  },
  authButtons: {
    flexDirection: 'row',
    gap: 12,
  },
  authCard: {
    flex: 1,
    borderRadius: 20,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 2},
    shadowOpacity: 0.08,
    shadowRadius: 8,
    backgroundColor: '#FFFFFF',
    borderWidth: 0,
  },
  authCardContent: {
    padding: 20,
    alignItems: 'center',
  },
  authIcon: {
    width: 56,
    height: 56,
    borderRadius: 16,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 12,
  },
  authCardText: {
    color: '#1A1A1A',
    fontWeight: '600',
    fontSize: 13,
    textAlign: 'center',
  },
});

export default SimulatorScreen;

