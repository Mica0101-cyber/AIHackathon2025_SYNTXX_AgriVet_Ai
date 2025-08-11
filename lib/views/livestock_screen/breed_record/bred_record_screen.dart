import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/breeding_record.dart';
import '../../../view_models/breed_view_model.dart';

class BreedingRecordsScreen extends StatelessWidget {
  final int livestockId;

  const BreedingRecordsScreen({Key? key, required this.livestockId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BreedingRecordsViewModel>(
      create: (_) {
        final vm = BreedingRecordsViewModel();
        vm.fetchRecords(livestockId);
        return vm;
      },
      child: Consumer<BreedingRecordsViewModel>(
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
                      child: BreedingRecordForm(
                        livestockId: livestockId,
                        onSubmit: vm.addRecord,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen,
                ),
                child: const Text('Add Breeding Record',
                    style: TextStyle(fontSize: 14, color: Colors.white)),
              ),
              const SizedBox(height: 24),
              const Text(
                'Breeding History',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: vm.records.isEmpty
                    ? const Center(
                        child: Text('No breeding records found.'),
                      )
                    : ListView.builder(
                        itemCount: vm.records.length,
                        itemBuilder: (context, i) {
                          final rec = vm.records[i];
                          final dateStr = rec.date
                              .toLocal()
                              .toIso8601String()
                              .split('T')
                              .first;
                          return ListTile(
                            title: Text('${rec.type} - ${rec.feedType}'),
                            subtitle: Text(
                              'Date: $dateStr\n'
                              'Amount: ${rec.amount.toStringAsFixed(2)} kg\n'
                              'Notes: ${rec.notes ?? "N/A"}',
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
                                        child: BreedingRecordForm(
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
                                            'Delete this breeding record?'),
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

class BreedingRecordForm extends StatefulWidget {
  final int livestockId;
  final BreedingRecord? existing;
  final Future<void> Function(BreedingRecord) onSubmit;

  const BreedingRecordForm({
    Key? key,
    required this.livestockId,
    this.existing,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _BreedingRecordFormState createState() => _BreedingRecordFormState();
}

class _BreedingRecordFormState extends State<BreedingRecordForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  String? _selectedFeedType;
  String? _selectedBreedingType;
  DateTime? _selectedDate;
  bool _isUpdating = false;

  final _feedTypes = <String>[
    'Feed 1',
    'Feed 2',
    'Feed 3',
    'Feed 4',
  ];

  final _breedingTypes = <String>[
    'Weaning',
    'Gestating',
    'Farrowing',
    'Lactating',
  ];

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController(
      text: widget.existing?.amount.toString() ?? '',
    );

    _notesController = TextEditingController(
      text: widget.existing?.notes ?? '',
    );

    _isUpdating = widget.existing != null;
    _selectedDate = widget.existing?.date;

    if (widget.existing != null &&
        _feedTypes.contains(widget.existing!.feedType)) {
      _selectedFeedType = widget.existing!.feedType;
    }

    if (widget.existing != null &&
        _breedingTypes.contains(widget.existing!.type)) {
      _selectedBreedingType = widget.existing!.type;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
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

    final rec = BreedingRecord(
      id: widget.existing?.id,
      livestockId: widget.livestockId,
      date: _selectedDate!,
      feedType: _selectedFeedType!,
      amount: double.tryParse(_amountController.text.trim()) ?? 0,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      type: _selectedBreedingType!,
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
            DropdownButtonFormField<String>(
              value: _breedingTypes.contains(_selectedBreedingType)
                  ? _selectedBreedingType
                  : null,
              decoration: const InputDecoration(
                labelText: 'Breeding Type',
                border: OutlineInputBorder(),
              ),
              items: _breedingTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedBreedingType = val),
              validator: (v) => v == null || v.isEmpty
                  ? 'Please choose a breeding type'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (kg)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Amount is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
              maxLines: 2,
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
