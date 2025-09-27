import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

// Data Models
class ProjectAnalytics {
  final String period;
  final int totalProjects;
  final int approvedProjects;
  final int pendingProjects;
  final int rejectedProjects;
  final double totalCredits;
  final double totalRevenue;
  final double impactScore;

  ProjectAnalytics({
    required this.period,
    required this.totalProjects,
    required this.approvedProjects,
    required this.pendingProjects,
    required this.rejectedProjects,
    required this.totalCredits,
    required this.totalRevenue,
    required this.impactScore,
  });
}

class MonthlyData {
  final String month;
  final int projects;
  final double credits;
  final double revenue;
  final double impactScore;

  MonthlyData({
    required this.month,
    required this.projects,
    required this.credits,
    required this.revenue,
    required this.impactScore,
  });
}

// Providers
final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AsyncValue<ProjectAnalytics>>((ref) {
  return AnalyticsNotifier();
});

final monthlyDataProvider = StateNotifierProvider<MonthlyDataNotifier, AsyncValue<List<MonthlyData>>>((ref) {
  return MonthlyDataNotifier();
});

class AnalyticsNotifier extends StateNotifier<AsyncValue<ProjectAnalytics>> {
  AnalyticsNotifier() : super(const AsyncValue.loading()) {
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    try {
      state = const AsyncValue.loading();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      final analytics = ProjectAnalytics(
        period: 'Last 6 Months',
        totalProjects: 15,
        approvedProjects: 12,
        pendingProjects: 2,
        rejectedProjects: 1,
        totalCredits: 18750.0,
        totalRevenue: 281250.0,
        impactScore: 94.5,
      );

      state = AsyncValue.data(analytics);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshAnalytics() async {
    await loadAnalytics();
  }
}

class MonthlyDataNotifier extends StateNotifier<AsyncValue<List<MonthlyData>>> {
  MonthlyDataNotifier() : super(const AsyncValue.loading()) {
    loadMonthlyData();
  }

  Future<void> loadMonthlyData() async {
    try {
      state = const AsyncValue.loading();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final data = [
        MonthlyData(month: 'Jan', projects: 2, credits: 1800.0, revenue: 20250000.0, impactScore: 88.5),
        MonthlyData(month: 'Feb', projects: 3, credits: 2400.0, revenue: 27000000.0, impactScore: 91.2),
        MonthlyData(month: 'Mar', projects: 2, credits: 3200.0, revenue: 36000000.0, impactScore: 93.8),
        MonthlyData(month: 'Apr', projects: 3, credits: 2800.0, revenue: 31500000.0, impactScore: 95.1),
        MonthlyData(month: 'May', projects: 2, credits: 3500.0, revenue: 39375000.0, impactScore: 96.3),
        MonthlyData(month: 'Jun', projects: 3, credits: 4950.0, revenue: 55687500.0, impactScore: 97.8),
      ];

      state = AsyncValue.data(data);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class NgoAnalyticsPage extends ConsumerStatefulWidget {
  const NgoAnalyticsPage({super.key});

  @override
  ConsumerState<NgoAnalyticsPage> createState() => _NgoAnalyticsPageState();
}

class _NgoAnalyticsPageState extends ConsumerState<NgoAnalyticsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeframe = '6_months';
  int _selectedChartIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NGO Analytics Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/ngo-dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(analyticsProvider.notifier).refreshAnalytics();
              ref.read(monthlyDataProvider.notifier).loadMonthlyData();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Performance', icon: Icon(Icons.trending_up)),
            Tab(text: 'Impact', icon: Icon(Icons.eco)),
            Tab(text: 'Reports', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildPerformanceTab(),
          _buildImpactTab(),
          _buildReportsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final analyticsAsync = ref.watch(analyticsProvider);

    return analyticsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading analytics: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(analyticsProvider.notifier).refreshAnalytics(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (analytics) => RefreshIndicator(
        onRefresh: () => ref.read(analyticsProvider.notifier).refreshAnalytics(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeframeSelector(),
              const SizedBox(height: 20),
              _buildKPICards(analytics),
              const SizedBox(height: 20),
              _buildProjectStatusChart(analytics),
              const SizedBox(height: 20),
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.blue),
            const SizedBox(width: 12),
            const Text(
              'Time Period:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedTimeframe,
                  items: const [
                    DropdownMenuItem(value: '1_month', child: Text('Last Month')),
                    DropdownMenuItem(value: '3_months', child: Text('Last 3 Months')),
                    DropdownMenuItem(value: '6_months', child: Text('Last 6 Months')),
                    DropdownMenuItem(value: '1_year', child: Text('Last Year')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedTimeframe = value!);
                    ref.read(analyticsProvider.notifier).refreshAnalytics();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPICards(ProjectAnalytics analytics) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildAnimatedKPICard(
          'Total Projects',
          '${analytics.totalProjects}',
          Icons.eco,
          Colors.green,
          '+${((analytics.totalProjects / 12 - 1) * 100).toStringAsFixed(0)}%',
          Colors.green,
        ),
        _buildAnimatedKPICard(
          'Credits Generated',
          '${analytics.totalCredits.toStringAsFixed(0)}',
          Icons.co2,
          Colors.blue,
          '+22%',
          Colors.green,
        ),
        _buildAnimatedKPICard(
          'Total Revenue',
          '\$${(analytics.totalRevenue / 1000).toStringAsFixed(0)}K',
          Icons.attach_money,
          Colors.orange,
          '+18%',
          Colors.green,
        ),
        _buildAnimatedKPICard(
          'Impact Score',
          '${analytics.impactScore.toStringAsFixed(1)}%',
          Icons.star,
          Colors.purple,
          'Excellent',
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildAnimatedKPICard(String title, String value, IconData icon, Color color, String trend, Color trendColor) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0, end: 1),
      builder: (context, animation, child) {
        return Transform.scale(
          scale: animation,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.1),
                    color.withOpacity(0.05),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: trendColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          trend,
                          style: TextStyle(
                            color: trendColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProjectStatusChart(ProjectAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Project Status Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(
                            color: Colors.green,
                            value: analytics.approvedProjects.toDouble(),
                            title: '${((analytics.approvedProjects / analytics.totalProjects) * 100).toStringAsFixed(0)}%',
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            color: Colors.orange,
                            value: analytics.pendingProjects.toDouble(),
                            title: '${((analytics.pendingProjects / analytics.totalProjects) * 100).toStringAsFixed(0)}%',
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            color: Colors.red,
                            value: analytics.rejectedProjects.toDouble(),
                            title: '${((analytics.rejectedProjects / analytics.totalProjects) * 100).toStringAsFixed(0)}%',
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendItem('Approved', analytics.approvedProjects, Colors.green),
                        const SizedBox(height: 8),
                        _buildLegendItem('Pending', analytics.pendingProjects, Colors.orange),
                        const SizedBox(height: 8),
                        _buildLegendItem('Rejected', analytics.rejectedProjects, Colors.red),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label ($count)',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Submit New Project',
                    Icons.add_circle,
                    Colors.green,
                    () => context.go('/ngo-project-submission'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Export Report',
                    Icons.file_download,
                    Colors.blue,
                    () => _showExportDialog(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildPerformanceTab() {
    final monthlyDataAsync = ref.watch(monthlyDataProvider);

    return monthlyDataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (monthlyData) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChartSelector(),
            const SizedBox(height: 20),
            _buildPerformanceChart(monthlyData),
            const SizedBox(height: 20),
            _buildPerformanceMetrics(monthlyData),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSelector() {
    const options = ['Credits', 'Revenue', 'Projects', 'Impact Score'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'View Performance By:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                return ChoiceChip(
                  label: Text(option),
                  selected: _selectedChartIndex == index,
                  onSelected: (selected) {
                    setState(() => _selectedChartIndex = index);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceChart(List<MonthlyData> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getChartTitle(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 1,
                    verticalInterval: 1,
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < data.length) {
                            return Text(data[value.toInt()].month);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((entry) {
                        final index = entry.key;
                        final monthData = entry.value;
                        return FlSpot(index.toDouble(), _getChartValue(monthData));
                      }).toList(),
                      isCurved: true,
                      color: _getChartColor(),
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: _getChartColor().withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getChartTitle() {
    switch (_selectedChartIndex) {
      case 0: return 'Credits Generated Over Time';
      case 1: return 'Revenue Growth';
      case 2: return 'Projects Submitted';
      case 3: return 'Impact Score Trend';
      default: return 'Performance Chart';
    }
  }

  double _getChartValue(MonthlyData data) {
    switch (_selectedChartIndex) {
      case 0: return data.credits / 1000; // Scale down for better visualization
      case 1: return data.revenue / 1000;
      case 2: return data.projects.toDouble();
      case 3: return data.impactScore;
      default: return 0;
    }
  }

  Color _getChartColor() {
    switch (_selectedChartIndex) {
      case 0: return Colors.green;
      case 1: return Colors.orange;
      case 2: return Colors.blue;
      case 3: return Colors.purple;
      default: return Colors.blue;
    }
  }

  Widget _buildPerformanceMetrics(List<MonthlyData> data) {
    final latestMonth = data.last;
    final previousMonth = data[data.length - 2];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Insights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
              'Credits Growth',
              '${((latestMonth.credits - previousMonth.credits) / previousMonth.credits * 100).toStringAsFixed(1)}%',
              latestMonth.credits > previousMonth.credits,
            ),
            _buildMetricRow(
              'Revenue Growth',
              '${((latestMonth.revenue - previousMonth.revenue) / previousMonth.revenue * 100).toStringAsFixed(1)}%',
              latestMonth.revenue > previousMonth.revenue,
            ),
            _buildMetricRow(
              'Impact Score',
              '${latestMonth.impactScore.toStringAsFixed(1)}%',
              latestMonth.impactScore > previousMonth.impactScore,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, bool isPositive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: isPositive ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEnvironmentalImpact(),
          const SizedBox(height: 20),
          _buildSocialImpact(),
          const SizedBox(height: 20),
          _buildSDGAlignment(),
        ],
      ),
    );
  }

  Widget _buildEnvironmentalImpact() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.nature, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Environmental Impact',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildImpactMetric(
                    'CO2 Sequestered',
                    '18,750',
                    'tCO2e',
                    Icons.air,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildImpactMetric(
                    'Area Restored',
                    '142.5',
                    'hectares',
                    Icons.landscape,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildImpactMetric(
                    'Biodiversity Score',
                    '94.5',
                    '/ 100',
                    Icons.pets,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildImpactMetric(
                    'Water Quality',
                    'Excellent',
                    'Grade A',
                    Icons.water_drop,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialImpact() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Social Impact',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSocialMetricTile('Communities Benefited', '12 villages', Icons.location_city),
            _buildSocialMetricTile('Livelihoods Supported', '450 families', Icons.work),
            _buildSocialMetricTile('Training Programs', '8 completed', Icons.school),
            _buildSocialMetricTile('Women Participation', '65%', Icons.woman),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMetricTile(String title, String value, IconData icon) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.orange.withOpacity(0.1),
        child: Icon(icon, color: Colors.orange),
      ),
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSDGAlignment() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.public, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'UN SDG Alignment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSDGChip('SDG 13: Climate Action', Colors.green),
                _buildSDGChip('SDG 14: Life Below Water', Colors.blue),
                _buildSDGChip('SDG 15: Life on Land', Colors.green.shade700),
                _buildSDGChip('SDG 1: No Poverty', Colors.red),
                _buildSDGChip('SDG 5: Gender Equality', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSDGChip(String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }

  Widget _buildImpactMetric(String title, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            unit,
            style: TextStyle(fontSize: 10, color: color),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportCategories(),
          const SizedBox(height: 20),
          _buildCustomReportBuilder(),
          const SizedBox(height: 20),
          _buildRecentReports(),
        ],
      ),
    );
  }

  Widget _buildReportCategories() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Standard Reports',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildReportTile(
              'Project Performance Report',
              'Comprehensive analysis of all projects with detailed metrics',
              Icons.analytics,
              Colors.blue,
              'PDF, Excel',
              () => _generateReport('performance'),
            ),
            _buildReportTile(
              'Carbon Credit Summary',
              'Detailed breakdown of carbon credits generated and verified',
              Icons.eco,
              Colors.green,
              'PDF, CSV',
              () => _generateReport('credits'),
            ),
            _buildReportTile(
              'Financial Overview',
              'Revenue analysis and financial performance metrics',
              Icons.attach_money,
              Colors.orange,
              'PDF, Excel',
              () => _generateReport('financial'),
            ),
            _buildReportTile(
              'Impact Assessment',
              'Environmental and social impact detailed analysis',
              Icons.nature,
              Colors.purple,
              'PDF',
              () => _generateReport('impact'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTile(String title, String subtitle, IconData icon, Color color, String formats, VoidCallback onGenerate) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            const SizedBox(height: 4),
            Text(
              'Available formats: $formats',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: ElevatedButton.icon(
          onPressed: onGenerate,
          icon: const Icon(Icons.download, size: 16),
          label: const Text('Generate'),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
          ),
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildCustomReportBuilder() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Custom Report Builder',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Select metrics to include in your custom report:'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('Project Status'),
                  selected: true,
                  onSelected: (selected) {},
                ),
                FilterChip(
                  label: const Text('Credit Generation'),
                  selected: true,
                  onSelected: (selected) {},
                ),
                FilterChip(
                  label: const Text('Revenue Analytics'),
                  selected: false,
                  onSelected: (selected) {},
                ),
                FilterChip(
                  label: const Text('Impact Metrics'),
                  selected: true,
                  onSelected: (selected) {},
                ),
                FilterChip(
                  label: const Text('Timeline Analysis'),
                  selected: false,
                  onSelected: (selected) {},
                ),
                FilterChip(
                  label: const Text('Compliance Status'),
                  selected: true,
                  onSelected: (selected) {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showCustomReportDialog(),
                    icon: const Icon(Icons.build),
                    label: const Text('Build Custom Report'),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _scheduleReport(),
                  icon: const Icon(Icons.schedule),
                  label: const Text('Schedule'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentReports() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Reports',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRecentReportItem('Project Performance Q4 2024', 'Generated 2 days ago', Icons.analytics),
            _buildRecentReportItem('Carbon Credits Summary Dec', 'Generated 5 days ago', Icons.eco),
            _buildRecentReportItem('Financial Overview 2024', 'Generated 1 week ago', Icons.attach_money),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentReportItem(String title, String date, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Text(date),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadReport(title),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareReport(title),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Analytics Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select export format:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF Report'),
              onTap: () {
                Navigator.pop(context);
                _exportReport('PDF');
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Excel Spreadsheet'),
              onTap: () {
                Navigator.pop(context);
                _exportReport('Excel');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _exportReport(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting analytics as $format...'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'View',
          onPressed: () {},
        ),
      ),
    );
  }

  void _generateReport(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generating $type report...'),
        backgroundColor: Colors.blue,
        action: SnackBarAction(
          label: 'View Progress',
          onPressed: () {},
        ),
      ),
    );
  }

  void _showCustomReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Report Configuration'),
        content: const Text('Advanced report builder will be opened...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _generateReport('custom');
            },
            child: const Text('Create Report'),
          ),
        ],
      ),
    );
  }

  void _scheduleReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report scheduling feature coming soon...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _downloadReport(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading $title...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareReport(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing $title...'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}