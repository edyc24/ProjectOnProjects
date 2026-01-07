import React from 'react';
import {View, StyleSheet, ScrollView} from 'react-native';
import {Card, Text, Button, Chip} from 'react-native-paper';
import {ScoringResult} from '../../types/application.types';
import {NativeStackNavigationProp} from '@react-navigation/native-stack';
import {LineChart} from 'react-native-chart-kit';
import {Dimensions} from 'react-native';

type SimulatorResultScreenNavigationProp = NativeStackNavigationProp<any>;

interface Props {
  navigation: SimulatorResultScreenNavigationProp;
  route: {
    params: {
      result: ScoringResult;
    };
  };
}

const SimulatorResultScreen: React.FC<Props> = ({navigation, route}) => {
  const {result} = route.params;

  const getScoringEmoji = (level: string) => {
    switch (level) {
      case 'foarte_mare':
        return '1️⃣';
      case 'mare':
        return '2️⃣';
      case 'bun':
        return '3️⃣';
      case 'conditii_speciale':
        return '4️⃣';
      case 'foarte_scazut':
        return '5️⃣';
      default:
        return '';
    }
  };

  const getScoringText = (level: string) => {
    switch (level) {
      case 'foarte_mare':
        return 'Șanse foarte mari';
      case 'mare':
        return 'Șanse bune';
      case 'bun':
        return 'Posibile, dar cu condiții';
      case 'conditii_speciale':
        return 'Scăzute';
      case 'foarte_scazut':
        return 'Foarte scăzute';
      default:
        return level;
    }
  };

  const getScoringColor = (level: string) => {
    switch (level) {
      case 'foarte_mare':
        return '#4CAF50';
      case 'mare':
        return '#8BC34A';
      case 'bun':
        return '#FFC107';
      case 'conditii_speciale':
        return '#FF9800';
      case 'foarte_scazut':
        return '#F44336';
      default:
        return '#757575';
    }
  };

  const screenWidth = Dimensions.get('window').width;

  const chartData = {
    labels: ['DTI'],
    datasets: [
      {
        data: [result.dti * 100],
        color: (opacity = 1) => getScoringColor(result.scoringLevel),
        strokeWidth: 2,
      },
    ],
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.content}>
        <Card style={styles.resultCard}>
          <Card.Content>
            <View style={styles.resultHeader}>
              <Text variant="displaySmall" style={styles.emoji}>
                {getScoringEmoji(result.scoringLevel)}
              </Text>
              <Text variant="headlineMedium" style={styles.resultTitle}>
                {getScoringText(result.scoringLevel)}
              </Text>
            </View>

            <View style={styles.metrics}>
              <View style={styles.metric}>
                <Text variant="titleMedium">DTI</Text>
                <Text variant="headlineSmall" style={styles.metricValue}>
                  {(result.dti * 100).toFixed(1)}%
                </Text>
              </View>
              <View style={styles.metric}>
                <Text variant="titleMedium">Nivel recomandat</Text>
                <Chip
                  style={[
                    styles.chip,
                    {backgroundColor: getScoringColor(result.scoringLevel)},
                  ]}>
                  {result.recommendedLevel}
                </Chip>
              </View>
            </View>

            <LineChart
              data={chartData}
              width={screenWidth - 64}
              height={200}
              chartConfig={{
                backgroundColor: '#ffffff',
                backgroundGradientFrom: '#ffffff',
                backgroundGradientTo: '#ffffff',
                decimalPlaces: 1,
                color: (opacity = 1) => getScoringColor(result.scoringLevel),
                labelColor: (opacity = 1) => '#333',
                style: {
                  borderRadius: 16,
                },
                propsForDots: {
                  r: '6',
                  strokeWidth: '2',
                  stroke: getScoringColor(result.scoringLevel),
                },
              }}
              bezier
              style={styles.chart}
            />
          </Card.Content>
        </Card>

        {result.reasoning && result.reasoning.length > 0 && (
          <Card style={styles.card}>
            <Card.Content>
              <Text variant="titleMedium" style={styles.sectionTitle}>
                Observații:
              </Text>
              {result.reasoning.map((reason, index) => (
                <View key={index} style={styles.reasonItem}>
                  <Text>• {reason}</Text>
                </View>
              ))}
            </Card.Content>
          </Card>
        )}

        <Button
          mode="contained"
          onPress={() => {
            navigation.navigate('Dashboard', {
              screen: 'ApplicationWizard',
            });
          }}
          style={styles.button}>
          Aplica acum – trimite dosarul spre analiză completă
        </Button>

        <Button
          mode="outlined"
          onPress={() => navigation.goBack()}
          style={styles.button}>
          Înapoi la simulator
        </Button>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  content: {
    padding: 16,
  },
  resultCard: {
    marginBottom: 16,
  },
  resultHeader: {
    alignItems: 'center',
    marginBottom: 24,
  },
  emoji: {
    fontSize: 64,
    marginBottom: 8,
  },
  resultTitle: {
    fontWeight: 'bold',
    textAlign: 'center',
  },
  metrics: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginBottom: 24,
  },
  metric: {
    alignItems: 'center',
  },
  metricValue: {
    marginTop: 8,
    fontWeight: 'bold',
  },
  chip: {
    marginTop: 8,
  },
  chart: {
    marginVertical: 8,
    borderRadius: 16,
  },
  card: {
    marginBottom: 16,
  },
  sectionTitle: {
    marginBottom: 12,
    fontWeight: 'bold',
  },
  reasonItem: {
    marginBottom: 8,
  },
  button: {
    marginTop: 12,
    paddingVertical: 5,
  },
});

export default SimulatorResultScreen;

