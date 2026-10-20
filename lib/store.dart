import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const categories = [
  'Todos',
  'Documentos',
  'Tecnología',
  'Accesorios',
  'Útiles',
  'Otros',
];

class Notice {
  final String id, title, category, place, description, contact, kind, date;
  final bool mine, resolved;
  final String? photo;
  const Notice({
    required this.id,
    required this.title,
    required this.category,
    required this.place,
    required this.description,
    required this.contact,
    required this.kind,
    required this.date,
    this.mine = false,
    this.resolved = false,
    this.photo,
  });
  Notice withStatus(bool value) => Notice(
    id: id,
    title: title,
    category: category,
    place: place,
    description: description,
    contact: contact,
    kind: kind,
    date: date,
    mine: mine,
    resolved: value,
    photo: photo,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'place': place,
    'description': description,
    'contact': contact,
    'kind': kind,
    'date': date,
    'mine': mine,
    'resolved': resolved,
    'photo': photo,
  };
  factory Notice.fromJson(Map<String, dynamic> j) => Notice(
    id: j['id'],
    title: j['title'],
    category: j['category'],
    place: j['place'],
    description: j['description'],
    contact: j['contact'],
    kind: j['kind'],
    date: j['date'],
    mine: j['mine'] ?? false,
    resolved: j['resolved'] ?? false,
    photo: j['photo'],
  );
}

// Datos ficticios para demostrar la interfaz sin exponer datos personales.
List<Notice> demoNotices() => [
  const Notice(
    id: '1',
    title: 'Audífonos inalámbricos',
    category: 'Tecnología',
    place: 'Biblioteca central',
    description: 'Estuche blanco encontrado cerca de las mesas de lectura. Indica la marca y una característica para acreditar que es tuyo.',
    contact: 'biblioteca@example.com',
    kind: 'Encontrado',
    date: '2026-10-19',
  ),
  const Notice(
    id: '2',
    title: 'Carné universitario',
    category: 'Documentos',
    place: 'Pabellón de Sistemas',
    description: 'Perdí mi carné al salir de clase. Tiene una funda transparente. Escríbeme si lo encontraste.',
    contact: 'estudiante@example.com',
    kind: 'Perdido',
    date: '2026-10-18',
    mine: true,
  ),
  const Notice(
    id: '3',
    title: 'Llaves con cinta azul',
    category: 'Accesorios',
    place: 'Área de Ingenierías',
    description: 'Juego de tres llaves encontrado en una banca. La persona propietaria debe describir el llavero.',
    contact: 'aviso@example.com',
    kind: 'Encontrado',
    date: '2026-10-18',
  ),
  const Notice(
    id: '4',
    title: 'Cuaderno de apuntes',
    category: 'Útiles',
    place: 'Cafetería universitaria',
    description: 'Cuaderno de tapa verde con apuntes de programación. Fue entregado a la persona encargada de la cafetería.',
    contact: 'cuaderno@example.com',
    kind: 'Encontrado',
    date: '2026-10-17',
    mine: true,
  ),
];

class NoticeStore extends ChangeNotifier {
  static const storageKey = 'encuentra_unsa_v1';
  List<Notice> notices = demoNotices();
  Future<void> load() async {
    final raw = (await SharedPreferences.getInstance()).getString(storageKey);
    if (raw != null) {
      try {
        notices = (jsonDecode(raw) as List)
            .map((e) => Notice.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } catch (_) {
        notices = demoNotices();
      }
    }
    notifyListeners();
  }

  // Cambio C01: guardar antes de actualizar la interfaz para evitar falsos éxitos.
  Future<void> save(Notice n) async {
    final next = [...notices];
    final index = next.indexWhere((e) => e.id == n.id);
    if (index < 0) {
      next.insert(0, n);
    } else {
      next[index] = n;
    }
    final ok = await (await SharedPreferences.getInstance()).setString(
      storageKey,
      jsonEncode(next.map((e) => e.toJson()).toList()),
    );
    if (!ok) {
      throw StateError('No se pudo guardar');
    }
    notices = next;
    notifyListeners();
  }

  List<Notice> search({
    String query = '',
    String kind = 'Todos',
    String category = 'Todos',
    bool mine = false,
    bool showResolved = false,
  }) {
    String norm(String s) {
      var value = s.toLowerCase().trim();
      const a = 'áéíóúü', b = 'aeiouu';
      for (var i = 0; i < a.length; i++) {
        value = value.replaceAll(a[i], b[i]);
      }
      return value;
    }

    return notices
        .where(
          (n) =>
              (!mine || n.mine) &&
              (showResolved || !n.resolved) &&
              (kind == 'Todos' || n.kind == kind) &&
              (category == 'Todos' || n.category == category) &&
              norm('${n.title} ${n.place} ${n.description}').contains(norm(query)),
        )
        .toList();
  }
}
