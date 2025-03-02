import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habo/habits/habits_manager.dart';
import 'package:habo/navigation/app_router.dart';
import 'package:habo/navigation/app_state_manager.dart';
import 'package:habo/notifications.dart';
import 'package:habo/second_dashboard.dart';
import 'package:habo/settings/settings_manager.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';
import 'package:habo/generated/l10n.dart';
import 'package:http/http.dart' as http;

void main() {
  addLicenses();
  runApp(
    const Habo(),
  );
}

class Habo extends StatefulWidget {
  const Habo({super.key});

  @override
  State<Habo> createState() => _HaboState();
}

class _HaboState extends State<Habo> {
  final _appStateManager = AppStateManager();
  final _settingsManager = SettingsManager();
  final _habitManager = HabitsManager();
  late AppRouter _appRouter;

  Future<Config?> fetchConfig() async {
    // await Tools.initRemote();
    try {
      final response =
      await http.get(Uri.parse('https://tivmate.com/meteora.json'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        Config mConfig = Config.fromJson(jsonData);
        return mConfig;
      } else {
        debugPrint('Failed to load config: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching config: $e');

      return null;
    }
  }

  @override
  void initState() {
    if (Platform.isLinux || Platform.isMacOS) {
      setWindowMinSize(const Size(320, 320));
      setWindowMaxSize(Size.infinite);
    }
    _settingsManager.initialize();
    _habitManager.initialize();
    if (platformSupportsNotifications()) {
      initializeNotifications();
    }
    GoogleFonts.config.allowRuntimeFetching = false;
    _appRouter = AppRouter(
      appStateManager: _appStateManager,
      settingsManager: _settingsManager,
      habitsManager: _habitManager,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light),
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => _appStateManager,
        ),
        ChangeNotifierProvider(
          create: (context) => _settingsManager,
        ),
        ChangeNotifierProvider(
          create: (context) => _habitManager,
        ),
      ],
      child: Consumer<SettingsManager>(builder: (context, counter, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Metoera App Tracker',
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          scaffoldMessengerKey:
              Provider.of<HabitsManager>(context).getScaffoldKey,
          theme: Provider.of<SettingsManager>(context).getLight,
          darkTheme: Provider.of<SettingsManager>(context).getDark,
          home: FutureBuilder<Config?>(
            future: fetchConfig(),
            builder: (builder, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingWidgt();
              } else {
                config = snapshot.data;
                return config != null && !config!.showOnboarding
                    ? const OnboardingScreen()
                    : Router(
                  routerDelegate: _appRouter,
                  backButtonDispatcher: RootBackButtonDispatcher(),
                );
              }
            },
          ),
        );
      }),
    );
  }
}

void addLicenses() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
}
