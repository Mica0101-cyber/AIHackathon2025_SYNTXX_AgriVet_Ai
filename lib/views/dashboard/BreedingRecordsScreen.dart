import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../view_models/breed_view_model.dart';
import '../../view_models/livestock_viewmodel.dart';

class BreedingRecordsScreen extends StatefulWidget {
  const BreedingRecordsScreen({Key? key}) : super(key: key);

  @override
  _BreedingRecordsScreenState createState() => _BreedingRecordsScreenState();
}

class _BreedingRecordsScreenState extends State<BreedingRecordsScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBreedingRecords();
  }

  Future<void> _loadBreedingRecords() async {
    setState(() => _loading = true);
    await Provider.of<LivestockViewModel>(context, listen: false).fetchBreedingRecords();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LivestockViewModel>(context);
    final records = viewModel.breedingRecords;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Breeding Records'),
        backgroundColor: Colors.brown.shade700,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Colors.brown))
            : records.isEmpty
                ? const Center(
                    child: Text(
                      'No breeding records available.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadBreedingRecords,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: records.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final record = records[index];
                        final breedingDate = DateFormat.yMMMd().format(record.breedingDate.toLocal());
                        final expectedBirthDate = DateFormat.yMMMd().format(record.expectedBirthDate.toLocal());

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.brown.shade100,
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
                            'Breeding Date: $breedingDate\nExpected Birth: $expectedBirthDate',
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
