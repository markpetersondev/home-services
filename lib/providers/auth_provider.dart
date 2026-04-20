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
  bool login(String phone, String password) {
    final users = _ref.read(usersProvider);
    try {
      final user = users.firstWhere(
        (u) => u.phone == phone && u.password == password,
      );
      state = user;
      return true;
    } catch (_) {
      return false;
    }
  }

  void logout() => state = null;
}
