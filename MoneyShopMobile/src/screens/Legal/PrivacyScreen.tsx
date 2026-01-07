import React from 'react';
import {View, StyleSheet, ScrollView} from 'react-native';
import {Text, Card} from 'react-native-paper';

const PrivacyScreen = ({navigation}: any) => {
  return (
    <View style={styles.container}>
      <ScrollView style={styles.scrollView}>
        <View style={styles.content}>
          <Text variant="headlineSmall" style={styles.title}>
            Politica de Confidențialitate (GDPR) – MoneyShop.ro
          </Text>
          <Text variant="bodySmall" style={styles.date}>
            Ultima actualizare: {new Date().toLocaleDateString('ro-RO')}
          </Text>

          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                1. Operatorul de Date
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                <Text style={styles.bold}>POPIX BROKERAGE CONSULTING S.R.L.</Text>
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                Nr. ONRC: J2024018340008{'\n'}
                CUI: 50477260{'\n'}
                E-mail GDPR: gdpr@moneyshop.ro{'\n'}
                E-mail DPO: dpo@moneyshop.ro
              </Text>
            </Card.Content>
          </Card>

          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                2. Scopurile Prelucrării
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                Datele sunt prelucrate exclusiv pentru:
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                • Analiza eligibilității financiare{'\n'}
                • Realizarea analizelor MoneyShop{'\n'}
                • Intermedierea solicitărilor de credit{'\n'}
                • Îndeplinirea obligațiilor legale
              </Text>
            </Card.Content>
          </Card>

          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                3. Prelucrarea Datelor ANAF/BC
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                Datele obținute de la ANAF și Biroul de Credit sunt prelucrate:
              </Text>
              <Text variant="bodyMedium" style={styles.infoBox}>
                • Exclusiv pentru analiza eligibilității de credit{'\n'}
                • În baza mandatului temporar (max. 30 zile){'\n'}
                • Fără transmitere către brokeri sau terți neimplicați
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                Aceste date NU sunt vândute, NU sunt cesionate și NU sunt utilizate în scopuri de marketing.
              </Text>
            </Card.Content>
          </Card>

          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                4. Transmiterea către Brokeri
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                Transmiterea analizei către un broker:
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                • Se face exclusiv cu consimțământ separat{'\n'}
                • Este inițiată doar de utilizator{'\n'}
                • Nu este condiție pentru utilizarea Platformei{'\n'}
                • Poate fi refuzată fără consecințe
              </Text>
            </Card.Content>
          </Card>

          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                5. Drepturile Tale
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                Beneficiezi de drepturile prevăzute la art. 12–22 GDPR:
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                • Dreptul de acces{'\n'}
                • Dreptul la rectificare{'\n'}
                • Dreptul la ștergere{'\n'}
                • Dreptul la portabilitate{'\n'}
                • Dreptul de opoziție
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                Solicitări: gdpr@moneyshop.ro
              </Text>
            </Card.Content>
          </Card>

          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                Contact GDPR
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                Email GDPR: gdpr@moneyshop.ro{'\n'}
                Email DPO: dpo@moneyshop.ro{'\n'}
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
  bold: {
    fontWeight: '600',
  },
  infoBox: {
    marginTop: 8,
    padding: 16,
    backgroundColor: '#E3F2FD',
    borderRadius: 12,
    color: '#1976D2',
    borderLeftWidth: 4,
    borderLeftColor: '#2196F3',
  },
});

export default PrivacyScreen;

