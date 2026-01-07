import React, {useState} from 'react';
import {
  View,
  StyleSheet,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import {
  Text,
  TextInput,
  Button,
  Card,
  Checkbox,
  RadioButton,
  Divider,
} from 'react-native-paper';
import {useQuery, useMutation} from '@tanstack/react-query';
import {simulatorApi} from '../../services/api/simulatorApi';
import {banksApi} from '../../services/api/banksApi';
import {ScoringRequest, CardCreditData, OverdraftData, CodebitorData} from '../../types/application.types';
import {NativeStackNavigationProp} from '@react-navigation/native-stack';
import {useAuthStore} from '../../store/authStore';

type SimulatorFormScreenNavigationProp = NativeStackNavigationProp<any>;

interface Props {
  navigation: SimulatorFormScreenNavigationProp;
}

const SimulatorFormScreen: React.FC<Props> = ({navigation}) => {
  const {isAuthenticated} = useAuthStore();
  
  const {data: banks} = useQuery({
    queryKey: ['banks'],
    queryFn: banksApi.getAll,
  });

  // Step 1: Salariu
  const [salariuNet, setSalariuNet] = useState('');
  const [bonuriMasa, setBonuriMasa] = useState(false);
  const [sumaBonuriMasa, setSumaBonuriMasa] = useState('');

  // Step 2: Vechime
  const [vechimeLuni, setVechimeLuni] = useState('');

  // Step 3: Credite bancare
  const [nrCrediteBanci, setNrCrediteBanci] = useState('');
  const [banciSelectate, setBanciSelectate] = useState<number[]>([]);

  // Step 4: IFN
  const [nrIfn, setNrIfn] = useState('');

  // Step 5: Poprire
  const [poprire, setPoprire] = useState<string>('nu');

  // Step 6: Sold total
  const [soldTotal, setSoldTotal] = useState('');

  // Step 7: Tip credit
  const [typeCredit, setTypeCredit] = useState<string>('nevoi_personale');
  const [tipOperatiune, setTipOperatiune] = useState<string>('nou');

  // Step 8: Întârzieri
  const [intarzieri, setIntarzieri] = useState<string>('nu');
  const [intarzieriNumar, setIntarzieriNumar] = useState('');

  // Step 9: Carduri de credit
  const [cardCredit, setCardCredit] = useState<string>('nu');
  const [carduriCredit, setCarduriCredit] = useState<CardCreditData[]>([]);
  const [nrCarduri, setNrCarduri] = useState('');

  // Step 10: Descoperit de cont
  const [overdraft, setOverdraft] = useState<string>('nu');
  const [descoperite, setDescoperite] = useState<OverdraftData[]>([]);
  const [nrDescoperite, setNrDescoperite] = useState('');

  // Step 11: Codebitori
  const [nrCodebitori, setNrCodebitori] = useState('0');
  const [codebitori, setCodebitori] = useState<CodebitorData[]>([]);

  const [currentStep, setCurrentStep] = useState(1);
  const totalSteps = 12;

  const calculateMutation = useMutation({
    mutationFn: (request: ScoringRequest) => simulatorApi.calculateScoring(request),
    onSuccess: (data) => {
      navigation.navigate('SimulatorResult', {result: data});
    },
  });

  const toggleBanca = (bankId: number) => {
    if (banciSelectate.includes(bankId)) {
      setBanciSelectate(banciSelectate.filter(id => id !== bankId));
    } else {
      setBanciSelectate([...banciSelectate, bankId]);
    }
  };

  const addCardCredit = () => {
    const num = parseInt(nrCarduri) || 0;
    const newCards: CardCreditData[] = [];
    for (let i = 0; i < num; i++) {
      newCards.push({banca: '', limita: 0});
    }
    setCarduriCredit(newCards);
  };

  const addDescoperit = () => {
    const num = parseInt(nrDescoperite) || 0;
    const newOverdrafts: OverdraftData[] = [];
    for (let i = 0; i < num; i++) {
      newOverdrafts.push({banca: '', limita: 0});
    }
    setDescoperite(newOverdrafts);
  };

  const addCodebitori = () => {
    const num = parseInt(nrCodebitori) || 0;
    const newCodebitori: CodebitorData[] = [];
    for (let i = 0; i < num; i++) {
      newCodebitori.push({
        nume: '',
        venit: 0,
        relatie: '',
        nrCredite: 0,
        ifn: 0,
      });
    }
    setCodebitori(newCodebitori);
  };

  const handleNext = () => {
    if (currentStep < totalSteps) {
      setCurrentStep(currentStep + 1);
    }
  };

  const handlePrevious = () => {
    if (currentStep > 1) {
      setCurrentStep(currentStep - 1);
    }
  };

  const handleCalculate = () => {
    const request: ScoringRequest = {
      salariuNet: parseFloat(salariuNet) || 0,
      bonuriMasa: bonuriMasa,
      sumaBonuriMasa: bonuriMasa ? parseFloat(sumaBonuriMasa) || 0 : undefined,
      vechimeLuni: parseInt(vechimeLuni) || undefined,
      nrCrediteBanci: parseInt(nrCrediteBanci) || undefined,
      nrIfn: parseInt(nrIfn) || undefined,
      poprire: poprire === 'da',
      soldTotal: parseFloat(soldTotal) || undefined,
      intarzieri: intarzieri === 'da',
      intarzieriNumar: intarzieri === 'da' ? parseInt(intarzieriNumar) || 0 : undefined,
      cardCredit: cardCredit === 'da' ? JSON.stringify(carduriCredit) : undefined,
      overdraft: overdraft === 'da' ? JSON.stringify(descoperite) : undefined,
      codebitori: codebitori.length > 0 ? JSON.stringify(codebitori) : undefined,
    };

    calculateMutation.mutate(request);
  };

  const renderStep = () => {
    switch (currentStep) {
      case 1:
        return (
          <View>
            <Text variant="titleLarge" style={styles.stepTitle}>
              Pas 1: Salariul net
            </Text>
            <TextInput
              label="Salariul net (lei)"
              value={salariuNet}
              onChangeText={setSalariuNet}
              keyboardType="numeric"
              mode="outlined"
              style={styles.input}
            />
            <View style={styles.checkboxRow}>
              <Checkbox
                status={bonuriMasa ? 'checked' : 'unchecked'}
                onPress={() => setBonuriMasa(!bonuriMasa)}
              />
              <Text>Am bonuri de masă</Text>
            </View>
            {bonuriMasa && (
              <TextInput
                label="Suma bonuri de masă (lei/lună) sau 40 lei/zi"
                value={sumaBonuriMasa}
                onChangeText={setSumaBonuriMasa}
                keyboardType="numeric"
                mode="outlined"
                style={styles.input}
              />
            )}
          </View>
        );

      case 2:
        return (
          <View>
            <Text variant="titleLarge" style={styles.stepTitle}>
              Pas 2: Vechime la locul de muncă
            </Text>
            <TextInput
              label="Vechime (luni)"
              value={vechimeLuni}
              onChangeText={setVechimeLuni}
              keyboardType="numeric"
              mode="outlined"
              style={styles.input}
            />
          </View>
        );

      case 3:
        return (
          <View>
            <Text variant="titleLarge" style={styles.stepTitle}>
              Pas 3: Credite bancare active
            </Text>
            <TextInput
              label="Număr credite bancare"
              value={nrCrediteBanci}
              onChangeText={setNrCrediteBanci}
              keyboardType="numeric"
              mode="outlined"
              style={styles.input}
            />
            {banks && banks.length > 0 && (
              <View style={styles.banksList}>
                <Text variant="titleMedium" style={styles.sectionTitle}>
                  Selectează băncile:
                </Text>
                {banks.map(bank => (
                  <View key={bank.id} style={styles.checkboxRow}>
                    <Checkbox
                      status={
                        banciSelectate.includes(bank.id) ? 'checked' : 'unchecked'
                      }
                      onPress={() => toggleBanca(bank.id)}
                    />
                    <Text>{bank.name}</Text>
                  </View>
                ))}
              </View>
            )}
          </View>
        );

      case 4:
        return (
          <View>
            <Text variant="titleLarge" style={styles.stepTitle}>
              Pas 4: IFN-uri active
            </Text>
            <TextInput
              label="Număr IFN-uri"
              value={nrIfn}
              onChangeText={setNrIfn}
              keyboardType="numeric"
              mode="outlined"
              style={styles.input}
            />
          </View>
        );

      case 5:
        return (
          <View>
            <Text variant="titleLarge" style={styles.stepTitle}>
              Pas 5: Poprire în ultimii 5 ani
            </Text>
            <RadioButton.Group
              onValueChange={setPoprire}
              value={poprire}>
              <View style={styles.radioRow}>
                <RadioButton value="nu" />
                <Text>Nu</Text>
              </View>
              <View style={styles.radioRow}>
                <RadioButton value="da" />
                <Text>Da</Text>
              </View>
            </RadioButton.Group>
          </View>
        );

      case 6:
        return (
          <View>
            <Text variant="titleLarge" style={styles.stepTitle}>
              Pas 6: Sold total rămas la credite
            </Text>
            <TextInput
              label="Sold total (lei)"
              value={soldTotal}
              onChangeText={setSoldTotal}
              keyboardType="numeric"
              mode="outlined"
              style={styles.input}
            />
          </View>
        );

      case 7:
        return (
          <View>
            <Text variant="titleLarge" style={styles.stepTitle}>
              Pas 7: Tip credit
            </Text>
            <Text variant="titleMedium" style={styles.sectionTitle}>
              Tip credit dorit:
            </Text>
            <RadioButton.Group
              onValueChange={setTypeCredit}
              value={typeCredit}>
              <View style={styles.radioRow}>
                <RadioButton value="ipotecar" />
                <Text>Ipotecar</Text>
              </View>
              <View style={styles.radioRow}>
                <RadioButton value="nevoi_personale" />
                <Text>Nevoi personale</Text>
              </View>
            </RadioButton.Group>
            <Text variant="titleMedium" style={styles.sectionTitle}>
              Tip operațiune:
            </Text>
            <RadioButton.Group
              onValueChange={setTipOperatiune}
              value={tipOperatiune}>
              <View style={styles.radioRow}>
                <RadioButton value="nou" />
                <Text>Nou</Text>
              </View>
              <View style={styles.radioRow}>
                <RadioButton value="refinantare" />
                <Text>Refinanțare</Text>
              </View>
            </RadioButton.Group>
          </View>
        );

      case 8:
        return (
          <View>
            <Text variant="titleLarge" style={styles.stepTitle}>
              Pas 8: Întârzieri la rate
            </Text>
            <RadioButton.Group
              onValueChange={setIntarzieri}
              value={intarzieri}>
              <View style={styles.radioRow}>
                <RadioButton value="nu" />
                <Text>Nu</Text>
              </View>
              <View style={styles.radioRow}>
                <RadioButton value="da" />
                <Text>Da</Text>
              </View>
            </RadioButton.Group>
            {intarzieri === 'da' && (
              <TextInput
                label="Număr întârzieri"
                value={intarzieriNumar}
                onChangeText={setIntarzieriNumar}
                keyboardType="numeric"
                mode="outlined"
                style={styles.input}
              />
            )}
          </View>
        );

      case 9:
        return (
          <View>
            <Text variant="titleLarge" style={styles.stepTitle}>
              Pas 9: Carduri de credit
            </Text>
            <RadioButton.Group
              onValueChange={setCardCredit}
              value={cardCredit}>
              <View style={styles.radioRow}>
                <RadioButton value="nu" />
                <Text>Nu</Text>
              </View>
              <View style={styles.radioRow}>
                <RadioButton value="da" />
                <Text>Da</Text>
              </View>
            </RadioButton.Group>
            {cardCredit === 'da' && (
              <View>
                <TextInput
                  label="Număr carduri"
                  value={nrCarduri}
                  onChangeText={setNrCarduri}
                  keyboardType="numeric"
                  mode="outlined"
                  style={styles.input}
                />
                <Button onPress={addCardCredit} mode="outlined">
                  Adaugă carduri
                </Button>
                {carduriCredit.map((card, index) => (
                  <Card key={index} style={styles.card}>
                    <Card.Content>
                      <Text>Card {index + 1}</Text>
                      <TextInput
                        label="Bancă"
                        value={card.banca}
                        onChangeText={text => {
                          const newCards = [...carduriCredit];
                          newCards[index].banca = text;
                          setCarduriCredit(newCards);
                        }}
                        mode="outlined"
                        style={styles.input}
                      />
                      <TextInput
                        label="Limită (lei)"
                        value={card.limita.toString()}
                        onChangeText={text => {
                          const newCards = [...carduriCredit];
                          newCards[index].limita = parseFloat(text) || 0;
                          setCarduriCredit(newCards);
                        }}
                        keyboardType="numeric"
                        mode="outlined"
                        style={styles.input}
                      />
                    </Card.Content>
                  </Card>
                ))}
              </View>
            )}
          </View>
        );

      case 10:
        return (
          <View>
            <Text variant="titleLarge" style={styles.stepTitle}>
              Pas 10: Descoperit de cont
            </Text>
            <RadioButton.Group
              onValueChange={setOverdraft}
              value={overdraft}>
              <View style={styles.radioRow}>
                <RadioButton value="nu" />
                <Text>Nu</Text>
              </View>
              <View style={styles.radioRow}>
                <RadioButton value="da" />
                <Text>Da</Text>
              </View>
            </RadioButton.Group>
            {overdraft === 'da' && (
              <View>
                <TextInput
                  label="Număr descoperite"
                  value={nrDescoperite}
                  onChangeText={setNrDescoperite}
                  keyboardType="numeric"
                  mode="outlined"
                  style={styles.input}
                />
                <Button onPress={addDescoperit} mode="outlined">
                  Adaugă descoperite
                </Button>
                {descoperite.map((od, index) => (
                  <Card key={index} style={styles.card}>
                    <Card.Content>
                      <Text>Descoperit {index + 1}</Text>
                      <TextInput
                        label="Bancă"
                        value={od.banca}
                        onChangeText={text => {
                          const newODs = [...descoperite];
                          newODs[index].banca = text;
                          setDescoperite(newODs);
                        }}
                        mode="outlined"
                        style={styles.input}
                      />
                      <TextInput
                        label="Limită (lei)"
                        value={od.limita.toString()}
                        onChangeText={text => {
                          const newODs = [...descoperite];
                          newODs[index].limita = parseFloat(text) || 0;
                          setDescoperite(newODs);
                        }}
                        keyboardType="numeric"
                        mode="outlined"
                        style={styles.input}
                      />
                    </Card.Content>
                  </Card>
                ))}
              </View>
            )}
          </View>
        );

      case 11:
        return (
          <View>
            <Text variant="titleLarge" style={styles.stepTitle}>
              Pas 11: Codebitori
            </Text>
            <TextInput
              label="Număr codebitori (0, 1 sau 2)"
              value={nrCodebitori}
              onChangeText={setNrCodebitori}
              keyboardType="numeric"
              mode="outlined"
              style={styles.input}
            />
            <Button onPress={addCodebitori} mode="outlined">
              Adaugă codebitori
            </Button>
            {codebitori.map((codebitor, index) => (
              <Card key={index} style={styles.card}>
                <Card.Content>
                  <Text>Codebitor {index + 1}</Text>
                  <TextInput
                    label="Nume"
                    value={codebitor.nume}
                    onChangeText={text => {
                      const newCodebitori = [...codebitori];
                      newCodebitori[index].nume = text;
                      setCodebitori(newCodebitori);
                    }}
                    mode="outlined"
                    style={styles.input}
                  />
                  <TextInput
                    label="Venit (lei)"
                    value={codebitor.venit.toString()}
                    onChangeText={text => {
                      const newCodebitori = [...codebitori];
                      newCodebitori[index].venit = parseFloat(text) || 0;
                      setCodebitori(newCodebitori);
                    }}
                    keyboardType="numeric"
                    mode="outlined"
                    style={styles.input}
                  />
                  <TextInput
                    label="Relație"
                    value={codebitor.relatie}
                    onChangeText={text => {
                      const newCodebitori = [...codebitori];
                      newCodebitori[index].relatie = text;
                      setCodebitori(newCodebitori);
                    }}
                    mode="outlined"
                    style={styles.input}
                  />
                  <TextInput
                    label="Număr credite"
                    value={codebitor.nrCredite.toString()}
                    onChangeText={text => {
                      const newCodebitori = [...codebitori];
                      newCodebitori[index].nrCredite = parseInt(text) || 0;
                      setCodebitori(newCodebitori);
                    }}
                    keyboardType="numeric"
                    mode="outlined"
                    style={styles.input}
                  />
                  <TextInput
                    label="Număr IFN"
                    value={codebitor.ifn.toString()}
                    onChangeText={text => {
                      const newCodebitori = [...codebitori];
                      newCodebitori[index].ifn = parseInt(text) || 0;
                      setCodebitori(newCodebitori);
                    }}
                    keyboardType="numeric"
                    mode="outlined"
                    style={styles.input}
                  />
                </Card.Content>
              </Card>
            ))}
          </View>
        );

      case 12:
        return (
          <View>
            <Text variant="titleLarge" style={styles.stepTitle}>
              Confirmare și calculare
            </Text>
            <Text variant="bodyMedium">
              Verifică datele introduse și apasă "Calculează scoring" pentru a vedea
              șansele tale de aprobare.
            </Text>
            <Button
              mode="contained"
              onPress={handleCalculate}
              loading={calculateMutation.isPending}
              style={styles.calculateButton}>
              Calculează scoring
            </Button>
          </View>
        );

      default:
        return null;
    }
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}>
      <ScrollView style={styles.scrollView}>
        <View style={styles.progressBar}>
          <Text>
            Pas {currentStep} din {totalSteps}
          </Text>
        </View>
        <Card style={styles.card}>
          <Card.Content>{renderStep()}</Card.Content>
        </Card>
        <View style={styles.buttons}>
          {currentStep > 1 && (
            <Button mode="outlined" onPress={handlePrevious} style={styles.button}>
              Înapoi
            </Button>
          )}
          {currentStep < totalSteps ? (
            <Button mode="contained" onPress={handleNext} style={styles.button}>
              Următorul
            </Button>
          ) : null}
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  scrollView: {
    flex: 1,
  },
  progressBar: {
    padding: 16,
    backgroundColor: '#fff',
  },
  card: {
    margin: 16,
  },
  stepTitle: {
    marginBottom: 16,
    fontWeight: 'bold',
  },
  sectionTitle: {
    marginTop: 16,
    marginBottom: 8,
  },
  input: {
    marginBottom: 16,
  },
  checkboxRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 8,
  },
  radioRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 8,
  },
  banksList: {
    marginTop: 16,
  },
  buttons: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    padding: 16,
  },
  button: {
    flex: 1,
    marginHorizontal: 8,
  },
  calculateButton: {
    marginTop: 20,
    paddingVertical: 5,
  },
});

export default SimulatorFormScreen;

