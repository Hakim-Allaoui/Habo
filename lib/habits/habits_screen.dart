import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:habo/constants.dart';
import 'package:habo/generated/l10n.dart';
import 'package:habo/notifications.dart';
import 'package:provider/provider.dart';
import 'package:habo/habits/calendar_column.dart';
import 'package:habo/habits/habits_manager.dart';
import 'package:habo/settings/settings_manager.dart';
import 'package:habo/navigation/navigation.dart';

class HabitsScreen extends StatefulWidget {
  static MaterialPage page() {
    return MaterialPage(
      name: Routes.habitsPath,
      key: ValueKey(Routes.habitsPath),
      child: const HabitsScreen(),
    );
  }

  const HabitsScreen({
    super.key,
  });

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  // Removed SingleTickerProviderStateMixin
  final GlobalKey _calendarColumnKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (platformSupportsNotifications()) {
      Future.delayed(const Duration(seconds: 0), () async {
        showNotificationDialog(context);
      });
    }

    // Removed cloud animation setup
  }

  @override
  void dispose() {
    // Removed cloud animation controller disposal
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ghibli-inspired color palette
    const Color skyBlue = Color(0xFFB0E2FF);
    const Color grassGreen = Color(0xFF88C057);
    const Color leafGreen = Color(0xFF4D6E5E);
    const Color dustyPink = Color(0xFFF8C3B5);
    const Color softYellow = Color(0xFFF9EBC8);

    return Consumer<AppStateManager>(
      builder: (context, appStateManager, child) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: skyBlue,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(
              'Metoera App Tracker',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 24,
                color: leafGreen,
                shadows: [
                  Shadow(
                    blurRadius: 2.0,
                    color: Colors.white.withOpacity(0.7),
                    offset: const Offset(1.0, 1.0),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              // Statistics button with Ghibli styling
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Provider.of<HabitsManager>(context, listen: false)
                          .hideSnackBar();
                      Provider.of<AppStateManager>(context, listen: false)
                          .goStatistics(true);
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.6), width: 1),
                      ),
                      child: SvgPicture.asset(
                        'assets/images/graph.svg',
                        semanticsLabel: S.of(context).settings,
                        width: 20,
                        colorFilter: const ColorFilter.mode(
                          leafGreen,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Settings button with Ghibli styling
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Provider.of<AppStateManager>(context, listen: false)
                          .goSettings(true);
                      Provider.of<HabitsManager>(context, listen: false)
                          .hideSnackBar();
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.6), width: 1),
                      ),
                      child: SvgPicture.asset(
                        'assets/images/settings.svg',
                        semanticsLabel: S.of(context).settings,
                        width: 20,
                        colorFilter: const ColorFilter.mode(
                          leafGreen,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              // Removed cloud animation elements

              // Grass-like decoration at the bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    height: 70,
                    color: grassGreen,
                  ),
                ),
              ),

              // Main calendar content
              SafeArea(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: CalendarColumn(
                    key: _calendarColumnKey,
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Provider.of<AppStateManager>(context, listen: false)
                  .goCreateHabit(true);
              Provider.of<HabitsManager>(context, listen: false).hideSnackBar();
            },
            backgroundColor: dustyPink,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: Colors.white.withOpacity(0.7),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.add,
              color: leafGreen,
              semanticLabel: S.of(context).add,
              size: 35.0,
            ),
          ),
        );
      },
    );
  }

  // Removed _buildCloud method

  void showNotificationDialog(BuildContext context) {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        showRestoreDialog(context);
      } else {
        resetNotifications();
      }
    });
  }

  void showRestoreDialog(BuildContext context) {
    // Ghibli-inspired color palette
    const Color leafGreen = Color(0xFF4D6E5E);
    const Color skyBlue = Color(0xFFB0E2FF);
    const Color softYellow = Color(0xFFF9EBC8);

    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      headerAnimationLoop: false,
      animType: AnimType.bottomSlide,
      title: S.of(context).notifications,
      desc: S.of(context).haboNeedsPermission,
      btnOkText: S.of(context).allow,
      btnCancelText: S.of(context).cancel,
      btnCancelColor: Colors.grey[400],
      btnOkColor: leafGreen,
      dialogBackgroundColor: softYellow,
      borderSide: const BorderSide(color: leafGreen, width: 2),
      titleTextStyle: const TextStyle(
        fontSize: 22,
        color: leafGreen,
        fontWeight: FontWeight.w600,
      ),
      descTextStyle: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      buttonsBorderRadius: BorderRadius.circular(20),
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        AwesomeNotifications()
            .requestPermissionToSendNotifications()
            .then((value) {
          resetNotifications();
        });
      },
    ).show();
  }

  void resetNotifications() {
    Provider.of<SettingsManager>(context, listen: false).resetAppNotification();
    Provider.of<HabitsManager>(context, listen: false)
        .resetHabitsNotifications();
  }
}

// Custom clipper for wave-like grass effect
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 20);

    // Create a wave pattern
    for (int i = 0; i < size.width.toInt(); i++) {
      if (i % 2 == 0) {
        path.lineTo(size.width - i.toDouble(), 30 + 10 * (i % 5) / 5);
      } else {
        path.lineTo(size.width - i.toDouble(), 40 - 15 * (i % 7) / 7);
      }
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
