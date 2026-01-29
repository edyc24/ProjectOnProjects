import React from 'react';
import {View, StyleSheet, ScrollView, TouchableOpacity, Alert} from 'react-native';
import {Text} from 'react-native-paper';
import {useAuthStore} from '../../store/authStore';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import {NativeStackNavigationProp} from '@react-navigation/native-stack';
import {colors, spacing, borderRadius, typography, shadows} from '../../theme/designSystem';
import {StatusBadge} from '../../components/ui';

type ProfileScreenNavigationProp = NativeStackNavigationProp<any, 'Profile'>;

interface Props {
  navigation: ProfileScreenNavigationProp;
}

/**
 * ProfileScreen - Profil Utilizator Redesign
 * 
 * Design UX simplu conform SRS:
 * - Secțiuni clare și organizate
 * - Iconuri mari și descriptive
 * - Acțiuni vizibile și accesibile
 */

interface MenuItemProps {
  icon: string;
  title: string;
  subtitle?: string;
  onPress: () => void;
  iconBg?: string;
  iconColor?: string;
  badge?: string;
  chevron?: boolean;
}

const MenuItem: React.FC<MenuItemProps> = ({
  icon,
  title,
  subtitle,
  onPress,
  iconBg = colors.neutral[100],
  iconColor = colors.neutral[600],
  badge,
  chevron = true,
}) => (
  <TouchableOpacity
    onPress={onPress}
    activeOpacity={0.7}
    style={styles.menuItem}>
    <View style={[styles.menuIcon, {backgroundColor: iconBg}]}>
      <Icon name={icon} size={22} color={iconColor} />
    </View>
    <View style={styles.menuContent}>
      <Text style={styles.menuTitle}>{title}</Text>
      {subtitle && <Text style={styles.menuSubtitle}>{subtitle}</Text>}
    </View>
    {badge && <StatusBadge status={badge} size="small" showIcon={false} />}
    {chevron && (
      <Icon name="chevron-right" size={22} color={colors.neutral[400]} />
    )}
  </TouchableOpacity>
);

const ProfileScreen = ({navigation}: Props) => {
  const {user, logout} = useAuthStore();

  const handleLogout = async () => {
    Alert.alert(
      'Deconectare',
      'Ești sigur că vrei să te deconectezi?',
      [
        {text: 'Anulează', style: 'cancel'},
        {
          text: 'Deconectare',
          style: 'destructive',
          onPress: async () => {
            await logout();
          },
        },
      ],
    );
  };

  const getInitials = (name: string) => {
    return name
      .split(' ')
      .map(n => n[0])
      .join('')
      .toUpperCase()
      .substring(0, 2);
  };

  return (
    <ScrollView 
      style={styles.container}
      showsVerticalScrollIndicator={false}
      contentContainerStyle={styles.scrollContent}>
      
      {/* Profile Header */}
      <View style={styles.profileHeader}>
        <View style={styles.avatarContainer}>
          <View style={styles.avatar}>
            <Text style={styles.avatarText}>
              {user?.name ? getInitials(user.name) : 'U'}
            </Text>
          </View>
          <View style={styles.avatarBadge}>
            <Icon name="check" size={12} color="#FFFFFF" />
          </View>
        </View>
        <Text style={styles.userName}>{user?.name || 'Utilizator'}</Text>
        <Text style={styles.userEmail}>{user?.email}</Text>
        {user?.role && (
          <View style={styles.roleBadge}>
            <Icon 
              name={user.role === 'Administrator' ? 'shield-account' : 'account'} 
              size={14} 
              color={colors.primary[600]} 
            />
            <Text style={styles.roleText}>{user.role}</Text>
          </View>
        )}
      </View>

      {/* Quick Stats */}
      <View style={styles.statsContainer}>
        <View style={styles.statItem}>
          <Icon name="file-document-check" size={24} color={colors.success[500]} />
          <Text style={styles.statValue}>0</Text>
          <Text style={styles.statLabel}>Credite active</Text>
        </View>
        <View style={styles.statDivider} />
        <View style={styles.statItem}>
          <Icon name="file-clock" size={24} color={colors.warning[500]} />
          <Text style={styles.statValue}>0</Text>
          <Text style={styles.statLabel}>În analiză</Text>
        </View>
        <View style={styles.statDivider} />
        <View style={styles.statItem}>
          <Icon name="shield-check" size={24} color={colors.primary[500]} />
          <Text style={styles.statValue}>0</Text>
          <Text style={styles.statLabel}>Mandate</Text>
        </View>
      </View>

      {/* Main Menu */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Contul tău</Text>
        <View style={styles.menuCard}>
          <MenuItem
            icon="chart-line"
            title="Date Financiare"
            subtitle="Vizualizează veniturile și istoricul"
            onPress={() => navigation.navigate('FinancialData')}
            iconBg={colors.success[50]}
            iconColor={colors.success[600]}
          />
          <View style={styles.menuDivider} />
          <MenuItem
            icon="file-sign"
            title="Mandate"
            subtitle="Gestionează mandatele pentru ANAF/BC"
            onPress={() => navigation.navigate('MandateManagement')}
            iconBg={colors.primary[50]}
            iconColor={colors.primary[600]}
          />
          <View style={styles.menuDivider} />
          <MenuItem
            icon="checkbox-marked-circle"
            title="Consimțământ"
            subtitle="Gestionează acordurile tale"
            onPress={() => navigation.navigate('ConsentManagement')}
            iconBg={colors.warning[50]}
            iconColor={colors.warning[600]}
          />
        </View>
      </View>

      {/* Verification Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Verificări</Text>
        <View style={styles.menuCard}>
          {user?.role !== 'Administrator' && (
            <>
              <MenuItem
                icon="card-account-details"
                title="Verificare Identitate (KYC)"
                subtitle="Confirmă-ți identitatea pentru siguranță"
                onPress={() => navigation.navigate('KycForm')}
                iconBg={colors.primary[50]}
                iconColor={colors.primary[600]}
              />
              <View style={styles.menuDivider} />
            </>
          )}
          <MenuItem
            icon="email-check"
            title="Verifică Email"
            subtitle={user?.email}
            onPress={() => {
              const parent = navigation.getParent();
              if (parent) {
                parent.navigate('Auth', {
                  screen: 'Verification',
                  params: {type: 'email', email: user?.email},
                });
              }
            }}
            iconBg={colors.success[50]}
            iconColor={colors.success[600]}
          />
          <View style={styles.menuDivider} />
          <MenuItem
            icon="phone-check"
            title="Verifică Telefon"
            subtitle="Confirmă numărul de telefon"
            onPress={() => {
              const parent = navigation.getParent();
              if (parent) {
                parent.navigate('Auth', {
                  screen: 'Verification',
                  params: {type: 'phone', phone: user?.phone},
                });
              }
            }}
            iconBg={colors.success[50]}
            iconColor={colors.success[600]}
          />
        </View>
      </View>

      {/* Admin Section */}
      {user?.role === 'Administrator' && (
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Administrare</Text>
          <View style={styles.menuCard}>
            <MenuItem
              icon="shield-check"
              title="Verificări KYC"
              subtitle="Administrează verificările utilizatorilor"
              onPress={() => navigation.navigate('KycAdmin')}
              iconBg={colors.error[50]}
              iconColor={colors.error[600]}
            />
          </View>
        </View>
      )}

      {/* Resources Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Resurse</Text>
        <View style={styles.menuCard}>
          <MenuItem
            icon="office-building"
            title="Director Brokeri"
            subtitle="Găsește un broker autorizat"
            onPress={() => navigation.navigate('BrokerDirectory')}
            iconBg={colors.neutral[100]}
            iconColor={colors.neutral[600]}
          />
          <View style={styles.menuDivider} />
          <MenuItem
            icon="file-document-multiple"
            title="Informații Legale"
            subtitle="Termeni, confidențialitate, GDPR"
            onPress={() => navigation.navigate('LegalMenu')}
            iconBg={colors.neutral[100]}
            iconColor={colors.neutral[600]}
          />
        </View>
      </View>

      {/* Settings Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Aplicație</Text>
        <View style={styles.menuCard}>
          <MenuItem
            icon="cog"
            title="Setări"
            subtitle="Notificări, limbă, temă"
            onPress={() => {}}
            iconBg={colors.neutral[100]}
            iconColor={colors.neutral[600]}
          />
          <View style={styles.menuDivider} />
          <MenuItem
            icon="help-circle"
            title="Ajutor și Suport"
            subtitle="Întrebări frecvente, contact"
            onPress={() => {}}
            iconBg={colors.neutral[100]}
            iconColor={colors.neutral[600]}
          />
          <View style={styles.menuDivider} />
          <MenuItem
            icon="information"
            title="Despre MoneyShop"
            subtitle="Versiune 1.0.0"
            onPress={() => {}}
            iconBg={colors.primary[50]}
            iconColor={colors.primary[600]}
            chevron={false}
          />
        </View>
      </View>

      {/* Logout Button */}
      <TouchableOpacity
        onPress={handleLogout}
        activeOpacity={0.8}
        style={styles.logoutButton}>
        <Icon name="logout" size={22} color={colors.error[500]} />
        <Text style={styles.logoutText}>Deconectare</Text>
      </TouchableOpacity>

      {/* Footer */}
      <View style={styles.footer}>
        <Text style={styles.footerText}>
          MoneyShop® - Broker de credite autorizat
        </Text>
        <Text style={styles.footerVersion}>
          Versiune 1.0.0
        </Text>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.neutral[50],
  },
  scrollContent: {
    paddingBottom: spacing.xxxl,
  },

  // Profile Header
  profileHeader: {
    alignItems: 'center',
    paddingVertical: spacing.xxl,
    paddingHorizontal: spacing.lg,
    backgroundColor: colors.neutral[0],
    borderBottomLeftRadius: borderRadius.xxl,
    borderBottomRightRadius: borderRadius.xxl,
    ...shadows.md,
  },
  avatarContainer: {
    position: 'relative',
    marginBottom: spacing.md,
  },
  avatar: {
    width: 88,
    height: 88,
    borderRadius: 44,
    backgroundColor: colors.primary[500],
    justifyContent: 'center',
    alignItems: 'center',
  },
  avatarText: {
    ...typography.h2,
    color: '#FFFFFF',
  },
  avatarBadge: {
    position: 'absolute',
    bottom: 4,
    right: 4,
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: colors.success[500],
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: colors.neutral[0],
  },
  userName: {
    ...typography.h3,
    color: colors.neutral[900],
    marginBottom: spacing.xs,
  },
  userEmail: {
    ...typography.bodyMedium,
    color: colors.neutral[500],
    marginBottom: spacing.sm,
  },
  roleBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.primary[50],
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.xs,
    borderRadius: borderRadius.full,
    gap: spacing.xs,
  },
  roleText: {
    ...typography.labelSmall,
    color: colors.primary[700],
  },

  // Stats
  statsContainer: {
    flexDirection: 'row',
    backgroundColor: colors.neutral[0],
    marginHorizontal: spacing.lg,
    marginTop: -spacing.lg,
    borderRadius: borderRadius.xl,
    padding: spacing.lg,
    ...shadows.md,
  },
  statItem: {
    flex: 1,
    alignItems: 'center',
  },
  statValue: {
    ...typography.h4,
    color: colors.neutral[900],
    marginTop: spacing.xs,
  },
  statLabel: {
    ...typography.caption,
    color: colors.neutral[500],
    marginTop: 2,
    textAlign: 'center',
  },
  statDivider: {
    width: 1,
    backgroundColor: colors.neutral[200],
    marginVertical: spacing.xs,
  },

  // Sections
  section: {
    marginTop: spacing.xl,
    paddingHorizontal: spacing.lg,
  },
  sectionTitle: {
    ...typography.labelLarge,
    color: colors.neutral[600],
    marginBottom: spacing.md,
    marginLeft: spacing.xs,
  },

  // Menu Card
  menuCard: {
    backgroundColor: colors.neutral[0],
    borderRadius: borderRadius.xl,
    ...shadows.sm,
    overflow: 'hidden',
  },
  menuItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: spacing.lg,
  },
  menuIcon: {
    width: 44,
    height: 44,
    borderRadius: borderRadius.md,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: spacing.md,
  },
  menuContent: {
    flex: 1,
  },
  menuTitle: {
    ...typography.labelLarge,
    color: colors.neutral[800],
    marginBottom: 2,
  },
  menuSubtitle: {
    ...typography.bodySmall,
    color: colors.neutral[500],
  },
  menuDivider: {
    height: 1,
    backgroundColor: colors.neutral[100],
    marginLeft: 76,
  },

  // Logout
  logoutButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    marginHorizontal: spacing.lg,
    marginTop: spacing.xl,
    padding: spacing.lg,
    backgroundColor: colors.error[50],
    borderRadius: borderRadius.xl,
    borderWidth: 1,
    borderColor: colors.error[200],
  },
  logoutText: {
    ...typography.labelLarge,
    color: colors.error[600],
    marginLeft: spacing.sm,
  },

  // Footer
  footer: {
    alignItems: 'center',
    paddingVertical: spacing.xl,
    marginTop: spacing.lg,
  },
  footerText: {
    ...typography.caption,
    color: colors.neutral[400],
  },
  footerVersion: {
    ...typography.caption,
    color: colors.neutral[400],
    marginTop: spacing.xs,
  },
});

export default ProfileScreen;
