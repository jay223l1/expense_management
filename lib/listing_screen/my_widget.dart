import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'listing_screen.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  List<Map<String, dynamic>> _entries = [];
  String _selectedFilter = "Monthly";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? entriesString = prefs.getString('entries');
      if (entriesString != null) {
        final List<dynamic> decoded = jsonDecode(entriesString);
        setState(() {
          _entries = decoded.map<Map<String, dynamic>>((item) {
            final map = Map<String, dynamic>.from(item);
            return {
              'title': map['title'],
              'amount': (map['amount'] as num).toDouble(),
              'date': DateTime.parse(map['date'] as String),
              'type': map['type'],
            };
          }).toList();
        });
      }
    } catch (e) {
      debugPrint("Error loading entries: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> saveList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serialized = _entries.map((entry) => {
        'title': entry['title'],
        'amount': entry['amount'],
        'date': (entry['date'] as DateTime).toIso8601String(),
        'type': entry['type'],
      }).toList();
      final String entriesString = jsonEncode(serialized);
      await prefs.setString('entries', entriesString);
      if (entriesString != null) {
    print('List stored successfully');
    print(entriesString);
  } else {
    print('List not found');
    }

    } catch (e) {
      debugPrint("Error saving entries: $e");
    }
  }

  // CREATE
  void _addEntry(Map<String, dynamic> entry) {
    setState(() {
      _entries.add(entry);
    });
    saveList();
  }

  // UPDATE
  void _updateEntry(int index, Map<String, dynamic> entry) {
    setState(() {
      _entries[index] = entry;
    });
    saveList();
  }

  // DELETE
  void _deleteEntry(int index) {
    setState(() {
      _entries.removeAt(index);
    });
    saveList();
  }

  // FILTER
  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
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