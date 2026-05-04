import 'package:flutter/material.dart';

class DashboardRightPanel extends StatelessWidget {
  const DashboardRightPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CreditCard(),
          const SizedBox(height: 18),
          const _SectionTitle(title: 'Recent Activities', subtitle: '02 Mar 2021'),
          const SizedBox(height: 10),
          _ActivityTile(
            icon: Icons.water_drop_rounded,
            iconBg: const Color(0xFFEAEAF7),
            title: 'Water Bill',
            subtitle: 'Successfully',
            amount: '\$120',
          ),
          const SizedBox(height: 10),
          _ActivityTile(
            icon: Icons.attach_money_rounded,
            iconBg: const Color(0xFFEAF3EE),
            title: 'Income Salary',
            subtitle: 'Received',
            amount: '\$4500',
          ),
          const SizedBox(height: 10),
          _ActivityTile(
            icon: Icons.flash_on_rounded,
            iconBg: const Color(0xFFF7EEE9),
            title: 'Electric Bill',
            subtitle: 'Successfully',
            amount: '\$150',
          ),
          const SizedBox(height: 10),
          _ActivityTile(
            icon: Icons.wifi_rounded,
            iconBg: const Color(0xFFEAF4F8),
            title: 'Internet Bill',
            subtitle: 'Successfully',
            amount: '\$60',
          ),
          const SizedBox(height: 18),
          const _SectionTitle(
            title: 'Upcoming Payments',
            subtitle: '02 Mar 2021',
          ),
          const SizedBox(height: 10),
          _ActivityTile(
            icon: Icons.home_rounded,
            iconBg: const Color(0xFFECE7F7),
            title: 'Home Rent',
            subtitle: 'Pending',
            amount: '\$1500',
          ),
          const SizedBox(height: 10),
          _ActivityTile(
            icon: Icons.directions_car_rounded,
            iconBg: const Color(0xFFE8EAF5),
            title: 'Car Insurance',
            subtitle: 'Pending',
            amount: '\$350',
          ),
          const SizedBox(height: 10),
          _ActivityTile(
            icon: Icons.local_hospital_rounded,
            iconBg: const Color(0xFFF7EEE9),
            title: 'Health',
            subtitle: 'Pending',
            amount: '\$90',
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.black.withOpacity(0.35),
          ),
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Colors.black.withOpacity(0.35),
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _CreditCard extends StatelessWidget {
  const _CreditCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A2E3B),
            Color(0xFF101218),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 32,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 28,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.sim_card_rounded,
                size: 16,
                color: Colors.white70,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: SizedBox(
              width: 64,
              height: 36,
              child: Stack(
                children: [
                  Positioned(
                    right: 22,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE84D3D),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF2B138),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 38),
              const Text(
                '4562 1122 4595 7852',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              Text(
                'CARD HOLDER',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ghulam',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

