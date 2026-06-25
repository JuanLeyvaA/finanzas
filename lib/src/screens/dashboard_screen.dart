import 'package:flutter/material.dart';

import '../app_identity.dart';
import '../controller.dart';
import '../currency_theme.dart';
import '../models.dart';
import '../formatters.dart';
import 'expense_editor_sheet.dart';
import '../widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.controller});

  final PresuCoController controller;

  @override
  Widget build(BuildContext context) {
    final currency = controller.profile.currency;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      children: [
        const SizedBox(height: 4),
        FadeSlideIn(
          child: AnimalSectionBanner(
            title: controller.currentMonthLabel,
            subtitle:
                '$fixedUserName, tu resumen del mes se actualiza en vivo mientras registras gastos.',
            currency: currency,
            animals: const ['🐱', '🦊', '🐼', '🐢', '🐰', '🐤'],
          ),
        ),
        const SizedBox(height: 14),
        FadeSlideIn(
          delay: const Duration(milliseconds: 40),
          child: CurrencyPickerCard(
            currency: currency,
            title: 'Divisa del entorno',
            onChanged: controller.updateCurrency,
          ),
        ),
        const SizedBox(height: 14),
        FadeSlideIn(
          delay: const Duration(milliseconds: 90),
          child: _HeroCard(controller: controller),
        ),
        const SizedBox(height: 14),
        FadeSlideIn(
          delay: const Duration(milliseconds: 150),
          child: Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'Gastado',
                  value: _money(controller.spentThisMonth, currency),
                  subtitle: 'Este mes',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  title: 'Restante',
                  value: _money(controller.remainingBudget, currency),
                  subtitle: 'Disponible',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        FadeSlideIn(
          delay: const Duration(milliseconds: 160),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gastos recientes', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                if (controller.currentMonthExpenses.isEmpty)
                  Text(
                    'Todavia no hay gastos. Usa el boton de importar o agrega uno manualmente.',
                    style: TextStyle(color: Colors.grey.shade700),
                  )
                else
                  ...controller.currentMonthExpenses.take(5).map(
                        (expense) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ExpenseTile(
                            expense: expense,
                            currency: currency,
                            onEdit: () async {
                              final result = await showModalBottomSheet<dynamic>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) {
                                  return ExpenseEditorSheet(
                                    expense: expense,
                                  );
                                },
                              );

                              if (result == 'delete') {
                                await controller.removeExpense(expense.id);
                                return;
                              }

                              if (result is Map) {
                                await controller.updateExpense(
                                  expense.id,
                                  amount: (result['amount'] as num?)?.toDouble(),
                                  note: result['note'] as String?,
                                  source: result['source'] as String?,
                                  category: result['category'] as String?,
                                  bank: result['bank'] as String?,
                                );
                              }
                            },
                            onDelete: () => controller.removeExpense(expense.id),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _money(double value, AppCurrency currency) {
    return formatMoney(value, currency);
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.controller});

  final PresuCoController controller;

  @override
  Widget build(BuildContext context) {
    final progress = controller.progress;
    final palette = paletteForCurrency(controller.profile.currency);
    final color = controller.isOverBudget
        ? const Color(0xFFD33B3B)
        : controller.shouldWarn
            ? palette.secondary
            : palette.accent;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hola, $fixedUserName', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: Text(
                        controller.statusLabel,
                        key: ValueKey(controller.statusLabel),
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                backgroundColor: color.withOpacity(0.14),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.scale(scale: 0.85 + (value * 0.15), child: child);
                  },
                  child: Icon(
                    controller.isOverBudget ? Icons.warning_rounded : Icons.auto_graph_rounded,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month_rounded, color: color),
                const SizedBox(width: 8),
                Text(
                  controller.currentMonthLabel,
                  style: TextStyle(fontWeight: FontWeight.w800, color: color),
                ),
                const Spacer(),
                Text(
                  controller.isOverBudget
                      ? 'Fuera de limite'
                      : controller.shouldWarn
                          ? 'Casi'
                          : 'Bien',
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0).toDouble(),
              minHeight: 14,
              backgroundColor: const Color(0xFFE5DFD3),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Presupuesto: ${_money(controller.monthlyBudget)}'),
              Text('Gastado: ${_money(controller.spentThisMonth)}'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            controller.statusAction,
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _MoodChip(label: 'Ahorra suave'),
              _MoodChip(label: 'Paso a paso'),
              _MoodChip(label: 'Tu puedes'),
            ],
          ),
        ],
      ),
    );
  }

  String _money(double value) {
    return formatMoney(value, controller.profile.currency);
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8F2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFBAE7D7)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({
    required this.expense,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
  });

  final ExpenseEntry expense;
  final AppCurrency currency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF9F6EF),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onEdit,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE8E0D2)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(expense.category.isNotEmpty ? expense.category[0] : '?'),
            ),
            title: Text(expense.note),
            subtitle: Text('${expense.category} • ${expense.source}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatMoney(expense.amount, currency),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  splashRadius: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
