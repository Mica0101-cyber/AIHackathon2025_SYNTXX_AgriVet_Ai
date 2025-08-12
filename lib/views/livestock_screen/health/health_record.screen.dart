import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/health_record.dart';
import '../../../models/health_record.dart';


class HealthRecordsScreen extends StatelessWidget {
  final int livestockId;

  const HealthRecordsScreen({Key? key, required this.livestockId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HealthRecordsViewModel>(
      create: (_) {
        final vm = HealthRecordsViewModel();
        vm.fetchRecords(livestockId);
        return vm;
      },
      child: Consumer<HealthRecordsViewModel>(
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
                      child: HealthRecordForm(
                        livestockId: livestockId,
                        onSubmit: vm.addRecord,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen,
                ),
                child: const Text(
                  'Add Health Record',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Health History',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: vm.records.isEmpty
                    ? const Center(child: Text('No health records found.'))
                    : ListView.builder(
                        itemCount: vm.records.length,
                        itemBuilder: (context, i) {
                          final rec = vm.records[i];
                          final dateStr =
                              rec.date.toLocal().toIso8601String().split('T').first;
                          return ListTile(
                            title: Text('${rec.procedure} (${rec.medicineUsed})'),
                            subtitle: Text(
                              'Date: $dateStr\n'
                              'Diagnosis: ${rec.diagnosis}\n'
                              'Dosage: ${rec.dosage}\n'
                              'Outcome: ${rec.outcome}\n'
                              'Notes: ${rec.notes}',
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
                                        padding: MediaQuery.of(context).viewInsets,
                                        child: HealthRecordForm(
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
                                            'Delete this health record?'),
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

class HealthRecordForm extends StatefulWidget {
  final int livestockId;
  final HealthRecord? existing;
  final Future<void> Function(HealthRecord) onSubmit;

  const HealthRecordForm({
    Key? key,
    required this.livestockId,
    this.existing,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _HealthRecordFormState createState() => _HealthRecordFormState();
}

class _HealthRecordFormState extends State<HealthRecordForm> {
  final _formKey = GlobalKey<FormState>();
  final _procedureController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _medicineController = TextEditingController();
  final _dosageController = TextEditingController();
  final _administeredByController = TextEditingController();
  final _outcomeController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _selectedDate;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _isUpdating = true;
      _selectedDate = widget.existing!.date;
      _procedureController.text = widget.existing!.procedure;
      _diagnosisController.text = widget.existing!.diagnosis;
      _medicineController.text = widget.existing!.medicineUsed;
      _dosageController.text = widget.existing!.dosage;
      _administeredByController.text = widget.existing!.administeredBy;
      _outcomeController.text = widget.existing!.outcome;
      _notesController.text = widget.existing!.notes;
    }
  }

  @override
  void dispose() {
    _procedureController.dispose();
    _diagnosisController.dispose();
    _medicineController.dispose();
    _dosageController.dispose();
    _administeredByController.dispose();
    _outcomeController.dispose();
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

    final record = HealthRecord(
      id: widget.existing?.id,
      livestockId: widget.livestockId,
      date: _selectedDate!,
      procedure: _procedureController.text.trim(),
      diagnosis: _diagnosisController.text.trim(),
      medicineUsed: _medicineController.text.trim(),
      dosage: _dosageController.text.trim(),
      administeredBy: _administeredByController.text.trim(),
      outcome: _outcomeController.text.trim(),
      notes: _notesController.text.trim(),
    );

    await widget.onSubmit(record);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
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
              const SizedBox(height: 16),
              _buildTextField(_procedureController, 'Procedure'),
              const SizedBox(height: 16),
              _buildTextField(_diagnosisController, 'Diagnosis'),
              const SizedBox(height: 16),
              _buildTextField(_medicineController, 'Medicine Used'),
              const SizedBox(height: 16),
              _buildTextField(_dosageController, 'Dosage'),
              const SizedBox(height: 16),
              _buildTextField(_administeredByController, 'Administered By'),
              const SizedBox(height: 16),
              _buildTextField(_outcomeController, 'Outcome'),
              const SizedBox(height: 16),
              _buildTextField(_notesController, 'Notes (optional)', maxLines: 2),
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
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      validator: (v) =>
          v == null || v.trim().isEmpty ? '$label is required' : null,
    );
  }
}
// ignore: prefer_typing_uninitialized_variables.,
