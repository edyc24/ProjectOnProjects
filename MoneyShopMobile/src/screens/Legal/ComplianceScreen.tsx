import React from 'react';
import {View, StyleSheet, ScrollView} from 'react-native';
import {Text, Card} from 'react-native-paper';

const ComplianceScreen = ({navigation}: any) => {
  return (
    <View style={styles.container}>
      <ScrollView style={styles.scrollView}>
        <View style={styles.content}>
          <Text variant="headlineSmall" style={styles.title}>
            🧾 Pachet Oficial de Conformitate
          </Text>
          <Text variant="bodyMedium" style={styles.subtitle}>
            MoneyShop® – POPIX BROKERAGE CONSULTING S.R.L.
          </Text>
          <Text variant="bodySmall" style={styles.subtitle}>
            (pentru ANAF & Biroul de Credit)
          </Text>

          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                📄 Declarație Oficială MoneyShop
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                MoneyShop®, operată de POPIX BROKERAGE CONSULTING S.R.L., declară:
              </Text>
              <Text variant="bodyMedium" style={styles.warning}>
                1. MoneyShop NU este instituție de credit și NU este IFN{'\n'}
                2. MoneyShop NU este participant în sistemul Biroului de Credit S.A.{'\n'}
                3. MoneyShop NU este afiliat cu ANAF sau Biroul de Credit{'\n'}
                4. MoneyShop NU vinde, nu comercializează și nu revinde rapoarte{'\n'}
                5. MoneyShop acționează exclusiv ca mandatar
              </Text>
            </Card.Content>
          </Card>

          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                📄 Fluxul Operațional
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                1. Utilizatorul solicită analiza eligibilității de credit{'\n'}
                2. Utilizatorul acordă mandat expres, limitat la maximum 30 de zile{'\n'}
                3. MoneyShop interoghează ANAF și Biroul de Credit{'\n'}
                4. Datele sunt utilizate exclusiv pentru analiza eligibilității{'\n'}
                5. Transmiterea către broker are loc doar cu consimțământ distinct
              </Text>
            </Card.Content>
          </Card>

          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                📄 Politica de Mandatare
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                Mandatul este:
              </Text>
              <Text variant="bodyMedium" style={styles.infoBox}>
                • Expres, individual, acordat electronic{'\n'}
                • Durată maximă: 30 zile calendaristice{'\n'}
                • Scop unic: analiză eligibilitate credit{'\n'}
                • Nu este permanent sau general{'\n'}
                • Revocabil oricând de utilizator
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                Fără mandat valid → nicio interogare nu este efectuată.
              </Text>
            </Card.Content>
          </Card>

          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                📄 GDPR – Structură Dual Consent
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                <Text style={styles.bold}>Nivel 1 – Prelucrare în baza mandatului ANAF/BC:</Text>
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                • Fără transmitere către broker{'\n'}
                • Temei: art. 6 alin. (1) lit. b, c, f GDPR{'\n'}
                • Date utilizate exclusiv intern pentru analiză
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                <Text style={styles.bold}>Nivel 2 – Transmitere către broker:</Text>
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                • Consimțământ separat, voluntar{'\n'}
                • Temei: art. 6 alin. (1) lit. a GDPR{'\n'}
                • Utilizatorul poate refuza fără consecințe
              </Text>
              <Text variant="bodyMedium" style={styles.infoBox}>
                Cele două consimțăminte sunt distincte, necondiționate între ele.
              </Text>
            </Card.Content>
          </Card>

          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                📄 Log Juridic de Consimțământ
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                MoneyShop utilizează un log juridic care înregistrează:
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                • Identitatea utilizatorului{'\n'}
                • Textul exact al consimțământului{'\n'}
                • Data și ora{'\n'}
                • IP, device, sesiune{'\n'}
                • Durata mandatului{'\n'}
                • Evenimentul de confirmare
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                Logul este nealterabil, stocat securizat și disponibil ca probă în caz de control.
              </Text>
            </Card.Content>
          </Card>

          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                📄 Date de Contact Oficiale
              </Text>
              <Text variant="bodyMedium" style={styles.text}>
                Pentru orice clarificări suplimentare:{'\n'}
                📧 office@moneyshop.ro{'\n'}
                📧 gdpr@moneyshop.ro{'\n'}
                📞 031 434 0940
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
  subtitle: {
    marginBottom: 24,
    color: '#666',
    textAlign: 'center',
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

export default ComplianceScreen;

