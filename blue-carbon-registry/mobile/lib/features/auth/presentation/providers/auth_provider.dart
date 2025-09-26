import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await Future.delayed(const Duration(seconds: 1));

      UserRole role;
      String name;
      String orgName;

      if (email.contains('ngo')) {
        role = UserRole.ngo;
        name = 'Coastal Conservation NGO';
        orgName = 'Green Coast Foundation';
      } else if (email.contains('admin')) {
        role = UserRole.admin;
        name = 'Forest Admin';
        orgName = 'Ministry of Environment';
      } else if (email.contains('buyer')) {
        role = UserRole.buyer;
        name = 'EcoTech Corp';
        orgName = 'EcoTech Corporation';
      } else {
        role = UserRole.ngo;
        name = 'Test User';
        orgName = 'Test Organization';
      }

      final user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name,
        role: role,
        organizationName: orgName,
        phone: '+91 9876543210',
        locale: 'en',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastLoginAt: DateTime.now(),
      );

      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Invalid credentials',
      );
    }
  }

  Future<void> quickLogin(UserRole role) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      String name, email, orgName;

      switch (role) {
        case UserRole.ngo:
          name = 'Mangrove Restoration NGO';
          email = 'ngo@bluecarbonregistry.com';
          orgName = 'Coastal Conservation Foundation';
          break;
        case UserRole.admin:
          name = 'Environment Officer';
          email = 'admin@bluecarbonregistry.com';
          orgName = 'Ministry of Environment & Forests';
          break;
        case UserRole.buyer:
          name = 'Sustainability Manager';
          email = 'buyer@ecotech.com';
          orgName = 'EcoTech Corporation';
          break;
      }

      final user = User(
        id: 'demo_${role.name.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name,
        role: role,
        organizationName: orgName,
        phone: '+91 9876543210',
        locale: 'en',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastLoginAt: DateTime.now(),
      );

      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Quick login failed',
      );
    }
  }

  Future<void> logout() async {
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});