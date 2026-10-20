import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'store.dart';

const ink = Color(0xFF193B36), green = Color(0xFF176B54);
IconData categoryIcon(String c) => switch (c) {
  'Documentos' => Icons.badge_outlined,
  'Tecnología' => Icons.headphones_outlined,
  'Accesorios' => Icons.key_outlined,
  'Útiles' => Icons.menu_book_outlined,
  _ => Icons.inventory_2_outlined,
};

class HomeScreen extends StatefulWidget {
  final NoticeStore store;
  const HomeScreen({super.key, required this.store});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;
  String query = '', kind = 'Todos', category = 'Todos';
  bool resolved = false;
  final search = TextEditingController();
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  void editor() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => NoticeEditor(store: widget.store)),
  );
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final items = widget.store.search(
        query: query,
        kind: kind,
        category: category,
        mine: tab == 1,
        showResolved: tab == 1 && resolved,
      );
      return Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              Icon(Icons.radar, color: green, size: 30),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Encuentra UNSA',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: ink,
                    ),
                  ),
                  Text(
                    'COMUNIDAD UNIVERSITARIA',
                    style: TextStyle(fontSize: 9, letterSpacing: 1.6),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Acerca del proyecto',
              icon: const Icon(Icons.info_outline),
              onPressed: () => showAboutDialog(
                context: context,
                applicationName: 'Encuentra UNSA',
                applicationVersion: '1.0 · Laboratorio 04',
                children: [
                  const Text(
                    'Prototipo académico independiente. No es un servicio oficial de la UNSA.\n\nLos avisos se guardan solo en este dispositivo o navegador. Los ejemplos son ficticios. No hay cuentas, chat ni servidor compartido.',
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              children: [
                if (tab == 0)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: ink,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'VOLVAMOS A ENCONTRARNOS',
                          style: TextStyle(
                            color: Color(0xFFBDE6AE),
                            fontSize: 10,
                            letterSpacing: 1.8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Lo que perdiste,\npuede estar aquí.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            height: 1.12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Busca un objeto o ayuda a alguien a recuperarlo.',
                          style: TextStyle(color: Color(0xFFD8E5DF), height: 1.5),
                        ),
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          onPressed: editor,
                          icon: const Icon(Icons.add),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFDDF1B6),
                            foregroundColor: ink,
                          ),
                          label: const Text('Publicar un aviso'),
                        ),
                      ],
                    ),
                  ),
                if (tab == 1) ...[
                  const Text(
                    'Mis publicaciones',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Actualiza tus avisos y cierra los casos resueltos.'),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Incluir avisos resueltos'),
                    value: resolved,
                    onChanged: (v) => setState(() => resolved = v),
                  ),
                ],
                const SizedBox(height: 20),
                TextField(
                  controller: search,
                  onChanged: (v) => setState(() => query = v),
                  decoration: InputDecoration(
                    hintText: 'Buscar objeto o lugar',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Limpiar búsqueda',
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              search.clear();
                              setState(() => query = '');
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Todos', 'Perdido', 'Encontrado']
                      .map(
                        (v) => ChoiceChip(
                          label: Text(v == 'Todos' ? v : '${v}s'),
                          selected: kind == v,
                          onSelected: (_) => setState(() => kind = v),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    prefixIcon: Icon(Icons.tune),
                  ),
                  items: categories
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (v) => setState(() => category = v!),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tab == 0 ? 'Avisos de la comunidad' : 'Tus avisos',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: ink,
                        ),
                      ),
                    ),
                    Text(
                      '${items.length} resultados',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(Icons.search_off, size: 48, color: green),
                        const SizedBox(height: 12),
                        const Text(
                          'No encontramos avisos',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'Prueba otro término o publica un aviso.',
                          textAlign: TextAlign.center,
                        ),
                        TextButton(
                          onPressed: editor,
                          child: const Text('Crear publicación'),
                        ),
                      ],
                    ),
                  ),
                // Cambio C02: una, dos o tres columnas según el ancho disponible.
                LayoutBuilder(
                  builder: (context, box) {
                    final columns = box.maxWidth >= 760
                        ? 3
                        : box.maxWidth >= 520
                        ? 2
                        : 1;
                    final width = (box.maxWidth - (columns - 1) * 14) / columns;
                    return Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: items
                          .map(
                            (n) => SizedBox(
                              width: width,
                              child: NoticeCard(
                                notice: n,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        NoticeDetail(store: widget.store, id: n.id),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 22),
                const Text(
                  'DEMOSTRACIÓN ACADÉMICA · Datos locales y avisos ficticios',
                  style: TextStyle(fontSize: 10, color: Color(0xFF63736C)),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: tab == 1
            ? FloatingActionButton.extended(
                onPressed: editor,
                icon: const Icon(Icons.add),
                label: const Text('Nuevo aviso'),
              )
            : null,
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (i) => setState(() {
            tab = i;
            query = '';
            search.clear();
          }),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Explorar',
            ),
            NavigationDestination(
              icon: Icon(Icons.folder_outlined),
              selectedIcon: Icon(Icons.folder),
              label: 'Mis publicaciones',
            ),
          ],
        ),
      );
    },
  );
}

class ObjectVisual extends StatelessWidget {
  final Notice notice;
  final double height;
  const ObjectVisual({super.key, required this.notice, this.height = 130});
  Widget placeholder() => Container(
    height: height,
    width: double.infinity,
    color: const Color(0xFFE8EEE3),
    child: Icon(categoryIcon(notice.category), size: 66, color: green),
  );
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: notice.photo == null
        ? placeholder()
        : Image.memory(
            base64Decode(notice.photo!),
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => placeholder(),
          ),
  );
}

class StatusBadge extends StatelessWidget {
  final Notice notice;
  const StatusBadge({super.key, required this.notice});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: notice.resolved
          ? const Color(0xFFE7E9E7)
          : notice.kind == 'Encontrado'
          ? const Color(0xFFE2F1DF)
          : const Color(0xFFFFEBD6),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Text(
      notice.resolved ? 'Resuelto' : notice.kind,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: ink),
    ),
  );
}

class NoticeCard extends StatelessWidget {
  final Notice notice;
  final VoidCallback onTap;
  const NoticeCard({super.key, required this.notice, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    elevation: 0,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: Color(0xFFE0E7DE)),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ObjectVisual(notice: notice),
            const SizedBox(height: 12),
            StatusBadge(notice: notice),
            const SizedBox(height: 9),
            Text(
              notice.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ink,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 15),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(notice.place, style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${notice.category} · ${notice.date}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF63736C)),
            ),
          ],
        ),
      ),
    ),
  );
}

class NoticeDetail extends StatelessWidget {
  final NoticeStore store;
  final String id;
  const NoticeDetail({super.key, required this.store, required this.id});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final n = store.notices.firstWhere((n) => n.id == id);
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle del objeto')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                ObjectVisual(notice: n, height: 220),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: StatusBadge(notice: n),
                ),
                const SizedBox(height: 12),
                Text(
                  n.title,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 12),
                Text('${n.category} · ${n.date}'),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.place_outlined),
                  title: Text(n.place),
                ),
                const Divider(),
                const SizedBox(height: 12),
                const Text(
                  'Sobre este objeto',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(n.description, style: const TextStyle(height: 1.6)),
                const SizedBox(height: 24),
                const Text(
                  'Contacto de la publicación',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SelectableText(n.contact),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: n.contact));
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('Contacto copiado')));
                    }
                  },
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Copiar contacto'),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0DB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Acuerda la entrega en un lugar público. Comprueba una característica del objeto antes de entregarlo. Evita publicar datos de documentos personales.',
                    style: TextStyle(height: 1.5),
                  ),
                ),
                if (n.mine) ...[
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NoticeEditor(store: store, notice: n),
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar publicación'),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: Text(
                            n.resolved ? '¿Reabrir aviso?' : '¿Objeto recuperado?',
                          ),
                          content: Text(
                            n.resolved ? 'El aviso volverá a aparecer en Explorar.' : 'Se ocultará de Explorar y quedará en tus publicaciones.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(c, false),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(c, true),
                              child: const Text('Confirmar'),
                            ),
                          ],
                        ),
                      );
                      if (ok == true) {
                        try {
                          await store.save(n.withStatus(!n.resolved));
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'No se pudo guardar el cambio. Inténtalo otra vez.',
                                ),
                              ),
                            );
                          }
                        }
                      }
                    },
                    icon: Icon(n.resolved ? Icons.refresh : Icons.check_circle_outline),
                    label: Text(n.resolved ? 'Reabrir aviso' : 'Marcar como resuelto'),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}

class NoticeEditor extends StatefulWidget {
  final NoticeStore store;
  final Notice? notice;
  const NoticeEditor({super.key, required this.store, this.notice});
  @override
  State<NoticeEditor> createState() => _NoticeEditorState();
}

class _NoticeEditorState extends State<NoticeEditor> {
  final form = GlobalKey<FormState>();
  late final TextEditingController title, place, description, contact;
  String category = 'Documentos', kind = 'Perdido';
  DateTime date = DateTime.now();
  String? photo;
  bool busy = false;
  @override
  void initState() {
    super.initState();
    final n = widget.notice;
    title = TextEditingController(text: n?.title);
    place = TextEditingController(text: n?.place);
    description = TextEditingController(text: n?.description);
    contact = TextEditingController(text: n?.contact);
    if (n != null) {
      category = n.category;
      kind = n.kind;
      date = DateTime.parse(n.date);
      photo = n.photo;
    }
  }

  @override
  void dispose() {
    for (final c in [title, place, description, contact]) {
      c.dispose();
    }
    super.dispose();
  }

  String get dateText => date.toIso8601String().substring(0, 10);
  void message(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  Future<void> pickPhoto() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 900,
        imageQuality: 70,
      );
      if (file == null) {
        return;
      }
      final bytes = await file.readAsBytes();
      if (bytes.length > 700000) {
        message('Elige una imagen menor de 700 KB.');
        return;
      }
      if (mounted) {
        setState(() => photo = base64Encode(bytes));
      }
    } catch (_) {
      message('No se pudo abrir la imagen. Intenta con otra foto.');
    }
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) {
      return;
    }
    setState(() => busy = true);
    try {
      await widget.store.save(
        Notice(
          id: widget.notice?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
          title: title.text.trim(),
          category: category,
          place: place.text.trim(),
          description: description.text.trim(),
          contact: contact.text.trim(),
          kind: kind,
          date: dateText,
          mine: true,
          resolved: widget.notice?.resolved ?? false,
          photo: photo,
        ),
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (_) {
      message('No se pudo guardar. Libera espacio o usa una foto más pequeña.');
    } finally {
      if (mounted) {
        setState(() => busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.notice == null ? 'Publicar aviso' : 'Editar publicación'),
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Form(
          key: form,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                widget.notice == null
                    ? 'Cada aviso puede ayudar.'
                    : 'Mantén tu aviso actualizado.',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Describe el objeto y dónde se perdió o encontró.'),
              const SizedBox(height: 24),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'Perdido',
                    label: Text('Lo perdí'),
                    icon: Icon(Icons.search),
                  ),
                  ButtonSegment(
                    value: 'Encontrado',
                    label: Text('Lo encontré'),
                    icon: Icon(Icons.volunteer_activism_outlined),
                  ),
                ],
                selected: {kind},
                onSelectionChanged: busy ? null : (s) => setState(() => kind = s.first),
              ),
              const SizedBox(height: 20),
              if (photo != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(
                    base64Decode(photo!),
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: busy ? null : () => setState(() => photo = null),
                  child: const Text('Quitar foto'),
                ),
              ],
              OutlinedButton.icon(
                onPressed: busy ? null : pickPhoto,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(photo == null ? 'Añadir foto opcional' : 'Cambiar foto'),
              ),
              const SizedBox(height: 18),
              field(title, 'Nombre del objeto', 'Ejemplo: mochila azul', 60),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: categories
                    .skip(1)
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: busy ? null : (v) => setState(() => category = v!),
              ),
              const SizedBox(height: 18),
              field(place, 'Lugar', 'Ejemplo: biblioteca central', 80),
              const SizedBox(height: 18),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month_outlined),
                title: const Text('Fecha del suceso'),
                subtitle: Text(dateText),
                trailing: const Icon(Icons.edit_calendar_outlined),
                onTap: busy
                    ? null
                    : () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null && mounted) {
                          setState(() => date = picked);
                        }
                      },
              ),
              const SizedBox(height: 18),
              field(
                description,
                'Descripción',
                'Color, características y detalles útiles',
                600,
                lines: 4,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: contact,
                enabled: !busy,
                maxLength: 100,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo de contacto',
                  hintText: 'nombre@ejemplo.com',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
                validator: (v) =>
                    v == null ||
                        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v.trim())
                    ? 'Ingresa un correo válido'
                    : null,
              ),
              const SizedBox(height: 12),
              const Text(
                'Tu correo será visible en el aviso. No publiques números de DNI ni fotos legibles de documentos.',
                style: TextStyle(fontSize: 12, height: 1.5),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: busy ? null : submit,
                icon: busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(
                  busy
                      ? 'Guardando…'
                      : widget.notice == null
                      ? 'Publicar aviso'
                      : 'Guardar cambios',
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
  );
  Widget field(
    TextEditingController c,
    String label,
    String hint,
    int max, {
    int lines = 1,
  }) => TextFormField(
    controller: c,
    enabled: !busy,
    maxLength: max,
    minLines: lines,
    maxLines: lines,
    decoration: InputDecoration(labelText: label, hintText: hint),
    validator: (v) =>
        v == null || v.trim().length < 3 ? 'Escribe al menos 3 caracteres' : null,
  );
}
