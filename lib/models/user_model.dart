class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final double miningRate;
  final bool isPremium;
  final String referralCode;
  final String? country;
  final String? city;
  final String? profileImage;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'user',
    this.miningRate = 1.0,
    this.isPremium = false,
    this.referralCode = '',
    this.country,
    this.city,
    this.profileImage,
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      miningRate: (json['miningRate'] ?? 1.0).toDouble(),
      isPremium: json['isPremium'] ?? false,
      referralCode: json['referralCode'] ?? '',
      country: json['country'],
      city: json['city'],
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'miningRate': miningRate,
      'isPremium': isPremium,
      'referralCode': referralCode,
      'country': country,
      'city': city,
      'profileImage': profileImage,
    };
  }
}
