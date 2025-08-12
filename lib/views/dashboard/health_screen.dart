import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/health_record.dart';

class AllHealthRecordsScreen extends StatefulWidget {
  final int livestockId;
  const AllHealthRecordsScreen({required this.livestockId});

  @override
  State<AllHealthRecordsScreen> createState() => _AllHealthRecordsScreenState();
}

class _AllHealthRecordsScreenState extends State<AllHealthRecordsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<HealthRecordsViewModel>(context, listen: false)
            .fetchRecords(widget.livestockId));
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<HealthRecordsViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Health Records'),
        backgroundColor: Colors.red.shade700,
      ),
      body: vm.records.isEmpty
          ? Center(child: Text('No health records found'))
          : ListView.builder(
              itemCount: vm.records.length,
              itemBuilder: (context, index) {
                final record = vm.records[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(record.diagnosis),
                    subtitle: Text('Treatment: ${record.treatment}'),
                  ),
                );
              },
            ),
    );
  }
}
