import 'package:flutter/material.dart';
import '../models/calculation_record.dart';
import '../services/local_store.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<CalculationRecord>> future;
  @override void initState() { super.initState(); future = LocalStore.history(); }

  void refresh() => setState(() => future = LocalStore.history());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History', style: TextStyle(fontWeight: FontWeight.w800)), actions: [
        IconButton(onPressed: () async { await LocalStore.clearHistory(); refresh(); }, icon: const Icon(Icons.delete_outline_rounded)),
      ]),
      body: FutureBuilder<List<CalculationRecord>>(
        future: future,
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final items = snap.data!;
          if (items.isEmpty) return const Center(child: Text('No calculations yet'));
          return ListView.separated(
            padding: const EdgeInsets.all(16), itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) { final x = items[i]; return Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.history_rounded)), title: Text(x.title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(x.summary), trailing: Text('${x.createdAt.day}/${x.createdAt.month}'))); },
          );
        },
      ),
    );
  }
}
