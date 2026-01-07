import React from 'react';
import {createBottomTabNavigator} from '@react-navigation/bottom-tabs';
import {createNativeStackNavigator} from '@react-navigation/native-stack';
import DashboardScreen from '../screens/Dashboard/DashboardScreen';
import ApplicationListScreen from '../screens/Dashboard/ApplicationListScreen';
import SimulatorScreen from '../screens/Simulator/SimulatorScreen';
import SimulatorFormScreen from '../screens/Simulator/SimulatorFormScreen';
import SimulatorResultScreen from '../screens/Simulator/SimulatorResultScreen';
import ApplicationWizardScreen from '../screens/Application/ApplicationWizardScreen';
import ApplicationSuccessScreen from '../screens/Application/ApplicationSuccessScreen';
import ProfileScreen from '../screens/Profile/ProfileScreen';
import LegalMenuScreen from '../screens/Legal/LegalMenuScreen';
import TermsScreen from '../screens/Legal/TermsScreen';
import PrivacyScreen from '../screens/Legal/PrivacyScreen';
import MandateScreen from '../screens/Legal/MandateScreen';
import ComplianceScreen from '../screens/Legal/ComplianceScreen';
import DataTransferScreen from '../screens/Legal/DataTransferScreen';
import ConsentManagementScreen from '../screens/Consent/ConsentManagementScreen';
import MandateManagementScreen from '../screens/Mandate/MandateManagementScreen';
import BrokerDirectoryScreen from '../screens/Broker/BrokerDirectoryScreen';
import FinancialDataScreen from '../screens/Profile/FinancialDataScreen';
import KycFormScreen from '../screens/Kyc/KycFormScreen';
import KycAdminScreen from '../screens/Kyc/KycAdminScreen';
import CustomHeader from '../components/CustomHeader';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

const Tab = createBottomTabNavigator();
const Stack = createNativeStackNavigator();

const DashboardStack = () => {
  const getTitle = (routeName: string) => {
    const titles: {[key: string]: string} = {
      ApplicationList: 'Cererile mele',
      ApplicationWizard: 'Cerere nouă',
      KycAdmin: 'Verificări KYC',
    };
    return titles[routeName];
  };

  return (
    <Stack.Navigator
      screenOptions={{
        header: ({navigation, route}) => (
          <CustomHeader
            title={route.name === 'DashboardHome' ? undefined : getTitle(route.name)}
            onBack={navigation.canGoBack() ? () => navigation.goBack() : undefined}
            showLogo={route.name === 'DashboardHome'}
          />
        ),
      }}>
      <Stack.Screen
        name="DashboardHome"
        component={DashboardScreen}
        options={{headerShown: true}}
      />
      <Stack.Screen
        name="ApplicationList"
        component={ApplicationListScreen}
      />
      <Stack.Screen
        name="ApplicationWizard"
        component={ApplicationWizardScreen}
      />
      <Stack.Screen
        name="ApplicationSuccess"
        component={ApplicationSuccessScreen}
        options={{headerShown: false}}
      />
      <Stack.Screen
        name="KycForm"
        component={KycFormScreen}
      />
      <Stack.Screen
        name="KycAdmin"
        component={KycAdminScreen}
      />
    </Stack.Navigator>
  );
};

const SimulatorStack = () => {
  const getTitle = (routeName: string) => {
    const titles: {[key: string]: string} = {
      SimulatorForm: 'Simulator Credit',
      SimulatorResult: 'Rezultat Simulator',
    };
    return titles[routeName];
  };

  return (
    <Stack.Navigator
      screenOptions={{
        header: ({navigation, route}) => (
          <CustomHeader
            title={route.name === 'SimulatorHome' ? undefined : getTitle(route.name)}
            onBack={navigation.canGoBack() ? () => navigation.goBack() : undefined}
            showLogo={route.name === 'SimulatorHome'}
          />
        ),
      }}>
      <Stack.Screen
        name="SimulatorHome"
        component={SimulatorScreen}
        options={{headerShown: true}}
      />
      <Stack.Screen
        name="SimulatorForm"
        component={SimulatorFormScreen}
      />
      <Stack.Screen
        name="SimulatorResult"
        component={SimulatorResultScreen}
      />
    </Stack.Navigator>
  );
};

const MainNavigator = () => {
  return (
    <Tab.Navigator
      screenOptions={({route}) => ({
        tabBarIcon: ({focused, color, size}) => {
          let iconName: string;

          if (route.name === 'Dashboard') {
            iconName = focused ? 'view-dashboard' : 'view-dashboard-outline';
          } else if (route.name === 'Simulator') {
            iconName = focused ? 'calculator' : 'calculator-outline';
          } else if (route.name === 'Profile') {
            iconName = focused ? 'account' : 'account-outline';
          } else {
            iconName = 'help-circle';
          }

          return <Icon name={iconName} size={size} color={color} />;
        },
        tabBarActiveTintColor: '#00C853',
        tabBarInactiveTintColor: '#9E9E9E',
        headerShown: false,
        tabBarStyle: {
          display: 'flex',
          backgroundColor: '#FFFFFF',
          borderTopWidth: 0,
          elevation: 8,
          shadowColor: '#000',
          shadowOffset: {width: 0, height: -2},
          shadowOpacity: 0.1,
          shadowRadius: 8,
          height: 70,
          paddingBottom: 12,
          paddingTop: 12,
        },
        tabBarLabelStyle: {
          fontSize: 11,
          fontWeight: '600',
          letterSpacing: 0.3,
        },
      })}>
      <Tab.Screen 
        name="Dashboard" 
        component={DashboardStack}
        options={{title: 'Dashboard'}}
      />
      <Tab.Screen 
        name="Simulator" 
        component={SimulatorStack}
        options={{title: 'Simulator'}}
      />
      <Tab.Screen 
        name="Profile" 
        component={ProfileStack}
        options={{title: 'Profil'}}
      />
    </Tab.Navigator>
  );
};

const ProfileStack = () => {
  const getTitle = (routeName: string) => {
    const titles: {[key: string]: string} = {
      LegalMenu: 'Informații Legale',
      Terms: 'Termeni și Condiții',
      Privacy: 'Politica de Confidențialitate',
      Mandate: 'Politica de Mandatare',
      Compliance: 'Pachet de Conformitate',
      DataTransfer: 'Politica de Transmitere Date',
      ConsentManagement: 'Gestionare Consimțământ',
      MandateManagement: 'Gestionare Mandate',
      BrokerDirectory: 'Director Brokeri',
      FinancialData: 'Date Financiare',
      KycForm: 'Verificare Identitate',
      KycAdmin: 'Verificări KYC',
    };
    return titles[routeName];
  };

  return (
    <Stack.Navigator
      screenOptions={{
        header: ({navigation, route}) => (
          <CustomHeader
            title={route.name === 'ProfileHome' ? undefined : getTitle(route.name)}
            onBack={navigation.canGoBack() ? () => navigation.goBack() : undefined}
            showLogo={route.name === 'ProfileHome'}
          />
        ),
      }}>
      <Stack.Screen
        name="ProfileHome"
        component={ProfileScreen}
        options={{headerShown: true}}
      />
      <Stack.Screen
        name="LegalMenu"
        component={LegalMenuScreen}
      />
      <Stack.Screen
        name="Terms"
        component={TermsScreen}
      />
      <Stack.Screen
        name="Privacy"
        component={PrivacyScreen}
      />
      <Stack.Screen
        name="Mandate"
        component={MandateScreen}
      />
      <Stack.Screen
        name="Compliance"
        component={ComplianceScreen}
      />
      <Stack.Screen
        name="DataTransfer"
        component={DataTransferScreen}
      />
      <Stack.Screen
        name="ConsentManagement"
        component={ConsentManagementScreen}
      />
      <Stack.Screen
        name="MandateManagement"
        component={MandateManagementScreen}
      />
      <Stack.Screen
        name="BrokerDirectory"
        component={BrokerDirectoryScreen}
      />
      <Stack.Screen
        name="FinancialData"
        component={FinancialDataScreen}
      />
      <Stack.Screen
        name="KycForm"
        component={KycFormScreen}
      />
      <Stack.Screen
        name="KycAdmin"
        component={KycAdminScreen}
      />
    </Stack.Navigator>
  );
};

export default MainNavigator;

