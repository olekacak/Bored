import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ActivityHistoryView.dart';
import '../controller/ActivityController.dart';
import '../model/ActivityModel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<Activity> _history = []; // Activity history
  Activity? _currentActivity; // Current activity
  String _selectedType = ''; // Selected activity type

  @override
  void initState() {
    super.initState();
    _loadSelectedType();
  }

  void _loadSelectedType() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedType = prefs.getString('selected_type') ?? '';
    });
  }

  void _getActivity() async {
    Activity? activity = await ActivityController().getRandomActivity(type: _selectedType);
    if (activity != null) {
      setState(() {
        _currentActivity = activity;
      });
      await ActivityController().postHistory(activity); // Save to local storage (SharedPreferences)
    }
  }

  Future<void> _goToHistory() async {
    _history = await ActivityController().getHistory();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityHistoryView(
          history: _history,
          selectedType: _selectedType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bored API Explorer"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<String>(
              value: _selectedType,
              hint: const Text("Select Activity Type"),
              items: <String>['', 'recreational', 'social', 'education', 'diy', 'charity']
                  .map((type) => DropdownMenuItem<String>(
                value: type,
                child: Text(type.isEmpty ? "None" : type),
              ))
                  .toList(),
              onChanged: (value) async {
                final prefs = await SharedPreferences.getInstance();
                final newType = value ?? '';
                await prefs.setString('selected_type', newType);

                setState(() {
                  _selectedType = newType;
                });
              },
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('selected_type');
                setState(() {
                  _selectedType = '';
                });
              },
              child: const Text(
                "Clear Selection",
                style: TextStyle(color: Colors.blue),
              ),
            ),
            ElevatedButton(
              onPressed: _getActivity,
              child: const Text("Next"),
            ),
            const SizedBox(height: 20),
            if (_currentActivity != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_currentActivity!.activity, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text("Price: \$${_currentActivity!.price.toStringAsFixed(2)}"),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _goToHistory,
              child: const Text("History"),
            ),
          ],
        ),
      ),
    );
  }
}
