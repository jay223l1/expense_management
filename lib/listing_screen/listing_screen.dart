import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'add_entry_screen.dart';
import 'entry_detail_screen.dart';

class ListingScreen extends StatefulWidget {
  const ListingScreen({super.key});

  @override
  State<ListingScreen> createState() =>
      _ListingScreenState();
}

class _ListingScreenState
    extends State<ListingScreen> {
  final List<Map<String, dynamic>> entries = [];

  String selectedFilter = "Daily";

  void addEntry(Map<String, dynamic> entry) {
    setState(() {
      entries.add(entry);
    });
  }

  void updateEntry(
    int index,
    Map<String, dynamic> updatedEntry,
  ) {
    setState(() {
      entries[index] = updatedEntry;
    });
  }

  void deleteEntry(int index) {
    setState(() {
      entries.removeAt(index);
    });
  }

  List<Map<String, dynamic>> getFilteredEntries() {
    DateTime now = DateTime.now();

    return entries.where((entry) {
      DateTime date = entry['date'];

      if (selectedFilter == "Daily") {
        return date.day == now.day &&
            date.month == now.month &&
            date.year == now.year;
      }

      if (selectedFilter == "Weekly") {
        return now.difference(date).inDays <= 7;
      }

      if (selectedFilter == "Monthly") {
        return date.month == now.month &&
            date.year == now.year;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredEntries = getFilteredEntries();

    double cashIn = filteredEntries
        .where((e) => e['type'] == 'Cash In')
        .fold(
          0,
          (sum, item) => sum + item['amount'],
        );

    double cashOut = filteredEntries
        .where((e) => e['type'] == 'Cash Out')
        .fold(
          0,
          (sum, item) => sum + item['amount'],
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Manager"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // TOP BAR
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Colors.teal,
                    Colors.green,
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(20),
              ),

              child: Column(
                children: [
                  // FILTERS
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceEvenly,
                    children: [
                      filterButton("Daily"),
                      filterButton("Weekly"),
                      filterButton("Monthly"),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // TOTALS
                  Row(
                    children: [
                      Expanded(
                        child: totalCard(
                          "Cash In",
                          cashIn,
                          Colors.green,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: totalCard(
                          "Cash Out",
                          cashOut,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // HEADER
            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius:
                    BorderRadius.circular(12),
              ),

              child: Row(
                children: const [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Date",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  Expanded(
                    child: Center(
                      child: Text(
                        "Cash In",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Center(
                      child: Text(
                        "Cash Out",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // LIST
            Expanded(
              child: ListView.builder(
                itemCount:
                    filteredEntries.length,

                itemBuilder: (
                  context,
                  index,
                ) {
                  final entry =
                      filteredEntries[index];

                  bool isCashIn =
                      entry['type'] ==
                          "Cash In";

                  return GestureDetector(
                    onTap: () async {
                      final result =
                          await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  EntryDetailScreen(
                            entry: entry,
                          ),
                        ),
                      );

                      if (result != null) {
                        if (result ==
                            "delete") {
                          deleteEntry(
                            entries.indexOf(
                              entry,
                            ),
                          );
                        } else {
                          updateEntry(
                            entries.indexOf(
                              entry,
                            ),
                            result,
                          );
                        }
                      }
                    },

                    child: Card(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(
                          14,
                        ),

                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,

                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [
                                  Text(
                                    entry['title'],
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),

                                  Text(
                                    DateFormat(
                                      'dd MMM yyyy',
                                    ).format(
                                      entry['date'],
                                    ),
                                  ),

                                  Text(
                                    DateFormat(
                                      'hh:mm a',
                                    ).format(
                                      entry['date'],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Expanded(
                              child: Center(
                                child: isCashIn
                                    ? Text(
                                        '₹${entry['amount']}',
                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.green,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      )
                                    : const Text(
                                        "-",
                                      ),
                              ),
                            ),

                            Expanded(
                              child: Center(
                                child: !isCashIn
                                    ? Text(
                                        '₹${entry['amount']}',
                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.red,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      )
                                    : const Text(
                                        "-",
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // BOTTOM BUTTONS
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),

        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green,
                ),

                onPressed: () async {
                  final result =
                      await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              const AddEntryScreen(
                        type: "Cash In",
                      ),
                    ),
                  );

                  if (result != null) {
                    addEntry(result);
                  }
                },

                child: const Text(
                  "Cash In",
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.red,
                ),

                onPressed: () async {
                  final result =
                      await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              const AddEntryScreen(
                        type: "Cash Out",
                      ),
                    ),
                  );

                  if (result != null) {
                    addEntry(result);
                  }
                },

                child: const Text(
                  "Cash Out",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget filterButton(String text) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            selectedFilter == text
                ? Colors.white
                : Colors.white24,
      ),

      onPressed: () {
        setState(() {
          selectedFilter = text;
        });
      },

      child: Text(
        text,
        style: TextStyle(
          color:
              selectedFilter == text
                  ? Colors.teal
                  : Colors.white,
        ),
      ),
    );
  }

  Widget totalCard(
    String title,
    double amount,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius:
            BorderRadius.circular(14),
      ),

      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}