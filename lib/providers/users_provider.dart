import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';
import '../repositories/user_repository.dart';

/// Swap this for an API version when the backend is ready.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return InMemoryUserRepository();
});

final usersProvider =
    StateNotifierProvider<UsersNotifier, List<AppUser>>((ref) {
  return UsersNotifier(ref.watch(userRepositoryProvider));
});

class UsersNotifier extends StateNotifier<List<AppUser>> {
  final UserRepository _repository;

  UsersNotifier(this._repository) : super(const []) {
    _refresh();
  }

  Future<void> _refresh() async {
    final users = await _repository.fetchUsers();
    if (mounted) state = users;
  }

  Future<void> registerUser(AppUser user) async {
    await _repository.registerUser(user);
    await _refresh();
  }

  Future<void> toggleOnline(int userId) async {
    await _repository.toggleOnline(userId);
    await _refresh();
  }

  Future<void> addEarnings(int userId, double amount) async {
    await _repository.addEarnings(userId, amount);
    await _refresh();
  }
}
