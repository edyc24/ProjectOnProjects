import React from 'react';
import {View, StyleSheet} from 'react-native';
import {Card, Text, Button} from 'react-native-paper';
import {NativeStackNavigationProp} from '@react-navigation/native-stack';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

type ApplicationSuccessScreenNavigationProp = NativeStackNavigationProp<any>;

interface Props {
  navigation: ApplicationSuccessScreenNavigationProp;
}

const ApplicationSuccessScreen: React.FC<Props> = ({navigation}) => {
  return (
    <View style={styles.container}>
      <Card style={styles.card}>
        <Card.Content style={styles.content}>
          <Icon name="check-circle" size={80} color="#4CAF50" />
          <Text variant="headlineMedium" style={styles.title}>
            Cererea a fost trimisă!
          </Text>
          <Text variant="bodyMedium" style={styles.message}>
            Cererea ta de credit a fost înregistrată cu succes. Vei primi
            notificări despre statusul cererii.
          </Text>
          <Button
            mode="contained"
            onPress={() => navigation.navigate('Dashboard')}
            style={styles.button}>
            Mergi la Dashboard
          </Button>
        </Card.Content>
      </Card>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f5f5f5',
    padding: 20,
  },
  card: {
    width: '100%',
    maxWidth: 400,
  },
  content: {
    alignItems: 'center',
    padding: 24,
  },
  title: {
    marginTop: 16,
    marginBottom: 12,
    textAlign: 'center',
    fontWeight: 'bold',
  },
  message: {
    textAlign: 'center',
    marginBottom: 24,
    color: '#666',
  },
  button: {
    marginTop: 8,
    paddingVertical: 5,
  },
});

export default ApplicationSuccessScreen;

