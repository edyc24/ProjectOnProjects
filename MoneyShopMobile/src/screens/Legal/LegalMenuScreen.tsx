import React from 'react';
import {View, StyleSheet, ScrollView} from 'react-native';
import {Card, Button, Text, Divider} from 'react-native-paper';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

const LegalMenuScreen = ({navigation}: any) => {
  return (
    <View style={styles.container}>
      <ScrollView style={styles.scrollView}>
        <View style={styles.content}>
          <Text variant="headlineSmall" style={styles.title}>
            Documente Legale
          </Text>
          <Text variant="bodyMedium" style={styles.subtitle}>
            Accesează documentele legale și politicile MoneyShop
          </Text>

          <Card style={styles.card}>
            <Card.Content>
              <Button
                icon="file-document"
                mode="text"
                onPress={() => navigation.navigate('Terms')}
                style={styles.menuItem}
                contentStyle={styles.menuItemContent}>
                <View style={styles.menuItemView}>
                  <Icon name="file-document" size={24} color="#1976D2" />
                  <View style={styles.menuItemText}>
                    <Text variant="titleMedium">Termeni și Condiții</Text>
                    <Text variant="bodySmall" style={styles.description}>
                      Condițiile de utilizare a platformei
                    </Text>
                  </View>
                </View>
              </Button>
              <Divider />
              <Button
                icon="shield-lock"
                mode="text"
                onPress={() => navigation.navigate('Privacy')}
                style={styles.menuItem}
                contentStyle={styles.menuItemContent}>
                <View style={styles.menuItemView}>
                  <Icon name="shield-lock" size={24} color="#1976D2" />
                  <View style={styles.menuItemText}>
                    <Text variant="titleMedium">Politica de Confidențialitate</Text>
                    <Text variant="bodySmall" style={styles.description}>
                      GDPR și protecția datelor personale
                    </Text>
                  </View>
                </View>
              </Button>
              <Divider />
              <Button
                icon="file-sign"
                mode="text"
                onPress={() => navigation.navigate('Mandate')}
                style={styles.menuItem}
                contentStyle={styles.menuItemContent}>
                <View style={styles.menuItemView}>
                  <Icon name="file-sign" size={24} color="#1976D2" />
                  <View style={styles.menuItemText}>
                    <Text variant="titleMedium">Politica de Mandatare</Text>
                    <Text variant="bodySmall" style={styles.description}>
                      Mandat ANAF și Biroul de Credit
                    </Text>
                  </View>
                </View>
              </Button>
              <Divider />
              <Button
                icon="file-document-multiple"
                mode="text"
                onPress={() => navigation.navigate('Compliance')}
                style={styles.menuItem}
                contentStyle={styles.menuItemContent}>
                <View style={styles.menuItemView}>
                  <Icon name="file-document-multiple" size={24} color="#1976D2" />
                  <View style={styles.menuItemText}>
                    <Text variant="titleMedium">Pachet de Conformitate</Text>
                    <Text variant="bodySmall" style={styles.description}>
                      Documente pentru ANAF și Biroul de Credit
                    </Text>
                  </View>
                </View>
              </Button>
              <Divider />
              <Button
                icon="file-send"
                mode="text"
                onPress={() => navigation.navigate('DataTransfer')}
                style={styles.menuItem}
                contentStyle={styles.menuItemContent}>
                <View style={styles.menuItemView}>
                  <Icon name="file-send" size={24} color="#1976D2" />
                  <View style={styles.menuItemText}>
                    <Text variant="titleMedium">Politica de Transmitere Date</Text>
                    <Text variant="bodySmall" style={styles.description}>
                      Transmiterea datelor către brokeri autorizați
                    </Text>
                  </View>
                </View>
              </Button>
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
  },
  card: {
    marginBottom: 16,
    borderRadius: 16,
    elevation: 0,
    shadowOpacity: 0,
    backgroundColor: '#FFFFFF',
    borderWidth: 0,
  },
  menuItem: {
    justifyContent: 'flex-start',
    paddingVertical: 12,
  },
  menuItemContent: {
    justifyContent: 'flex-start',
  },
  menuItemView: {
    flexDirection: 'row',
    alignItems: 'center',
    width: '100%',
  },
  menuItemText: {
    marginLeft: 16,
    flex: 1,
  },
  description: {
    color: '#666',
    marginTop: 4,
  },
});

export default LegalMenuScreen;

