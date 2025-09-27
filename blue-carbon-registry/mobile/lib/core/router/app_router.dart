import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/ngo/presentation/pages/ngo_dashboard.dart';
import '../../features/ngo/presentation/pages/project_submission_page.dart';
import '../../features/ngo/presentation/pages/ngo_analytics_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard.dart';
import '../../features/admin/presentation/pages/admin_analytics_page.dart';
import '../../features/admin/presentation/pages/project_review_page.dart';
import '../../features/buyer/presentation/pages/buyer_dashboard.dart';
import '../../features/buyer/presentation/pages/marketplace_page.dart';
import '../../features/buyer/presentation/pages/portfolio_page.dart';
import '../../features/shared/presentation/pages/home_page.dart';
import '../../features/shared/presentation/pages/notifications_page.dart';
import '../../features/shared/presentation/pages/certificates_page.dart';
import '../constants/app_routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash & Auth Routes
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      // NGO Routes
      GoRoute(
        path: AppRoutes.ngoDashboard,
        name: 'ngo-dashboard',
        builder: (context, state) => const NgoDashboard(),
        routes: [
          GoRoute(
            path: 'project-submission',
            name: 'ngo-project-submission',
            builder: (context, state) => const ProjectSubmissionPage(),
          ),
          GoRoute(
            path: 'analytics',
            name: 'ngo-analytics',
            builder: (context, state) => const NgoAnalyticsPage(),
          ),
        ],
      ),

      // Admin Routes
      GoRoute(
        path: AppRoutes.adminDashboard,
        name: 'admin-dashboard',
        builder: (context, state) => const AdminDashboard(),
        routes: [
          GoRoute(
            path: 'analytics',
            name: 'admin-analytics',
            builder: (context, state) => const AdminAnalyticsPage(),
          ),
          GoRoute(
            path: 'project-review/:id',
            name: 'admin-project-review',
            builder: (context, state) {
              final projectId = state.pathParameters['id']!;
              return ProjectReviewPage(projectId: projectId);
            },
          ),
        ],
      ),

      // Buyer Routes
      GoRoute(
        path: AppRoutes.buyerDashboard,
        name: 'buyer-dashboard',
        builder: (context, state) => const BuyerDashboard(),
        routes: [
          GoRoute(
            path: 'marketplace',
            name: 'buyer-marketplace',
            builder: (context, state) => const MarketplacePage(),
          ),
          GoRoute(
            path: 'portfolio',
            name: 'buyer-portfolio',
            builder: (context, state) => const PortfolioPage(),
          ),
        ],
      ),

      // Standalone Routes for easier navigation
      GoRoute(
        path: AppRoutes.projectSubmission,
        name: 'project-submission',
        builder: (context, state) => const ProjectSubmissionPage(),
      ),
      GoRoute(
        path: '/project-review/:id',
        name: 'project-review',
        builder: (context, state) {
          final projectId = state.pathParameters['id']!;
          return ProjectReviewPage(projectId: projectId);
        },
      ),
      GoRoute(
        path: AppRoutes.marketplace,
        name: 'marketplace',
        builder: (context, state) => const MarketplacePage(),
      ),
      GoRoute(
        path: AppRoutes.portfolio,
        name: 'portfolio',
        builder: (context, state) => const PortfolioPage(),
      ),
      GoRoute(
        path: AppRoutes.ngoAnalytics,
        name: 'ngo-analytics-standalone',
        builder: (context, state) => const NgoAnalyticsPage(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/certificates',
        name: 'certificates',
        builder: (context, state) => const CertificatesPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'The page you\'re looking for doesn\'t exist or has been moved.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Requested: ${state.uri}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.go(AppRoutes.login),
                    icon: const Icon(Icons.home),
                    label: const Text('Go to Login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.go(AppRoutes.login),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
});