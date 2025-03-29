import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:habo/constants.dart';
import 'package:habo/extensions.dart';
import 'package:habo/generated/l10n.dart';
import 'package:habo/habits/habits_manager.dart';
import 'package:habo/navigation/app_state_manager.dart';
import 'package:habo/navigation/routes.dart';
import 'package:habo/notifications.dart';
import 'package:habo/settings/color_icon.dart';
import 'package:habo/settings/settings_manager.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  static MaterialPage page() {
    return MaterialPage(
      name: Routes.settingsPath,
      key: ValueKey(Routes.settingsPath),
      child: const SettingsScreen(),
    );
  }

  const SettingsScreen({
    super.key,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  Future<void> testTime(context) async {
    TimeOfDay? selectedTime;
    TimeOfDay initialTime =
        Provider.of<SettingsManager>(context, listen: false).getDailyNot;
    selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (selectedTime != null) {
      Provider.of<SettingsManager>(context, listen: false).setDailyNot =
          selectedTime;
    }
  }

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  showRestoreDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
      dialogType: DialogType.warning,
      headerAnimationLoop: false,
      animType: AnimType.bottomSlide,
      title: S.of(context).warning,
      desc: S.of(context).allHabitsWillBeReplaced,
      btnOkText: S.of(context).restore,
      btnCancelText: S.of(context).cancel,
      btnCancelColor: Colors.grey,
      btnOkColor: HaboColors.primary,
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        await Provider.of<HabitsManager>(context, listen: false)
            .loadBackup()
            .then(
              (value) => {
                if (!value)
                  {
                    Provider.of<HabitsManager>(context, listen: false)
                        .showErrorMessage(S.of(context).restoreFailedError),
                  }
              },
            );
      },
    ).show();
  }

  Widget _buildSettingsTile({
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    bool isEnabled = true,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isEnabled
            ? Theme.of(context).colorScheme.surface.withOpacity(0.8)
            : Theme.of(context).colorScheme.surface.withOpacity(0.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        enabled: isEnabled,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: isEnabled
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).disabledColor,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateManager>(
      builder: (
        context,
        appStateManager,
        child,
      ) {
        return LoaderOverlay(
          useDefaultLoading: false,
          overlayWidgetBuilder: (_) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const CircularProgressIndicator(
                  color: HaboColors.primary,
                  strokeWidth: 3,
                ),
              ),
            );
          },
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: Text(
                S.of(context).settings,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              iconTheme: IconThemeData(
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    Theme.of(context).colorScheme.surface,
                  ],
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 100, bottom: 30),
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.settings,
                            size: 30,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Personalize your experience",
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildSettingsTile(
                      title: S.of(context).theme,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton<Themes>(
                          underline: const SizedBox(),
                          borderRadius: BorderRadius.circular(12),
                          items: Themes.values.map((Themes value) {
                            return DropdownMenuItem<Themes>(
                              value: value,
                              child: Text(
                                S.of(context).themeSelect(value.name),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }).toList(),
                          value: Provider.of<SettingsManager>(context)
                              .getThemeString,
                          onChanged: (value) {
                            Provider.of<SettingsManager>(context, listen: false)
                                .setTheme = value!;
                          },
                        ),
                      ),
                    ),
                    _buildSettingsTile(
                      title: S.of(context).firstDayOfWeek,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton<dynamic>(
                          underline: const SizedBox(),
                          borderRadius: BorderRadius.circular(12),
                          alignment: Alignment.center,
                          items: StartingDayOfWeek.values.map((dynamic value) {
                            return DropdownMenuItem<dynamic>(
                              alignment: Alignment.center,
                              value: value,
                              child: Text(
                                DateFormat('E', Intl.getCurrentLocale())
                                    .dateSymbols
                                    .WEEKDAYS[(value.index + 1) % 7]
                                    .substring(0, 2)
                                    .capitalize(),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }).toList(),
                          value: Provider.of<SettingsManager>(context)
                              .getWeekStartEnum,
                          onChanged: (value) {
                            Provider.of<SettingsManager>(context, listen: false)
                                .setWeekStart = value;
                          },
                        ),
                      ),
                    ),
                    if (platformSupportsNotifications())
                      _buildSettingsTile(
                        title: S.of(context).notifications,
                        trailing: Switch(
                          value: Provider.of<SettingsManager>(context)
                              .getShowDailyNot,
                          onChanged: (value) async {
                            Provider.of<SettingsManager>(context, listen: false)
                                .setShowDailyNot = value;
                          },
                        ),
                      ),
                    if (platformSupportsNotifications())
                      _buildSettingsTile(
                        isEnabled: Provider.of<SettingsManager>(context)
                            .getShowDailyNot,
                        title: S.of(context).notificationTime,
                        trailing: InkWell(
                          onTap: () {
                            if (Provider.of<SettingsManager>(context,
                                    listen: false)
                                .getShowDailyNot) {
                              testTime(context);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Provider.of<SettingsManager>(context)
                                      .getShowDailyNot
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1)
                                  : Theme.of(context)
                                      .disabledColor
                                      .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${Provider.of<SettingsManager>(context).getDailyNot.hour.toString().padLeft(2, '0')}'
                              ':'
                              '${Provider.of<SettingsManager>(context).getDailyNot.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: (Provider.of<SettingsManager>(context)
                                        .getShowDailyNot)
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context).disabledColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    _buildSettingsTile(
                      title: S.of(context).soundEffects,
                      trailing: Switch(
                        value: Provider.of<SettingsManager>(context)
                            .getSoundEffects,
                        onChanged: (value) {
                          Provider.of<SettingsManager>(context, listen: false)
                              .setSoundEffects = value;
                        },
                      ),
                    ),
                    _buildSettingsTile(
                      title: S.of(context).showMonthName,
                      trailing: Switch(
                        value: Provider.of<SettingsManager>(context)
                            .getShowMonthName,
                        onChanged: (value) {
                          Provider.of<SettingsManager>(context, listen: false)
                              .setShowMonthName = value;
                        },
                      ),
                    ),
                    _buildSettingsTile(
                      title: S.of(context).setColors,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildColorIconWrapper(
                            ColorIcon(
                              color: Provider.of<SettingsManager>(context,
                                      listen: false)
                                  .checkColor,
                              icon: Icons.check,
                              defaultColor: HaboColors.primary,
                              onPicked: (value) {
                                Provider.of<SettingsManager>(context,
                                        listen: false)
                                    .checkColor = value;
                              },
                            ),
                          ),
                          _buildColorIconWrapper(
                            ColorIcon(
                              color: Provider.of<SettingsManager>(context,
                                      listen: false)
                                  .failColor,
                              icon: Icons.close,
                              defaultColor: HaboColors.red,
                              onPicked: (value) {
                                Provider.of<SettingsManager>(context,
                                        listen: false)
                                    .failColor = value;
                              },
                            ),
                          ),
                          _buildColorIconWrapper(
                            ColorIcon(
                              color: Provider.of<SettingsManager>(context,
                                      listen: false)
                                  .skipColor,
                              icon: Icons.last_page,
                              defaultColor: HaboColors.skip,
                              onPicked: (value) {
                                Provider.of<SettingsManager>(context,
                                        listen: false)
                                    .skipColor = value;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildSettingsTile(
                      title: S.of(context).backup,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildBackupButton(
                            S.of(context).create,
                            () async {
                              Provider.of<HabitsManager>(context, listen: false)
                                  .createBackup()
                                  .then(
                                    (value) => {
                                      if (!value)
                                        {
                                          Provider.of<HabitsManager>(context,
                                                  listen: false)
                                              .showErrorMessage(S
                                                  .of(context)
                                                  .backupFailedError),
                                        }
                                    },
                                  );
                            },
                          ),
                          Container(
                            height: 25,
                            width: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            color:
                                Theme.of(context).dividerColor.withOpacity(0.3),
                          ),
                          _buildBackupButton(
                            S.of(context).restore,
                            () async {
                              showRestoreDialog(context);
                            },
                          ),
                        ],
                      ),
                    ),
                    _buildSettingsTile(
                      title: S.of(context).onboarding,
                      onTap: () {
                        Provider.of<AppStateManager>(context, listen: false)
                            .goOnboarding(true);
                      },
                    ),
                    _buildSettingsTile(
                      title: S.of(context).about,
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationIcon: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/images/icon.png',
                                width: 60,
                                height: 60,
                              ),
                            ),
                          ),
                          applicationName: 'Metoera App Tracker',
                          applicationVersion: _packageInfo.version,
                          applicationLegalese: '©2023 Habo',
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  children: [
                                    _buildLinkTextSpan(
                                      S.of(context).termsAndConditions,
                                      'https://habo.space/terms.html#terms',
                                    ),
                                    const TextSpan(text: '\n'),
                                    _buildLinkTextSpan(
                                      S.of(context).privacyPolicy,
                                      'https://habo.space/terms.html#privacy',
                                    ),
                                    const TextSpan(text: '\n'),
                                    _buildLinkTextSpan(
                                      S.of(context).disclaimer,
                                      'https://habo.space/terms.html#disclaimer',
                                    ),
                                    const TextSpan(text: '\n'),
                                    _buildLinkTextSpan(
                                      S.of(context).sourceCode,
                                      'https://github.com/xpavle00/Habo',
                                    ),
                                    const TextSpan(text: '\n\n'),
                                    TextSpan(
                                      text: S.of(context).ifYouWantToSupport,
                                    ),
                                    const TextSpan(text: '\n'),
                                    _buildLinkTextSpan(
                                      S.of(context).buyMeACoffee,
                                      'https://www.buymeacoffee.com/peterpavlenko',
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorIconWrapper(Widget child) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildBackupButton(String text, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  TextSpan _buildLinkTextSpan(String text, String url) {
    return TextSpan(
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        decoration: TextDecoration.underline,
      ),
      text: text,
      recognizer: TapGestureRecognizer()
        ..onTap = () async {
          final Uri uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
          }
        },
    );
  }
}
