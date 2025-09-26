class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String ngoDashboard = '/ngo';
  static const String adminDashboard = '/admin';
  static const String buyerDashboard = '/buyer';

  // NGO Routes
  static const String ngoProjectForm = '/ngo/project/new';
  static const String ngoProjectDetails = '/ngo/project/:id';
  static const String ngoAnalytics = '/ngo/analytics';

  // Admin Routes
  static const String adminReviews = '/admin/reviews';
  static const String adminProjectReview = '/admin/review/:id';
  static const String adminAnalytics = '/admin/analytics';

  // Buyer Routes
  static const String buyerMarketplace = '/buyer/marketplace';
  static const String buyerPortfolio = '/buyer/portfolio';
  static const String buyerPurchase = '/buyer/purchase/:id';

  // Shared Routes
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String transparencyMap = '/map';
}