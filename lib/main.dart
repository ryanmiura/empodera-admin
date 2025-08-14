import 'dart:async';
import 'config/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:empoderaadmin/core/firebase/main_app/options.dart';
import 'package:empoderaadmin/core/firebase/admin_auth/options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Configura tratamento detalhado de erros do Flutter
    FlutterError.onError = (details) {
      debugPrint('FLUTTER ERROR: ${details.exceptionAsString()}');
      debugPrint('STACK TRACE: ${details.stack}');
    };

    // Carrega e verifica variáveis de ambiente
    await _loadEnvironmentVariables();

    // Inicializa instâncias do Firebase
    await _initializeFirebaseApps();

    runApp(const MyApp());
  } catch (e, stack) {
    debugPrint('INITIALIZATION ERROR: $e');
    debugPrint('STACK TRACE: $stack');
    runApp(_ErrorApp(error: e.toString(), stackTrace: stack.toString()));
  }
}

Future<void> _loadEnvironmentVariables() async {
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('Environment variables loaded successfully');

    // Verifica variáveis obrigatórias para ambos os projetos Firebase
    final requiredAdminVars = [
      'ADMIN_AUTH_FIREBASE_API_KEY',
      'ADMIN_AUTH_FIREBASE_APP_ID',
      'ADMIN_AUTH_FIREBASE_PROJECT_ID'
    ];

    final requiredMainAppVars = [
      'MAIN_APP_FIREBASE_API_KEY',
      'MAIN_APP_FIREBASE_APP_ID',
      'MAIN_APP_FIREBASE_PROJECT_ID'
    ];

    final missingVars = <String>[];

    for (final varName in [...requiredAdminVars, ...requiredMainAppVars]) {
      if (dotenv.env[varName] == null || dotenv.env[varName]!.isEmpty) {
        missingVars.add(varName);
      }
    }

    if (missingVars.isNotEmpty) {
      throw Exception('Missing required environment variables: ${missingVars.join(', ')}');
    }
  } catch (e) {
    throw Exception('Failed to load environment variables: $e');
  }
}

Future<void>? _firebaseInitFuture;
Completer<void>? _firebaseInitCompleter;

/// Inicializa os apps Firebase de forma segura e única.
Future<void> _initializeFirebaseApps() async {
  // Mutex simples para garantir inicialização estritamente sequencial
  while (_firebaseInitCompleter != null && !_firebaseInitCompleter!.isCompleted) {
    await _firebaseInitCompleter!.future;
  }
  if (_firebaseInitCompleter != null) return _firebaseInitCompleter!.future;
  _firebaseInitCompleter = Completer<void>();
  try {
    await _doInitializeFirebaseApps();
    _firebaseInitCompleter?.complete();
  } catch (e, st) {
    _firebaseInitCompleter?.completeError(e, st);
    rethrow;
  }
  return _firebaseInitCompleter!.future;
}

Future<void> _doInitializeFirebaseApps() async {
  try {
    // Inicializa o app principal apenas se ainda não existir.
    if (!Firebase.apps.any((app) => app.name == '[DEFAULT]')) {
      await Firebase.initializeApp(
        options: MainAppFirebaseOptions.currentPlatform,
      );
      debugPrint('Main Firebase app initialized');
    } else {
      debugPrint('Main Firebase app já inicializado');
    }

    // Inicializa o app admin-auth apenas se ainda não existir.
    if (!Firebase.apps.any((app) => app.name == 'admin-auth')) {
      await Firebase.initializeApp(
        name: 'admin-auth',
        options: AdminAuthFirebaseOptions.currentPlatform,
      );
      debugPrint('Admin Auth Firebase app initialized');
    } else {
      debugPrint('Admin Auth Firebase app já inicializado');
    }
  } on FirebaseException catch (e) {
    throw Exception('Firebase initialization error: ${e.code} - ${e.message}');
  } catch (e) {
    throw Exception('Unknown Firebase initialization error: $e');
  }
}

class _ErrorApp extends StatelessWidget {
  final String error;
  final String stackTrace;

  const _ErrorApp({required this.error, required this.stackTrace});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red[50],
        appBar: AppBar(
          title: const Text('Initialization Error'),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'A critical error occurred:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                error,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 20),
              const Text(
                'Technical details:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(stackTrace),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => main(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Empodera Admin',
      debugShowCheckedModeBanner: false,
      theme: _buildThemeData(),
      routerConfig: appRouter,
    );
  }

  ThemeData _buildThemeData() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFD13B83),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 2,
      ),
    );
  }

}