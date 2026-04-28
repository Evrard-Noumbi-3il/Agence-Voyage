import React from 'react';
import { 
  View, 
  Text, 
  StyleSheet, 
  ScrollView, 
  Image, 
  TouchableOpacity, 
  TextInput,
  SafeAreaView,
  StatusBar
} from 'react-native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';

export default function HomeScreen() {
  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="light-content" />
      
      {/* HEADER */}
      <View style={styles.header}>
        <View style={styles.headerLeft}>
          <MaterialCommunityIcons name="bus-side" size={28} color="#b1c7f2" />
          <Text style={styles.headerTitle}>GENERAL EXPRESS</Text>
        </View>
        <TouchableOpacity style={styles.profileCircle}>
          <Image 
            source={{ uri: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100' }} 
            style={styles.profileImg} 
          />
        </TouchableOpacity>
      </View>

      <ScrollView contentContainerStyle={styles.scrollContent}>
        
        {/* HERO SECTION */}
        <View style={styles.heroSection}>
          <Image 
            source={{ uri: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=800' }} 
            style={styles.heroBg}
            blurRadius={2}
          />
          <LinearGradient
            colors={['transparent', '#121414']}
            style={styles.heroOverlay}
          />
          <View style={styles.heroTextContainer}>
            <Text style={styles.heroTitle}>
              Premium Journeys, {'\n'}
              <Text style={{ color: '#b1c7f2' }}>Institutional Trust.</Text>
            </Text>
            <Text style={styles.heroSubtitle}>
              Book your next inter-city voyage with Cameroon's most reliable transport network.
            </Text>
          </View>

          {/* SEARCH FORM */}
          <View style={styles.searchCard}>
            <View style={styles.inputGroup}>
              <Text style={styles.inputLabel}>DEPARTURE</Text>
              <View style={styles.inputRow}>
                <MaterialCommunityIcons name="map-marker" size={16} color="#b1c7f2" />
                <TextInput placeholder="Douala" placeholderTextColor="#6f84ac" style={styles.textInput} />
              </View>
            </View>
            
            <View style={[styles.inputGroup, styles.borderVertical]}>
              <Text style={styles.inputLabel}>ARRIVAL</Text>
              <View style={styles.inputRow}>
                <MaterialCommunityIcons name="navigation" size={16} color="#b1c7f2" />
                <TextInput placeholder="Yaoundé" placeholderTextColor="#6f84ac" style={styles.textInput} />
              </View>
            </View>

            <TouchableOpacity style={styles.searchButton}>
              <Text style={styles.searchButtonText}>SEARCH VOYAGES</Text>
              <MaterialCommunityIcons name="arrow-right" size={20} color="#193053" />
            </TouchableOpacity>
          </View>
        </View>

        {/* ACTIVE TICKETS */}
        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>Active Tickets</Text>
          <TouchableOpacity>
            <Text style={styles.viewAll}>View All</Text>
          </TouchableOpacity>
        </View>

        {/* MAIN TICKET */}
        <View style={styles.mainTicket}>
          <View style={styles.premiumBadge}>
            <Text style={styles.premiumText}>PREMIUM CLASS</Text>
          </View>
          
          <View style={styles.ticketRoute}>
            <View>
              <Text style={styles.cityCode}>DLA</Text>
              <Text style={styles.cityName}>Douala Agency</Text>
            </View>
            <View style={styles.busDivider}>
              <View style={styles.dashedLine} />
              <MaterialCommunityIcons name="bus" size={24} color="#b1c7f2" />
              <View style={styles.dashedLine} />
            </View>
            <View style={{ alignItems: 'flex-end' }}>
              <Text style={styles.cityCode}>YAO</Text>
              <Text style={styles.cityName}>Yaoundé Mvan</Text>
            </View>
          </View>

          <View style={styles.ticketDetails}>
            <View>
              <Text style={styles.detailLabel}>DATE</Text>
              <Text style={styles.detailValue}>Oct 24, 2023</Text>
            </View>
            <View>
              <Text style={styles.detailLabel}>SEAT</Text>
              <Text style={styles.detailValue}>A-12</Text>
            </View>
            <View>
              <Text style={styles.detailLabel}>REFERENCE</Text>
              <Text style={[styles.detailValue, { color: '#b1c7f2' }]}>GE-992381</Text>
            </View>
          </View>
        </View>

        {/* SERVICES */}
        <View style={styles.servicesGrid}>
          <View style={styles.serviceItem}>
            <View style={styles.serviceIconBg}>
              <MaterialCommunityIcons name="shield-check" size={24} color="#b1c7f2" />
            </View>
            <Text style={styles.serviceTitle}>Secure Transit</Text>
          </View>
          <View style={styles.serviceItem}>
            <View style={styles.serviceIconBg}>
              <MaterialCommunityIcons name="package-variant-closed" size={24} color="#b1c7f2" />
            </View>
            <Text style={styles.serviceTitle}>Cargo Tracking</Text>
          </View>
        </View>

      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#121414',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    height: 60,
    backgroundColor: '#121414',
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(226, 226, 222, 0.1)',
  },
  headerLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  headerTitle: {
    color: '#D4AF37',
    fontSize: 18,
    fontWeight: '800',
    letterSpacing: -0.5,
  },
  profileCircle: {
    width: 35,
    height: 35,
    borderRadius: 17.5,
    borderWidth: 1,
    borderColor: '#b1c7f2',
    overflow: 'hidden',
  },
  profileImg: {
    width: '100%',
    height: '100%',
  },
  scrollContent: {
    paddingBottom: 40,
  },
  heroSection: {
    height: 450,
    width: '100%',
    position: 'relative',
    padding: 20,
    justifyContent: 'flex-end',
  },
  heroBg: {
    ...StyleSheet.absoluteFillObject,
    opacity: 0.4,
  },
  heroOverlay: {
    ...StyleSheet.absoluteFillObject,
  },
  heroTextContainer: {
    marginBottom: 20,
  },
  heroTitle: {
    color: '#e2e2e2',
    fontSize: 32,
    fontWeight: '800',
    lineHeight: 38,
  },
  heroSubtitle: {
    color: '#c4c6cf',
    fontSize: 16,
    marginTop: 10,
    lineHeight: 22,
  },
  searchCard: {
    backgroundColor: '#1a1c1c',
    borderRadius: 16,
    padding: 4,
    borderWidth: 1,
    borderColor: 'rgba(142, 144, 153, 0.15)',
  },
  inputGroup: {
    padding: 16,
  },
  inputLabel: {
    fontSize: 10,
    color: '#b1c7f2',
    fontWeight: 'bold',
    marginBottom: 4,
  },
  inputRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  textInput: {
    color: '#e2e2e2',
    fontSize: 16,
    flex: 1,
  },
  borderVertical: {
    borderTopWidth: 1,
    borderBottomWidth: 1,
    borderColor: 'rgba(68, 71, 78, 0.2)',
  },
  searchButton: {
    backgroundColor: '#b1c7f2',
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    padding: 18,
    borderRadius: 12,
    marginTop: 4,
    gap: 10,
  },
  searchButtonText: {
    color: '#193053',
    fontWeight: 'bold',
    fontSize: 14,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    marginTop: 30,
    marginBottom: 15,
  },
  sectionTitle: {
    color: '#e2e2e2',
    fontSize: 22,
    fontWeight: 'bold',
  },
  viewAll: {
    color: '#b1c7f2',
    fontSize: 14,
  },
  mainTicket: {
    backgroundColor: '#282a2b',
    marginHorizontal: 20,
    borderRadius: 20,
    padding: 24,
    position: 'relative',
  },
  premiumBadge: {
    backgroundColor: '#085230',
    alignSelf: 'flex-start',
    paddingHorizontal: 12,
    paddingVertical: 4,
    borderRadius: 20,
    marginBottom: 20,
  },
  premiumText: {
    color: '#81c399',
    fontSize: 10,
    fontWeight: 'bold',
  },
  ticketRoute: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 30,
  },
  cityCode: {
    color: '#e2e2e2',
    fontSize: 28,
    fontWeight: '800',
  },
  cityName: {
    color: '#c4c6cf',
    fontSize: 12,
  },
  busDivider: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 15,
  },
  dashedLine: {
    flex: 1,
    height: 1,
    borderStyle: 'dashed',
    borderWidth: 1,
    borderColor: 'rgba(196, 198, 207, 0.3)',
  },
  ticketDetails: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    borderTopWidth: 1,
    borderTopColor: 'rgba(68, 71, 78, 0.3)',
    paddingTop: 20,
  },
  detailLabel: {
    color: 'rgba(196, 198, 207, 0.6)',
    fontSize: 10,
    fontWeight: 'bold',
  },
  detailValue: {
    color: '#e2e2e2',
    fontSize: 14,
    fontWeight: 'bold',
    marginTop: 4,
  },
  servicesGrid: {
    flexDirection: 'row',
    paddingHorizontal: 20,
    marginTop: 30,
    gap: 15,
  },
  serviceItem: {
    flex: 1,
    backgroundColor: '#1a1c1c',
    padding: 20,
    borderRadius: 16,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: 'rgba(142, 144, 153, 0.1)',
  },
  serviceIconBg: {
    backgroundColor: '#001b3d',
    padding: 12,
    borderRadius: 12,
    marginBottom: 10,
  },
  serviceTitle: {
    color: '#e2e2e2',
    fontSize: 14,
    fontWeight: 'bold',
    textAlign: 'center',
  }
});