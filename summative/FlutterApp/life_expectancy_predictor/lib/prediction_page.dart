import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'about_page.dart';
import 'api_service.dart';
import 'field_config.dart';
import 'field_insights.dart';

/// The actual life expectancy for Rwanda 2014 from the WHO dataset.
const double _rwandaActual = 65.7;

class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _usingSampleData = false;
  double? _prediction;
  String? _errorMessage;
  String? _focusedFieldKey;
  bool _buttonPressed = false;

  late AnimationController _resultAnimCtrl;
  late Animation<double> _resultFadeIn;

  late AnimationController _pageAnimCtrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _bodyFade;
  late Animation<Offset> _bodySlide;

  late AnimationController _buttonPulseCtrl;
  late Animation<double> _buttonPulse;

  // ── Design tokens ──────────────────────────────────────────────────────
  static const _orange = Color(0xFFFF7A2F);
  static const _navy = Color(0xFF1B2559);
  static const _bg = Color(0xFFF5F6FA);
  static const _cardBg = Colors.white;
  static const _labelGrey = Color(0xFF8F9BB3);
  static const _green = Color(0xFF00B884);

  // ── Lifecycle ──────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    for (final f in fieldConfigs) {
      _controllers[f.apiKey] = TextEditingController();
      final node = FocusNode();
      node.addListener(() {
        if (node.hasFocus) {
          setState(() => _focusedFieldKey = f.apiKey);
        } else if (_focusedFieldKey == f.apiKey) {
          setState(() => _focusedFieldKey = null);
        }
      });
      _focusNodes[f.apiKey] = node;
    }
    _resultAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _resultFadeIn = CurvedAnimation(
      parent: _resultAnimCtrl,
      curve: Curves.easeOut,
    );

    // Page entrance animation
    _pageAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _headerFade = CurvedAnimation(
      parent: _pageAnimCtrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageAnimCtrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    _bodyFade = CurvedAnimation(
      parent: _pageAnimCtrl,
      curve: const Interval(0.25, 1.0, curve: Curves.easeOut),
    );
    _bodySlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageAnimCtrl,
      curve: const Interval(0.25, 1.0, curve: Curves.easeOut),
    ));
    _pageAnimCtrl.forward();

    // Predict button glow pulse
    _buttonPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _buttonPulse = CurvedAnimation(
      parent: _buttonPulseCtrl,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    for (final n in _focusNodes.values) {
      n.dispose();
    }
    _resultAnimCtrl.dispose();
    _pageAnimCtrl.dispose();
    _buttonPulseCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────
  Map<String, List<FieldConfig>> get _grouped {
    final map = <String, List<FieldConfig>>{};
    for (final f in fieldConfigs) {
      map.putIfAbsent(f.group, () => []).add(f);
    }
    return map;
  }

  IconData _iconForGroup(String group) {
    switch (group) {
      case 'General':
        return Icons.info_outline_rounded;
      case 'Mortality':
        return Icons.monitor_heart_outlined;
      case 'Immunisation':
        return Icons.vaccines_outlined;
      case 'Health & Lifestyle':
        return Icons.favorite_border_rounded;
      case 'Economic':
        return Icons.account_balance_outlined;
      case 'Education':
        return Icons.school_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  // ── Actions ────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    setState(() {
      _errorMessage = null;
      _prediction = null;
    });
    _resultAnimCtrl.reset();

    if (!_formKey.currentState!.validate()) {
      setState(
        () => _errorMessage = 'Please fix the highlighted fields above.',
      );
      return;
    }

    final body = <String, dynamic>{};
    for (final f in fieldConfigs) {
      final raw = _controllers[f.apiKey]!.text.trim();
      body[f.apiKey] = f.isInt ? int.parse(raw) : double.parse(raw);
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.predict(body);
      setState(() {
        _prediction = result;
        _isLoading = false;
      });
      _resultAnimCtrl.forward();
      Future.delayed(const Duration(milliseconds: 150), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
      _resultAnimCtrl.forward();
    }
  }

  void _fillSample() {
    // Real data: Rwanda 2014 from the WHO Life Expectancy dataset
    // Actual life expectancy recorded: 65.7 years
    final sample = {
      'Year': '2014',
      'Status': '1',
      'Adult_Mortality': '23',
      'infant_deaths': '12',
      'under_five_deaths': '16',
      'HIV_AIDS': '0.4',
      'Hepatitis_B': '98',
      'Polio': '98',
      'Diphtheria': '98',
      'Measles': '10',
      'BMI': '2.8',
      'Alcohol': '0.01',
      'thinness_1_19_years': '5.8',
      'thinness_5_9_years': '5.8',
      'GDP': '76.57',
      'percentage_expenditure': '7.55',
      'Total_expenditure': '7.53',
      'Population': '11345357',
      'Income_composition_of_resources': '0.488',
      'Schooling': '10.8',
    };
    for (final entry in sample.entries) {
      _controllers[entry.key]?.text = entry.value;
    }
    setState(() {
      _usingSampleData = true;
      _prediction = null;
      _errorMessage = null;
    });
    _resultAnimCtrl.reset();
  }

  void _clearAll() {
    for (final c in _controllers.values) {
      c.clear();
    }
    setState(() {
      _usingSampleData = false;
      _prediction = null;
      _errorMessage = null;
    });
    _resultAnimCtrl.reset();
  }

  // ── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _headerFade,
                  child: SlideTransition(
                    position: _headerSlide,
                    child: _buildHeader(),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    FadeTransition(
                      opacity: _bodyFade,
                      child: SlideTransition(
                        position: _bodySlide,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              for (final entry in _grouped.entries)
                                _buildSectionCard(entry.key, entry.value),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPredictButton(),
                    const SizedBox(height: 16),
                    _buildResultArea(),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: logo + 3 action buttons
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_orange, Color(0xFFFF9F5F)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _orange.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const Spacer(),
              _pillButton('About', Icons.info_outline_rounded, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutPage()),
                );
              }),
              const SizedBox(width: 8),
              _pillButton('Sample', Icons.science_outlined, _fillSample),
              const SizedBox(width: 8),
              _pillButton('Clear', Icons.refresh_rounded, _clearAll),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Life Expectancy',
            style: GoogleFonts.dmSans(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: _navy,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Predictor',
            style: GoogleFonts.dmSans(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: _orange,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter socio-economic & health indicators to predict\nlife expectancy using the WHO dataset model.',
            style: GoogleFonts.dmSans(
              fontSize: 13.5,
              color: _labelGrey,
              height: 1.5,
            ),
          ),
          // Show sample-data banner when active
          if (_usingSampleData) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _navy.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _navy.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.flag_rounded,
                    size: 16,
                    color: _navy.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Loaded: Rwanda 2014  •  Actual life expectancy: ${_rwandaActual.toStringAsFixed(1)} yrs',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _navy.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _pillButton(String label, IconData icon, VoidCallback onTap) {
    return Material(
      color: _cardBg,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE4E9F2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: _navy.withOpacity(0.6)),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _navy.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section Card ───────────────────────────────────────────────────────
  Widget _buildSectionCard(String title, List<FieldConfig> fields) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                  child: Icon(_iconForGroup(title), size: 17, color: _orange),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _navy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFieldGrid(fields),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldGrid(List<FieldConfig> fields) {
    final rows = <Widget>[];
    for (var i = 0; i < fields.length; i += 2) {
      final first = fields[i];
      final second = (i + 1 < fields.length) ? fields[i + 1] : null;
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildField(first)),
            if (second != null) ...[
              const SizedBox(width: 12),
              Expanded(child: _buildField(second)),
            ] else
              const Expanded(child: SizedBox()),
          ],
        ),
      );
      if (i + 2 < fields.length) rows.add(const SizedBox(height: 12));
    }
    return Column(children: rows);
  }

  Widget _buildField(FieldConfig f) {
    final insight = getInsight(f.apiKey);
    final isFocused = _focusedFieldKey == f.apiKey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: _controllers[f.apiKey],
          focusNode: _focusNodes[f.apiKey],
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _navy,
          ),
          decoration: InputDecoration(
            labelText: f.label,
            hintText: f.hint,
            hintStyle: GoogleFonts.dmSans(
              fontSize: 11.5,
              color: _labelGrey.withOpacity(0.6),
            ),
            isDense: true,
            // Show a small info icon if field has insight
            suffixIcon: insight != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: isFocused ? _orange : _labelGrey.withOpacity(0.4),
                    ),
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 28,
              minHeight: 28,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Required';
            final num? parsed = num.tryParse(value.trim());
            if (parsed == null) return 'Invalid number';
            if (parsed < f.min || parsed > f.max) {
              return '${f.min.toStringAsFixed(f.min == f.min.roundToDouble() ? 0 : 1)}–${f.max.toStringAsFixed(f.max == f.max.roundToDouble() ? 0 : 1)}';
            }
            if (f.isInt && parsed != parsed.roundToDouble())
              return 'Whole number only';
            return null;
          },
        ),
        // Inline insight hint — only when focused and field has insight data
        if (isFocused && insight != null) _buildInlineInsight(insight),
      ],
    );
  }

  Widget _buildInlineInsight(FieldInsight insight) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _navy.withOpacity(0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _navy.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            Text(
              insight.description,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: _navy.withOpacity(0.6),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            // Good range
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00B884),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    insight.goodLabel,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF00B884),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Poor range
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    insight.poorLabel,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Predict Button ─────────────────────────────────────────────────────
  Widget _buildPredictButton() {
    return AnimatedScale(
      scale: _buttonPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: AnimatedBuilder(
        animation: _buttonPulse,
        builder: (context, _) {
          final pulse = _isLoading ? 0.0 : _buttonPulse.value;
          return Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_orange, Color(0xFFFF9F5F)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _orange.withOpacity(0.25 + pulse * 0.28),
                  blurRadius: 10 + pulse * 14,
                  offset: const Offset(0, 4),
                  spreadRadius: pulse * 2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                splashColor: Colors.white.withOpacity(0.18),
                highlightColor: Colors.white.withOpacity(0.06),
                onTap: _isLoading ? null : _submit,
                onTapDown: _isLoading
                    ? null
                    : (_) => setState(() => _buttonPressed = true),
                onTapUp: _isLoading
                    ? null
                    : (_) => setState(() => _buttonPressed = false),
                onTapCancel: _isLoading
                    ? null
                    : () => setState(() => _buttonPressed = false),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Predict',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Result Area ────────────────────────────────────────────────────────
  Widget _buildResultArea() {
    if (_prediction == null && _errorMessage == null) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _resultFadeIn,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _prediction != null ? _cardBg : const Color(0xFFFFF0F0),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (_prediction != null ? _orange : Colors.red).withOpacity(
                0.08,
              ),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: (_prediction != null ? _orange : Colors.redAccent)
                .withOpacity(0.2),
            width: 1.2,
          ),
        ),
        child: _prediction != null
            ? _buildSuccessResult()
            : _buildErrorResult(),
      ),
    );
  }

  Widget _buildSuccessResult() {
    final double error = _usingSampleData
        ? (_prediction! - _rwandaActual).abs()
        : 0;

    return Column(
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_orange, Color(0xFFFF9F5F)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.timeline_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: 16),

        // Label
        Text(
          'Predicted Life Expectancy',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _labelGrey,
          ),
        ),
        const SizedBox(height: 6),

        // Big number
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _prediction!.toStringAsFixed(1),
              style: GoogleFonts.dmSans(
                fontSize: 44,
                fontWeight: FontWeight.w800,
                color: _navy,
                height: 1,
              ),
            ),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                'years',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _orange,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Quality badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: _resultBadgeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _qualityLabel(_prediction!),
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _resultBadgeColor,
            ),
          ),
        ),

        // ── Comparison with real value (only when sample data is used) ──
        if (_usingSampleData) ...[
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Comparison with Real Data',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rwanda, 2014 — WHO Dataset',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _labelGrey,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    // Actual
                    Expanded(
                      child: _comparisonTile(
                        label: 'Actual',
                        value: _rwandaActual.toStringAsFixed(1),
                        icon: Icons.verified_outlined,
                        color: _navy,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Predicted
                    Expanded(
                      child: _comparisonTile(
                        label: 'Predicted',
                        value: _prediction!.toStringAsFixed(1),
                        icon: Icons.auto_awesome_rounded,
                        color: _orange,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Error
                    Expanded(
                      child: _comparisonTile(
                        label: 'Error',
                        value: '±${error.toStringAsFixed(1)}',
                        icon: Icons.swap_vert_rounded,
                        color: error <= 3 ? _green : Colors.redAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Accuracy bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (1 - (error / _rwandaActual)).clamp(0, 1),
                    minHeight: 8,
                    backgroundColor: _labelGrey.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      error <= 3 ? _green : _orange,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Model accuracy: ${((1 - error / _rwandaActual) * 100).clamp(0, 100).toStringAsFixed(1)}%',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _labelGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _comparisonTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: _labelGrey,
            ),
          ),
        ],
      ),
    );
  }

  Color get _resultBadgeColor {
    if (_prediction == null) return Colors.grey;
    if (_prediction! >= 70) return _green;
    if (_prediction! >= 55) return _orange;
    return Colors.redAccent;
  }

  String _qualityLabel(double val) {
    if (val >= 75) return '● Above global average';
    if (val >= 65) return '● Near global average';
    if (val >= 55) return '● Below global average';
    return '● Critical – far below average';
  }

  Widget _buildErrorResult() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Prediction Failed',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _errorMessage ?? 'Unknown error',
                style: GoogleFonts.dmSans(
                  fontSize: 12.5,
                  color: const Color(0xFFCC4444),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
