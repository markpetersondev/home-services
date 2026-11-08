import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';
import 'users_provider.dart';

// Stores the phone number entered on the phone screen
final phoneProvider = StateProvider<String>((ref) => '');

final authProvider =
    StateNotifierProvider<AuthNotifier, AppUser?>((ref) {
  return AuthNotifier(ref);
});

// Always returns the up-to-date user object from usersProvider
final currentUserProvider = Provider<AppUser?>((ref) {
  final authUser = ref.watch(authProvider);
  if (authUser == null) return null;
  final users = ref.watch(usersProvider);
  try {
    return users.firstWhere((u) => u.id == authUser.id);
  } catch (_) {
    return null;
  }
});

class AuthNotifier extends StateNotifier<AppUser?> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(null);

  /// Returns true if a matching user was found and logged in.
  Future<bool> login(String phone, String password) async {
    final user = await _ref.read(userRepositoryProvider).login(phone, password);
    if (user == null) return false;
    state = user;
    return true;
  }

  void logout() => state = null;
}
