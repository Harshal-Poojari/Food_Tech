import React from 'react';
import { StyleSheet, View, ScrollView, Linking } from 'react-native';
import { Text, Card, List, Button, Divider } from 'react-native-paper';
import { SafeAreaView } from 'react-native-safe-area-context';

const AboutScreen = ({ navigation }) => {
  return (
    <SafeAreaView style={styles.container}>
      <ScrollView>
        <Card style={styles.card}>
          <Card.Title title="About Food Scanner" />
          <Card.Content>
            <Text style={styles.paragraph}>
              Food Scanner is an app designed to help you make healthier food choices by analyzing
              ingredients in packaged foods. Simply scan the barcode of any food product to get
              detailed information about its ingredients.
            </Text>
          </Card.Content>
        </Card>

        <Card style={styles.card}>
          <Card.Title title="How It Works" />
          <Card.Content>
            <List.Item
              title="Scan Barcode"
              description="Use your phone's camera to scan the barcode on any food product"
              left={props => <List.Icon {...props} icon="barcode-scan" />}
            />
            <Divider />
            <List.Item
              title="Analyze Ingredients"
              description="Our system analyzes the ingredients and identifies potentially harmful components"
              left={props => <List.Icon {...props} icon="flask" />}
            />
            <Divider />
            <List.Item
              title="Get Results"
              description="View a detailed breakdown of ingredients, categorized as safe or harmful"
              left={props => <List.Icon {...props} icon="clipboard-list" />}
            />
          </Card.Content>
        </Card>

        <Card style={styles.card}>
          <Card.Title title="Ingredient Analysis" />
          <Card.Content>
            <Text style={styles.paragraph}>
              Our app categorizes ingredients based on scientific research and nutritional guidelines.
              We identify ingredients that may be:
            </Text>
            <List.Item
              title="Harmful"
              description="Ingredients linked to health issues like artificial colors, certain preservatives, and high-fructose corn syrup"
              left={props => <List.Icon {...props} color="#c62828" icon="alert-circle" />}
            />
            <Divider />
            <List.Item
              title="Safe"
              description="Natural ingredients and nutrients that are generally recognized as beneficial or neutral"
              left={props => <List.Icon {...props} color="#2e7d32" icon="check-circle" />}
            />
            <Text style={[styles.paragraph, styles.disclaimer]}>
              Disclaimer: This app provides general information and should not replace professional
              medical advice. Always consult with a healthcare provider for specific dietary concerns.
            </Text>
          </Card.Content>
        </Card>

        <Card style={styles.card}>
          <Card.Title title="Data Sources" />
          <Card.Content>
            <Text style={styles.paragraph}>
              Our ingredient database is compiled from various sources including:
            </Text>
            <List.Item
              title="Food Databases"
              description="Open Food Facts, USDA FoodData Central"
              left={props => <List.Icon {...props} icon="database" />}
            />
            <Divider />
            <List.Item
              title="Research Studies"
              description="Peer-reviewed nutritional and food safety research"
              left={props => <List.Icon {...props} icon="book-open-page-variant" />}
            />
            <Divider />
            <List.Item
              title="Health Organizations"
              description="Guidelines from WHO, FDA, and other health authorities"
              left={props => <List.Icon {...props} icon="hospital-building" />}
            />
          </Card.Content>
        </Card>

        <View style={styles.buttonContainer}>
          <Button
            mode="contained"
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
  paragraph: {
    fontSize: 14,
    lineHeight: 22,
    marginBottom: 16,
    color: '#333',
  },
  disclaimer: {
    fontStyle: 'italic',
    color: '#666',
    marginTop: 16,
  },
  buttonContainer: {
    marginVertical: 16,
  },
  button: {
    marginVertical: 8,
    borderRadius: 8,
  },
});

export default AboutScreen; 