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
  final double balance;
  final double referralEarnings;
  final double totalEarnedFromMining;
  final bool isFlagged;
  final DateTime? premiumExpiry;

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
    this.balance = 0.0,
    this.referralEarnings = 0.0,
    this.totalEarnedFromMining = 0.0,
    this.isFlagged = false,
    this.premiumExpiry,
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      miningRate: (json['mining_rate'] ?? json['miningRate'] ?? 0.01).toDouble(),
      isPremium: (json['is_premium'] ?? json['isPremium'] ?? false) == true || (json['is_premium'] ?? json['isPremium'] ?? 0) == 1,
      referralCode: json['referral_code'] ?? json['referralCode'] ?? '',
      country: json['country'],
      city: json['city'],
      profileImage: json['profile_image'] ?? json['profileImage'],
      balance: (json['balance'] ?? 0.0).toDouble(),
      referralEarnings: (json['referral_earnings'] ?? json['referralEarnings'] ?? 0.0).toDouble(),
      totalEarnedFromMining: (json['total_earned_from_mining'] ?? json['totalEarnedFromMining'] ?? 0.0).toDouble(),
      isFlagged: (json['is_flagged'] ?? json['isFlagged'] ?? false) == true || (json['is_flagged'] ?? json['isFlagged'] ?? 0) == 1,
      premiumExpiry: json['premium_expiry'] != null ? DateTime.parse(json['premium_expiry']) : null,
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
      'balance': balance,
      'referralEarnings': referralEarnings,
      'totalEarnedFromMining': totalEarnedFromMining,
      'isFlagged': isFlagged,
      'premium_expiry': premiumExpiry?.toIso8601String(),
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
    double? balance,
    double? referralEarnings,
    double? totalEarnedFromMining,
    bool? isFlagged,
    DateTime? premiumExpiry,
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
      balance: balance ?? this.balance,
      referralEarnings: referralEarnings ?? this.referralEarnings,
      totalEarnedFromMining: totalEarnedFromMining ?? this.totalEarnedFromMining,
      isFlagged: isFlagged ?? this.isFlagged,
      premiumExpiry: premiumExpiry ?? this.premiumExpiry,
    );
  }
}
