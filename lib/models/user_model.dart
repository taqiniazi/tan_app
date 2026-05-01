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
  final double referralEarnings;
  final double totalEarnedFromMining;
  final bool isFlagged;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'user',
    this.miningRate = 0.01,
    this.isPremium = false,
    this.referralCode = '',
    this.country,
    this.city,
    this.profileImage,
    this.referralEarnings = 0.0,
    this.totalEarnedFromMining = 0.0,
    this.isFlagged = false,
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      miningRate: (json['miningRate'] ?? 0.01).toDouble(),
      isPremium: json['isPremium'] ?? false,
      referralCode: json['referralCode'] ?? '',
      country: json['country'],
      city: json['city'],
      profileImage: json['profileImage'],
      referralEarnings: (json['referralEarnings'] ?? 0.0).toDouble(),
      totalEarnedFromMining: (json['totalEarnedFromMining'] ?? 0.0).toDouble(),
      isFlagged: json['isFlagged'] ?? false,
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
      'referralEarnings': referralEarnings,
      'totalEarnedFromMining': totalEarnedFromMining,
      'isFlagged': isFlagged,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    double? miningRate,
    bool? isPremium,
    String? referralCode,
    String? country,
    String? city,
    String? profileImage,
    double? referralEarnings,
    double? totalEarnedFromMining,
    bool? isFlagged,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      miningRate: miningRate ?? this.miningRate,
      isPremium: isPremium ?? this.isPremium,
      referralCode: referralCode ?? this.referralCode,
      country: country ?? this.country,
      city: city ?? this.city,
      profileImage: profileImage ?? this.profileImage,
      referralEarnings: referralEarnings ?? this.referralEarnings,
      totalEarnedFromMining: totalEarnedFromMining ?? this.totalEarnedFromMining,
      isFlagged: isFlagged ?? this.isFlagged,
    );
  }
}
