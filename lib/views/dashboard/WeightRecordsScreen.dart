import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../view_models/livestock_viewmodel.dart';
class WeightRecordsScreen extends StatefulWidget {
  const WeightRecordsScreen({Key? key}) : super(key: key);

  @override
  _WeightRecordsScreenState createState() => _WeightRecordsScreenState();
}
class _WeightRecordsScreenState extends State<WeightRecordsScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWeightRecords();
  }

  Future<void> _loadWeightRecords() async {
    setState(() => _loading = true);
    await Provider.of<LivestockViewModel>(context, listen: false).fetchWeightRecords();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LivestockViewModel>(context);
    final records = viewModel.weightRecords;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight Records'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Colors.blue))
            : records.isEmpty
                ? const Center(
                    child: Text(
                      'No weight records available.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadWeightRecords,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: records.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final record = records[index];
                        final formattedDate = DateFormat.yMMMd().format(record.date.toLocal());

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              record.livestockName.isNotEmpty
                                  ? record.livestockName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            record.livestockName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Weight: ${record.weight} kg\nDate: $formattedDate'),
                          isThreeLine: true,
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
