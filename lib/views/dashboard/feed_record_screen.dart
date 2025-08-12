import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/feed_records_view_model.dart';

class AllFeedRecordsScreen extends StatefulWidget {
  final int livestockId;
  const AllFeedRecordsScreen({required this.livestockId});

  @override
  State<AllFeedRecordsScreen> createState() => _AllFeedRecordsScreenState();
}

class _AllFeedRecordsScreenState extends State<AllFeedRecordsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<FeedRecordsViewModel>(context, listen: false)
            .fetchRecords(widget.livestockId));
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<FeedRecordsViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Feed Records'),
        backgroundColor: Colors.orange.shade700,
      ),
      body: vm.records.isEmpty
          ? Center(child: Text('No feed records found'))
          : ListView.builder(
              itemCount: vm.records.length,
              itemBuilder: (context, index) {
                final record = vm.records[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(record.feedType),
                    subtitle: Text('Quantity: ${record.quantity}'),
                  ),
                );
              },
            ),
    );
  }
}
