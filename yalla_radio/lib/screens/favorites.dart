import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  final List<Map<String, String>> favoriteStations;
  final Function(Map<String, String>) onRemove;

  const FavoritesScreen({
    super.key,
    required this.favoriteStations,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المحطات المفضلة')),
      body:
          favoriteStations.isEmpty
              ? const Center(child: Text('لا يوجد محطات مفضلة بعد'))
              : ListView.builder(
                itemCount: favoriteStations.length,
                itemBuilder: (context, index) {
                  final station = favoriteStations[index];
                  return ListTile(
                    title: Text(station['name'] ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () => onRemove(station),
                    ),
                  );
                },
              ),
    );
  }
}
