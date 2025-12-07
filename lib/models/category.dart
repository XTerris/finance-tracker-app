// Модель категории транзакций (например, "Еда", "Транспорт")
class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  // Создание объекта из JSON (из базы данных)
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: json['id'], name: json['name']);
  }

  // Преобразование объекта в JSON (для сохранения в БД)
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
