import 'package:flutter/material.dart';
import '../models/user_planning_models.dart';
import '../services/local_store.dart';

class SavedPlansScreen extends StatefulWidget {
  const SavedPlansScreen({super.key});
  @override State<SavedPlansScreen> createState() => _SavedPlansScreenState();
}

class _SavedPlansScreenState extends State<SavedPlansScreen> {
  List<SavedPlan> plans = [];
  List<dynamic> recent = [];
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async { final x = await LocalStore.savedPlans(); final h = await LocalStore.history(); if (mounted) setState(() { plans = x; recent = h; }); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Plans', style: TextStyle(fontWeight: FontWeight.w900)), actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded))]),
      floatingActionButton: recent.isEmpty ? null : FloatingActionButton.extended(onPressed: _pickRecent, icon: const Icon(Icons.bookmark_add_rounded), label: const Text('Save recent')),
      body: plans.isEmpty ? _empty() : ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: plans.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final p = plans[i];
          return Dismissible(
            key: ValueKey(p.id),
            background: Container(decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(22)), alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete_outline, color: Colors.white)),
            onDismissed: (_) { LocalStore.deletePlan(p.id); setState(() => plans.removeAt(i)); },
            child: Card(child: ListTile(contentPadding: const EdgeInsets.all(15), leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: .12), child: Icon(Icons.bookmark_rounded, color: Theme.of(context).colorScheme.primary)), title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Padding(padding: const EdgeInsets.only(top: 5), child: Text('${p.summary}\n${p.type.toUpperCase()} • ${_date(p.createdAt)}', style: const TextStyle(fontSize: 12, height: 1.4))), isThreeLine: true, trailing: const Icon(Icons.chevron_right_rounded), onTap: () => _showDetails(p))),
          );
        },
      ),
    );
  }

  Widget _empty() => Center(child: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.bookmark_border_rounded, size: 64, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 14), const Text('No saved plans yet', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)), const SizedBox(height: 7), const Text('Run a calculation, then use Save recent here to keep it for later.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF6B7280)))])));

  Future<void> _pickRecent() async {
    final selected = await showModalBottomSheet<dynamic>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: [
        const Padding(padding: EdgeInsets.only(bottom: 10), child: Text('Choose a recent calculation', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900))),
        ...recent.take(12).map((r) => ListTile(leading: const Icon(Icons.history_rounded), title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(r.summary), onTap: () => Navigator.pop(context, r))),
      ])),
    );
    if (selected == null) return;
    final plan = SavedPlan(id: DateTime.now().microsecondsSinceEpoch.toString(), title: selected.title, type: selected.type, summary: selected.summary, createdAt: DateTime.now(), inputs: selected.inputs);
    await LocalStore.savePlan(plan);
    await _load();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to My Plans.')));
  }

  void _showDetails(SavedPlan p) => showModalBottomSheet(context: context, showDragHandle: true, builder: (_) => Padding(padding: const EdgeInsets.fromLTRB(20, 6, 20, 28), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 8), Text(p.summary, style: const TextStyle(color: Color(0xFF6B7280))), const SizedBox(height: 16), ...p.inputs.entries.take(8).map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [Expanded(child: Text(e.key)), Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.w800))]))) ])));
  String _date(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
