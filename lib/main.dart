import 'package:flutter/material.dart';
import 'dart:async';
import 'package:uni_links/uni_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metropulse/theme.dart';
import 'package:metropulse/pages/splash_page.dart';
import 'package:metropulse/supabase/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  // Listen for incoming deep links (Android/iOS) and attempt to complete
  // the Supabase OAuth flow if the SDK exposes a helper.
  unawaited(_initDeepLinkHandler());
  runApp(const ProviderScope(child: MyApp()));
}

Future<void> _initDeepLinkHandler() async {
  // Handle initial uri
  try {
    final initial = await getInitialUri();
    if (initial != null) {
      try {
        await (SupabaseConfig.auth as dynamic).getSessionFromUrl(initial.toString());
      } catch (e) {
        // Older/newer supabase_flutter versions may not expose this; ignore.
        // The session listener in SessionController will still detect state
        // changes if the SDK manages sessions automatically.
      }
    }
  } catch (e) {
    // no-op
  }

  // Listen for subsequent incoming links while app is running.
  uriLinkStream.listen((Uri? uri) async {
    if (uri == null) return;
    try {
      await (SupabaseConfig.auth as dynamic).getSessionFromUrl(uri.toString());
    } catch (e) {
      // Ignore if method unavailable or handling fails; session listener may
      // still pick up events from Supabase SDK.
    }
  }, onError: (_) {});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MetroPulse',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashPage(),
    );
  }
}
