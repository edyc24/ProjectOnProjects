import React from 'react';
import {View, StyleSheet, ScrollView} from 'react-native';
import {Text, Card} from 'react-native-paper';

const TermsScreen = ({navigation}: any) => {
  return (
    <View style={styles.container}>
      <ScrollView style={styles.scrollView}>
        <View style={styles.content}>
          <Text variant="headlineSmall" style={styles.title}>
            Termeni și Condiții de Utilizare – MoneyShop.ro
          </Text>
          <Text variant="bodySmall" style={styles.date}>
            Ultima actualizare: {new Date().toLocaleDateString('ro-RO')}
          </Text>

          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                1. Dispoziții Generale
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                Prezentul document stabilește termenii și condițiile de utilizare a platformei digitale www.MoneyShop.ro, precum și a aplicațiilor mobile MoneyShop.
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                Platforma este operată de <Text style={styles.bold}>POPIX BROKERAGE CONSULTING S.R.L.</Text>, societate română organizată și funcționând în conformitate cu legislația în vigoare din România.
              </Text>
            </Card.Content>
          </Card>

          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                2. Identitatea Operatorului
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                <Text style={styles.bold}>POPIX BROKERAGE CONSULTING S.R.L.</Text>
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                Nr. ONRC: J2024018340008{'\n'}
                CUI: 50477260{'\n'}
                Sediu: Mun. Râmnicu Vâlcea, Str. Constantin Brâncuși nr. 8{'\n'}
                Telefon: 031 434 0940{'\n'}
                E-mail: office@moneyshop.ro
              </Text>
            </Card.Content>
          </Card>

          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                3. Statutul Juridic al MoneyShop
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                MoneyShop este o platformă digitală de intermediere, informare și analiză financiară.
              </Text>
              <Text variant="bodyMedium" style={styles.warning}>
                În mod expres, se precizează că:{'\n'}
                • MoneyShop NU este instituție de credit{'\n'}
                • MoneyShop NU este IFN{'\n'}
                • MoneyShop NU acordă credite{'\n'}
                • MoneyShop NU aprobă cereri de credit
              </Text>
            </Card.Content>
          </Card>

          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                4. Natura Serviciilor
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                Platforma pune la dispoziție:
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                • Simulări financiare orientative{'\n'}
                • Informații generale despre produse de creditare{'\n'}
                • Analiză preliminară de eligibilitate{'\n'}
                • Servicii de intermediere între utilizator și creditori
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                Toate simulările au caracter strict informativ, nefiind oferte ferme sau promisiuni de creditare.
              </Text>
            </Card.Content>
          </Card>

          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                5. Limitarea Răspunderii
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                În limitele permise de lege, MoneyShop nu răspunde pentru:
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                • Deciziile creditorilor{'\n'}
                • Refuzuri de creditare{'\n'}
                • Modificări de dobânzi sau condiții{'\n'}
                • Pierderi indirecte sau de oportunitate
              </Text>
            </Card.Content>
          </Card>

          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                Contact
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                Pentru întrebări sau clarificări:{'\n'}
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
  bold: {
    fontWeight: '600',
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

export default TermsScreen;

