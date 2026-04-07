import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../view_models/livestock_viewmodel.dart';
import '../sidebar_menu.dart';

// ─────────────────────────────────────────────
// Data Models
// ─────────────────────────────────────────────

class _DailyPrice {
  final String day; // e.g. "Mon", "Tue"
  final double price; // ₱ per kg
  const _DailyPrice(this.day, this.price);
}

class _DailyWeight {
  final String date; // e.g. "Apr 1"
  final double weightKg;
  const _DailyWeight(this.date, this.weightKg);
}

// ─────────────────────────────────────────────
// Dashboard Screen
// ─────────────────────────────────────────────

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = true;

  // ── Brand Colors ──────────────────────────
  final Color primaryGreen = const Color(0xFF2E7D32);
  final Color accentGreen = const Color(0xFF43A047);
  final Color lightGreen = const Color(0xFFE8F5E9);
  final Color bgGrey = const Color(0xFFF4F6F8);
  final Color textDark = const Color(0xFF1A2332);
  final Color textMuted = const Color(0xFF90A4AE);
  final Color cardBg = Colors.white;

  // ── Sample daily market price data (last 7 days) ──
  final List<_DailyPrice> _dailyPrices = const [
    _DailyPrice('Mon', 122.50),
    _DailyPrice('Tue', 124.00),
    _DailyPrice('Wed', 123.25),
    _DailyPrice('Thu', 125.75),
    _DailyPrice('Fri', 126.50),
    _DailyPrice('Sat', 124.00),
    _DailyPrice('Sun', 125.00),
  ];

  // ── Sample daily weight data for a pig (last 14 days) ──
  final List<_DailyWeight> _dailyWeights = const [
    _DailyWeight('Apr 1',  88.0),
    _DailyWeight('Apr 2',  88.5),
    _DailyWeight('Apr 3',  89.2),
    _DailyWeight('Apr 4',  89.8),
    _DailyWeight('Apr 5',  90.5),
    _DailyWeight('Apr 6',  91.0),
    _DailyWeight('Apr 7',  91.4),
    _DailyWeight('Apr 8',  92.0),
    _DailyWeight('Apr 9',  92.6),
    _DailyWeight('Apr 10', 93.1),
    _DailyWeight('Apr 11', 93.8),
    _DailyWeight('Apr 12', 94.2),
    _DailyWeight('Apr 13', 94.9),
    _DailyWeight('Apr 14', 95.5),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    await Provider.of<LivestockViewModel>(context, listen: false)
        .fetchLivestocks();
    if (mounted) setState(() => _loading = false);
  }

  // ─────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LivestockViewModel>(context);
    final totalLivestocks = viewModel.livestocks.length;

    return Scaffold(
      backgroundColor: bgGrey,
      appBar: _buildAppBar(),
      drawer: const SidebarMenu(),
      body: SafeArea(
        child: _loading
            ? Center(child: CircularProgressIndicator(color: primaryGreen))
            : RefreshIndicator(
                onRefresh: _loadData,
                color: primaryGreen,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Stat Cards ──
                      _buildStatRow(totalLivestocks),
                      const SizedBox(height: 16),

                      // ── AI Insights ──
                      _buildAICard(),
                      const SizedBox(height: 16),

                      // ── Daily Market Price Bar Chart ──
                      _buildMarketBarChartCard(),
                      const SizedBox(height: 16),

                      // ── Daily Weight Line Chart ──
                      _buildWeightLineChartCard(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // AppBar
  // ─────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'AGRIVET AI',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
          fontSize: 17,
        ),
      ),
      backgroundColor: primaryGreen,
      elevation: 0,
      centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Center(
            child: InkWell(
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/signin'),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.3), width: 1),
                ),
                child: const Row(
                  children: [
                    Text('Logout',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    SizedBox(width: 5),
                    Icon(Icons.logout, color: Colors.white, size: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // Stat Row
  // ─────────────────────────────────────────

  Widget _buildStatRow(int totalLivestocks) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Total Pigs',
            value: totalLivestocks > 0 ? '$totalLivestocks' : '0',
            icon: '🐷',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Reminders',
            value: '0',
            icon: '🔔',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 13,
                      color: textMuted,
                      fontWeight: FontWeight.w600)),
              Text(icon, style: const TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                  height: 1)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // AI Insights Card
  // ─────────────────────────────────────────

  Widget _buildAICard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: lightGreen,
        border: Border.all(color: const Color(0xFFA5D6A7), width: 1.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: primaryGreen, size: 18),
                  const SizedBox(width: 7),
                  Text('Predictive AI Insights',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textDark)),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/chatScreen'),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Ask AI',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pig ID: 0000001',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: textDark)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: lightGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('6 months',
                          style: TextStyle(
                              color: primaryGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Divider(height: 1, color: Colors.grey.shade100),
                const SizedBox(height: 8),
                Text(
                  'Based on current weight gain trend, this pig is on track to reach market weight (95–100 kg) within 2 weeks. Consider scheduling a health check.',
                  style: TextStyle(
                      fontSize: 13, color: textDark, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Market Price Bar Chart — Daily
  // ─────────────────────────────────────────

  Widget _buildMarketBarChartCard() {
    // Compute weekly average for badge
    final avg = _dailyPrices.map((e) => e.price).reduce((a, b) => a + b) /
        _dailyPrices.length;

    // Determine min/max with padding
    final prices = _dailyPrices.map((e) => e.price).toList();
    final minPrice = (prices.reduce((a, b) => a < b ? a : b) - 2)
        .floorToDouble();
    final maxPrice = (prices.reduce((a, b) => a > b ? a : b) + 2)
        .ceilToDouble();
    final highestIdx =
        prices.indexOf(prices.reduce((a, b) => a > b ? a : b));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Market Price',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textDark)),
                  const SizedBox(height: 2),
                  Text('₱ per kg — this week',
                      style:
                          TextStyle(fontSize: 12, color: textMuted)),
                ],
              ),
              // Weekly avg badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Avg ₱${avg.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontSize: 11,
                      color: primaryGreen,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Chart ──
          SizedBox(
            height: 175,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxPrice,
                minY: minPrice,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => textDark,
                    getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                      '₱${rod.toY.toStringAsFixed(2)}',
                      const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= _dailyPrices.length) {
                          return const SizedBox();
                        }
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            _dailyPrices[i].day,
                            style: TextStyle(
                                color: textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w500),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 46,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        if (value == minPrice || value == maxPrice) {
                          return const SizedBox();
                        }
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            '₱${value.toInt()}',
                            style: TextStyle(
                                color: textMuted,
                                fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.grey.shade100, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(_dailyPrices.length, (i) {
                  final isHighest = i == highestIdx;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: _dailyPrices[i].price,
                        width: 26,
                        color: isHighest
                            ? primaryGreen
                            : primaryGreen.withOpacity(0.45),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxPrice,
                          color: Colors.grey.shade50,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Daily Weight Line Chart
  // ─────────────────────────────────────────

  Widget _buildWeightLineChartCard() {
    final weights = _dailyWeights.map((e) => e.weightKg).toList();
    final latestWeight = weights.last;
    final firstWeight = weights.first;
    final gained = latestWeight - firstWeight;
    final gainPositive = gained >= 0;

    final minW = (weights.reduce((a, b) => a < b ? a : b) - 2)
        .floorToDouble();
    final maxW = (weights.reduce((a, b) => a > b ? a : b) + 2)
        .ceilToDouble();

    // Build spots — x = day index (0..n-1)
    final spots = List.generate(
      _dailyWeights.length,
      (i) => FlSpot(i.toDouble(), _dailyWeights[i].weightKg),
    );

    // Show every ~3rd label to avoid clutter
    const labelInterval = 3;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily Weight',
                      style: TextStyle(
                          fontSize: 12,
                          color: textMuted,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 3),
                  Text(
                    '${latestWeight.toStringAsFixed(1)} kg',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                        height: 1.1),
                  ),
                  const SizedBox(height: 4),
                  Text('Pig ID: 0000001',
                      style:
                          TextStyle(fontSize: 11, color: textMuted)),
                ],
              ),
              // Gain badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: gainPositive
                      ? lightGreen
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      gainPositive
                          ? Icons.trending_up
                          : Icons.trending_down,
                      size: 13,
                      color:
                          gainPositive ? primaryGreen : Colors.red.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${gained.toStringAsFixed(1)} kg (14d)',
                      style: TextStyle(
                          fontSize: 11,
                          color: gainPositive
                              ? primaryGreen
                              : Colors.red.shade700,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Chart ──
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 3,
                  getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.grey.shade100, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 ||
                            i >= _dailyWeights.length ||
                            i % labelInterval != 0) {
                          return const SizedBox();
                        }
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            _dailyWeights[i].date,
                            style: TextStyle(
                                color: textMuted,
                                fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 3,
                      getTitlesWidget: (value, meta) {
                        if (value == minW || value == maxW) {
                          return const SizedBox();
                        }
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            '${value.toInt()}kg',
                            style: TextStyle(
                                color: textMuted, fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (_dailyWeights.length - 1).toDouble(),
                minY: minW,
                maxY: maxW,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: primaryGreen,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, index) {
                        // Only show dot on the last point
                        if (index == spots.length - 1) {
                          return FlDotCirclePainter(
                            radius: 5,
                            color: Colors.white,
                            strokeWidth: 2.5,
                            strokeColor: primaryGreen,
                          );
                        }
                        return FlDotCirclePainter(
                          radius: 0,
                          color: Colors.transparent,
                          strokeWidth: 0,
                          strokeColor: Colors.transparent,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          primaryGreen.withOpacity(0.22),
                          primaryGreen.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
                // Touch tooltip
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => textDark,
                    getTooltipItems: (spots) => spots
                        .map((s) => LineTooltipItem(
                              '${s.y.toStringAsFixed(1)} kg',
                              const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // ── Show more link ──
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/livestockList'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Show more',
                style: TextStyle(
                    fontSize: 12,
                    color: primaryGreen,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}