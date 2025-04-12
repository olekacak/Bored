import 'package:flutter/material.dart';
import '../model/ActivityModel.dart';

class ActivityHistoryView extends StatelessWidget {
  final List<Activity> history;
  final String selectedType;

  const ActivityHistoryView({super.key, required this.history, required this.selectedType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Activity History (${history.length})"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: history.length > 50 ? 50 : history.length, // Limit to 50
          itemBuilder: (context, index) {
            final activity = history[index];
            bool isSelectedType = activity.type == selectedType;

            return Card(
              color: isSelectedType ? Colors.yellow[100] : null,
              child: ListTile(
                leading: CircleAvatar(
                  child: Text('${activity.id}'),
                ),
                title: Text(activity.activity),
                subtitle: Text("Price: \$${activity.price.toStringAsFixed(2)}"),
              ),
            );
          },
        ),
      ),
    );
  }
}
