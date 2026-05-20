import 'package:flutter/material.dart';
import 'listing_screen/listing_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<Map<String, dynamic>> _entries = [];
  String _selectedFilter = 'Monthly';

  void _addEntry(Map<String, dynamic> entry) {
    setState(() {
      _entries.add(entry);
    });
  }

  void _updateEntry(int index, Map<String, dynamic> entry) {
    setState(() {
      _entries[index] = entry;
    });
  }

  void _deleteEntry(int index) {
    setState(() {
      _entries.removeAt(index);
    });
  }

  void _changeFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ListingScreen(
        entries: _entries,
        selectedFilter: _selectedFilter,
        onAddEntry: _addEntry,
        onUpdateEntry: _updateEntry,
        onDeleteEntry: _deleteEntry,
        onFilterChanged: _changeFilter,
      ),
    );
  }
}
