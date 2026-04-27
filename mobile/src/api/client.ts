import axios from 'axios';
import { Platform } from 'react-native';

// 1. Trouve ton adresse IP locale (Tape 'ipconfig' dans ton terminal PC)
// Remplace '192.168.x.x' par la tienne.
const PC_IP = '192.168.1.89'; 

const API_URL = Platform.select({
  // L'émulateur Android voit le PC à cette adresse spéciale
  android: `http://10.0.2.2:8080`, 
  // L'iPhone réel ou simulateur utilise l'IP locale
  ios: `http://${PC_IP}:8080`,
  default: `http://localhost:8080`,
});

const apiClient = axios.create({
  baseURL: API_URL,
  // baseURL: `http://${PC_IP}:8080`,
  timeout: 10000,
  headers: { 'Content-Type': 'application/json' }
});

export default apiClient;