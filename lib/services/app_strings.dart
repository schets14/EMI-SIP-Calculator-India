import 'package:flutter/material.dart';

class AppStrings {
  final String language;
  const AppStrings(this.language);

  bool get hi => language == 'hi';

  String get appName => 'EMI SIP Calculator India';
  String get smartMoneyTools => hi ? 'Smart money tools' : 'Smart money tools';
  String get planYourMoney => hi ? 'Apne paise ko better plan karein' : 'Plan your money';
  String get calculateSmarter => hi ? 'Calculate smarter.\nPlan with confidence.' : 'Calculate smarter.\nPlan with confidence.';
  String get fastPrivateOffline => hi ? 'Fast • Private • Offline' : 'Fast • Private • Offline';
  String get quickTools => hi ? 'Quick tools' : 'Quick tools';
  String get everythingInOnePlace => hi ? 'Everything in one place' : 'Everything in one place';
  String get planAndDecide => hi ? 'Plan & decide' : 'Plan & decide';
  String get planAndDecideSub => hi ? 'Use scenarios before making a money decision' : 'Use scenarios before making a money decision';
  String get lowerLoanCost => hi ? 'Lower loan cost' : 'Lower loan cost';
  String get lowerLoanCostSub => hi ? 'See how prepayment can change interest and tenure' : 'See how prepayment can change interest and tenure';
  String get growSavings => hi ? 'Grow savings' : 'Grow savings';
  String get growSavingsSub => hi ? 'Estimate SIP and step-up SIP outcomes' : 'Estimate SIP and step-up SIP outcomes';
  String get reachGoal => hi ? 'Reach a goal' : 'Reach a goal';
  String get reachGoalSub => hi ? 'Find a monthly amount for your target' : 'Find a monthly amount for your target';
  String get popularCalculations => hi ? 'Popular calculations' : 'Popular calculations';
  String get startWithTap => hi ? 'Start with a tap' : 'Start with a tap';
  String get loanEmi => hi ? 'Loan EMI' : 'Loan EMI';
  String get loanEmiSub => hi ? 'EMI, interest & amortization' : 'EMI, interest & amortization';
  String get sipPlanner => hi ? 'SIP Planner' : 'SIP Planner';
  String get sipPlannerSub => hi ? 'Estimate long-term wealth' : 'Estimate long-term wealth';
  String get gstCalculator => hi ? 'GST Calculator' : 'GST Calculator';
  String get gstCalculatorSub => hi ? 'Add or remove GST instantly' : 'Add or remove GST instantly';
  String get loanPrepayment => hi ? 'Loan Prepayment' : 'Loan Prepayment';
  String get loanPrepaymentSub => hi ? 'See interest savings before you pay' : 'See interest savings before you pay';
  String get stepUpSip => hi ? 'Step-up SIP' : 'Step-up SIP';
  String get stepUpSipSub => hi ? 'Increase your SIP every year' : 'Increase your SIP every year';
  String get moreCalculators => hi ? 'More calculators' : 'More calculators';
  String get moreCalculatorsSub => hi ? 'FD, RD, PPF, home loan & goals' : 'FD, RD, PPF, home loan & goals';
  String get privateByDesign => hi ? 'Private by design' : 'Private by design';
  String get privateByDesignSub => hi ? 'Your calculations can stay on your device. No account required.' : 'Your calculations can stay on your device. No account required.';
  String get settings => hi ? 'Settings' : 'Settings';
  String get english => 'English';
  String get hindi => 'हिन्दी';
  String get appLanguage => hi ? 'App language' : 'App language';
  String get languageNote => hi ? 'English is the default. More Indian languages can be added later.' : 'English is the default. More Indian languages can be added later.';
  String get history => hi ? 'Calculation history' : 'Calculation history';
  String get historySub => hi ? 'View your recent calculations' : 'View your recent calculations';
  String get favorites => hi ? 'Favorites' : 'Favorites';
  String get favoritesSub => hi ? 'Your saved calculators' : 'Your saved calculators';
  String get privacy => hi ? 'Privacy' : 'Privacy';
  String get privacySub => hi ? 'Calculations are performed locally.' : 'Calculations are performed locally.';
  String get about => hi ? 'About EMI SIP Calculator India' : 'About EMI SIP Calculator India';
  String get aboutSub => hi ? 'Smart financial utilities • v1.0.0' : 'Smart financial utilities • v1.0.0';
  String get disclaimer => hi ? 'Financial calculations are estimates for planning and informational purposes. Verify rates, tax rules and product terms with the relevant institution before making decisions.' : 'Financial calculations are estimates for planning and informational purposes. Verify rates, tax rules and product terms with the relevant institution before making decisions.';
}

class AppLanguage {
  static const english = 'en';
  static const hindi = 'hi';

  static String label(String value) => value == hindi ? 'हिन्दी' : 'English';

  static Locale locale(String value) => Locale(value == hindi ? 'hi' : 'en', 'IN');
}
