import React from 'react';
import { StyleSheet, View, ScrollView } from 'react-native';
import { Text, Card, Divider, List, Button, Chip } from 'react-native-paper';
import { SafeAreaView } from 'react-native-safe-area-context';

const ResultsScreen = ({ route, navigation }) => {
  const { productData } = route.params;

  // Separate ingredients into harmful and safe
  const harmfulIngredients = productData.ingredients.filter(ing => ing.harmful);
  const safeIngredients = productData.ingredients.filter(ing => !ing.harmful);

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView>
        <Card style={styles.card}>
          <Card.Title title="Product Information" />
          <Card.Content>
            <Text style={styles.productName}>{productData.name}</Text>
            <Text style={styles.barcode}>Barcode: {productData.barcode}</Text>
          </Card.Content>
        </Card>

        <Card style={[styles.card, styles.summaryCard]}>
          <Card.Title title="Ingredient Summary" />
          <Card.Content>
            <View style={styles.summaryContainer}>
              <View style={styles.summaryItem}>
                <Text style={styles.summaryCount}>{productData.ingredients.length}</Text>
                <Text style={styles.summaryLabel}>Total</Text>
              </View>
              <View style={styles.summaryItem}>
                <Text style={[styles.summaryCount, styles.safeCount]}>{safeIngredients.length}</Text>
                <Text style={styles.summaryLabel}>Safe</Text>
              </View>
              <View style={styles.summaryItem}>
                <Text style={[styles.summaryCount, styles.harmfulCount]}>{harmfulIngredients.length}</Text>
                <Text style={styles.summaryLabel}>Harmful</Text>
              </View>
            </View>
          </Card.Content>
        </Card>

        <Card style={styles.card}>
          <Card.Title title="Harmful Ingredients" />
          <Card.Content>
            {harmfulIngredients.length > 0 ? (
              harmfulIngredients.map((ingredient, index) => (
                <View key={index} style={styles.ingredientItem}>
                  <View style={styles.ingredientHeader}>
                    <Text style={styles.ingredientName}>{ingredient.name}</Text>
                    <Chip icon="alert" style={styles.harmfulChip}>Harmful</Chip>
                  </View>
                  <Text style={styles.ingredientReason}>{ingredient.reason}</Text>
                  {index < harmfulIngredients.length - 1 && <Divider style={styles.divider} />}
                </View>
              ))
            ) : (
              <Text style={styles.noIngredientsText}>No harmful ingredients found!</Text>
            )}
          </Card.Content>
        </Card>

        <Card style={styles.card}>
          <Card.Title title="Safe Ingredients" />
          <Card.Content>
            {safeIngredients.length > 0 ? (
              safeIngredients.map((ingredient, index) => (
                <View key={index} style={styles.ingredientItem}>
                  <View style={styles.ingredientHeader}>
                    <Text style={styles.ingredientName}>{ingredient.name}</Text>
                    <Chip icon="check" style={styles.safeChip}>Safe</Chip>
                  </View>
                  <Text style={styles.ingredientReason}>{ingredient.reason}</Text>
                  {index < safeIngredients.length - 1 && <Divider style={styles.divider} />}
                </View>
              ))
            ) : (
              <Text style={styles.noIngredientsText}>No safe ingredients found!</Text>
            )}
          </Card.Content>
        </Card>

        <View style={styles.buttonContainer}>
          <Button
            mode="contained"
            icon="barcode-scan"
            onPress={() => navigation.navigate('Scanner')}
            style={styles.button}
          >
            Scan Another Product
          </Button>
          <Button
            mode="outlined"
            icon="home"
            onPress={() => navigation.navigate('Home')}
            style={styles.button}
          >
            Back to Home
          </Button>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
    padding: 16,
  },
  card: {
    marginBottom: 16,
    elevation: 2,
  },
  summaryCard: {
    backgroundColor: '#f9f9f9',
  },
  productName: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  barcode: {
    fontSize: 14,
    color: '#666',
  },
  summaryContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginVertical: 8,
  },
  summaryItem: {
    alignItems: 'center',
  },
  summaryCount: {
    fontSize: 24,
    fontWeight: 'bold',
  },
  summaryLabel: {
    fontSize: 14,
    color: '#666',
  },
  safeCount: {
    color: '#2e7d32',
  },
  harmfulCount: {
    color: '#c62828',
  },
  ingredientItem: {
    marginBottom: 12,
  },
  ingredientHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 4,
  },
  ingredientName: {
    fontSize: 16,
    fontWeight: 'bold',
  },
  ingredientReason: {
    fontSize: 14,
    color: '#555',
    marginTop: 4,
  },
  harmfulChip: {
    backgroundColor: '#ffcdd2',
  },
  safeChip: {
    backgroundColor: '#c8e6c9',
  },
  divider: {
    marginVertical: 12,
  },
  noIngredientsText: {
    fontStyle: 'italic',
    color: '#666',
    textAlign: 'center',
    marginVertical: 16,
  },
  buttonContainer: {
    marginVertical: 16,
  },
  button: {
    marginVertical: 8,
    borderRadius: 8,
  },
});

export default ResultsScreen; 