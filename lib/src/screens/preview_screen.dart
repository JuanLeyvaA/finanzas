import 'package:flutter/material.dart';

import '../controller.dart';
import '../models.dart';
import '../widgets.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key, required this.controller});

  final PresuCoController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      children: [
        FadeSlideIn(
          child: GlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Preview de la app', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Esta vista resume como se siente PresuCo: elegante, simple y enfocada en automatizar lo maximo posible en iPhone.',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        FadeSlideIn(
          delay: const Duration(milliseconds: 80),
          child: const PreviewPhoneShowcase(),
        ),
        const SizedBox(height: 14),
        FadeSlideIn(
          delay: const Duration(milliseconds: 160),
          child: Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'Bancos activos',
                  value: '${controller.profile.selectedBanks.length}',
                  subtitle: 'Seleccionados',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  title: 'Automatizacion',
                  value: controller.profile.onboardingComplete ? 'Lista' : 'Pendiente',
                  subtitle: 'Estado',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        FadeSlideIn(
          delay: const Duration(milliseconds: 220),
          child: const GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lo que muestra la preview', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                SizedBox(height: 10),
                Text('- Onboarding con look premium'),
                Text('- Dashboard con barra de presupuesto'),
                Text('- Importador de texto para banco'),
                Text('- Seleccion de bancos y guia de automatizacion'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
