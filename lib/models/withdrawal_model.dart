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
    return WithdrawalModel(
      id: json['_id'] ?? json['id'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      address: json['walletAddress'] ?? json['address'] ?? '',
      network: json['network'] ?? '',
      date: DateTime.parse(json['createdAt'] ?? json['date'] ?? DateTime.now().toIso8601String()),
      status: WithdrawalStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => WithdrawalStatus.pending,
      ),
      userId: json['userId'],
    );
  }
}
