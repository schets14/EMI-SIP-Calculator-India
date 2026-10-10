import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'emi_screen.dart';
import 'sip_screen.dart';
import 'gst_screen.dart';
import 'prepayment_screen.dart';
import 'step_up_sip_screen.dart';
import 'extra_calculators_screen.dart';
import 'settings_screen.dart';
import 'decision_center_screen.dart';
import 'search_screen.dart';
import 'saved_plans_screen.dart';
import 'reminders_screen.dart';
import 'financial_health_screen.dart';
import 'history_screen.dart';
import 'favorites_screen.dart';
import 'planning_hub_screen.dart';
import 'sip_swp_screen.dart';
import 'cash_counter_screen.dart';
import 'interest_rate_screen.dart';
import '../services/app_strings.dart';
import '../widgets/ad_banner.dart';
import '../services/local_store.dart';
import '../models/user_planning_models.dart';
import '../models/calculation_record.dart';
import '../utils/formatters.dart';

class _HomeFeature {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final VoidCallback onTap;
  final String badge;

  const _HomeFeature(
    this.icon,
    this.title,
    this.subtitle,
    this.colors,
    this.onTap,
    this.badge,
  );
}

class HomeScreen extends StatefulWidget {
  final String language;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<ThemeMode>? onThemeModeChanged;
  final ThemeMode themeMode;
  const HomeScreen({super.key, required this.language, required this.onLanguageChanged, this.onThemeModeChanged, required this.themeMode});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _open(Widget page) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, animation, __) => page,
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, .035),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.language);
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildNavigationDrawer(s),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
            children: [
              _header(s),
              const SizedBox(height: 18),
              _homeHero(s),
              const SizedBox(height: 18),
              _sectionTitle('Popular Calculators', 'Your most-used money calculations'),
              const SizedBox(height: 11),
              _primaryCalculatorGrid(),
              const SizedBox(height: 18),
              _sectionTitle('Featured Tools', 'Important tools from the menu, right here on Home'),
              const SizedBox(height: 11),
              _featuredHomeTools(),
              const SizedBox(height: 18),
              _sectionTitle('Quick Tools', 'Useful tools without cluttering Home'),
              const SizedBox(height: 11),
              _quickToolRow(),
              const SizedBox(height: 18),
              _personalDashboard(),
              const SizedBox(height: 14),
              const FinanceBannerAd(),
              const SizedBox(height: 14),
              _recentAndPlanningRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _homeHero(AppStrings s) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = Curves.easeOutCubic.transform(_controller.value);
    return Transform.translate(
      offset: Offset(0, 12 * (1 - t)),
      child: Opacity(
        opacity: t.clamp(0, 1),
        child: Container(
          padding: const EdgeInsets.fromLTRB(19, 20, 19, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(27),
            gradient: LinearGradient(
              colors: Theme.of(context).brightness == Brightness.dark
                  ? const [Color(0xFF0A0A0A), Color(0xFF111111)]
                  : const [Color(0xFFF1F5F9), Color(0xFFF7F8FA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: AppTheme.primary.withValues(alpha: .10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Smart money tools', style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w800,
                      color: AppTheme.primary.withValues(alpha: .9),
                    )),
                    const SizedBox(height: 5),
                    Text(AppStrings.translate(context, 'Calculate before you commit.'), style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w900,
                      height: 1.08,
                      color: Theme.of(context).colorScheme.onSurface,
                    )),
                    const SizedBox(height: 7),
                    Text(AppStrings.translate(context, 'Loans, investments, GST and everyday finance tools in one place.'),
                      style: TextStyle(
                        fontSize: 12, height: 1.4,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .62),
                      )),
                  ]),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 58, height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(19),
                    gradient: LinearGradient(
                      colors: isDark
                          ? const [Color(0xFF1D4ED8), Color(0xFF3B82F6)]
                          : const [AppTheme.primary, AppTheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [BoxShadow(
                      color: AppTheme.primary.withValues(alpha: .20),
                      blurRadius: 20, offset: const Offset(0, 8),
                    )],
                  ),
                  child: const Icon(Icons.calculate_rounded, color: Colors.white, size: 29),
                ),
              ]),
              const SizedBox(height: 15),
              Row(children: [
                Expanded(child: _heroAction(Icons.search_rounded, 'Find a calculator',
                    () => _open(const SearchScreen()))),
                const SizedBox(width: 9),
                Expanded(child: _heroAction(Icons.bookmark_outline_rounded, 'My plans',
                    () => _open(const SavedPlansScreen()))),
              ]),
            ],
          ),
        ),
      ),
    );
  }


  Widget _heroAction(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Theme.of(context).cardColor.withValues(alpha: .86),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primary),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _primaryCalculatorGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.48,
      children: [
        _primaryCard(Icons.account_balance_rounded, 'EMI Calculator',
            'Loan EMI & interest', const [Color(0xFF2563EB), Color(0xFF3B82F6)],
            () => _open(const EmiScreen())),
        _primaryCard(Icons.auto_graph_rounded, 'SIP Calculator',
            'Returns & wealth', const [Color(0xFF10B981), Color(0xFF14B8A6)],
            () => _open(const SipScreen())),
        _primaryCard(Icons.payments_rounded, 'Prepayment',
            'Save loan interest', const [Color(0xFF0F766E), Color(0xFF14B8A6)],
            () => _open(const PrepaymentScreen())),
        _primaryCard(Icons.receipt_long_rounded, 'GST Calculator',
            'Add or remove GST', const [Color(0xFFD97706), Color(0xFFF59E0B)],
            () => _open(const GstScreen())),
      ],
    );
  }

  Widget _primaryCard(IconData icon, String title, String subtitle,
      List<Color> colors, VoidCallback onTap) {
    final index = ['EMI Calculator', 'SIP Calculator', 'Prepayment', 'GST Calculator'].indexOf(title);
    final delay = 120 + (index < 0 ? 0 : index * 90);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) => Opacity(
        opacity: progress,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - progress)),
          child: child,
        ),
      ),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(21),
        child: InkWell(
          borderRadius: BorderRadius.circular(21),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 39, height: 39,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    gradient: LinearGradient(colors: colors),
                  ),
                  child: Icon(icon, color: Colors.white, size: 21),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_rounded, size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .35)),
              ]),
              const Spacer(),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10.5, color: AppTheme.muted)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _featuredHomeTools() {
    final tools = <_HomeFeature>[
      _HomeFeature(
        Icons.trending_up_rounded,
        'Step-up SIP',
        'Grow your SIP every year',
        const [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
        () => _open(const StepUpSipScreen()),
        'POPULAR',
      ),
      _HomeFeature(
        Icons.payments_rounded,
        'Loan Prepayment',
        'See interest you can save',
        const [Color(0xFF0F766E), Color(0xFF14B8A6)],
        () => _open(const PrepaymentScreen()),
        'SAVE',
      ),
      _HomeFeature(
        Icons.swap_vert_rounded,
        'SIP & SWP',
        'Build and withdraw from wealth',
        const [Color(0xFF2563EB), Color(0xFF06B6D4)],
        () => _open(const SipSwpScreen()),
        'PLAN',
      ),
      _HomeFeature(
        Icons.health_and_safety_rounded,
        'Financial Health',
        'Check your money position',
        const [Color(0xFF059669), Color(0xFF10B981)],
        () => _open(const FinancialHealthScreen()),
        'CHECK',
      ),
      _HomeFeature(
        Icons.event_note_rounded,
        'Planning Hub',
        'Plan goals, loans and savings',
        const [Color(0xFFD97706), Color(0xFFF59E0B)],
        () => _open(PlanningHubScreen(language: widget.language)),
        'PLAN',
      ),
      _HomeFeature(
        Icons.tune_rounded,
        'Decision Center',
        'Compare important money choices',
        const [Color(0xFFDB2777), Color(0xFFEC4899)],
        () => _open(const DecisionCenterScreen()),
        'SMART',
      ),
      _HomeFeature(
        Icons.currency_rupee_rounded,
        'Cash Counter',
        'Count cash notes and match totals',
        const [Color(0xFF059669), Color(0xFF10B981)],
        () => _open(const CashCounterScreen()),
        'QUICK',
      ),
    ];

    return SizedBox(
      height: 142,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: tools.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) => _featuredHomeCard(tools[index], index),
      ),
    );
  }

  Widget _featuredHomeCard(_HomeFeature feature, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 480 + index * 70),
      curve: Curves.easeOutCubic,
      builder: (_, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(16 * (1 - value), 0),
          child: child,
        ),
      ),
      child: SizedBox(
        width: 190,
        child: Material(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(21),
          child: InkWell(
            onTap: feature.onTap,
            borderRadius: BorderRadius.circular(21),
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(colors: feature.colors),
                          boxShadow: [
                            BoxShadow(
                              color: feature.colors.first.withValues(alpha: .18),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(feature.icon, color: Colors.white, size: 20),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                        decoration: BoxDecoration(
                          color: feature.colors.first.withValues(alpha: .10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          feature.badge,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: feature.colors.first,
                            letterSpacing: .35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    feature.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    feature.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10.5, color: AppTheme.muted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickToolRow() {
    return Row(children: [
      Expanded(child: _quickTool(Icons.percent_rounded, 'Rate Finder',
          () => _open(const InterestRateScreen()))),
      const SizedBox(width: 9),
      Expanded(child: _quickTool(Icons.swap_vert_rounded, 'SIP & SWP',
          () => _open(const SipSwpScreen()))),
      const SizedBox(width: 9),
      Expanded(child: _quickTool(Icons.event_note_rounded, 'Planning',
          () => _open(PlanningHubScreen(language: widget.language)))),
    ]);
  }

  Widget _quickTool(IconData icon, String title, VoidCallback onTap) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(children: [
            Icon(icon, color: AppTheme.primary, size: 22),
            const SizedBox(height: 6),
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800)),
          ]),
        ),
      ),
    );
  }

  Widget _recentAndPlanningRow() {
    return Row(children: [
      Expanded(child: _wideMini(Icons.event_note_rounded, 'Planning Hub',
          () => _open(PlanningHubScreen(language: widget.language)))),
      const SizedBox(width: 10),
      Expanded(child: _wideMini(Icons.health_and_safety_rounded, 'Financial Health',
          () => _open(const FinancialHealthScreen()))),
    ]);
  }

  Widget _header(AppStrings s) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                blurRadius: 18,
                offset: Offset(0, 6),
                color: Color(0x10000000),
              ),
            ],
          ),
          child: IconButton(
            tooltip: 'Open menu',
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            icon: const Icon(Icons.menu_rounded),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.account_balance_wallet_rounded,
              color: Colors.white, size: 21),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.appName,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w900)),
              Text(s.smartMoneyTools,
                  style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            tooltip: 'Search calculators',
            onPressed: () => _open(const SearchScreen()),
            icon: const Icon(Icons.search_rounded),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationDrawer(AppStrings s) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final drawerText = Theme.of(context).colorScheme.onSurface;
    final muted = isDark ? const Color(0xFFA8BAD0) : const Color(0xFF6B7280);

    return Drawer(
      width: MediaQuery.of(context).size.width * .86,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: isDark
                      ? const [Color(0xFF183A62), Color(0xFF245C92)]
                      : const [AppTheme.primary, AppTheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .16),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded,
                        color: Colors.white, size: 25),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.appName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w900)),
                        const SizedBox(height: 3),
                        const Text('All your money tools in one place',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(10, 2, 10, 12),
                children: [
                  _drawerLabel('FEATURED', muted),
                  _featuredDrawerItem(
                    Icons.account_balance_rounded,
                    'EMI Calculator',
                    'Calculate loan EMI instantly',
                    const [Color(0xFF2563EB), Color(0xFF3B82F6)],
                    drawerText,
                    () {
                      Navigator.pop(context);
                      _open(const EmiScreen());
                    },
                  ),
                  _featuredDrawerItem(
                    Icons.auto_graph_rounded,
                    'SIP Calculator',
                    'Plan wealth and monthly investing',
                    const [Color(0xFF059669), Color(0xFF10B981)],
                    drawerText,
                    () {
                      Navigator.pop(context);
                      _open(const SipScreen());
                    },
                  ),
                  _featuredDrawerItem(
                    Icons.trending_up_rounded,
                    'Step-up SIP',
                    'Increase SIP every year',
                    const [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
                    drawerText,
                    () {
                      Navigator.pop(context);
                      _open(const StepUpSipScreen());
                    },
                  ),
                  _featuredDrawerItem(
                    Icons.health_and_safety_rounded,
                    'Financial Health',
                    'Check your overall money position',
                    const [Color(0xFF0F766E), Color(0xFF14B8A6)],
                    drawerText,
                    () {
                      Navigator.pop(context);
                      _open(const FinancialHealthScreen());
                    },
                  ),
                  const SizedBox(height: 8),
                  _drawerLabel('MAIN', muted),
                  _drawerItem(Icons.home_rounded, 'Home', drawerText, () => Navigator.pop(context)),
                  _drawerItem(Icons.search_rounded, 'Search all calculators', drawerText, () {
                    Navigator.pop(context);
                    _open(const SearchScreen());
                  }),
                  const SizedBox(height: 8),
                  _drawerLabel('LOANS', muted),
                  _drawerItem(Icons.account_balance_rounded, 'EMI Calculator', drawerText, () {
                    Navigator.pop(context);
                    _open(const EmiScreen());
                  }),
                  _drawerItem(Icons.payments_rounded, 'Loan Prepayment', drawerText, () {
                    Navigator.pop(context);
                    _open(const PrepaymentScreen());
                  }),
                  _drawerItem(Icons.percent_rounded, 'Interest Rate Finder', drawerText, () {
                    Navigator.pop(context);
                    _open(const InterestRateScreen());
                  }),
                  _drawerItem(Icons.grid_view_rounded, 'More Loan & Savings Calculators', drawerText, () {
                    Navigator.pop(context);
                    _open(const ExtraCalculatorsScreen());
                  }),
                  const SizedBox(height: 8),
                  _drawerLabel('INVESTMENTS', muted),
                  _drawerItem(Icons.auto_graph_rounded, 'SIP Planner', drawerText, () {
                    Navigator.pop(context);
                    _open(const SipScreen());
                  }),
                  _drawerItem(Icons.trending_up_rounded, 'Step-up SIP', drawerText, () {
                    Navigator.pop(context);
                    _open(const StepUpSipScreen());
                  }),
                  _drawerItem(Icons.swap_vert_rounded, 'SIP & SWP', drawerText, () {
                    Navigator.pop(context);
                    _open(const SipSwpScreen());
                  }),
                  const SizedBox(height: 8),
                  _drawerLabel('QUICK TOOLS', muted),
                  _drawerItem(Icons.receipt_long_rounded, 'GST Calculator', drawerText, () {
                    Navigator.pop(context);
                    _open(const GstScreen());
                  }),
                  _drawerItem(Icons.payments_rounded, 'Cash Counter', drawerText, () {
                    Navigator.pop(context);
                    _open(const CashCounterScreen());
                  }),
                  _drawerItem(Icons.tune_rounded, 'Decision Center', drawerText, () {
                    Navigator.pop(context);
                    _open(const DecisionCenterScreen());
                  }),
                  _drawerItem(Icons.event_note_rounded, 'Planning Hub', drawerText, () {
                    Navigator.pop(context);
                    _open(PlanningHubScreen(language: widget.language));
                  }),
                  const SizedBox(height: 8),
                  _drawerLabel('YOUR FINANCES', muted),
                  _drawerItem(Icons.favorite_rounded, 'Financial Health', drawerText, () {
                    Navigator.pop(context);
                    _open(const FinancialHealthScreen());
                  }),
                  _drawerItem(Icons.bookmark_rounded, 'Saved Plans', drawerText, () {
                    Navigator.pop(context);
                    _open(const SavedPlansScreen());
                  }),
                  _drawerItem(Icons.star_rounded, 'Favorites', drawerText, () {
                    Navigator.pop(context);
                    _open(const FavoritesScreen());
                  }),
                  _drawerItem(Icons.notifications_active_rounded, 'Reminders', drawerText, () {
                    Navigator.pop(context);
                    _open(const RemindersScreen());
                  }),
                  _drawerItem(Icons.history_rounded, 'Calculation History', drawerText, () {
                    Navigator.pop(context);
                    _open(const HistoryScreen());
                  }),
                  const SizedBox(height: 8),
                  _drawerLabel('APP', muted),
                  _drawerItem(Icons.settings_rounded, 'Settings', drawerText, () {
                    Navigator.pop(context);
                    _open(SettingsScreen(
                        language: widget.language,
                        onLanguageChanged: widget.onLanguageChanged,
                        onThemeModeChanged: widget.onThemeModeChanged,
                        themeMode: widget.themeMode));
                  }),
                  _drawerItem(Icons.info_outline_rounded, 'About & help', drawerText, () {
                    Navigator.pop(context);
                    _showAboutDialog();
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
              child: Row(
                children: [
                  Icon(Icons.lock_outline_rounded, size: 15, color: muted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text('Calculations run on your device',
                        style: TextStyle(fontSize: 10.5, color: muted)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 5),
      child: Text(text,
          style: TextStyle(
              fontSize: 10,
              letterSpacing: .9,
              fontWeight: FontWeight.w900,
              color: color)),
    );
  }

  Widget _featuredDrawerItem(
      IconData icon,
      String title,
      String subtitle,
      List<Color> colors,
      Color textColor,
      VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        gradient: LinearGradient(
          colors: [
            colors.first.withValues(alpha: .12),
            colors.last.withValues(alpha: .055),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border.all(color: colors.first.withValues(alpha: .16)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    gradient: LinearGradient(colors: colors),
                    boxShadow: [
                      BoxShadow(
                        color: colors.first.withValues(alpha: .18),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                color: textColor,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colors.first.withValues(alpha: .13),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              'POPULAR',
                              style: TextStyle(
                                fontSize: 7.5,
                                letterSpacing: .45,
                                fontWeight: FontWeight.w900,
                                color: colors.first,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: textColor.withValues(alpha: .58),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: colors.first.withValues(alpha: .72),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(
      IconData icon, String title, Color textColor, VoidCallback onTap) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: (Theme.of(context).brightness == Brightness.dark
              ? AppTheme.darkIcon
              : AppTheme.primary).withValues(alpha: .13),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
            icon,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppTheme.darkIcon
                : AppTheme.primary,
            size: 20,
          ),
      ),
      title: Text(title,
          style: TextStyle(
              fontSize: 13.5, fontWeight: FontWeight.w700, color: textColor)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 19),
      onTap: onTap,
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'EMI SIP Calculator India',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.account_balance_wallet_rounded),
      children: [
        Text(AppStrings.translate(context, 'Calculate loans, investments, GST and everyday finance tools in one app.')),
        const SizedBox(height: 10),
        const Text('For guidance only. Verify important financial decisions with your lender, tax professional or investment provider.'),
      ],
    );
  }


  Widget _personalDashboard() {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait<dynamic>([
        LocalStore.financialHealth(),
        LocalStore.savedPlans(),
        LocalStore.reminders(),
        LocalStore.history(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final health = snapshot.data![0] as FinancialHealth?;
        final plans = snapshot.data![1] as List<SavedPlan>;
        final reminders = snapshot.data![2] as List<FinanceReminder>;
        final history = snapshot.data![3] as List<CalculationRecord>;
        final upcoming = reminders.where((r) => !r.completed).toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
        final next = upcoming.isEmpty ? null : upcoming.first;
        final surplus = health == null
            ? 0.0
            : health.monthlyIncome -
                health.monthlyExpenses -
                health.existingEmi -
                health.monthlyInvestments;

        return Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: .45)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.dashboard_customize_rounded,
                        color: AppTheme.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.translate(context, 'Your money snapshot'),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 2),
                        const Text('Pick up where you left off',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF6B7280))),
                      ],
                    ),
                  ),
                  if (health != null)
                    IconButton(
                      tooltip: 'Open financial health',
                      onPressed: () => _open(const FinancialHealthScreen()),
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              if (health != null) ...[
                Row(
                  children: [
                    Expanded(
                        child: _snapshotMetric(
                            'Monthly surplus',
                            indianCompact(surplus),
                            surplus >= 0 ? Colors.green : Colors.orange)),
                    const SizedBox(width: 9),
                    Expanded(
                        child: _snapshotMetric(
                            'Debt / income',
                            '${health.monthlyIncome > 0 ? (health.existingEmi / health.monthlyIncome * 100).toStringAsFixed(0) : '0'}%',
                            AppTheme.primary)),
                    const SizedBox(width: 9),
                    Expanded(
                        child: _snapshotMetric(
                            'Emergency fund',
                            health.monthlyExpenses + health.existingEmi > 0
                                ? '${(health.emergencyFund / (health.monthlyExpenses + health.existingEmi)).toStringAsFixed(1)} mo'
                                : '0 mo',
                            Colors.teal)),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                      child: _dashboardAction(
                          Icons.bookmark_rounded,
                          '${plans.length} saved plan${plans.length == 1 ? '' : 's'}',
                          () => _open(const SavedPlansScreen()))),
                  const SizedBox(width: 9),
                  Expanded(
                      child: _dashboardAction(
                          Icons.notifications_active_rounded,
                          next == null ? 'No reminders' : 'Next: ${next.title}',
                          () => _open(const RemindersScreen()))),
                ],
              ),
              if (history.isNotEmpty) ...[
                const SizedBox(height: 11),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: .04)
                        : const Color(0xFFF7F7FB),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.history_rounded,
                          size: 18, color: AppTheme.primary),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Continue your last calculation',
                                  style: TextStyle(
                                      fontSize: 11, color: Color(0xFF6B7280))),
                              const SizedBox(height: 2),
                              Text(history.first.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800)),
                            ]),
                      ),
                      Text(history.first.summary,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _snapshotMetric(String label, String value, Color accent) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: accent.withValues(alpha: .08),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 9.5, color: Color(0xFF6B7280))),
        const SizedBox(height: 4),
        Text(value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w900, color: accent)),
      ]),
    );
  }

  Widget _dashboardAction(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withValues(alpha: .05)
          : const Color(0xFFF7F7FB),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
          child: Row(children: [
            Icon(icon, size: 17, color: AppTheme.primary),
            const SizedBox(width: 7),
            Expanded(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w800))),
            const Icon(Icons.chevron_right_rounded, size: 16)
          ]),
        ),
      ),
    );
  }


  Widget _wideMini(IconData icon, String title, VoidCallback onTap) => Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Icon(icon, color: AppTheme.primary),
                const SizedBox(width: 9),
                Expanded(
                    child: Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 12))),
                const Icon(Icons.chevron_right_rounded, size: 18)
              ]),
            )),
      );


  Widget _sectionTitle(String title, String subtitle) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.w900)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            ],
          ),
        ),
      ],
    );
  }


}
