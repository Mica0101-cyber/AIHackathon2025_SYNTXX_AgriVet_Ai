import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/livestock_viewmodel.dart';
import '../../models/livestock.dart';

class AddLiveStockScreen extends StatefulWidget {
  const AddLiveStockScreen({Key? key}) : super(key: key);

  @override
  _AddLiveStockScreenState createState() => _AddLiveStockScreenState();
}

class _AddLiveStockScreenState extends State<AddLiveStockScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _tagController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedType;
  String? _selectedStatus;
  String? _selectedBreed;
  bool _loading = false;

  final List<String> _livestockTypes = [
    'Pig',
    'Chicken (coming soon)',
    'Cattle (coming soon)',
    'Goat (coming soon)',
    'Sheep (coming soon)',
  ];

  final List<String> _statuses = [
    'Healthy',
    'Sick',
    'Sold',
  ];

  final List<String> _breeds = [
    'Piglet',
    'Weaner',
    'Nursery',
    'Barrow',
    'Gilt',
    'Sow',
    'Dry sow',
    'Grower',
    'Finisher'
  ];

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
        _dobController.text =
            _selectedDate!.toLocal().toIso8601String().split('T').first;
      });
    }
  }

  Future<void> _saveLivestock() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final newLivestock = Livestock(
      name: _nameController.text.trim(),
      type: _selectedType!,
      status: _selectedStatus!,
      dateOfBirth: _selectedDate!,
      breed: _selectedBreed!, // now from dropdown
      tagNumber: _tagController.text.trim(),
    );

    try {
      await Provider.of<LivestockViewModel>(context, listen: false)
          .addLivestock(newLivestock);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding livestock: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Livestock'),
        backgroundColor: Colors.lightGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
  child:   Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),

              // DOB
              TextFormField(
                controller: _dobController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: _pickDate,
                validator: (v) =>
                    v == null || v.isEmpty ? 'DOB is required' : null,
              ),
              const SizedBox(height: 16),

              // Livestock Type
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Livestock Type',
                  border: OutlineInputBorder(),
                ),
                items: _livestockTypes.map((type) {
                  final comingSoon = type.contains('(coming soon)');
                  return DropdownMenuItem<String>(
                    value: type,
                    enabled: !comingSoon,
                    child: Text(
                      type,
                      style: comingSoon
                          ? const TextStyle(color: Colors.grey)
                          : null,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null && !val.contains('(coming soon)')) {
                    setState(() => _selectedType = val);
                  }
                },
                validator: (v) =>
                    v == null || v.isEmpty || v.contains('(coming soon)')
                        ? 'Please select a valid type'
                        : null,
              ),
              const SizedBox(height: 16),

              // Status
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: _statuses.map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedStatus = val),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Status is required' : null,
              ),
              const SizedBox(height: 16),

              // Breed (Dropdown instead of text field)
              DropdownButtonFormField<String>(
                value: _selectedBreed,
                decoration: const InputDecoration(
                  labelText: 'Type of pig',
                  border: OutlineInputBorder(),
                ),
                items: _breeds.map((breed) {
                  return DropdownMenuItem<String>(
                    value: breed,
                    child: Text(breed),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedBreed = val),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Breed is required' : null,
              ),
              const SizedBox(height: 16),

              // Tag Number
              TextFormField(
                controller: _tagController,
                decoration: const InputDecoration(
                  labelText: 'Tag Number',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Tag number is required'
                    : null,
              ),
              const SizedBox(height: 24),

              // Save button / spinner
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveLivestock,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text('Save Livestock',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
            ],
          ),
          )
        ),
      ),
    );
  }
}
