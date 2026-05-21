import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'add_entry_screen.dart';
import 'entry_detail_screen.dart';

class ListingScreen extends StatelessWidget {
  final List<Map<String, dynamic>> entries;
  final String selectedFilter;
  final Function(Map<String, dynamic>) onAddEntry;
  final Function(int, Map<String, dynamic>) onUpdateEntry;
  final Function(int) onDeleteEntry;
  final Function(String) onFilterChanged;

  const ListingScreen({
    super.key,
    required this.entries,
    required this.selectedFilter,
    required this.onAddEntry,
    required this.onUpdateEntry,
    required this.onDeleteEntry,
    required this.onFilterChanged,
  });

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
        return date.month == now.month && date.year == now.year;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredEntries = getFilteredEntries();

    double cashIn = filteredEntries
        .where((e) => e['type'] == 'Cash In')
        .fold<double>(0.0, (sum, item) => sum + item['amount']);

    double cashOut = filteredEntries
        .where((e) => e['type'] == 'Cash Out')
        .fold<double>(0.0, (sum, item) => sum + item['amount']);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cash Mate"),
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
                  colors: [Colors.teal, Colors.green],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // FILTERS
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterButton(context, "Daily"),
                        const SizedBox(width: 10),
                        _filterButton(context, "Weekly"),
                        const SizedBox(width: 10),
                        _filterButton(context, "Monthly"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // TOTALS
                  Row(
                    children: [
                      Expanded(
                        child: _totalCard("Cash In", cashIn, Colors.green),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _totalCard("Cash Out", cashOut, Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // HEADER ROW
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Date",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Cash In",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Cash Out",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
              child: filteredEntries.isEmpty
                  ? const Center(
                      child: Text(
                        "No entries found.\nTap Cash In or Cash Out to add one.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredEntries.length,
                      itemBuilder: (context, index) {
                        final entry = filteredEntries[index];
                        bool isCashIn = entry['type'] == "Cash In";

                        return GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EntryDetailScreen(
                                  entry: entry,
                                ),
                              ),
                            );

                            if (result != null) {
                              if (result == "delete") {
                                // DELETE
                                onDeleteEntry(entries.indexOf(entry));
                              } else {
                                // UPDATE
                                onUpdateEntry(entries.indexOf(entry), result);
                              }
                            }
                          },
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          entry['title'],
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          DateFormat('dd MMM yyyy')
                                              .format(entry['date']),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          DateFormat('hh:mm a')
                                              .format(entry['date']),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // CASH IN column
                                  Expanded(
                                    child: Center(
                                      child: isCashIn
                                          ? FittedBox(
                                              child: Text(
                                                '₹${entry['amount']}',
                                                style: const TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                          : const Text("-"),
                                    ),
                                  ),

                                  // CASH OUT column
                                  Expanded(
                                    child: Center(
                                      child: !isCashIn
                                          ? FittedBox(
                                              child: Text(
                                                '₹${entry['amount']}',
                                                style: const TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                          : const Text("-"),
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
            // CREATE - Cash In
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddEntryScreen(
                        type: "Cash In",
                      ),
                    ),
                  );

                  if (result != null) {
                    onAddEntry(result);
                  }
                },
                child: const Text("Cash In"),
              ),
            ),

            const SizedBox(width: 12),

            // CREATE - Cash Out
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddEntryScreen(
                        type: "Cash Out",
                      ),
                    ),
                  );

                  if (result != null) {
                    onAddEntry(result);
                  }
                },
                child: const Text("Cash Out"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterButton(BuildContext context, String text) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            selectedFilter == text ? Colors.white : Colors.white24,
      ),
      onPressed: () {
        onFilterChanged(text);
      },
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: selectedFilter == text ? Colors.teal : Colors.white,
        ),
      ),
    );
  }

  Widget _totalCard(String title, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              '₹${amount.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}