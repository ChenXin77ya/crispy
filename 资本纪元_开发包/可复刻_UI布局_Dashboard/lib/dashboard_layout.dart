import 'package:flutter/material.dart';

import 'widgets/dashboard_balance_section.dart';
import 'widgets/dashboard_history_section.dart';
import 'widgets/dashboard_right_panel.dart';
import 'widgets/dashboard_sidebar.dart';
import 'widgets/dashboard_summary_cards.dart';
import 'widgets/dashboard_top_bar.dart';

class DashboardLayoutPage extends StatefulWidget {
  const DashboardLayoutPage({super.key});

  @override
  State<DashboardLayoutPage> createState() => _DashboardLayoutPageState();
}

class _DashboardLayoutPageState extends State<DashboardLayoutPage> {
  static const breakpointWide = 1100.0;

  final _drawerKey = GlobalKey<ScaffoldState>();
  int _navIndex = 0;

  void _onNavSelected(int index) {
    setState(() => _navIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= breakpointWide;

        if (isWide) {
          return _WideDashboard(
            navIndex: _navIndex,
            onNavSelected: _onNavSelected,
          );
        }

        return Scaffold(
          key: _drawerKey,
          drawer: Drawer(
            child: SafeArea(
              child: DashboardSidebar(
                selectedIndex: _navIndex,
                onSelected: _onNavSelected,
                isInDrawer: true,
              ),
            ),
          ),
          backgroundColor: const Color(0xFFF4F6FB),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    DashboardTopBar(
                      leading: IconButton(
                        onPressed: () => _drawerKey.currentState?.openDrawer(),
                        icon: const Icon(Icons.menu_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const DashboardSummaryCards(),
                    const SizedBox(height: 18),
                    const DashboardBalanceSection(),
                    const SizedBox(height: 18),
                    const DashboardHistorySection(),
                    const SizedBox(height: 18),
                    const DashboardRightPanel(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WideDashboard extends StatelessWidget {
  const _WideDashboard({
    required this.navIndex,
    required this.onNavSelected,
  });

  final int navIndex;
  final ValueChanged<int> onNavSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Row(
          children: [
            DashboardSidebar(
              selectedIndex: navIndex,
              onSelected: onNavSelected,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(26, 18, 26, 18),
                child: Column(
                  children: [
                    const DashboardTopBar(),
                    const SizedBox(height: 18),
                    const Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            DashboardSummaryCards(),
                            SizedBox(height: 18),
                            DashboardBalanceSection(),
                            SizedBox(height: 18),
                            DashboardHistorySection(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 360,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 18, 18, 18),
                child: DashboardRightPanel(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

