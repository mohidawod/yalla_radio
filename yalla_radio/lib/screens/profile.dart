import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('عن التطبيق'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.radio, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'تطبيق الراديو',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('الإصدار 1.0.0'),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),
            const Text('المطور: محمد داود', style: TextStyle(fontSize: 18)),
            const Spacer(),
            const Text(
              'شكراً لاستخدامك التطبيق',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
