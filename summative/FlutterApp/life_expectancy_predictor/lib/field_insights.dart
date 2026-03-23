/// Insight about what a field value means — good vs poor ranges.
class FieldInsight {
  final String fieldKey;    // matches apiKey from FieldConfig
  final String label;
  final String unit;
  final double goodThreshold;
  final double poorThreshold;
  final bool lowerIsBetter; // true = lower values are better (e.g. mortality)
  final String goodLabel;
  final String poorLabel;
  final String description;

  const FieldInsight({
    required this.fieldKey,
    required this.label,
    required this.unit,
    required this.goodThreshold,
    required this.poorThreshold,
    required this.lowerIsBetter,
    required this.goodLabel,
    required this.poorLabel,
    required this.description,
  });

  /// Returns 'good', 'moderate', or 'poor' based on value.
  String rating(double value) {
    if (lowerIsBetter) {
      if (value <= goodThreshold) return 'good';
      if (value >= poorThreshold) return 'poor';
      return 'moderate';
    } else {
      if (value >= goodThreshold) return 'good';
      if (value <= poorThreshold) return 'poor';
      return 'moderate';
    }
  }
}

/// Insights for all 20 input features.
/// Thresholds based on Q25/Q75 percentiles from the WHO dataset.
const List<FieldInsight> fieldInsights = [
  FieldInsight(
    fieldKey: 'Adult_Mortality', label: 'Adult Mortality', unit: 'per 1,000',
    goodThreshold: 74, poorThreshold: 228, lowerIsBetter: true,
    goodLabel: '≤ 74 (developed-nation level)',
    poorLabel: '≥ 228 (crisis-level mortality)',
    description: 'Deaths between ages 15–60 per 1,000 population. Countries with strong healthcare systems have rates below 74.',
  ),
  FieldInsight(
    fieldKey: 'infant_deaths', label: 'Infant Deaths', unit: 'per 1,000',
    goodThreshold: 3, poorThreshold: 22, lowerIsBetter: true,
    goodLabel: '≤ 3 (excellent neonatal care)',
    poorLabel: '≥ 22 (high infant mortality)',
    description: 'Number of infant deaths per 1,000 live births. Low-income countries often have rates above 22.',
  ),
  FieldInsight(
    fieldKey: 'under_five_deaths', label: 'Under-5 Deaths', unit: 'per 1,000',
    goodThreshold: 4, poorThreshold: 28, lowerIsBetter: true,
    goodLabel: '≤ 4 (strong child health)',
    poorLabel: '≥ 28 (inadequate child healthcare)',
    description: 'Deaths under age 5 per 1,000. Closely tied to access to vaccines, nutrition, and clean water.',
  ),
  FieldInsight(
    fieldKey: 'HIV_AIDS', label: 'HIV/AIDS', unit: 'per 1,000 births',
    goodThreshold: 0.1, poorThreshold: 0.8, lowerIsBetter: true,
    goodLabel: '≤ 0.1 (minimal impact)',
    poorLabel: '≥ 0.8 (significant burden)',
    description: 'Deaths per 1,000 live births due to HIV/AIDS (ages 0–4). Sub-Saharan Africa carries the highest burden.',
  ),
  FieldInsight(
    fieldKey: 'Hepatitis_B', label: 'Hepatitis B', unit: '% coverage',
    goodThreshold: 92, poorThreshold: 77, lowerIsBetter: false,
    goodLabel: '≥ 92% (strong immunization)',
    poorLabel: '≤ 77% (insufficient coverage)',
    description: 'HepB vaccine coverage among 1-year-olds. WHO targets 90%+ for herd immunity.',
  ),
  FieldInsight(
    fieldKey: 'Polio', label: 'Polio', unit: '% coverage',
    goodThreshold: 93, poorThreshold: 78, lowerIsBetter: false,
    goodLabel: '≥ 93% (strong immunization)',
    poorLabel: '≤ 78% (at risk of outbreaks)',
    description: 'Polio vaccine coverage among 1-year-olds. Critical for maintaining eradication.',
  ),
  FieldInsight(
    fieldKey: 'Diphtheria', label: 'Diphtheria', unit: '% coverage',
    goodThreshold: 93, poorThreshold: 78, lowerIsBetter: false,
    goodLabel: '≥ 93% (strong DTP3 coverage)',
    poorLabel: '≤ 78% (vulnerable population)',
    description: 'DTP3 immunization coverage. One of the best proxy indicators of healthcare system strength.',
  ),
  FieldInsight(
    fieldKey: 'Measles', label: 'Measles', unit: 'reported cases',
    goodThreshold: 17, poorThreshold: 360, lowerIsBetter: true,
    goodLabel: '≤ 17 cases (well-controlled)',
    poorLabel: '≥ 360 cases (outbreaks likely)',
    description: 'Reported measles cases per 1,000 population. High numbers indicate vaccine gaps.',
  ),
  FieldInsight(
    fieldKey: 'BMI', label: 'BMI', unit: 'avg.',
    goodThreshold: 43.5, poorThreshold: 19.3, lowerIsBetter: false,
    goodLabel: '≥ 43.5 (adequate nutrition)',
    poorLabel: '≤ 19.3 (widespread malnutrition)',
    description: 'Average BMI of entire population. Very low values signal malnutrition; this is a population-level metric, not individual.',
  ),
  FieldInsight(
    fieldKey: 'Alcohol', label: 'Alcohol', unit: 'litres/capita',
    goodThreshold: 3.75, poorThreshold: 7.7, lowerIsBetter: true,
    goodLabel: '≤ 3.75 L (moderate consumption)',
    poorLabel: '≥ 7.7 L (high consumption)',
    description: 'Per-capita alcohol consumption (age 15+). High consumption is linked to liver disease and accidents.',
  ),
  FieldInsight(
    fieldKey: 'thinness_1_19_years', label: 'Thinness 10-19 yrs', unit: '%',
    goodThreshold: 1.6, poorThreshold: 7.2, lowerIsBetter: true,
    goodLabel: '≤ 1.6% (low malnutrition)',
    poorLabel: '≥ 7.2% (significant malnutrition)',
    description: 'Prevalence of thinness among adolescents. Reflects chronic food insecurity.',
  ),
  FieldInsight(
    fieldKey: 'thinness_5_9_years', label: 'Thinness 5-9 yrs', unit: '%',
    goodThreshold: 1.5, poorThreshold: 7.2, lowerIsBetter: true,
    goodLabel: '≤ 1.5% (low malnutrition)',
    poorLabel: '≥ 7.2% (significant malnutrition)',
    description: 'Prevalence of thinness among children 5–9. Early-childhood indicator of nutrition programs.',
  ),
  FieldInsight(
    fieldKey: 'GDP', label: 'GDP', unit: 'USD/capita',
    goodThreshold: 5910, poorThreshold: 463, lowerIsBetter: false,
    goodLabel: '≥ \$5,910 (upper-middle income)',
    poorLabel: '≤ \$463 (low income)',
    description: 'Gross domestic product per capita. Higher GDP enables better healthcare infrastructure.',
  ),
  FieldInsight(
    fieldKey: 'percentage_expenditure', label: '% Expenditure', unit: '% GDP',
    goodThreshold: 441, poorThreshold: 4.7, lowerIsBetter: false,
    goodLabel: '≥ 441 (strong health investment)',
    poorLabel: '≤ 4.7 (minimal health spending)',
    description: 'Health expenditure as percentage of GDP per capita. Higher spending correlates with better outcomes.',
  ),
  FieldInsight(
    fieldKey: 'Total_expenditure', label: 'Total Expenditure', unit: '%',
    goodThreshold: 7.49, poorThreshold: 4.26, lowerIsBetter: false,
    goodLabel: '≥ 7.5% (prioritized health)',
    poorLabel: '≤ 4.3% (underfunded health)',
    description: 'Government health expenditure as % of total government expenditure.',
  ),
  FieldInsight(
    fieldKey: 'Income_composition_of_resources', label: 'Income Composition', unit: 'HDI',
    goodThreshold: 0.78, poorThreshold: 0.49, lowerIsBetter: false,
    goodLabel: '≥ 0.78 (high human development)',
    poorLabel: '≤ 0.49 (low human development)',
    description: 'Human Development Index income component (0–1). Captures standard of living beyond just GDP.',
  ),
  FieldInsight(
    fieldKey: 'Schooling', label: 'Schooling', unit: 'years',
    goodThreshold: 14.3, poorThreshold: 10.1, lowerIsBetter: false,
    goodLabel: '≥ 14.3 yrs (strong education)',
    poorLabel: '≤ 10.1 yrs (limited education)',
    description: 'Expected years of schooling. Strongest single predictor of life expectancy in the dataset.',
  ),
];

/// Look up insight by field key.
FieldInsight? getInsight(String fieldKey) {
  for (final i in fieldInsights) {
    if (i.fieldKey == fieldKey) return i;
  }
  return null;
}