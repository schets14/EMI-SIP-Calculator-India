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
import 'sip_swp_screen.dart';
import '../services/app_strings.dart';
import '../widgets/ad_banner.dart';
import '../services/local_store.dart';
import '../models/user_planning_models.dart';
import '../models/calculation_record.dart';
import '../utils/formatters.dart';

class HomeScreen extends StatefulWidget {
  final String language;
  final ValueChanged<String> onLanguageChanged;
  const HomeScreen(
      {super.key, required this.language, required this.onLanguageChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

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
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
            children: [
              _header(s),
              const SizedBox(height: 14),
              _quickActions(),
              const SizedBox(height: 18),
              _hero(s),
              const SizedBox(height: 24),
              _sectionTitle(s.quickTools, s.everythingInOnePlace),
              const SizedBox(height: 12),
              _toolGrid(s),
              const SizedBox(height: 22),
              _planCard(s),
              const SizedBox(height: 12),
              _personalDashboard(),
              const SizedBox(height: 12),
              _personalTools(),
              const SizedBox(height: 22),
              const FinanceBannerAd(),
              const SizedBox(height: 14),
              _insightCard(s),
              const SizedBox(height: 22),
              _sectionTitle(s.popularCalculations, s.startWithTap),
              const SizedBox(height: 12),
              _wideTool(
                icon: Icons.account_balance_rounded,
                iconColors: const [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                tag: 'LOAN',
                title: s.loanEmi,
                subtitle: s.loanEmiSub,
                onTap: () => _open(const EmiScreen()),
              ),
              const SizedBox(height: 10),
              _wideTool(
                icon: Icons.auto_graph_rounded,
                iconColors: const [Color(0xFF059669), Color(0xFF14B8A6)],
                tag: 'INVEST',
                title: s.sipPlanner,
                subtitle: s.sipPlannerSub,
                onTap: () => _open(const SipScreen()),
              ),
              const SizedBox(height: 10),
              _wideTool(
                icon: Icons.receipt_long_rounded,
                iconColors: const [Color(0xFFEA580C), Color(0xFFF97316)],
                tag: 'TAX',
                title: s.gstCalculator,
                subtitle: s.gstCalculatorSub,
                onTap: () => _open(const GstScreen()),
              ),
              const SizedBox(height: 10),
              _wideTool(
                icon: Icons.payments_rounded,
                iconColors: const [Color(0xFF0F766E), Color(0xFF14B8A6)],
                tag: 'LOAN',
                title: s.loanPrepayment,
                subtitle: s.loanPrepaymentSub,
                onTap: () => _open(const PrepaymentScreen()),
              ),
              const SizedBox(height: 10),
              _wideTool(
                icon: Icons.trending_up_rounded,
                iconColors: const [Color(0xFFDB2777), Color(0xFFF472B6)],
                tag: 'INVEST',
                title: s.stepUpSip,
                subtitle: s.stepUpSipSub,
                onTap: () => _open(const StepUpSipScreen()),
              ),
              const SizedBox(height: 10),
              _wideTool(
                icon: Icons.grid_view_rounded,
                iconColors: const [Color(0xFF0369A1), Color(0xFF38BDF8)],
                tag: 'TOOLS',
                title: s.moreCalculators,
                subtitle: s.moreCalculatorsSub,
                onTap: () => _open(const ExtraCalculatorsScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(AppStrings s) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.account_balance_wallet_rounded,
              color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.appName,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w900)),
              Text(s.smartMoneyTools,
                  style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            tooltip: 'Search',
            onPressed: () => _open(const SearchScreen()),
            icon: const Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                blurRadius: 18,
                offset: Offset(0, 6),
                color: Color(0x12000000),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => _open(SettingsScreen(
                language: widget.language,
                onLanguageChanged: widget.onLanguageChanged)),
            icon: const Icon(Icons.tune_rounded),
          ),
        ),
      ],
    );
  }

  Widget _quickActions() {
    return Row(children: [
      Expanded(
          child: _miniAction(Icons.search_rounded, 'Search',
              () => _open(const SearchScreen()))),
      const SizedBox(width: 9),
      Expanded(
          child: _miniAction(Icons.bookmark_rounded, 'My Plans',
              () => _open(const SavedPlansScreen()))),
      const SizedBox(width: 9),
      Expanded(
          child: _miniAction(Icons.notifications_active_rounded, 'Reminders',
              () => _open(const RemindersScreen()))),
    ]);
  }

  Widget _miniAction(IconData icon, String label, VoidCallback onTap) =>
      Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
            borderRadius: BorderRadius.circular(17),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
              child: Column(children: [
                Icon(icon, size: 20, color: AppTheme.primary),
                const SizedBox(height: 4),
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w800))
              ]),
            )),
      );

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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your money snapshot',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w900)),
                        SizedBox(height: 2),
                        Text('Pick up where you left off',
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

  Widget _personalTools() => Row(children: [
        Expanded(
            child: _wideMini(Icons.insights_rounded, 'Financial Health',
                () => _open(const FinancialHealthScreen()))),
        const SizedBox(width: 10),
        Expanded(
            child: _wideMini(Icons.compare_arrows_rounded, 'SIP → SWP',
                () => _open(const SipSwpScreen()))),
      ]);

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

  Widget _hero(AppStrings s) {
    final t = Curves.easeOutCubic.transform(_controller.value);
    return Transform.translate(
      offset: Offset(0, 18 * (1 - t)),
      child: Opacity(
        opacity: t.clamp(0, 1),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 22, 18, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x304F46E5),
                blurRadius: 28,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -32,
                top: -42,
                child: Container(
                  width: 145,
                  height: 145,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: .09),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.planYourMoney,
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  SizedBox(height: 7),
                  Text(
                    s.calculateSmarter,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.6,
                    ),
                  ),
                  SizedBox(height: 14),
                  Row(
                    children: [
                      Icon(Icons.bolt_rounded, color: Colors.white, size: 17),
                      SizedBox(width: 5),
                      Text(
                        s.fastPrivateOffline,
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _toolGrid(AppStrings s) {
    final items = [
      (
        'EMI',
        Icons.account_balance_rounded,
        const [Color(0xFF5B5FEF), Color(0xFF8B5CF6)],
        () => _open(const EmiScreen())
      ),
      (
        'SIP',
        Icons.trending_up_rounded,
        const [Color(0xFF059669), Color(0xFF10B981)],
        () => _open(const SipScreen())
      ),
      (
        'GST',
        Icons.receipt_long_rounded,
        const [Color(0xFFEA580C), Color(0xFFF97316)],
        () => _open(const GstScreen())
      ),
      (
        'Prepay',
        Icons.payments_rounded,
        const [Color(0xFF0F766E), Color(0xFF14B8A6)],
        () => _open(const PrepaymentScreen())
      ),
      (
        'Step-up SIP',
        Icons.auto_graph_rounded,
        const [Color(0xFFDB2777), Color(0xFFF472B6)],
        () => _open(const StepUpSipScreen())
      ),
      (
        'Reports',
        Icons.picture_as_pdf_rounded,
        const [Color(0xFF0369A1), Color(0xFF38BDF8)],
        () => _open(const EmiScreen())
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 11,
        mainAxisSpacing: 11,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (_, i) {
        final item = items[i];
        return _animatedGridCard(i, item);
      },
    );
  }

  Widget _animatedGridCard(int index, dynamic item) {
    final start = (index * .12).clamp(0.0, .6);
    final progress = ((_controller.value - start) / .4).clamp(0.0, 1.0);
    final curved = Curves.easeOutBack.transform(progress);
    return Transform.scale(
      scale: .92 + .08 * curved,
      child: Opacity(
        opacity: progress,
        child: GestureDetector(
          onTap: item.$4,
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(23),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0B111827),
                  blurRadius: 20,
                  offset: Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: item.$3),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(item.$2, color: Colors.white, size: 21),
                ),
                Row(
                  children: [
                    Text(
                      item.$1,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : const Color(0xFF111827),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_outward_rounded,
                      size: 16,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : const Color(0xFF111827),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _planCard(AppStrings s) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: () => _open(const DecisionCenterScreen()),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
                      borderRadius: BorderRadius.circular(16)),
                  child:
                      const Icon(Icons.explore_rounded, color: Colors.white)),
              const SizedBox(width: 13),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(s.planAndDecide,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 3),
                    Text(s.planAndDecideSub,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            height: 1.35))
                  ])),
              const Icon(Icons.arrow_forward_ios_rounded, size: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _insightCard(AppStrings s) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x0C111827)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: Color(0xFFEDE9FE),
            child: Icon(Icons.lock_outline_rounded, color: AppTheme.primary),
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.privateByDesign,
                    style: TextStyle(fontWeight: FontWeight.w800)),
                SizedBox(height: 3),
                Text(
                  s.privateByDesignSub,
                  style: TextStyle(
                      fontSize: 12, color: AppTheme.muted, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _wideTool({
    required IconData icon,
    required List<Color> iconColors,
    required String tag,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        splashColor: iconColors.first.withValues(alpha: .07),
        highlightColor: iconColors.first.withValues(alpha: .035),
        child: Ink(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: dark ? .10 : .055),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? .10 : .045),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(13, 13, 12, 13),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: iconColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: iconColors.first.withValues(alpha: .22),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        right: -7,
                        top: -8,
                        child: Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: .13),
                          ),
                        ),
                      ),
                      Icon(icon, color: Colors.white, size: 25),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: iconColors.first.withValues(alpha: .09),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                letterSpacing: .6,
                                color: iconColors.first,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.3,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: .055),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 17,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
