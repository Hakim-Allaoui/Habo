import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:habo/constants.dart';
import 'package:habo/generated/l10n.dart';
import 'package:habo/habits/habits_manager.dart';
import 'package:habo/model/habit_data.dart';
import 'package:habo/navigation/routes.dart';
import 'package:habo/notifications.dart';
import 'package:habo/widgets/text_container.dart';
import 'package:provider/provider.dart';

class EditHabitScreen extends StatefulWidget {
  static MaterialPage page(HabitData? data) {
    return MaterialPage(
      name: (data != null) ? Routes.editHabitPath : Routes.createHabitPath,
      key: (data != null)
          ? ValueKey(Routes.editHabitPath)
          : ValueKey(Routes.createHabitPath),
      child: EditHabitScreen(habitData: data),
    );
  }

  const EditHabitScreen({super.key, required this.habitData});

  final HabitData? habitData;

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  TextEditingController title = TextEditingController();
  TextEditingController cue = TextEditingController();
  TextEditingController routine = TextEditingController();
  TextEditingController reward = TextEditingController();
  TextEditingController sanction = TextEditingController();
  TextEditingController accountant = TextEditingController();
  TimeOfDay notTime = const TimeOfDay(hour: 12, minute: 0);
  bool twoDayRule = false;
  bool showReward = false;
  bool advanced = false;
  bool notification = false;
  bool showSanction = false;

  Future<void> setNotificationTime(context) async {
    TimeOfDay? selectedTime;
    TimeOfDay initialTime = notTime;
    selectedTime =
        await showTimePicker(context: context, initialTime: initialTime);
    if (selectedTime != null) {
      setState(() {
        notTime = selectedTime!;
      });
    }
  }

  void showSmallTooltip(BuildContext context, String title, String desc) {
    AwesomeDialog(
      context: context,
      dialogBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
      dialogType: DialogType.info,
      headerAnimationLoop: false,
      animType: AnimType.bottomSlide,
      title: title,
      desc: desc,
    ).show();
  }

  void showAdvancedTooltip(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
      dialogType: DialogType.info,
      headerAnimationLoop: false,
      animType: AnimType.bottomSlide,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 28),
        child: Column(
          children: [
            Text(
              S.of(context).habitLoop,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  TextSpan(
                    text: S.of(context).habitLoopDescription,
                  ),
                  const TextSpan(
                    text: '\n\n',
                  ),
                  TextSpan(
                    text: S.of(context).cue,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: S.of(context).cueDescription,
                  ),
                  const TextSpan(
                    text: '\n\n',
                  ),
                  TextSpan(
                    text: S.of(context).routine,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: S.of(context).routineDescription,
                  ),
                  const TextSpan(
                    text: '\n\n',
                  ),
                  TextSpan(
                    text: S.of(context).reward,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: S.of(context).rewardDescription,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).show();
  }

  @override
  void initState() {
    super.initState();
    if (widget.habitData != null) {
      title.text = widget.habitData!.title;
      cue.text = widget.habitData!.cue;
      routine.text = widget.habitData!.routine;
      reward.text = widget.habitData!.reward;
      twoDayRule = widget.habitData!.twoDayRule;
      showReward = widget.habitData!.showReward;
      advanced = widget.habitData!.advanced;
      notification = widget.habitData!.notification;
      notTime = widget.habitData!.notTime;
      sanction.text = widget.habitData!.sanction;
      showSanction = widget.habitData!.showSanction;
      accountant.text = widget.habitData!.accountant;
    }
  }

  @override
  void dispose() {
    title.dispose();
    cue.dispose();
    routine.dispose();
    reward.dispose();
    sanction.dispose();
    accountant.dispose();
    super.dispose();
  }

  Widget _buildCustomTextContainer({
    required TextEditingController controller,
    required String hint,
    required String label,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextContainer(
        title: controller,
        hint: hint,
        label: label,
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required VoidCallback onInfoTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Transform.scale(
            scale: 1.1,
            child: Checkbox(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: onChanged,
              value: value,
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          IconButton(
            onPressed: onInfoTap,
            icon: Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(1, 1),
              blurRadius: 2,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          (widget.habitData != null)
              ? S.of(context).editHabit
              : S.of(context).createHabit,
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
        actions: <Widget>[
          if (widget.habitData != null)
            IconButton(
              icon: Icon(
                Icons.delete,
                semanticLabel: S.of(context).delete,
                size: 28,
              ),
              color: HaboColors.red,
              tooltip: S.of(context).delete,
              onPressed: () {
                Navigator.of(context).pop();
                if (widget.habitData != null) {
                  Provider.of<HabitsManager>(context, listen: false)
                      .deleteHabit(widget.habitData!.id!);
                }
              },
            ),
        ],
      ),
      floatingActionButton: Builder(builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.primary,
            onPressed: () {
              if (title.text.isNotEmpty) {
                if (widget.habitData != null) {
                  Provider.of<HabitsManager>(context, listen: false).editHabit(
                    HabitData(
                      id: widget.habitData!.id,
                      title: title.text.toString(),
                      twoDayRule: twoDayRule,
                      cue: cue.text.toString(),
                      routine: routine.text.toString(),
                      reward: reward.text.toString(),
                      showReward: showReward,
                      advanced: advanced,
                      notification: notification,
                      notTime: notTime,
                      position: widget.habitData!.position,
                      events: widget.habitData!.events,
                      sanction: sanction.text.toString(),
                      showSanction: showSanction,
                      accountant: accountant.text.toString(),
                    ),
                  );
                } else {
                  Provider.of<HabitsManager>(context, listen: false).addHabit(
                    title.text.toString(),
                    twoDayRule,
                    cue.text.toString(),
                    routine.text.toString(),
                    reward.text.toString(),
                    showReward,
                    advanced,
                    notification,
                    notTime,
                    sanction.text.toString(),
                    showSanction,
                    accountant.text.toString(),
                  );
                }
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    behavior: SnackBarBehavior.floating,
                    content: Text(S.of(context).habitTitleEmptyError),
                  ),
                );
              }
            },
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 35.0,
            ),
          ),
        );
      }),
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
        child: Builder(
          builder: (BuildContext context) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: 100, bottom: 30),
              child: Center(
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.all(15),
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
                      child: _buildCustomTextContainer(
                        controller: title,
                        hint: S.of(context).exercise,
                        label: S.of(context).habit,
                      ),
                    ),
                    _buildCheckboxTile(
                      title: S.of(context).useTwoDayRule,
                      value: twoDayRule,
                      onChanged: (bool? value) {
                        setState(() {
                          twoDayRule = value!;
                        });
                      },
                      onInfoTap: () {
                        showSmallTooltip(context, S.of(context).twoDayRule,
                            S.of(context).twoDayRuleDescription);
                      },
                    ),
                    const SizedBox(height: 10),
                    Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 2,
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withOpacity(0.9),
                      child: ExpansionTile(
                        shape: const Border(),
                        backgroundColor: Colors.transparent,
                        collapsedBackgroundColor: Colors.transparent,
                        tilePadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        title: Text(
                          S.of(context).advancedHabitBuilding,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        initiallyExpanded: advanced,
                        onExpansionChanged: (bool value) {
                          setState(() {
                            advanced = value;
                          });
                        },
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: 15,
                                ),
                                children: [
                                  TextSpan(
                                    text: S
                                        .of(context)
                                        .advancedHabitBuildingDescription,
                                  ),
                                  WidgetSpan(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 0, 0, 0),
                                      child: GestureDetector(
                                        onTap: () {
                                          showAdvancedTooltip(context);
                                        },
                                        child: Icon(
                                          Icons.info_outline,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.6),
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          _buildSectionTitle(S.of(context).cue),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildCustomTextContainer(
                              controller: cue,
                              hint: S.of(context).at7AM,
                              label: S.of(context).cue,
                            ),
                          ),
                          if (platformSupportsNotifications())
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surface
                                    .withOpacity(0.7),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.notifications_none,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      S.of(context).notifications,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                  ),
                                  Switch(
                                    value: notification,
                                    onChanged: (value) {
                                      setState(() {
                                        notification = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          if (platformSupportsNotifications())
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: notification ? 8 : 0),
                              height: notification ? 60 : 0,
                              decoration: BoxDecoration(
                                color: notification
                                    ? Theme.of(context)
                                        .colorScheme
                                        .surface
                                        .withOpacity(0.7)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: notification
                                  ? Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            S.of(context).notificationTime,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () =>
                                              setNotificationTime(context),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${notTime.hour.toString().padLeft(2, '0')}:${notTime.minute.toString().padLeft(2, '0')}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : null,
                            ),
                          const SizedBox(height: 15),
                          _buildSectionTitle(S.of(context).routine),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildCustomTextContainer(
                              controller: routine,
                              hint: S.of(context).do50PushUps,
                              label: S.of(context).routine,
                            ),
                          ),
                          _buildSectionTitle(S.of(context).reward),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildCustomTextContainer(
                              controller: reward,
                              hint: S.of(context).fifteenMinOfVideoGames,
                              label: S.of(context).reward,
                            ),
                          ),
                          _buildCheckboxTile(
                            title: S.of(context).showReward,
                            value: showReward,
                            onChanged: (bool? value) {
                              setState(() {
                                showReward = value!;
                              });
                            },
                            onInfoTap: () {
                              showSmallTooltip(
                                context,
                                S.of(context).showReward,
                                S.of(context).remainderOfReward,
                              );
                            },
                          ),
                          const SizedBox(height: 15),
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  S.of(context).habitContract,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  S.of(context).habitContractDescription,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          _buildSectionTitle(S.of(context).sanction),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildCustomTextContainer(
                              controller: sanction,
                              hint: S.of(context).donateToCharity,
                              label: S.of(context).sanction,
                            ),
                          ),
                          _buildCheckboxTile(
                            title: S.of(context).showSanction,
                            value: showSanction,
                            onChanged: (bool? value) {
                              setState(() {
                                showSanction = value!;
                              });
                            },
                            onInfoTap: () {
                              showSmallTooltip(
                                context,
                                S.of(context).showSanction,
                                S.of(context).remainderOfSanction,
                              );
                            },
                          ),
                          const SizedBox(height: 15),
                          _buildSectionTitle(
                              S.of(context).accountabilityPartner),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildCustomTextContainer(
                              controller: accountant,
                              hint: S.of(context).dan,
                              label: S.of(context).accountabilityPartner,
                            ),
                          ),
                          const SizedBox(height: 110),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
