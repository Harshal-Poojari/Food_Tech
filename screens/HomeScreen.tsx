import React from 'react';
import { StyleSheet, View, Image } from 'react-native';
import { Button, Text, Card } from 'react-native-paper';
import { SafeAreaView } from 'react-native-safe-area-context';

const HomeScreen = ({ navigation }) => {
  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Food Scanner</Text>
        <Text style={styles.subtitle}>Scan food products to check ingredients</Text>
      </View>

      <Card style={styles.card}>
        <Card.Content>
          <Text style={styles.cardTitle}>How it works</Text>
          <Text style={styles.cardText}>
            1. Scan the barcode on any food product
          </Text>
          <Text style={styles.cardText}>
            2. Our app will analyze the ingredients
          </Text>
          <Text style={styles.cardText}>
            3. Get insights about what's good and what's harmful
          </Text>
        </Card.Content>
      </Card>

      <View style={styles.buttonContainer}>
        <Button
          mode="contained"
          icon="barcode-scan"
          onPress={() => navigation.navigate('Scanner')}
          style={styles.button}
          contentStyle={styles.buttonContent}
        >
          Scan Product
        </Button>

        <Button
          mode="outlined"
          icon="information-outline"
          onPress={() => navigation.navigate('About')}
          style={styles.button}
          contentStyle={styles.buttonContent}
        >
          About
        </Button>
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
    backgroundColor: '#f5f5f5',
  },
  header: {
    alignItems: 'center',
    marginVertical: 24,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#2e7d32',
  },
  subtitle: {
    fontSize: 16,
    color: '#555',
    marginTop: 8,
  },
  card: {
    marginVertical: 16,
    elevation: 4,
  },
  cardTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 12,
  },
  cardText: {
    fontSize: 16,
    marginBottom: 8,
    lineHeight: 24,
  },
  buttonContainer: {
    marginTop: 16,
  },
  button: {
    marginVertical: 8,
    borderRadius: 8,
  },
  buttonContent: {
    height: 56,
  },
});

export default HomeScreen; 