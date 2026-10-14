import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

abstract interface class CrashlyticsService {
  Future<void> initialize();
  Future<void> prepareCrash();
  void crash();
}

class FirebaseCrashlyticsService implements CrashlyticsService {
  @override
  Future<void> initialize() async {
    // iOS reads the existing Firebase app from GoogleService-Info.plist.
    await Firebase.initializeApp();
    final crashlytics = FirebaseCrashlytics.instance;
    await crashlytics.setCrashlyticsCollectionEnabled(true);
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      crashlytics.recordFlutterFatalError(details);
    };
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      crashlytics.recordError(error, stackTrace, fatal: true);
      return true;
    };
  }

  @override
  Future<void> prepareCrash() async {
    final crashlytics = FirebaseCrashlytics.instance;
    await crashlytics.setCustomKey('test_type', 'native_crash');
    await crashlytics.log('Crash nativo de prueba generado desde el botón.');
  }

  @override
  void crash() => FirebaseCrashlytics.instance.crash();
}
