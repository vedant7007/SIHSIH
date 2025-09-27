import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PortfolioPage extends ConsumerStatefulWidget {
  const PortfolioPage({super.key});

  @override
  ConsumerState<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends ConsumerState<PortfolioPage> with TickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _ownedCredits = [
    {
      'id': '1',
      'project': 'Coastal Mangrove Project',
      'ngo': 'Green Coast Foundation',
      'quantity': 25,
      'purchasePrice': 15.0,
      'currentPrice': 18.0,
      'purchaseDate': '2024-01-15',
      'status': 'Active',
      'serialNumbers': ['BCR-001-000001', 'BCR-001-000002'],
      'retirementEligible': true,
      'location': 'West Bengal, India',
      'vintage': '2024',
    },
    {
      'id': '2',
      'project': 'Sundarbans Restoration',
      'ngo': 'Bengal Environmental Group',
      'quantity': 50,
      'purchasePrice': 18.0,
      'currentPrice': 20.0,
      'purchaseDate': '2024-02-01',
      'status': 'Active',
      'serialNumbers': ['BCR-002-000001', 'BCR-002-000002'],
      'retirementEligible': true,
      'location': 'Bangladesh Border',
      'vintage': '2024',
    },
    {
      'id': '3',
      'project': 'Kerala Backwater Initiative',
      'ngo': 'Backwater Conservation Society',
      'quantity': 15,
      'purchasePrice': 12.0,
      'currentPrice': 12.0,
      'purchaseDate': '2024-02-10',
      'status': 'Active',
      'serialNumbers': ['BCR-003-000001'],
      'retirementEligible': true,
      'location': 'Kerala, India',
      'vintage': '2024',
    },
  ];

  final List<Map<String, dynamic>> _retiredCredits = [
    {
      'id': '4',
      'project': 'Tamil Nadu Coastal Project',
      'ngo': 'Tamil Coast Guardians',
      'quantity': 100,
      'retirementDate': '2024-01-30',
      'certificateId': 'RC-2024-001',
      'reason': 'Corporate Net Zero Commitment',
      'location': 'Tamil Nadu, India',
      'vintage': '2023',
    },
    {
      'id': '5',
      'project': 'Goa Mangrove Conservation',
      'ngo': 'Goa Green Initiative',
      'quantity': 30,
      'retirementDate': '2024-02-15',
      'certificateId': 'RC-2024-002',
      'reason': 'Event Carbon Offsetting',
      'location': 'Goa, India',
      'vintage': '2023',
    },
  ];

  final Map<String, dynamic> _portfolioStats = {
    'totalOwned': 90,
    'totalRetired': 130,
    'totalInvestment': 1770.0,
    'currentValue': 1970.0,
    'carbonFootprintOffset': 220.0,
    'totalROI': 11.3,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _retireCredits(Map<String, dynamic> credit) {
    showDialog(
      context: context,
      builder: (context) => _RetirementDialog(credit: credit),
    );
  }

  void _transferCredits(Map<String, dynamic> credit) {
    showDialog(
      context: context,
      builder: (context) => _TransferDialog(credit: credit),
    );
  }

  void _downloadCertificate(Map<String, dynamic> credit) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading retirement certificate ${credit['certificateId']}...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Portfolio Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Active Credits',
                          '${_portfolioStats['totalOwned']} tCO2e',
                          Icons.eco,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Retired Credits',
                          '${_portfolioStats['totalRetired']} tCO2e',
                          Icons.check_circle,
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Investment',
                          '\$${_portfolioStats['totalInvestment'].toStringAsFixed(0)}',
                          Icons.trending_up,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Current Value',
                          '\$${_portfolioStats['currentValue'].toStringAsFixed(0)}',
                          Icons.account_balance,
                          Colors.purple,
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
                  Row(
                    children: [
                      const Icon(Icons.analytics, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Impact Metrics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.nature, color: Colors.green, size: 32),
                            const SizedBox(width: 12),
                            Column(
                              children: [
                                Text(
                                  '${_portfolioStats['carbonFootprintOffset']} tCO2e',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const Text('Total Carbon Offset'),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Your contributions have helped restore coastal ecosystems, '
                          'protect biodiversity, and support local communities.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '+${_portfolioStats['totalROI']}%',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const Text('Portfolio ROI'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Column(
                            children: [
                              Text(
                                '5',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              Text('Projects Supported'),
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
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.go('/marketplace'),
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text('Buy More'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _tabController.animateTo(1),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Retire Credits'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCreditsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _ownedCredits.length,
      itemBuilder: (context, index) {
        final credit = _ownedCredits[index];
        final gainLoss = (credit['currentPrice'] - credit['purchasePrice']) * credit['quantity'];
        final gainLossPercent = ((credit['currentPrice'] - credit['purchasePrice']) / credit['purchasePrice']) * 100;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            credit['project'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            credit['ngo'],
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            credit['location'],
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${credit['quantity']} tCO2e',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Purchased: ${credit['purchaseDate']}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: gainLoss >= 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Purchase Price: \$${credit['purchasePrice']}'),
                            Text('Current Price: \$${credit['currentPrice']}'),
                            Text(
                              'P&L: ${gainLoss >= 0 ? '+' : ''}\$${gainLoss.toStringAsFixed(2)} (${gainLossPercent >= 0 ? '+' : ''}${gainLossPercent.toStringAsFixed(1)}%)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: gainLoss >= 0 ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _transferCredits(credit),
                        icon: const Icon(Icons.swap_horiz),
                        label: const Text('Transfer'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: credit['retirementEligible'] ? () => _retireCredits(credit) : null,
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Retire'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRetiredCreditsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _retiredCredits.length,
      itemBuilder: (context, index) {
        final credit = _retiredCredits[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            credit['project'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            credit['ngo'],
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${credit['quantity']} tCO2e',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Retired: ${credit['retirementDate']}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Certificate ID: ${credit['certificateId']}'),
                      Text('Reason: ${credit['reason']}'),
                      Text('Location: ${credit['location']}'),
                      Text('Vintage: ${credit['vintage']}'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _downloadCertificate(credit),
                    icon: const Icon(Icons.download),
                    label: const Text('Download Certificate'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carbon Credit Portfolio'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/buyer-dashboard'),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Active', icon: Icon(Icons.eco)),
            Tab(text: 'Retired', icon: Icon(Icons.check_circle)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildActiveCreditsTab(),
          _buildRetiredCreditsTab(),
        ],
      ),
    );
  }
}

class _RetirementDialog extends StatefulWidget {
  final Map<String, dynamic> credit;

  const _RetirementDialog({required this.credit});

  @override
  State<_RetirementDialog> createState() => _RetirementDialogState();
}

class _RetirementDialogState extends State<_RetirementDialog> {
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _quantityController.text = widget.credit['quantity'].toString();
  }

  Future<void> _processRetirement() async {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    if (quantity <= 0 || quantity > widget.credit['quantity']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid quantity'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a retirement reason'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Simulate blockchain transaction
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isProcessing = false;
    });

    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirement Successful!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Project: ${widget.credit['project']}'),
            Text('Quantity Retired: $quantity tCO2e'),
            Text('Certificate ID: RC-${DateTime.now().millisecondsSinceEpoch}'),
            const SizedBox(height: 8),
            const Text('Your retirement certificate is being generated and will be available for download shortly.'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Retire Credits - ${widget.credit['project']}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Available: ${widget.credit['quantity']} tCO2e'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity to Retire (tCO2e)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Retirement Reason',
                hintText: 'e.g., Corporate Net Zero Commitment, Event Offsetting',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Important:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Retired credits cannot be transferred or sold. '
                    'This action is permanent and will generate a retirement certificate.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isProcessing ? null : _processRetirement,
          child: _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Retire'),
        ),
      ],
    );
  }
}

class _TransferDialog extends StatefulWidget {
  final Map<String, dynamic> credit;

  const _TransferDialog({required this.credit});

  @override
  State<_TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends State<_TransferDialog> {
  final _quantityController = TextEditingController();
  final _recipientController = TextEditingController();
  bool _isProcessing = false;

  Future<void> _processTransfer() async {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    if (quantity <= 0 || quantity > widget.credit['quantity']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid quantity'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_recipientController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter recipient wallet address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Simulate blockchain transaction
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isProcessing = false;
    });

    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transfer Successful!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Project: ${widget.credit['project']}'),
            Text('Quantity Transferred: $quantity tCO2e'),
            Text('To: ${_recipientController.text}'),
            const SizedBox(height: 8),
            const Text('The credits have been transferred successfully.'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Transfer Credits - ${widget.credit['project']}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Available: ${widget.credit['quantity']} tCO2e'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity to Transfer (tCO2e)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _recipientController,
              decoration: const InputDecoration(
                labelText: 'Recipient Wallet Address',
                hintText: '0x...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isProcessing ? null : _processTransfer,
          child: _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Transfer'),
        ),
      ],
    );
  }
}