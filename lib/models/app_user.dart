class AppUser {
  final int id;
  final String name;
  final String phone;
  final String password;
  final String role; // 'customer' or 'provider'
  final String? address;
  final String? serviceType;
  final String? areaCovered;
  final double rating;
  final bool isOnline;
  final double earnings;

  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.password,
    required this.role,
    this.address,
    this.serviceType,
    this.areaCovered,
    this.rating = 0.0,
    this.isOnline = false,
    this.earnings = 0.0,
  });

  AppUser copyWith({
    int? id,
    String? name,
    String? phone,
    String? password,
    String? role,
    String? address,
    String? serviceType,
    String? areaCovered,
    double? rating,
    bool? isOnline,
    double? earnings,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      role: role ?? this.role,
      address: address ?? this.address,
      serviceType: serviceType ?? this.serviceType,
      areaCovered: areaCovered ?? this.areaCovered,
      rating: rating ?? this.rating,
      isOnline: isOnline ?? this.isOnline,
      earnings: earnings ?? this.earnings,
    );
  }

  String get formattedEarnings {
    final n = earnings.toInt();
    if (n >= 1000) {
      return 'Rs. ${(n ~/ 1000)},${(n % 1000).toString().padLeft(3, '0')}';
    }
    return 'Rs. $n';
  }
}
