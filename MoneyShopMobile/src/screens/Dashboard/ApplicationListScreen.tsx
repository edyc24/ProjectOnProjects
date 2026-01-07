import React from 'react';
import {View, StyleSheet, FlatList} from 'react-native';
import {Card, Text, ActivityIndicator} from 'react-native-paper';
import {useQuery} from '@tanstack/react-query';
import {applicationsApi} from '../../services/api/applicationsApi';
import {Application} from '../../types/application.types';

const ApplicationListScreen = () => {
  const {data: applications, isLoading} = useQuery({
    queryKey: ['applications'],
    queryFn: applicationsApi.getAll,
  });

  if (isLoading) {
    return (
      <View style={styles.center}>
        <ActivityIndicator size="large" />
      </View>
    );
  }

  const renderApplication = ({item}: {item: Application}) => (
    <Card style={styles.card}>
      <Card.Content>
        <Text variant="titleMedium">
          {item.typeCredit === 'ipotecar'
            ? 'Credit Ipotecar'
            : 'Credit Nevoi Personale'}
        </Text>
        <Text variant="bodySmall" style={styles.status}>
          Status: {item.status}
        </Text>
        <Text variant="bodySmall" style={styles.date}>
          {new Date(item.createdAt).toLocaleDateString('ro-RO')}
        </Text>
      </Card.Content>
    </Card>
  );

  return (
    <View style={styles.container}>
      <FlatList
        data={applications}
        renderItem={renderApplication}
        keyExtractor={item => item.id.toString()}
        contentContainerStyle={styles.list}
        ListEmptyComponent={
          <View style={styles.empty}>
            <Text>Nu ai nicio cerere</Text>
          </View>
        }
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  center: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  list: {
    padding: 16,
  },
  card: {
    marginBottom: 12,
  },
  status: {
    marginTop: 8,
    color: '#666',
  },
  date: {
    marginTop: 4,
    color: '#999',
  },
  empty: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingTop: 100,
  },
});

export default ApplicationListScreen;

