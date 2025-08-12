import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../view_models/livestock_viewmodel.dart';
import '../sidebar_menu.dart';
import '../livestock_screen/edit_livestock_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    await Provider.of<LivestockViewModel>(context, listen: false).fetchLivestocks();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LivestockViewModel>(context);
    final totalLivestocks = viewModel.livestocks.length;
    final formattedDate = DateFormat.yMMMMd().format(DateTime.now());

    final primaryGreen = Colors.green.shade700;
    final accentGreen = Colors.green.shade500;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.lightGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: const Text(
              'Livestock Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ),
      ),
      drawer: const SidebarMenu(),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Colors.green))
            : RefreshIndicator(
                onRefresh: _loadData,
                color: Colors.green,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.green, Colors.lightGreen],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hello, Farmer! 👋',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.green.shade100,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.agriculture,
                              size: 50,
                              color: Colors.white70,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Dashboard Cards
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.1,
                        children: [
                          _DashboardCard(
                            title: 'Total Livestock',
                            value: totalLivestocks.toString(),
                            icon: const Text('🐷', style: TextStyle(fontSize: 40)),
                            color: primaryGreen,
                            onTap: () {
                              Navigator.pushNamed(context, '/livestockList')
                                  .then((_) => _loadData());
                            },
                          ),
                          _DashboardCard(
                            title: 'Add Livestock',
                            value: '',
                            icon: const Icon(Icons.add_circle, size: 40, color: Colors.white),
                            color: accentGreen,
                            onTap: () {
                              Navigator.pushNamed(context, '/addLivestock')
                                  .then((_) => _loadData());
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Recent Livestock
                      Text(
                        'Recent Livestock',
                        style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: primaryGreen,
                            ),
                      ),
                      const SizedBox(height: 8),
                      viewModel.livestocks.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                'No recent livestock.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : Column(
                              children: viewModel.livestocks.take(3).map((livestock) {
                                final dob = DateFormat.yMMMd().format(livestock.dateOfBirth.toLocal());
                                return Card(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  elevation: 3,
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.green.shade100,
                                      child: Text(
                                        livestock.name.isNotEmpty
                                            ? livestock.name[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    title: Text(
                                      livestock.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      'Breed: ${livestock.breed}\nDOB: $dob',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    isThreeLine: true,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditLiveStockScreen(livestock: livestock),
                                      ),
                                    ).then((_) => _loadData()),
                                  ),
                                );
                              }).toList(),
                            ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _DashboardCard extends StatefulWidget {
  final String title;
  final String value;
  final Widget icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<_DashboardCard> with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.color.withOpacity(0.95), widget.color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.icon,
              Text(
                widget.value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28, // Increased from 22
                  color: Colors.white,
                ),
              ),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18, // Increased from 14
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
