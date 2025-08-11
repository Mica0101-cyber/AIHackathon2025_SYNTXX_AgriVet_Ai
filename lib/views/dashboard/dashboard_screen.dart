import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/livestock_viewmodel.dart';
import '../sidebar_menu.dart';
import 'package:intl/intl.dart';
import '../../views/livestock_screen/edit_livestock_screen.dart';

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
    await Provider.of<LivestockViewModel>(context, listen: false)
        .fetchLivestocks();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LivestockViewModel>(context);
    final totalLivestocks = viewModel.livestocks.length;
    final now = DateTime.now();
    final formattedDate = DateFormat.yMMMMd().format(now);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Livestock Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.greenAccent,
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
                      // Greeting Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green.shade700, Colors.green.shade400],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, Farmer! 👋',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green.shade100,
                              ),
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
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 1.1,
                        children: [
                          _DashboardCard(
                            title: 'Total Livestock',
                            value: totalLivestocks.toString(),
                            icon: const Text('🐷', style: TextStyle(fontSize: 40)),
                            color: Colors.orange.shade400,
                            onTap: () {
                              Navigator.pushNamed(context, '/livestock')
                                  .then((_) => _loadData());
                            },
                          ),
                          _DashboardCard(
                            title: 'Add Livestock',
                            value: '+',
                            icon: const Icon(Icons.add_circle, size: 40, color: Colors.white),
                            color: Colors.green.shade500,
                            onTap: () {
                              Navigator.pushNamed(context, '/addLivestock')
                                  .then((_) => _loadData());
                            },
                          ),
                          _DashboardCard(
                            title: 'Feed Records',
                            value: '',
                            icon: const Icon(Icons.restaurant_menu, size: 36, color: Colors.white),
                            color: Colors.purple.shade400,
                            onTap: () {
                              Navigator.pushNamed(context, '/feedRecords');
                            },
                          ),
                          _DashboardCard(
                            title: 'Weight Records',
                            value: '',
                            icon: const Icon(Icons.monitor_weight, size: 36, color: Colors.white),
                            color: Colors.blue.shade400,
                            onTap: () {
                              Navigator.pushNamed(context, '/weightRecords');
                            },
                          ),
                          _DashboardCard(
                            title: 'Health Records',
                            value: '',
                            icon: const Icon(Icons.medical_services, size: 36, color: Colors.white),
                            color: Colors.red.shade400,
                            onTap: () {
                              Navigator.pushNamed(context, '/healthRecords');
                            },
                          ),
                          _DashboardCard(
                            title: 'Breeding Records',
                            value: '',
                            icon: const Icon(Icons.medical_services, size: 36, color: Colors.white),
                            color: Colors.red.shade400,
                            onTap: () {
                              Navigator.pushNamed(context, '/breedingRecords');
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
                              color: Colors.green.shade800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      viewModel.livestocks.isEmpty
                          ? const Text('No recent livestock.', style: TextStyle(color: Colors.grey))
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: viewModel.livestocks.length > 3
                                  ? 3
                                  : viewModel.livestocks.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, index) {
                                final livestock = viewModel.livestocks[index];
                                final dob = DateFormat.yMMMd()
                                    .format(livestock.dateOfBirth.toLocal());
                                return ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  tileColor: Colors.white,
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
                                      builder: (_) => EditLiveStockScreen(
                                          livestock: livestock),
                                    ),
                                  ).then((_) => _loadData()),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            icon,
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
