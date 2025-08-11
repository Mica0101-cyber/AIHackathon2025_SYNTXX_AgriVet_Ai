import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/livestock_viewmodel.dart';
import '../../views/livestock_screen/edit_livestock_screen.dart';
import '../../views/livestock_screen/add_livestock_screen.dart';
import '../sidebar_menu.dart';
import 'package:intl/intl.dart';

class LivestockListScreen extends StatefulWidget {
  const LivestockListScreen({Key? key}) : super(key: key);

  @override
  _LivestockListScreenState createState() => _LivestockListScreenState();
}

class _LivestockListScreenState extends State<LivestockListScreen> {
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String? _selectedBreed;
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
    _refreshLivestock();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshLivestock() async {
    setState(() => _isLoading = true);
    await Provider.of<LivestockViewModel>(context, listen: false)
        .fetchLivestocks();
    setState(() => _isLoading = false);
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (date != null) setState(() => _startDate = date);
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (date != null) setState(() => _endDate = date);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LivestockViewModel>(context);
    final all = viewModel.livestocks;

    // ← YOUR FIXED LISTS HERE:

    final breeds = [
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
    final statuses = ['Healthy', 'Sick', 'Sold'];

    // apply search + breed + status + date filters

    final filtered = all.where((l) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          l.name.toLowerCase().contains(q) ||
          l.breed.toLowerCase().contains(q) ||
          l.tagNumber.toLowerCase().contains(q);
      final matchesBreed = _selectedBreed == null || l.breed == _selectedBreed;
      final matchesStatus =
          _selectedStatus == null || l.status == _selectedStatus;
      final matchesStart =
          _startDate == null || l.dateOfBirth.isAfter(_startDate!);
      final matchesEnd = _endDate == null || l.dateOfBirth.isBefore(_endDate!);
      return matchesSearch &&
          matchesBreed &&
          matchesStatus &&
          matchesStart &&
          matchesEnd;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Livestock'),
        backgroundColor: Colors.lightGreen,
        centerTitle: true,
      ),
      drawer: const SidebarMenu(),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // ─── Search Bar ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search livestock...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),

                  // ─── Filters ────────────────────────────────────────
                  // … inside your Column, instead of the Wrap:
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Table(
                      columnWidths: {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(1),
                      },
                      children: [
                        TableRow(
                          children: [
                            // 1st cell: Breed filter
                            DropdownButton<String?>(
                              isExpanded: true,
                              hint: const Text('Breeds'),
                              value: _selectedBreed,
                              items: <DropdownMenuItem<String?>>[
                                const DropdownMenuItem(
                                    value: null, child: Text('All Breeds')),
                                ...breeds.map((b) =>
                                    DropdownMenuItem(value: b, child: Text(b))),
                              ],
                              onChanged: (val) =>
                                  setState(() => _selectedBreed = val),
                            ),

                            // 2nd cell: Status filter
                            DropdownButton<String?>(
                              isExpanded: true,
                              hint: const Text('Status'),
                              value: _selectedStatus,
                              items: <DropdownMenuItem<String?>>[
                                const DropdownMenuItem(
                                    value: null, child: Text('All Statuses')),
                                ...statuses.map((s) =>
                                    DropdownMenuItem(value: s, child: Text(s))),
                              ],
                              onChanged: (val) =>
                                  setState(() => _selectedStatus = val),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            // 3rd cell: Start date
                            OutlinedButton.icon(
                              onPressed: _pickStartDate,
                              icon: const Icon(Icons.date_range),
                              label: Text(
                                _startDate == null
                                    ? 'Start Date'
                                    : DateFormat.yMd().format(_startDate!),
                              ),
                            ),

                            // 4th cell: End date
                            OutlinedButton.icon(
                              onPressed: _pickEndDate,
                              icon: const Icon(Icons.date_range),
                              label: Text(
                                _endDate == null
                                    ? 'End Date'
                                    : DateFormat.yMd().format(_endDate!),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

// then below the Table, your Clear button:
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 16.0, top: 4.0, bottom: 8.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => setState(() {
                          _selectedBreed = null;
                          _selectedStatus = null;
                          _startDate = null;
                          _endDate = null;
                        }),
                        child: const Text('Clear Filters'),
                      ),
                    ),
                  ),
                  // ─── List ────────────────────────────────────────────
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refreshLivestock,
                      child: filtered.isEmpty
                          ? ListView(
                              children: const [
                                SizedBox(height: 100),
                                Center(
                                  child: Text(
                                    'No livestock found.',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final l = filtered[index];
                                final dob = DateFormat.yMMMd()
                                    .format(l.dateOfBirth.toLocal());
                                return Dismissible(
                                  key: ValueKey(l.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade400,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.delete,
                                        color: Colors.white),
                                  ),
                                  confirmDismiss: (_) async {
                                    return await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Delete Record'),
                                        content: const Text(
                                            'Are you sure you want to delete this livestock?'),
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
                                  },
                                  onDismissed: (_) {
                                    viewModel.deleteLivestock(l.id!);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Livestock deleted'),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                      leading: CircleAvatar(
                                        radius: 24,
                                        child: Text(
                                          l.name.isNotEmpty
                                              ? l.name[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                      ),
                                      title: Text(
                                        l.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        'Breed: ${l.breed}\n'
                                        'Status: ${l.status}\n'
                                        'DOB: $dob  •  Tag #: ${l.tagNumber}',
                                      ),
                                      isThreeLine: true,
                                      trailing: const Icon(Icons.chevron_right),
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              EditLiveStockScreen(livestock: l),
                                        ),
                                      ).then((_) => _refreshLivestock()),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AddLiveStockScreen(),
          ),
        ).then((_) => _refreshLivestock()),
        icon: const Icon(Icons.add),
        label: const Text('Add Livestock'),
      ),
    );
  }
}
