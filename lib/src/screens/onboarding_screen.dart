import 'package:flutter/material.dart';

import '../controller.dart';
import '../app_identity.dart';
import '../formatters.dart';
import '../models.dart';
import '../widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.controller});

  final MisFinController controller;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _savingsController = TextEditingController();
  late final Set<String> _selectedBanks;
  late IncomeFrequency _frequency;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _incomeController.text = widget.controller.profile.incomePerPeriod == 0
        ? ''
        : widget.controller.profile.incomePerPeriod.round().toString();
    _savingsController.text = widget.controller.profile.monthlySavingsGoal == 0
        ? ''
        : widget.controller.profile.monthlySavingsGoal.round().toString();
    _selectedBanks = widget.controller.profile.selectedBanks.isEmpty
        ? defaultSelectedBankNames.toSet()
        : widget.controller.profile.selectedBanks.toSet();
    _frequency = widget.controller.profile.frequency;
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _savingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      _WelcomeStep(
        currency: widget.controller.profile.currency,
        onCurrencyChanged: widget.controller.updateCurrency,
        onShowPreview: () => _goTo(1),
      ),
      _IncomeStep(
        frequency: _frequency,
        currency: widget.controller.profile.currency,
        incomeController: _incomeController,
        savingsController: _savingsController,
        monthlyIncome: _monthlyIncome,
        monthlySavingsGoal: _monthlySavingsGoal,
        onFrequencyChanged: (value) => setState(() => _frequency = value),
        onChanged: () => setState(() {}),
      ),
      _BanksStep(
        selectedBanks: _selectedBanks,
        onToggleBank: (bank) {
          setState(() {
            if (_selectedBanks.contains(bank)) {
              _selectedBanks.remove(bank);
            } else {
              _selectedBanks.add(bank);
            }
          });
        },
      ),
      _AutomationStep(
        name: fixedUserName,
        currency: widget.controller.profile.currency,
        monthlyIncome: _monthlyIncome,
        monthlySavingsGoal: _monthlySavingsGoal,
        monthlyBudget: _monthlyBudget,
        selectedBanks: _selectedBanks,
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF09050E),
              Color(0xFF2A103F),
              Color(0xFF5F1A7A),
              Color(0xFF0A0910)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -44,
              right: -18,
              child: _MoodBlob(color: Color(0x55FFF7FF), size: 180),
            ),
            const Positioned(
              top: 180,
              left: -54,
              child: _MoodBlob(color: Color(0x44FFF2A8), size: 200),
            ),
            const Positioned(
              bottom: 70,
              right: -30,
              child: _MoodBlob(color: Color(0x44FFFFFF), size: 190),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
                child: Column(
                  children: [
                    _OnboardingHeader(index: _index, total: steps.length),
                    const SizedBox(height: 18),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 320),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                layoutBuilder:
                                    (currentChild, previousChildren) {
                                  return currentChild ??
                                      const SizedBox.shrink();
                                },
                                transitionBuilder: (child, animation) {
                                  final slide = Tween<Offset>(
                                    begin: const Offset(0.04, 0.02),
                                    end: Offset.zero,
                                  ).animate(animation);
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                        position: slide, child: child),
                                  );
                                },
                                child: KeyedSubtree(
                                  key: ValueKey(_index),
                                  child: FadeSlideIn(
                                    child: steps[_index],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        if (_index > 0)
                          OutlinedButton(
                            onPressed: () => _goTo(_index - 1),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                  color: Colors.white.withOpacity(0.7)),
                            ),
                            child: const Text('Atras'),
                          ),
                        const Spacer(),
                        FilledButton(
                          onPressed: _canAdvance
                              ? (_index < steps.length - 1
                                  ? () => _goTo(_index + 1)
                                  : _finish)
                              : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF7B42D8),
                          ),
                          child: Text(_index < steps.length - 1
                              ? 'Continuar'
                              : 'Entrar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goTo(int nextIndex) {
    setState(() => _index = nextIndex);
  }

  Future<void> _finish() async {
    final income =
        double.tryParse(_incomeController.text.replaceAll(',', '')) ?? 0;
    final savings =
        double.tryParse(_savingsController.text.replaceAll(',', '')) ?? 0;
    await widget.controller.completeOnboarding(
      name: fixedUserName,
      frequency: _frequency,
      incomePerPeriod: income,
      monthlySavingsGoal: savings,
      selectedBanks: _selectedBanks.toList(),
    );
  }

  double get _incomePerPeriod =>
      double.tryParse(_incomeController.text.replaceAll(',', '')) ?? 0;
  double get _monthlyIncome => _incomePerPeriod * _frequency.monthlyMultiplier;
  double get _monthlySavingsGoal =>
      double.tryParse(_savingsController.text.replaceAll(',', '')) ?? 0;
  double get _monthlyBudget => (_monthlyIncome - _monthlySavingsGoal)
      .clamp(0, double.infinity)
      .toDouble();
  bool get _hasImpossibleSavingsGoal =>
      _monthlyIncome > 0 && _monthlySavingsGoal > _monthlyIncome;
  bool get _canAdvance => _index == 1 ? !_hasImpossibleSavingsGoal : true;
}

class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader({required this.index, required this.total});

  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 390;
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 14 : 16,
            vertical: compact ? 12 : 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.22),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configuracion inicial',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontSize: compact ? 16 : null,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Paso ${index + 1} de $total',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: compact ? 13 : null,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: compact ? 8 : 12),
              AnimatedAnimalSticker(
                emoji: '🦉',
                size: compact ? 48 : 54,
                backgroundColor: const Color(0x66FFFFFF),
              ),
              SizedBox(width: compact ? 8 : 12),
              SizedBox(
                width: compact ? 82 : 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: (index + 1) / total,
                    minHeight: compact ? 8 : 10,
                    backgroundColor: Colors.white.withOpacity(0.22),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({
    required this.currency,
    required this.onCurrencyChanged,
    required this.onShowPreview,
  });

  final AppCurrency currency;
  final ValueChanged<AppCurrency> onCurrencyChanged;
  final VoidCallback onShowPreview;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hola, Cindy',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 10),
          Text(
            'Vamos a dejar tu espacio bonito, simple y listo para acompañarte cada vez que registres un gasto.',
            style: TextStyle(color: Colors.grey.shade800, fontSize: 16),
          ),
          const SizedBox(height: 18),
          const _OwlGuideIllustration(),
          const SizedBox(height: 18),
          Text('Divisa inicial', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: AppCurrency.values.map((item) {
              final selected = item == currency;
              return AnimatedScale(
                duration: const Duration(milliseconds: 180),
                scale: selected ? 1.04 : 1.0,
                child: ChoiceChip(
                  label: Text('${item.shortLabel} · ${item.label}'),
                  selected: selected,
                  onSelected: (_) => onCurrencyChanged(item),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: onShowPreview,
              child: const Text('Empezar la configuracion'),
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomeStep extends StatelessWidget {
  const _IncomeStep({
    required this.frequency,
    required this.currency,
    required this.incomeController,
    required this.savingsController,
    required this.monthlyIncome,
    required this.monthlySavingsGoal,
    required this.onFrequencyChanged,
    required this.onChanged,
  });

  final IncomeFrequency frequency;
  final AppCurrency currency;
  final TextEditingController incomeController;
  final TextEditingController savingsController;
  final double monthlyIncome;
  final double monthlySavingsGoal;
  final ValueChanged<IncomeFrequency> onFrequencyChanged;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tu ingreso', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          const Row(
            children: [
              AnimatedAnimalSticker(
                emoji: '🦉',
                size: 54,
                backgroundColor: Color(0xFFE8D9FF),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Cuéntame tu ritmo de pago para calcular un límite mensual realista.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            children: IncomeFrequency.values
                .map(
                  (item) => AnimatedScale(
                    duration: const Duration(milliseconds: 180),
                    scale: frequency == item ? 1.04 : 1.0,
                    child: ChoiceChip(
                      label: Text(item.label),
                      selected: frequency == item,
                      onSelected: (_) => onFrequencyChanged(item),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: incomeController,
            keyboardType: TextInputType.number,
            onChanged: (_) => onChanged(),
            decoration: InputDecoration(
              labelText: 'Cuanto ganas ${frequency.gainsPrompt}',
              prefixText: '${currency.symbol} ',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: savingsController,
            keyboardType: TextInputType.number,
            onChanged: (_) => onChanged(),
            decoration: InputDecoration(
              labelText: 'Cuanto quieres ahorrar al mes',
              prefixText: '${currency.symbol} ',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFBE7FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_graph_rounded, color: Color(0xFF8B46D3)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Ingreso mensual estimado: ${formatMoney(monthlyIncome, currency)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          if (monthlyIncome > 0 && monthlySavingsGoal > monthlyIncome) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4EA),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFA3BA)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.favorite_rounded, color: Color(0xFFE15483)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ops, por el momento no es posible ahorrar esa cantidad, pero pronto lo lograras',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BanksStep extends StatelessWidget {
  const _BanksStep({
    required this.selectedBanks,
    required this.onToggleBank,
  });

  final Set<String> selectedBanks;
  final ValueChanged<String> onToggleBank;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tus bancos', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 10,
            children: [
              AnimatedEmojiBadge(emoji: '🐼', delayMs: 0),
              AnimatedEmojiBadge(emoji: '🐸', delayMs: 80),
              AnimatedEmojiBadge(emoji: '🦊', delayMs: 160),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Selecciona los bancos que mas usas para dejar la app lista. MisFin intentara leer tus gastos sola y solo te pedira ayuda si hay dudas.',
            style: TextStyle(color: Colors.grey.shade800),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: bankCatalog
                .map(
                  (bank) => AnimatedScale(
                    duration: const Duration(milliseconds: 180),
                    scale: selectedBanks.contains(bank.name) ? 1.03 : 1.0,
                    child: FilterChip(
                      label: Text(bank.name),
                      selected: selectedBanks.contains(bank.name),
                      selectedColor: Color(bank.accent).withOpacity(0.16),
                      onSelected: (_) => onToggleBank(bank.name),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _AutomationStep extends StatelessWidget {
  const _AutomationStep({
    required this.name,
    required this.currency,
    required this.monthlyIncome,
    required this.monthlySavingsGoal,
    required this.monthlyBudget,
    required this.selectedBanks,
  });

  final String name;
  final AppCurrency currency;
  final double monthlyIncome;
  final double monthlySavingsGoal;
  final double monthlyBudget;
  final Set<String> selectedBanks;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name.isEmpty ? 'Todo listo para empezar' : 'Todo listo, $name',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 360;
              return Container(
                height: compact ? 278 : 194,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFB0DE),
                      Color(0xFFC19CFF),
                      Color(0xFF8DDFFF)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 18,
                      top: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Tu equipo ya te anima',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: compact ? constraints.maxWidth - 36 : 180,
                            child: Text(
                              'Tus animalitos estaran contigo para animarte a ahorrar con calma y constancia.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: compact ? 16 : 18,
                                fontWeight: FontWeight.w800,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (compact)
                      const Positioned(
                        left: 10,
                        right: 10,
                        bottom: 10,
                        height: 68,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AnimatedAnimalSticker(
                              emoji: '🐤',
                              size: 38,
                              framed: false,
                            ),
                            AnimatedAnimalSticker(
                              emoji: '🐢',
                              size: 40,
                              framed: false,
                            ),
                            AnimatedAnimalSticker(
                              emoji: '🦊',
                              size: 42,
                              framed: false,
                            ),
                            AnimatedAnimalSticker(
                              emoji: '🐰',
                              size: 44,
                              framed: false,
                            ),
                            AnimatedAnimalSticker(
                              emoji: '🐼',
                              size: 48,
                              framed: false,
                            ),
                            AnimatedAnimalSticker(
                              emoji: '🐱',
                              size: 54,
                              framed: false,
                            ),
                          ],
                        ),
                      )
                    else ...[
                      const Positioned(
                        top: 18,
                        right: 18,
                        child: AnimatedAnimalSticker(
                          emoji: '🐱',
                          size: 84,
                          framed: false,
                        ),
                      ),
                      const Positioned(
                        top: 18,
                        right: 92,
                        child: AnimatedAnimalSticker(
                          emoji: '🐰',
                          size: 60,
                          framed: false,
                        ),
                      ),
                      const Positioned(
                        top: 86,
                        right: 114,
                        child: AnimatedAnimalSticker(
                          emoji: '🦊',
                          size: 58,
                          framed: false,
                        ),
                      ),
                      const Positioned(
                        bottom: 18,
                        right: 22,
                        child: AnimatedAnimalSticker(
                          emoji: '🐼',
                          size: 72,
                          framed: false,
                        ),
                      ),
                      const Positioned(
                        bottom: 16,
                        right: 104,
                        child: AnimatedAnimalSticker(
                          emoji: '🐢',
                          size: 56,
                          framed: false,
                        ),
                      ),
                      const Positioned(
                        bottom: 18,
                        right: 154,
                        child: AnimatedAnimalSticker(
                          emoji: '🐤',
                          size: 48,
                          framed: false,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          _SummaryRow(label: 'Ingreso mensual', value: _money(monthlyIncome)),
          _SummaryRow(
              label: 'Ahorro mensual', value: _money(monthlySavingsGoal)),
          _SummaryRow(label: 'Presupuesto', value: _money(monthlyBudget)),
          _SummaryRow(label: 'Bancos', value: selectedBanks.join(', ')),
          const SizedBox(height: 18),
          Text(
            'Desde aqui en adelante la app te ira guiando con un entorno bonito, mensajes amables y el menor numero posible de pasos.',
            style: TextStyle(color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }

  String _money(double value) {
    return formatMoney(value, currency);
  }
}

class _OwlGuideIllustration extends StatelessWidget {
  const _OwlGuideIllustration();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 390;
        return Container(
          height: compact ? 280 : 236,
          padding: const EdgeInsets.all(18),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [Color(0xFFFA8AD6), Color(0xFF8B5CFF), Color(0xFF241030)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Guia inicial',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              if (compact) ...[
                const Positioned(
                  left: 4,
                  top: 112,
                  child: AnimatedAnimalSticker(
                    emoji: '🦉',
                    size: 86,
                    framed: false,
                    backgroundColor: Color(0x55FFFFFF),
                  ),
                ),
                Positioned(
                  left: 88,
                  right: 0,
                  top: 56,
                  bottom: 14,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.82),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Te acompaño paso a paso',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                        SizedBox(height: 8),
                        Text('Elegimos tu divisa'),
                        SizedBox(height: 6),
                        Text('Calculamos tu ingreso mensual'),
                        SizedBox(height: 6),
                        Text('Y dejamos listo tu plan de ahorro'),
                      ],
                    ),
                  ),
                ),
                const Positioned(
                  top: 60,
                  left: 26,
                  child: AnimatedAnimalSticker(
                    emoji: '🐰',
                    size: 44,
                    framed: false,
                    backgroundColor: Color(0x66FFFFFF),
                  ),
                ),
              ] else ...[
                const Positioned(
                  left: 4,
                  bottom: 8,
                  child: AnimatedAnimalSticker(
                    emoji: '🦉',
                    size: 124,
                    framed: false,
                    backgroundColor: Color(0x55FFFFFF),
                  ),
                ),
                Positioned(
                  right: 0,
                  left: 108,
                  top: 48,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.78),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Te acompaño paso a paso',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                        SizedBox(height: 8),
                        Text('Elegimos tu divisa'),
                        SizedBox(height: 6),
                        Text('Calculamos tu ingreso mensual'),
                        SizedBox(height: 6),
                        Text('Y dejamos listo tu plan de ahorro'),
                      ],
                    ),
                  ),
                ),
                const Positioned(
                  right: 18,
                  bottom: 12,
                  child: AnimatedAnimalSticker(
                    emoji: '🐰',
                    size: 58,
                    framed: false,
                    backgroundColor: Color(0x66FFFFFF),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _MoodBlob extends StatelessWidget {
  const _MoodBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0)],
          stops: const [0, 1],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
