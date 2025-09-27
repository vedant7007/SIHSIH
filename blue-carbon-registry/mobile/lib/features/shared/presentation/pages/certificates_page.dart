import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Certificate Models
class CarbonCertificate {
  final String id;
  final String certificateNumber;
  final String projectName;
  final String ngoName;
  final String buyerName;
  final double creditsAmount;
  final DateTime issuanceDate;
  final DateTime validUntil;
  final String certificateType; // 'issuance', 'retirement', 'transfer'
  final String status; // 'active', 'retired', 'transferred', 'expired'
  final String blockchainHash;
  final String ipfsHash; // For storing certificate metadata
  final Map<String, dynamic> metadata;
  final String verificationMethod;
  final List<String> signatures; // Digital signatures
  final String location;
  final double carbonReduction;
  final String methodologyUsed;
  final String vintageYear;

  CarbonCertificate({
    required this.id,
    required this.certificateNumber,
    required this.projectName,
    required this.ngoName,
    required this.buyerName,
    required this.creditsAmount,
    required this.issuanceDate,
    required this.validUntil,
    required this.certificateType,
    required this.status,
    required this.blockchainHash,
    required this.ipfsHash,
    required this.metadata,
    required this.verificationMethod,
    required this.signatures,
    required this.location,
    required this.carbonReduction,
    required this.methodologyUsed,
    required this.vintageYear,
  });
}

class BlockchainTransaction {
  final String txHash;
  final DateTime timestamp;
  final String fromAddress;
  final String toAddress;
  final String action; // 'mint', 'transfer', 'retire'
  final double amount;
  final String status; // 'pending', 'confirmed', 'failed'
  final int blockNumber;
  final double gasFee;

  BlockchainTransaction({
    required this.txHash,
    required this.timestamp,
    required this.fromAddress,
    required this.toAddress,
    required this.action,
    required this.amount,
    required this.status,
    required this.blockNumber,
    required this.gasFee,
  });
}

// Providers
final certificatesProvider = StateNotifierProvider<CertificatesNotifier, AsyncValue<List<CarbonCertificate>>>((ref) {
  return CertificatesNotifier();
});

final blockchainTransactionsProvider = StateNotifierProvider<BlockchainNotifier, AsyncValue<List<BlockchainTransaction>>>((ref) {
  return BlockchainNotifier();
});

class CertificatesNotifier extends StateNotifier<AsyncValue<List<CarbonCertificate>>> {
  CertificatesNotifier() : super(const AsyncValue.loading()) {
    loadCertificates();
  }

  Future<void> loadCertificates() async {
    try {
      state = const AsyncValue.loading();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      final certificates = [
        CarbonCertificate(
          id: 'cert_001',
          certificateNumber: 'BCR-2024-MNG-001-500',
          projectName: 'Coastal Mangrove Restoration Project',
          ngoName: 'Green Coast Foundation',
          buyerName: 'EcoTech Solutions Pvt Ltd',
          creditsAmount: 500.0,
          issuanceDate: DateTime.now().subtract(const Duration(days: 30)),
          validUntil: DateTime.now().add(const Duration(days: 3650)), // 10 years
          certificateType: 'issuance',
          status: 'active',
          blockchainHash: '0x1a2b3c4d5e6f7890abcdef1234567890abcdef12',
          ipfsHash: 'QmPK1s3pNYLi9ERiq3BDxKa4XosgWwFRQUydHUtz4YgpqB',
          metadata: {
            'projectId': 'proj_001',
            'verifier': 'Bureau Veritas',
            'standard': 'Verra VCS',
            'serialNumber': 'VCS-2024-001',
            'vintage': '2024',
          },
          verificationMethod: 'Gold Standard + Verra VCS',
          signatures: [
            'admin:0x9876543210abcdef',
            'verifier:0xfedcba0987654321',
            'ngo:0x1357924680acbdef'
          ],
          location: 'Sundarbans, West Bengal, India',
          carbonReduction: 500.0,
          methodologyUsed: 'VM0007 - REDD+ Methodology Framework',
          vintageYear: '2024',
        ),
        CarbonCertificate(
          id: 'cert_002',
          certificateNumber: 'BCR-2024-MNG-002-750',
          projectName: 'Kerala Backwater Conservation',
          ngoName: 'Backwater Conservation Society',
          buyerName: 'GreenTech Solutions Pvt Ltd',
          creditsAmount: 750.0,
          issuanceDate: DateTime.now().subtract(const Duration(days: 45)),
          validUntil: DateTime.now().add(const Duration(days: 3650)),
          certificateType: 'retirement',
          status: 'retired',
          blockchainHash: '0x2b3c4d5e6f7890ab1234567890abcdef1234567',
          ipfsHash: 'QmNK2t4qOZMj8FRnq4CExLb5YpthXxFRVWydIVuz5ZhqrC',
          metadata: {
            'projectId': 'proj_002',
            'verifier': 'SGS',
            'standard': 'Plan Vivo',
            'serialNumber': 'PV-2024-002',
            'vintage': '2024',
            'retirementReason': 'Corporate Carbon Neutrality Goal',
          },
          verificationMethod: 'Plan Vivo Standard',
          signatures: [
            'admin:0x9876543210abcdef',
            'verifier:0xfedcba0987654321',
            'buyer:0x2468ace013579bdf'
          ],
          location: 'Kumarakom, Kerala, India',
          carbonReduction: 750.0,
          methodologyUsed: 'PV-GHG-01 - Mangrove Restoration',
          vintageYear: '2024',
        ),
        CarbonCertificate(
          id: 'cert_003',
          certificateNumber: 'BCR-2024-MNG-003-300',
          projectName: 'Tamil Nadu Coastal Protection',
          ngoName: 'Tamil Coast Guardians',
          buyerName: 'CleanEnergy Corp',
          creditsAmount: 300.0,
          issuanceDate: DateTime.now().subtract(const Duration(days: 15)),
          validUntil: DateTime.now().add(const Duration(days: 3650)),
          certificateType: 'transfer',
          status: 'active',
          blockchainHash: '0x3c4d5e6f7890ab1234567890abcdef123456789a',
          ipfsHash: 'QmOL3u5rQaMk9GSoq5DFyMc6ZqujYxGSXXydJWvz6AirSD',
          metadata: {
            'projectId': 'proj_003',
            'verifier': 'TUV SUD',
            'standard': 'Gold Standard',
            'serialNumber': 'GS-2024-003',
            'vintage': '2024',
            'transferHistory': ['EcoTech Solutions', 'CleanEnergy Corp'],
          },
          verificationMethod: 'Gold Standard Methodology',
          signatures: [
            'admin:0x9876543210abcdef',
            'verifier:0xfedcba0987654321',
            'from:0x1357924680acbdef',
            'to:0x2468ace013579bdf'
          ],
          location: 'Pichavaram, Tamil Nadu, India',
          carbonReduction: 300.0,
          methodologyUsed: 'GS-AFOLU-01 - Coastal Wetland Restoration',
          vintageYear: '2024',
        ),
      ];

      state = AsyncValue.data(certificates);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshCertificates() async {
    await loadCertificates();
  }
}

class BlockchainNotifier extends StateNotifier<AsyncValue<List<BlockchainTransaction>>> {
  BlockchainNotifier() : super(const AsyncValue.loading()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    try {
      state = const AsyncValue.loading();

      await Future.delayed(const Duration(seconds: 1));

      final transactions = [
        BlockchainTransaction(
          txHash: '0x1a2b3c4d5e6f7890abcdef1234567890abcdef12345',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          fromAddress: '0x0000000000000000000000000000000000000000',
          toAddress: '0x1357924680acbdef9876543210fedcba09876543',
          action: 'mint',
          amount: 500.0,
          status: 'confirmed',
          blockNumber: 18456789,
          gasFee: 0.025,
        ),
        BlockchainTransaction(
          txHash: '0x2b3c4d5e6f7890ab1234567890abcdef1234567890',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          fromAddress: '0x1357924680acbdef9876543210fedcba09876543',
          toAddress: '0x2468ace013579bdf1357924680acbdef987654',
          action: 'transfer',
          amount: 250.0,
          status: 'confirmed',
          blockNumber: 18456788,
          gasFee: 0.018,
        ),
        BlockchainTransaction(
          txHash: '0x3c4d5e6f7890ab1234567890abcdef123456789abc',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          fromAddress: '0x2468ace013579bdf1357924680acbdef987654',
          toAddress: '0x0000000000000000000000000000000000000001',
          action: 'retire',
          amount: 100.0,
          status: 'confirmed',
          blockNumber: 18456787,
          gasFee: 0.012,
        ),
      ];

      state = AsyncValue.data(transactions);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class CertificatesPage extends ConsumerStatefulWidget {
  const CertificatesPage({super.key});

  @override
  ConsumerState<CertificatesPage> createState() => _CertificatesPageState();
}

class _CertificatesPageState extends ConsumerState<CertificatesPage> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Certificates & Blockchain'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(certificatesProvider.notifier).refreshCertificates();
              ref.read(blockchainTransactionsProvider.notifier).loadTransactions();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Certificates', icon: Icon(Icons.card_membership)),
            Tab(text: 'Blockchain', icon: Icon(Icons.link)),
            Tab(text: 'Verification', icon: Icon(Icons.verified_user)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCertificatesTab(),
          _buildBlockchainTab(),
          _buildVerificationTab(),
        ],
      ),
    );
  }

  Widget _buildCertificatesTab() {
    final certificatesAsync = ref.watch(certificatesProvider);

    return certificatesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading certificates: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(certificatesProvider.notifier).refreshCertificates(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (certificates) => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Certificates')),
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(value: 'retired', child: Text('Retired')),
                      DropdownMenuItem(value: 'transferred', child: Text('Transferred')),
                    ],
                    onChanged: (value) => setState(() => _selectedFilter = value!),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showIssueCertificateDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Issue New'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: certificates.length,
              itemBuilder: (context, index) {
                final certificate = certificates[index];
                if (_selectedFilter != 'all' && certificate.status != _selectedFilter) {
                  return const SizedBox.shrink();
                }
                return _buildCertificateCard(certificate);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateCard(CarbonCertificate certificate) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getCertificateColor(certificate.status),
              _getCertificateColor(certificate.status).withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getCertificateIcon(certificate.certificateType),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              certificate.certificateNumber,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              certificate.projectName,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusChip(certificate.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoItem(
                                'Credits',
                                '${certificate.creditsAmount.toStringAsFixed(0)} tCO2e',
                                Icons.eco,
                              ),
                            ),
                            Expanded(
                              child: _buildInfoItem(
                                'NGO',
                                certificate.ngoName,
                                Icons.business,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoItem(
                                'Buyer',
                                certificate.buyerName,
                                Icons.person,
                              ),
                            ),
                            Expanded(
                              child: _buildInfoItem(
                                'Location',
                                certificate.location.split(',').first,
                                Icons.location_on,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoItem(
                                'Issued',
                                _formatDate(certificate.issuanceDate),
                                Icons.calendar_today,
                              ),
                            ),
                            Expanded(
                              child: _buildInfoItem(
                                'Valid Until',
                                _formatDate(certificate.validUntil),
                                Icons.schedule,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showCertificateDetails(certificate),
                          icon: const Icon(Icons.visibility, color: Colors.white),
                          label: const Text('View Details', style: TextStyle(color: Colors.white)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _downloadCertificate(certificate),
                          icon: const Icon(Icons.download),
                          label: const Text('Download'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: _getCertificateColor(certificate.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockchainTab() {
    final transactionsAsync = ref.watch(blockchainTransactionsProvider);

    return transactionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (transactions) => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.link, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'Blockchain Network Status',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildNetworkStatItem('Network', 'Polygon Mumbai', Colors.purple),
                        ),
                        Expanded(
                          child: _buildNetworkStatItem('Block Height', '18,456,789', Colors.blue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildNetworkStatItem('Gas Price', '25 Gwei', Colors.orange),
                        ),
                        Expanded(
                          child: _buildNetworkStatItem('Status', 'Connected', Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return _buildTransactionCard(transaction);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationTab() {
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
                      const Icon(Icons.verified_user, color: Colors.green),
                      const SizedBox(width: 8),
                      const Text(
                        'Verification Methods',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildVerificationMethod(
                    'Gold Standard',
                    'International best practice for climate and development projects',
                    'gold_standard_logo.png',
                    true,
                  ),
                  _buildVerificationMethod(
                    'Verra VCS',
                    'Verified Carbon Standard for greenhouse gas reduction projects',
                    'verra_logo.png',
                    true,
                  ),
                  _buildVerificationMethod(
                    'Plan Vivo',
                    'Community-led payment for ecosystem services programmes',
                    'plan_vivo_logo.png',
                    true,
                  ),
                  _buildVerificationMethod(
                    'UN Clean Development Mechanism',
                    'United Nations framework for emission reduction projects',
                    'un_cdm_logo.png',
                    false,
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
                      const Icon(Icons.security, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Blockchain Security',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSecurityFeature(
                    'Immutable Records',
                    'All certificates are stored on blockchain for permanent record keeping',
                    Icons.lock,
                    Colors.green,
                  ),
                  _buildSecurityFeature(
                    'Digital Signatures',
                    'Multi-party digital signatures ensure authenticity',
                    Icons.edit_note,
                    Colors.blue,
                  ),
                  _buildSecurityFeature(
                    'IPFS Storage',
                    'Decentralized storage for certificate metadata and documents',
                    Icons.cloud,
                    Colors.purple,
                  ),
                  _buildSecurityFeature(
                    'Smart Contracts',
                    'Automated certificate lifecycle management through smart contracts',
                    Icons.smart_toy,
                    Colors.orange,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'active':
        color = Colors.green;
        text = 'Active';
        break;
      case 'retired':
        color = Colors.grey;
        text = 'Retired';
        break;
      case 'transferred':
        color = Colors.blue;
        text = 'Transferred';
        break;
      case 'expired':
        color = Colors.red;
        text = 'Expired';
        break;
      default:
        color = Colors.grey;
        text = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(BlockchainTransaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTransactionColor(transaction.action).withOpacity(0.1),
          child: Icon(
            _getTransactionIcon(transaction.action),
            color: _getTransactionColor(transaction.action),
          ),
        ),
        title: Text(
          'Tx: ${transaction.txHash.substring(0, 10)}...',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${transaction.action.toUpperCase()} ${transaction.amount} tCO2e'),
            Text(
              _formatTimestamp(transaction.timestamp),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTransactionStatusChip(transaction.status),
            const SizedBox(height: 4),
            Text(
              '${transaction.gasFee} ETH',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  Widget _buildNetworkStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationMethod(String name, String description, String logoPath, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isActive ? Colors.green : Colors.grey.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isActive ? Colors.green.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isActive ? Icons.verified : Icons.help_outline,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.green : Colors.grey,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (isActive)
            const Icon(Icons.check_circle, color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildSecurityFeature(String title, String description, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionStatusChip(String status) {
    Color color;
    switch (status) {
      case 'confirmed':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'failed':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getCertificateColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'retired':
        return Colors.blue;
      case 'transferred':
        return Colors.purple;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getCertificateIcon(String type) {
    switch (type) {
      case 'issuance':
        return Icons.card_membership;
      case 'retirement':
        return Icons.delete_forever;
      case 'transfer':
        return Icons.swap_horiz;
      default:
        return Icons.description;
    }
  }

  Color _getTransactionColor(String action) {
    switch (action) {
      case 'mint':
        return Colors.green;
      case 'transfer':
        return Colors.blue;
      case 'retire':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTransactionIcon(String action) {
    switch (action) {
      case 'mint':
        return Icons.add_circle;
      case 'transfer':
        return Icons.swap_horiz;
      case 'retire':
        return Icons.delete_forever;
      default:
        return Icons.receipt;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showCertificateDetails(CarbonCertificate certificate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Certificate Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Certificate Number', certificate.certificateNumber),
              _buildDetailRow('Project', certificate.projectName),
              _buildDetailRow('NGO', certificate.ngoName),
              _buildDetailRow('Buyer', certificate.buyerName),
              _buildDetailRow('Credits', '${certificate.creditsAmount} tCO2e'),
              _buildDetailRow('Location', certificate.location),
              _buildDetailRow('Methodology', certificate.methodologyUsed),
              _buildDetailRow('Vintage', certificate.vintageYear),
              _buildDetailRow('Blockchain Hash', certificate.blockchainHash),
              _buildDetailRow('IPFS Hash', certificate.ipfsHash),
              _buildDetailRow('Verification', certificate.verificationMethod),
              _buildDetailRow('Status', certificate.status.toUpperCase()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetails(BlockchainTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transaction Details'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Hash', transaction.txHash),
            _buildDetailRow('Action', transaction.action.toUpperCase()),
            _buildDetailRow('Amount', '${transaction.amount} tCO2e'),
            _buildDetailRow('From', transaction.fromAddress),
            _buildDetailRow('To', transaction.toAddress),
            _buildDetailRow('Status', transaction.status.toUpperCase()),
            _buildDetailRow('Block', '${transaction.blockNumber}'),
            _buildDetailRow('Gas Fee', '${transaction.gasFee} ETH'),
            _buildDetailRow('Time', _formatTimestamp(transaction.timestamp)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Open blockchain explorer
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening blockchain explorer...')),
              );
            },
            child: const Text('View on Explorer'),
          ),
        ],
      ),
    );
  }

  void _downloadCertificate(CarbonCertificate certificate) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading certificate ${certificate.certificateNumber}...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showIssueCertificateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Issue New Certificate'),
        content: const Text('Certificate issuance feature will be available for verified projects.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Certificate issuance initiated...')),
              );
            },
            child: const Text('Proceed'),
          ),
        ],
      ),
    );
  }
}