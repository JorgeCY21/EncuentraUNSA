import 'package:flutter/material.dart';

import 'store.dart';
import 'screens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = NoticeStore();
  await store.load();
  runApp(
    MaterialApp(
      title: 'Encuentra UNSA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176B54)),
        scaffoldBackgroundColor: const Color(0xFFF6F8F5),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      home: HomeScreen(store: store),
    ),
  );
}
