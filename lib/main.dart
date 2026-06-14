import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/achiever_screen.dart';
import 'screens/analysis_screen.dart';
import 'constants/theme.dart';
import 'constants/keys.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final provider = AppProvider();
  await provider.init();

  runApp(
    ChangeNotifierProvider.value(
      value: provider,
      child: const QuestLogApp(),
    ),
  );
}

class QuestLogApp extends StatelessWidget {
  const QuestLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Deskter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.bg,
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CalendarScreen(),
    AchieverScreen(),
    AnalysisScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: NavigationBar(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.accent.withOpacity(0.2),
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.shield_outlined, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.shield, color: AppColors.accentLight),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined,
                color: AppColors.textMuted),
            selectedIcon:
                Icon(Icons.calendar_month, color: AppColors.accentLight),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.flag, color: AppColors.accentLight),
            label: 'Achiever',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.bar_chart, color: AppColors.accentLight),
            label: 'Analysis',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.person, color: AppColors.accentLight),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}