import 'package:flutter/material.dart';

import '../controller.dart';
import '../formatters.dart';
import '../widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final MisFinController controller;

  @override
  Widget build(BuildContext context) {
    final currency = controller.profile.currency;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      children: [
        FadeSlideIn(
          child: AnimalSectionBanner(
            title: 'Ajustes',
            subtitle:
                'Control local, respaldo y edicion rapida del entorno, la divisa y tus datos.',
            currency: currency,
            animals: const ['🐼', '🦄', '🐯', '🐨', '🐰', '🐤'],
          ),
        ),
        const SizedBox(height: 14),
        FadeSlideIn(
          delay: const Duration(milliseconds: 40),
          child: CurrencyPickerCard(
            currency: currency,
            onChanged: controller.updateCurrency,
          ),
        ),
        const SizedBox(height: 14),
        FadeSlideIn(
          delay: const Duration(milliseconds: 80),
          child: GlassCard(
            child: Column(
              children: [
                _SettingRow(
                    label: 'Frecuencia',
                    value: controller.profile.frequency.label),
                _SettingRow(label: 'Divisa', value: currency.label),
                _SettingRow(
                    label: 'Ingreso por periodo',
                    value: formatMoney(
                        controller.profile.incomePerPeriod, currency)),
                _SettingRow(
                    label: 'Ahorro mensual',
                    value: formatMoney(
                        controller.profile.monthlySavingsGoal, currency)),
                _SettingRow(
                    label: 'Presupuesto',
                    value: formatMoney(
                        controller.profile.monthlyBudget, currency)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.tonal(
          onPressed: controller.beginOnboarding,
          child: const Text('Modificar datos'),
        ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
