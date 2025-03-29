import 'package:flutter/material.dart';
import 'package:habo/habits/empty_list_image.dart';
import 'package:habo/habits/habit.dart';
import 'package:habo/habits/habits_manager.dart';
import 'package:provider/provider.dart';

class CalendarColumn extends StatefulWidget {
  const CalendarColumn({super.key});

  @override
  State<CalendarColumn> createState() => CalendarColumnState();
}

class CalendarColumnState extends State<CalendarColumn>
    with AutomaticKeepAliveClientMixin {
  // Local list to manage reordering without triggering full rebuilds
  List<Habit> _habits = [];
  bool _isReordering = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateHabitsList();
    });
  }

  void _updateHabitsList() {
    // Only update from provider if not in the middle of reordering
    if (!_isReordering) {
      final habits =
          Provider.of<HabitsManager>(context, listen: false).getAllHabits;
      if (!mounted) return;
      setState(() {
        _habits = List.from(habits); // Create a new copy
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateHabitsList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin

    const Color softYellow = Color(0xFFF9EBC8);
    const Color leafGreen = Color(0xFF4D6E5E);
    const Color dustyPink = Color(0xFFF8C3B5);

    // Use Consumer to properly listen to changes in habits list
    return Consumer<HabitsManager>(
      builder: (context, habitsManager, _) {
        // Update local list if not reordering and if there's a change
        if (!_isReordering &&
            (_habits.isEmpty ||
                _habits.length != habitsManager.getAllHabits.length)) {
          _habits = List.from(habitsManager.getAllHabits);
        }

        return (_habits.isNotEmpty)
            ? NotificationListener<ScrollNotification>(
                onNotification: (_) {
                  // Avoid rebuilds during scroll
                  return true;
                },
                child: ReorderableListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 120),
                  itemCount: _habits.length,
                  itemBuilder: (context, index) {
                    final habit = _habits[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 6.0),
                      key: ValueKey(habit),
                      decoration: BoxDecoration(
                        color: softYellow.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.7),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: leafGreen.withOpacity(0.2),
                            offset: const Offset(0, 3),
                            blurRadius: 5,
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ReorderableDragStartListener(
                            key: ValueKey('drag-${habit.habitData.id}'),
                            index: index,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: dustyPink.withOpacity(0.3),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  bottomLeft: Radius.circular(16),
                                ),
                              ),
                              child: const Icon(
                                Icons.drag_handle_rounded,
                                color: leafGreen,
                                size: 24,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: habit,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  onReorderStart: (index) {
                    // Set flag to prevent provider updates during reordering
                    setState(() {
                      _isReordering = true;
                    });
                  },
                  onReorderEnd: (index) {
                    // After reordering is done, we can sync with provider
                    Future.delayed(Duration.zero, () {
                      if (mounted) {
                        setState(() {
                          _isReordering = false;
                        });
                        // Update provider after local reordering is complete
                        habitsManager.setHabitsList(_habits);
                      }
                    });
                  },
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final Habit item = _habits.removeAt(oldIndex);
                      _habits.insert(newIndex, item);
                    });
                  },
                ),
              )
            : const EmptyListImage();
      },
    );
  }
}
