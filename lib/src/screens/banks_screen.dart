import 'package:flutter/material.dart';

import '../controller.dart';
import '../models.dart';
import '../widgets.dart';

class BanksScreen extends StatelessWidget {
  const BanksScreen({super.key, required this.controller});

  final MisFinController controller;

  @override
  Widget build(BuildContext context) {
    final currency = controller.profile.currency;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      children: [
        FadeSlideIn(
          child: AnimalSectionBanner(
            title: 'Tus bancos',
            subtitle:
                'Aqui eliges los bancos que mas usas para que llevar la cuenta se sienta mas simple.',
            currency: currency,
            animals: const ['🐶', '🐻', '🐸', '🦊', '🐼', '🐤'],
          ),
        ),
        const SizedBox(height: 14),
        ...bankCatalog.map(
          (bank) {
            final selected =
                controller.profile.selectedBanks.contains(bank.name);
            final tips = [
              bank.shortcutHint,
              bank.notificationHint,
              bank.officialHint,
            ];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FadeSlideIn(
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                Color(bank.accent).withOpacity(0.16),
                            child:
                                Text(bank.name.isNotEmpty ? bank.name[0] : '?'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(bank.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16)),
                                Text(selected
                                    ? 'Ideas simples para usarlo mejor'
                                    : 'Activalo para ver ideas utiles'),
                              ],
                            ),
                          ),
                          Switch(
                            value: selected,
                            onChanged: (_) => controller.toggleBank(bank.name),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...tips.map(
                        (tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _BankTip(text: tip),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _BankTip extends StatelessWidget {
  const _BankTip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 9,
          height: 9,
          margin: const EdgeInsets.only(top: 6),
          decoration: const BoxDecoration(
            color: Color(0xFFB26BFF),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey.shade800, height: 1.35),
          ),
        ),
      ],
    );
  }
}
