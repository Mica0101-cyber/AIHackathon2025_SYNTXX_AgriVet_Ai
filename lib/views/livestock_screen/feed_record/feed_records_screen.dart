import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/feed_record.dart';
import '../../../view_models/feed_records_view_model.dart';

class FeedRecordsScreen extends StatelessWidget {
  final int livestockId;

  const FeedRecordsScreen({Key? key, required this.livestockId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FeedRecordsViewModel>(
      create: (_) {
        final vm = FeedRecordsViewModel();
        vm.fetchRecords(livestockId);
        return vm;
      },
      child: Consumer<FeedRecordsViewModel>(
        builder: (context, vm, _) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => Padding(
                      padding: MediaQuery.of(context).viewInsets,
                      child: FeedRecordForm(
                        livestockId: livestockId,
                        onSubmit: vm.addRecord,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen,
                ),
                child: const Text('Add Feed Record',
                    style: TextStyle(fontSize: 14, color: Colors.white)),
              ),
              const SizedBox(height: 24),
              const Text(
                'Feeding History',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: vm.records.isEmpty
                    ? const Center(
                        child: Text('No records found for feeding.'),
                      )
                    : ListView.builder(
                        itemCount: vm.records.length,
                        itemBuilder: (context, i) {
                          final rec = vm.records[i];
                          final dateStr = rec.datetime
                              .toLocal()
                              .toIso8601String()
                              .split('T')
                              .first;
                          return ListTile(
                            title: Text(rec.feedType),
                            subtitle: Text(
                              'Date: $dateStr\n'
                              'Amount: ${rec.amount.toStringAsFixed(2)} kg',
                            ),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (_) => Padding(
                                        padding:
                                            MediaQuery.of(context).viewInsets,
                                        child: FeedRecordForm(
                                          livestockId: livestockId,
                                          existing: rec,
                                          onSubmit: (updated) async {
                                            await vm.updateRecord(updated);
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Confirm Delete'),
                                        content: const Text(
                                            'Delete this feed record?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(true),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await vm.deleteRecord(
                                          rec.id!, livestockId);
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeedRecordForm extends StatefulWidget {
  final int livestockId;
  final FeedRecord? existing;
  final Future<void> Function(FeedRecord) onSubmit;

  const FeedRecordForm({
    Key? key,
    required this.livestockId,
    this.existing,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _FeedRecordFormState createState() => _FeedRecordFormState();
}

class _FeedRecordFormState extends State<FeedRecordForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  String? _selectedFeedType;
  DateTime? _selectedDate;
  bool _isUpdating = false;

  final _feedTypes = <String>[
    'Feed 1',
    'Feed 2',
    'Feed 3',
    'Feed 4',
    // …add more types here…
  ];

  @override
  void initState() {
    super.initState();

    // always start with the amount (editing or not)
    _amountController = TextEditingController(
      text: widget.existing?.amount.toString() ?? '',
    );

    // mark editing mode if there's an existing record
    _isUpdating = widget.existing != null;

    // pre-fill the date if editing
    _selectedDate = widget.existing?.datetime;

    // only pre-fill feedType if it's one of your dropdown options
    if (widget.existing != null &&
        _feedTypes.contains(widget.existing!.feedType)) {
      _selectedFeedType = widget.existing!.feedType;
    } else {
      _selectedFeedType = null;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final first = DateTime(2000);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: first,
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date')),
        );
      }
      return;
    }

    final rec = FeedRecord(
      id: widget.existing?.id,
      livestockId: widget.livestockId,
      datetime: _selectedDate!,
      feedType: _selectedFeedType!,
      amount: double.tryParse(_amountController.text.trim()) ?? 0,
    );

    await widget.onSubmit(rec);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _selectedDate != null
                            ? _selectedDate!
                                .toLocal()
                                .toIso8601String()
                                .split('T')
                                .first
                            : 'Select date',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _feedTypes.contains(_selectedFeedType)
                        ? _selectedFeedType
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Feed Type',
                      border: OutlineInputBorder(),
                    ),
                    items: _feedTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedFeedType = val),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Please choose a feed type'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (kg/L)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Amount is required' : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen,
                ),
                child: Text(
                  _isUpdating ? 'Update Record' : 'Add Record',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
