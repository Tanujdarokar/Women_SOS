import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:women_sos/services/api_service.dart';

class AuthState {
  final bool isLoading;
  final String? userId;
  final String? name;
  final String? email;
  final String? phone;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.userId,
    this.name,
    this.email,
    this.phone,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _loadSession();
  }

  void _loadSession() {
    state = AuthState(
      userId: ApiService.loggedInUserId,
      name: ApiService.userFullName,
      email: ApiService.userEmail,
      phone: ApiService.userPhone,
    );
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await ApiService.login(email, password);
    
    if (response != null) {
      state = AuthState(
        userId: ApiService.loggedInUserId,
        name: ApiService.userFullName,
        email: ApiService.userEmail,
        phone: ApiService.userPhone,
      );
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: "Invalid credentials");
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await ApiService.register(name, email, password, phone, "User");
    
    if (response != null) {
      await ApiService.saveUserData(
        response['_id'] ?? "",
        name,
        email,
        phone,
      );
      state = AuthState(
        userId: ApiService.loggedInUserId,
        name: ApiService.userFullName,
        email: ApiService.userEmail,
        phone: ApiService.userPhone,
      );
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: "Registration failed");
      return false;
    }
  }

  Future<void> logout() async {
    await ApiService.logout();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
