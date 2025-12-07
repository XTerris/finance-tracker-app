import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker_app/widgets/tabs/tab_widgets/add_bottom_sheet_base.dart';

// Простой тестовый виджет, наследующий AddBottomSheetBase
class TestBottomSheet extends AddBottomSheetBase {
  const TestBottomSheet({super.key});

  @override
  State<TestBottomSheet> createState() => _TestBottomSheetState();
}

class _TestBottomSheetState extends AddBottomSheetBaseState<TestBottomSheet> {
  @override
  String get title => 'Test Title';

  @override
  String get submitButtonText => 'Submit Test';

  @override
  Future<void> submitForm() async {
    // Простая реализация для теста
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      Navigator.of(context).pop('success');
    }
  }

  @override
  Widget buildFormContent(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'Test Field'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required field';
            }
            return null;
          },
        ),
      ],
    );
  }
}

void main() {
  group('AddBottomSheetBase', () {
    testWidgets('renders with title and close button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => const TestBottomSheet(),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      // Открываем bottom sheet
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Проверяем, что заголовок отображается
      expect(find.text('Test Title'), findsOneWidget);

      // Проверяем, что кнопка закрытия отображается
      expect(find.byIcon(Icons.close), findsOneWidget);

      // Проверяем, что кнопка отправки отображается
      expect(find.text('Submit Test'), findsOneWidget);
    });

    testWidgets('renders form content', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => const TestBottomSheet(),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Проверяем, что контент формы отображается
      expect(find.text('Test Field'), findsOneWidget);
    });

    testWidgets('closes when close button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => const TestBottomSheet(),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Проверяем, что bottom sheet открыт
      expect(find.text('Test Title'), findsOneWidget);

      // Нажимаем кнопку закрытия
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Проверяем, что bottom sheet закрыт
      expect(find.text('Test Title'), findsNothing);
    });

    testWidgets('validates form before submission',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => const TestBottomSheet(),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Пытаемся отправить форму без заполнения
      await tester.tap(find.text('Submit Test'));
      await tester.pumpAndSettle();

      // Проверяем, что отображается сообщение об ошибке
      expect(find.text('Required field'), findsOneWidget);

      // Bottom sheet не должен закрыться
      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets('shows loading indicator during submission',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => const TestBottomSheet(),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Заполняем поле
      await tester.enterText(find.byType(TextFormField), 'Test Value');

      // Нажимаем кнопку отправки
      await tester.tap(find.text('Submit Test'));
      await tester.pump(); // Только один pump, чтобы увидеть индикатор загрузки

      // Проверяем, что отображается индикатор загрузки
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Ждем завершения
      await tester.pumpAndSettle();
    });

    testWidgets('submits form successfully when valid',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  final result = await showModalBottomSheet(
                    context: context,
                    builder: (_) => const TestBottomSheet(),
                  );
                  if (result == 'success') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Success')),
                    );
                  }
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Заполняем поле
      await tester.enterText(find.byType(TextFormField), 'Test Value');

      // Нажимаем кнопку отправки
      await tester.tap(find.text('Submit Test'));
      await tester.pumpAndSettle();

      // Bottom sheet должен закрыться
      expect(find.text('Test Title'), findsNothing);
    });
  });
}
