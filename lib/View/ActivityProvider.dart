import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/ActivityController.dart';
import '../model/ActivityModel.dart';

// Provider for the selected activity type
final selectedTypeProvider = StateProvider<String>((ref) {
  return ''; // Default value is an empty string (no selection)
});

// Provider for the current activity
final currentActivityProvider = StateProvider<Activity?>((ref) {
  return null; // Default value is null (no activity selected)
});

// Provider for the activity history
final activityHistoryProvider = StateProvider<List<Activity>>((ref) {
  return []; // Default value is an empty list
});

// Provider to load the selected type from SharedPreferences
final loadSelectedTypeProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('selected_type') ?? ''; // Return saved type or an empty string
});

// Provider to fetch a random activity
final randomActivityProvider = FutureProvider.autoDispose<Activity?>((ref) async {
  final selectedType = ref.watch(selectedTypeProvider);
  Activity? activity = await ActivityController().getRandomActivity(type: selectedType);
  if (activity != null) {
    // Save to local storage (SharedPreferences)
    await ActivityController().postHistory(activity);
  }
  return activity;
});

// Provider to load the activity history from the controller
final activityHistoryFetchProvider = FutureProvider<List<Activity>>((ref) async {
  return await ActivityController().getHistory();
});
