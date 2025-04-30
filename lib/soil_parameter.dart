class SoilParameters {
  static double nitrogen = 78.0;
  static double phosphorus = 36.0;
  static double potassium = 72.0;
  static double pHLevel = 6.3;
  static double moisture = 74.0;
  static double temperature = 25.0;
  static double humidity = 88.0;
  static double rainfall = 280.0;

  // Soil type as a string (Loamy, Clayey, etc.)
  static String soilType = 'Loamy'; // Default soil type as a string (Loamy)

  // Function to reset the parameters if needed
  static void reset() {
    nitrogen = 78.0;
    phosphorus = 36.0;
    potassium = 72.0;
    pHLevel = 6.3;
    moisture = 74.0;
    temperature = 25.0;
    humidity = 88.0;
    rainfall = 280.0;
    soilType = 'Loamy'; // Reset to Loamy
  }

  // Function to update the soil type
  static void updateSoilType(String newSoilType) {
    // Set the soil type directly as a string
    soilType = newSoilType;
  }

  // Function to get current soil parameters as a Map for easy passing to other functions
  static Map<String, double> getSoilParameters() {
    return {
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'pHLevel': pHLevel,
      'moisture': moisture,
      'temperature': temperature,
      'humidity': humidity,
      'rainfall': rainfall,
    };
  }

  // Function to get soil type (string) for easy comparison or display
  static String getSoilTypeString() {
    return soilType; // Directly return the soil type as a string
  }
}
