import 'dart:io';

import 'package:flutter/material.dart';
import 'package:siprocalsdk_chronos/siprocalsdk_chronos.dart';

import 'crashlytics_service.dart';

final _siprocalPlugin = SiprocalsdkChronos();

class MyApp extends StatelessWidget {
  const MyApp({required this.service, super.key});

  final CrashlyticsService service;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Prueba de Crashlytics',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3159A7)),
      useMaterial3: true,
    ),
    home: CrashTestScreen(service: service),
  );
}

class CrashTestScreen extends StatefulWidget {
  const CrashTestScreen({required this.service, super.key});

  final CrashlyticsService service;

  @override
  State<CrashTestScreen> createState() => _CrashTestScreenState();
}

class _CrashTestScreenState extends State<CrashTestScreen> {
  bool _initializing = true;
  bool _ready = false;
  bool _crashing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
    if(Platform.isIOS){
      _siprocalPlugin.requestPushPermission();
    }
  }

  Future<void> _initialize() async {
    setState(() {
      _initializing = true;
      _ready = false;
      _error = null;
    });
    try {
      await widget.service.initialize();
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _ready = true;
      });
    } catch (error) {
      debugPrint('Firebase initialization failed: $error');
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _error = 'No se pudo iniciar Firebase.';
      });
    }
  }

  Future<void> _generateCrash() async {
    if (!_ready || _crashing) return;
    setState(() {
      _crashing = true;
      _error = null;
    });
    try {
      await widget.service.prepareCrash();
      if (!mounted) return;
      widget.service.crash();
    } catch (error) {
      debugPrint('Crash preparation failed: $error');
      if (!mounted) return;
      setState(() {
        _crashing = false;
        _error = 'No se pudo preparar el crash. Inténtalo de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Prueba de Crashlytics')),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.bug_report_outlined, size: 72),
                const SizedBox(height: 24),
                Text(
                  'Prueba un fallo real en iOS',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Este botón cerrará la app intencionalmente. '
                  'Vuelve a abrirla con conexión a internet para enviar '
                  'el reporte a Firebase Crashlytics.',
                ),
                const SizedBox(height: 24),
                if (_initializing) ...[
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 12),
                  const Text(
                    'Iniciando Firebase…',
                    textAlign: TextAlign.center,
                  ),
                ] else if (_ready)
                  Text(
                    _crashing ? 'Preparando crash…' : 'Crashlytics listo',
                    textAlign: TextAlign.center,
                  ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  if (!_ready)
                    TextButton(
                      onPressed: _initialize,
                      child: const Text('Reintentar'),
                    ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _ready && !_crashing ? _generateCrash : null,
                  icon: const Icon(Icons.warning_amber_rounded),
                  label: const Text('Generar crash'),
                ),
                const SizedBox(height: 24),
                const Text(
                  'En un iPhone, instala la versión Release y abre la app '
                  'desde su icono sin el depurador conectado. '
                  'En el simulador puedes usar Debug. '
                  'El reporte puede tardar unos minutos en aparecer '
                  'después de volver a abrirla.',
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
