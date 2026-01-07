import React from 'react';
import {View, StyleSheet, Text, Image} from 'react-native';

interface LogoProps {
  size?: 'small' | 'medium' | 'large';
  showTagline?: boolean;
}

const Logo: React.FC<LogoProps> = ({size = 'medium', showTagline = false}) => {
  const sizeStyles = {
    small: {fontSize: 18, iconSize: 24},
    medium: {fontSize: 24, iconSize: 32},
    large: {fontSize: 32, iconSize: 40},
  };

  const currentSize = sizeStyles[size];

  return (
    <View style={styles.container}>
      <View style={styles.logoContainer}>
        <Text style={[styles.logoText, {fontSize: currentSize.fontSize}]}>
          <Text style={styles.money}>Money</Text>
          <Text style={styles.shop}>Shop</Text>
          <Text style={styles.registered}>®</Text>
        </Text>
      </View>
      {showTagline && (
        <Text style={styles.tagline}>Simplu. Rapid. Transparent.</Text>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  logoContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  logoText: {
    fontWeight: '800',
    letterSpacing: 0.8,
  },
  money: {
    color: '#00C853', // Vibrant Green (Volt-inspired)
  },
  shop: {
    color: '#1A237E', // Deep Blue
  },
  registered: {
    color: '#1A237E',
    fontSize: 10,
    verticalAlign: 'super',
  },
  tagline: {
    marginTop: 6,
    fontSize: 13,
    color: '#6B7280',
    fontWeight: '400',
    letterSpacing: 0.8,
  },
});

export default Logo;

