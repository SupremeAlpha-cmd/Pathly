import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Supabase client provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Auth state stream provider
final authStateProvider = StreamProvider<User?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange.map((event) => event.session?.user);
});

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

// Auth notifier
class AuthNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  SupabaseClient get _client => ref.read(supabaseClientProvider);

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        await _client.auth.signUp(
          email: email,
          password: password,
          data: {'full_name': fullName},
        );
      } on AuthRetryableFetchException {
        // Retry once for transient web fetch errors
        await _client.auth.signUp(
          email: email,
          password: password,
          data: {'full_name': fullName},
        );
      }
    });
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        await _client.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } on AuthRetryableFetchException {
        // Retry once for transient web fetch errors
        await _client.auth.signInWithPassword(
          email: email,
          password: password,
        );
      }
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _client.auth.signOut();
    });
  }

  Future<void> resetPassword(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _client.auth.resetPasswordForEmail(email);
    });
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, void>(AuthNotifier.new);