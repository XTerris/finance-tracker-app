// Example Usage Scenario - Demonstrating Balance Management
// This file shows how the balance management works in practice

// SCENARIO 1: Basic Transaction Creation
// ======================================

void scenario1_basicTransaction() async {
  final dbService = DatabaseService();
  
  // Create an account with $1000
  final account = await dbService.createAccount('Checking', 1000.0);
  print('Initial balance: \$${account.balance}'); // Output: $1000
  
  // Create a category
  final category = await dbService.createCategory('Groceries');
  
  // Add an expense transaction
  final transaction = await dbService.createTransaction(
    title: 'Weekly Shopping',
    amount: 150.0,
    categoryId: category.id,
    fromAccountId: account.id,
  );
  
  // Check the balance - it should now be $850
  final accounts = await dbService.getAllAccounts();
  final updatedAccount = accounts.firstWhere((a) => a.id == account.id);
  print('Balance after expense: \$${updatedAccount.balance}'); // Output: $850
  
  // ✅ RESULT: Balance automatically updated!
}

// SCENARIO 2: Historical Transaction Validation
// =============================================

void scenario2_historicalValidation() async {
  final dbService = DatabaseService();
  
  // Create an account with $1000
  final account = await dbService.createAccount('Checking', 1000.0);
  final category = await dbService.createCategory('Expenses');
  
  final now = DateTime.now();
  
  // Add a transaction today for $900
  await dbService.createTransaction(
    title: 'Big Purchase',
    amount: 900.0,
    categoryId: category.id,
    fromAccountId: account.id,
    doneAt: now,
  );
  
  // Current balance: $100
  
  // Try to add a historical transaction for $950 (yesterday)
  try {
    await dbService.createTransaction(
      title: 'Past Expense',
      amount: 950.0,
      categoryId: category.id,
      fromAccountId: account.id,
      doneAt: now.subtract(Duration(days: 1)),
    );
    print('Transaction succeeded - ERROR!');
  } catch (e) {
    print('Transaction rejected: $e');
    // Output: Transaction would cause account "Checking" balance to become 
    //         negative at some point in history. Transaction rejected.
  }
  
  // Balance remains $100 - transaction was rolled back!
  
  // ✅ RESULT: Invalid historical transaction prevented!
}

// SCENARIO 3: Transfer Between Accounts
// =====================================

void scenario3_transfer() async {
  final dbService = DatabaseService();
  
  // Create two accounts
  final checking = await dbService.createAccount('Checking', 1000.0);
  final savings = await dbService.createAccount('Savings', 500.0);
  final category = await dbService.createCategory('Transfer');
  
  // Transfer $300 from checking to savings
  await dbService.createTransaction(
    title: 'Monthly Savings',
    amount: 300.0,
    categoryId: category.id,
    fromAccountId: checking.id,
    toAccountId: savings.id,
  );
  
  // Check both balances
  final accounts = await dbService.getAllAccounts();
  final updatedChecking = accounts.firstWhere((a) => a.id == checking.id);
  final updatedSavings = accounts.firstWhere((a) => a.id == savings.id);
  
  print('Checking balance: \$${updatedChecking.balance}'); // Output: $700
  print('Savings balance: \$${updatedSavings.balance}');   // Output: $800
  
  // ✅ RESULT: Both accounts updated correctly!
}

// SCENARIO 4: Transaction Deletion Validation
// ==========================================

void scenario4_deletionValidation() async {
  final dbService = DatabaseService();
  
  // Create account starting at $0
  final account = await dbService.createAccount('Checking', 0.0);
  final category = await dbService.createCategory('Mixed');
  
  final now = DateTime.now();
  
  // Add income (2 days ago) - balance becomes $100
  final incomeTransaction = await dbService.createTransaction(
    title: 'Income',
    amount: 100.0,
    categoryId: category.id,
    toAccountId: account.id,
    doneAt: now.subtract(Duration(days: 2)),
  );
  
  // Add expense (1 day ago) - balance becomes $10
  await dbService.createTransaction(
    title: 'Expense',
    amount: 90.0,
    categoryId: category.id,
    fromAccountId: account.id,
    doneAt: now.subtract(Duration(days: 1)),
  );
  
  // Current balance: $10
  
  // Try to delete the income transaction
  try {
    await dbService.deleteTransaction(incomeTransaction.id);
    print('Deletion succeeded - ERROR!');
  } catch (e) {
    print('Deletion rejected: $e');
    // Output: Deleting this transaction would cause account "Checking" balance 
    //         to become negative at some point in history. Deletion rejected.
  }
  
  // Balance remains $10 - deletion was rolled back!
  
  // ✅ RESULT: Critical transaction deletion prevented!
}

// SCENARIO 5: Valid Historical Transaction
// =======================================

void scenario5_validHistorical() async {
  final dbService = DatabaseService();
  
  // Create an account with $1000
  final account = await dbService.createAccount('Checking', 1000.0);
  final category = await dbService.createCategory('Expenses');
  
  final now = DateTime.now();
  
  // Add a transaction today for $100
  await dbService.createTransaction(
    title: 'Recent Purchase',
    amount: 100.0,
    categoryId: category.id,
    fromAccountId: account.id,
    doneAt: now,
  );
  
  // Current balance: $900
  
  // Add a historical transaction for $50 (yesterday)
  // This is valid because: 1000 - 50 = 950, then 950 - 100 = 850 (always positive)
  await dbService.createTransaction(
    title: 'Past Expense',
    amount: 50.0,
    categoryId: category.id,
    fromAccountId: account.id,
    doneAt: now.subtract(Duration(days: 1)),
  );
  
  // Check final balance
  final accounts = await dbService.getAllAccounts();
  final updatedAccount = accounts.firstWhere((a) => a.id == account.id);
  print('Final balance: \$${updatedAccount.balance}'); // Output: $850
  
  // Balance history: $1000 → $950 (yesterday) → $850 (today)
  // All positive! ✅
  
  // ✅ RESULT: Valid historical transaction accepted!
}

// SCENARIO 6: Complex Multi-Transaction History
// ============================================

void scenario6_complexHistory() async {
  final dbService = DatabaseService();
  
  final account = await dbService.createAccount('Checking', 500.0);
  final category = await dbService.createCategory('Mixed');
  
  final now = DateTime.now();
  
  // Add transactions in non-chronological order
  
  // Transaction 3 (yesterday): -$100
  await dbService.createTransaction(
    title: 'Transaction 3',
    amount: 100.0,
    categoryId: category.id,
    fromAccountId: account.id,
    doneAt: now.subtract(Duration(days: 1)),
  );
  
  // Transaction 1 (5 days ago): +$50
  await dbService.createTransaction(
    title: 'Transaction 1',
    amount: 50.0,
    categoryId: category.id,
    toAccountId: account.id,
    doneAt: now.subtract(Duration(days: 5)),
  );
  
  // Transaction 2 (3 days ago): -$30
  await dbService.createTransaction(
    title: 'Transaction 2',
    amount: 30.0,
    categoryId: category.id,
    fromAccountId: account.id,
    doneAt: now.subtract(Duration(days: 3)),
  );
  
  // Check final balance
  final accounts = await dbService.getAllAccounts();
  final updatedAccount = accounts.firstWhere((a) => a.id == account.id);
  print('Final balance: \$${updatedAccount.balance}'); // Output: $420
  
  // Balance history (chronological):
  // Start: $500
  // 5 days ago: $500 + $50 = $550 (Transaction 1) ✅
  // 3 days ago: $550 - $30 = $520 (Transaction 2) ✅
  // Yesterday:  $520 - $100 = $420 (Transaction 3) ✅
  // All positive!
  
  // ✅ RESULT: Complex ordering handled correctly!
}

// SUMMARY OF FEATURES DEMONSTRATED:
// =================================
// 
// ✅ Automatic balance updates on transaction creation
// ✅ Historical transaction validation
// ✅ Transfer between accounts
// ✅ Transaction deletion validation
// ✅ Valid historical transactions accepted
// ✅ Complex transaction ordering handled correctly
// ✅ Clear error messages with account names
// ✅ Atomic operations with rollback on failure
