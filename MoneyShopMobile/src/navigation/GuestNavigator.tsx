import React from 'react';
import {createNativeStackNavigator} from '@react-navigation/native-stack';
import MobileLoginScreen from '../screens/Auth/MobileLoginScreen';

export type GuestStackParamList = {
  MobileLogin: undefined;
};

const Stack = createNativeStackNavigator<GuestStackParamList>();

/**
 * GuestNavigator - Navigator simplificat pentru utilizatori neautentificați
 * 
 * Pe mobile, utilizatorul vede doar un ecran de login care îl redirecționează
 * către browser-ul web pentru autentificare securizată.
 */
const GuestNavigator = () => {
  return (
    <Stack.Navigator
      initialRouteName="MobileLogin"
      screenOptions={{
        headerShown: false,
      }}>
      <Stack.Screen
        name="MobileLogin"
        component={MobileLoginScreen}
      />
    </Stack.Navigator>
  );
};

export default GuestNavigator;

