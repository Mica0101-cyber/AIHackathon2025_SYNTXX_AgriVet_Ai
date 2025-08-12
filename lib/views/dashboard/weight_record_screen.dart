import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/weight_records_view_model.dart';

class AllWeightRecordsScreen extends StatefulWidget {
  final int livestockId;
  const AllWeightRecordsScreen({required this.livestockId});

  @override
  State<AllWeightRecordsScreen> createState() => _AllWeightRecordsScreenState();
}

class _AllWeightRecordsScreenState extends State<AllWeightRecordsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<WeightRecordsViewModel>(context, listen: false)
            .fetchRecords(widget.livestockId));
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<WeightRecordsViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Weight Records'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: vm.records.isEmpty
          ? Center(child: Text('No weight records found'))
          : ListView.builder(
              itemCount: vm.records.length,
              itemBuilder: (context, index) {
                final record = vm.records[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('${record.weight} kg'),
                    subtitle: Text('Date: ${record.date}'),
                  ),
                );
              },
            ),
    );
  }
}
