import 'package:flutter/material.dart';

class DashboardSidebar extends StatelessWidget {
  const DashboardSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    this.isInDrawer = false,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool isInDrawer;

  static const _items = <_NavItem>[
    _NavItem(Icons.home_rounded),
    _NavItem(Icons.grid_view_rounded),
    _NavItem(Icons.receipt_long_rounded),
    _NavItem(Icons.credit_card_rounded),
    _NavItem(Icons.emoji_events_rounded),
    _NavItem(Icons.assignment_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    if (isInDrawer) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        children: [
          const SizedBox(height: 8),
          const Text(
            'Dashboard',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < _items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                tileColor:
                    i == selectedIndex ? const Color(0xFFE9ECF6) : null,
                leading: Icon(_items[i].icon),
                title: Text(_labelFor(i)),
                onTap: () {
                  Navigator.of(context).maybePop();
                  onSelected(i);
                },
              ),
            ),
        ],
      );
    }

    return Container(
      width: 96,
      margin: const EdgeInsets.fromLTRB(18, 18, 0, 18),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF1F8),
        borderRadius: BorderRadius.circular(26),
      ),
      child: NavigationRail(
        backgroundColor: Colors.transparent,
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelected,
        labelType: NavigationRailLabelType.none,
        groupAlignment: -0.85,
        leading: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.apps_rounded, size: 20),
          ),
        ),
        destinations: [
          for (final item in _items)
            NavigationRailDestination(
              icon: _NavIcon(icon: item.icon, isSelected: false),
              selectedIcon: _NavIcon(icon: item.icon, isSelected: true),
              label: const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }

  String _labelFor(int index) {
    return switch (index) {
      0 => 'Home',
      1 => 'Overview',
      2 => 'Transactions',
      3 => 'Cards',
      4 => 'Rewards',
      _ => 'Docs',
    };
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.icon, required this.isSelected});

  final IconData icon;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Colors.black : Colors.black.withOpacity(0.55);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isSelected
            ? const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon);

  final IconData icon;
}

