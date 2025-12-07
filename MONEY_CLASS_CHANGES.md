# Изменения: Использование класса Money для всех денежных сумм

## Обзор

Все денежные суммы в приложении теперь используют класс `Money` вместо простых значений `double`. Это позволяет в будущем легко добавить поддержку нескольких валют.

## Класс Money

Создан новый класс `lib/models/money.dart` со следующими возможностями:

- **Поля**:
  - `amount` (double) - сумма денег
  - `currency` (String) - код валюты (например, 'RUB', 'USD', 'EUR')

- **Конструкторы**:
  - `Money({required amount, required currency})` - основной конструктор
  - `Money.rub(amount)` - удобный конструктор для рублей (используется везде)
  - `Money.fromDatabase(amount)` - создание из БД (всегда RUB)
  - `Money.fromJson(json)` - десериализация из JSON

- **Методы**:
  - `toDatabaseValue()` - получение amount для сохранения в БД
  - `toJson()` - сериализация в JSON
  - `toString()` - строковое представление
  - Переопределены `==` и `hashCode` для сравнения

## Изменённые модели

### Transaction (lib/models/transaction.dart)
- `double amount` → `Money amount`
- Обновлены `fromJson()` и `toJson()` для работы с Money

### Account (lib/models/account.dart)
- `double balance` → `Money balance`
- Обновлены `fromJson()` и `toJson()` для работы с Money

### Goal (lib/models/goal.dart)
- `double targetAmount` → `Money targetAmount`
- Обновлены `fromJson()` и `toJson()` для работы с Money

## Изменённые сервисы

### DatabaseService (lib/services/database_service.dart)
Обновлены все методы для работы с Money:
- `createAccount(name, Money initialBalance)`
- `updateAccount({id, name, Money? balance})`
- `createTransaction({title, Money amount, ...})`
- `updateTransaction({id, title, categoryId, Money? amount})`
- `createGoal({accountId, Money targetAmount, deadline})`
- `updateGoal({id, accountId, Money? targetAmount, ...})`

База данных продолжает хранить суммы как `REAL`, преобразование происходит на уровне сервиса.

## Изменённые провайдеры

Все провайдеры обновлены для передачи объектов Money:
- `AccountProvider` - `addAccount()`, `updateAccount()`
- `TransactionProvider` - `addTransaction()`, `updateTransaction()`
- `GoalProvider` - `addGoal()`, `updateGoal()`

## Изменённые виджеты

Обновлены все формы и виджеты отображения:

### Формы создания/редактирования:
- `AddAccountBottomSheet` - создание счёта с `Money.rub()`
- `EditAccountBottomSheet` - редактирование счёта
- `AddTransactionBottomSheet` - создание транзакции
- `EditTransactionBottomSheet` - редактирование транзакции
- `AddGoalBottomSheet` - создание цели
- `EditGoalBottomSheet` - редактирование цели

### Виджеты отображения:
- `AccountPlate` - отображение баланса через `balance.amount`
- `TransactionPlate` - отображение суммы через `amount.amount`
- `Dashboard` - подсчёт балансов и сумм через `.amount`
- `Reports` - анализ данных через `.amount`
- `Accounts` - суммирование балансов через `.amount`

## Графический интерфейс

Графический интерфейс **не изменился**:
- Все суммы продолжают отображаться так же, как раньше
- Форматирование происходит через существующие методы `_formatBalance()` и `_formatAmount()`
- Пользователи вводят суммы как обычные числа

## Тесты

Добавлены и обновлены тесты:
- Создан `test/money_test.dart` с тестами для класса Money
- Обновлены все существующие тесты для работы с Money:
  - `balance_management_test.dart`
  - `negative_balance_validation_test.dart`
  - `widget_test.dart`

## Использование в коде

### Создание Money объектов:
```dart
// Для рублей (используется везде в приложении)
final money = Money.rub(1000.50);

// Для других валют (в будущем)
final money = Money(amount: 100.0, currency: 'USD');
```

### Получение суммы:
```dart
final account = await dbService.getAccount(id);
final balance = account.balance.amount; // double
```

### Отображение:
```dart
Text('Баланс: ${account.balance.amount.toStringAsFixed(2)} ₽')
```

## Валюта

На данный момент **везде используются российские рубли (RUB)**:
- Все суммы создаются через `Money.rub()`
- База данных хранит только `amount` (валюта не сохраняется)
- `Money.fromDatabase()` всегда создаёт рубли

В будущем можно легко добавить поддержку других валют:
1. Добавить поле `currency` в таблицы БД
2. Обновить `fromDatabase()` и `toDatabaseValue()`
3. Добавить конвертацию валют
4. Обновить UI для выбора валюты

## Совместимость

Все изменения **обратно совместимы** с существующей базой данных:
- Структура таблиц не изменилась
- Данные продолжают храниться как `REAL`
- Миграция БД не требуется
