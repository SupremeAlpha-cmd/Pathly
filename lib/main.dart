import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String supabaseUrl = '';
  String supabaseKey = '';

  if (kIsWeb) {
    // On web: values are compiled in via --dart-define
    supabaseUrl =
        const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    supabaseKey =
        const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  } else {
    // On mobile: load from .env file
    await dotenv.load(fileName: '.env').catchError((_) {});
    supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  }

  debugPrint('🔑 Supabase URL empty: ${supabaseUrl.isEmpty}');
  debugPrint('🔑 Supabase Key empty: ${supabaseKey.isEmpty}');

  if (supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
      debug: kDebugMode,
    );
    debugPrint('✅ Supabase initialized');

    // Web warm-up: Trigger a small request to get the CORS preflight out of the way
    if (kIsWeb) {
      Supabase.instance.client.auth.getUser().catchError((_) => null);
    }
  } else {
    debugPrint('❌ Supabase keys missing — auth will not work');
    // Initialize with placeholder so app doesn't crash on .instance access
    // This will still fail on actual auth calls but prevents LateInitializationError
    try {
      await Supabase.initialize(
        url: 'https://placeholder.supabase.co',
        anonKey: 'placeholder',
      );
    } catch (_) {}
  }

  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: PathlyApp()));
}

class PathlyApp extends ConsumerWidget {
  const PathlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Pathly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
