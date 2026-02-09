import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'db/app_database.dart';
import 'rust_core_bridge.dart';
import 'sync/api_client.dart';
import 'sync/sync_service.dart';
import 'ui/emar_screen.dart';
import 'ui/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    try {
      await RustCoreBridge.instance.init();
    } catch (err) {
      debugPrint('Rust core init failed: $err');
    }
  }
  runApp(const EmarApp());
}

class EmarApp extends StatelessWidget {
  const EmarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eMAR (Offline First)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF185C6B)),
        useMaterial3: true,
      ),
      routes: {
        '/': (_) => const LoginScreen(),
        '/emar': (_) => const EmarScreen(),
        '/sync': (_) => const SyncDemoScreen(),
      },
    );
  }
}

class SyncDemoScreen extends StatefulWidget {
  const SyncDemoScreen({super.key});

  @override
  State<SyncDemoScreen> createState() => _SyncDemoScreenState();
}

class _SyncDemoScreenState extends State<SyncDemoScreen> {
  final _db = AppDatabase();
  final _baseUrlController = TextEditingController(
    text: 'http://10.0.2.2:8080',
  );
  final _tokenController = TextEditingController();
  final _orgIdController = TextEditingController();
  final _userIdController = TextEditingController();
  final _deviceIdController = TextEditingController();

  bool _loading = false;
  String _status = 'Idle';

  @override
  void dispose() {
    _db.close();
    _baseUrlController.dispose();
    _tokenController.dispose();
    _orgIdController.dispose();
    _userIdController.dispose();
    _deviceIdController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _orgIdController.text = '550e8400-e29b-41d4-a716-446655440000';
    _userIdController.text = 'b36117f8-7ede-403c-99f1-0f25deb3b057';
    _deviceIdController.text = 'device-001';
  }

  Future<void> _enqueueTestEvent() async {
    final orgId = _orgIdController.text.trim();
    final userId = _userIdController.text.trim();
    final deviceId = _deviceIdController.text.trim();
    final now = DateTime.now();

    if (orgId.isEmpty || userId.isEmpty || deviceId.isEmpty) {
      setState(() {
        _status = 'Org, user, and device IDs required';
      });
      return;
    }

    await _db.enqueueEvent(
      eventId: DateTime.now().millisecondsSinceEpoch.toString(),
      orgId: orgId,
      actorUserId: userId,
      deviceId: deviceId,
      eventType: 'ResidentUpserted',
      entityType: 'resident',
      entityId: now.millisecondsSinceEpoch.toString(),
      occurredAt: now,
      payload: {
        'first_name': 'Ada',
        'last_name': 'Lovelace',
        'status': 'active',
      },
    );

    setState(() {
      _status = 'Enqueued test event';
    });
  }

  Future<void> _runSync() async {
    final baseUrl = _baseUrlController.text.trim();
    final token = _tokenController.text.trim();
    final orgId = _orgIdController.text.trim();
    if (baseUrl.isEmpty || token.isEmpty || orgId.isEmpty) {
      setState(() {
        _status = 'Base URL, token, and org ID required';
      });
      return;
    }

    setState(() {
      _loading = true;
      _status = 'Syncing...';
    });

    final service = SyncService(
      db: _db,
      apiClient: ApiClient(baseUrl: baseUrl, accessToken: token),
    );

    try {
      await service.runSync(orgId: orgId);
      setState(() {
        _status = 'Sync complete';
      });
    } catch (err) {
      setState(() {
        _status = 'Sync failed: $err';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _runBootstrap() async {
    final baseUrl = _baseUrlController.text.trim();
    final token = _tokenController.text.trim();
    final orgId = _orgIdController.text.trim();
    if (baseUrl.isEmpty || token.isEmpty || orgId.isEmpty) {
      setState(() {
        _status = 'Base URL, token, and org ID required';
      });
      return;
    }

    setState(() {
      _loading = true;
      _status = 'Bootstrapping...';
    });

    final service = SyncService(
      db: _db,
      apiClient: ApiClient(baseUrl: baseUrl, accessToken: token),
    );

    try {
      await service.runBootstrap(orgId: orgId);
      setState(() {
        _status = 'Bootstrap complete';
      });
    } catch (err) {
      setState(() {
        _status = 'Bootstrap failed: $err';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _testRustCore() async {
    final normalized = await RustCoreBridge.instance
        .normalizeMedicationName('Acetaminophen 500 MG');
    setState(() {
      _status = 'Rust core: $normalized';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('eMAR Sync Demo')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _baseUrlController,
                decoration: const InputDecoration(
                  labelText: 'API Base URL',
                  hintText: 'http://10.0.2.2:8080',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tokenController,
                decoration: const InputDecoration(labelText: 'Access Token'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _orgIdController,
                decoration: const InputDecoration(labelText: 'Org ID (UUID)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _userIdController,
                decoration: const InputDecoration(labelText: 'User ID (UUID)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _deviceIdController,
                decoration: const InputDecoration(
                  labelText: 'Device ID (UUID)',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _loading ? null : _enqueueTestEvent,
                    child: const Text('Create Event'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _loading ? null : _runSync,
                    child: _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Sync Now'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: _loading ? null : _runBootstrap,
                    child: const Text('Bootstrap'),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: _loading ? null : _testRustCore,
                    child: const Text('Test Rust Core'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FutureBuilder<int>(
                future: _db.outboxCount(),
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  return Text('Outbox events: $count');
                },
              ),
              const SizedBox(height: 12),
              Text('Status: $_status'),
              const Spacer(),
              Text(
                'Note: run build_runner to generate Drift code.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
