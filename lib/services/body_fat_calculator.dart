import 'dart:math';

/// Body Fat Calculator that implements the U.S. Navy method and BMI-based estimation.
///
/// The U.S. Navy method was developed by Hodgdon and Beckett in 1984 and is based on
/// circumference measurements and height. The formula was designed to work with
/// measurements in inches, so this implementation converts the input values from
/// centimeters to inches before applying the formula.
///
/// References:
/// - Hodgdon JA, Beckett MB. Prediction of percent body fat for U.S. Navy men and women
///   from body circumferences and height. Naval Health Research Center, San Diego, CA, 1984.
/// - Conversion: 1 inch = 2.54 centimeters
///
/// The formulas use the following measurements:
/// - For men: Height, neck circumference, and waist circumference (at navel)
/// - For women: Height, neck circumference, waist circumference (at navel), and hip circumference
///
/// If those measurements are not available, a BMI-based estimate is used as a fallback.
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
    // Validate inputs
    if (heightCm <= 0 || weightKg <= 0) {
      throw ArgumentError("Height and weight must be positive values");
    }

    if (waistCm != null && waistCm <= 0) {
      throw ArgumentError("Waist measurement must be positive");
    }

    if (neckCm != null && neckCm <= 0) {
      throw ArgumentError("Neck measurement must be positive");
    }

    if (hipCm != null && hipCm <= 0) {
      throw ArgumentError("Hip measurement must be positive");
    }

    // Convert gender to lowercase for case-insensitive comparison
    gender = gender.toLowerCase();

    // Check if we can use the Navy formula (requires waist and neck measurements)
    if (waistCm != null && neckCm != null) {
      // Convert measurements from centimeters to inches (1 inch = 2.54 cm)
      final heightInches = heightCm / 2.54;
      final waistInches = waistCm / 2.54;
      final neckInches = neckCm / 2.54;

      // Validate measurements to prevent negative log values
      if (gender == 'female' && hipCm != null) {
        // Convert hip measurement to inches
        final hipInches = hipCm / 2.54;

        // Validate to avoid negative or zero in logarithm
        if (waistInches + hipInches - neckInches <= 0) {
          return _estimateBodyFatFromBMI(gender, heightCm, weightKg, age ?? 30);
        }

        // U.S. Navy formula for women (using inches)
        // 163.205×log10(waist+hip-neck) - 97.684×log10(height) - 78.387
        double result = 163.205 * log10(waistInches + hipInches - neckInches) -
            97.684 * log10(heightInches) -
            78.387;

        // Ensure result is within realistic range (2-45%)
        return _clampBodyFatPercentage(result);
      } else if (gender == 'male') {
        // Validate to avoid negative or zero in logarithm
        if (waistInches - neckInches <= 0) {
          return _estimateBodyFatFromBMI(gender, heightCm, weightKg, age ?? 30);
        }

        // U.S. Navy formula for men (using inches)
        // 86.010×log10(abdomen-neck) - 70.041×log10(height) + 36.76
        double result = 86.010 * log10(waistInches - neckInches) -
            70.041 * log10(heightInches) +
            36.76;

        // Ensure result is within realistic range (2-45%)
        return _clampBodyFatPercentage(result);
      }
    }

    // Fall back to BMI-based estimate if Navy formula can't be used
    return _clampBodyFatPercentage(
        _estimateBodyFatFromBMI(gender, heightCm, weightKg, age ?? 30));
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

  /// Ensures body fat percentage is within realistic range
  static double _clampBodyFatPercentage(double bodyFat) {
    if (bodyFat < 2.0) return 2.0; // Minimum essential fat
    if (bodyFat > 45.0) return 45.0; // Maximum realistic value
    return bodyFat;
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
