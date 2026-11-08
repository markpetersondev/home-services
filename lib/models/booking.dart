class Booking {
  final int id;
  final int customerId;
  final int? providerId;
  final String serviceType;
  final String address;
  final String description;
  final DateTime scheduledAt;
  final String status; // 'pending', 'accepted', 'inProgress', 'completed', 'cancelled'
  final double? price;
  final DateTime createdAt;
  final List<int> declinedBy; // Providers who declined this booking

  const Booking({
    required this.id,
    required this.customerId,
    this.providerId,
    required this.serviceType,
    required this.address,
    required this.description,
    required this.scheduledAt,
    required this.status,
    this.price,
    required this.createdAt,
    this.declinedBy = const [],
  });

  Booking copyWith({
    int? id,
    int? customerId,
    int? providerId,
    String? serviceType,
    String? address,
    String? description,
    DateTime? scheduledAt,
    String? status,
    double? price,
    DateTime? createdAt,
    List<int>? declinedBy,
  }) {
    return Booking(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      providerId: providerId ?? this.providerId,
      serviceType: serviceType ?? this.serviceType,
      address: address ?? this.address,
      description: description ?? this.description,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      status: status ?? this.status,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      declinedBy: declinedBy ?? this.declinedBy,
    );
  }

  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[scheduledAt.month - 1];
    final hour = scheduledAt.hour % 12 == 0 ? 12 : scheduledAt.hour % 12;
    final min = scheduledAt.minute.toString().padLeft(2, '0');
    final period = scheduledAt.hour < 12 ? 'AM' : 'PM';
    return '$month ${scheduledAt.day}, ${scheduledAt.year} · $hour:$min $period';
  }

  String? get formattedPrice {
    if (price == null) return null;
    final n = price!.toInt();
    if (n >= 1000) {
      return 'Rs. ${(n ~/ 1000)},${(n % 1000).toString().padLeft(3, '0')}';
    }
    return 'Rs. $n';
  }
}
