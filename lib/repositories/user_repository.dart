import '../models/app_user.dart';

/// Everything the app needs to know about users.
///
/// The methods return Futures because a real API will be asynchronous. To
/// connect a backend, write an `ApiUserRepository` and return it from
/// `userRepositoryProvider`. Screens don't need to change.
abstract class UserRepository {
  Future<List<AppUser>> fetchUsers();

  /// Returns the matching user, or null if the phone and code are wrong.
  Future<AppUser?> login(String phone, String code);

  Future<void> registerUser(AppUser user);
  Future<void> toggleOnline(int userId);
  Future<void> addEarnings(int userId, double amount);
}

/// Temporary demo data, held in memory until the app restarts.
class InMemoryUserRepository implements UserRepository {
  final List<AppUser> _users = [
    const AppUser(
      id: 1,
      name: 'Amaya Silva',
      phone: '0701111111',
      password: '1234',
      role: 'customer',
      address: 'Colombo 07',
    ),
    const AppUser(
      id: 2,
      name: 'Saman Perera',
      phone: '0702222222',
      password: '1234',
      role: 'customer',
      address: 'Nugegoda',
    ),
    const AppUser(
      id: 3,
      name: 'Kasun Perera',
      phone: '0771234567',
      password: '1234',
      role: 'provider',
      serviceType: 'Plumbing',
      areaCovered: 'Colombo',
      rating: 4.8,
      isOnline: true,
      earnings: 8500.0,
    ),
    const AppUser(
      id: 4,
      name: 'Nimal Fernando',
      phone: '0777654321',
      password: '1234',
      role: 'provider',
      serviceType: 'Electrical',
      areaCovered: 'Colombo',
      rating: 4.5,
      isOnline: false,
      earnings: 6200.0,
    ),
    const AppUser(
      id: 5,
      name: 'Ruwan Silva',
      phone: '0712223344',
      password: '1234',
      role: 'provider',
      serviceType: 'AC Repair',
      areaCovered: 'Dehiwala',
      rating: 4.9,
      isOnline: false,
      earnings: 11000.0,
    ),
  ];

  @override
  Future<List<AppUser>> fetchUsers() async => List.unmodifiable(_users);

  @override
  Future<AppUser?> login(String phone, String code) async {
    for (final user in _users) {
      if (user.phone == phone && user.password == code) return user;
    }
    return null;
  }

  @override
  Future<void> registerUser(AppUser user) async => _users.add(user);

  @override
  Future<void> toggleOnline(int userId) async {
    _update(userId, (u) => u.copyWith(isOnline: !u.isOnline));
  }

  @override
  Future<void> addEarnings(int userId, double amount) async {
    _update(userId, (u) => u.copyWith(earnings: u.earnings + amount));
  }

  void _update(int userId, AppUser Function(AppUser) change) {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) _users[index] = change(_users[index]);
  }
}
