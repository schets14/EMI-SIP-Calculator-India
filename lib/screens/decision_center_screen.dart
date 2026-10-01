import 'package:flutter/material.dart';
import '../services/finance_calculator.dart';
import '../utils/formatters.dart';
import '../widgets/ad_banner.dart';

class DecisionCenterScreen extends StatelessWidget {
  const DecisionCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plan & Decide', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
        children: [
          const Text('Go beyond a number. Compare real money scenarios before you decide.', style: TextStyle(color: Color(0xFF6B7280), height: 1.4)),
          const SizedBox(height: 18),
          _card(context, Icons.speed_rounded, const Color(0xFF059669), 'Pay More, Finish Early', 'See how an extra EMI can reduce your loan tenure and interest.', const PayMoreScreen()),
          const SizedBox(height: 12),
          _card(context, Icons.compare_arrows_rounded, const Color(0xFF4F46E5), 'Compare Two Loans', 'Put two loan offers side by side before you choose.', const LoanCompareScreen()),
          const SizedBox(height: 12),
          _card(context, Icons.swap_vert_rounded, const Color(0xFFEA580C), 'Prepay vs SIP', 'Compare using extra monthly cash for debt reduction or investing.', const EmiVsSipScreen()),
          const SizedBox(height: 12),
          _card(context, Icons.home_work_rounded, const Color(0xFF0F766E), 'Rent vs Buy', 'Compare rent outflow with a home purchase scenario.', const RentVsBuyScreen()),
          const SizedBox(height: 18),
          const FinanceBannerAd(),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, IconData icon, Color color, String title, String subtitle, Widget page) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(width: 52, height: 52, decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(17)), child: Icon(icon, color: color)),
            const SizedBox(width: 13),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12, height: 1.35))])),
            const Icon(Icons.arrow_forward_ios_rounded, size: 15),
          ]),
        ),
      ),
    );
  }
}

class PayMoreScreen extends StatefulWidget {
  const PayMoreScreen({super.key});
  @override State<PayMoreScreen> createState() => _PayMoreScreenState();
}
class _PayMoreScreenState extends State<PayMoreScreen> {
  final loan = TextEditingController(text: '2000000');
  final rate = TextEditingController(text: '8.5');
  final years = TextEditingController(text: '20');
  double extra = 3000;
  @override void initState() { super.initState(); for (final c in [loan, rate, years]) c.addListener(_refresh); }
  void _refresh() { if (mounted) setState(() {}); }
  @override void dispose() { loan.dispose(); rate.dispose(); years.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    final p = double.tryParse(loan.text) ?? 0;
    final r = double.tryParse(rate.text) ?? 0;
    final n = (int.tryParse(years.text) ?? 0) * 12;
    final base = FinanceCalculator.emi(principal: p, annualRate: r, tenureMonths: n);
    final newSchedule = p <= 0 || n <= 0 ? [] : FinanceCalculator.amortization(principal: p, annualRate: r, tenureMonths: n, fixedEmi: base.emi + extra);
    final newInterest = newSchedule.fold<double>(0, (sum, row) => sum + row.interest);
    final saved = (base.totalInterest - newInterest).clamp(0.0, double.infinity).toDouble();
    final monthsSaved = (n - newSchedule.length).clamp(0, n);
    return _shell(context, 'Pay More, Finish Early', [
      _inputs([_field('Loan amount', loan, '₹'), _field('Rate', rate, '%'), _field('Tenure', years, 'years')]),
      const SizedBox(height: 16),
      _hero('Estimated interest saved', money(saved), 'By adding ${money(extra)} to your monthly EMI'),
      const SizedBox(height: 14),
      _slider('Extra monthly payment', extra, 0, 30000, (v) => setState(() => extra = v.roundToDouble()), money(extra)),
      const SizedBox(height: 14),
      _resultRows({'Current EMI': money(base.emi), 'New monthly payment': money(base.emi + extra), 'Current interest': money(base.totalInterest), 'New estimated interest': money(newInterest), 'Tenure reduced': '$monthsSaved months'}),
      const SizedBox(height: 14),
      _note('This is an estimate. Actual lender schedules can differ due to payment dates, fees and lender rules.'),
    ]);
  }
}

class LoanCompareScreen extends StatefulWidget {
  const LoanCompareScreen({super.key});
  @override State<LoanCompareScreen> createState() => _LoanCompareScreenState();
}
class _LoanCompareScreenState extends State<LoanCompareScreen> {
  final amount = TextEditingController(text: '2000000');
  final years = TextEditingController(text: '20');
  final rateA = TextEditingController(text: '8.5');
  final rateB = TextEditingController(text: '9.0');
  @override void initState() { super.initState(); for (final c in [amount, years, rateA, rateB]) c.addListener(_refresh); }
  void _refresh() { if (mounted) setState(() {}); }
  @override void dispose() { for (final c in [amount, years, rateA, rateB]) c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final p = double.tryParse(amount.text) ?? 0;
    final n = (int.tryParse(years.text) ?? 0) * 12;
    final a = FinanceCalculator.emi(principal: p, annualRate: double.tryParse(rateA.text) ?? 0, tenureMonths: n);
    final b = FinanceCalculator.emi(principal: p, annualRate: double.tryParse(rateB.text) ?? 0, tenureMonths: n);
    return _shell(context, 'Compare Two Loans', [
      _inputs([_field('Loan amount', amount, '₹'), _field('Tenure', years, 'years')]),
      const SizedBox(height: 12),
      Row(children: [Expanded(child: _rateCard('Loan A', rateA, a)), const SizedBox(width: 10), Expanded(child: _rateCard('Loan B', rateB, b))]),
      const SizedBox(height: 14),
      _resultRows({'EMI difference': money((a.emi - b.emi).abs()), 'Interest difference': money((a.totalInterest - b.totalInterest).abs())}),
      const SizedBox(height: 14),
      _note('Compare the actual lender offer too, including processing fees, insurance, prepayment terms and other charges.'),
    ]);
  }
  Widget _rateCard(String title, TextEditingController rate, dynamic result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            TextField(
              controller: rate,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Interest', suffixText: '%'),
            ),
            const SizedBox(height: 10),
            Text(money(result.emi), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
            const Text('monthly EMI', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
          ],
        ),
      ),
    );
  }
}

class EmiVsSipScreen extends StatefulWidget { const EmiVsSipScreen({super.key}); @override State<EmiVsSipScreen> createState() => _EmiVsSipScreenState(); }
class _EmiVsSipScreenState extends State<EmiVsSipScreen> {
  final loan = TextEditingController(text: '2000000'); final loanRate = TextEditingController(text: '8.5'); final years = TextEditingController(text: '15'); final sipRate = TextEditingController(text: '12'); final cash = TextEditingController(text: '10000');
  @override void initState(){super.initState();for(final c in [loan,loanRate,years,sipRate,cash])c.addListener(_refresh);}
  void _refresh(){if(mounted)setState((){});}
  @override void dispose(){for(final c in [loan,loanRate,years,sipRate,cash]) c.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    final p=double.tryParse(loan.text)??0; final n=(int.tryParse(years.text)??0)*12; final lr=double.tryParse(loanRate.text)??0; final sr=double.tryParse(sipRate.text)??0; final extra=double.tryParse(cash.text)??0;
    final base=FinanceCalculator.emi(principal:p,annualRate:lr,tenureMonths:n); final schedule=FinanceCalculator.amortization(principal:p,annualRate:lr,tenureMonths:n,fixedEmi:base.emi+extra); final saved=base.totalInterest-schedule.fold<double>(0,(s,row)=>s+row.interest); final corpus=FinanceCalculator.sipFutureValue(monthlyInvestment:extra,annualRate:sr,years:int.tryParse(years.text)??0);
    return _shell(context,'Prepay vs SIP',[ _inputs([_field('Loan balance',loan,'₹'),_field('Loan rate',loanRate,'%'),_field('Remaining',years,'years'),_field('Extra cash',cash,'₹/month'),_field('SIP return',sipRate,'%')]), const SizedBox(height:16), _hero('Interest saved by prepaying',money(saved),'If the extra monthly cash increases your EMI'), const SizedBox(height:12), _resultRows({'SIP corpus on same cash flow':money(corpus),'Prepayment tenure reduction':'${(n-schedule.length).clamp(0,n)} months','Current EMI':money(base.emi),'EMI with extra':money(base.emi+extra)}), const SizedBox(height:14), _note('SIP returns are market-linked estimates, not guaranteed. Compare the assumptions rather than treating either scenario as a recommendation.') ]);
  }
}

class RentVsBuyScreen extends StatefulWidget { const RentVsBuyScreen({super.key}); @override State<RentVsBuyScreen> createState()=>_RentVsBuyScreenState(); }
class _RentVsBuyScreenState extends State<RentVsBuyScreen>{ final rent=TextEditingController(text:'25000'); final price=TextEditingController(text:'5000000'); final down=TextEditingController(text:'700000'); final rate=TextEditingController(text:'8.5'); final years=TextEditingController(text:'10'); @override void initState(){super.initState();for(final c in [rent,price,down,rate,years])c.addListener(_refresh);}
 void _refresh(){if(mounted)setState((){});}
 @override void dispose(){for(final c in [rent,price,down,rate,years])c.dispose();super.dispose();}
 @override Widget build(BuildContext context){final r=double.tryParse(rent.text)??0;final home=double.tryParse(price.text)??0;final dp=double.tryParse(down.text)??0;final yr=int.tryParse(years.text)??0;final loan=(home-dp).clamp(0.0,home).toDouble();final emi=FinanceCalculator.emi(principal:loan,annualRate:double.tryParse(rate.text)??0,tenureMonths:yr*12);final rentTotal=r*12*yr;final buyCash=dp+(emi.emi*12*yr);return _shell(context,'Rent vs Buy',[ _inputs([_field('Monthly rent',rent,'₹'),_field('Home price',price,'₹'),_field('Down payment',down,'₹'),_field('Loan rate',rate,'%'),_field('Horizon',years,'years')]),const SizedBox(height:16),_resultRows({'Rent paid over horizon':money(rentTotal),'EMI':money(emi.emi),'Down payment':money(dp),'Illustrative loan payments':money(emi.emi*12*yr),'Down payment + payments':money(buyCash)}),const SizedBox(height:14),_note('This simplified comparison does not include property appreciation, maintenance, taxes, stamp duty, rent inflation or investment returns. Add those assumptions before making a decision.') ]);}
}

Widget _shell(BuildContext context,String title,List<Widget> children)=>Scaffold(appBar:AppBar(title:Text(title,style:const TextStyle(fontWeight:FontWeight.w900))),body:ListView(padding:const EdgeInsets.fromLTRB(16,6,16,30),children:children));
Widget _inputs(List<Widget> fields)=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(children:[for(int i=0;i<fields.length;i++)... [fields[i],if(i<fields.length-1)const SizedBox(height:10)]])));
Widget _field(String label,TextEditingController c,String suffix)=>TextField(controller:c,keyboardType:const TextInputType.numberWithOptions(decimal:true),onChanged:(_){},decoration:InputDecoration(labelText:label,suffixText:suffix));
Widget _hero(String label,String value,String sub)=>Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(borderRadius:BorderRadius.circular(26),gradient:const LinearGradient(colors:[Color(0xFF4F46E5),Color(0xFF7C3AED)])),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label.toUpperCase(),style:const TextStyle(color:Colors.white70,fontSize:11,fontWeight:FontWeight.w800,letterSpacing:1)),const SizedBox(height:5),Text(value,style:const TextStyle(color:Colors.white,fontSize:32,fontWeight:FontWeight.w900)),const SizedBox(height:6),Text(sub,style:const TextStyle(color:Colors.white70,fontSize:12))]));
Widget _slider(String label,double value,double min,double max,ValueChanged<double> onChanged,String display)=>Card(child:Padding(padding:const EdgeInsets.fromLTRB(14,10,14,4),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text(label,style:const TextStyle(fontWeight:FontWeight.w800)),Text(display,style:const TextStyle(fontWeight:FontWeight.w900))]),Slider(value:value.clamp(min,max),min:min,max:max,onChanged:onChanged)])));
Widget _resultRows(Map<String, String> rows) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: rows.entries.map((e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              Expanded(child: Text(e.key, style: const TextStyle(color: Color(0xFF6B7280)))),
              Text(e.value, style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
        )).toList(),
      ),
    ),
  );
}
Widget _note(String text)=>Container(padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:const Color(0xFFF1F5F9),borderRadius:BorderRadius.circular(20)),child:Text(text,style:const TextStyle(fontSize:12,height:1.45,color:Color(0xFF475569))));
