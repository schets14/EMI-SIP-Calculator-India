import 'package:flutter/material.dart';

class AppStrings {
  final String language;
  const AppStrings(this.language);

  bool get hi => language == 'hi';

  String get appName => 'EMI SIP Calculator India';
  String get smartMoneyTools => hi ? 'स्मार्ट मनी टूल्स' : 'Smart money tools';
  String get planYourMoney => hi ? 'अपने पैसों की बेहतर प्लानिंग करें' : 'Plan your money';
  String get calculateSmarter => hi ? 'स्मार्ट तरीके से कैलकुलेट करें।\nआत्मविश्वास से प्लान करें।' : 'Calculate smarter.\nPlan with confidence.';
  String get fastPrivateOffline => hi ? 'Fast • Private • Offline' : 'Fast • Private • Offline';
  String get quickTools => hi ? 'क्विक टूल्स' : 'Quick tools';
  String get everythingInOnePlace => hi ? 'सब कुछ एक जगह' : 'Everything in one place';
  String get planAndDecide => hi ? 'प्लान और निर्णय' : 'Plan & decide';
  String get planAndDecideSub => hi ? 'पैसों का फैसला लेने से पहले अलग-अलग विकल्प देखें' : 'Use scenarios before making a money decision';
  String get lowerLoanCost => hi ? 'लोन की लागत कम करें' : 'Lower loan cost';
  String get lowerLoanCostSub => hi ? 'प्रीपेमेंट से ब्याज और अवधि पर असर देखें' : 'See how prepayment can change interest and tenure';
  String get growSavings => hi ? 'बचत बढ़ाएँ' : 'Grow savings';
  String get growSavingsSub => hi ? 'SIP और स्टेप-अप SIP का अनुमान लगाएँ' : 'Estimate SIP and step-up SIP outcomes';
  String get reachGoal => hi ? 'लक्ष्य तक पहुँचें' : 'Reach a goal';
  String get reachGoalSub => hi ? 'अपने लक्ष्य के लिए मासिक राशि जानें' : 'Find a monthly amount for your target';
  String get popularCalculations => hi ? 'लोकप्रिय कैलकुलेशन' : 'Popular calculations';
  String get startWithTap => hi ? 'एक टैप से शुरू करें' : 'Start with a tap';
  String get loanEmi => hi ? 'लोन EMI' : 'Loan EMI';
  String get loanEmiSub => hi ? 'EMI, ब्याज और अमॉर्टाइजेशन' : 'EMI, interest & amortization';
  String get sipPlanner => hi ? 'SIP प्लानर' : 'SIP Planner';
  String get sipPlannerSub => hi ? 'लंबी अवधि की संपत्ति का अनुमान लगाएँ' : 'Estimate long-term wealth';
  String get gstCalculator => hi ? 'GST Calculator' : 'GST Calculator';
  String get gstCalculatorSub => hi ? 'GST तुरंत जोड़ें या हटाएँ' : 'Add or remove GST instantly';
  String get loanPrepayment => hi ? 'Loan Prepayment' : 'Loan Prepayment';
  String get loanPrepaymentSub => hi ? 'भुगतान से पहले ब्याज की बचत देखें' : 'See interest savings before you pay';
  String get stepUpSip => hi ? 'Step-up SIP' : 'Step-up SIP';
  String get stepUpSipSub => hi ? 'हर साल अपनी SIP बढ़ाएँ' : 'Increase your SIP every year';
  String get moreCalculators => hi ? 'और कैलकुलेटर' : 'More calculators';
  String get moreCalculatorsSub => hi ? 'FD, RD, PPF, होम लोन और लक्ष्य' : 'FD, RD, PPF, home loan & goals';
  String get privateByDesign => hi ? 'प्राइवेसी को ध्यान में रखकर' : 'Private by design';
  String get privateByDesignSub => hi ? 'आपकी गणनाएँ आपके डिवाइस पर ही रह सकती हैं। अकाउंट की जरूरत नहीं।' : 'Your calculations can stay on your device. No account required.';
  String get settings => hi ? 'सेटिंग्स' : 'Settings';
  String get english => 'English';
  String get hindi => 'हिन्दी';
  String get appLanguage => hi ? 'ऐप की भाषा' : 'App language';
  String get languageNote => hi ? 'अभी English और हिन्दी उपलब्ध हैं।' : 'English is the default. More Indian languages can be added later.';
  String get history => hi ? 'गणना इतिहास' : 'Calculation history';
  String get historySub => hi ? 'हाल की गणनाएँ देखें' : 'View your recent calculations';
  String get favorites => hi ? 'पसंदीदा' : 'Favorites';
  String get favoritesSub => hi ? 'आपके सेव किए गए कैलकुलेटर' : 'Your saved calculators';
  String get privacy => hi ? 'प्राइवेसी' : 'Privacy';
  String get privacySub => hi ? 'गणनाएँ आपके डिवाइस पर ही होती हैं।' : 'Calculations are performed locally.';
  String get about => hi ? 'EMI SIP Calculator India के बारे में' : 'About EMI SIP Calculator India';
  String get aboutSub => hi ? 'स्मार्ट वित्तीय टूल्स • v1.0.0' : 'Smart financial utilities • v1.0.0';
  String get disclaimer => hi ? 'वित्तीय गणनाएँ केवल योजना और जानकारी के लिए अनुमान हैं। कोई फैसला लेने से पहले संबंधित संस्था से दरें, टैक्स नियम और शर्तें सत्यापित करें।' : 'Financial calculations are estimates for planning and informational purposes. Verify rates, tax rules and product terms with the relevant institution before making decisions.';
  static String translate(BuildContext context, String english) {
    final isHindi = Localizations.localeOf(context).languageCode == 'hi';
    if (!isHindi) return english;
    const hi = <String, String>{
      'Loan EMI': 'लोन EMI',
      'SIP Planner': 'SIP प्लानर',
      'Step-up SIP': 'स्टेप-अप SIP',
      'SIP & SWP': 'SIP और SWP',
      'Loan Prepayment': 'लोन प्रीपेमेंट',
      'Plan & Decide': 'योजना और निर्णय',
      'More Calculators': 'और कैलकुलेटर',
      'My Plans': 'मेरी योजनाएँ',
      'Reminders': 'रिमाइंडर',
      'Financial Health': 'वित्तीय स्वास्थ्य',
      'Planning Hub': 'प्लानिंग हब',
      'Favorites': 'पसंदीदा',
      'Calculation History': 'गणना इतिहास',
      'Cash Counter': 'कैश काउंटर',
      'Interest Rate Finder': 'ब्याज दर खोजें',
      'EMI Calculator': 'EMI कैलकुलेटर',
      'SIP Calculator': 'SIP कैलकुलेटर',
      'GST Calculator': 'GST कैलकुलेटर',
      'Home Loan': 'होम लोन',
      'Fixed Deposit': 'फिक्स्ड डिपॉजिट',
      'Recurring Deposit': 'रिकरिंग डिपॉजिट',
      'Financial Goal': 'वित्तीय लक्ष्य',
      'PPF': 'PPF',
      'Prepayment': 'प्रीपेमेंट',
      'Pay More, Finish Early': 'ज्यादा भुगतान, जल्दी खत्म करें',
      'Compare Two Loans': 'दो लोन की तुलना',
      'Prepay vs SIP': 'प्रीपेमेंट बनाम SIP',
      'Rent vs Buy': 'किराया बनाम खरीद',
      'Loan amount': 'लोन राशि',
      'Interest rate': 'ब्याज दर',
      'Interest': 'ब्याज',
      'Principal': 'मूलधन',
      'Tenure': 'अवधि',
      'Current EMI': 'वर्तमान EMI',
      'Monthly EMI': 'मासिक EMI',
      'Loan rate': 'लोन दर',
      'Down payment': 'डाउन पेमेंट',
      'Expected return': 'अनुमानित रिटर्न',
      'Duration': 'अवधि',
      'Goal amount': 'लक्ष्य राशि',
      'Monthly surplus': 'मासिक बचत',
      'Emergency fund': 'आपातकालीन फंड',
      'Debt / income': 'कर्ज / आय',
      'Monthly SIP': 'मासिक SIP',
      'Yearly step-up': 'वार्षिक स्टेप-अप',
      'Yearly contribution': 'वार्षिक योगदान',
      'Maturity value': 'मैच्योरिटी राशि',
      'Interest earned': 'कमाया गया ब्याज',
      'Estimated returns': 'अनुमानित रिटर्न',
      'Invested': 'निवेश',
      'Total invested': 'कुल निवेश',
      'Total interest': 'कुल ब्याज',
      'Total repayment': 'कुल भुगतान',
      'Total deposits': 'कुल जमा',
      'Total contributions': 'कुल योगदान',
      'Total new SIP contributions': 'नई SIP का कुल योगदान',
      'Time to goal': 'लक्ष्य तक समय',
      'Withdrawal phase': 'निकासी चरण',
      'Year-wise plan': 'वर्षवार योजना',
      'View full amortization': 'पूरी अमॉर्टाइजेशन देखें',
      'Add reminder': 'रिमाइंडर जोड़ें',
      'Continue': 'जारी रखें',
      'Start planning': 'प्लानिंग शुरू करें',
      'Title': 'शीर्षक',
      'Total': 'कुल',
      'Your money, planned smarter': 'अपने पैसों की बेहतर प्लानिंग करें',
      'Your money snapshot': 'आपकी वित्तीय स्थिति',
      'Your next checks': 'आपके अगले चेक',
      'Your most-used money calculations': 'आपके सबसे ज्यादा इस्तेमाल होने वाले कैलकुलेटर',
      'Useful tools without cluttering Home': 'जरूरी टूल्स, बिना Home को भरने के',
      'Saved calculations and scenarios': 'सेव की गई गणनाएँ और सीनारियो',
      'Your bookmarked tools': 'आपके पसंदीदा टूल्स',
      'Calculate before you commit.': 'फैसला लेने से पहले गणना करें।',
      'Loans, investments, GST and everyday finance tools in one place.': 'लोन, निवेश, GST और रोजमर्रा के वित्तीय टूल्स एक जगह।',
      'Calculate loans, investments, GST and everyday finance tools in one app.': 'लोन, निवेश, GST और रोजमर्रा के वित्तीय टूल्स एक ऐप में।',
      'Appearance': 'दिखावट',
      'Privacy': 'प्राइवेसी',
      'Settings': 'सेटिंग्स',
      'Choose language': 'भाषा चुनें',
      'Choose appearance': 'दिखावट चुनें',
      'Light mode': 'लाइट मोड',
      'Dark mode': 'डार्क मोड',
      'System default': 'सिस्टम डिफॉल्ट',
      'Follow your phone theme': 'फोन की थीम के अनुसार',
      'Light': 'लाइट',
      'Dark': 'डार्क',
      'Bright and clean': 'ब्राइट और क्लीन',
      'Comfortable in low light': 'कम रोशनी में आरामदायक',
      'EMI, SIP and financial review reminders': 'EMI, SIP और वित्तीय समीक्षा के रिमाइंडर',
      'Build a private monthly money snapshot': 'अपनी मासिक वित्तीय स्थिति देखें',
      'Plan accumulation and withdrawals': 'निवेश और निकासी की योजना बनाएं',
      'Goals, planning and money decisions': 'लक्ष्य, प्लानिंग और पैसों के फैसले',
      'Calculate interest rate': 'ब्याज दर निकालें',
      'monthly EMI': 'मासिक EMI',
      'Amount': 'राशि',
      'Rate': 'दर',
      'yr': 'वर्ष',
      'years': 'वर्ष',
      'mo': 'माह',
      'Amount excluding GST': 'GST हटाने के बाद राशि',
      'Amount including GST': 'GST सहित राशि',
      'GST amount': 'GST राशि',
      'Taxable amount': 'टैक्स योग्य राशि',
      'GST rate': 'GST दर',
      'Goal duration': 'लक्ष्य अवधि',
      'Target amount': 'लक्ष्य राशि',
      'Current savings': 'मौजूदा बचत',
      'Required monthly SIP': 'जरूरी मासिक SIP',
      'Total corpus': 'कुल कॉर्पस',
      'Contributions': 'योगदान',
      'Returns': 'रिटर्न',
      'Corpus': 'कॉर्पस',
      'Maturity': 'मैच्योरिटी',
      'Savings': 'बचत',
      'Months saved': 'बचे हुए महीने',
      'Interest saved': 'बचने वाला ब्याज',
      'New EMI': 'नई EMI',
      'Current loan': 'मौजूदा लोन',
      'Withdrawal': 'निकासी',
      'Monthly withdrawal': 'मासिक निकासी',
      'Months': 'महीने',
      'Years': 'वर्ष',
      'Tenure (years)': 'अवधि (वर्ष)',
      'Step-up': 'स्टेप-अप',
      'Annual return': 'वार्षिक रिटर्न',
      'Monthly investment': 'मासिक निवेश',
      'Actual lender schedules can differ because of daily interest, fees, payment dates and lender rules.': 'वास्तविक लोन शेड्यूल दैनिक ब्याज, फीस, भुगतान तारीख और लेंडर के नियमों के कारण अलग हो सकता है।',
      'Outstanding loan': 'बकाया लोन',
      'Remaining months': 'बाकी महीने',
      'Part-payment': 'पार्ट पेमेंट',
      'Loan tenure': 'लोन अवधि',
      'Expected annual return': 'अनुमानित वार्षिक रिटर्न',
      'Monthly contribution': 'मासिक योगदान',
      'Invested vs returns': 'निवेश बनाम रिटर्न',
      'SIP growth': 'SIP ग्रोथ',
      'Principal vs interest across the full repayment': 'पूरे भुगतान में मूलधन बनाम ब्याज',
      'Loan composition': 'लोन का विभाजन',
      'You have a positive monthly surplus. Consider assigning it between goals, emergency savings and investing.': 'आपके पास सकारात्मक मासिक बचत है। इसे लक्ष्य, आपातकालीन बचत और निवेश में बाँटने पर विचार करें।',
      'Your entered monthly outgo exceeds income. Review the assumptions first.': 'आपका मासिक खर्च आय से ज्यादा है। पहले आंकड़ों की समीक्षा करें।',
      'Emergency fund is below a 3-month planning benchmark.': 'आपका आपातकालीन फंड 3 महीने के प्लानिंग बेंचमार्क से कम है।',
      'A simple snapshot using numbers you enter. Nothing is linked to your bank.': 'आपके डाले गए आंकड़ों से एक सरल स्नैपशॉट। आपका बैंक इससे लिंक नहीं है।',
      'Planning only, not financial advice. Use your actual income, expenses, debt and savings figures.': 'यह केवल प्लानिंग के लिए है, वित्तीय सलाह नहीं। अपनी वास्तविक आय, खर्च, कर्ज और बचत के आंकड़े इस्तेमाल करें।',
      'Emergency cover': 'आपातकालीन कवरेज',
      'Investment rate': 'निवेश दर',
      'Financial snapshot saved on this device.': 'वित्तीय स्नैपशॉट इस डिवाइस पर सेव हो गया।',
      'Save snapshot': 'स्नैपशॉट सेव करें',
      'Current savings / investments': 'मौजूदा बचत / निवेश',
      'Monthly investments': 'मासिक निवेश',
      'Existing EMI': 'मौजूदा EMI',
      'Monthly expenses': 'मासिक खर्च',
      'Monthly income': 'मासिक आय',
      'Find the monthly SIP needed for a goal': 'लक्ष्य के लिए जरूरी मासिक SIP जानें',
      'EMI, interest and total repayment': 'EMI, ब्याज और कुल भुगतान',
      'Plan a long-term PPF corpus': 'लंबी अवधि के PPF कॉर्पस की योजना',
      'Estimate maturity from monthly deposits': 'मासिक जमा से मैच्योरिटी का अनुमान',
      'Estimate maturity and interest': 'मैच्योरिटी और ब्याज का अनुमान',
      'Find the annual rate from loan amount, EMI and months': 'लोन राशि, EMI और महीनों से वार्षिक दर निकालें',
      'Count notes, coins and reconcile expected cash': 'नोट, सिक्के गिनें और अपेक्षित कैश से मिलाएँ',
      'Review your recent calculations': 'हाल की गणनाएँ देखें',
      'FD, RD, PPF, GST and goals': 'FD, RD, PPF, GST और लक्ष्य',
      'Compare loan and money scenarios': 'लोन और पैसों के विकल्पों की तुलना',
      'Estimate interest saved': 'बचने वाले ब्याज का अनुमान',
      'Plan investing and systematic withdrawals': 'निवेश और नियमित निकासी की योजना',
      'Increase SIP every year': 'हर साल SIP बढ़ाएँ',
      'Estimate corpus and returns': 'कॉर्पस और रिटर्न का अनुमान',
      'Calculate EMI, interest and amortization': 'EMI, ब्याज और अमॉर्टाइजेशन निकालें',
      'Try “loan”, “SIP”, “retirement”…': '“loan”, “SIP”, “retirement”… खोजें',
      'Search': 'सर्च',
    };
    return hi[english] ?? english;
  }

}

class AppLanguage {
  static const english = 'en';
  static const hindi = 'hi';

  static String label(String value) => value == hindi ? 'हिन्दी' : 'English';

  static Locale locale(String value) => Locale(value == hindi ? 'hi' : 'en', 'IN');
}
