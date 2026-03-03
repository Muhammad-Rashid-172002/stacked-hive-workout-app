import 'package:fitness_tracker_app/components/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/history_model.dart';


class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Box<HistoryModel> historyBox;

  @override
  void initState() {
    super.initState();
    historyBox = Hive.box<HistoryModel>('history');
  }

  @override
  Widget build(BuildContext context) {
    final historyList =
        historyBox.values.toList().reversed.toList();

    return Scaffold(
      backgroundColor: AppTheme.jetBlack,

      /// 🔥 Premium Dark Header
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: AppBar(
          automaticallyImplyLeading: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            padding: const EdgeInsets.fromLTRB(20, 55, 20, 25),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryRed,
                  AppTheme.darkRed,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment.end,
                  children: [
                    Text(
                      "Workout History",
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Your completed sessions",
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),

                /// Delete Button
                if (historyList.isNotEmpty)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_forever,
                      color: AppTheme.textPrimary,
                      size: 28,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor:
                              AppTheme.surface,
                          title: const Text(
                            "Clear History",
                            style: TextStyle(
                                color: AppTheme.textPrimary),
                          ),
                          content: const Text(
                            "Are you sure you want to delete all workout history?",
                            style: TextStyle(
                                color:
                                    AppTheme.textSecondary),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                    color: AppTheme
                                        .textSecondary),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                historyBox.clear();
                                setState(() {});
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Clear",
                                style: TextStyle(
                                    color:
                                        AppTheme.primaryRed),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),

      /// 🔥 BODY
      body: historyList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.history_toggle_off,
                    size: 80,
                    color: AppTheme.textMuted,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "No Workout History",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Complete workouts to see records here",
                    style: TextStyle(
                        color:
                            AppTheme.textSecondary),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historyList.length,
              itemBuilder: (_, i) {
                final h = historyList[i];

                final formattedDate = DateFormat(
                  'dd MMM yyyy • hh:mm a',
                ).format(h.date);

                return Container(
                  margin:
                      const EdgeInsets.only(bottom: 16),
                  padding:
                      const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius:
                        BorderRadius.circular(20),
                    border: Border.all(
                        color: AppTheme.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.3),
                        blurRadius: 10,
                        offset:
                            const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [

                      /// Icon Box
                      Container(
                        padding:
                            const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme
                              .primaryRed
                              .withOpacity(0.15),
                          borderRadius:
                              BorderRadius.circular(
                                  16),
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          color:
                              AppTheme.primaryRed,
                          size: 26,
                        ),
                      ),

                      const SizedBox(width: 16),

                      /// Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              h.exerciseName,
                              style:
                                  const TextStyle(
                                color: AppTheme
                                    .textPrimary,
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                                height: 6),
                            Text(
                              h.categoryName,
                              style:
                                  const TextStyle(
                                color: AppTheme
                                    .textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(
                                height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons
                                      .calendar_month,
                                  size: 14,
                                  color: AppTheme
                                      .textMuted,
                                ),
                                const SizedBox(
                                    width: 6),
                                Text(
                                  formattedDate,
                                  style:
                                      const TextStyle(
                                    color: AppTheme
                                        .textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      /// Duration Badge
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              AppTheme.primaryRed,
                          borderRadius:
                              BorderRadius.circular(
                                  12),
                        ),
                        // child: Text(
                        //  // "${h.duration}s",
                        //   style:
                        //       const TextStyle(
                        //     color: AppTheme
                        //         .textPrimary,
                        //     fontWeight:
                        //         FontWeight.bold,
                        //     fontSize: 12,
                        //   ),
                        // ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
