import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';

final _initialUsers = <AppUser>[
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

final usersProvider =
    StateNotifierProvider<UsersNotifier, List<AppUser>>((ref) {
  return UsersNotifier();
});

class UsersNotifier extends StateNotifier<List<AppUser>> {
  UsersNotifier() : super(_initialUsers);

  void registerUser(AppUser user) {
    state = [...state, user];
  }

  void toggleOnline(int userId) {
    state = [
      for (final u in state)
        if (u.id == userId) u.copyWith(isOnline: !u.isOnline) else u,
    ];
  }
}
