import 'package:flutter/material.dart';

import '../controller.dart';
import 'banks_screen.dart';
import 'dashboard_screen.dart';
import 'import_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key, required this.controller, this.initialIndex = 0});

  final MisFinController controller;
  final int initialIndex;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, 4).toInt();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(controller: widget.controller),
      ImportScreen(controller: widget.controller),
      HistoryScreen(controller: widget.controller),
      BanksScreen(controller: widget.controller),
      SettingsScreen(controller: widget.controller),
    ];

    final titles = ['Inicio', 'Importar', 'Historial', 'Bancos', 'Ajustes'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(titles[_index]),
        actions: [
          if (_index == 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(
                backgroundColor: Colors.white.withOpacity(0.14),
                label: Text(
                  widget.controller.isOverBudget
                      ? 'Fuera de limite'
                      : widget.controller.shouldWarn
                          ? 'Ojo'
                          : 'Ok',
                ),
              ),
            ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF050308), Color(0xFF180A24), Color(0xFF351050), Color(0xFF09050D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: IndexedStack(
            index: _index,
            children: pages,
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xDD170B22),
        indicatorColor: const Color(0xFFB26BFF),
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Importar'),
          NavigationDestination(icon: Icon(Icons.timeline_outlined), selectedIcon: Icon(Icons.timeline), label: 'Historial'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Bancos'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}
