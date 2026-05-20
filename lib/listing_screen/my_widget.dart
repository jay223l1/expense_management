import 'package:flutter/material.dart';
import 'listing_screen.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final List<Map<String, dynamic>> _entries = [];
  String _selectedFilter = "Monthly";

  // CREATE
  void _addEntry(Map<String, dynamic> entry) {
    setState(() {
      _entries.add(entry);
    });
  }

  // UPDATE
  void _updateEntry(int index, Map<String, dynamic> entry) {
    setState(() {
      _entries[index] = entry;
    });
  }

  // DELETE
  void _deleteEntry(int index) {
    setState(() {
      _entries.removeAt(index);
    });
  }

  // FILTER
  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListingScreen(
      entries: _entries,
      selectedFilter: _selectedFilter,
      onAddEntry: _addEntry,
      onUpdateEntry: _updateEntry,
      onDeleteEntry: _deleteEntry,
      onFilterChanged: _onFilterChanged,
    );
  }
}