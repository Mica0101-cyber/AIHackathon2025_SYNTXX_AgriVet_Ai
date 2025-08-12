import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../view_models/livestock_viewmodel.dart';


class FeedRecordsScreen extends StatefulWidget {
  const FeedRecordsScreen({Key? key}) : super(key: key);

  @override
  _FeedRecordsScreenState createState() => _FeedRecordsScreenState();
}

class _FeedRecordsScreenState extends State<FeedRecordsScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFeedRecords();
  }

  Future<void> _loadFeedRecords() async {
    setState(() => _loading = true);
    await Provider.of<LivestockViewModel>(context, listen: false).fetchFeedRecords();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LivestockViewModel>(context);
    final records = viewModel.feedRecords;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Records'),
        backgroundColor: Colors.purple.shade700,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Colors.purple))
            : records.isEmpty
                ? const Center(
                    child: Text(
                      'No feed records available.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadFeedRecords,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: records.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final record = records[index];
                        final formattedDate = DateFormat.yMMMd().format(record.date.toLocal());

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.purple.shade100,
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
                          subtitle: Text(
                            'Feed Type: ${record.feedType}\nQuantity: ${record.quantity} kg\nDate: $formattedDate',
                          ),
                          isThreeLine: true,
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
