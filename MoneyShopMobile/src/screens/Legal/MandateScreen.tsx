import React from 'react';
import {View, StyleSheet, ScrollView} from 'react-native';
import {Text, Card} from 'react-native-paper';

const MandateScreen = ({navigation}: any) => {
  return (
    <View style={styles.container}>
      <ScrollView style={styles.scrollView}>
        <View style={styles.content}>
          <Text variant="headlineSmall" style={styles.title}>
            Politica de Mandatare – MoneyShop.ro
          </Text>
          <Text variant="bodySmall" style={styles.date}>
            Ultima actualizare: {new Date().toLocaleDateString('ro-RO')}
          </Text>

          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                1. Natura Mandatului
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                Prezenta Politică stabilește condițiile în care acordați un mandat expres, limitat și temporar societății POPIX BROKERAGE CONSULTING S.R.L.
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                Mandatul este acordat electronic, la distanță, prin acțiune explicită (checkbox / confirmare digitală).
              </Text>
            </Card.Content>
          </Card>

          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                2. Obiectul Mandatului
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                Mandatul constă exclusiv în:
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                • Interogarea veniturilor la ANAF{'\n'}
                • Interogarea situației la Biroul de Credit{'\n'}
                • Analiza eligibilității de credit{'\n'}
                • Realizarea analizei MoneyShop
              </Text>
            </Card.Content>
          </Card>

          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                3. Durata Limitată
              </Text>
              <Text variant="bodyMedium" style={styles.warning}>
                Mandatul este valabil pentru o perioadă maximă de 30 (treizeci) de zile calendaristice, calculate de la data acordării consimțământului.
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                La expirarea termenului, mandatul încetează de drept și orice nouă interogare necesită un nou mandat expres.
              </Text>
            </Card.Content>
          </Card>

          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                4. Limitări Exprese
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                Este expres interzis ca datele:
              </Text>
              <Text variant="bodyMedium" style={styles.warning}>
                • Să fie vândute{'\n'}
                • Să fie cesionate{'\n'}
                • Să fie utilizate în scopuri comerciale sau de marketing{'\n'}
                • Să fie transmise către terți neimplicați
              </Text>
            </Card.Content>
          </Card>

          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                5. Revocarea Mandatului
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                Poți revoca mandatul:
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                • În orice moment{'\n'}
                • Fără justificare{'\n'}
                • Cu efect pentru viitor
              </Text>
            </Card.Content>
          </Card>

          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                Contact
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                Email: office@moneyshop.ro{'\n'}
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
  warning: {
    marginTop: 8,
    padding: 16,
    backgroundColor: '#FFF9E6',
    borderRadius: 12,
    color: '#856404',
    borderLeftWidth: 4,
    borderLeftColor: '#FFC107',
  },
});

export default MandateScreen;

