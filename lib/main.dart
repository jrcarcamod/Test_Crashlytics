import 'package:flutter/widgets.dart';
import 'app.dart';
import 'crashlytics_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp(service: FirebaseCrashlyticsService()));
}
