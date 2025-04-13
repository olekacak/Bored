import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/ActivityModel.dart';

class ActivityController {
  String server;
  http.Response? _res;
  final Map<dynamic, dynamic> _body = {};
  final Map<String, String> _headers = {};
  dynamic _resultData;

  ActivityController({this.server = "https://bored.api.lewagon.com/api/activity"});

  static const String historyKey = 'activity_history';

  setBody(Map<String, dynamic> data) {
    _body.clear();
    _body.addAll(data);
    _headers["Content-Type"] = "application/json; charset=UTF-8";
  }

  // Fetch a single activity from the API
  Future<Activity?> getActivity() async {
    try {
      // Make a GET request to the server
      _res = await http.get(Uri.parse(server), headers: _headers);
      _parseResult();

      // Check if the response is successful and parse the activity
      if (status() == 200 && _resultData is Map<String, dynamic>) {
        return Activity.fromJson(_resultData, 1);
      }
    } catch (e) {
      print("Error fetching activity: $e");
    }
    return null;
  }

  // Fetch a random activity from the API with an optional type filter
  Future<Activity?> getRandomActivity({String? type}) async {
    try {
      // Construct the URL with type filter if provided
      final uri = Uri.parse(type != null ? '$server?type=$type' : server);
      final response = await http.get(uri, headers: _headers);

      _res = response;
      _parseResult();

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Get current history to calculate new ID
        final history = await getHistory();
        //final newId = (history.isNotEmpty ? (history.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1) : 1);
        //final newId = history.isNotEmpty ? history.last.id + 1 : 1;
        final newId = history.isNotEmpty ? history.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1 : 1;



        return Activity.fromJson(jsonData, newId);// Return a new activity with a unique ID
      } else {
        print('Failed to load activity. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error in getRandomActivity: $e");
    }
    return null;
  }

  Future<void> postHistory(Activity activity) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    if (history.length > 50) {
      history.removeLast();
    }
    history.forEach((activity) {
      //print("History Activity ID: ${activity.id}");
    });
    history.add(activity);
    final historyJson = jsonEncode(history.map((e) => e.toJson()).toList());
    await prefs.setString(historyKey, historyJson);
  }

  // Retrieve activity history from SharedPreferences
  Future<List<Activity>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(historyKey);

    if (jsonString != null) {
      final List decoded = json.decode(jsonString);
      return decoded.map((e) => Activity.fromJson(e, e['id'])).toList(); // Convert list of maps into Activity objects

      // final history = decoded.map((e) => Activity.fromJson(e, e['id'])).toList();
      //
      // // Sort by ID descending (latest first)
      // history.sort((a, b) => b.id.compareTo(a.id));
      //
      // return history;

    }
    return [];
  }

  void _parseResult() {
    try {
      //print("Raw response: ${_res?.body}");
      _resultData = jsonDecode(_res?.body ?? "");
    } catch (ex) {
      _resultData = _res?.body;
      print("Exception in HTTP result parsing: $ex"); // Log the exception
    }
  }

  dynamic result() => _resultData;

  int status() => _res?.statusCode ?? 0;
}
