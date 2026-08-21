import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kumayokeru_app/data/datasources/remote/auth_remote_datasource.dart';
import 'package:kumayokeru_app/data/repositories/auth_repository_impl.dart';
import 'package:kumayokeru_app/domain/entities/auth_user.dart';
import 'package:kumayokeru_app/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

/// 認証状態。isLoading中はボタンを無効化し、errorMessageがあればスナックバー等で表示する。
class AuthState {
  const AuthState({this.user, this.isLoading = false, this.errorMessage});

  final AuthUser? user;
  final bool isLoading;
  final String? errorMessage;

  bool get isAuthenticated => user != null;

  AuthState copyWith({AuthUser? user, bool? isLoading, String? errorMessage}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(const AuthState()) {
    _restoreSession();
  }

  final AuthRepository _repository;

  Future<void> _restoreSession() async {
    final user = await _repository.currentUser();
    if (user != null) state = state.copyWith(user: user);
  }

  Future<void> signUp(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _repository.signUp(email, password);
      state = AuthState(user: user);
    } on AuthApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _repository.login(email, password);
      state = AuthState(user: user);
    } on AuthApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    }
  }

  Future<void> updateName(String name) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _repository.updateName(name);
      state = AuthState(user: user);
    } on AuthApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
