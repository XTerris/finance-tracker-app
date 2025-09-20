import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['username'],
      email: json['login'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': name,
      'login': email,
    };
  }
}
