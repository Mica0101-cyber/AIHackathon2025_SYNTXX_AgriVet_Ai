import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/livestock_viewmodel.dart';
import '../../views/livestock_screen/edit_livestock_screen.dart';
import '../../views/livestock_screen/add_livestock_screen.dart';
import '../sidebar_menu.dart';
import 'package:intl/intl.dart';

// ── Brand palette (mirrors dashboard) ─────────────────────────────────────────
const Color _primaryGreen = Color(0xFF2E7D32);
const Color _lightGreen   = Color(0xFFE8F5E9);
const Color _bgGrey       = Color(0xFFF4F6F8);
const Color _textDark     = Color(0xFF1A2332);
const Color _textMuted    = Color(0xFF90A4AE);

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

  static const List<String> _breeds = [
    'Piglet', 'Weaner', 'Nursery', 'Barrow',
    'Gilt', 'Sow', 'Dry sow', 'Grower', 'Finisher',
  ];
  static const List<String> _statuses = ['Healthy', 'Sick', 'Sold'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
        () => setState(() => _searchQuery = _searchController.text));
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
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now  = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _primaryGreen,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (date != null) {
      setState(() {
        if (isStart) { _startDate = date; } else { _endDate = date; }
      });
    }
  }

  bool get _hasFilters =>
      _selectedBreed != null ||
      _selectedStatus != null ||
      _startDate != null ||
      _endDate != null;

  // ── Status color / icon ─────────────────────────────────────────────────────
  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'healthy': return const Color(0xFF2E7D32);
      case 'sick':    return const Color(0xFFB71C1C);
      case 'sold':    return const Color(0xFF1565C0);
      default:        return _textMuted;
    }
  }

  Color _statusBg(String s) {
    switch (s.toLowerCase()) {
      case 'healthy': return const Color(0xFFE8F5E9);
      case 'sick':    return const Color(0xFFFFEBEE);
      case 'sold':    return const Color(0xFFE3F2FD);
      default:        return _bgGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LivestockViewModel>(context);
    final all       = viewModel.livestocks;

    final filtered = all.where((l) {
      final q = _searchQuery.toLowerCase();
      final matchSearch = _searchQuery.isEmpty ||
          l.name.toLowerCase().contains(q) ||
          l.breed.toLowerCase().contains(q) ||
          l.tagNumber.toLowerCase().contains(q);
      final matchBreed  = _selectedBreed == null || l.breed == _selectedBreed;
      final matchStatus = _selectedStatus == null || l.status == _selectedStatus;
      final matchStart  = _startDate == null || l.dateOfBirth.isAfter(_startDate!);
      final matchEnd    = _endDate == null || l.dateOfBirth.isBefore(_endDate!);
      return matchSearch && matchBreed && matchStatus && matchStart && matchEnd;
    }).toList();

    return Scaffold(
      backgroundColor: _bgGrey,
      drawer: const SidebarMenu(),
      appBar: AppBar(
        backgroundColor: _primaryGreen,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'My Livestock',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              fontSize: 17),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Text(
                '${filtered.length} total',
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: _primaryGreen))
            : Column(
                children: [
                  // ── Search + Filters panel ─────────────────────────────
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      children: [
                        // Search bar
                        Container(
                          decoration: BoxDecoration(
                            color: _bgGrey,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFFDDE1E7), width: 1),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(
                                fontSize: 14, color: _textDark),
                            decoration: const InputDecoration(
                              hintText: 'Search livestock…',
                              hintStyle:
                                  TextStyle(fontSize: 13, color: _textMuted),
                              prefixIcon: Icon(Icons.search,
                                  color: _textMuted, size: 20),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Breed + Status dropdowns
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdown<String?>(
                                value: _selectedBreed,
                                hint: 'All Breeds',
                                icon: Icons.pets,
                                items: [
                                  const DropdownMenuItem(
                                      value: null,
                                      child: Text('All Breeds')),
                                  ..._breeds.map((b) => DropdownMenuItem(
                                      value: b, child: Text(b))),
                                ],
                                onChanged: (v) =>
                                    setState(() => _selectedBreed = v),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildDropdown<String?>(
                                value: _selectedStatus,
                                hint: 'All Statuses',
                                icon: Icons.health_and_safety_outlined,
                                items: [
                                  const DropdownMenuItem(
                                      value: null,
                                      child: Text('All Statuses')),
                                  ..._statuses.map((s) => DropdownMenuItem(
                                      value: s, child: Text(s))),
                                ],
                                onChanged: (v) =>
                                    setState(() => _selectedStatus = v),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Date pickers
                        Row(
                          children: [
                            Expanded(
                              child: _buildDateButton(
                                label: _startDate == null
                                    ? 'Start Date'
                                    : DateFormat.yMd()
                                        .format(_startDate!),
                                onTap: () => _pickDate(isStart: true),
                                active: _startDate != null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildDateButton(
                                label: _endDate == null
                                    ? 'End Date'
                                    : DateFormat.yMd().format(_endDate!),
                                onTap: () => _pickDate(isStart: false),
                                active: _endDate != null,
                              ),
                            ),
                          ],
                        ),

                        // Clear filters
                        if (_hasFilters) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _selectedBreed  = null;
                                _selectedStatus = null;
                                _startDate      = null;
                                _endDate        = null;
                              }),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.close,
                                      size: 14, color: _primaryGreen),
                                  SizedBox(width: 3),
                                  Text('Clear Filters',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: _primaryGreen,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // divider
                  const Divider(height: 1, color: Color(0xFFEBEEF2)),

                  // ── List ──────────────────────────────────────────────────
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refreshLivestock,
                      color: _primaryGreen,
                      child: filtered.isEmpty
                          ? _buildEmpty()
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (ctx, idx) =>
                                  _buildCard(ctx, filtered[idx], viewModel),
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
              builder: (_) => const AddLiveStockScreen()),
        ).then((_) => _refreshLivestock()),
        backgroundColor: _primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Livestock',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
        elevation: 3,
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Widget _buildDropdown<T>({
    required T value,
    required String hint,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _bgGrey,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDDE1E7), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: Row(
            children: [
              Icon(icon, size: 15, color: _textMuted),
              const SizedBox(width: 6),
              Text(hint,
                  style: const TextStyle(
                      fontSize: 12, color: _textMuted)),
            ],
          ),
          style: const TextStyle(
              fontSize: 12, color: _textDark),
          dropdownColor: Colors.white,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required VoidCallback onTap,
    required bool active,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: active ? _lightGreen : _bgGrey,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: active
                  ? const Color(0xFFA5D6A7)
                  : const Color(0xFFDDE1E7),
              width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 13,
                color: active ? _primaryGreen : _textMuted),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12,
                    color: active ? _primaryGreen : _textMuted,
                    fontWeight: active
                        ? FontWeight.w700
                        : FontWeight.normal),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, dynamic l, LivestockViewModel vm) {
    final dob = DateFormat.yMMMd().format(l.dateOfBirth.toLocal());
    return Dismissible(
      key: ValueKey(l.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 22),
            SizedBox(height: 3),
            Text('Delete',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: const Text('Delete Record',
                style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 16)),
            content: Text(
                'Delete ${l.name}? This action cannot be undone.',
                style: const TextStyle(fontSize: 13)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel',
                    style: TextStyle(color: _textMuted)),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        vm.deleteLivestock(l.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Livestock deleted'),
            backgroundColor: _primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => EditLiveStockScreen(livestock: l)),
        ).then((_) => _refreshLivestock()),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    l.name.isNotEmpty ? l.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _primaryGreen),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l.name,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _textDark),
                          ),
                        ),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: _statusBg(l.status),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            l.status,
                            style: TextStyle(
                                fontSize: 11,
                                color: _statusColor(l.status),
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${l.breed}  •  Tag #${l.tagNumber}',
                      style: const TextStyle(
                          fontSize: 12, color: _textMuted),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Born $dob',
                      style: const TextStyle(
                          fontSize: 11, color: _textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right,
                  color: _textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return ListView(
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                    color: _lightGreen, shape: BoxShape.circle),
                child: const Icon(Icons.pets,
                    color: _primaryGreen, size: 34),
              ),
              const SizedBox(height: 16),
              const Text('No livestock found',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _textDark)),
              const SizedBox(height: 6),
              const Text('Tap + Add Livestock to get started.',
                  style:
                      TextStyle(fontSize: 13, color: _textMuted)),
            ],
          ),
        ),
      ],
    );
  }
}
