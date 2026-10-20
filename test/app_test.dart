import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encuentra_unsa/store.dart';
import 'package:encuentra_unsa/screens.dart';

Widget shell(Widget home) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: green),
    scaffoldBackgroundColor: const Color(0xFFF6F8F5),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
  home: home,
);
void main() {
  setUpAll(() async {
    final font = FontLoader('Roboto');
    font.addFont(
      File('test/fonts/roboto-regular.ttf')
          .readAsBytes()
          .then((b) => ByteData.sublistView(b)),
    );
    font.addFont(
      File('test/fonts/roboto-bold.ttf')
          .readAsBytes()
          .then((b) => ByteData.sublistView(b)),
    );
    await font.load();
    final icons = FontLoader('MaterialIcons');
    icons.addFont(
      File('test/fonts/materialicons-regular.otf')
          .readAsBytes()
          .then((b) => ByteData.sublistView(b)),
    );
    await icons.load();
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('Búsqueda combinada, edición, resolución y persistencia', () async {
    final s = NoticeStore();
    await s.load();
    expect(
      s.search(query: 'audifonos', category: 'Tecnología', kind: 'Encontrado').length,
      1,
    );
    expect(s.search(query: 'zzzz'), isEmpty);
    final n = s.notices[1];
    await s.save(n.withStatus(true));
    expect(s.search(mine: true).any((e) => e.id == n.id), false);
    expect(s.search(mine: true, showResolved: true).any((e) => e.id == n.id), true);
    final reloaded = NoticeStore();
    await reloaded.load();
    expect(reloaded.notices.firstWhere((e) => e.id == n.id).resolved, true);
    await reloaded.save(n.withStatus(false));
    expect(reloaded.search().length, 4);
  });
  testWidgets('Publicar valida campos y conserva el nuevo aviso', (t) async {
    t.view.physicalSize = const Size(430, 1400);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    final s = NoticeStore();
    await t.pumpWidget(shell(NoticeEditor(store: s)));
    await t.pumpAndSettle();
    final submit = find.widgetWithText(FilledButton, 'Publicar aviso');
    await t.ensureVisible(submit);
    await t.tap(submit);
    await t.pumpAndSettle();
    expect(find.text('Escribe al menos 3 caracteres'), findsWidgets);
    expect(s.notices.length, 4);
    final fields = find.byType(TextFormField);
    for (final entry in {
      0: 'Mochila azul',
      1: 'Biblioteca',
      2: 'Mochila con cierre negro',
      3: 'demo@example.com',
    }.entries) {
      await t.ensureVisible(fields.at(entry.key));
      await t.enterText(fields.at(entry.key), entry.value);
    }
    await t.ensureVisible(submit);
    await t.tap(submit);
    await t.pumpAndSettle();
    expect(s.notices.first.title, 'Mochila azul');
    final again = NoticeStore();
    await again.load();
    expect(again.notices.first.title, 'Mochila azul');
  });
  testWidgets('Pantallas renderizadas sin desbordamientos', (t) async {
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    final s = NoticeStore();
    Future<void> capture(Widget screen, String name, Size size) async {
      t.view.physicalSize = size;
      await t.pumpWidget(shell(screen));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('captures/$name.png'),
      );
    }

    await capture(HomeScreen(store: s), '01_inicio', const Size(430, 1400));
    await t.tap(find.text('Mis publicaciones').last);
    await t.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('captures/04_mis_publicaciones.png'),
    );
    await capture(NoticeEditor(store: s), '02_publicar', const Size(430, 1500));
    await capture(NoticeDetail(store: s, id: '1'), '03_detalle', const Size(430, 1050));
    await capture(
      NoticeEditor(store: s, notice: s.notices[1]),
      '05_editar',
      const Size(430, 1500),
    );
    await capture(
      HomeScreen(store: s, key: const ValueKey('desktop')),
      '06_escritorio',
      const Size(1280, 1000),
    );
    await capture(
      HomeScreen(store: s, key: const ValueKey('small')),
      '07_movil',
      const Size(360, 800),
    );
  });
}
