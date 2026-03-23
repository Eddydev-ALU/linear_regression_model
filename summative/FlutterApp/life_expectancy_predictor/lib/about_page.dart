import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // ── Design tokens (same as prediction page) ────────────────────────────
  static const _orange = Color(0xFFFF7A2F);
  static const _navy = Color(0xFF1B2559);
  static const _bg = Color(0xFFF5F6FA);
  static const _cardBg = Colors.white;
  static const _labelGrey = Color(0xFF8F9BB3);
  static const _green = Color(0xFF00B884);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeroCard(),
                  const SizedBox(height: 16),
                  _buildUseCaseCard(),
                  const SizedBox(height: 16),
                  _buildDatasetCard(),
                  const SizedBox(height: 16),
                  _buildModelsCard(),
                  const SizedBox(height: 16),
                  _buildFeaturesCard(),
                  const SizedBox(height: 16),
                  _buildPipelineCard(),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header with back button ────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 24, 16),
      child: Row(
        children: [
          Material(
            color: _cardBg,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE4E9F2)),
                ),
                child: Icon(Icons.arrow_back_rounded,
                    size: 20, color: _navy.withOpacity(0.7)),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'About the Model',
            style: GoogleFonts.dmSans(
                fontSize: 20, fontWeight: FontWeight.w700, color: _navy),
          ),
        ],
      ),
    );
  }

  // ── Hero Card ──────────────────────────────────────────────────────────
  Widget _buildHeroCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_navy, _navy.withOpacity(0.85)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.analytics_outlined,
                color: Colors.white, size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            'Life Expectancy\nPrediction Model',
            style: GoogleFonts.dmSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'A machine learning model that predicts the life expectancy '
            '(in years) of populations across countries using socio-economic '
            'and health-related indicators.',
            style: GoogleFonts.dmSans(
              fontSize: 13.5,
              color: Colors.white.withOpacity(0.75),
              height: 1.55,
            ),
          ),
          const SizedBox(height: 18),
          // Stat chips
          Row(
            children: [
              _heroBadge('2,938', 'Rows'),
              const SizedBox(width: 8),
              _heroBadge('20', 'Features'),
              const SizedBox(width: 8),
              _heroBadge('193', 'Countries'),
              const SizedBox(width: 8),
              _heroBadge('2000–15', 'Years'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroBadge(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
            const SizedBox(height: 2),
            Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.6))),
          ],
        ),
      ),
    );
  }

  // ── Use Case Card ──────────────────────────────────────────────────────
  Widget _buildUseCaseCard() {
    return _card(
      icon: Icons.lightbulb_outline_rounded,
      title: 'What Problem Does It Solve?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This model helps public-health organizations and NGOs '
            'prioritize interventions in countries where life expectancy '
            'is projected to be lowest.',
            style: _bodyStyle,
          ),
          const SizedBox(height: 14),
          Text('Key applications:',
              style: GoogleFonts.dmSans(
                  fontSize: 13, fontWeight: FontWeight.w700, color: _navy)),
          const SizedBox(height: 10),
          _bulletItem(Icons.vaccines_outlined,
              'Target immunization campaigns in high-risk regions'),
          const SizedBox(height: 8),
          _bulletItem(Icons.school_outlined,
              'Invest in schooling where it most impacts longevity'),
          const SizedBox(height: 8),
          _bulletItem(Icons.health_and_safety_outlined,
              'Direct HIV/AIDS program funding to countries in need'),
          const SizedBox(height: 8),
          _bulletItem(Icons.trending_up_rounded,
              'Forecast health outcomes under different policy scenarios'),
        ],
      ),
    );
  }

  // ── Dataset Card ───────────────────────────────────────────────────────
  Widget _buildDatasetCard() {
    return _card(
      icon: Icons.storage_rounded,
      title: 'About the Dataset',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The WHO Life Expectancy dataset from Kaggle contains health, '
            'economic, and social data for 193 countries spanning 2000 to 2015 '
            '(2,938 records).',
            style: _bodyStyle,
          ),
          const SizedBox(height: 14),
          _infoRow('Source', 'WHO via Kaggle'),
          _infoRow('Records', '2,938 rows × 22 columns'),
          _infoRow('Target', 'Life expectancy (years)'),
          _infoRow('Period', '2000 – 2015'),
          _infoRow('Countries', '193 (Developed & Developing)'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _labelGrey)),
          ),
          Expanded(
            child: Text(value,
                style: GoogleFonts.dmSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _navy)),
          ),
        ],
      ),
    );
  }

  // ── Models Card ────────────────────────────────────────────────────────
  Widget _buildModelsCard() {
    return _card(
      icon: Icons.model_training_rounded,
      title: 'Models Trained',
      child: Column(
        children: [
          _modelTile(
            icon: Icons.show_chart_rounded,
            name: 'Linear Regression (SGD)',
            desc: 'Gradient descent optimizer with L2 regularization, '
                '300 epochs. Good baseline for understanding linear relationships.',
          ),
          const SizedBox(height: 12),
          _modelTile(
            icon: Icons.account_tree_outlined,
            name: 'Decision Tree',
            desc: 'Max depth 10, min 5 samples per leaf. '
                'Captures non-linear patterns but prone to overfitting.',
          ),
          const SizedBox(height: 12),
          _modelTile(
            icon: Icons.forest_rounded,
            name: 'Random Forest',
            desc: '200 estimators, max depth 15. Ensemble method that '
                'reduces overfitting — selected as the best model by lowest MSE.',
            isBest: true,
          ),
        ],
      ),
    );
  }

  Widget _modelTile({
    required IconData icon,
    required String name,
    required String desc,
    bool isBest = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isBest ? _orange.withOpacity(0.06) : _bg,
        borderRadius: BorderRadius.circular(14),
        border: isBest
            ? Border.all(color: _orange.withOpacity(0.2))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isBest ? _orange.withOpacity(0.12) : _cardBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: isBest ? _orange : _navy),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(name,
                          style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _navy)),
                    ),
                    if (isBest)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _green.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('BEST',
                            style: GoogleFonts.dmSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: _green)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(desc,
                    style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: _labelGrey,
                        height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Features Card ──────────────────────────────────────────────────────
  Widget _buildFeaturesCard() {
    return _card(
      icon: Icons.grid_view_rounded,
      title: 'Input Features (20)',
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: const [
          _FeatureChip('Year'),
          _FeatureChip('Status'),
          _FeatureChip('Adult Mortality'),
          _FeatureChip('Infant Deaths'),
          _FeatureChip('Alcohol'),
          _FeatureChip('% Expenditure'),
          _FeatureChip('Hepatitis B'),
          _FeatureChip('Measles'),
          _FeatureChip('BMI'),
          _FeatureChip('Under-5 Deaths'),
          _FeatureChip('Polio'),
          _FeatureChip('Total Expenditure'),
          _FeatureChip('Diphtheria'),
          _FeatureChip('HIV/AIDS'),
          _FeatureChip('GDP'),
          _FeatureChip('Population'),
          _FeatureChip('Thinness 10-19 yrs'),
          _FeatureChip('Thinness 5-9 yrs'),
          _FeatureChip('Income Composition'),
          _FeatureChip('Schooling'),
        ],
      ),
    );
  }

  // ── Pipeline Card ──────────────────────────────────────────────────────
  Widget _buildPipelineCard() {
    return _card(
      icon: Icons.route_rounded,
      title: 'Training Pipeline',
      child: Column(
        children: [
          _pipelineStep('1', 'Data Cleaning',
              'Drop rows with missing target, remove Country column, encode Status to numeric, impute missing values with median.'),
          _pipelineConnector(),
          _pipelineStep('2', 'Feature Engineering',
              'Identify high-correlation features (Schooling +0.75, Income Composition +0.72, Adult Mortality −0.70). Drop or transform as needed.'),
          _pipelineConnector(),
          _pipelineStep('3', 'Standardization',
              'StandardScaler applied to all features. 80/20 train-test split with random_state=42.'),
          _pipelineConnector(),
          _pipelineStep('4', 'Model Training',
              'Train Linear Regression (SGD), Decision Tree, and Random Forest. Evaluate on MSE, MAE, and R².'),
          _pipelineConnector(),
          _pipelineStep('5', 'Best Model Saved',
              'Model with lowest test MSE is saved as best_model.pkl along with scaler and feature names.'),
        ],
      ),
    );
  }

  Widget _pipelineStep(String number, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(number,
              style: GoogleFonts.dmSans(
                  fontSize: 13, fontWeight: FontWeight.w800, color: _orange)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.dmSans(
                      fontSize: 13, fontWeight: FontWeight.w700, color: _navy)),
              const SizedBox(height: 3),
              Text(desc,
                  style: GoogleFonts.dmSans(
                      fontSize: 12, color: _labelGrey, height: 1.45)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pipelineConnector() {
    return Padding(
      padding: const EdgeInsets.only(left: 14),
      child: Container(
        width: 2,
        height: 16,
        color: _orange.withOpacity(0.2),
      ),
    );
  }

  // ── Shared helpers ─────────────────────────────────────────────────────
  Widget _card({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: _orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 17, color: _orange),
                ),
                const SizedBox(width: 10),
                Text(title,
                    style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _navy)),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _bulletItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: _green),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: _bodyStyle),
        ),
      ],
    );
  }

  TextStyle get _bodyStyle => GoogleFonts.dmSans(
      fontSize: 13, color: _labelGrey, height: 1.55);
}

// ── Feature Chip widget ──────────────────────────────────────────────────
class _FeatureChip extends StatelessWidget {
  final String label;
  const _FeatureChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE4E9F2)),
      ),
      child: Text(label,
          style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1B2559).withOpacity(0.7))),
    );
  }
}