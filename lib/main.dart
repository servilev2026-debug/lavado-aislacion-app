import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

void main() => runApp(const LavadoApp());

class LavadoApp extends StatelessWidget {
  const LavadoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Lavado de Aislación',
    theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
    home: const InicioPage(),
  );
}

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Lavado de Aislación')),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 30),
          const Icon(Icons.electrical_services, size: 80),
          const SizedBox(height: 20),
          const Text('CONTROL DE ACTIVIDAD', textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Demo App Terreno', textAlign: TextAlign.center),
          const SizedBox(height: 35),
          FilledButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text('INICIAR FAENA'),
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const FaenaPage())),
          ),
          const SizedBox(height: 15),
          OutlinedButton.icon(
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('HISTORIAL PDF'),
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const HistorialPage())),
          ),
        ],
      ),
    ),
  );
}

class FaenaPage extends StatefulWidget {
  const FaenaPage({super.key});
  @override State<FaenaPage> createState() => _FaenaPageState();
}

class _FaenaPageState extends State<FaenaPage> {
  final fields = <String, TextEditingController>{
    for (final n in ['Aviso','OT','SDI','Orden de compra','Nivel de tensión',
      'FlexiApp','Argos','Jefe de faena','Dirección','Alimentador','Reconectador'])
      n: TextEditingController()
  };
  String cuadrilla = 'Constitución';
  final poles = List<bool>.filled(20, false);
  final photos = <XFile>[];
  double? lat, lon;
  final picker = ImagePicker();

  Future<void> gps() async {
    if (!await Geolocator.isLocationServiceEnabled()) return;
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
    if (p == LocationPermission.denied || p == LocationPermission.deniedForever) return;
    final pos = await Geolocator.getCurrentPosition();
    setState(() { lat = pos.latitude; lon = pos.longitude; });
  }

  Future<void> photo() async {
    final x = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (x != null) setState(() => photos.add(x));
  }

  Future<void> pdf() async {
    final doc = pw.Document();
    final now = DateTime.now();
    doc.addPage(pw.MultiPage(build: (_) => [
      pw.Header(level: 0, child: pw.Text('INFORME LAVADO DE AISLACIÓN')),
      pw.Text('Reporte generado automáticamente desde app móvil'),
      pw.SizedBox(height: 12),
      for (final e in fields.entries) pw.Text('${e.key}: ${e.value.text}'),
      pw.Text('Cuadrilla: $cuadrilla'),
      pw.Text('Postes lavados: ${poles.where((x) => x).length} / 20'),
      pw.Text('GPS: ${lat ?? "sin dato"}, ${lon ?? "sin dato"}'),
      pw.Text('Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(now)}'),
      pw.SizedBox(height: 12),
      pw.Text('Fotografías registradas: ${photos.length}'),
    ]));
    final dir = await getApplicationDocumentsDirectory();
    final name = 'LAVADO_${fields["OT"]!.text.isEmpty ? "SIN_OT" : fields["OT"]!.text}_${DateFormat("yyyyMMdd_HHmm").format(now)}.pdf';
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(await doc.save());
    await Share.shareXFiles([XFile(file.path)], text: 'Informe de lavado de aislación');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Nueva Faena')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...fields.entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TextField(controller: e.value, decoration: InputDecoration(
            labelText: e.key, border: const OutlineInputBorder())),
        )),
        DropdownButtonFormField<String>(
          value: cuadrilla,
          decoration: const InputDecoration(labelText: 'Cuadrilla', border: OutlineInputBorder()),
          items: ['Constitución','Hualañé'].map((x) =>
            DropdownMenuItem(value: x, child: Text(x))).toList(),
          onChanged: (x) => setState(() => cuadrilla = x!),
        ),
        const SizedBox(height: 15),
        const Text('Postes / estructuras', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ...List.generate(20, (i) => CheckboxListTile(
          title: Text('Poste ${i + 1}'),
          value: poles[i],
          onChanged: (v) => setState(() => poles[i] = v ?? false),
        )),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            icon: const Icon(Icons.location_on), label: const Text('GPS'),
            onPressed: gps)),
          const SizedBox(width: 8),
          Expanded(child: OutlinedButton.icon(
            icon: const Icon(Icons.camera_alt), label: Text('Foto (${photos.length})'),
            onPressed: photo)),
        ]),
        if (lat != null) Text('GPS: $lat, $lon'),
        const SizedBox(height: 20),
        FilledButton.icon(
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('GENERAR INFORME PDF'),
          onPressed: pdf),
      ],
    ),
  );
}

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});
  @override State<HistorialPage> createState() => _HistorialPageState();
}
class _HistorialPageState extends State<HistorialPage> {
  Future<List<File>> files() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.listSync().whereType<File>().where((f) => f.path.endsWith('.pdf')).toList();
  }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Historial PDF')),
    body: FutureBuilder<List<File>>(
      future: files(),
      builder: (_, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        if (s.data!.isEmpty) return const Center(child: Text('No hay informes guardados'));
        return ListView(children: s.data!.map((f) => ListTile(
          leading: const Icon(Icons.picture_as_pdf),
          title: Text(f.path.split('/').last),
          trailing: IconButton(icon: const Icon(Icons.share),
            onPressed: () => Share.shareXFiles([XFile(f.path)])),
        )).toList());
      },
    ),
  );
}
