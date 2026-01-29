import React, {useState, useEffect, useCallback} from 'react';
import {
  View,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Dimensions,
  TextInput,
  Image,
  Platform,
  Text,
} from 'react-native';
import {NativeStackNavigationProp} from '@react-navigation/native-stack';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import {useAuthStore} from '../../store/authStore';
import {eligibilityApi, CalcSimpleRequest} from '../../services/api/eligibilityApi';
import {GuestStackParamList} from '../../navigation/GuestNavigator';
import LinearGradient from 'react-native-linear-gradient';

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
  const [currentLoanType, setCurrentLoanType] = useState<'NP' | 'IPOTECAR' | 'REFINANTARE'>('NP');
  const [salaryNet, setSalaryNet] = useState('9000');
  const [mealTickets, setMealTickets] = useState('0');
  const [termMonths, setTermMonths] = useState(60);
  const [isCalculating, setIsCalculating] = useState(false);
  const [results, setResults] = useState<{
    amount?: number;
    rate?: number;
    dti?: number;
    score?: number;
  } | null>(null);

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
      
      let score = 721;
      if (response.decision?.rating) {
        const scoreMap: {[key: string]: number} = {'A': 780, 'B': 721, 'C': 650, 'D': 550};
        score = scoreMap[response.decision.rating] || 721;
      }
      
      setResults({
        amount: response.offers?.maxLoanAmountUsed || 85000,
        rate: response.offers?.affordability?.paymentMax || 1250,
        dti: response.dti?.dtiUsed || 0.32,
        score: score,
      });
    } catch (error) {
      console.error('Error calculating eligibility:', error);
      // Set default values
      setResults({
        amount: 85000,
        rate: 1250,
        dti: 0.32,
        score: 721,
      });
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
    <ScrollView 
      style={styles.container} 
      contentContainerStyle={styles.contentContainer}
      showsVerticalScrollIndicator={false}>
      
      {/* Navigation Header */}
      <View style={styles.nav}>
        <View style={styles.navContent}>
          <Text style={styles.logo}>
            MoneyShop<Text style={styles.logoReg}>®</Text>
          </Text>
          <View style={styles.navLinks}>
            <TouchableOpacity style={styles.navLink}>
              <Text style={styles.navLinkText}>Calculator Credite</Text>
              <Icon name="chevron-down" size={14} color="#94a3b8" />
            </TouchableOpacity>
            <TouchableOpacity style={styles.navLink}>
              <Text style={styles.navLinkText}>Cum Functioneaza</Text>
              <Icon name="chevron-down" size={14} color="#94a3b8" />
            </TouchableOpacity>
            <TouchableOpacity style={styles.navLink}>
              <Text style={styles.navLinkText}>Educatie Financiara</Text>
              <Icon name="chevron-down" size={14} color="#94a3b8" />
            </TouchableOpacity>
            <TouchableOpacity style={styles.navLink}>
              <Text style={styles.navLinkText}>Contact</Text>
            </TouchableOpacity>
          </View>
          <View style={styles.navActions}>
            {!isAuthenticated && (
              <TouchableOpacity
                onPress={() => navigation.navigate('Login')}
                style={styles.loginButton}>
                <Text style={styles.loginButtonText}>Conecteaza-te</Text>
              </TouchableOpacity>
            )}
            <TouchableOpacity style={styles.profileButton}>
              <Icon name="account-outline" size={18} color="#94a3b8" />
            </TouchableOpacity>
          </View>
        </View>
      </View>

      {/* Hero Section */}
      <View style={styles.heroSection}>
        {/* Background gradients */}
        <View style={styles.heroBackground}>
          <View style={styles.gradientOrb1} />
          <View style={styles.gradientOrb2} />
        </View>
        
        <View style={styles.heroContent}>
          {/* Left side - Text */}
          <View style={styles.heroTextContainer}>
            <Text style={styles.heroTitle}>
              Simuleaza.{'\n'}
              Intelege.{'\n'}
              <Text style={styles.heroTitleAccent}>Decide Informat.</Text>
            </Text>
            
            <Text style={styles.heroDescription}>
              Credite rapide, simplu si transparent cu un broker autorizat.
            </Text>
            
            <Text style={styles.heroBadge}>
              FARA COMISION <Text style={styles.heroBadgeLight}>(complet gratuit)</Text>
            </Text>
            
            <View style={styles.heroButtons}>
              <TouchableOpacity style={styles.heroButtonPrimary}>
                <Text style={styles.heroButtonPrimaryText}>Calculeaza Creditul</Text>
              </TouchableOpacity>
              <TouchableOpacity 
                style={styles.heroButtonSecondary}
                onPress={() => navigation.navigate('Login')}>
                <Text style={styles.heroButtonSecondaryText}>Vorbeste cu un Broker</Text>
              </TouchableOpacity>
            </View>
          </View>

          {/* Right side - Device Mockups */}
          <View style={styles.devicesContainer}>
            {/* Desktop Monitor */}
            <View style={styles.monitorWrapper}>
              <View style={styles.monitorFrame}>
                {/* Screen Header */}
                <View style={styles.screenHeader}>
                  <Text style={styles.screenHeaderText}>MoneyShop •</Text>
                  <View style={styles.windowDots}>
                    <View style={[styles.dot, styles.dotRed]} />
                    <View style={[styles.dot, styles.dotYellow]} />
                    <View style={[styles.dot, styles.dotGreen]} />
                  </View>
                </View>
                
                {/* Screen Content */}
                <View style={styles.screenContent}>
                  {/* Sidebar */}
                  <View style={styles.sidebar}>
                    <View style={styles.sidebarItem1} />
                    <View style={styles.sidebarItem2} />
                    <View style={styles.sidebarItem3} />
                    <View style={styles.sidebarItem4} />
                  </View>
                  
                  {/* Main Content */}
                  <View style={styles.mainContent}>
                    <Text style={styles.eligibilityLabel}>Eligibilitatea ta</Text>
                    <View style={styles.amountRow}>
                      <Text style={styles.amountValue}>
                        {formatCurrency(results?.amount || 85000)}
                      </Text>
                      <Text style={styles.amountCurrency}>Lei</Text>
                    </View>
                    
                    <View style={styles.statsRow}>
                      <View style={styles.statItem}>
                        <Text style={styles.statLabel}>Rată Estimată</Text>
                        <Text style={styles.statValue}>
                          {formatCurrency(results?.rate || 1250)} <Text style={styles.statUnit}>Lei/lună</Text>
                        </Text>
                      </View>
                      <View style={styles.statItem}>
                        <Text style={styles.statLabel}>Grad Îndatorare</Text>
                        <Text style={styles.statValue}>
                          {Math.round((results?.dti || 0.32) * 100)}%
                        </Text>
                      </View>
                    </View>
                    
                    {/* Score Card */}
                    <View style={styles.scoreCard}>
                      <View style={styles.scoreInfo}>
                        <Text style={styles.scoreLabel}>Scor de Credit</Text>
                        <View style={styles.scoreValueRow}>
                          <Text style={styles.scoreValue}>{results?.score || 721}</Text>
                          <Text style={styles.scoreRating}>Bun</Text>
                        </View>
                      </View>
                      <View style={styles.scoreCheckmark}>
                        <Icon name="check" size={12} color="#fff" />
                      </View>
                    </View>
                    
                    {/* Progress bar */}
                    <View style={styles.scoreProgressBar}>
                      <View style={[styles.scoreProgressFill, {width: '72%'}]} />
                    </View>
                  </View>
                </View>
              </View>
              
              {/* Monitor Stand */}
              <View style={styles.monitorStand} />
              <View style={styles.monitorBase} />
              
              {/* Phone Mockup - Overlapping */}
              <View style={styles.phoneWrapper}>
                <View style={styles.phoneFrame}>
                  <View style={styles.phoneNotch} />
                  <View style={styles.phoneHeader}>
                    <Text style={styles.phoneHeaderText}>MoneyShop</Text>
                  </View>
                  <View style={styles.phoneContent}>
                    <View style={styles.phoneCard}>
                      <Text style={styles.phoneCardLabel}>ELIGIBILITATE</Text>
                      <Text style={styles.phoneCardAmount}>
                        {formatCurrency(results?.amount || 85000)}
                      </Text>
                      <Text style={styles.phoneCardCurrency}>Lei</Text>
                      <View style={styles.phoneCardStats}>
                        <View style={styles.phoneCardStat}>
                          <Text style={styles.phoneCardStatLabel}>Rata</Text>
                          <Text style={styles.phoneCardStatValue}>
                            {formatCurrency(results?.rate || 1250)} Lei
                          </Text>
                        </View>
                        <View style={styles.phoneCardStat}>
                          <Text style={styles.phoneCardStatLabel}>Scor</Text>
                          <Text style={styles.phoneCardStatValue}>
                            {results?.score || 721}
                          </Text>
                        </View>
                      </View>
                    </View>
                  </View>
                </View>
              </View>
            </View>
          </View>
        </View>
      </View>

      {/* Calculator Section */}
      <View style={styles.calculatorSection}>
        <View style={styles.calculatorCard}>
          {/* Tabs */}
          <View style={styles.calculatorTabs}>
            <TouchableOpacity
              style={[styles.calculatorTab, currentLoanType === 'NP' && styles.calculatorTabActive]}
              onPress={() => setCurrentLoanType('NP')}>
              <Text style={[styles.calculatorTabText, currentLoanType === 'NP' && styles.calculatorTabTextActive]}>
                Credit de Nevoi Personale
              </Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={[styles.calculatorTab, currentLoanType === 'IPOTECAR' && styles.calculatorTabActive]}
              onPress={() => setCurrentLoanType('IPOTECAR')}>
              <Text style={[styles.calculatorTabText, currentLoanType === 'IPOTECAR' && styles.calculatorTabTextActive]}>
                Credit Ipotecar
              </Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={[styles.calculatorTab, currentLoanType === 'REFINANTARE' && styles.calculatorTabActive]}
              onPress={() => setCurrentLoanType('REFINANTARE')}>
              <Text style={[styles.calculatorTabText, currentLoanType === 'REFINANTARE' && styles.calculatorTabTextActive]}>
                Refinantare
              </Text>
            </TouchableOpacity>
          </View>
          
          {/* Calculator Content */}
          <View style={styles.calculatorContent}>
            {/* Inputs */}
            <View style={styles.calculatorInputs}>
              <View style={styles.inputsGrid}>
                <View style={styles.inputGroup}>
                  <Text style={styles.inputLabel}>VENIT NET LUNAR</Text>
                  <View style={styles.inputWrapper}>
                    <TextInput
                      style={styles.input}
                      value={`${salaryNet} Lei`}
                      onChangeText={(text) => setSalaryNet(text.replace(/[^0-9]/g, ''))}
                      keyboardType="numeric"
                      placeholderTextColor="#64748b"
                    />
                    <Icon name="chevron-down" size={16} color="#94a3b8" />
                  </View>
                </View>
                <View style={styles.inputGroup}>
                  <Text style={styles.inputLabel}>BONURI DE MASA</Text>
                  <View style={styles.inputWrapper}>
                    <TextInput
                      style={styles.input}
                      value={`${mealTickets} Lei`}
                      onChangeText={(text) => setMealTickets(text.replace(/[^0-9]/g, ''))}
                      keyboardType="numeric"
                      placeholderTextColor="#64748b"
                    />
                    <Icon name="chevron-down" size={16} color="#94a3b8" />
                  </View>
                </View>
                <View style={styles.inputGroup}>
                  <Text style={styles.inputLabel}>PERIOADA</Text>
                  <TouchableOpacity
                    style={styles.inputWrapper}
                    onPress={() => {
                      const options = [12, 24, 36, 48, 60];
                      const currentIndex = options.indexOf(termMonths);
                      const nextIndex = (currentIndex + 1) % options.length;
                      setTermMonths(options[nextIndex]);
                    }}>
                    <Text style={styles.inputText}>
                      {termMonths === 12 ? '1 an' : `${termMonths / 12} ani`}
                    </Text>
                    <Icon name="chevron-down" size={16} color="#94a3b8" />
                  </TouchableOpacity>
                </View>
                <View style={styles.inputGroup}>
                  <Text style={styles.inputLabel}>TIP CREDIT</Text>
                  <View style={styles.inputWrapper}>
                    <Text style={styles.inputTextDisabled}>Selectat automat</Text>
                  </View>
                </View>
              </View>
              
              <TouchableOpacity
                onPress={calculateEligibility}
                style={styles.calculateButton}
                disabled={isCalculating}>
                <Text style={styles.calculateButtonText}>Vezi Analiza Completa</Text>
              </TouchableOpacity>
            </View>
            
            {/* Results */}
            <View style={styles.calculatorResults}>
              <View style={styles.resultItem}>
                <Text style={styles.resultLabel}>Suma Estimata</Text>
                <Text style={styles.resultValue}>
                  {formatCurrency(results?.amount || 75000)} <Text style={styles.resultUnit}>Lei</Text>
                </Text>
              </View>
              <View style={styles.resultItem}>
                <Text style={styles.resultLabel}>Rata Lunara</Text>
                <Text style={styles.resultValue}>
                  {formatCurrency(results?.rate || 1250)} <Text style={styles.resultUnit}>Lei</Text>
                </Text>
              </View>
              <View style={styles.resultItem}>
                <Text style={styles.resultLabel}>Grad Indatorare</Text>
                <View style={styles.resultDtiRow}>
                  <Text style={styles.resultValue}>
                    {Math.round((results?.dti || 0.32) * 100)}%
                  </Text>
                  <View style={styles.resultDtiIcon}>
                    <Icon name="close" size={12} color="#fff" />
                  </View>
                </View>
              </View>
              <TouchableOpacity style={styles.estimativBadge}>
                <Icon name="information-outline" size={12} color="#94a3b8" />
                <Text style={styles.estimativText}>Estimativ</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </View>

      {/* Partners Section */}
      <View style={styles.partnersSection}>
        <View style={styles.partnersDivider} />
        <Text style={styles.partnersTitle}>Lucram cu cele mai mari institutii financiare</Text>
        <View style={styles.partnersDivider} />
        
        <View style={styles.partnersRow}>
          <View style={styles.partnerItem}>
            <Text style={styles.partnerBCR}>BCR</Text>
            <View style={styles.partnerBCRDot} />
          </View>
          <View style={styles.partnerItem}>
            <View style={styles.partnerBTCircle}>
              <Text style={styles.partnerBTText}>BT</Text>
            </View>
          </View>
          <View style={styles.partnerItem}>
            <View style={styles.partnerBRD}>
              <View style={styles.brdShape1} />
              <View style={styles.brdShape2} />
            </View>
            <Text style={styles.partnerBRDText}>BRD</Text>
          </View>
          <View style={styles.partnerItem}>
            <Text style={styles.partnerING}>ING</Text>
            <Icon name="paw" size={16} color="#f97316" />
          </View>
          <View style={styles.partnerItem}>
            <View style={styles.partnerUniCredit}>
              <Icon name="arrow-up" size={10} color="#fff" style={styles.uniCreditArrow} />
            </View>
            <Text style={styles.partnerUniCreditText}>UniCredit</Text>
          </View>
          <View style={styles.partnerItem}>
            <Icon name="check-circle" size={16} color="#22c55e" />
            <Text style={styles.partnerGaranti}>Garanti BBVA</Text>
          </View>
        </View>
      </View>

      {/* Features Section */}
      <View style={styles.featuresSection}>
        <View style={styles.featuresTitleContainer}>
          <View style={styles.featuresTitleLine} />
          <Text style={styles.featuresTitle}>De ce sa alegi MoneyShop</Text>
        </View>
        
        <View style={styles.featuresGrid}>
          <View style={styles.featureCard}>
            <View style={styles.featureHeader}>
              <View style={styles.featureIconContainer}>
                <Icon name="eye-outline" size={20} color="#3b82f6" />
              </View>
              <Text style={styles.featureTitle}>Transparenta{'\n'}Totala</Text>
            </View>
            <View style={styles.featureDivider} />
            <Text style={styles.featureDescription}>
              Costuri clar afișate, fără comisioane ascunse. Înțelegi exact ce plătești.
            </Text>
          </View>
          
          <View style={styles.featureCard}>
            <View style={styles.featureHeader}>
              <View style={styles.featureIconContainer}>
                <Icon name="clock-outline" size={20} color="#3b82f6" />
              </View>
              <Text style={styles.featureTitle}>Raspuns{'\n'}Rapid</Text>
            </View>
            <View style={styles.featureDivider} />
            <Text style={styles.featureDescription}>
              Primești ofertele în timp real. Proces rapid de aplicare și aprobare.
            </Text>
          </View>
          
          <View style={styles.featureCard}>
            <View style={styles.featureHeader}>
              <View style={styles.featureIconContainer}>
                <Icon name="school-outline" size={20} color="#3b82f6" />
              </View>
              <Text style={styles.featureTitle}>Educatie{'\n'}Financiara</Text>
            </View>
            <View style={styles.featureDivider} />
            <Text style={styles.featureDescription}>
              Resurse gratuite pentru a lua decizii financiare inteligente pe termen lung.
            </Text>
          </View>
          
          <View style={styles.featureCard}>
            <View style={styles.featureHeader}>
              <View style={styles.featureIconContainer}>
                <Icon name="shield-check-outline" size={20} color="#3b82f6" />
              </View>
              <Text style={styles.featureTitle}>Date{'\n'}Protejate</Text>
            </View>
            <View style={styles.featureDivider} />
            <Text style={styles.featureDescription}>
              Sistem de securitate avansat. Datele tale sunt confidențiale și în siguranță.
            </Text>
          </View>
        </View>
      </View>

      {/* Help Section */}
      <View style={styles.helpSection}>
        <View style={styles.helpCard}>
          <View style={styles.helpContent}>
            <View style={styles.helpTextContainer}>
              <Text style={styles.helpTitle}>Ai nevoie de ajutor?</Text>
              <Text style={styles.helpDescription}>
                Discuta cu un broker autorizat pentru cea mai buna solutie.
              </Text>
              
              <View style={styles.helpButtons}>
                <TouchableOpacity
                  onPress={() => navigation.navigate('Login')}
                  style={styles.helpButtonPrimary}>
                  <Text style={styles.helpButtonPrimaryText}>Programeaza un Apel</Text>
                </TouchableOpacity>
                <TouchableOpacity
                  onPress={() => navigation.navigate('Login')}
                  style={styles.helpButtonSecondary}>
                  <Text style={styles.helpButtonSecondaryText}>Chat cu un Broker</Text>
                </TouchableOpacity>
              </View>
              
              <Text style={styles.helpFooter}>
                MoneyShop® - Broker de credite autorizat. FARA COMISION (complet gratuit)
              </Text>
            </View>
            
            <View style={styles.helpImageContainer}>
              <Image
                source={alexPhoto}
                style={styles.helpImage}
                resizeMode="cover"
              />
              <View style={styles.helpImageOverlay} />
            </View>
          </View>
        </View>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#0a0f1a',
  },
  contentContainer: {
    paddingBottom: 60,
  },
  
  // Navigation
  nav: {
    paddingTop: Platform.OS === 'ios' ? 50 : 30,
    paddingBottom: 16,
    paddingHorizontal: 20,
    backgroundColor: 'rgba(10, 15, 26, 0.95)',
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(255, 255, 255, 0.05)',
  },
  navContent: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  logo: {
    fontSize: 22,
    fontWeight: '700',
    color: '#fff',
    letterSpacing: -0.5,
  },
  logoReg: {
    fontSize: 10,
    color: '#6b7280',
    fontWeight: '400',
  },
  navLinks: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 28,
  },
  navLink: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  navLinkText: {
    fontSize: 13,
    fontWeight: '500',
    color: '#94a3b8',
  },
  navActions: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  loginButton: {
    backgroundColor: '#1d4ed8',
    paddingHorizontal: 18,
    paddingVertical: 8,
    borderRadius: 6,
  },
  loginButtonText: {
    color: '#fff',
    fontSize: 13,
    fontWeight: '600',
  },
  profileButton: {
    width: 36,
    height: 36,
    borderRadius: 6,
    backgroundColor: 'rgba(55, 65, 81, 0.5)',
    borderWidth: 1,
    borderColor: '#374151',
    justifyContent: 'center',
    alignItems: 'center',
  },
  
  // Hero Section
  heroSection: {
    minHeight: 600,
    paddingHorizontal: 20,
    paddingTop: 60,
    paddingBottom: 40,
    position: 'relative',
    overflow: 'hidden',
  },
  heroBackground: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  },
  gradientOrb1: {
    position: 'absolute',
    top: -100,
    right: -150,
    width: 500,
    height: 500,
    borderRadius: 250,
    backgroundColor: 'rgba(59, 130, 246, 0.08)',
  },
  gradientOrb2: {
    position: 'absolute',
    bottom: -200,
    left: -100,
    width: 400,
    height: 400,
    borderRadius: 200,
    backgroundColor: 'rgba(99, 102, 241, 0.05)',
  },
  heroContent: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    justifyContent: 'space-between',
    zIndex: 10,
  },
  heroTextContainer: {
    flex: 1,
    maxWidth: 480,
    paddingRight: 40,
  },
  heroTitle: {
    fontSize: 44,
    fontWeight: '700',
    color: '#fff',
    lineHeight: 52,
    letterSpacing: -1,
    marginBottom: 24,
  },
  heroTitleAccent: {
    color: '#60a5fa',
  },
  heroDescription: {
    fontSize: 17,
    color: '#94a3b8',
    lineHeight: 26,
    marginBottom: 16,
  },
  heroBadge: {
    fontSize: 16,
    fontWeight: '700',
    color: '#fff',
    marginBottom: 32,
  },
  heroBadgeLight: {
    fontWeight: '400',
    color: '#6b7280',
  },
  heroButtons: {
    flexDirection: 'row',
    gap: 14,
  },
  heroButtonPrimary: {
    backgroundColor: '#1e3a8a',
    borderWidth: 1,
    borderColor: '#1e40af',
    paddingHorizontal: 28,
    paddingVertical: 14,
    borderRadius: 8,
  },
  heroButtonPrimaryText: {
    color: '#fff',
    fontSize: 15,
    fontWeight: '600',
  },
  heroButtonSecondary: {
    backgroundColor: '#2563eb',
    paddingHorizontal: 28,
    paddingVertical: 14,
    borderRadius: 8,
  },
  heroButtonSecondaryText: {
    color: '#fff',
    fontSize: 15,
    fontWeight: '600',
  },
  
  // Device Mockups
  devicesContainer: {
    flex: 1.2,
    alignItems: 'center',
    justifyContent: 'center',
    minWidth: 400,
  },
  monitorWrapper: {
    position: 'relative',
    alignItems: 'center',
    transform: [
      {perspective: 1000},
      {rotateY: '-12deg'},
      {rotateX: '5deg'},
    ],
  },
  monitorFrame: {
    width: 420,
    backgroundColor: '#1a202c',
    borderRadius: 12,
    borderWidth: 8,
    borderColor: '#2d3748',
    overflow: 'hidden',
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: {width: 20, height: 30},
        shadowOpacity: 0.5,
        shadowRadius: 40,
      },
      android: {
        elevation: 30,
      },
    }),
  },
  screenHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 10,
    backgroundColor: '#0f1419',
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(255, 255, 255, 0.08)',
  },
  screenHeaderText: {
    fontSize: 11,
    color: '#6b7280',
    fontWeight: '500',
  },
  windowDots: {
    flexDirection: 'row',
    gap: 6,
  },
  dot: {
    width: 10,
    height: 10,
    borderRadius: 5,
  },
  dotRed: {backgroundColor: '#ef4444'},
  dotYellow: {backgroundColor: '#eab308'},
  dotGreen: {backgroundColor: '#22c55e'},
  screenContent: {
    flexDirection: 'row',
    padding: 16,
    backgroundColor: '#0f1419',
    minHeight: 200,
  },
  sidebar: {
    width: 60,
    backgroundColor: 'rgba(30, 41, 59, 0.4)',
    borderRadius: 8,
    padding: 10,
    marginRight: 16,
    gap: 8,
  },
  sidebarItem1: {height: 6, backgroundColor: '#374151', borderRadius: 3, width: '50%'},
  sidebarItem2: {height: 6, backgroundColor: '#3b82f6', borderRadius: 3, opacity: 0.6},
  sidebarItem3: {height: 6, backgroundColor: '#374151', borderRadius: 3, width: '70%', opacity: 0.5},
  sidebarItem4: {height: 6, backgroundColor: '#374151', borderRadius: 3, width: '85%', opacity: 0.5},
  mainContent: {
    flex: 1,
  },
  eligibilityLabel: {
    fontSize: 10,
    color: '#6b7280',
    marginBottom: 4,
    letterSpacing: 0.3,
  },
  amountRow: {
    flexDirection: 'row',
    alignItems: 'baseline',
    marginBottom: 14,
  },
  amountValue: {
    fontSize: 32,
    fontWeight: '700',
    color: '#fff',
    letterSpacing: -0.5,
  },
  amountCurrency: {
    fontSize: 14,
    color: '#6b7280',
    marginLeft: 6,
  },
  statsRow: {
    flexDirection: 'row',
    gap: 20,
    marginBottom: 14,
  },
  statItem: {
    flex: 1,
  },
  statLabel: {
    fontSize: 9,
    color: '#4b5563',
    marginBottom: 3,
    letterSpacing: 0.2,
  },
  statValue: {
    fontSize: 15,
    fontWeight: '700',
    color: '#fff',
  },
  statUnit: {
    fontSize: 10,
    fontWeight: '400',
    color: '#6b7280',
  },
  scoreCard: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: '#1e293b',
    borderWidth: 1,
    borderColor: '#334155',
    borderRadius: 8,
    padding: 10,
  },
  scoreInfo: {},
  scoreLabel: {
    fontSize: 9,
    color: '#6b7280',
    marginBottom: 2,
  },
  scoreValueRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  scoreValue: {
    fontSize: 16,
    fontWeight: '700',
    color: '#fff',
  },
  scoreRating: {
    fontSize: 10,
    fontWeight: '600',
    color: '#22c55e',
  },
  scoreCheckmark: {
    width: 22,
    height: 22,
    borderRadius: 11,
    backgroundColor: '#2563eb',
    borderWidth: 2,
    borderColor: '#60a5fa',
    justifyContent: 'center',
    alignItems: 'center',
  },
  scoreProgressBar: {
    height: 4,
    backgroundColor: '#1e293b',
    borderRadius: 2,
    marginTop: 8,
    overflow: 'hidden',
  },
  scoreProgressFill: {
    height: '100%',
    backgroundColor: '#22c55e',
    borderRadius: 2,
  },
  monitorStand: {
    width: 80,
    height: 35,
    backgroundColor: '#374151',
    marginTop: -1,
  },
  monitorBase: {
    width: 140,
    height: 10,
    backgroundColor: '#1f2937',
    borderRadius: 5,
    marginTop: -1,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: {width: 0, height: 4},
        shadowOpacity: 0.3,
        shadowRadius: 8,
      },
    }),
  },
  
  // Phone Mockup
  phoneWrapper: {
    position: 'absolute',
    right: -80,
    top: 20,
    transform: [
      {perspective: 800},
      {rotateY: '-15deg'},
      {rotateX: '8deg'},
    ],
  },
  phoneFrame: {
    width: 130,
    aspectRatio: 9 / 17,
    backgroundColor: '#000',
    borderRadius: 22,
    borderWidth: 4,
    borderColor: '#1f2937',
    overflow: 'hidden',
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: {width: 15, height: 25},
        shadowOpacity: 0.6,
        shadowRadius: 30,
      },
      android: {
        elevation: 25,
      },
    }),
  },
  phoneNotch: {
    width: 40,
    height: 5,
    backgroundColor: '#1f2937',
    borderRadius: 3,
    alignSelf: 'center',
    marginTop: 8,
    marginBottom: 8,
  },
  phoneHeader: {
    paddingHorizontal: 12,
    paddingBottom: 8,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(255, 255, 255, 0.1)',
  },
  phoneHeaderText: {
    fontSize: 10,
    color: '#6b7280',
    fontWeight: '600',
    textAlign: 'center',
    letterSpacing: 0.5,
  },
  phoneContent: {
    flex: 1,
    padding: 10,
    backgroundColor: '#0f1419',
  },
  phoneCard: {
    backgroundColor: '#334155',
    borderRadius: 10,
    padding: 12,
    borderWidth: 1,
    borderColor: 'rgba(148, 163, 184, 0.2)',
  },
  phoneCardLabel: {
    fontSize: 8,
    color: '#6b7280',
    fontWeight: '600',
    letterSpacing: 0.8,
    marginBottom: 6,
  },
  phoneCardAmount: {
    fontSize: 24,
    fontWeight: '700',
    color: '#fff',
    letterSpacing: -0.5,
  },
  phoneCardCurrency: {
    fontSize: 10,
    color: '#6b7280',
    marginBottom: 10,
  },
  phoneCardStats: {
    gap: 8,
  },
  phoneCardStat: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingTop: 8,
    borderTopWidth: 1,
    borderTopColor: 'rgba(148, 163, 184, 0.15)',
  },
  phoneCardStatLabel: {
    fontSize: 8,
    color: '#4b5563',
    fontWeight: '500',
  },
  phoneCardStatValue: {
    fontSize: 10,
    color: '#e2e8f0',
    fontWeight: '600',
  },
  
  // Calculator Section
  calculatorSection: {
    marginTop: -60,
    paddingHorizontal: 20,
    paddingBottom: 60,
    zIndex: 20,
  },
  calculatorCard: {
    backgroundColor: 'rgba(255, 255, 255, 0.03)',
    borderRadius: 16,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.08)',
    overflow: 'hidden',
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: {width: 0, height: 20},
        shadowOpacity: 0.3,
        shadowRadius: 30,
      },
      android: {
        elevation: 15,
      },
    }),
  },
  calculatorTabs: {
    flexDirection: 'row',
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(255, 255, 255, 0.05)',
  },
  calculatorTab: {
    flex: 1,
    paddingVertical: 16,
    alignItems: 'center',
    backgroundColor: 'rgba(255, 255, 255, 0.02)',
  },
  calculatorTabActive: {
    backgroundColor: '#d1d5db',
  },
  calculatorTabText: {
    fontSize: 13,
    fontWeight: '500',
    color: '#6b7280',
  },
  calculatorTabTextActive: {
    color: '#111827',
    fontWeight: '600',
  },
  calculatorContent: {
    flexDirection: 'row',
  },
  calculatorInputs: {
    flex: 1,
    padding: 28,
    backgroundColor: '#e2e8f0',
  },
  inputsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 16,
    marginBottom: 24,
  },
  inputGroup: {
    width: '48%',
  },
  inputLabel: {
    fontSize: 10,
    fontWeight: '700',
    color: '#475569',
    marginBottom: 8,
    letterSpacing: 0.5,
  },
  inputWrapper: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#fff',
    borderRadius: 8,
    paddingHorizontal: 14,
    paddingVertical: 12,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: {width: 0, height: 1},
        shadowOpacity: 0.08,
        shadowRadius: 2,
      },
      android: {
        elevation: 1,
      },
    }),
  },
  input: {
    flex: 1,
    fontSize: 14,
    fontWeight: '500',
    color: '#0f172a',
    padding: 0,
  },
  inputText: {
    flex: 1,
    fontSize: 14,
    fontWeight: '500',
    color: '#0f172a',
  },
  inputTextDisabled: {
    flex: 1,
    fontSize: 13,
    color: '#64748b',
    fontStyle: 'italic',
  },
  calculateButton: {
    backgroundColor: '#1e3a8a',
    paddingVertical: 14,
    paddingHorizontal: 28,
    borderRadius: 8,
    alignSelf: 'flex-end',
    ...Platform.select({
      ios: {
        shadowColor: '#1e3a8a',
        shadowOffset: {width: 0, height: 4},
        shadowOpacity: 0.3,
        shadowRadius: 8,
      },
      android: {
        elevation: 6,
      },
    }),
  },
  calculateButtonText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: '600',
  },
  calculatorResults: {
    width: 280,
    backgroundColor: '#111827',
    padding: 24,
    borderLeftWidth: 1,
    borderLeftColor: 'rgba(255, 255, 255, 0.05)',
  },
  resultItem: {
    marginBottom: 18,
    paddingBottom: 18,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(255, 255, 255, 0.08)',
  },
  resultLabel: {
    fontSize: 13,
    color: '#94a3b8',
    marginBottom: 6,
  },
  resultValue: {
    fontSize: 22,
    fontWeight: '700',
    color: '#fff',
    letterSpacing: -0.3,
  },
  resultUnit: {
    fontSize: 12,
    fontWeight: '400',
    color: '#6b7280',
  },
  resultDtiRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  resultDtiIcon: {
    width: 22,
    height: 22,
    borderRadius: 11,
    backgroundColor: '#2563eb',
    justifyContent: 'center',
    alignItems: 'center',
  },
  estimativBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    alignSelf: 'flex-end',
    backgroundColor: 'rgba(255, 255, 255, 0.05)',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 4,
    gap: 6,
  },
  estimativText: {
    fontSize: 11,
    color: '#6b7280',
  },
  
  // Partners Section
  partnersSection: {
    paddingVertical: 50,
    paddingHorizontal: 20,
    alignItems: 'center',
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(255, 255, 255, 0.05)',
  },
  partnersDivider: {
    width: 80,
    height: 1,
    backgroundColor: '#374151',
  },
  partnersTitle: {
    fontSize: 13,
    color: '#6b7280',
    letterSpacing: 0.5,
    marginVertical: 30,
    textAlign: 'center',
  },
  partnersRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'center',
    alignItems: 'center',
    gap: 32,
    marginTop: 20,
    opacity: 0.9,
  },
  partnerItem: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  partnerBCR: {
    fontSize: 18,
    fontWeight: '700',
    color: '#3b82f6',
  },
  partnerBCRDot: {
    width: 14,
    height: 14,
    backgroundColor: '#dc2626',
    borderRadius: 2,
  },
  partnerBTCircle: {
    width: 28,
    height: 28,
    borderRadius: 14,
    borderWidth: 2,
    borderColor: '#eab308',
    justifyContent: 'center',
    alignItems: 'center',
  },
  partnerBTText: {
    fontSize: 10,
    fontWeight: '700',
    color: '#eab308',
  },
  partnerBRD: {
    flexDirection: 'row',
    gap: -6,
  },
  brdShape1: {
    width: 12,
    height: 12,
    backgroundColor: '#dc2626',
    transform: [{rotate: '45deg'}],
  },
  brdShape2: {
    width: 12,
    height: 12,
    backgroundColor: '#000',
    borderWidth: 1,
    borderColor: '#fff',
    transform: [{rotate: '45deg'}],
  },
  partnerBRDText: {
    fontSize: 16,
    fontWeight: '700',
    color: '#fff',
    fontFamily: Platform.OS === 'ios' ? 'Georgia' : 'serif',
    marginLeft: 4,
  },
  partnerING: {
    fontSize: 18,
    fontWeight: '700',
    color: '#f97316',
  },
  partnerUniCredit: {
    width: 20,
    height: 20,
    borderRadius: 10,
    backgroundColor: '#dc2626',
    justifyContent: 'center',
    alignItems: 'center',
  },
  uniCreditArrow: {
    transform: [{rotate: '45deg'}],
  },
  partnerUniCreditText: {
    fontSize: 16,
    fontWeight: '700',
    color: '#fff',
    fontStyle: 'italic',
    marginLeft: 4,
  },
  partnerGaranti: {
    fontSize: 15,
    fontWeight: '700',
    color: '#fff',
    marginLeft: 4,
  },
  
  // Features Section
  featuresSection: {
    paddingVertical: 60,
    paddingHorizontal: 20,
    backgroundColor: '#0f1419',
  },
  featuresTitleContainer: {
    alignItems: 'center',
    marginBottom: 40,
    position: 'relative',
  },
  featuresTitleLine: {
    position: 'absolute',
    top: '50%',
    left: 0,
    right: 0,
    height: 1,
    backgroundColor: '#1f2937',
  },
  featuresTitle: {
    fontSize: 22,
    fontWeight: '700',
    color: '#fff',
    backgroundColor: '#0f1419',
    paddingHorizontal: 20,
  },
  featuresGrid: {
    flexDirection: 'row',
    gap: 14,
  },
  featureCard: {
    flex: 1,
    backgroundColor: '#151f32',
    borderRadius: 12,
    padding: 18,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.05)',
    minHeight: 180,
  },
  featureHeader: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    gap: 10,
    marginBottom: 14,
  },
  featureIconContainer: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: 'rgba(59, 130, 246, 0.2)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  featureTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: '#fff',
    lineHeight: 18,
    flex: 1,
  },
  featureDivider: {
    height: 1,
    backgroundColor: '#1f2937',
    marginBottom: 12,
  },
  featureDescription: {
    fontSize: 12,
    color: '#6b7280',
    lineHeight: 18,
  },
  
  // Help Section
  helpSection: {
    paddingVertical: 50,
    paddingHorizontal: 20,
    backgroundColor: '#0a0f1a',
  },
  helpCard: {
    backgroundColor: '#162032',
    borderRadius: 16,
    borderWidth: 1,
    borderColor: '#1f2937',
    overflow: 'hidden',
  },
  helpContent: {
    flexDirection: 'row',
  },
  helpTextContainer: {
    flex: 1,
    padding: 40,
  },
  helpTitle: {
    fontSize: 28,
    fontWeight: '700',
    color: '#fff',
    marginBottom: 14,
    letterSpacing: -0.3,
  },
  helpDescription: {
    fontSize: 15,
    color: '#94a3b8',
    lineHeight: 24,
    marginBottom: 28,
  },
  helpButtons: {
    flexDirection: 'row',
    gap: 14,
    marginBottom: 28,
  },
  helpButtonPrimary: {
    backgroundColor: '#1e3a8a',
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: 8,
  },
  helpButtonPrimaryText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: '600',
  },
  helpButtonSecondary: {
    borderWidth: 1,
    borderColor: '#4b5563',
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: 8,
  },
  helpButtonSecondaryText: {
    color: '#d1d5db',
    fontSize: 14,
    fontWeight: '500',
  },
  helpFooter: {
    fontSize: 11,
    color: '#4b5563',
    letterSpacing: 0.2,
  },
  helpImageContainer: {
    width: '40%',
    minHeight: 320,
    position: 'relative',
  },
  helpImage: {
    width: '100%',
    height: '100%',
  },
  helpImageOverlay: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    height: '50%',
    backgroundColor: 'rgba(22, 32, 50, 0.8)',
  },
});

export default LandingScreen;
