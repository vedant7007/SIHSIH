import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Data Models
class CarbonCredit {
  final String id;
  final String projectName;
  final String ngoName;
  final String location;
  final int availableCredits;
  final double pricePerCredit;
  final double multiplierRate; // e.g., 1.5 means 1.5x price for buyers
  final String rating;
  final bool isVerified;
  final int sustainabilityScore;
  final String impactStory;
  final List<String> certifications;
  final String vintage;
  final String methodology;
  final List<String> cobenefits;
  final String coordinates;
  final String projectType;
  final DateTime expiryDate;
  final Map<String, dynamic> projectDetails;

  CarbonCredit({
    required this.id,
    required this.projectName,
    required this.ngoName,
    required this.location,
    required this.availableCredits,
    required this.pricePerCredit,
    this.multiplierRate = 1.5, // Default 1.5x multiplier
    required this.rating,
    required this.isVerified,
    required this.sustainabilityScore,
    required this.impactStory,
    required this.certifications,
    required this.vintage,
    required this.methodology,
    required this.cobenefits,
    required this.coordinates,
    required this.projectType,
    required this.expiryDate,
    required this.projectDetails,
  });

  double get buyerPrice => pricePerCredit * multiplierRate;
}

class BuyerProfile {
  final String id;
  final String name;
  final String companyName;
  final int creditLimit; // Monthly credit purchase limit
  final int currentMonthPurchases;
  final double budgetLimit; // Monthly budget limit in INR
  final double currentMonthSpending;
  final String verificationLevel; // 'basic', 'verified', 'premium'

  BuyerProfile({
    required this.id,
    required this.name,
    required this.companyName,
    required this.creditLimit,
    this.currentMonthPurchases = 0,
    required this.budgetLimit,
    this.currentMonthSpending = 0.0,
    this.verificationLevel = 'basic',
  });

  bool canPurchase(int quantity, double totalPrice) {
    return (currentMonthPurchases + quantity <= creditLimit) &&
           (currentMonthSpending + totalPrice <= budgetLimit);
  }

  int get remainingCredits => creditLimit - currentMonthPurchases;
  double get remainingBudget => budgetLimit - currentMonthSpending;
}

class PurchaseOrder {
  final String id;
  final String creditId;
  final int quantity;
  final double totalPrice;
  final DateTime orderDate;
  final String status;
  final String buyerId;

  PurchaseOrder({
    required this.id,
    required this.creditId,
    required this.quantity,
    required this.totalPrice,
    required this.orderDate,
    required this.status,
    required this.buyerId,
  });
}

// Filters and Sorting
enum SortBy { priceAsc, priceDesc, ratingDesc, sustainabilityDesc, dateDesc }
enum ProjectType { all, mangrove, seagrass, coastal, saltmarsh }
enum CertificationType { all, goldStandard, verra, plan }

class MarketplaceFilters {
  final ProjectType projectType;
  final CertificationType certification;
  final RangeValues priceRange;
  final RangeValues sustainabilityRange;
  final String location;
  final SortBy sortBy;
  final bool verifiedOnly;

  MarketplaceFilters({
    this.projectType = ProjectType.all,
    this.certification = CertificationType.all,
    this.priceRange = const RangeValues(0, 50),
    this.sustainabilityRange = const RangeValues(80, 100),
    this.location = '',
    this.sortBy = SortBy.ratingDesc,
    this.verifiedOnly = true,
  });

  MarketplaceFilters copyWith({
    ProjectType? projectType,
    CertificationType? certification,
    RangeValues? priceRange,
    RangeValues? sustainabilityRange,
    String? location,
    SortBy? sortBy,
    bool? verifiedOnly,
  }) {
    return MarketplaceFilters(
      projectType: projectType ?? this.projectType,
      certification: certification ?? this.certification,
      priceRange: priceRange ?? this.priceRange,
      sustainabilityRange: sustainabilityRange ?? this.sustainabilityRange,
      location: location ?? this.location,
      sortBy: sortBy ?? this.sortBy,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
    );
  }
}

// Providers
final marketplaceFiltersProvider = StateNotifierProvider<MarketplaceFiltersNotifier, MarketplaceFilters>((ref) {
  return MarketplaceFiltersNotifier();
});

final carbonCreditsProvider = StateNotifierProvider<CarbonCreditsNotifier, AsyncValue<List<CarbonCredit>>>((ref) {
  return CarbonCreditsNotifier(ref);
});

final buyerProfileProvider = StateProvider<BuyerProfile>((ref) {
  // Demo buyer profile
  return BuyerProfile(
    id: 'buyer_001',
    name: 'Rajesh Kumar',
    companyName: 'GreenTech Solutions Pvt Ltd',
    creditLimit: 1000,
    currentMonthPurchases: 150,
    budgetLimit: 500000.0, // ₹5,00,000 monthly limit
    currentMonthSpending: 75000.0, // ₹75,000 spent this month
    verificationLevel: 'verified',
  );
});

class MarketplaceFiltersNotifier extends StateNotifier<MarketplaceFilters> {
  MarketplaceFiltersNotifier() : super(MarketplaceFilters());

  void updateProjectType(ProjectType type) {
    state = state.copyWith(projectType: type);
  }

  void updateCertification(CertificationType cert) {
    state = state.copyWith(certification: cert);
  }

  void updatePriceRange(RangeValues range) {
    state = state.copyWith(priceRange: range);
  }

  void updateSustainabilityRange(RangeValues range) {
    state = state.copyWith(sustainabilityRange: range);
  }

  void updateLocation(String location) {
    state = state.copyWith(location: location);
  }

  void updateSortBy(SortBy sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void updateVerifiedOnly(bool verifiedOnly) {
    state = state.copyWith(verifiedOnly: verifiedOnly);
  }

  void resetFilters() {
    state = MarketplaceFilters();
  }
}

class CarbonCreditsNotifier extends StateNotifier<AsyncValue<List<CarbonCredit>>> {
  final StateNotifierProviderRef ref;

  CarbonCreditsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadCredits();
  }

  Future<void> loadCredits() async {
    try {
      state = const AsyncValue.loading();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      final credits = _generateMockCredits();
      state = AsyncValue.data(credits);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  List<CarbonCredit> _generateMockCredits() {
    return [
      CarbonCredit(
        id: '1',
        projectName: 'Sundarbans Mangrove Restoration',
        ngoName: 'Green Coast Foundation',
        location: 'West Bengal, India',
        availableCredits: 500,
        pricePerCredit: 15.0,
        multiplierRate: 1.6, // Premium multiplier for high-quality project
        rating: 'A+',
        isVerified: true,
        sustainabilityScore: 95,
        impactStory: 'Protecting 50 hectares of critical mangrove ecosystem while supporting 200 local families',
        certifications: ['Gold Standard', 'Verra VCS'],
        vintage: '2024',
        methodology: 'Blue Carbon',
        cobenefits: ['Biodiversity Protection', 'Coastal Defense', 'Livelihood Support'],
        coordinates: '22.3511°N, 87.9085°E',
        projectType: 'Mangrove Restoration',
        expiryDate: DateTime.now().add(const Duration(days: 365)),
        projectDetails: {
          'area': '50 hectares',
          'species': 'Rhizophora mucronata, Avicennia marina',
          'carbonSequestration': '10 tCO2e/hectare/year',
          'monitoringFrequency': 'Quarterly',
        },
      ),
      CarbonCredit(
        id: '2',
        projectName: 'Kerala Backwater Seagrass Conservation',
        ngoName: 'Marine Life Protection Society',
        location: 'Kerala, India',
        availableCredits: 750,
        pricePerCredit: 18.0,
        rating: 'A',
        isVerified: true,
        sustainabilityScore: 92,
        impactStory: 'Restoring vital seagrass beds that serve as nurseries for marine life',
        certifications: ['Gold Standard'],
        vintage: '2024',
        methodology: 'Blue Carbon',
        cobenefits: ['Marine Biodiversity', 'Fisheries Support', 'Water Quality'],
        coordinates: '9.9312°N, 76.2673°E',
        projectType: 'Seagrass Restoration',
        expiryDate: DateTime.now().add(const Duration(days: 300)),
        projectDetails: {
          'area': '75 hectares',
          'species': 'Zostera marina, Halophila ovalis',
          'carbonSequestration': '8 tCO2e/hectare/year',
          'monitoringFrequency': 'Monthly',
        },
      ),
      CarbonCredit(
        id: '3',
        projectName: 'Tamil Nadu Coastal Protection',
        ngoName: 'Coastal Conservation Network',
        location: 'Tamil Nadu, India',
        availableCredits: 300,
        pricePerCredit: 12.0,
        rating: 'A-',
        isVerified: true,
        sustainabilityScore: 88,
        impactStory: 'Multi-species coastal restoration providing storm protection for vulnerable communities',
        certifications: ['Verra VCS'],
        vintage: '2024',
        methodology: 'Blue Carbon',
        cobenefits: ['Storm Protection', 'Community Resilience', 'Tourism'],
        coordinates: '11.1271°N, 78.6569°E',
        projectType: 'Coastal Restoration',
        expiryDate: DateTime.now().add(const Duration(days: 400)),
        projectDetails: {
          'area': '30 hectares',
          'species': 'Mixed coastal vegetation',
          'carbonSequestration': '12 tCO2e/hectare/year',
          'monitoringFrequency': 'Bi-monthly',
        },
      ),
      CarbonCredit(
        id: '4',
        projectName: 'Gujarat Salt Marsh Rehabilitation',
        ngoName: 'Arid Land Conservation Trust',
        location: 'Gujarat, India',
        availableCredits: 450,
        pricePerCredit: 14.0,
        rating: 'A',
        isVerified: true,
        sustainabilityScore: 90,
        impactStory: 'Rehabilitating degraded salt marshes to enhance carbon storage and bird habitat',
        certifications: ['Gold Standard', 'Plan Vivo'],
        vintage: '2024',
        methodology: 'Blue Carbon',
        cobenefits: ['Bird Habitat', 'Salt Production', 'Research'],
        coordinates: '22.3039°N, 68.9885°E',
        projectType: 'Salt Marsh',
        expiryDate: DateTime.now().add(const Duration(days: 350)),
        projectDetails: {
          'area': '45 hectares',
          'species': 'Salicornia, Suaeda species',
          'carbonSequestration': '6 tCO2e/hectare/year',
          'monitoringFrequency': 'Quarterly',
        },
      ),
    ];
  }

  List<CarbonCredit> getFilteredCredits(MarketplaceFilters filters) {
    final credits = state.asData?.value ?? [];

    var filteredCredits = credits.where((credit) {
      // Project type filter
      if (filters.projectType != ProjectType.all) {
        final typeMatch = {
          ProjectType.mangrove: credit.projectType.toLowerCase().contains('mangrove'),
          ProjectType.seagrass: credit.projectType.toLowerCase().contains('seagrass'),
          ProjectType.coastal: credit.projectType.toLowerCase().contains('coastal'),
          ProjectType.saltmarsh: credit.projectType.toLowerCase().contains('salt'),
        };
        if (!(typeMatch[filters.projectType] ?? false)) return false;
      }

      // Verification filter
      if (filters.verifiedOnly && !credit.isVerified) return false;

      // Price range filter
      if (credit.pricePerCredit < filters.priceRange.start ||
          credit.pricePerCredit > filters.priceRange.end) return false;

      // Sustainability score filter
      if (credit.sustainabilityScore < filters.sustainabilityRange.start ||
          credit.sustainabilityScore > filters.sustainabilityRange.end) return false;

      // Location filter
      if (filters.location.isNotEmpty &&
          !credit.location.toLowerCase().contains(filters.location.toLowerCase())) return false;

      // Certification filter
      if (filters.certification != CertificationType.all) {
        final certMatch = {
          CertificationType.goldStandard: credit.certifications.any((cert) => cert.toLowerCase().contains('gold')),
          CertificationType.verra: credit.certifications.any((cert) => cert.toLowerCase().contains('verra')),
          CertificationType.plan: credit.certifications.any((cert) => cert.toLowerCase().contains('plan')),
        };
        if (!(certMatch[filters.certification] ?? false)) return false;
      }

      return true;
    }).toList();

    // Sort credits
    switch (filters.sortBy) {
      case SortBy.priceAsc:
        filteredCredits.sort((a, b) => a.pricePerCredit.compareTo(b.pricePerCredit));
        break;
      case SortBy.priceDesc:
        filteredCredits.sort((a, b) => b.pricePerCredit.compareTo(a.pricePerCredit));
        break;
      case SortBy.ratingDesc:
        filteredCredits.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortBy.sustainabilityDesc:
        filteredCredits.sort((a, b) => b.sustainabilityScore.compareTo(a.sustainabilityScore));
        break;
      case SortBy.dateDesc:
        filteredCredits.sort((a, b) => b.expiryDate.compareTo(a.expiryDate));
        break;
    }

    return filteredCredits;
  }
}

class MarketplacePage extends ConsumerStatefulWidget {
  const MarketplacePage({super.key});

  @override
  ConsumerState<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends ConsumerState<MarketplacePage> with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carbon Credit Marketplace'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/buyer-dashboard'),
        ),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => _showCart(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Browse Credits', icon: Icon(Icons.store)),
            Tab(text: 'My Purchases', icon: Icon(Icons.receipt_long)),
            Tab(text: 'Portfolio', icon: Icon(Icons.pie_chart)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          if (_showFilters) _buildAdvancedFilters(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBrowseCreditsTab(),
                _buildMyPurchasesTab(),
                _buildPortfolioTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search projects, locations, NGOs...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              _buildQuickSortButton(),
            ],
          ),
          const SizedBox(height: 12),
          _buildQuickFilters(),
        ],
      ),
    );
  }

  Widget _buildQuickSortButton() {
    final filters = ref.watch(marketplaceFiltersProvider);
    return PopupMenuButton<SortBy>(
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.sort, color: Colors.white),
      ),
      onSelected: (sortBy) {
        ref.read(marketplaceFiltersProvider.notifier).updateSortBy(sortBy);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: SortBy.ratingDesc,
          child: Row(
            children: [
              Icon(Icons.star),
              SizedBox(width: 8),
              Text('Highest Rated'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: SortBy.priceAsc,
          child: Row(
            children: [
              Icon(Icons.arrow_upward),
              SizedBox(width: 8),
              Text('Price: Low to High'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: SortBy.priceDesc,
          child: Row(
            children: [
              Icon(Icons.arrow_downward),
              SizedBox(width: 8),
              Text('Price: High to Low'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: SortBy.sustainabilityDesc,
          child: Row(
            children: [
              Icon(Icons.eco),
              SizedBox(width: 8),
              Text('Sustainability Score'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickFilters() {
    final filters = ref.watch(marketplaceFiltersProvider);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            'Verified Only',
            filters.verifiedOnly,
            Icons.verified,
            () => ref.read(marketplaceFiltersProvider.notifier).updateVerifiedOnly(!filters.verifiedOnly),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Mangroves',
            filters.projectType == ProjectType.mangrove,
            Icons.nature,
            () => ref.read(marketplaceFiltersProvider.notifier).updateProjectType(
              filters.projectType == ProjectType.mangrove ? ProjectType.all : ProjectType.mangrove,
            ),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Seagrass',
            filters.projectType == ProjectType.seagrass,
            Icons.grass,
            () => ref.read(marketplaceFiltersProvider.notifier).updateProjectType(
              filters.projectType == ProjectType.seagrass ? ProjectType.all : ProjectType.seagrass,
            ),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Gold Standard',
            filters.certification == CertificationType.goldStandard,
            Icons.workspace_premium,
            () => ref.read(marketplaceFiltersProvider.notifier).updateCertification(
              filters.certification == CertificationType.goldStandard ? CertificationType.all : CertificationType.goldStandard,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    final filters = ref.watch(marketplaceFiltersProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Advanced Filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => ref.read(marketplaceFiltersProvider.notifier).resetFilters(),
                child: const Text('Reset All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Price Range: ₹${filters.priceRange.start.toInt()} - ₹${filters.priceRange.end.toInt()}'),
          RangeSlider(
            values: RangeValues(
              filters.priceRange.start.clamp(0, 50),
              filters.priceRange.end.clamp(0, 50),
            ),
            min: 0,
            max: 50,
            divisions: 50,
            onChanged: (values) => ref.read(marketplaceFiltersProvider.notifier).updatePriceRange(values),
          ),
          const SizedBox(height: 8),
          Text('Sustainability Score: ${filters.sustainabilityRange.start.toInt()} - ${filters.sustainabilityRange.end.toInt()}'),
          RangeSlider(
            values: RangeValues(
              filters.sustainabilityRange.start.clamp(0, 100),
              filters.sustainabilityRange.end.clamp(0, 100),
            ),
            min: 0,
            max: 100,
            divisions: 100,
            onChanged: (values) => ref.read(marketplaceFiltersProvider.notifier).updateSustainabilityRange(values),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseCreditsTab() {
    final creditsAsync = ref.watch(carbonCreditsProvider);
    final filters = ref.watch(marketplaceFiltersProvider);

    return creditsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading credits: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(carbonCreditsProvider.notifier).loadCredits(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (allCredits) {
        final filteredCredits = ref.read(carbonCreditsProvider.notifier).getFilteredCredits(filters);

        if (filteredCredits.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No credits match your filters'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.read(marketplaceFiltersProvider.notifier).resetFilters(),
                  child: const Text('Clear Filters'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref.read(carbonCreditsProvider.notifier).loadCredits(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredCredits.length,
            itemBuilder: (context, index) {
              final credit = filteredCredits[index];
              return _buildCreditCard(credit);
            },
          ),
        );
      },
    );
  }

  Widget _buildCreditCard(CarbonCredit credit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCreditHeader(credit),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCreditMetrics(credit),
                const SizedBox(height: 12),
                _buildCreditDescription(credit),
                const SizedBox(height: 12),
                _buildCertifications(credit),
                const SizedBox(height: 16),
                _buildCreditActions(credit),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditHeader(CarbonCredit credit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
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
                      credit.projectName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      credit.ngoName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              if (credit.isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, size: 16, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.white70),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  credit.location,
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Rating: ${credit.rating}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreditMetrics(CarbonCredit credit) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricItem(
            'Available',
            '${credit.availableCredits}',
            'credits',
            Icons.eco,
            Colors.green,
          ),
        ),
        Expanded(
          child: _buildMetricItem(
            'Price',
            '₹${credit.buyerPrice.toStringAsFixed(2)}',
            'per credit',
            Icons.attach_money,
            Colors.orange,
          ),
        ),
        Expanded(
          child: _buildMetricItem(
            'Impact Score',
            '${credit.sustainabilityScore}',
            '/ 100',
            Icons.star,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              unit,
              style: TextStyle(fontSize: 9, color: color),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCreditDescription(CarbonCredit credit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Impact Story',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          credit.impactStory,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: credit.cobenefits.map((benefit) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              benefit,
              style: const TextStyle(fontSize: 11, color: Colors.blue),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildCertifications(CarbonCredit credit) {
    return Row(
      children: [
        const Text(
          'Certifications: ',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        ...credit.certifications.map((cert) => Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            cert,
            style: const TextStyle(fontSize: 11, color: Colors.green),
          ),
        )),
      ],
    );
  }

  Widget _buildCreditActions(CarbonCredit credit) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showCreditDetails(credit),
            icon: const Icon(Icons.info),
            label: const Text('Details'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showPurchaseDialog(credit),
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Purchase'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMyPurchasesTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No purchases yet'),
          SizedBox(height: 8),
          Text(
            'Your purchased credits will appear here',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pie_chart, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Portfolio Summary'),
          SizedBox(height: 8),
          Text(
            'Your carbon impact portfolio will be displayed here',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showCreditDetails(CarbonCredit credit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      credit.projectName,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('NGO', credit.ngoName),
              _buildDetailRow('Location', credit.location),
              _buildDetailRow('Coordinates', credit.coordinates),
              _buildDetailRow('Project Type', credit.projectType),
              _buildDetailRow('Methodology', credit.methodology),
              _buildDetailRow('Vintage', credit.vintage),
              _buildDetailRow('Available Credits', '${credit.availableCredits} tCO2e'),
              _buildDetailRow('Price per Credit', '₹${credit.buyerPrice.toStringAsFixed(2)}'),
              _buildDetailRow('NGO Rate', '₹${credit.pricePerCredit.toStringAsFixed(2)}'),
              _buildDetailRow('Multiplier', '${credit.multiplierRate}x'),
              _buildDetailRow('Sustainability Score', '${credit.sustainabilityScore}/100'),
              _buildDetailRow('Expires', _formatDate(credit.expiryDate)),
              const SizedBox(height: 16),
              const Text(
                'Project Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...credit.projectDetails.entries.map((entry) => _buildDetailRow(
                _capitalizeFirst(entry.key),
                entry.value.toString(),
              )),
              const SizedBox(height: 16),
              const Text(
                'Impact Story',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(credit.impactStory),
              const SizedBox(height: 16),
              const Text(
                'Co-benefits',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: credit.cobenefits.map((benefit) => Chip(
                  label: Text(benefit),
                  backgroundColor: Colors.blue.withOpacity(0.1),
                )).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showPurchaseDialog(credit);
                  },
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Purchase Credits'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPurchaseDialog(CarbonCredit credit) {
    showDialog(
      context: context,
      builder: (context) => _PurchaseDialog(credit: credit),
    );
  }

  void _showCart() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Shopping cart feature coming soon...'),
        backgroundColor: Colors.orange,
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
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _PurchaseDialog extends StatefulWidget {
  final CarbonCredit credit;

  const _PurchaseDialog({required this.credit});

  @override
  State<_PurchaseDialog> createState() => _PurchaseDialogState();
}

class _PurchaseDialogState extends State<_PurchaseDialog> {
  final _quantityController = TextEditingController(text: '10');
  bool _isProcessing = false;
  String _selectedPurpose = 'offset';

  int get quantity => int.tryParse(_quantityController.text) ?? 0;
  double get totalPrice => quantity * widget.credit.buyerPrice;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final buyerProfile = ref.watch(buyerProfileProvider);
        final canAfford = buyerProfile.canPurchase(quantity, totalPrice);
        final remainingCredits = buyerProfile.remainingCredits;
        final remainingBudget = buyerProfile.remainingBudget;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Row(
              children: [
                const Text(
                  'Purchase Carbon Credits',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.credit.projectName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(widget.credit.ngoName),
                  Text('Price: ₹${widget.credit.buyerPrice.toStringAsFixed(2)} per credit'),
                  Text('Available: ${widget.credit.availableCredits} credits'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Purchase Purpose'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedPurpose,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'offset', child: Text('Carbon Offsetting')),
                DropdownMenuItem(value: 'investment', child: Text('Investment')),
                DropdownMenuItem(value: 'csr', child: Text('Corporate Social Responsibility')),
                DropdownMenuItem(value: 'compliance', child: Text('Regulatory Compliance')),
              ],
              onChanged: (value) => setState(() => _selectedPurpose = value!),
            ),
            const SizedBox(height: 16),
            const Text('Quantity'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                suffixText: 'credits',
              ),
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 12),
            // Buyer Limits Display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Limits',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Credit Limit:', style: TextStyle(color: Colors.grey[600])),
                      Text('$remainingCredits / ${buyerProfile.creditLimit}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Budget Limit:', style: TextStyle(color: Colors.grey[600])),
                      Text('₹${remainingBudget.toStringAsFixed(0)} / ₹${buyerProfile.budgetLimit.toStringAsFixed(0)}'),
                    ],
                  ),
                  if (!canAfford && quantity > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.red, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              quantity > remainingCredits
                                ? 'Exceeds credit limit'
                                : 'Exceeds budget limit',
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Price',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '₹${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessing || quantity <= 0 || !canAfford ? null : _processPurchase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Purchase'),
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

  Future<void> _processPurchase() async {
    if (quantity <= 0 || quantity > widget.credit.availableCredits) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid quantity'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully purchased $quantity credits for ₹${totalPrice.toStringAsFixed(2)}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Purchase failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }
}