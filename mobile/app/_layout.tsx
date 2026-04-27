import { useEffect } from 'react';
import { Stack, useRouter, useSegments } from 'expo-router';
import { Provider, useSelector } from 'react-redux';
import { store, RootState } from '../src/store/store';

// Garde d'authentification — redirige selon le statut auth
function AuthGuard() {
  const router = useRouter();
  const segments = useSegments();
  const { isAuthenticated } = useSelector((state: RootState) => state.auth);

  useEffect(() => {
    const inAuthGroup = segments[0] === '(auth)';
    const inAppGroup = segments[0] === '(app)';

    if (!isAuthenticated && inAppGroup) {
      // Non authentifié et tente d'accéder à l'app → login
      router.replace('/(auth)/login');
    } else if (isAuthenticated && inAuthGroup) {
      // Authentifié et sur login → home
      router.replace('/(app)/home');
    }
  }, [isAuthenticated, segments, router]);

  return (
    <Stack screenOptions={{ headerShown: false }}>
      <Stack.Screen name="(auth)" />
      <Stack.Screen name="(app)" />
    </Stack>
  );
}

export default function RootLayout() {
  return (
    <Provider store={store}>
      <AuthGuard />
    </Provider>
  );
}