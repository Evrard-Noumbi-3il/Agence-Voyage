// mobile/app/callback.tsx
import { useEffect } from 'react';
import { View, ActivityIndicator } from 'react-native';
import { useRouter } from 'expo-router';

export default function Callback() {
  const router = useRouter();

  useEffect(() => {
    // On redirige immédiatement vers l'index qui, lui, 
    // déclenchera la logique useAuth pour récupérer le token.
    router.replace('/');
  }, []);

  return (
    <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
      <ActivityIndicator size="large" color="#E63946" />
    </View>
  );
}