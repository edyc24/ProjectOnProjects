import React, {useState, useEffect, useCallback, useRef} from 'react';
import {
  View,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Dimensions,
  TextInput,
  Image,
  Platform,
  Animated,
} from 'react-native';
import {Text, Button, Card, ProgressBar} from 'react-native-paper';
import {NativeStackNavigationProp} from '@react-navigation/native-stack';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import {useAuthStore} from '../../store/authStore';
import {eligibilityApi, CalcSimpleRequest} from '../../services/api/eligibilityApi';
import {GuestStackParamList} from '../../navigation/GuestNavigator';

// Import logo-uri - path relativ din src/screens/Landing/ către assets/
// Din Landing/ -> screens/ -> src/ -> root/ -> assets/
const logoImage = require('../../../assets/images/logo/Logo.PNG');
const bcrLogo = require('../../../assets/images/parteners/bcr.png');
const brdLogo = require('../../../assets/images/parteners/brd.png');
const btLogo = require('../../../assets/images/parteners/bt.png');
const garantiLogo = require('../../../assets/images/parteners/garanti.png');
const unicreditLogo = require('../../../assets/images/parteners/unicredit.png');
const alexPhoto = require('../../../assets/images/Alex/Alex.jpeg');

type LandingScreenNavigationProp = NativeStackNavigationProp<
  GuestStackParamList,
  'Landing'
>;

interface Props {
  navigation: LandingScreenNavigationProp;
}

const {width} = Dimensions.get('window');

const LandingScreen: React.FC<Props> = ({navigation}) => {
  const {isAuthenticated} = useAuthStore();
  const [currentLoanType, setCurrentLoanType] = useState<'NP' | 'IPOTECAR'>('NP');
  const [salaryNet, setSalaryNet] = useState('9000');
  const [mealTickets, setMealTickets] = useState('0');
  const [termMonths, setTermMonths] = useState(60);
  const [isCalculating, setIsCalculating] = useState(false);
  const [results, setResults] = useState<{
    amount?: number;
    rate?: number;
    dti?: number;
  } | null>(null);

  // Animații pentru feature cards
  const featureAnimations = useRef(
    [0, 1, 2, 3].map(() => new Animated.Value(1))
  ).current;

  const calculateEligibility = useCallback(async () => {
    const salary = parseFloat(salaryNet) || 0;
    const meals = parseFloat(mealTickets) || 0;

    if (salary <= 0) {
      return;
    }

    setIsCalculating(true);
    try {
      const request: CalcSimpleRequest = {
        loanType: currentLoanType,
        salaryNetUser: salary,
        mealTicketsUser: meals,
        termMonths: termMonths,
      };

      const response = await eligibilityApi.calculateSimple(request);
      
      setResults({
        amount: response.offers?.maxLoanAmountUsed,
        rate: response.offers?.affordability?.paymentMax,
        dti: response.dti?.dtiUsed,
      });
    } catch (error) {
      console.error('Error calculating eligibility:', error);
    } finally {
      setIsCalculating(false);
    }
  }, [currentLoanType, salaryNet, mealTickets, termMonths]);

  useEffect(() => {
    calculateEligibility();
  }, [calculateEligibility]);

  const formatCurrency = (value?: number) => {
    if (!value) return '0';
    return Math.round(value).toLocaleString('ro-RO');
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      {/* Header with Logo */}
      <View style={styles.headerContainer}>
        <View style={styles.logoWrapper}>
          <Image 
            source={logoImage} 
            style={styles.headerLogo}
            resizeMode="contain"
          />
        </View>
        {!isAuthenticated && (
          <TouchableOpacity
            onPress={() => navigation.navigate('Login')}
            style={styles.loginButton}>
            <Text style={styles.loginButtonText}>Conecteaza-te</Text>
          </TouchableOpacity>
        )}
      </View>

      {/* Hero Section */}
      <View style={styles.heroSection}>
        <View style={styles.heroContent}>
          <Text variant="headlineLarge" style={styles.heroTitle}>
            Simuleaza. Intelege. Decide Informat.
          </Text>
          <Text variant="bodyLarge" style={styles.heroDescription}>
            Credite rapide, simplu si transparent cu un broker autorizat.
          </Text>
          <View style={styles.badge}>
            <Icon name="check-circle" size={16} color="#0d6efd" style={styles.badgeIcon} />
            <Text style={styles.badgeText}>FARA COMISION (complet gratuit)</Text>
          </View>
          
          <View style={styles.heroButtons}>
            <Button
              mode="contained"
              onPress={() => {
                // Scroll to calculator section
                // In React Native, we'll navigate or use refs
                // For now, just trigger calculation
                calculateEligibility();
              }}
              style={styles.primaryButton}>
              Calculeaza Creditul
            </Button>
            <Button
              mode="outlined"
              onPress={() => navigation.navigate('Login')}
              style={styles.outlineButton}>
              Vorbeste cu un Broker
            </Button>
          </View>
        </View>

        {/* Calculator Preview */}
        <View style={styles.previewCardContainer}>
          <View style={styles.previewCard}>
          <Text style={styles.previewLabel}>Eligibilitatea ta</Text>
          <Text style={styles.previewAmount}>
            {formatCurrency(results?.amount)} Lei
          </Text>
          <View style={styles.previewRow}>
            <Icon name="check-circle" size={20} color="#4CAF50" />
            <Text style={styles.previewText}>
              Scor de Credit <Text style={styles.previewBold}>721</Text> Bun
            </Text>
          </View>
          <Text style={styles.previewText}>
            Rata Estimata <Text style={styles.previewBold}>
              {formatCurrency(results?.rate)}
            </Text> Lei/luna
          </Text>
          <View style={styles.dtiContainer}>
            <Text style={styles.dtiLabel}>Grad indatorare</Text>
            <ProgressBar
              progress={results?.dti || 0}
              color="#0d6efd"
              style={styles.progressBar}
            />
          </View>
        </View>
        </View>
      </View>

      {/* Calculator Section */}
      <View style={styles.calculatorSection}>
        <Card style={styles.calculatorCard}>
          <Card.Content>
            {/* Tabs */}
            <View style={styles.tabs}>
              <TouchableOpacity
                style={[
                  styles.tab,
                  currentLoanType === 'NP' && styles.tabActive,
                ]}
                onPress={() => setCurrentLoanType('NP')}>
                <Text
                  style={[
                    styles.tabText,
                    currentLoanType === 'NP' && styles.tabTextActive,
                  ]}>
                  Credit Nevoi Personale
                </Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[
                  styles.tab,
                  currentLoanType === 'IPOTECAR' && styles.tabActive,
                ]}
                onPress={() => setCurrentLoanType('IPOTECAR')}>
                <Text
                  style={[
                    styles.tabText,
                    currentLoanType === 'IPOTECAR' && styles.tabTextActive,
                  ]}>
                  Credit Ipotecar
                </Text>
              </TouchableOpacity>
            </View>

            {/* Inputs */}
            <View style={styles.inputsRow}>
              <View style={styles.inputGroup}>
                <Text style={styles.inputLabel}>Venit Net Lunar</Text>
                <View style={styles.inputContainer}>
                  <TextInput
                    style={styles.input}
                    value={salaryNet}
                    onChangeText={setSalaryNet}
                    keyboardType="numeric"
                    placeholder="0"
                    placeholderTextColor="#AAAAAA"
                  />
                  <Text style={styles.inputSuffix}>Lei</Text>
                </View>
              </View>

              <View style={styles.inputGroup}>
                <Text style={styles.inputLabel}>Bonuri de Masa</Text>
                <View style={styles.inputContainer}>
                  <TextInput
                    style={styles.input}
                    value={mealTickets}
                    onChangeText={setMealTickets}
                    keyboardType="numeric"
                    placeholder="0"
                    placeholderTextColor="#AAAAAA"
                  />
                  <Text style={styles.inputSuffix}>Lei</Text>
                </View>
              </View>
            </View>

            <View style={styles.inputsRow}>
              <View style={styles.inputGroup}>
                <Text style={styles.inputLabel}>Perioada</Text>
                <View style={styles.selectContainer}>
                  <TouchableOpacity
                    onPress={() => {
                      const options = [12, 24, 36, 48, 60];
                      const currentIndex = options.indexOf(termMonths);
                      const nextIndex = (currentIndex + 1) % options.length;
                      setTermMonths(options[nextIndex]);
                    }}>
                    <Text style={styles.selectText}>
                      {termMonths === 12
                        ? '1 an'
                        : termMonths === 24
                        ? '2 ani'
                        : termMonths === 36
                        ? '3 ani'
                        : termMonths === 48
                        ? '4 ani'
                        : '5 ani'}
                    </Text>
                  </TouchableOpacity>
                </View>
              </View>
            </View>

            <Button
              mode="contained"
              onPress={calculateEligibility}
              loading={isCalculating}
              style={styles.calculateButton}>
              Vezi Analiza Completa
            </Button>

            {/* Results */}
            <View style={styles.resultsCard}>
              <Text style={styles.resultsTitle}>Rezultate Estimate</Text>
              <View style={styles.resultItem}>
                <Text style={styles.resultLabel}>Suma Estimata</Text>
                <Text style={styles.resultValue}>
                  {formatCurrency(results?.amount)} Lei
                </Text>
              </View>
              <View style={styles.resultItem}>
                <Text style={styles.resultLabel}>Rata Lunara</Text>
                <Text style={styles.resultValue}>
                  {formatCurrency(results?.rate)} Lei
                </Text>
              </View>
              <View style={styles.resultItem}>
                <Text style={styles.resultLabel}>Grad Indatorare</Text>
                <View style={styles.dtiResult}>
                  <Text style={styles.resultValue}>
                    {Math.round((results?.dti || 0) * 100)}%
                  </Text>
                  <View style={styles.badgeEstimativ}>
                    <Text style={styles.badgeEstimativText}>Estimativ</Text>
                  </View>
                </View>
                <ProgressBar
                  progress={results?.dti || 0}
                  color="#0d6efd"
                  style={styles.progressBar}
                />
              </View>
            </View>
          </Card.Content>
        </Card>
      </View>

      {/* Partners Section */}
      <View style={styles.partnersSection}>
        <Text variant="headlineSmall" style={styles.sectionTitle}>
          Lucram cu cele mai mari institutii financiare
        </Text>
        <View style={styles.partnersContainer}>
          <View style={styles.partnersRow}>
            {[
              {name: 'BCR', logo: bcrLogo},
              {name: 'BT', logo: btLogo},
              {name: 'BRD', logo: brdLogo},
            ].map((bank, index) => (
              <View key={index} style={styles.partnerLogo}>
                <Image
                  source={bank.logo}
                  style={styles.partnerImage}
                  resizeMode="contain"
                />
              </View>
            ))}
          </View>
          <View style={styles.partnersRow}>
            {[
              {name: 'UniCredit', logo: unicreditLogo},
              {name: 'Garanti BBVA', logo: garantiLogo},
            ].map((bank, index) => (
              <View key={index} style={styles.partnerLogo}>
                <Image
                  source={bank.logo}
                  style={styles.partnerImage}
                  resizeMode="contain"
                />
              </View>
            ))}
          </View>
        </View>
      </View>

      {/* Features Section */}
      <View style={styles.featuresSection}>
        <Text variant="headlineSmall" style={styles.sectionTitle}>
          De ce sa alegi MoneyShop
        </Text>
        <View style={styles.featuresRow}>
          {[
            {
              icon: 'search',
              title: 'Transparenta Totala',
              description:
                'Vezi exact ce date sunt folosite, pentru ce scop si cand.',
            },
            {
              icon: 'clock-outline',
              title: 'Raspuns Rapid',
              description:
                'Analiza completa in cateva minute. Fara birocratie.',
            },
            {
              icon: 'school',
              title: 'Educatie Financiara',
              description:
                'Invatam despre credite, DTI, si alegeri financiare inteligente.',
            },
            {
              icon: 'shield-check',
              title: 'Date Protejate',
              description:
                'Datele tale sunt protejate conform GDPR. Mandat temporar.',
            },
          ].map((feature, index) => {
            const scaleAnim = featureAnimations[index];
            
            const handleHoverIn = () => {
              Animated.spring(scaleAnim, {
                toValue: 1.05,
                useNativeDriver: true,
                tension: 300,
                friction: 10,
              }).start();
            };
            
            const handleHoverOut = () => {
              Animated.spring(scaleAnim, {
                toValue: 1,
                useNativeDriver: true,
                tension: 300,
                friction: 10,
              }).start();
            };

            const handlePressIn = () => {
              Animated.spring(scaleAnim, {
                toValue: 0.95,
                useNativeDriver: true,
                tension: 300,
                friction: 10,
              }).start();
            };
            
            const handlePressOut = () => {
              Animated.spring(scaleAnim, {
                toValue: 1,
                useNativeDriver: true,
                tension: 300,
                friction: 10,
              }).start();
            };

            return (
              <TouchableOpacity
                key={index}
                activeOpacity={1}
                onPressIn={handlePressIn}
                onPressOut={handlePressOut}
                // @ts-ignore - onMouseEnter/onMouseLeave pentru web
                onMouseEnter={handleHoverIn}
                onMouseLeave={handleHoverOut}
                style={styles.featureCardWrapper}>
                <Animated.View
                  style={[
                    styles.featureCardAnimated,
                    {transform: [{scale: scaleAnim}]},
                  ]}>
                  <Card style={styles.featureCard}>
                    <Card.Content style={styles.featureContent}>
                      <Icon
                        name={feature.icon}
                        size={48}
                        color="#0d6efd"
                        style={styles.featureIcon}
                      />
                      <Text variant="titleMedium" style={styles.featureTitle}>
                        {feature.title}
                      </Text>
                      <Text variant="bodyMedium" style={styles.featureDescription}>
                        {feature.description}
                      </Text>
                    </Card.Content>
                  </Card>
                </Animated.View>
              </TouchableOpacity>
            );
          })}
        </View>
      </View>

      {/* Help Section */}
      <View style={styles.helpSection}>
        <View style={styles.helpContent}>
          <View style={styles.helpTextContainer}>
            <Text variant="headlineSmall" style={styles.sectionTitle}>
              Ai nevoie de ajutor?
            </Text>
            <Text variant="bodyLarge" style={styles.helpDescription}>
              Discuta cu un broker autorizat pentru cea mai buna solutie.
            </Text>
            <View style={styles.helpButtons}>
              <Button
                mode="contained"
                onPress={() => navigation.navigate('Login')}
                style={styles.primaryButton}>
                Programeaza un Apel
              </Button>
              <Button
                mode="outlined"
                onPress={() => navigation.navigate('Login')}
                style={styles.outlineButton}>
                Chat cu un Broker
              </Button>
            </View>
          </View>
          
          {/* Broker Photo */}
          <View style={styles.brokerPhotoContainer}>
            <View style={styles.brokerPhotoWrapper}>
              <Image
                source={alexPhoto}
                style={styles.brokerPhoto}
                resizeMode="cover"
              />
              <View style={styles.brokerPhotoOverlay} />
            </View>
            <Text variant="bodyMedium" style={styles.brokerName}>
              Alex Moore
            </Text>
            <Text variant="bodySmall" style={styles.brokerTitle}>
              Broker Autorizat
            </Text>
          </View>
        </View>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#1a1a2e',
  },
  contentContainer: {
    paddingBottom: 40,
  },
  headerContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingTop: Platform.OS === 'ios' ? 50 : 30,
    paddingBottom: 16,
    paddingRight: 20,
    paddingLeft: 0,
    backgroundColor: '#1a1a2e',
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(255, 255, 255, 0.1)',
  },
  logoWrapper: {
    marginLeft: 0,
    paddingLeft: 0,
    marginTop: 0,
    marginBottom: 0,
    alignItems: 'flex-start',
    justifyContent: 'flex-start',
    overflow: 'visible',
  },
  headerLogo: {
    width: 560,
    height: 200,
    marginLeft: 0,
    marginTop: 0,
  },
  loginButton: {
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 20,
    borderWidth: 1.5,
    borderColor: '#0d6efd',
    backgroundColor: 'rgba(13, 110, 253, 0.1)',
  },
  loginButtonText: {
    color: '#0d6efd',
    fontWeight: '600',
    fontSize: 14,
  },
  heroSection: {
    backgroundColor: '#1a1a2e',
    paddingHorizontal: 24,
    paddingVertical: 40,
    minHeight: 500,
    alignItems: 'center',
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: {width: 0, height: 4},
        shadowOpacity: 0.3,
        shadowRadius: 8,
      },
      android: {
        elevation: 8,
      },
    }),
  },
  heroContent: {
    marginBottom: 30,
    width: '100%',
    maxWidth: 1200,
    alignItems: 'center',
  },
  heroTitle: {
    fontSize: 42,
    fontWeight: '900',
    color: '#FFFFFF',
    marginBottom: 16,
    lineHeight: 52,
    letterSpacing: 0.8,
    textAlign: 'center',
  },
  heroDescription: {
    fontSize: 18,
    color: '#E0E0E0',
    marginBottom: 24,
    lineHeight: 26,
    textAlign: 'center',
  },
  badge: {
    backgroundColor: 'rgba(13, 110, 253, 0.15)',
    borderWidth: 2,
    borderColor: '#0d6efd',
    borderRadius: 30,
    paddingHorizontal: 20,
    paddingVertical: 12,
    alignSelf: 'center',
    marginBottom: 24,
    flexDirection: 'row',
    alignItems: 'center',
    ...Platform.select({
      ios: {
        shadowColor: '#0d6efd',
        shadowOffset: {width: 0, height: 2},
        shadowOpacity: 0.3,
        shadowRadius: 4,
      },
      android: {
        elevation: 4,
      },
    }),
  },
  badgeIcon: {
    marginRight: 8,
  },
  badgeText: {
    color: '#0d6efd',
    fontWeight: '700',
    fontSize: 13,
    letterSpacing: 0.5,
  },
  heroButtons: {
    flexDirection: 'row',
    gap: 12,
    flexWrap: 'wrap',
    marginTop: 8,
    justifyContent: 'center',
    width: '100%',
  },
  primaryButton: {
    backgroundColor: '#0d6efd',
    paddingHorizontal: 24,
    paddingVertical: 8,
    borderRadius: 12,
    ...Platform.select({
      ios: {
        shadowColor: '#0d6efd',
        shadowOffset: {width: 0, height: 4},
        shadowOpacity: 0.4,
        shadowRadius: 8,
      },
      android: {
        elevation: 6,
      },
    }),
  },
  outlineButton: {
    borderColor: '#0d6efd',
    borderWidth: 2,
    paddingHorizontal: 24,
    paddingVertical: 8,
    borderRadius: 12,
  },
  previewCardContainer: {
    width: '100%',
    maxWidth: 1200,
    alignItems: 'center',
    marginTop: 24,
  },
  previewCard: {
    backgroundColor: 'rgba(255, 255, 255, 0.12)',
    borderRadius: 20,
    padding: 28,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.1)',
    width: '100%',
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: {width: 0, height: 8},
        shadowOpacity: 0.3,
        shadowRadius: 12,
      },
      android: {
        elevation: 12,
      },
    }),
  },
  previewLabel: {
    fontSize: 14,
    color: '#AAAAAA',
    marginBottom: 10,
  },
  previewAmount: {
    fontSize: 32,
    fontWeight: '700',
    color: '#0d6efd',
    marginBottom: 15,
  },
  previewRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    marginBottom: 10,
  },
  previewText: {
    fontSize: 14,
    color: '#CCCCCC',
  },
  previewBold: {
    fontWeight: '700',
    color: '#FFFFFF',
  },
  dtiContainer: {
    marginTop: 15,
  },
  dtiLabel: {
    fontSize: 12,
    color: '#AAAAAA',
    marginBottom: 5,
  },
  progressBar: {
    height: 8,
    borderRadius: 4,
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
  },
  calculatorSection: {
    padding: 24,
    paddingHorizontal: 40,
    backgroundColor: 'rgba(255, 255, 255, 0.03)',
    alignItems: 'center',
  },
  calculatorCard: {
    backgroundColor: 'rgba(255, 255, 255, 0.12)',
    borderRadius: 24,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.1)',
    maxWidth: 900,
    width: '100%',
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: {width: 0, height: 8},
        shadowOpacity: 0.25,
        shadowRadius: 16,
      },
      android: {
        elevation: 10,
      },
    }),
  },
  tabs: {
    flexDirection: 'row',
    borderBottomWidth: 2,
    borderBottomColor: 'rgba(255, 255, 255, 0.15)',
    marginBottom: 24,
    gap: 8,
  },
  tab: {
    paddingVertical: 16,
    paddingHorizontal: 20,
    borderBottomWidth: 3,
    borderBottomColor: 'transparent',
    borderRadius: 8,
  },
  tabActive: {
    borderBottomColor: '#0d6efd',
    backgroundColor: 'rgba(13, 110, 253, 0.1)',
  },
  tabText: {
    color: '#B0B0B0',
    fontSize: 15,
    fontWeight: '500',
  },
  tabTextActive: {
    color: '#0d6efd',
    fontWeight: '700',
  },
  inputsRow: {
    flexDirection: 'row',
    gap: 15,
    marginBottom: 15,
  },
  inputGroup: {
    flex: 1,
  },
  inputLabel: {
    color: '#FFFFFF',
    fontWeight: '500',
    marginBottom: 8,
    fontSize: 14,
  },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(255, 255, 255, 0.12)',
    borderWidth: 1.5,
    borderColor: 'rgba(255, 255, 255, 0.25)',
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 14,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: {width: 0, height: 2},
        shadowOpacity: 0.1,
        shadowRadius: 4,
      },
      android: {
        elevation: 2,
      },
    }),
  },
  input: {
    flex: 1,
    color: '#FFFFFF',
    fontSize: 17,
    padding: 0,
    margin: 0,
    fontWeight: '500',
  },
  inputSuffix: {
    color: '#B0B0B0',
    marginLeft: 12,
    fontSize: 15,
    fontWeight: '600',
  },
  selectContainer: {
    backgroundColor: 'rgba(255, 255, 255, 0.12)',
    borderWidth: 1.5,
    borderColor: 'rgba(255, 255, 255, 0.25)',
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 14,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: {width: 0, height: 2},
        shadowOpacity: 0.1,
        shadowRadius: 4,
      },
      android: {
        elevation: 2,
      },
    }),
  },
  selectText: {
    color: '#FFFFFF',
    fontSize: 16,
  },
  calculateButton: {
    marginTop: 24,
    backgroundColor: '#0d6efd',
    paddingVertical: 6,
    borderRadius: 12,
    ...Platform.select({
      ios: {
        shadowColor: '#0d6efd',
        shadowOffset: {width: 0, height: 4},
        shadowOpacity: 0.4,
        shadowRadius: 8,
      },
      android: {
        elevation: 6,
      },
    }),
  },
  resultsCard: {
    marginTop: 32,
    backgroundColor: 'rgba(13, 110, 253, 0.15)',
    borderWidth: 2,
    borderColor: '#0d6efd',
    borderRadius: 20,
    padding: 24,
    ...Platform.select({
      ios: {
        shadowColor: '#0d6efd',
        shadowOffset: {width: 0, height: 6},
        shadowOpacity: 0.3,
        shadowRadius: 12,
      },
      android: {
        elevation: 8,
      },
    }),
  },
  resultsTitle: {
    color: '#0d6efd',
    fontWeight: '600',
    marginBottom: 20,
    fontSize: 18,
  },
  resultItem: {
    marginBottom: 20,
  },
  resultLabel: {
    fontSize: 14,
    color: '#AAAAAA',
    marginBottom: 5,
  },
  resultValue: {
    fontSize: 24,
    fontWeight: '700',
    color: '#FFFFFF',
  },
  dtiResult: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 10,
  },
  badgeEstimativ: {
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 4,
    marginLeft: 10,
  },
  badgeEstimativText: {
    color: '#FFFFFF',
    fontSize: 12,
  },
  partnersSection: {
    padding: 40,
    paddingVertical: 50,
    backgroundColor: 'rgba(255, 255, 255, 0.02)',
    alignItems: 'center',
  },
  sectionTitle: {
    fontSize: 26,
    fontWeight: '800',
    color: '#FFFFFF',
    marginBottom: 40,
    textAlign: 'center',
    letterSpacing: 0.5,
  },
  partnersContainer: {
    gap: 16,
    alignItems: 'center',
    width: '100%',
    maxWidth: 1200,
  },
  partnersRow: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    gap: 16,
    flexWrap: 'wrap',
  },
  partnerLogo: {
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    borderRadius: 16,
    paddingHorizontal: 20,
    paddingVertical: 16,
    borderWidth: 1.5,
    borderColor: 'rgba(255, 255, 255, 0.15)',
    width: 110,
    height: 60,
    alignItems: 'center',
    justifyContent: 'center',
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: {width: 0, height: 2},
        shadowOpacity: 0.15,
        shadowRadius: 4,
      },
      android: {
        elevation: 3,
      },
    }),
  },
  partnerImage: {
    width: '100%',
    height: '100%',
    maxWidth: 100,
    maxHeight: 50,
  },
  partnerText: {
    fontSize: 16,
    fontWeight: '700',
    color: '#D0D0D0',
    letterSpacing: 0.5,
  },
  featuresSection: {
    padding: 40,
    paddingHorizontal: 30,
    alignItems: 'center',
  },
  featuresRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'stretch',
    gap: 16,
    flexWrap: 'nowrap',
    width: '100%',
    maxWidth: 1200,
  },
  featureCardWrapper: {
    flex: 1,
    minWidth: 0,
    width: '25%',
  },
  featureCardAnimated: {
    width: '100%',
    height: '100%',
  },
  featureCard: {
    backgroundColor: 'rgba(255, 255, 255, 0.08)',
    borderRadius: 20,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.1)',
    height: 240,
    width: '100%',
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: {width: 0, height: 4},
        shadowOpacity: 0.2,
        shadowRadius: 8,
      },
      android: {
        elevation: 5,
      },
    }),
  },
  featureContent: {
    alignItems: 'center',
    padding: 20,
    height: '100%',
    justifyContent: 'flex-start',
  },
  featureIcon: {
    marginBottom: 16,
  },
  featureTitle: {
    color: '#FFFFFF',
    marginBottom: 12,
    textAlign: 'center',
    fontWeight: '700',
    fontSize: 16,
  },
  featureDescription: {
    color: '#D0D0D0',
    textAlign: 'center',
    fontSize: 13,
    lineHeight: 20,
  },
  helpSection: {
    padding: 40,
    paddingVertical: 60,
    backgroundColor: 'rgba(255, 255, 255, 0.02)',
    alignItems: 'center',
    width: '100%',
    maxWidth: 1200,
    alignSelf: 'center',
  },
  helpContent: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    width: '100%',
    gap: 40,
    flexWrap: 'wrap',
  },
  helpTextContainer: {
    flex: 1,
    minWidth: 300,
    alignItems: 'center',
  },
  helpDescription: {
    fontSize: 18,
    color: '#CCCCCC',
    marginBottom: 30,
    textAlign: 'center',
  },
  helpButtons: {
    flexDirection: 'row',
    gap: 15,
    flexWrap: 'wrap',
    justifyContent: 'center',
  },
  brokerPhotoContainer: {
    alignItems: 'center',
    minWidth: 200,
  },
  brokerPhotoWrapper: {
    width: 180,
    height: 180,
    borderRadius: 90,
    overflow: 'hidden',
    borderWidth: 4,
    borderColor: '#0d6efd',
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    ...Platform.select({
      ios: {
        shadowColor: '#0d6efd',
        shadowOffset: {width: 0, height: 8},
        shadowOpacity: 0.4,
        shadowRadius: 16,
      },
      android: {
        elevation: 12,
      },
    }),
  },
  brokerPhoto: {
    width: '100%',
    height: '100%',
  },
  brokerPhotoOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(13, 110, 253, 0.1)',
  },
  brokerName: {
    color: '#ffffff',
    fontWeight: 'bold',
    marginTop: 16,
    fontSize: 18,
  },
  brokerTitle: {
    color: '#0d6efd',
    marginTop: 4,
    fontSize: 14,
  },
});

export default LandingScreen;

