import 'package:flutter/material.dart';
import '../services/local_store.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<Set<String>> future;

  @override
  void initState() {
    super.initState();
    future = LocalStore.favorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: FutureBuilder<Set<String>>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Tap the bookmark icon on a calculator to save it here.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final widgets = items.map<Widget>((item) {
            return Card(
              child: ListTile(
                leading: const Icon(Icons.bookmark_rounded),
                title: Text(
                  item,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () async {
                    await LocalStore.toggleFavorite(item);
                    if (!mounted) return;
                    setState(() {
                      future = LocalStore.favorites();
                    });
                  },
                ),
              ),
            );
          }).toList();

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: widgets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) => widgets[index],
          );
        },
      ),
    );
  }
}
