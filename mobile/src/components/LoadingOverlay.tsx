import React from 'react';
import { View, Text, StyleSheet, ImageBackground, TouchableOpacity, Dimensions } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { MaterialIcons } from '@expo/vector-icons';

const { height } = Dimensions.get('window');

export const LoadingOverlay = () => {
  return (
    <View style={styles.masterContainer}>
      {/* Background Image avec Overlay Gradient */}
      <ImageBackground 
        source={{ uri: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCK9x-9A3ClAF4X4GPlksYvHxrAPp-zHqrAt4fWexgzFdXCQuX7_fNZpNPTZOuNQFpXBKJryO0tPqjEaEZ1DI56ocSq7JWqV6ouawn98GMAOjhL-YPnZEHoKJOXbvDd5xon6nqxjnu2WjTrQzy4d9JTplmvfjmx391g6d13QYCl1AYnTahZTFfmlGPcQb-b7pwXutuUAr9yZLWS1u5Jh0aCtbustNUcX5t_56UkYPsVciumty36qSckSPY3c92Dag3kV6-7diAGjRo' }}
        style={styles.background}
      >
        <LinearGradient
          colors={['rgba(0,27,61,0.85)', 'rgba(8,82,48,0.85)']}
          style={styles.gradientOverlay}
        >
          <View style={styles.content}>
            
            {/* Header / Logo */}
            <View style={styles.header}>
              <MaterialIcons name="local-shipping" size={40} color="#D4AF37" />
              <Text style={styles.logoText}>GENERAL EXPRESS</Text>
            </View>

            {/* Icone Centrale */}
            <View style={styles.iconCircleWrapper}>
              <View style={styles.iconCircle}>
                <MaterialIcons name="verified-user" size={50} color="#b1c7f2" />
              </View>
            </View>

            {/* Textes */}
            <Text style={styles.title}>Institutional Security,{"\n"}
              <Text style={styles.titleHighlight}>Personal Journey.</Text>
            </Text>
            
            <Text style={styles.description}>
              To ensure the highest standards of safety and compliance across our network, 
              your secure profile is being synchronized.
            </Text>

            {/* Info Cards */}
            <View style={styles.infoGrid}>
              <View style={styles.infoCard}>
                <MaterialIcons name="lock" size={24} color="#92d5a9" />
                <View style={styles.infoTextContainer}>
                  <Text style={styles.infoTitle}>ENCRYPTED DATA</Text>
                  <Text style={styles.infoSub}>Military-grade protection.</Text>
                </View>
              </View>
            </View>

          </View>

          {/* Footer avec bouton factice pour le style */}
          <View style={styles.footer}>
             <LinearGradient
                colors={['#b1c7f2', '#31476b']}
                start={{x: 0, y: 0}} end={{x: 1, y: 0}}
                style={styles.button}
              >
                <Text style={styles.buttonText}>SYNCHRONISATION EN COURS...</Text>
              </LinearGradient>
              <Text style={styles.poweredBy}>POWERED BY SECUREVAULT IDENTITY SYSTEMS</Text>
          </View>
        </LinearGradient>
      </ImageBackground>
      
      {/* Barre de progression en haut */}
      <View style={styles.topProgressBar} />
    </View>
  );
};

const styles = StyleSheet.create({
  masterContainer: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: '#121414',
    zIndex: 9999,
  },
  background: { flex: 1 },
  gradientOverlay: { flex: 1, paddingTop: 60, paddingHorizontal: 30 },
  content: { flex: 1, alignItems: 'center' },
  header: { flexDirection: 'row', alignItems: 'center', marginBottom: 60 },
  logoText: {
    color: '#D4AF37',
    fontSize: 22,
    fontWeight: '900',
    letterSpacing: -1,
    marginLeft: 10,
  },
  iconCircleWrapper: {
    padding: 4,
    borderRadius: 100,
    backgroundColor: 'rgba(212,175,55,0.2)',
    marginBottom: 30,
  },
  iconCircle: {
    width: 90,
    height: 90,
    backgroundColor: '#0c0f0f',
    borderRadius: 45,
    justifyContent: 'center',
    alignItems: 'center',
  },
  title: {
    color: '#e2e2e2',
    fontSize: 32,
    fontWeight: '800',
    textAlign: 'center',
    lineHeight: 38,
    marginBottom: 20,
  },
  titleHighlight: { color: '#b1c7f2' },
  description: {
    color: '#c4c6cf',
    textAlign: 'center',
    fontSize: 16,
    lineHeight: 24,
    fontWeight: '300',
    marginBottom: 40,
  },
  infoGrid: { width: '100%' },
  infoCard: {
    flexDirection: 'row',
    backgroundColor: 'rgba(26,28,28,0.6)',
    padding: 20,
    borderRadius: 8,
    alignItems: 'center',
  },
  infoTextContainer: { marginLeft: 15 },
  infoTitle: { color: '#e2e2e2', fontSize: 12, fontWeight: '800', letterSpacing: 1 },
  infoSub: { color: '#c4c6cf', fontSize: 11 },
  footer: { paddingBottom: 40 },
  button: {
    height: 56,
    borderRadius: 4,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 20,
  },
  buttonText: { color: '#001b3d', fontWeight: '800', letterSpacing: 1 },
  poweredBy: {
    color: 'rgba(226,226,226,0.3)',
    textAlign: 'center',
    fontSize: 9,
    letterSpacing: 2,
  },
  topProgressBar: {
    position: 'absolute',
    top: 0,
    height: 4,
    width: '100%',
    backgroundColor: '#b1c7f2',
  }
});