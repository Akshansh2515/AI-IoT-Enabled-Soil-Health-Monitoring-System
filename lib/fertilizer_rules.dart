import 'package:shm/soil_parameter.dart'; // Import your soil parameters

class FertilizerRule {
  // This method compares soil parameters with crop requirements and gives fertilizer recommendation
  static String getRecommendation(Map<String, dynamic> cropData) {
    double nitrogen = cropData['nitrogen'];
    double phosphorus = cropData['phosphorus'];
    double potassium = cropData['potassium'];
    double temperature = cropData['temperature'];
    String soilType = cropData['soilType'];

    // Loamy soil rules
    if (soilType == 'Loamy') {
      if (nitrogen < 1.5) {
        return 'Fertilizer - Urea(25kg)'; // Apply Urea for low nitrogen
      } else if (phosphorus < 1.5) {
        return 'Fertilizer - DAP(20kg)'; // Apply DAP for low phosphorus
      } else if (potassium < 2.0) {
        return 'Fertilizer - MOP(15kg)'; // Apply MOP for low potassium
      } else if (temperature < 25) {
        return 'Fertilizer - Urea(20kg)'; // Apply Urea if temperature is low
      } else {
        return 'Fertilizer - NPK(20kg)'; // Apply balanced NPK
      }
    }

    // Clayey soil rules
    else if (soilType == 'Clayey') {
      if (temperature < 20) {
        return 'Fertilizer - Urea(30kg)'; // Apply Urea to raise temperature
      } else if (nitrogen < 1.5) {
        return 'Fertilizer - Urea(20kg)'; // Apply Urea for low nitrogen
      } else if (phosphorus < 2.0) {
        return 'Fertilizer - DAP(18kg)'; // Apply DAP for low phosphorus
      } else if (potassium < 2.0) {
        return 'Fertilizer - MOP(12kg)'; // Apply MOP for low potassium
      } else {
        return 'Fertilizer - NPK(25kg)'; // Apply NPK for balanced nutrients
      }
    }

    // Sandy soil rules
    else if (soilType == 'Sandy') {
      if (nitrogen < 1.0) {
        return 'Fertilizer - Urea(18kg)'; // Apply Urea for very low nitrogen
      } else if (phosphorus < 2.5) {
        return 'Fertilizer - DAP(15kg)'; // Apply DAP for low phosphorus
      } else if (potassium < 1.5) {
        return 'Fertilizer - MOP(10kg)'; // Apply MOP for low potassium
      } else if (temperature < 25) {
        return 'Fertilizer - Urea(20kg)'; // Apply Urea for temperature control
      } else {
        return 'Fertilizer - NPK(20kg)'; // Apply balanced NPK for stable growth
      }
    }

    // Black soil rules
    else if (soilType == 'Black') {
      if (temperature < 28) {
        return 'Fertilizer - Urea(25kg)'; // Apply Urea to raise temperature
      } else if (phosphorus < 2.0) {
        return 'Fertilizer - DAP(20kg)'; // Apply DAP for phosphorus deficiency
      } else if (potassium < 2.5) {
        return 'Fertilizer - MOP(18kg)'; // Apply MOP for potassium deficiency
      } else {
        return 'Fertilizer - NPK(20kg)'; // Apply balanced NPK
      }
    }

    // Red soil rules
    else if (soilType == 'Red') {
      if (nitrogen < 1.0) {
        return 'Fertilizer - Urea(22kg)'; // Apply Urea for nitrogen deficiency
      } else if (phosphorus < 1.5) {
        return 'Fertilizer - DAP(18kg)'; // Apply DAP for phosphorus deficiency
      } else if (potassium < 2.0) {
        return 'Fertilizer - MOP(12kg)'; // Apply MOP for potassium deficiency
      } else if (temperature < 25) {
        return 'Fertilizer - Urea(20kg)'; // Apply Urea for low temperature
      } else {
        return 'Fertilizer - NPK(18kg)'; // Apply balanced NPK for overall growth
      }
    }

    // Default recommendation for unknown or mixed soil types
    return 'Fertilizer - NPK(20kg)'; // Default balanced NPK
  }

  // This method calculates the amount of fertilizer to apply
  static double calculateFertilizerAmount(
      double nitrogen, double phosphorus, double potassium) {
    return (nitrogen + phosphorus + potassium) * 0.1;
  }
}
