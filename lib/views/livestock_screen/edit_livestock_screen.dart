import 'package:flutter/material.dart';
import 'package:phonebook_app/views/livestock_screen/breed_record/bred_record_screen.dart';
import 'package:phonebook_app/views/livestock_screen/health/health_record.screen.dart';
import 'package:provider/provider.dart';
import '../../view_models/livestock_viewmodel.dart';
import '../../models/livestock.dart';
import '../../views/livestock_screen/feed_record/feed_records_screen.dart';
import '../../views/livestock_screen/weight_record/weight_records_screen.dart';

class EditLiveStockScreen extends StatefulWidget {
  final Livestock livestock;

  const EditLiveStockScreen({Key? key, required this.livestock})
      : super(key: key);

  @override
  _EditLiveStockScreenState createState() => _EditLiveStockScreenState();
}

class _EditLiveStockScreenState extends State<EditLiveStockScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _tagController;
  DateTime? _selectedDate;
  String? _selectedType;
  String? _selectedStatus;
  String? _selectedBreed; // <-- NEW
  bool _loading = false;
  late TabController _tabController;

  final Map<String, String> _livestockTypes = {
    'Pig': 'Pig',
    'Chicken': 'Chicken (coming soon)',
    'Cattle': 'Cattle (coming soon)',
    'Goat': 'Goat (coming soon)',
    'Sheep': 'Sheep (coming soon)',
  };

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

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.livestock.name);
    _selectedType = _livestockTypes.containsKey(widget.livestock.type)
        ? widget.livestock.type
        : null;

    _selectedDate = widget.livestock.dateOfBirth;
    _dobController = TextEditingController(
      text: _selectedDate!.toLocal().toIso8601String().split('T').first,
    );

    _tagController = TextEditingController(text: widget.livestock.tagNumber);

    // Breed
    _selectedBreed = _breeds.contains(widget.livestock.breed)
        ? widget.livestock.breed
        : null;

    // Status
    _selectedStatus = _statuses.contains(widget.livestock.status)
        ? widget.livestock.status
        : null;

    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _tagController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
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

  Future<void> _updateLivestock() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final updated = Livestock(
      id: widget.livestock.id,
      name: _nameController.text.trim(),
      type: _selectedType!,
      status: _selectedStatus!,
      dateOfBirth: _selectedDate!,
      breed: _selectedBreed!, // <-- from dropdown
      tagNumber: _tagController.text.trim(),
    );
    try {
      await Provider.of<LivestockViewModel>(context, listen: false)
          .updateLivestock(updated);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating livestock: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Livestock Details'),
        backgroundColor: Colors.lightGreen,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Name is required'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Type
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Livestock Type',
                        border: OutlineInputBorder(),
                      ),
                      items: _livestockTypes.entries.map((entry) {
                        final raw = entry.key;
                        final label = entry.value;
                        final disabled = label.contains('coming soon');
                        return DropdownMenuItem(
                          value: raw,
                          enabled: !disabled,
                          child: Text(
                            label,
                            style: disabled
                                ? const TextStyle(color: Colors.grey)
                                : null,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null &&
                            !_livestockTypes[val]!.contains('coming soon')) {
                          setState(() => _selectedType = val);
                        }
                      },
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Type is required';
                        if (_livestockTypes[v]!.contains('coming soon')) {
                          return 'Please select a valid type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Status
                    DropdownButtonFormField<String?>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Select Status'),
                      items: _statuses
                          .map((s) => DropdownMenuItem<String?>(
                                value: s,
                                child: Text(s),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedStatus = val),
                      validator: (v) => v == null ? 'Status is required' : null,
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

                    // Breed Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedBreed,
                      decoration: const InputDecoration(
                        labelText: 'Breed',
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

                    // Tag
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

                    // Save
                    _loading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _updateLivestock,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightGreen,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              child: Text('Update Livestock',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white)),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: Colors.lightGreen,
            unselectedLabelColor: Colors.blueGrey,
            tabs: const [
              Tab(icon: Icon(Icons.restaurant), text: 'Feeding'),
              Tab(icon: Icon(Icons.scale), text: 'Weight'),
              Tab(icon: Icon(Icons.account_tree), text: 'Breeding'),
              Tab(icon: Icon(Icons.medical_services), text: 'Health'),
            ],
          ),
          SizedBox(
            height: 230,
            child: TabBarView(
              controller: _tabController,
              children: [
                FeedRecordsScreen(livestockId: widget.livestock.id!),
                WeightRecordsScreen(livestockId: widget.livestock.id!),
                BreedingRecordsScreen(livestockId: widget.livestock.id!),
                HealthRecordsScreen(livestockId: widget.livestock.id!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
