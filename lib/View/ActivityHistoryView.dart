import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/ActivityModel.dart';
import 'ActivityProvider.dart';

class ActivityHistoryView extends ConsumerWidget {
  final String selectedType;

  const ActivityHistoryView({super.key, required this.selectedType, required List<Activity> history});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch async history fetch
    final activityHistoryAsync = ref.watch(activityHistoryFetchProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Activity History"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: activityHistoryAsync.when(
          data: (history) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Show count (max 50 shown)
                Text(
                  "Activity History (${history.length > 50 ? 50 : history.length})",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: history.length > 50 ? 50 : history.length,
                    itemBuilder: (context, index) {
                      final activity = history[index];
                      bool isSelectedType = activity.type == selectedType;

                      // Highlight card if it matches selected type
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
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}
