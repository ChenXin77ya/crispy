import 'package:flutter/material.dart';

class DashboardBalanceSection extends StatelessWidget {
  const DashboardBalanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
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
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Balance',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7B8296),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '\$1500',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Past 30 DAYS',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.35),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _BalanceChart(),
        ],
      ),
    );
  }
}

class _BalanceChart extends StatelessWidget {
  const _BalanceChart();

  @override
  Widget build(BuildContext context) {
    const values = [
      0.20,
      0.35,
      0.50,
      0.90,
      0.60,
      0.42,
      0.28,
      0.22,
      0.75,
      0.88,
      0.70,
      0.62,
    ];

    final maxHeight = 150.0;

    return Column(
      children: [
        SizedBox(
          height: maxHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final v in values)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: _Bar(
                      height: maxHeight * v,
                      isEmphasis: v >= 0.8,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: const [
            _XLabel('JAN'),
            _XLabel('FEB'),
            _XLabel('MAR'),
            _XLabel('APR'),
            _XLabel('MAY'),
            _XLabel('JUN'),
            _XLabel('JUL'),
            _XLabel('AUG'),
            _XLabel('SEP'),
            _XLabel('OCT'),
            _XLabel('NOV'),
            _XLabel('DEC'),
          ],
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.height, required this.isEmphasis});

  final double height;
  final bool isEmphasis;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      height: height,
      decoration: BoxDecoration(
        color: isEmphasis ? Colors.black : const Color(0xFFE7EAF3),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class _XLabel extends StatelessWidget {
  const _XLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.black.withOpacity(0.32),
        ),
      ),
    );
  }
}

