import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import 'tab_widgets/transaction_plate.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  @override
  Widget build(BuildContext context) {
    final transactions = context.watch<TransactionProvider>().transactions;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<TransactionProvider>().update();
        },
        child: ListView(
          physics: AlwaysScrollableScrollPhysics(),
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 32),
                  Text(
                    'История',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
            if (transactions.isEmpty)
              Center(
                child: SizedBox(
                  height: 200,
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'Нет транзакций',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),
              )
            else
              ...transactions.map(
                (transaction) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: TransactionPlate(transaction: transaction),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionBottomSheet,
        tooltip: 'Добавить транзакцию',
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddTransactionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Text("Not implemented yet"),
    );
  }
}
