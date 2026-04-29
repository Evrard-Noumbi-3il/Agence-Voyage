import * as AuthSession from 'expo-auth-session';
import * as SecureStore from 'expo-secure-store';
import * as WebBrowser from 'expo-web-browser';
import { useDispatch } from 'react-redux';
import { setTokens, setLoading, logout } from './authSlice';
import { AppDispatch } from '../../store/store';
import { jwtDecode } from 'jwt-decode';

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
 // const redirectUri = AuthSession.makeRedirectUri({
  //  scheme: 'com.adv.app',
  //  path: 'callback'
  // });
  console.log("Ma Redirect URI envoyée :", redirectUri);
  const [request, response, promptAsync] = AuthSession.useAuthRequest(
    {
      clientId: CLIENT_ID,
      redirectUri,
      scopes: ['openid', 'profile', 'email', 'offline_access'],
      usePKCE: true,
    },
    discovery
  );

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
      console.log("TOKEN REÇU AVEC SUCCÈS ! Redirection en cours...");
    } catch (error) {
      console.error('[AUTH] Échec échange token :', error);
      dispatch(setLoading(false));
    }
  }

  async function signOut() {
    await SecureStore.deleteItemAsync(KEY_ACCESS_TOKEN);
    await SecureStore.deleteItemAsync(KEY_REFRESH_TOKEN);
    dispatch(logout());
  }

  return {
    request,
    response,
    promptAsync,
    handleAuthResponse,
    signOut,
    redirectUri,
  };
}