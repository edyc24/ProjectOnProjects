import React from 'react';
import {createNativeStackNavigator} from '@react-navigation/native-stack';
import LandingScreen from '../screens/Landing/LandingScreen';
import SimulatorScreen from '../screens/Simulator/SimulatorScreen';
import SimulatorFormScreen from '../screens/Simulator/SimulatorFormScreen';
import SimulatorResultScreen from '../screens/Simulator/SimulatorResultScreen';
import LoginScreen from '../screens/Auth/LoginScreen';
import RegisterScreen from '../screens/Auth/RegisterScreen';
import ForgotPasswordScreen from '../screens/Auth/ForgotPasswordScreen';
import OtpLoginScreen from '../screens/Auth/OtpLoginScreen';
import CustomHeader from '../components/CustomHeader';

export type GuestStackParamList = {
  Landing: undefined;
  Simulator: undefined;
  SimulatorForm: undefined;
  SimulatorResult: {result: any};
  Login: undefined;
  Register: undefined;
  ForgotPassword: undefined;
  OtpLogin: undefined;
};

const Stack = createNativeStackNavigator<GuestStackParamList>();

const GuestNavigator = () => {
  return (
    <Stack.Navigator
      initialRouteName="Landing"
      screenOptions={{
        headerShown: true,
        header: props => <CustomHeader {...props} />,
      }}>
      <Stack.Screen
        name="Landing"
        component={LandingScreen}
        options={{title: 'MoneyShop', headerShown: false}}
      />
      <Stack.Screen
        name="Simulator"
        component={SimulatorScreen}
        options={{title: 'Simulator Credit'}}
      />
      <Stack.Screen
        name="SimulatorForm"
        component={SimulatorFormScreen}
        options={{title: 'Completează datele'}}
      />
      <Stack.Screen
        name="SimulatorResult"
        component={SimulatorResultScreen}
        options={{title: 'Rezultate'}}
      />
      <Stack.Screen
        name="Login"
        component={LoginScreen}
        options={{title: 'Autentificare'}}
      />
      <Stack.Screen
        name="Register"
        component={RegisterScreen}
        options={{title: 'Înregistrare'}}
      />
      <Stack.Screen
        name="ForgotPassword"
        component={ForgotPasswordScreen}
        options={{title: 'Recuperare parolă'}}
      />
      <Stack.Screen
        name="OtpLogin"
        component={OtpLoginScreen}
        options={{title: 'Autentificare SMS'}}
      />
    </Stack.Navigator>
  );
};

export default GuestNavigator;

