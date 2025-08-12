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
                        onSubmit: (record) async {
                          await vm.addRecord(record);
                          vm.fetchRecords(livestockId);
                          debugPrint('Record added: ${record.toMap()}');
                        },
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
                          final dateStr = rec.datetime
                              .toLocal()
                              .toIso8601String()
                              .split('T')
                              .first;
                          return ListTile(
                            title: Text('Method: ${rec.method}'),
                            subtitle: Text(
                              'Date: $dateStr\n'
                              'Type: ${rec.breedingType ?? "N/A"}\n'
                              'Piglets Born: ${rec.pigletBorn ?? "N/A"}\n'
                              'Notes: ${rec.notes ?? ""}',
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
                                            vm.fetchRecords(livestockId);
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
                                      vm.fetchRecords(livestockId);
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
  late TextEditingController _pigletBornController;
  late TextEditingController _notesController;
  String? _selectedMethod;
  String? _selectedBreedingType;
  DateTime? _selectedDate;
  bool _isUpdating = false;

  final _methods = <String>[
    'Natural Mating',
    'Artificial Insemination',
    'Heat Detection',
    'Pregnancy Check',
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

    _pigletBornController =
        TextEditingController(text: widget.existing?.pigletBorn ?? '');
    _notesController =
        TextEditingController(text: widget.existing?.notes ?? '');

    _isUpdating = widget.existing != null;
    _selectedDate = widget.existing?.datetime;

    if (widget.existing != null) {
      if (_methods.contains(widget.existing!.method)) {
        _selectedMethod = widget.existing!.method;
      }
      if (widget.existing!.breedingType != null &&
          _breedingTypes.contains(widget.existing!.breedingType)) {
        _selectedBreedingType = widget.existing!.breedingType;
      }
    }
  }

  @override
  void dispose() {
    _pigletBornController.dispose();
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
      datetime: _selectedDate!,
      method: _selectedMethod!,
      breedingType: _selectedBreedingType,
      pigletBorn: _pigletBornController.text.trim().isNotEmpty
          ? _pigletBornController.text.trim()
          : null,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
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
                        labelText: 'Breeding Date',
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
                    value: _methods.contains(_selectedMethod)
                        ? _selectedMethod
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Method',
                      border: OutlineInputBorder(),
                    ),
                    items: _methods.map((method) {
                      return DropdownMenuItem(
                        value: method,
                        child: Text(method),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedMethod = val),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Please choose a method' : null,
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
                labelText: 'Breeding Type (Optional)',
                border: OutlineInputBorder(),
              ),
              items: _breedingTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedBreedingType = val),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pigletBornController,
              decoration: const InputDecoration(
                labelText: 'Number of Piglets Born (Optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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