import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminAnalyticsPage extends ConsumerStatefulWidget {
  const AdminAnalyticsPage({super.key});

  @override
  ConsumerState<AdminAnalyticsPage> createState() => _AdminAnalyticsPageState();
}

class _AdminAnalyticsPageState extends ConsumerState<AdminAnalyticsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeframe = '1_year';

  final Map<String, dynamic> _systemData = {
    'totalProjects': 156,
    'pendingReviews': 23,
    'approvedProjects': 98,
    'rejectedProjects': 35,
    'totalNGOs': 45,
    'activeNGOs': 38,
    'totalBuyers': 234,
    'activeBuyers': 189,
    'totalCreditsIssued': 89500,
    'totalCreditsRetired': 42300,
    'totalTransactionVolume': 1850000.0,
    'averageReviewTime': 12.5,
    'aiAccuracyScore': 94.2,
    'systemUptime': 99.8,
    'flaggedProjects': 8,
    'revenueGenerated': 6937500.0,
    'monthlyStats': [
      {'month': 'Jan', 'projects': 18, 'approvals': 14, 'rejections': 4, 'revenue': 637500, 'credits': 2800, 'efficiency': 92.3},
      {'month': 'Feb', 'projects': 22, 'approvals': 16, 'rejections': 6, 'revenue': 690000, 'credits': 3200, 'efficiency': 94.1},
      {'month': 'Mar', 'projects': 25, 'approvals': 19, 'rejections': 6, 'revenue': 825000, 'credits': 3800, 'efficiency': 95.8},
      {'month': 'Apr', 'projects': 20, 'approvals': 15, 'rejections': 5, 'revenue': 667500, 'credits': 3000, 'efficiency': 93.7},
      {'month': 'May', 'projects': 28, 'approvals': 21, 'rejections': 7, 'revenue': 937500, 'credits': 4200, 'efficiency': 96.2},
      {'month': 'Jun', 'projects': 23, 'approvals': 18, 'rejections': 5, 'revenue': 765000, 'credits': 3600, 'efficiency': 97.1},
    ],
    'topNGOs': [
      {'name': 'Green Coast Foundation', 'projects': 12, 'credits': 15750, 'rating': 4.8},
      {'name': 'Bengal Environmental Group', 'projects': 9, 'credits': 12400, 'rating': 4.6},
      {'name': 'Backwater Conservation Society', 'projects': 8, 'credits': 10200, 'rating': 4.7},
      {'name': 'Tamil Coast Guardians', 'projects': 11, 'credits': 14800, 'rating': 4.9},
    ],
    'aiMetrics': {
      'photoVerificationAccuracy': 96.8,
      'documentValidationAccuracy': 94.2,
      'fraudDetectionRate': 98.5,
      'falsePositiveRate': 2.1,
      'processingTime': 1.2,
      'totalAnalyzed': 1568,
    },
    'geographicDistribution': [
      {'region': 'West Bengal', 'projects': 45, 'percentage': 28.8},
      {'region': 'Kerala', 'projects': 32, 'percentage': 20.5},
      {'region': 'Tamil Nadu', 'projects': 38, 'percentage': 24.4},
      {'region': 'Karnataka', 'projects': 21, 'percentage': 13.5},
      {'region': 'Andhra Pradesh', 'projects': 20, 'percentage': 12.8},
    ],
    'qualityMetrics': [
      {'metric': 'Project Compliance Rate', 'value': 94.2, 'trend': '+2.1%'},
      {'metric': 'Documentation Quality', 'value': 91.8, 'trend': '+1.5%'},
      {'metric': 'Verification Success Rate', 'value': 96.5, 'trend': '+0.8%'},
      {'metric': 'Stakeholder Satisfaction', 'value': 88.9, 'trend': '+3.2%'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'System Overview',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              DropdownButton<String>(
                value: _selectedTimeframe,
                items: const [
                  DropdownMenuItem(value: '1_month', child: Text('Last Month')),
                  DropdownMenuItem(value: '3_months', child: Text('Last 3 Months')),
                  DropdownMenuItem(value: '6_months', child: Text('Last 6 Months')),
                  DropdownMenuItem(value: '1_year', child: Text('Last Year')),
                ],
                onChanged: (value) => setState(() => _selectedTimeframe = value!),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildAnimatedMetricCard(
                'Total Projects',
                '${_systemData['totalProjects']}',
                Icons.eco,
                Colors.green,
                '${_systemData['pendingReviews']} pending',
                '+12.5%',
              ),
              _buildAnimatedMetricCard(
                'Platform Revenue',
                '₹${(_systemData['revenueGenerated'] / 100000).toStringAsFixed(1)}L',
                Icons.currency_rupee,
                Colors.blue,
                'Last 6 months',
                '+18.2%',
              ),
              _buildAnimatedMetricCard(
                'Credits Issued',
                '${(_systemData['totalCreditsIssued'] / 1000).toStringAsFixed(0)}K',
                Icons.verified,
                Colors.orange,
                '${(_systemData['totalCreditsRetired'] / 1000).toStringAsFixed(0)}K retired',
                '+25.3%',
              ),
              _buildAnimatedMetricCard(
                'AI Accuracy',
                '${_systemData['aiAccuracyScore']}%',
                Icons.psychology,
                Colors.purple,
                'Photo + Document',
                '+2.1%',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Text(
                        'Action Required',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      child: Text('${_systemData['pendingReviews']}'),
                    ),
                    title: const Text('Pending Project Reviews'),
                    subtitle: const Text('Projects awaiting admin review'),
                    trailing: ElevatedButton(
                      onPressed: () => context.go('/admin-dashboard'),
                      child: const Text('Review'),
                    ),
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.withOpacity(0.1),
                      child: Text('${_systemData['flaggedProjects']}'),
                    ),
                    title: const Text('Flagged Projects'),
                    subtitle: const Text('Projects flagged by AI for manual review'),
                    trailing: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Investigate'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildRevenueChart(),
          const SizedBox(height: 16),
          _buildSystemEfficiencyChart(),
        ],
      ),
    );
  }

  Widget _buildNGOsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'NGO Performance',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Onboard NGO'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildNGOStatCard(
                  'Total NGOs',
                  '${_systemData['totalNGOs']}',
                  Icons.business,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNGOStatCard(
                  'Active NGOs',
                  '${_systemData['activeNGOs']}',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Top Performing NGOs',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...(_systemData['topNGOs'] as List).map((ngo) =>
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.withOpacity(0.1),
                  child: Text(
                    ngo['rating'].toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(ngo['name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Projects: ${ngo['projects']}'),
                    Text('Credits Generated: ${ngo['credits']} tCO2e'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...List.generate(
                      5,
                      (index) => Icon(
                        Icons.star,
                        size: 16,
                        color: index < ngo['rating'].floor() ? Colors.amber : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Geographic Distribution',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...(_systemData['geographicDistribution'] as List).map((region) =>
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(region['region']),
                              Text('${region['projects']} projects (${region['percentage']}%)'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: region['percentage'] / 100,
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsightsTab() {
    final aiMetrics = _systemData['aiMetrics'] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI System Performance',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.psychology, color: Colors.purple),
                      const SizedBox(width: 8),
                      const Text(
                        'AI Accuracy Metrics',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2,
                    children: [
                      _buildAIMetricCard(
                        'Photo Verification',
                        '${aiMetrics['photoVerificationAccuracy']}%',
                        Colors.green,
                      ),
                      _buildAIMetricCard(
                        'Document Validation',
                        '${aiMetrics['documentValidationAccuracy']}%',
                        Colors.blue,
                      ),
                      _buildAIMetricCard(
                        'Fraud Detection',
                        '${aiMetrics['fraudDetectionRate']}%',
                        Colors.red,
                      ),
                      _buildAIMetricCard(
                        'Processing Time',
                        '${aiMetrics['processingTime']}s avg',
                        Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Analysis Summary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${aiMetrics['totalAnalyzed']}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const Text('Total Projects Analyzed'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${aiMetrics['falsePositiveRate']}%',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const Text('False Positive Rate'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Recommendations',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildRecommendationTile(
                    'Model Retraining',
                    'Consider retraining the photo verification model with recent data',
                    Icons.model_training,
                    Colors.blue,
                    'Medium Priority',
                  ),
                  _buildRecommendationTile(
                    'Threshold Adjustment',
                    'Fraud detection threshold could be optimized for better accuracy',
                    Icons.tune,
                    Colors.orange,
                    'Low Priority',
                  ),
                  _buildRecommendationTile(
                    'Performance Optimization',
                    'Processing time can be improved by optimizing the validation pipeline',
                    Icons.speed,
                    Colors.green,
                    'High Priority',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Quality Metrics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...(_systemData['qualityMetrics'] as List).map((metric) =>
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          metric['metric'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            metric['trend'],
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: metric['value'] / 100,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              metric['value'] >= 90 ? Colors.green :
                              metric['value'] >= 75 ? Colors.orange : Colors.red,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${metric['value']}%',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Performance Benchmarks',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildBenchmarkRow('Average Review Time', '${_systemData['averageReviewTime']} days', 'Target: <14 days', Colors.green),
                  _buildBenchmarkRow('System Availability', '${_systemData['systemUptime']}%', 'Target: >99%', Colors.green),
                  _buildBenchmarkRow('User Satisfaction', '88.9%', 'Target: >85%', Colors.green),
                  _buildBenchmarkRow('Data Accuracy', '96.5%', 'Target: >95%', Colors.green),
                ],
              ),
            ),
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
          const Text(
            'System Reports',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Executive Reports',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildReportTile(
                    'System Performance Dashboard',
                    'Comprehensive system health and performance metrics',
                    Icons.dashboard,
                    Colors.blue,
                  ),
                  _buildReportTile(
                    'NGO Performance Summary',
                    'Detailed analysis of NGO activities and compliance',
                    Icons.business,
                    Colors.green,
                  ),
                  _buildReportTile(
                    'Market Analytics Report',
                    'Carbon credit market trends and transaction analysis',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                  _buildReportTile(
                    'AI System Audit',
                    'AI model performance and accuracy assessment',
                    Icons.psychology,
                    Colors.purple,
                  ),
                  _buildReportTile(
                    'Compliance Overview',
                    'Regulatory compliance status and audit trails',
                    Icons.verified,
                    Colors.indigo,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Automated Alerts',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('High Priority Reviews'),
                    subtitle: const Text('Notify when critical projects need review'),
                    value: true,
                    onChanged: (value) {},
                  ),
                  SwitchListTile(
                    title: const Text('System Performance'),
                    subtitle: const Text('Alert on system performance degradation'),
                    value: true,
                    onChanged: (value) {},
                  ),
                  SwitchListTile(
                    title: const Text('AI Anomalies'),
                    subtitle: const Text('Notify when AI detects unusual patterns'),
                    value: false,
                    onChanged: (value) {},
                  ),
                  SwitchListTile(
                    title: const Text('Compliance Issues'),
                    subtitle: const Text('Alert on regulatory compliance violations'),
                    value: true,
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedMetricCard(String title, String value, IconData icon, Color color, String subtitle, String trend) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
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
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          trend,
                          style: const TextStyle(
                            color: Colors.green,
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
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
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

  Widget _buildNGOStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildAIMetricCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationTile(String title, String subtitle, IconData icon, Color color, String priority) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Chip(
        label: Text(priority),
        backgroundColor: priority == 'High Priority' ? Colors.red.withOpacity(0.1) :
                         priority == 'Medium Priority' ? Colors.orange.withOpacity(0.1) :
                         Colors.green.withOpacity(0.1),
      ),
    );
  }

  Widget _buildBenchmarkRow(String metric, String value, String target, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(metric)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              target,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTile(String title, String subtitle, IconData icon, Color color) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Generating $title...'),
              backgroundColor: Colors.green,
            ),
          );
        },
        icon: const Icon(Icons.download, size: 16),
        label: const Text('Download'),
      ),
    );
  }

  Widget _buildRevenueChart() {
    final monthlyStats = _systemData['monthlyStats'] as List;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Revenue Trends (₹)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 100000,
                    verticalInterval: 1,
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < monthlyStats.length) {
                            return Text(monthlyStats[value.toInt()]['month']);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          return Text('₹${(value / 100000).toStringAsFixed(0)}L');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: monthlyStats.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        return FlSpot(index.toDouble(), data['revenue'].toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withOpacity(0.1),
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

  Widget _buildSystemEfficiencyChart() {
    final monthlyStats = _systemData['monthlyStats'] as List;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Efficiency & Project Volume',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 30,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final month = monthlyStats[group.x.toInt()]['month'];
                        final value = rod.toY.round();
                        final label = rodIndex == 0 ? 'Projects' : 'Approvals';
                        return BarTooltipItem(
                          '$month\n$label: $value',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < monthlyStats.length) {
                            return Text(monthlyStats[value.toInt()]['month']);
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
                  borderData: FlBorderData(show: false),
                  barGroups: monthlyStats.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data['projects'].toDouble(),
                          color: Colors.blue,
                          width: 12,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: data['approvals'].toDouble(),
                          color: Colors.green,
                          width: 12,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Total Projects', Colors.blue),
                const SizedBox(width: 20),
                _buildLegendItem('Approved', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Analytics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin-dashboard'),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'NGOs', icon: Icon(Icons.business)),
            Tab(text: 'AI Insights', icon: Icon(Icons.psychology)),
            Tab(text: 'Quality', icon: Icon(Icons.verified)),
            Tab(text: 'Reports', icon: Icon(Icons.file_download)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildNGOsTab(),
          _buildAIInsightsTab(),
          _buildQualityTab(),
          _buildReportsTab(),
        ],
      ),
    );
  }
}