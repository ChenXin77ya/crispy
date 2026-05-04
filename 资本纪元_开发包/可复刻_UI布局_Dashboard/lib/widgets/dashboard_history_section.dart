import 'package:flutter/material.dart';

class DashboardHistorySection extends StatelessWidget {
  const DashboardHistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0E000000),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Transaction of last 6 months',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.35),
            ),
          ),
          const SizedBox(height: 14),
          _HistoryRow(
            leading: _Avatar(
              bg: const Color(0xFFE8EAF5),
              icon: Icons.directions_car_rounded,
              iconColor: const Color(0xFF5A5F74),
            ),
            title: 'Car Insurance',
            time: '10:42:23 AM',
            amount: '\$350.00',
            status: 'Completed',
          ),
          const SizedBox(height: 10),
          _HistoryRow(
            leading: _Avatar(
              bg: const Color(0xFFECE7F7),
              icon: Icons.home_work_rounded,
              iconColor: const Color(0xFF6E4FB7),
            ),
            title: 'Loan',
            time: '12:42:00 PM',
            amount: '\$1200.00',
            status: 'Completed',
          ),
          const SizedBox(height: 10),
          _HistoryRow(
            leading: _Avatar(
              bg: const Color(0xFFE7F1F7),
              icon: Icons.payments_rounded,
              iconColor: const Color(0xFF1F6E97),
            ),
            title: 'Online Payment',
            time: '10:42:23 PM',
            amount: '\$154.00',
            status: 'Completed',
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.leading,
    required this.title,
    required this.time,
    required this.amount,
    required this.status,
  });

  final Widget leading;
  final String title;
  final String time;
  final String amount;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              time,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black.withOpacity(0.35),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              amount,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.bg,
    required this.icon,
    required this.iconColor,
  });

  final Color bg;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }
}

