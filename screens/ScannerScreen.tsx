import React, { useState, useEffect } from 'react';
import { StyleSheet, View, Alert } from 'react-native';
import { Text, ActivityIndicator, Button } from 'react-native-paper';
import { BarCodeScanner } from 'expo-barcode-scanner';
import { SafeAreaView } from 'react-native-safe-area-context';

const ScannerScreen = ({ navigation }) => {
  const [hasPermission, setHasPermission] = useState(null);
  const [scanned, setScanned] = useState(false);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    (async () => {
      const { status } = await BarCodeScanner.requestPermissionsAsync();
      setHasPermission(status === 'granted');
    })();
  }, []);

  const handleBarCodeScanned = async ({ type, data }) => {
    setScanned(true);
    setLoading(true);
    
    try {
      // In a real app, you would fetch product data from an API using the barcode
      // For this template, we'll simulate a response with mock data
      setTimeout(() => {
        // Mock product data
        const productData = {
          name: "Sample Cereal",
          barcode: data,
          ingredients: [
            { name: "Sugar", harmful: true, reason: "High in added sugars" },
            { name: "Whole Grain Wheat", harmful: false, reason: "Good source of fiber" },
            { name: "Corn Syrup", harmful: true, reason: "Processed sweetener linked to obesity" },
            { name: "Vitamin D", harmful: false, reason: "Essential vitamin for bone health" },
            { name: "Artificial Color (Yellow 5)", harmful: true, reason: "Synthetic dye linked to hyperactivity" }
          ]
        };
        
        setLoading(false);
        navigation.navigate('Results', { productData });
      }, 1500);
    } catch (error) {
      setLoading(false);
      Alert.alert(
        "Error",
        "Failed to retrieve product information. Please try again.",
        [{ text: "OK", onPress: () => setScanned(false) }]
      );
    }
  };

  if (hasPermission === null) {
    return (
      <View style={styles.container}>
        <Text>Requesting camera permission...</Text>
      </View>
    );
  }

  if (hasPermission === false) {
    return (
      <View style={styles.container}>
        <Text>No access to camera</Text>
        <Button 
          mode="contained" 
          onPress={() => navigation.goBack()}
          style={styles.button}
        >
          Go Back
        </Button>
      </View>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      {loading ? (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#2e7d32" />
          <Text style={styles.loadingText}>Analyzing product...</Text>
        </View>
      ) : (
        <>
          <BarCodeScanner
            onBarCodeScanned={scanned ? undefined : handleBarCodeScanned}
            style={styles.scanner}
          />
          <View style={styles.overlay}>
            <View style={styles.scannerFrame} />
            <Text style={styles.instructions}>
              Position the barcode within the frame
            </Text>
          </View>
          
          {scanned && (
            <Button 
              mode="contained" 
              onPress={() => setScanned(false)}
              style={styles.button}
            >
              Scan Again
            </Button>
          )}
        </>
      )}
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  scanner: {
    ...StyleSheet.absoluteFillObject,
  },
  overlay: {
    ...StyleSheet.absoluteFillObject,
    justifyContent: 'center',
    alignItems: 'center',
  },
  scannerFrame: {
    width: 250,
    height: 250,
    borderWidth: 2,
    borderColor: '#2e7d32',
    backgroundColor: 'transparent',
    borderRadius: 16,
  },
  instructions: {
    position: 'absolute',
    bottom: 120,
    left: 0,
    right: 0,
    textAlign: 'center',
    color: 'white',
    backgroundColor: 'rgba(0,0,0,0.7)',
    padding: 16,
    fontSize: 16,
  },
  button: {
    position: 'absolute',
    bottom: 50,
    width: '80%',
    borderRadius: 8,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    marginTop: 16,
    fontSize: 16,
  },
});

export default ScannerScreen; 