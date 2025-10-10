import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 1)
class Transaction {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final double amount;
  @HiveField(3)
  final DateTime doneAt;
  @HiveField(4)
  final int categoryId;
  @HiveField(5)
  final int accountId;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.doneAt,
    required this.categoryId,
    required this.accountId,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      title: json['title'],
      amount: json['amount'],
      doneAt: DateTime.parse(json['done_at']),
      categoryId: json['category_id'],
      accountId: json['account_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'done_at': doneAt.toIso8601String(),
      'category_id': categoryId,
      'account_id': accountId,
    };
  }
}
