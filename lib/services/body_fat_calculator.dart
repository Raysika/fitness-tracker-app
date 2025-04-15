import 'dart:math';

class BodyFatCalculator {
  /// Calculates body fat percentage using the U.S. Navy formula if waist and/or neck measurements are provided.
  /// Falls back to a BMI-based estimate if the necessary measurements are missing.
  ///
  /// Parameters:
  /// - gender: 'male' or 'female'
  /// - heightCm: height in centimeters
  /// - weightKg: weight in kilograms
  /// - waistCm: waist circumference in centimeters (optional)
  /// - neckCm: neck circumference in centimeters (optional)
  /// - hipCm: hip circumference in centimeters (optional, used for women)
  /// - age: age in years (optional, used for BMI-based estimation)
  static double calculateBodyFat({
    required String gender,
    required double heightCm,
    required double weightKg,
    double? waistCm,
    double? neckCm,
    double? hipCm,
    int? age,
  }) {
    // Convert gender to lowercase for case-insensitive comparison
    gender = gender.toLowerCase();

    // Check if we can use the Navy formula (requires waist and neck measurements)
    if (waistCm != null && neckCm != null) {
      if (gender == 'female' && hipCm != null) {
        // U.S. Navy formula for women
        // 163.205×log10(waist+hip-neck) - 97.684×log10(height) - 78.387
        return 163.205 * log10(waistCm + hipCm - neckCm) -
            97.684 * log10(heightCm) -
            78.387;
      } else if (gender == 'male') {
        // U.S. Navy formula for men
        // 86.010×log10(abdomen-neck) - 70.041×log10(height) + 36.76
        return 86.010 * log10(waistCm - neckCm) -
            70.041 * log10(heightCm) +
            36.76;
      }
    }

    // Fall back to BMI-based estimate if Navy formula can't be used
    return _estimateBodyFatFromBMI(gender, heightCm, weightKg, age ?? 30);
  }

  /// Calculates body fat percentage based on BMI, gender, and age.
  /// This is a simpler fallback calculation when all measurements aren't available.
  static double _estimateBodyFatFromBMI(
      String gender, double heightCm, double weightKg, int age) {
    // Calculate BMI
    double heightM = heightCm / 100; // Convert cm to meters
    double bmi = weightKg / (heightM * heightM);

    // Apply different formulas based on gender
    if (gender == 'male') {
      // Adult male formula
      // (1.20 × BMI) + (0.23 × Age) - 16.2
      return (1.20 * bmi) + (0.23 * age) - 16.2;
    } else {
      // Adult female formula
      // (1.20 × BMI) + (0.23 × Age) - 5.4
      return (1.20 * bmi) + (0.23 * age) - 5.4;
    }
  }

  /// Helper method to calculate log base 10
  static double log10(double x) {
    return log(x) / ln10;
  }

  /// Interprets body fat percentage and returns a category
  static String getBodyFatCategory(String gender, double bodyFatPercentage) {
    gender = gender.toLowerCase();

    if (gender == 'male') {
      if (bodyFatPercentage < 6) return 'Essential Fat';
      if (bodyFatPercentage < 14) return 'Athletic';
      if (bodyFatPercentage < 18) return 'Fitness';
      if (bodyFatPercentage < 25) return 'Average';
      return 'Obese';
    } else {
      if (bodyFatPercentage < 14) return 'Essential Fat';
      if (bodyFatPercentage < 21) return 'Athletic';
      if (bodyFatPercentage < 25) return 'Fitness';
      if (bodyFatPercentage < 32) return 'Average';
      return 'Obese';
    }
  }
}
