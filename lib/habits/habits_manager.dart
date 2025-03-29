import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:habo/constants.dart';
import 'package:habo/generated/l10n.dart';
import 'package:habo/habits/habit.dart';
import 'package:habo/model/backup.dart';
import 'package:habo/model/habit_data.dart';
import 'package:habo/model/habo_model.dart';
import 'package:habo/notifications.dart';
import 'package:habo/statistics/statistics.dart';

class HabitsManager extends ChangeNotifier {
  final HaboModel _haboModel = HaboModel();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  late List<Habit> allHabits = [];
  bool _isInitialized = false;

  Habit? deletedHabit;
  Queue<Habit> toDelete = Queue();

  void initialize() async {
    await initModel();
    notifyListeners();
  }

  resetHabitsNotifications() {
    resetNotifications(allHabits);
  }

  initModel() async {
    await _haboModel.initDatabase();
    allHabits = await _haboModel.getAllHabits();
    _isInitialized = true;
    notifyListeners();
  }

  GlobalKey<ScaffoldMessengerState> get getScaffoldKey {
    return _scaffoldKey;
  }

  void hideSnackBar() {
    _scaffoldKey.currentState!.hideCurrentSnackBar();
  }

  Future<bool> createBackup() async {
    try {
      final file = await Backup.writeBackup(allHabits);
      if (Platform.isAndroid || Platform.isIOS) {
        final params = SaveFileDialogParams(
          sourceFilePath: file.path,
          mimeTypesFilter: ['application/json'],
        );
        await FlutterFileDialog.saveFile(params: params);
      } else {
        final outputFile = await FilePicker.platform.saveFile(
          dialogTitle: '',
          type: FileType.custom,
          allowedExtensions: ['json'],
          fileName: file.path.split('/').last,
        );
        if (outputFile != null) {
          await file.copy(outputFile);
        }
      }
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<bool> loadBackup() async {
    try {
      final String? filePath;
      if (Platform.isAndroid || Platform.isIOS) {
        const params = OpenFileDialogParams(
          fileExtensionsFilter: ['json'],
          mimeTypesFilter: ['application/json'],
        );
        filePath = await FlutterFileDialog.pickFile(params: params);
      } else {
        filePath = (await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['json'],
                allowMultiple: false,
                withReadStream: Platform.isLinux))
            ?.files
            .first
            .path;
      }
      if (filePath == null) {
        return true;
      }
      final json = await Backup.readBackup(filePath);
      List<Habit> habits = [];
      jsonDecode(json).forEach((element) {
        habits.add(Habit.fromJson(element));
      });
      await _haboModel.useBackup(habits);
      removeNotifications(allHabits);
      allHabits = habits;
      resetNotifications(allHabits);
      notifyListeners();
    } catch (e) {
      return false;
    }
    return true;
  }

  resetNotifications(List<Habit> habits) {
    for (var element in habits) {
      if (element.habitData.notification) {
        var data = element.habitData;
        setHabitNotification(
            data.id!, data.notTime, 'Metoera App Tracker', data.title);
      }
    }
  }

  removeNotifications(List<Habit> habits) {
    for (var element in habits) {
      disableHabitNotification(element.habitData.id!);
    }
  }

  showErrorMessage(String message) {
    _scaffoldKey.currentState!.hideCurrentSnackBar();
    _scaffoldKey.currentState!.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: HaboColors.red,
      ),
    );
  }

  List<Habit> get getAllHabits {
    return allHabits;
  }

  bool get isInitialized {
    return _isInitialized;
  }

  reorderList(oldIndex, newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    Habit moved = allHabits.removeAt(oldIndex);
    allHabits.insert(newIndex, moved);
    updateOrder();

    _haboModel.updateOrder(allHabits).then((_) {
      Future.microtask(() => notifyListeners());
    });
  }

  addEvent(int id, DateTime dateTime, List event) {
    _haboModel.insertEvent(id, dateTime, event);
  }

  deleteEvent(int id, DateTime dateTime) {
    _haboModel.deleteEvent(id, dateTime);
  }

  addHabit(
      String title,
      bool twoDayRule,
      String cue,
      String routine,
      String reward,
      bool showReward,
      bool advanced,
      bool notification,
      TimeOfDay notTime,
      String sanction,
      bool showSanction,
      String accountant) async {
    // Make this function async
    Habit newHabit = Habit(
      habitData: HabitData(
        position: allHabits.length,
        title: title,
        twoDayRule: twoDayRule,
        cue: cue,
        routine: routine,
        reward: reward,
        showReward: showReward,
        advanced: advanced,
        events: SplayTreeMap<DateTime, List>(),
        notification: notification,
        notTime: notTime,
        sanction: sanction,
        showSanction: showSanction,
        accountant: accountant,
      ),
    );

    // Use await to make sure the habit is inserted before proceeding
    final id = await _haboModel.insertHabit(newHabit);
    newHabit.setId = id;
    allHabits.add(newHabit);

    if (notification) {
      setHabitNotification(id, notTime, 'Metoera App Tracker', title);
    } else {
      disableHabitNotification(id);
    }

    updateOrder();

    // Make sure UI updates on the main thread
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  editHabit(HabitData habitData) {
    Habit? hab = findHabitById(habitData.id!);
    if (hab == null) return;
    hab.habitData.title = habitData.title;
    hab.habitData.twoDayRule = habitData.twoDayRule;
    hab.habitData.cue = habitData.cue;
    hab.habitData.routine = habitData.routine;
    hab.habitData.reward = habitData.reward;
    hab.habitData.showReward = habitData.showReward;
    hab.habitData.advanced = habitData.advanced;
    hab.habitData.notification = habitData.notification;
    hab.habitData.notTime = habitData.notTime;
    hab.habitData.sanction = habitData.sanction;
    hab.habitData.showSanction = habitData.showSanction;
    hab.habitData.accountant = habitData.accountant;
    _haboModel.editHabit(hab);
    if (habitData.notification) {
      setHabitNotification(habitData.id!, habitData.notTime,
          'Metoera App Tracker', habitData.title);
    } else {
      disableHabitNotification(habitData.id!);
    }
    notifyListeners();
  }

  String getNameOfHabit(int id) {
    Habit? hab = findHabitById(id);
    return (hab != null) ? hab.habitData.title : '';
  }

  Habit? findHabitById(int id) {
    Habit? result;
    for (var hab in allHabits) {
      if (hab.habitData.id == id) {
        result = hab;
      }
    }
    return result;
  }

  deleteHabit(int id) async {
    // Make this function async
    deletedHabit = findHabitById(id);
    if (deletedHabit == null) return;

    // Make a temporary copy before removal
    final tempHabit = deletedHabit!;

    // Remove from the list
    allHabits.remove(deletedHabit);
    toDelete.addLast(tempHabit);

    // Update order
    updateOrder();

    // Force UI refresh on the main thread
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    // Show snackbar
    _scaffoldKey.currentState!.hideCurrentSnackBar();
    _scaffoldKey.currentState!.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Text(S.current.habitDeleted),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: S.current.undo,
          onPressed: () {
            undoDeleteHabit(tempHabit);
          },
        ),
      ),
    );

    // Schedule deletion from database
    Future.delayed(const Duration(seconds: 4), () => deleteFromDB());
  }

  // Modify undoDeleteHabit to ensure proper UI update
  undoDeleteHabit(Habit del) {
    if (del.habitData.id == null) return;

    toDelete.remove(del);

    if (del.habitData.position < allHabits.length) {
      allHabits.insert(del.habitData.position, del);
    } else {
      allHabits.add(del);
    }

    updateOrder();

    // Force UI refresh on the main thread
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> deleteFromDB() async {
    if (toDelete.isEmpty) return; // Safety check

    var habitToDelete = toDelete.first;
    disableHabitNotification(habitToDelete.habitData.id!);
    await _haboModel.deleteHabit(habitToDelete.habitData.id!);
    toDelete.removeFirst();

    if (toDelete.isNotEmpty) {
      Future.delayed(const Duration(seconds: 1), () => deleteFromDB());
    }
  }

  updateOrder() {
    int iterator = 0;
    for (var habit in allHabits) {
      habit.habitData.position = iterator++;
    }
  }

  Future<AllStatistics> getFutureStatsData() async {
    return await Statistics.calculateStatistics(allHabits);
  }

  void setHabitsList(List<Habit> habits) {
    allHabits = List.from(habits);
    updateOrder();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _haboModel.updateOrder(allHabits);
      notifyListeners();
    });
  }

  // Add method to force refresh UI
  void refreshUI() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
