import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

import 'src/core/app.dart';
import 'src/core/services/service_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize app services
  await App.initialize();
  
  // Run the app with Riverpod provider scope
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}