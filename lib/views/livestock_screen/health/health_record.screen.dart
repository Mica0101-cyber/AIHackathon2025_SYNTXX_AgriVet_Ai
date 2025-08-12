import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/health_record.dart';
import '../../../models/health_record.dart';
import '../../../view_models/health_record.dart';

class HealthRecordsView extends StatelessWidget {
  final int livestockId;

  const HealthRecordsView({super.key, required this.livestockId});

  static Widget withProvider({required int livestockId}) {
    return ChangeNotifierProvider<HealthRecordsViewModel>(
      create: (_) {
        final vm = HealthRecordsViewModel(livestockId: livestockId);
        vm.fetchRecords();
        return vm;
      },
      child: HealthRecordsView(livestockId: livestockId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HealthRecordsViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Health Records"),
      ),
      body: viewModel.records.isEmpty
          ? const Center(child: Text("No health records found"))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              itemCount: viewModel.records.length,
              itemBuilder: (context, index) {
                final record = viewModel.records[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    title: Text(
                      record.procedure,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${record.date.toLocal().toIso8601String().split('T')[0]} • ${record.outcome}",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black87),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Diagnosis: ${record.diagnosis}",
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          tooltip: 'Edit',
                          onPressed: () {
                            _openForm(context, viewModel, record: record);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Delete',
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Confirm Delete'),
                                content:
                                    const Text('Delete this health record?'),
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
                            if (confirmed == true) {
                              await viewModel.deleteRecord(record.id!);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightGreen,
        onPressed: () {
          _openForm(context, viewModel);
        },
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add Health Record',
      ),
    );
  }
}

void _openForm(BuildContext context, HealthRecordsViewModel viewModel,
    {HealthRecord? record}) {
  final dateController = TextEditingController(
    text: record != null ? record.date.toLocal().toIso8601String().split('T')[0] : '',
  );
  final diagnosisController = TextEditingController(text: record?.diagnosis ?? '');
  final medicineController = TextEditingController(text: record?.medicineUsed ?? '');
  final dosageController = TextEditingController(text: record?.dosage ?? '');
  final administeredByController = TextEditingController(text: record?.administeredBy ?? '');
  final notesController = TextEditingController(text: record?.notes ?? '');

  String procedure = record?.procedure ?? 'Vaccination';
  String outcome = record?.outcome ?? 'Success';

  bool isSaving = false; // for loading state in dialog

  showDialog(
    context: context,
    barrierDismissible: false, // prevent dismiss while saving
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        Future<void> _pickDate() async {
          final picked = await showDatePicker(
            context: context,
            initialDate: record?.date ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            dateController.text = picked.toIso8601String().split('T')[0];
            setState(() {});
          }
        }

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            record == null ? "Add Health Record" : "Edit Health Record",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.lightGreen),
          ),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: dateController,
                    readOnly: true,
                    onTap: _pickDate,
                    decoration: InputDecoration(
                      labelText: "Date",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.calendar_today, color: Colors.lightGreen),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: diagnosisController,
                    decoration: InputDecoration(
                      labelText: "Diagnosis",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.sick, color: Colors.orange),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: medicineController,
                    decoration: InputDecoration(
                      labelText: "Medicine/Vaccine/Supplement",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.medication, color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: dosageController,
                    decoration: InputDecoration(
                      labelText: "Dosage",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.scale, color: Colors.purple),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: administeredByController,
                    decoration: InputDecoration(
                      labelText: "Administered By",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.person, color: Colors.teal),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: "Notes (Optional)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.note, color: Colors.grey),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: procedure,
                    items: const [
                      'Vaccination',
                      'Deworming',
                      'Castration',
                      'Treatment',
                      'Vitamin Supplementation',
                      'Others',
                    ].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => procedure = val);
                    },
                    decoration: InputDecoration(
                      labelText: "Procedure",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.healing, color: Colors.redAccent),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: outcome,
                    items: const ['Success', 'Failed']
                        .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => outcome = val);
                    },
                    decoration: InputDecoration(
                      labelText: "Outcome",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.check_circle, color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving
                  ? null
                  : () {
                      FocusScope.of(context).unfocus();
                      Navigator.pop(context);
                    },
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: isSaving
                  ? null
                  : () async {
                      FocusScope.of(context).unfocus();
                      setState(() => isSaving = true);

                      try {
                        final parsedDate = DateTime.parse(dateController.text);
                        final newRecord = HealthRecord(
                          id: record?.id,
                          livestockId: viewModel.livestockId,
                          date: parsedDate,
                          procedure: procedure,
                          diagnosis: diagnosisController.text.trim(),
                          medicineUsed: medicineController.text.trim(),
                          dosage: dosageController.text.trim(),
                          administeredBy: administeredByController.text.trim(),
                          outcome: outcome,
                          notes: notesController.text.trim(),
                        );

                        if (record == null) {
                          await viewModel.addRecord(newRecord);
                        } else {
                          await viewModel.updateRecord(newRecord);
                        }

                        Navigator.of(context, rootNavigator: true).pop();
                      } catch (e) {
                        setState(() => isSaving = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invalid date format. Use YYYY-MM-DD')),
                        );
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      });
    },
  );
}