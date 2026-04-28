import React, { useEffect } from 'react';
import { View, ActivityIndicator, StyleSheet } from 'react-native';
import { useRouter, Redirect } from 'expo-router';
import { useSelector } from 'react-redux';
import { RootState } from '../src/store/store';

/**
 * Point d'entrée principal de l'application.
 * Ce composant décide s'il faut envoyer l'utilisateur vers le Login 
 * ou vers l'interface principale (Home).
 */
export default function Index() {
  const router = useRouter();
  
  const { isAuthenticated, isLoading } = useSelector((state: RootState) => state.auth);

  if (isLoading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#E63946" />
      </View>
    );
  }

  // Redirection automatique basée sur l'état d'authentification
  // Si l'utilisateur est authentifié, on l'envoie vers le groupe (app) -> home
  // Sinon, on l'envoie vers le groupe (auth) -> login
  if (isAuthenticated) {
    return <Redirect href="/(app)/home" />;
  }

  return <Redirect href="/(auth)/login" />;
}

const styles = StyleSheet.create({
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#fff',
  },
});