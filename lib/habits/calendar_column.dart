import 'package:flutter/material.dart';
import 'package:habo/habits/calendar_header.dart';
import 'package:habo/habits/empty_list_image.dart';
import 'package:habo/habits/habit.dart';
import 'package:habo/habits/habits_manager.dart';
import 'package:provider/provider.dart';

class CalendarColumn extends StatelessWidget {
  const CalendarColumn({super.key});

  @override
  Widget build(BuildContext context) {
    List<Habit> calendars = Provider.of<HabitsManager>(context).getAllHabits;

    return (calendars.isNotEmpty)
        ? ReorderableListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 120),
            children: calendars
                .map(
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                    key: ObjectKey(index),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        ReorderableDragStartListener(
                          key: ObjectKey(index),
                          index: calendars.indexOf(index),
                          child: const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Icon(
                              Icons.drag_handle_rounded,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: index,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
            onReorder: (oldIndex, newIndex) {
              Provider.of<HabitsManager>(context, listen: false)
                  .reorderList(oldIndex, newIndex);
            },
          )
        : const EmptyListImage();
  }
}
