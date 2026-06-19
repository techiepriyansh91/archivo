import 'package:flutter/material.dart';

class ArchivoApp extends StatelessWidget {
  const ArchivoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'archivo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const _HomePlaceholder(),
    );
  }
}

/// Temporary landing screen for Slice 0. Replaced by the auth gate + notes list
/// in Slice 1.
class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('archivo')),
      body: const Center(child: Text('Foundation ready — Slice 0')),
    );
  }
}
