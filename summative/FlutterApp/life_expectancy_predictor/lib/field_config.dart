/// Represents a single input field for the prediction form.
class FieldConfig {
  final String label;
  final String apiKey; // JSON key sent to FastAPI (Python field name)
  final String hint;
  final double min;
  final double max;
  final bool isInt;
  final String group;

  const FieldConfig({
    required this.label,
    required this.apiKey,
    required this.hint,
    required this.min,
    required this.max,
    this.isInt = false,
    required this.group,
  });
}

/// All 20 fields grouped into logical sections.
/// Ranges derived from the actual WHO Life Expectancy dataset
/// (2938 rows, 2000–2015).
const List<FieldConfig> fieldConfigs = [
  // ── General ─────────────────────────────────────────────
  FieldConfig(
    label: 'Year',
    apiKey: 'Year',
    hint: 'e.g. 2014 (2000–2015)',
    min: 2000,
    max: 2015,
    isInt: true,
    group: 'General',
  ),
  FieldConfig(
    label: 'Status',
    apiKey: 'Status',
    hint: '0 = Developed, 1 = Developing',
    min: 0,
    max: 1,
    isInt: true,
    group: 'General',
  ),

  // ── Mortality ───────────────────────────────────────────
  FieldConfig(
    label: 'Adult Mortality',
    apiKey: 'Adult_Mortality',
    hint: 'per 1 000 pop (1–723)',
    min: 1,
    max: 723,
    group: 'Mortality',
  ),
  FieldConfig(
    label: 'Infant Deaths',
    apiKey: 'infant_deaths',
    hint: 'per 1 000 pop (0–1800)',
    min: 0,
    max: 1800,
    isInt: true,
    group: 'Mortality',
  ),
  FieldConfig(
    label: 'Under-5 Deaths',
    apiKey: 'under_five_deaths',
    hint: 'per 1 000 pop (0–2500)',
    min: 0,
    max: 2500,
    isInt: true,
    group: 'Mortality',
  ),
  FieldConfig(
    label: 'HIV/AIDS',
    apiKey: 'HIV_AIDS',
    hint: 'deaths per 1 000 births (0.1–50.6)',
    min: 0.1,
    max: 50.6,
    group: 'Mortality',
  ),

  // ── Immunisation ────────────────────────────────────────
  FieldConfig(
    label: 'Hepatitis B (%)',
    apiKey: 'Hepatitis_B',
    hint: '1-yr-old coverage (1–99)',
    min: 1,
    max: 99,
    group: 'Immunisation',
  ),
  FieldConfig(
    label: 'Polio (%)',
    apiKey: 'Polio',
    hint: '1-yr-old coverage (3–99)',
    min: 3,
    max: 99,
    group: 'Immunisation',
  ),
  FieldConfig(
    label: 'Diphtheria (%)',
    apiKey: 'Diphtheria',
    hint: 'DTP3 coverage (2–99)',
    min: 2,
    max: 99,
    group: 'Immunisation',
  ),
  FieldConfig(
    label: 'Measles',
    apiKey: 'Measles',
    hint: 'reported cases (0–212183)',
    min: 0,
    max: 212183,
    isInt: true,
    group: 'Immunisation',
  ),

  // ── Health & Lifestyle ──────────────────────────────────
  FieldConfig(
    label: 'BMI',
    apiKey: 'BMI',
    hint: 'avg. population BMI (1–87.3)',
    min: 1,
    max: 87.3,
    group: 'Health & Lifestyle',
  ),
  FieldConfig(
    label: 'Alcohol',
    apiKey: 'Alcohol',
    hint: 'litres per capita (0.01–17.87)',
    min: 0.01,
    max: 17.87,
    group: 'Health & Lifestyle',
  ),
  FieldConfig(
    label: 'Thinness 10-19 yrs (%)',
    apiKey: 'thinness_1_19_years',
    hint: 'prevalence (0.1–27.7)',
    min: 0.1,
    max: 27.7,
    group: 'Health & Lifestyle',
  ),
  FieldConfig(
    label: 'Thinness 5-9 yrs (%)',
    apiKey: 'thinness_5_9_years',
    hint: 'prevalence (0.1–28.6)',
    min: 0.1,
    max: 28.6,
    group: 'Health & Lifestyle',
  ),

  // ── Economic ────────────────────────────────────────────
  FieldConfig(
    label: 'GDP (USD)',
    apiKey: 'GDP',
    hint: 'per capita (1.68–119172.74)',
    min: 1.68,
    max: 119172.74,
    group: 'Economic',
  ),
  FieldConfig(
    label: '% Expenditure',
    apiKey: 'percentage_expenditure',
    hint: 'health exp as % GDP (0–19479.91)',
    min: 0,
    max: 19479.91,
    group: 'Economic',
  ),
  FieldConfig(
    label: 'Total Expenditure (%)',
    apiKey: 'Total_expenditure',
    hint: 'gov health spend (0.37–17.6)',
    min: 0.37,
    max: 17.6,
    group: 'Economic',
  ),
  FieldConfig(
    label: 'Population',
    apiKey: 'Population',
    hint: 'country pop (34–1.29 B)',
    min: 34,
    max: 1293859294,
    group: 'Economic',
  ),
  FieldConfig(
    label: 'Income Composition',
    apiKey: 'Income_composition_of_resources',
    hint: 'HDI income index (0–0.95)',
    min: 0,
    max: 0.95,
    group: 'Economic',
  ),

  // ── Education ───────────────────────────────────────────
  FieldConfig(
    label: 'Schooling (yrs)',
    apiKey: 'Schooling',
    hint: 'years of schooling (0–20.7)',
    min: 0,
    max: 20.7,
    group: 'Education',
  ),
];