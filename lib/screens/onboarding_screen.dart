import 'package:flutter/material.dart';
import '../services/local_store.dart';
import '../services/app_strings.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  final String language;
  const OnboardingScreen({super.key, required this.onDone, required this.language});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  int page = 0;

  List<(String, String, IconData)> get data {
    final s = AppStrings(widget.language);
    return [
      (s.planAndDecide, s.planAndDecideSub, Icons.explore_rounded),
      (s.loanEmi, s.loanEmiSub, Icons.account_balance_rounded),
      (s.growSavings, s.growSavingsSub, Icons.trending_up_rounded),
    ];
  }

  /* final data = const [
    ('Plan your money', 'EMI, SIP, GST, deposits and financial goals in one clean app.', Icons.auto_graph_rounded),
    ('See the numbers', 'Interactive charts and clear breakdowns make every result easier to understand.', Icons.pie_chart_rounded),
    ('Private by design', 'Your calculation history and preferences can stay on this device.', Icons.lock_outline_rounded),
  ]; */

  Future<void> finish() async {
    await LocalStore.setOnboardingDone();
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: data.length,
                onPageChanged: (v) => setState(() => page = v),
                itemBuilder: (_, i) {
                  final item = data[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(28, 50, 28, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(colors: [Color(0xFF5B5FEF), Color(0xFF8B5CF6)]),
                            boxShadow: const [BoxShadow(color: Color(0x355B5FEF), blurRadius: 35, offset: Offset(0, 18))],
                          ),
                          child: Icon(item.$3, color: Colors.white, size: 66),
                        ),
                        const SizedBox(height: 42),
                        Text(item.$1, textAlign: TextAlign.center, style: const TextStyle(fontSize: 31, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 14),
                        Text(item.$2, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF6B7280))),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(data.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: page == i ? 24 : 7,
                height: 7,
                decoration: BoxDecoration(color: page == i ? const Color(0xFF5B5FEF) : const Color(0xFFD1D5DB), borderRadius: BorderRadius.circular(10)),
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: FilledButton(
                onPressed: page == data.length - 1 ? finish : () => controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17))),
                child: Text(page == data.length - 1 ? (widget.language == 'hi' ? 'Start planning' : 'Start planning') : (widget.language == 'hi' ? 'Continue' : 'Continue')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
