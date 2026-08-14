import 'package:flutter/material.dart';

import '../../core/widgets/qeon_components.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: QeonPage(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
        child: ListView(
          children: [
            const Center(
              child: CircleAvatar(
                radius: 48,
                child: Text(
                  'VP',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(labelText: 'Name'),
              controller: null,
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'vikas@example.com',
              ),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Language',
                hintText: 'English',
              ),
            ),
            const SizedBox(height: 22),
            GradientButton(
              label: 'Save changes',
              icon: Icons.check_rounded,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
