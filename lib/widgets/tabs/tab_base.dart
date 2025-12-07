import 'package:flutter/material.dart';

/// Base class for all tab widgets in the application.
/// 
/// This abstract class serves as the foundation for DashboardTab, HistoryTab, 
/// AccountsAndGoalsTab, and ReportsTab. It provides a common structure for 
/// all tab implementations.
abstract class TabBase extends StatefulWidget {
  const TabBase({super.key});
}
