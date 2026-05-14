enum WithdrawalStatus { pending, completed, rejected }

class WithdrawalModel {
  final String id;
  final double amount;
  final String address;
  final String network;
  final DateTime date;
  final WithdrawalStatus status;
  final dynamic userId; // Can be String (ID) or Map (Populated User)

  WithdrawalModel({
    required this.id,
    required this.amount,
    required this.address,
    required this.network,
    required this.date,
    required this.status,
    this.userId,
  });

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) {
    String statusStr = json['status'] ?? 'pending';
    if (statusStr == 'failed') statusStr = 'rejected';
    
    return WithdrawalModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      address: json['wallet_address'] ?? json['walletAddress'] ?? json['address'] ?? '',
      network: json['network'] ?? '',
      date: DateTime.parse(json['created_at'] ?? json['createdAt'] ?? json['date'] ?? DateTime.now().toIso8601String()),
      status: WithdrawalStatus.values.firstWhere(
        (e) => e.name == statusStr,
        orElse: () => WithdrawalStatus.pending,
      ),
      userId: json['user_id'] ?? json['userId'],
    );
  }
}
