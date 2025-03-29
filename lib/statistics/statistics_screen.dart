import 'package:flutter/material.dart';
import 'package:habo/constants.dart';
import 'package:habo/generated/l10n.dart';
import 'package:habo/habits/habits_manager.dart';
import 'package:habo/navigation/routes.dart';
import 'package:habo/statistics/empty_statistics_image.dart';
import 'package:habo/statistics/overall_statistics_card.dart';
import 'package:habo/statistics/statistics.dart';
import 'package:habo/statistics/statistics_card.dart';
import 'package:provider/provider.dart';

class StatisticsScreen extends StatefulWidget {
  static MaterialPage page() {
    return MaterialPage(
      name: Routes.statisticsPath,
      key: ValueKey(Routes.statisticsPath),
      child: const StatisticsScreen(),
    );
  }

  const StatisticsScreen({
    super.key,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          S.of(context).statistics,
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
        child: FutureBuilder(
          future: Provider.of<HabitsManager>(context).getFutureStatsData(),
          builder:
              (BuildContext context, AsyncSnapshot<AllStatistics> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.habitsData.isEmpty) {
                return const EmptyStatisticsImage();
              } else {
                return ListView(
                  padding: const EdgeInsets.only(
                      top: 100, left: 16, right: 16, bottom: 24),
                  scrollDirection: Axis.vertical,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    OverallStatisticsCard(
                      total: snapshot.data!.total,
                      habits: snapshot.data!.habitsData.length,
                    ),
                    const SizedBox(height: 12),
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: snapshot.data!.habitsData
                          .map(
                            (index) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12.0),
                              child: StatisticsCard(data: index),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                );
              }
            } else {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
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
            }
          },
        ),
      ),
    );
  }
}
