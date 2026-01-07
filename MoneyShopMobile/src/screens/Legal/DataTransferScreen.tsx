import React from 'react';
import {View, StyleSheet, ScrollView} from 'react-native';
import {Text, Card} from 'react-native-paper';

const DataTransferScreen = ({navigation}: any) => {
  return (
    <View style={styles.container}>
      <ScrollView style={styles.scrollView}>
        <View style={styles.content}>
          <Text variant="headlineSmall" style={styles.title}>
            Politica de Transmitere a Datelor către Brokeri Autorizați
          </Text>
          <Text variant="bodySmall" style={styles.date}>
            Ultima actualizare: {new Date().toLocaleDateString('ro-RO')}
          </Text>

          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                1. Principiul Consimțământului Distinct
              </Text>
              <Text variant="bodyMedium" style={styles.infoBox}>
                Transmiterea datelor către brokeri se face EXCLUSIV cu consimțământ separat și distinct de utilizator.
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                Această transmitere:
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                • Este inițiată doar de utilizator{'\n'}
                • Nu este condiție pentru utilizarea Platformei{'\n'}
                • Nu afectează accesul la serviciile MoneyShop în cazul refuzului
              </Text>
            </Card.Content>
          </Card>

          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                2. Datele Transmise
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                La solicitarea expresă a utilizatorului, MoneyShop poate transmite către brokerul ales:
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                • Analiza MoneyShop de eligibilitate credit{'\n'}
                • O copie a raportului ANAF (dacă a fost interogat){'\n'}
                • O copie a raportului Biroului de Credit (dacă a fost interogat){'\n'}
                • Documentele KYC (doar dacă utilizatorul acceptă explicit)
              </Text>
            </Card.Content>
          </Card>

          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                3. Brokerii Autorizați
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                MoneyShop transmite datele exclusiv către:
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                • Brokeri înscriși în lista publică ANPC{'\n'}
                • Brokeri care au trecut procesul de verificare KYC{'\n'}
                • Brokeri aleși explicit de utilizator
              </Text>
            </Card.Content>
          </Card>

          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                4. Securitatea Transmiterii
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                Transmiterea datelor se face:
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                • Prin canale securizate (criptare){'\n'}
                • Cu confirmare de primire{'\n'}
                • Cu logare a evenimentului în sistemul de audit
              </Text>
            </Card.Content>
          </Card>

          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                5. Retragerea Consimțământului
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                Poți retrage consimțământul pentru transmiterea datelor:
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                • În orice moment{'\n'}
                • Fără consecințe{'\n'}
                • Cu efect pentru viitor (nu afectează transmiterile deja efectuate)
              </Text>
            </Card.Content>
          </Card>

          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                Contact
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                Pentru întrebări despre transmiterea datelor:{'\n'}
                Email: gdpr@moneyshop.ro{'\n'}
                Telefon: 031 434 0940
              </Text>
            </Card.Content>
          </Card>
        </View>
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FAFAFA',
  },
  scrollView: {
    flex: 1,
  },
  content: {
    padding: 20,
  },
  title: {
    marginBottom: 8,
    fontWeight: '600',
    color: '#333',
  },
  date: {
    marginBottom: 24,
    color: '#999',
    fontSize: 12,
  },
  card: {
    marginBottom: 16,
    borderRadius: 16,
    elevation: 0,
    shadowOpacity: 0,
    backgroundColor: '#FFFFFF',
    borderWidth: 0,
  },
  sectionTitle: {
    marginBottom: 12,
    fontWeight: '600',
    color: '#1976D2',
    fontSize: 18,
  },
  text: {
    marginBottom: 12,
    lineHeight: 24,
    color: '#333',
  },
  infoBox: {
    marginTop: 8,
    padding: 16,
    backgroundColor: '#E3F2FD',
    borderRadius: 12,
    color: '#1976D2',
    fontWeight: '600',
    borderLeftWidth: 4,
    borderLeftColor: '#2196F3',
  },
});

export default DataTransferScreen;

