import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ActivityHistoryView.dart';
import 'ActivityProvider.dart'; // Import the provider
import '../controller/ActivityController.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch providers
    final selectedType = ref.watch(selectedTypeProvider);
    final currentActivity = ref.watch(currentActivityProvider);
    final activityHistory = ref.watch(activityHistoryProvider);
    final loadSelectedTypeAsync = ref.watch(loadSelectedTypeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bored API Explorer"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Use AsyncValue to load selected type from SharedPreferences
            loadSelectedTypeAsync.when(
              data: (loadedType) {
                return DropdownButton<String>(
                  value: selectedType.isEmpty ? loadedType : selectedType,
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
                    ref.read(selectedTypeProvider.notifier).state = newType;
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stackTrace) => Text('Error: $error'),
            ),

            // Clear selected type from SharedPreferences
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('selected_type');
                ref.read(selectedTypeProvider.notifier).state = '';
              },
              child: const Text(
                "Clear Selection",
                style: TextStyle(color: Colors.blue),
              ),
            ),

            // Fetch new activity and update state + history
            ElevatedButton(
              onPressed: () async {
                final activity = await ref.read(randomActivityProvider.future);
                if (activity != null) {
                  ref.read(currentActivityProvider.notifier).state = activity;
                  final history = await ActivityController().getHistory();
                  ref.read(activityHistoryProvider.notifier).state = history;
                }
              },
              child: const Text("Next"),
            ),
            const SizedBox(height: 20),

            // Show current activity
            if (currentActivity != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(currentActivity.activity, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text("Price: \$${currentActivity.price.toStringAsFixed(2)}"),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Navigate to Activity History screen
            ElevatedButton(
              onPressed: () async {
                ref.refresh(activityHistoryFetchProvider);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActivityHistoryView(
                      history: activityHistory,
                      selectedType: selectedType,
                    ),
                  ),
                );
              },
              child: const Text("History"),
            ),
          ],
        ),
      ),
    );
  }
}
