import React, { useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Image,
  StatusBar,
  ScrollView,
} from 'react-native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useRouter } from 'expo-router'; 
import { useSelector } from 'react-redux'; 
import { useAuth } from '../../src/features/auth/useAuth';
import { RootState } from '../../src/store/store';
import { SafeAreaView } from 'react-native-safe-area-context';

export default function LoginScreen() {
  const router = useRouter();
  const { promptAsync, request, response, handleAuthResponse } = useAuth();
  const { isAuthenticated } = useSelector((state: RootState) => state.auth);

  // 1. Écouter la réponse de Keycloak pour déclencher l'échange de token
  useEffect(() => {
    if (response?.type === 'success') {
      handleAuthResponse();
    }
  }, [response]);

  // 2. Si Redux confirme que l'utilisateur est authentifié, on dégage vers Home
  useEffect(() => {
    if (isAuthenticated) {
      router.replace('/(app)/home');
    }
  }, [isAuthenticated]);

  return (
    <SafeAreaView style={styles.container}>
      {/* ... Tout ton code JSX reste identique ici ... */}
      <StatusBar barStyle="light-content" />
      
      <View style={styles.backgroundDecor}>
        <Image 
          source={{ uri: 'https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?w=800' }} 
          style={styles.mapImage}
          blurRadius={50}
        />
      </View>

      <View style={styles.header}>
        <MaterialCommunityIcons name="arrow-left" size={24} color="#b1c7f2" />
        <Text style={styles.headerText}>INSTITUTIONAL TRANSPORT</Text>
        <MaterialCommunityIcons name="dots-vertical" size={24} color="#b1c7f2" />
      </View>

      <ScrollView contentContainerStyle={styles.main}>
        <View style={styles.heroSection}>
          <View style={styles.iconContainer}>
            <View style={styles.iconGlow} />
            <View style={styles.iconCircle}>
              <MaterialCommunityIcons name="shield-check" size={50} color="#b1c7f2" />
            </View>
          </View>
          <Text style={styles.title}>GENERAL EXPRESS VOYAGES</Text>
          <Text style={styles.subtitle}>Institutional Excellence in Travel</Text>
        </View>

        <View style={styles.loginCard}>
          <Text style={styles.cardLabel}>AUTHENTICATION GATEWAY</Text>
          <Text style={styles.cardDescription}>
            Accédez à votre espace sécurisé via notre portail d'identité institutionnel.
          </Text>

          <TouchableOpacity 
            style={[styles.authButton, !request && styles.buttonDisabled]} 
            onPress={() => promptAsync()}
            disabled={!request}
          >
            <Text style={styles.authButtonText}>AUTHENTICATE</Text>
            <MaterialCommunityIcons name="login" size={20} color="#193053" />
          </TouchableOpacity>

          <TouchableOpacity style={styles.tempCodeButton}>
            <Text style={styles.tempCodeText}>Se connecter avec un code temporaire</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.dividerContainer}>
          <View style={styles.dividerLine} />
          <Text style={styles.dividerText}>EXTERNAL IDENTITY</Text>
          <View style={styles.dividerLine} />
        </View>

        <TouchableOpacity style={styles.googleButton}>
          <MaterialCommunityIcons name="google" size={20} color="#EA4335" />
          <Text style={styles.googleButtonText}>Connexion avec GOOGLE</Text>
        </TouchableOpacity>
      </ScrollView>

      <View style={styles.footer}>
        <View style={styles.verificationBadge}>
          <MaterialCommunityIcons name="shield-lock" size={14} color="#81c399" />
          <Text style={styles.verificationText}>END-TO-END SECURE CONNECTION</Text>
        </View>
        <Text style={styles.versionText}>INSTITUTIONAL ID SYSTEM V4.2.0</Text>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#121414',
  },
  backgroundDecor: {
    ...StyleSheet.absoluteFillObject,
    opacity: 0.05,
    zIndex: -1,
  },
  mapImage: {
    width: '100%',
    height: '100%',
    resizeMode: 'cover',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    height: 60,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(177, 199, 242, 0.15)',
  },
  headerText: {
    color: '#b1c7f2',
    fontSize: 10,
    fontWeight: '800',
    letterSpacing: 1,
  },
  main: {
    paddingHorizontal: 24,
    paddingTop: 40,
    alignItems: 'center',
  },
  heroSection: {
    alignItems: 'center',
    marginBottom: 40,
  },
  iconContainer: {
    position: 'relative',
    marginBottom: 20,
  },
  iconGlow: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: '#b1c7f2',
    borderRadius: 20,
    opacity: 0.2,
    transform: [{ scale: 1.5 }],
  },
  iconCircle: {
    backgroundColor: '#1a1c1c',
    padding: 20,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: 'rgba(177, 199, 242, 0.15)',
  },
  title: {
    color: '#e2e2e2',
    fontSize: 28,
    fontWeight: '900',
    textAlign: 'center',
    letterSpacing: -1,
  },
  subtitle: {
    color: '#c4c6cf',
    fontSize: 12,
    textTransform: 'uppercase',
    letterSpacing: 1,
    marginTop: 8,
  },
  loginCard: {
    backgroundColor: '#1a1c1c',
    width: '100%',
    borderRadius: 12,
    padding: 24,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 10 },
    shadowOpacity: 0.5,
    shadowRadius: 20,
    elevation: 10,
  },
  cardLabel: {
    color: '#b1c7f2',
    fontSize: 10,
    fontWeight: 'bold',
    letterSpacing: 2,
    marginBottom: 16,
  },
  cardDescription: {
    color: '#c4c6cf',
    fontSize: 14,
    lineHeight: 20,
    marginBottom: 24,
  },
  authButton: {
    backgroundColor: '#b1c7f2',
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: 16,
    borderRadius: 4,
    gap: 10,
  },
  buttonDisabled: {
    opacity: 0.5,
  },
  authButtonText: {
    color: '#193053',
    fontWeight: 'bold',
    fontSize: 16,
  },
  tempCodeButton: {
    marginTop: 20,
    alignItems: 'center',
  },
  tempCodeText: {
    color: '#92d5a9',
    fontSize: 13,
    textDecorationLine: 'underline',
  },
  dividerContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginVertical: 32,
    width: '100%',
  },
  dividerLine: {
    flex: 1,
    height: 1,
    backgroundColor: 'rgba(142, 144, 153, 0.2)',
  },
  dividerText: {
    color: 'rgba(142, 144, 153, 0.4)',
    fontSize: 10,
    marginHorizontal: 16,
    letterSpacing: 2,
  },
  googleButton: {
    width: '100%',
    flexDirection: 'row',
    backgroundColor: '#282a2b',
    paddingVertical: 16,
    borderRadius: 4,
    justifyContent: 'center',
    alignItems: 'center',
    gap: 12,
    borderWidth: 1,
    borderColor: 'rgba(142, 144, 153, 0.1)',
  },
  googleButtonText: {
    color: '#e2e2e2',
    fontWeight: '600',
    fontSize: 14,
  },
  footer: {
    padding: 24,
    alignItems: 'center',
  },
  verificationBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(8, 82, 48, 0.2)',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: 'rgba(146, 213, 169, 0.3)',
    gap: 6,
  },
  verificationText: {
    color: '#81c399',
    fontSize: 9,
    fontWeight: 'bold',
    letterSpacing: 1,
  },
  versionText: {
    color: 'rgba(142, 144, 153, 0.3)',
    fontSize: 9,
    marginTop: 16,
    letterSpacing: 3,
  },
});