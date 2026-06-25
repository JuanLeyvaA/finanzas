import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controller.dart';
import '../formatters.dart';
import '../models.dart';
import '../month_utils.dart';
import '../widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.controller});

  final PresuCoController controller;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? _selectedMonthKey;

  @override
  void initState() {
    super.initState();
    _selectedMonthKey = widget.controller.currentMonthKey;
  }

  @override
  Widget build(BuildContext context) {
    final history = widget.controller.orderedHistory;
    final currency = widget.controller.profile.currency;
    final selectedKey = _selectedMonthKey ?? widget.controller.currentMonthKey;
    final selectedSummary = history.firstWhere(
      (item) => item.monthKey == selectedKey,
      orElse: () => widget.controller.currentMonthSummary,
    );
    final selectedExpenses = widget.controller.expensesForMonth(selectedSummary.monthKey);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      children: [
        FadeSlideIn(
          child: AnimalSectionBanner(
            title: 'Historial mensual',
            subtitle:
                'Aqui mira como ha ido tu historial de gastos respecto a tu idea de ahorro.',
            currency: currency,
            animals: const ['🦉', '🐻', '🐸', '🐧', '🐱', '🐤'],
          ),
        ),
        const SizedBox(height: 14),
        FadeSlideIn(
          delay: const Duration(milliseconds: 80),
          child: GlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Evolucion', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                Text(
                  'Mira el comportamiento de cada mes y toca un bloque para ver el detalle completo.',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 18),
                MonthlyEvolutionChart(history: history, currency: currency),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (history.isEmpty)
          FadeSlideIn(
            delay: const Duration(milliseconds: 140),
            child: GlassCard(
              child: Text(
                'Todavia no hay historial suficiente. Cuando pase el tiempo y vayas agregando gastos, aqui apareceran tus meses anteriores.',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
          )
        else
          ...history.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _HistoryMonthCard(
                    summary: entry.value,
                    currency: currency,
                    selected: selectedSummary.monthKey == entry.value.monthKey,
                    onTap: () => setState(() => _selectedMonthKey = entry.value.monthKey),
                    onOpen: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return _MonthDetailsSheet(
                          summary: entry.value,
                          expenses: widget.controller.expensesForMonth(entry.value.monthKey),
                          currency: currency,
                        );
                      },
                    ),
                  ),
                ),
              ),
        const SizedBox(height: 14),
        FadeSlideIn(
          delay: const Duration(milliseconds: 160),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(monthLabelOf(selectedSummary.monthKey), style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                _DetailRow(label: 'Gastado', value: formatMoney(selectedSummary.spent, currency)),
                _DetailRow(label: 'Presupuesto', value: formatMoney(selectedSummary.budget, currency)),
                _DetailRow(label: 'Restante', value: formatMoney(selectedSummary.remaining, currency)),
                _DetailRow(label: 'Gastos', value: '${selectedSummary.expenseCount}'),
                const SizedBox(height: 12),
                if (selectedExpenses.isNotEmpty)
                  Column(
                    children: selectedExpenses.take(4).map(
                      (expense) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _HistoryExpenseTile(expense: expense, currency: currency),
                        );
                      },
                    ).toList(),
                  )
                else
                  Text(
                    'Este mes aun no tiene gastos. Cuando agregues mas movimientos, el historial se va llenando solo.',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryMonthCard extends StatelessWidget {
  const _HistoryMonthCard({
    required this.summary,
    required this.currency,
    required this.selected,
    required this.onTap,
    required this.onOpen,
  });

  final MonthlySummary summary;
  final AppCurrency currency;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final cardColor = summary.overBudget
        ? const Color(0xFFFF8A80)
        : summary.nearBudget
            ? const Color(0xFFFFC857)
            : const Color(0xFF7EE2B8);

    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      scale: selected ? 1.01 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        onDoubleTap: onOpen,
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(color: cardColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    summary.name,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onOpen,
                    icon: const Icon(Icons.open_in_new_rounded),
                    splashRadius: 20,
                  ),
                  if (selected) const Icon(Icons.check_circle_rounded, color: Color(0xFF1F8F6A)),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: summary.progress.clamp(0.0, 1.15).toDouble(),
                  minHeight: 12,
                  backgroundColor: const Color(0xFFE9E2D5),
                  valueColor: AlwaysStoppedAnimation<Color>(cardColor),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${formatMoney(summary.spent, currency)} gastados',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    summary.overBudget ? 'Pasado' : summary.nearBudget ? 'Casi' : 'Bien',
                    style: TextStyle(color: cardColor == const Color(0xFFFFC857) ? const Color(0xFF996A00) : Colors.grey.shade700),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${summary.expenseCount} movimientos en este mes',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MonthlyEvolutionChart extends StatelessWidget {
  const MonthlyEvolutionChart({super.key, required this.history, required this.currency});

  final List<MonthlySummary> history;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: const Color(0xFFF6F1E6),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            'Aun no hay datos suficientes para graficar.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ),
      );
    }

    final data = [...history]..sort((a, b) => a.monthKey.compareTo(b.monthKey));
    var maxBudget = 0.0;
    for (final item in data) {
      maxBudget = math.max(maxBudget, math.max(item.budget, item.spent).toDouble());
    }
    final axisMarks = <double>[
      maxBudget,
      maxBudget * 0.75,
      maxBudget * 0.5,
      maxBudget * 0.25,
      0,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFCF8), Color(0xFFF3FBF7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0x1F3A3A3A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _LegendDot(color: Color(0xFF1F8F6A)),
              const SizedBox(width: 6),
              Text('Presupuesto', style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w700)),
              const SizedBox(width: 14),
              const _LegendDot(color: Color(0xFFF28C28)),
              const SizedBox(width: 6),
              Text('Gastado', style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 88,
                height: 240,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: axisMarks
                      .map(
                        (value) => Text(
                          formatMoney(value, currency),
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 240,
                  child: CustomPaint(
                    painter: _EvolutionPainter(
                      data: data,
                      currency: currency,
                      maxValue: maxBudget == 0 ? 1.0 : maxBudget,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: data
                            .map(
                              (entry) => Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      monthShortLabelOf(entry.monthKey),
                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _EvolutionPainter extends CustomPainter {
  _EvolutionPainter({required this.data, required this.currency, required this.maxValue});

  final List<MonthlySummary> data;
  final AppCurrency currency;
  final double maxValue;

  @override
  void paint(Canvas canvas, Size size) {
    final paddingLeft = 12.0;
    final paddingRight = 12.0;
    final plotTop = 12.0;
    final plotBottom = 44.0;
    final plotHeight = size.height - plotTop - plotBottom;
    final plotWidth = size.width - paddingLeft - paddingRight;
    final barWidth = plotWidth / math.max(data.length * 2, 1);

    final gridPaint = Paint()
      ..color = const Color(0x22000000)
      ..strokeWidth = 1;

    for (var i = 0; i < 4; i++) {
      final y = plotTop + (plotHeight / 3) * i;
      canvas.drawLine(Offset(paddingLeft, y), Offset(size.width - paddingRight, y), gridPaint);
    }

    for (var i = 0; i < data.length; i++) {
      final summary = data[i];
      final xCenter = paddingLeft + (i * (plotWidth / data.length)) + (plotWidth / data.length) / 2;
      final budgetHeight = (summary.budget / maxValue) * plotHeight;
      final spentHeight = (summary.spent / maxValue) * plotHeight;
      final budgetRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(xCenter - barWidth - 4, plotTop + plotHeight - budgetHeight, barWidth, budgetHeight),
        const Radius.circular(20),
      );
      final spentRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(xCenter + 4, plotTop + plotHeight - spentHeight, barWidth, spentHeight),
        const Radius.circular(20),
      );

      final budgetPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF7EE2B8), Color(0xFF1F8F6A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(budgetRect.outerRect);

      final spentPaint = Paint()
        ..shader = LinearGradient(
          colors: summary.overBudget
              ? [const Color(0xFFFFB08D), const Color(0xFFD64545)]
              : summary.nearBudget
                  ? [const Color(0xFFFFE08A), const Color(0xFFF28C28)]
                  : [const Color(0xFFB3A6FF), const Color(0xFF6A1BFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(spentRect.outerRect);

      canvas.drawRRect(budgetRect, budgetPaint);
      canvas.drawRRect(spentRect, spentPaint);

      _paintBarLabel(
        canvas,
        budgetRect.outerRect,
        formatMoney(summary.budget, currency),
        const Color(0xFF1F8F6A),
      );
      _paintBarLabel(
        canvas,
        spentRect.outerRect,
        formatMoney(summary.spent, currency),
        summary.overBudget
            ? const Color(0xFFD64545)
            : summary.nearBudget
                ? const Color(0xFFF28C28)
                : const Color(0xFF6A1BFF),
      );
    }
  }

  void _paintBarLabel(Canvas canvas, Rect rect, String label, Color tint) {
    if (rect.height < 18) {
      return;
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          shadows: [
            Shadow(color: Color(0x99000000), blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: rect.width - 8);

    final labelWidth = math.min(rect.width - 4, textPainter.width + 12).toDouble();
    final labelHeight = (textPainter.height + 8).toDouble();
    final left = rect.left + (rect.width - labelWidth) / 2;
    final top = rect.top + math.min(8.0, (rect.height - labelHeight) / 2).clamp(4.0, 12.0).toDouble();
    final pillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, labelWidth, labelHeight),
      const Radius.circular(999),
    );

    canvas.drawRRect(
      pillRect,
      Paint()..color = tint.withOpacity(0.25),
    );
    textPainter.paint(canvas, Offset(left + 6, top + 4));
  }

  @override
  bool shouldRepaint(covariant _EvolutionPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.maxValue != maxValue || oldDelegate.currency != currency;
  }
}

class _HistoryExpenseTile extends StatelessWidget {
  const _HistoryExpenseTile({required this.expense, required this.currency});

  final ExpenseEntry expense;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F4EA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9DEC9)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Text(expense.category.isNotEmpty ? expense.category[0] : '?'),
        ),
        title: Text(expense.note),
        subtitle: Text(expense.source),
        trailing: Text(
          formatMoney(expense.amount, currency),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(value),
        ],
      ),
    );
  }
}

class _MonthDetailsSheet extends StatelessWidget {
  const _MonthDetailsSheet({
    required this.summary,
    required this.expenses,
    required this.currency,
  });

  final MonthlySummary summary;
  final List<ExpenseEntry> expenses;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFCF8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: DraggableScrollableSheet(
          initialChildSize: 0.86,
          minChildSize: 0.6,
          maxChildSize: 0.96,
          expand: false,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Row(
                  children: [
                    Text(summary.name, style: Theme.of(context).textTheme.titleLarge),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SavingsIllustration(
                  title: formatMoney(summary.spent, currency),
                  subtitle: summary.overBudget
                      ? 'Este mes te pasaste, pero ya puedes ver como se movio todo.'
                      : 'Resumen completo del mes con todos tus movimientos.',
                  accentColor: const Color(0xFF1F8F6A),
                  secondaryColor: const Color(0xFFFF8C42),
                ),
                const SizedBox(height: 14),
                GlassCard(
                  child: Column(
                    children: [
                      _DetailRow(label: 'Gastos', value: '${summary.expenseCount}'),
                      _DetailRow(label: 'Ingresos', value: formatMoney(summary.income, currency)),
                      _DetailRow(label: 'Ahorro', value: formatMoney(summary.savingsGoal, currency)),
                      _DetailRow(label: 'Presupuesto', value: formatMoney(summary.budget, currency)),
                      _DetailRow(label: 'Restante', value: formatMoney(summary.remaining, currency)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text('Movimientos del mes', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                ...expenses.map((expense) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _HistoryExpenseTile(expense: expense, currency: currency),
                )),
              ],
            );
          },
        ),
      ),
    );
  }
}
