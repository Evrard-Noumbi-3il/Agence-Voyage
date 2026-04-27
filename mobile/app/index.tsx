import React, { useEffect, useState } from 'react';
import { StyleSheet, Text, View, ActivityIndicator } from 'react-native';
import apiClient from '../src/api/client';


export default function TestConnexion() {
  const [message, setMessage] = useState('En attente du backend...');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    apiClient.get('/api/test/hello')
      .then(response => {
        setMessage(response.data.message);
        setLoading(false);
      })
      .catch(error => {
        console.error(error);
        setMessage("Erreur de connexion : " + error.message);
        setLoading(false);
      });
  }, []);

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Test de Connexion PFE</Text>
      {loading ? (
        <ActivityIndicator size="large" color="#0000ff" />
      ) : (
        <Text style={styles.result}>{message}</Text>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#fff' },
  title: { fontSize: 20, fontWeight: 'bold', marginBottom: 20 },
  result: { fontSize: 16, color: 'green', textAlign: 'center', padding: 20 },
});