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
  RadioButton,
  ProgressBar,
} from 'react-native-paper';
import {useMutation} from '@tanstack/react-query';
import {applicationsApi} from '../../services/api/applicationsApi';
import {Application} from '../../types/application.types';
import {NativeStackNavigationProp} from '@react-navigation/native-stack';
import {appInsightsService} from '../../services/telemetry/appInsightsService';

type ApplicationWizardScreenNavigationProp = NativeStackNavigationProp<any>;

interface Props {
  navigation: ApplicationWizardScreenNavigationProp;
}

const ApplicationWizardScreen: React.FC<Props> = ({navigation}) => {
  const [currentStep, setCurrentStep] = useState(1);
  const totalSteps = 7;

  // Step 1: Date personale
  const [nume, setNume] = useState('');
  const [prenume, setPrenume] = useState('');
  const [cnp, setCnp] = useState('');
  const [adresa, setAdresa] = useState('');

  // Step 2: Venituri
  const [salariuNet, setSalariuNet] = useState('');
  const [bonuriMasa, setBonuriMasa] = useState(false);
  const [sumaBonuriMasa, setSumaBonuriMasa] = useState('');
  const [venituriAlte, setVenituriAlte] = useState('');

  // Step 3: Credite existente
  const [nrCrediteBanci, setNrCrediteBanci] = useState('');
  const [soldTotal, setSoldTotal] = useState('');
  const [rataLunara, setRataLunara] = useState('');

  // Step 4: Tip credit
  const [typeCredit, setTypeCredit] = useState<string>('nevoi_personale');
  const [tipOperatiune, setTipOperatiune] = useState<string>('nou');
  const [sumaDorita, setSumaDorita] = useState('');
  const [perioada, setPerioada] = useState('');

  // Step 5: Upload documente (placeholder - fără upload real)
  const [documenteUploadate, setDocumenteUploadate] = useState<string[]>([]);

  // Step 6: Acorduri (fără OCR și semnătură)
  const [acordMarketing, setAcordMarketing] = useState(false);
  const [acordGdpr, setAcordGdpr] = useState(false);
  const [acordIntermediere, setAcordIntermediere] = useState(false);

  const createApplicationMutation = useMutation({
    mutationFn: (application: Partial<Application>) =>
      applicationsApi.create(application),
    onSuccess: (data, variables) => {
      // Track successful application creation
      appInsightsService.trackEvent('ApplicationCreated', {
        typeCredit: variables.typeCredit || 'unknown',
        tipOperatiune: variables.tipOperatiune || 'unknown',
      });
      navigation.navigate('ApplicationSuccess');
    },
    onError: (error: any) => {
      // Track application creation error
      appInsightsService.trackError(
        error instanceof Error ? error : new Error(error?.message || 'Unknown error'),
        {
          screen: 'ApplicationWizardScreen',
          errorType: 'ApplicationCreationError',
        }
      );
    },
  });

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

  const handleSubmit = () => {
    // Track button click event
    appInsightsService.trackButtonClick('CreateApplication', 'submit', {
      screen: 'ApplicationWizardScreen',
      step: currentStep.toString(),
      typeCredit: typeCredit,
    });

    const application: Partial<Application> = {
      typeCredit,
      tipOperatiune,
      salariuNet: parseFloat(salariuNet) || undefined,
      bonuriMasa,
      sumaBonuriMasa: bonuriMasa ? parseFloat(sumaBonuriMasa) || undefined : undefined,
      soldTotal: parseFloat(soldTotal) || undefined,
      nrCrediteBanci: parseInt(nrCrediteBanci) || undefined,
    };

    createApplicationMutation.mutate(application);
  };

  const renderStep = () => {
    switch (currentStep) {
      case 1:
        return (
          <View>
            <Text variant="titleLarge" style={styles.stepTitle}>
              Pas 1: Date personale
            </Text>
            <TextInput
              label="Nume"
              value={nume}
              onChangeText={setNume}
              mode="outlined"
              style={styles.input}
            />
            <TextInput
              label="Prenume"
              value={prenume}
              onChangeText={setPrenume}
              mode="outlined"
              style={styles.input}
            />
            <TextInput
              label="CNP"
              value={cnp}
              onChangeText={setCnp}
              keyboardType="numeric"
              mode="outlined"
              style={styles.input}
            />
            <TextInput
              label="Adresă"
              value={adresa}
              onChangeText={setAdresa}
              mode="outlined"
              multiline
              numberOfLines={3}
              style={styles.input}
            />
          </View>
        );

      case 2:
        return (
          <View>
            <Text variant="titleLarge" style={styles.stepTitle}>
              Pas 2: Venituri
            </Text>
            <TextInput
              label="Salariu net (lei)"
              value={salariuNet}
              onChangeText={setSalariuNet}
              keyboardType="numeric"
              mode="outlined"
              style={styles.input}
            />
            <View style={styles.checkboxRow}>
              <RadioButton
                value="da"
                status={bonuriMasa ? 'checked' : 'unchecked'}
                onPress={() => setBonuriMasa(!bonuriMasa)}
              />
              <Text>Am bonuri de masă</Text>
            </View>
            {bonuriMasa && (
              <TextInput
                label="Suma bonuri de masă (lei/lună)"
                value={sumaBonuriMasa}
                onChangeText={setSumaBonuriMasa}
                keyboardType="numeric"
                mode="outlined"
                style={styles.input}
              />
            )}
            <TextInput
              label="Alte venituri (lei/lună) - opțional"
              value={venituriAlte}
              onChangeText={setVenituriAlte}
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
              Pas 3: Credite existente
            </Text>
            <TextInput
              label="Număr credite bancare active"
              value={nrCrediteBanci}
              onChangeText={setNrCrediteBanci}
              keyboardType="numeric"
              mode="outlined"
              style={styles.input}
            />
            <TextInput
              label="Sold total rămas (lei)"
              value={soldTotal}
              onChangeText={setSoldTotal}
              keyboardType="numeric"
              mode="outlined"
              style={styles.input}
            />
            <TextInput
              label="Rată lunară totală (lei)"
              value={rataLunara}
              onChangeText={setRataLunara}
              keyboardType="numeric"
              mode="outlined"
              style={styles.input}
            />
          </View>
        );

      case 4:
        return (
          <View>
            <Text variant="titleLarge" style={styles.stepTitle}>
              Pas 4: Tip credit
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
            <TextInput
              label="Suma dorită (lei)"
              value={sumaDorita}
              onChangeText={setSumaDorita}
              keyboardType="numeric"
              mode="outlined"
              style={styles.input}
            />
            <TextInput
              label="Perioadă (luni)"
              value={perioada}
              onChangeText={setPerioada}
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
              Pas 5: Upload documente
            </Text>
            <Text variant="bodyMedium" style={styles.infoText}>
              Documentele necesare vor fi încărcate ulterior prin interfața web sau
              prin aplicație după finalizarea acestui formular.
            </Text>
            <Text variant="bodySmall" style={styles.infoText}>
              Documente necesare: CI, fluturaș salariu, extras de cont, etc.
            </Text>
          </View>
        );

      case 6:
        return (
          <View>
            <Text variant="titleLarge" style={styles.stepTitle}>
              Pas 6: Acorduri
            </Text>
            <Text variant="bodyMedium" style={styles.infoText}>
              Te rugăm să citești și să accepți următoarele acorduri:
            </Text>
            <View style={styles.checkboxRow}>
              <RadioButton
                value="acord1"
                status={acordMarketing ? 'checked' : 'unchecked'}
                onPress={() => setAcordMarketing(!acordMarketing)}
              />
              <Text style={styles.checkboxText}>
                Acord marketing Popix Brokerage Consulting SRL
              </Text>
            </View>
            <View style={styles.checkboxRow}>
              <RadioButton
                value="acord2"
                status={acordGdpr ? 'checked' : 'unchecked'}
                onPress={() => setAcordGdpr(!acordGdpr)}
              />
              <Text style={styles.checkboxText}>
                Consimțământ GDPR - Popix Brokerage Consulting SRL colectează
                datele și le poate transmite către Kingstone Management SRL, în
                scopul analizei eligibilității pentru un credit bancar.
              </Text>
            </View>
            <View style={styles.checkboxRow}>
              <RadioButton
                value="acord3"
                status={acordIntermediere ? 'checked' : 'unchecked'}
                onPress={() => setAcordIntermediere(!acordIntermediere)}
              />
              <Text style={styles.checkboxText}>
                Acord intermediere credite (OUG 52/2016 – fără comision)
              </Text>
            </View>
          </View>
        );

      case 7:
        return (
          <View>
            <Text variant="titleLarge" style={styles.stepTitle}>
              Pas 7: Confirmare
            </Text>
            <Card style={styles.summaryCard}>
              <Card.Content>
                <Text variant="titleMedium" style={styles.summaryTitle}>
                  Rezumat cerere:
                </Text>
                <Text style={styles.summaryText}>
                  Nume: {nume} {prenume}
                </Text>
                <Text style={styles.summaryText}>
                  Tip credit: {typeCredit === 'ipotecar' ? 'Ipotecar' : 'Nevoi personale'}
                </Text>
                <Text style={styles.summaryText}>
                  Suma dorită: {sumaDorita} lei
                </Text>
                <Text style={styles.summaryText}>
                  Salariu net: {salariuNet} lei
                </Text>
              </Card.Content>
            </Card>
            <Text variant="bodyMedium" style={styles.confirmText}>
              Confirm că datele introduse sunt corecte și accept acordurile
              menționate.
            </Text>
          </View>
        );

      default:
        return null;
    }
  };

  const canProceed = () => {
    switch (currentStep) {
      case 1:
        return nume && prenume && cnp && adresa;
      case 2:
        return salariuNet;
      case 3:
        return true; // Opțional
      case 4:
        return typeCredit && tipOperatiune && sumaDorita;
      case 5:
        return true;
      case 6:
        return acordMarketing && acordGdpr && acordIntermediere;
      case 7:
        return true;
      default:
        return false;
    }
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}>
      <View style={styles.progressContainer}>
        <ProgressBar
          progress={currentStep / totalSteps}
          color="#6200ee"
          style={styles.progressBar}
        />
        <Text style={styles.progressText}>
          Pas {currentStep} din {totalSteps}
        </Text>
      </View>
      <ScrollView style={styles.scrollView}>
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
            <Button
              mode="contained"
              onPress={handleNext}
              disabled={!canProceed()}
              style={styles.button}>
              Următorul
            </Button>
          ) : (
            <Button
              mode="contained"
              onPress={handleSubmit}
              loading={createApplicationMutation.isPending}
              disabled={!canProceed() || createApplicationMutation.isPending}
              style={styles.button}>
              Trimite cererea
            </Button>
          )}
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
  progressContainer: {
    padding: 16,
    backgroundColor: '#fff',
  },
  progressBar: {
    height: 8,
    borderRadius: 4,
    marginBottom: 8,
  },
  progressText: {
    textAlign: 'center',
    fontSize: 12,
    color: '#666',
  },
  scrollView: {
    flex: 1,
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
    marginBottom: 12,
  },
  checkboxText: {
    flex: 1,
    marginLeft: 8,
  },
  radioRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 8,
  },
  infoText: {
    marginBottom: 16,
    color: '#666',
  },
  summaryCard: {
    marginTop: 16,
    marginBottom: 16,
  },
  summaryTitle: {
    marginBottom: 12,
    fontWeight: 'bold',
  },
  summaryText: {
    marginBottom: 8,
  },
  confirmText: {
    marginTop: 16,
    textAlign: 'center',
    color: '#666',
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
});

export default ApplicationWizardScreen;

