import 'package:flutter/material.dart';
import 'package:phonebook_app/services/notification_service.dart';
import 'package:provider/provider.dart';
import '../../../models/weight_record.dart';
import '../../../view_models/weight_records_view_model.dart';
import '../../notifications/notifications_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WeightRecordsScreen extends StatelessWidget {
  final int livestockId;

  const WeightRecordsScreen({Key? key, required this.livestockId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WeightRecordsViewModel>(
      create: (_) {
        final supabase = context.read<SupabaseClient>();
        final notifications = context.read<NotificationService>();
        final vm = WeightRecordsViewModel(
          supabase: supabase,
          notifications: notifications,
        );
        vm.fetchRecords(livestockId);
        return vm;
      },
      child: Consumer<WeightRecordsViewModel>(
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
                      child: WeightRecordForm(
                        livestockId: livestockId,
                        onSubmit: vm.addRecord,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen),
                child: const Text('Add Weight Record',
                    style: TextStyle(fontSize: 14, color: Colors.white)),
              ),
              const SizedBox(height: 24),
              const Text(
                'Weight History',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: vm.records.isEmpty
                    ? const Center(child: Text('No weight records yet.'))
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
                            title: Text('${rec.weight.toStringAsFixed(2)} kg'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Date: $dateStr'),
                                if (rec.notes != null &&
                                    rec.notes!.trim().isNotEmpty)
                                  Text('Notes: ${rec.notes!}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.monitor_weight),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (_) => Padding(
                                        padding:
                                            MediaQuery.of(context).viewInsets,
                                        child: WeightRecordForm(
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
                                            'Delete this weight record?'),
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

class WeightRecordForm extends StatefulWidget {
  final int livestockId;
  final WeightRecord? existing;
  final Future<void> Function(WeightRecord) onSubmit;

  const WeightRecordForm({
    Key? key,
    required this.livestockId,
    this.existing,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<WeightRecordForm> createState() => _WeightRecordFormState();
}

class _WeightRecordFormState extends State<WeightRecordForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _weightController;
  late TextEditingController _notesController; // Added controller for notes
  DateTime? _selectedDate;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.existing?.weight.toString() ?? '',
    );
    _notesController = TextEditingController(
      text: widget.existing?.notes ?? '',
    );
    _isUpdating = widget.existing != null;
    _selectedDate = widget.existing?.datetime ?? DateTime.now();
  }

  @override
  void dispose() {
    _weightController.dispose();
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
    if (picked != null) setState(() => _selectedDate = picked);
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

    final rec = WeightRecord(
      id: widget.existing?.id,
      livestockId: widget.livestockId,
      datetime: _selectedDate!,
      weight: double.tryParse(_weightController.text.trim()) ?? 0,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(), // Optional notes
    );

    await widget.onSubmit(rec);
    if (mounted) Navigator.of(context).pop();
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
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Weight is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen),
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
