import 'package:flutter/material.dart';

import '../controller.dart';
import '../models.dart';
import '../widgets.dart';

class BanksScreen extends StatelessWidget {
  const BanksScreen({super.key, required this.controller});

  final PresuCoController controller;

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
            final selected = controller.profile.selectedBanks.contains(bank.name);
            final tips = _bankTips(bank);
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
                            backgroundColor: Color(bank.accent).withOpacity(0.16),
                            child: Text(bank.name.isNotEmpty ? bank.name[0] : '?'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(bank.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                Text(selected ? 'Recomendaciones para llevar mejor la cuenta' : 'Activalo para ver sugerencias utiles'),
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

List<String> _bankTips(BankProfile bank) {
  switch (bank.name) {
    case 'Bancolombia':
      return const [
        'Revisa seguido tus mensajes y compras para que ningun gasto se te pase por alto.',
        'Si pagas mucho con este banco, intenta registrar cada compra el mismo dia para llevar un mejor orden.',
        'Te conviene comparar lo que gastas aqui con tu presupuesto varias veces por semana.',
      ];
    case 'Nu':
      return const [
        'Como suele mostrar compras rapido, te sirve revisar tus movimientos con frecuencia.',
        'Es buena idea anotar enseguida los pagos pequenos para que el total del mes no te sorprenda.',
        'Si usas mucho esta tarjeta, mirarla cada noche puede ayudarte a cerrar el dia con claridad.',
      ];
    case 'Nequi':
      return const [
        'Como suele usarse para gastos del dia a dia, intenta registrar compras pequenas y transferencias al momento.',
        'Te ayuda bastante separar mentalmente lo que fue antojo, transporte o compras necesarias.',
        'Mirar este banco seguido evita que los gastos rapidos se te acumulen sin notarlo.',
      ];
    case 'Davivienda':
      return const [
        'Si usas este banco para pagos importantes, revisa cada movimiento con calma antes de cerrar el dia.',
        'Te puede servir mucho registrar apenas hagas una compra para no depender de la memoria.',
        'Comparar lo gastado aqui con tu meta de ahorro te ayuda a mantener el rumbo del mes.',
      ];
    default:
      return [
        'Revisa los movimientos de ${bank.name} con frecuencia para llevar una cuenta clara.',
        'Registrar cada gasto cerca del momento de la compra te ayuda a no olvidar nada.',
        'Mirar este banco junto a tu meta de ahorro puede darte una mejor idea de como vas.',
      ];
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
