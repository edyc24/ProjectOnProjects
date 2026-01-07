import React from 'react';
import {View, StyleSheet, Platform, StatusBar} from 'react-native';
import {Appbar} from 'react-native-paper';
import Logo from './Logo';

interface CustomHeaderProps {
  title?: string;
  onBack?: () => void;
  showLogo?: boolean;
  rightActions?: React.ReactNode;
  transparent?: boolean;
}

const CustomHeader: React.FC<CustomHeaderProps> = ({
  title,
  onBack,
  showLogo = true,
  rightActions,
  transparent = false,
}) => {
  return (
    <>
      <StatusBar barStyle="dark-content" backgroundColor="#FFFFFF" />
      <Appbar.Header
        style={[
          styles.header,
          transparent && styles.transparentHeader,
        ]}
        elevated={false}
        mode="small">
        {showLogo && (
          <View style={styles.logoContainer}>
            <Logo size="small" />
          </View>
        )}
        {onBack && (
          <Appbar.BackAction
            onPress={onBack}
            color="#333"
            style={styles.backButton}
          />
        )}
        {title && !showLogo && (
          <Appbar.Content
            title={title}
            titleStyle={styles.title}
            style={styles.titleContainer}
          />
        )}
        {rightActions && (
          <View style={styles.rightActions}>{rightActions}</View>
        )}
      </Appbar.Header>
    </>
  );
};

const styles = StyleSheet.create({
  header: {
    backgroundColor: '#FFFFFF',
    elevation: 0,
    shadowOpacity: 0,
    borderBottomWidth: 0,
    height: 60,
    paddingHorizontal: 16,
  },
  transparentHeader: {
    backgroundColor: 'transparent',
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    zIndex: 1000,
  },
  logoContainer: {
    flex: 1,
    alignItems: 'flex-start',
    justifyContent: 'center',
    marginLeft: -8,
  },
  titleContainer: {
    flex: 1,
  },
  title: {
    fontWeight: '700',
    fontSize: 18,
    color: '#1A1A1A',
    letterSpacing: 0.3,
  },
  rightActions: {
    flexDirection: 'row',
    alignItems: 'center',
    marginRight: -8,
  },
  backButton: {
    marginLeft: -8,
  },
});

export default CustomHeader;

