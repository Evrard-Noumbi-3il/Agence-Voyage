import * as AuthSession from 'expo-auth-session';
import * as SecureStore from 'expo-secure-store';
import * as WebBrowser from 'expo-web-browser';
import { useDispatch } from 'react-redux';
import { setTokens, setLoading, logout } from './authSlice';
import { AppDispatch } from '../../store/store';
import { jwtDecode } from 'jwt-decode';
import apiClient from '../../api/client';
import { useSelector } from 'react-redux';
import { RootState } from '../../store/store';

// Nécessaire pour que le navigateur se ferme proprement après auth
WebBrowser.maybeCompleteAuthSession();

const PC_IP = '192.168.1.89';
const KEYCLOAK_URL = `http://${PC_IP}:8081/realms/adv-dev`;



const discovery = {
  authorizationEndpoint: `${KEYCLOAK_URL}/protocol/openid-connect/auth`,
  tokenEndpoint: `${KEYCLOAK_URL}/protocol/openid-connect/token`,
  revocationEndpoint: `${KEYCLOAK_URL}/protocol/openid-connect/logout`,
};

const CLIENT_ID = 'adv-mobile';

// Clés SecureStore
const KEY_ACCESS_TOKEN = 'adv_access_token';
const KEY_REFRESH_TOKEN = 'adv_refresh_token';

interface KeycloakJwt {
  sub: string;
  realm_access?: { roles: string[] };
}

export function useAuth() {
  const dispatch = useDispatch<AppDispatch>();
  const redirectUri = 'com.adv.app://callback';
  const { accessToken } = useSelector((state: RootState) => state.auth);

  const [request, response, promptAsync] = AuthSession.useAuthRequest(
    {
      clientId: CLIENT_ID,
      redirectUri,
      scopes: ['openid', 'profile', 'email', 'offline_access'],
      usePKCE: true,
    },
    discovery
  );

  async function syncUserProfile(token: string) {
    try {
      console.log("[AUTH] Synchronisation du profil avec le backend...");
      const syncResponse = await fetch(`http://${PC_IP}:8080/api/auth/sync`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
      });

      if (!syncResponse.ok) {
        throw new Error(`Erreur synchro: ${syncResponse.status}`);
      }
      
      const userData = await syncResponse.json();
      console.log("[AUTH] Profil synchronisé dans Postgres :", userData.email);
      return true;
    } catch (error) {
      console.error("[AUTH] Échec de la synchronisation Postgres :", error);
      // On retourne false mais on ne bloque pas forcément l'app 
      // sauf si ton métier l'exige
      return false;
    }
  }

  // Appelé après le retour de Keycloak
  async function handleAuthResponse() {
    if (response?.type !== 'success') return;
    console.log("Tentative d'échange pour le code :", response.params.code);
    dispatch(setLoading(true));

    try {
      const tokenResponse = await AuthSession.exchangeCodeAsync(
        {
          clientId: CLIENT_ID,
          code: response.params.code,
          redirectUri,
          extraParams: {
            code_verifier: request?.codeVerifier || '',
          },
        },
        discovery
      );

      const accessToken = tokenResponse.accessToken;
      const refreshToken = tokenResponse.refreshToken ?? '';

      const isSynced = await syncUserProfile(accessToken);

      if (!isSynced) {
        console.warn("[AUTH] Attention: L'utilisateur n'est pas synchronisé en base locale.");
      }
      // Décoder le JWT pour extraire sub et role
      const decoded = jwtDecode<KeycloakJwt>(accessToken);

      const utilisateurId = decoded.sub;
      const roles = decoded.realm_access?.roles ?? [];
      // On prend le premier rôle métier (VOYAGEUR, AGENT_AGENCE, etc.)
      const role = roles.find((r) =>
        ['VOYAGEUR', 'CHAUFFEUR', 'AGENT_AGENCE', 'ADMIN'].includes(r)
      ) ?? 'VOYAGEUR';

      // Stockage sécurisé
      await SecureStore.setItemAsync(KEY_ACCESS_TOKEN, accessToken);
      await SecureStore.setItemAsync(KEY_REFRESH_TOKEN, refreshToken);

      dispatch(setTokens({ accessToken, refreshToken, utilisateurId, role }));
      console.log('[AUTH] Issuer dans le token:', (decoded as any).iss);
      console.log('[AUTH] Sub:', decoded.sub);
      console.log('[AUTH] Roles:', decoded.realm_access?.roles);
      console.log("TOKEN REÇU AVEC SUCCÈS ! Redirection en cours...");
    } catch (error) {
      console.error('[AUTH] Échec échange token :', error);
      dispatch(setLoading(false));
    }
  }

  async function signOut(accessToken: string | null, refreshToken: string | null) {
    try {
      if (refreshToken && accessToken) {
        await apiClient.post(
          '/api/auth/logout',
          { refreshToken },
          { headers: { Authorization: `Bearer ${accessToken}` } }
        );
      }
    } catch (error) {
      console.warn('[AUTH] Révocation serveur échouée — logout local quand même');
    }

    try {
      const logoutUrl = `${discovery.revocationEndpoint}?client_id=${CLIENT_ID}&post_logout_redirect_uri=${encodeURIComponent(redirectUri)}`;
      await WebBrowser.openAuthSessionAsync(logoutUrl, redirectUri);
    } catch (e) {
      console.error("[AUTH] Échec de la fermeture de session navigateur", e);
    }

    await SecureStore.deleteItemAsync(KEY_ACCESS_TOKEN);
    await SecureStore.deleteItemAsync(KEY_REFRESH_TOKEN);
    dispatch(logout());
  }

  async function startLogin() {
    dispatch(setLoading(true)); 
    try {
      const result = await promptAsync();
      if (result.type !== 'success') {
        dispatch(setLoading(false)); 
      }
    } catch (e) {
      dispatch(setLoading(false));
    }
  }

  return {
    request,
    response,
    promptAsync,
    handleAuthResponse,
    signOut,
    redirectUri,
    startLogin,
  };
}