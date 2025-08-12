import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/health_record.dart';
import '../../../models/health_record.dart';


class HealthRecordsView extends StatelessWidget {
  final int livestockId;

  const HealthRecordsView({super.key, required this.livestockId});

  static Widget withProvider({required int livestockId}) {
    return ChangeNotifierProvider<HealthRecordsViewModel>(
      create: (_) {
        final vm = HealthRecordsViewModel();
        vm.fetchRecords(livestockId);
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
              itemCount: viewModel.records.length,
              itemBuilder: (context, index) {
                final record = viewModel.records[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    title: Text(record.procedure),
                    subtitle: Text(
                        "${record.date.toLocal().toString().split(' ')[0]} • ${record.outcome}\nDiagnosis: ${record.diagnosis}"),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _openForm(context, viewModel, record: record);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            viewModel.deleteRecord(record.id!, livestockId);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openForm(context, viewModel);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

void _openForm(BuildContext context, HealthRecordsViewModel viewModel, {HealthRecord? record}) {
  final dateController = TextEditingController(
      text: record != null ? record.date.toLocal().toString().split(' ')[0] : '');
  final diagnosisController = TextEditingController(text: record?.diagnosis ?? '');
  final medicineController = TextEditingController(text: record?.medicineUsed ?? '');
  final dosageController = TextEditingController(text: record?.dosage ?? '');
  final administeredByController = TextEditingController(text: record?.administeredBy ?? '');
  final notesController = TextEditingController(text: record?.notes ?? '');

    String procedure = record?.procedure ?? 'Vaccination';
    String outcome = record?.outcome ?? 'Success';

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(record == null ? "Add Health Record" : "Edit Health Record"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: dateController,
              decoration: const InputDecoration(labelText: "Date (YYYY-MM-DD)"),
            ),
            TextField(
              controller: diagnosisController,
              decoration: const InputDecoration(labelText: "Diagnosis"),
            ),
            TextField(
              controller: medicineController,
              decoration: const InputDecoration(labelText: "Medicine/Vaccine/Supplement"),
            ),
            TextField(
              controller: dosageController,
              decoration: const InputDecoration(labelText: "Dosage"),
            ),
            TextField(
              controller: administeredByController,
              decoration: const InputDecoration(labelText: "Administered By"),
            ),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: "Notes (Optional)"),
            ),
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
              onChanged: (val) => procedure = val!,
              decoration: const InputDecoration(labelText: "Procedure"),
            ),
            DropdownButtonFormField<String>(
              value: outcome,
              items: const ['Success', 'Failed']
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
              onChanged: (val) => outcome = val!,
              decoration: const InputDecoration(labelText: "Outcome"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            // Example save logic (replace with your actual logic)
            // ... save or update record here ...
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: const Text("Save"),
        ),
      ],
    ),
  );
}