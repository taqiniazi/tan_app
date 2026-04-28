enum WithdrawalStatus { pending, completed, rejected }

class WithdrawalModel {
  final String id;
  final double amount;
  final String address;
  final String network;
  final DateTime date;
  final WithdrawalStatus status;

  WithdrawalModel({
    required this.id,
    required this.amount,
    required this.address,
    required this.network,
    required this.date,
    required this.status,
  });

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalModel(
      id: json['id'],
      amount: json['amount'].toDouble(),
      address: json['address'],
      network: json['network'],
      date: DateTime.parse(json['date']),
      status: WithdrawalStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => WithdrawalStatus.pending,
      ),
    );
  }
}
