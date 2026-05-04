import 'package:flutter/material.dart';

class DashboardSummaryCards extends StatelessWidget {
  const DashboardSummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = <_SummaryCardData>[
      const _SummaryCardData(
        icon: Icons.credit_card_rounded,
        title: 'Transfer via\nCard number',
        amount: '\$1200',
      ),
      const _SummaryCardData(
        icon: Icons.swap_horiz_rounded,
        title: 'Transfer via\nOnline Banks',
        amount: '\$150',
      ),
      const _SummaryCardData(
        icon: Icons.account_balance_rounded,
        title: 'Transfer\nSame Bank',
        amount: '\$1500',
      ),
      const _SummaryCardData(
        icon: Icons.receipt_long_rounded,
        title: 'Transfer to\nOther Bank',
        amount: '\$1500',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = 16.0;
        final minCardWidth = 210.0;
        final columns =
            (constraints.maxWidth / (minCardWidth + gap)).floor().clamp(1, 4);
        final cardWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final c in cards)
              SizedBox(
                width: cardWidth,
                child: _SummaryCard(data: c),
              ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data});

  final _SummaryCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, size: 26),
          const SizedBox(height: 10),
          Text(
            data.title,
            style: TextStyle(
              color: Colors.black.withOpacity(0.45),
              height: 1.12,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data.amount,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCardData {
  const _SummaryCardData({
    required this.icon,
    required this.title,
    required this.amount,
  });

  final IconData icon;
  final String title;
  final String amount;
}

