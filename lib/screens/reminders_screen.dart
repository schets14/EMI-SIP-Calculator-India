import 'package:flutter/material.dart';
import '../models/user_planning_models.dart';
import '../services/local_store.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});
  @override State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<FinanceReminder> reminders = [];

  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async { final x = await LocalStore.reminders(); if (mounted) setState(() => reminders = x); }

  Future<void> _add() async {
    final title = TextEditingController(text: 'SIP / EMI reminder');
    final note = TextEditingController(text: 'Check your financial plan');
    DateTime date = DateTime.now().add(const Duration(days: 30));
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('Add reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 10),
              TextField(controller: note, decoration: const InputDecoration(labelText: 'Note')),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month_rounded),
                title: Text('${date.day}/${date.month}/${date.year}'),
                trailing: TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 3650)), initialDate: date);
                    if (picked != null) setLocal(() => date = picked);
                  },
                  child: const Text('Change'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
          ],
        ),
      ),
    );
    if (ok == true) {
      await LocalStore.saveReminder(FinanceReminder(id: DateTime.now().microsecondsSinceEpoch.toString(), title: title.text.trim().isEmpty ? 'Reminder' : title.text.trim(), note: note.text.trim(), dueDate: date, type: 'finance'));
      await _load();
    }
    title.dispose();
    note.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...reminders]..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders', style: TextStyle(fontWeight: FontWeight.w900)), actions: [IconButton(onPressed: _add, icon: const Icon(Icons.add_rounded))]),
      floatingActionButton: FloatingActionButton.extended(onPressed: _add, icon: const Icon(Icons.notifications_active_rounded), label: const Text('Add reminder')),
      body: sorted.isEmpty
          ? const Center(child: Padding(padding: EdgeInsets.all(30), child: Text('Set a reminder for an EMI, SIP, review or financial goal.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF6B7280)))))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: sorted.length,
              separatorBuilder: (_, __) => const SizedBox(height: 9),
              itemBuilder: (_, i) {
                final r = sorted[i];
                final overdue = !r.completed && r.dueDate.isBefore(DateTime.now());
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: Checkbox(value: r.completed, onChanged: (v) async { await LocalStore.setReminderCompleted(r.id, v ?? false); await _load(); }),
                    title: Text(r.title, style: TextStyle(fontWeight: FontWeight.w900, decoration: r.completed ? TextDecoration.lineThrough : null)),
                    subtitle: Text('${r.note}\n${overdue ? 'Due' : 'Due on'} ${r.dueDate.day}/${r.dueDate.month}/${r.dueDate.year}', style: TextStyle(color: overdue ? Colors.orange : const Color(0xFF6B7280))),
                    trailing: IconButton(onPressed: () async { await LocalStore.deleteReminder(r.id); await _load(); }, icon: const Icon(Icons.delete_outline_rounded)),
                  ),
                );
              },
            ),
    );
  }
}
