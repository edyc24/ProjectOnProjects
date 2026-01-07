import React from 'react';
import {View, StyleSheet, ScrollView} from 'react-native';
import {Card, Text, Button, Divider} from 'react-native-paper';
import {useAuthStore} from '../../store/authStore';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import {NativeStackNavigationProp} from '@react-navigation/native-stack';

type ProfileScreenNavigationProp = NativeStackNavigationProp<any, 'Profile'>;

interface Props {
  navigation: ProfileScreenNavigationProp;
}

const ProfileScreen = ({navigation}: Props) => {
  const {user, logout} = useAuthStore();

  const handleLogout = async () => {
    await logout();
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.content}>
        <Card style={styles.card}>
          <Card.Content>
            <View style={styles.profileHeader}>
              <Icon name="account-circle" size={64} color="#6200ee" />
              <Text variant="headlineSmall" style={styles.name}>
                {user?.name}
              </Text>
              <Text variant="bodyMedium" style={styles.email}>
                {user?.email}
              </Text>
            </View>
          </Card.Content>
        </Card>

        <Card style={styles.card}>
          <Card.Content>
            <Button
              icon="cog"
              mode="text"
              onPress={() => {}}
              style={styles.menuItem}>
              Setări
            </Button>
            <Divider />
            <Button
              icon="help-circle"
              mode="text"
              onPress={() => {}}
              style={styles.menuItem}>
              Ajutor
            </Button>
            <Divider />
            <Button
              icon="file-document-multiple"
              mode="text"
              onPress={() => {
                navigation.navigate('LegalMenu');
              }}
              style={styles.menuItem}>
              Informații Legale
            </Button>
            <Divider />
            <Button
              icon="checkbox-marked-circle"
              mode="text"
              onPress={() => {
                navigation.navigate('ConsentManagement');
              }}
              style={styles.menuItem}>
              Consimțământ
            </Button>
            <Divider />
            <Button
              icon="file-sign"
              mode="text"
              onPress={() => {
                navigation.navigate('MandateManagement');
              }}
              style={styles.menuItem}>
              Mandate
            </Button>
            <Divider />
            <Button
              icon="chart-line"
              mode="text"
              onPress={() => {
                navigation.navigate('FinancialData');
              }}
              style={styles.menuItem}>
              Date Financiare
            </Button>
            <Divider />
            <Button
              icon="office-building"
              mode="text"
              onPress={() => {
                navigation.navigate('BrokerDirectory');
              }}
              style={styles.menuItem}>
              Director Brokeri
            </Button>
            {user?.role !== 'Administrator' && (
              <>
                <Divider />
                <Button
                  icon="card-account-details"
                  mode="text"
                  onPress={() => {
                    navigation.navigate('KycForm');
                  }}
                  style={styles.menuItem}>
                  Verificare Identitate (KYC)
                </Button>
              </>
            )}
            {user?.role === 'Administrator' && (
              <>
                <Divider />
                <Button
                  icon="shield-check"
                  mode="text"
                  onPress={() => {
                    navigation.navigate('KycAdmin');
                  }}
                  style={styles.menuItem}>
                  Verificări KYC (Admin)
                </Button>
              </>
            )}
            <Divider />
            <Button
              icon="email-check"
              mode="text"
              onPress={() => {
                const parent = navigation.getParent();
                if (parent) {
                  parent.navigate('Auth', {
                    screen: 'Verification',
                    params: {
                      type: 'email',
                      email: user?.email,
                    },
                  });
                }
              }}
              style={styles.menuItem}>
              Verifică Email
            </Button>
            <Divider />
            <Button
              icon="phone-check"
              mode="text"
              onPress={() => {
                const parent = navigation.getParent();
                if (parent) {
                  parent.navigate('Auth', {
                    screen: 'Verification',
                    params: {
                      type: 'phone',
                      phone: user?.phone,
                    },
                  });
                }
              }}
              style={styles.menuItem}>
              Verifică Telefon
            </Button>
            <Divider />
            <Button
              icon="information"
              mode="text"
              onPress={() => {}}
              style={styles.menuItem}>
              Despre aplicație
            </Button>
          </Card.Content>
        </Card>

        <Button
          mode="outlined"
          onPress={handleLogout}
          style={styles.logoutButton}
          textColor="#F44336">
          Deconectare
        </Button>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FAFAFA',
  },
  content: {
    padding: 20,
  },
  card: {
    marginBottom: 16,
    borderRadius: 16,
    elevation: 0,
    shadowOpacity: 0,
    backgroundColor: '#FFFFFF',
    borderWidth: 0,
  },
  profileHeader: {
    alignItems: 'center',
    paddingVertical: 24,
  },
  name: {
    marginTop: 16,
    fontWeight: '600',
    color: '#333',
  },
  email: {
    marginTop: 8,
    color: '#666',
  },
  menuItem: {
    justifyContent: 'flex-start',
    paddingVertical: 12,
  },
  logoutButton: {
    marginTop: 24,
    borderColor: '#F44336',
    borderRadius: 12,
  },
});

export default ProfileScreen;

