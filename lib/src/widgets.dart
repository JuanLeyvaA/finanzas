import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'currency_theme.dart';
import 'models.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.96),
            const Color(0xFFF9EAFF).withOpacity(0.92),
            scheme.tertiary.withOpacity(0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.72)),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.08),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
          const BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          Text(value,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }
}

class CurrencyPickerCard extends StatelessWidget {
  const CurrencyPickerCard({
    super.key,
    required this.currency,
    required this.onChanged,
    this.title = 'Divisa activa',
  });

  final AppCurrency currency;
  final ValueChanged<AppCurrency> onChanged;
  final String title;

  @override
  Widget build(BuildContext context) {
    final palette = paletteForCurrency(currency);
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
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
                  selectedColor: palette.accent.withOpacity(0.18),
                  onSelected: (_) => onChanged(item),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class AnimalSectionBanner extends StatelessWidget {
  const AnimalSectionBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.currency,
    required this.animals,
  });

  final String title;
  final String subtitle;
  final AppCurrency currency;
  final List<String> animals;

  @override
  Widget build(BuildContext context) {
    final palette = paletteForCurrency(currency);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final compact = width < 430;
        final textPanelWidth = compact
            ? math.min(width * 0.58, 218.0)
            : math.min(width * 0.36, 220.0);
        return Container(
          height: compact ? 308 : 254,
          padding: const EdgeInsets.all(20),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: [
                palette.secondary.withOpacity(0.96),
                palette.accent.withOpacity(0.94),
                palette.tertiary.withOpacity(0.92),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: palette.seed.withOpacity(0.22),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -18,
                right: 12,
                child:
                    _GlowOrb(color: Colors.white.withOpacity(0.16), size: 120),
              ),
              Positioned(
                left: -12,
                bottom: -28,
                child:
                    _GlowOrb(color: Colors.white.withOpacity(0.12), size: 110),
              ),
              Positioned.fill(
                child: _AnimalTrail(
                  animals: animals,
                  palette: palette,
                  reservedTextWidth: textPanelWidth,
                  compactBanner: compact,
                ),
              ),
              SizedBox(
                width: textPanelWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.26)),
                          ),
                          child: Text(
                            currency.shortLabel,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 24 : 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.7,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.97),
                        fontSize: compact ? 13.5 : 15,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AnimatedAnimalSticker extends StatefulWidget {
  const AnimatedAnimalSticker({
    super.key,
    required this.emoji,
    this.delayMs = 0,
    this.size = 64,
    this.framed = true,
    this.backgroundColor,
    this.highlightColor,
  });

  final String emoji;
  final int delayMs;
  final double size;
  final bool framed;
  final Color? backgroundColor;
  final Color? highlightColor;

  @override
  State<AnimatedAnimalSticker> createState() => _AnimatedAnimalStickerState();
}

class _AnimatedAnimalStickerState extends State<AnimatedAnimalSticker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1700 + widget.delayMs),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.delayMs > 0) {
        await Future<void>.delayed(Duration(milliseconds: widget.delayMs));
      }
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.backgroundColor ??
        Theme.of(context).colorScheme.primary.withOpacity(0.18);
    final highlightColor =
        widget.highlightColor ?? Colors.white.withOpacity(0.92);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle = math.sin(_controller.value * math.pi * 2) * 0.04;
        final dy = math.sin(_controller.value * math.pi * 2) * 6;
        final dx = math.cos(_controller.value * math.pi * 2) * 2;
        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.rotate(angle: angle, child: child),
        );
      },
      child: widget.framed
          ? Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [highlightColor, baseColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(widget.size * 0.3),
                border: Border.all(
                    color: Colors.white.withOpacity(0.82), width: 1.4),
                boxShadow: [
                  BoxShadow(
                    color: baseColor.withOpacity(0.34),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: widget.size * 0.1,
                    right: widget.size * 0.1,
                    child: Container(
                      width: widget.size * 0.12,
                      height: widget.size * 0.12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.55),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      widget.emoji,
                      style: TextStyle(fontSize: widget.size * 0.58),
                    ),
                  ),
                ],
              ),
            )
          : SizedBox(
              width: widget.size,
              height: widget.size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: widget.size * 0.78,
                    height: widget.size * 0.78,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          baseColor.withOpacity(0.62),
                          baseColor.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    widget.emoji,
                    style: TextStyle(
                      fontSize: widget.size * 0.78,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class AnimatedEmojiBadge extends StatelessWidget {
  const AnimatedEmojiBadge({
    super.key,
    required this.emoji,
    this.delayMs = 0,
  });

  final String emoji;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    return AnimatedAnimalSticker(
      emoji: emoji,
      delayMs: delayMs,
      size: 62,
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      highlightColor: Colors.white.withOpacity(0.88),
    );
  }
}

class _AnimalTrail extends StatelessWidget {
  const _AnimalTrail({
    required this.animals,
    required this.palette,
    required this.reservedTextWidth,
    required this.compactBanner,
  });

  final List<String> animals;
  final CurrencyPalette palette;
  final double reservedTextWidth;
  final bool compactBanner;

  @override
  Widget build(BuildContext context) {
    final visibleAnimals = animals.isEmpty ? ['🐱'] : animals;
    final backgrounds = [
      palette.secondary.withOpacity(0.42),
      palette.tertiary.withOpacity(0.45),
      Colors.white.withOpacity(0.55),
      palette.seed.withOpacity(0.28),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final rightStart = math.min(width - 66, reservedTextWidth + 12);
        final rightWidth = math.max(66.0, width - rightStart);
        final points = <({double centerX, double top, double size})>[
          if (compactBanner) ...[
            (centerX: rightStart + rightWidth * 0.32, top: 10, size: 62),
            (centerX: rightStart + rightWidth * 0.74, top: 84, size: 68),
            (centerX: rightStart + rightWidth * 0.30, top: 154, size: 56),
            (centerX: width * 0.10, top: 212, size: 46),
            (centerX: width * 0.34, top: 204, size: 54),
            (centerX: width * 0.61, top: 210, size: 50),
            (centerX: width * 0.87, top: 202, size: 58),
          ] else ...[
            (centerX: rightStart + rightWidth * 0.08, top: 24, size: 48),
            (centerX: rightStart + rightWidth * 0.20, top: 104, size: 56),
            (centerX: rightStart + rightWidth * 0.34, top: 28, size: 66),
            (centerX: rightStart + rightWidth * 0.48, top: 112, size: 62),
            (centerX: rightStart + rightWidth * 0.61, top: 16, size: 74),
            (centerX: rightStart + rightWidth * 0.74, top: 104, size: 58),
            (centerX: rightStart + rightWidth * 0.86, top: 26, size: 66),
            (centerX: rightStart + rightWidth * 0.96, top: 106, size: 62),
          ],
        ];

        return Stack(
          clipBehavior: Clip.none,
          children: [
            if (!compactBanner)
              Positioned(
                top: 28,
                left: width * 0.34,
                child:
                    _GlowOrb(color: Colors.white.withOpacity(0.12), size: 120),
              ),
            if (!compactBanner)
              Positioned(
                top: 102,
                left: width * 0.76,
                child: _GlowOrb(color: Colors.white.withOpacity(0.1), size: 82),
              ),
            for (var i = 0; i < points.length; i++)
              Positioned(
                left:
                    _clampAnimalLeft(points[i].centerX, points[i].size, width),
                top: points[i].top,
                child: AnimatedAnimalSticker(
                  emoji: visibleAnimals[i % visibleAnimals.length],
                  delayMs: 120 * i,
                  size: points[i].size,
                  framed: false,
                  backgroundColor: backgrounds[i % backgrounds.length],
                  highlightColor: Colors.white.withOpacity(0.92),
                ),
              ),
          ],
        );
      },
    );
  }
}

double _clampAnimalLeft(double centerX, double size, double width) {
  final maxLeft = math.max(0, width - size);
  final rawLeft = centerX - (size / 2);
  return rawLeft.clamp(0, maxLeft).toDouble();
}

class SavingsIllustration extends StatelessWidget {
  const SavingsIllustration({
    super.key,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.secondaryColor,
  });

  final String title;
  final String subtitle;
  final Color accentColor;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            accentColor.withOpacity(0.95),
            secondaryColor.withOpacity(0.92),
            const Color(0xFFFFE9B8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.22),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: _GlowOrb(color: Colors.white.withOpacity(0.24), size: 120),
          ),
          Positioned(
            left: -18,
            bottom: -24,
            child: _GlowOrb(color: Colors.white.withOpacity(0.16), size: 110),
          ),
          Positioned(
            right: 20,
            top: 20,
            child: Icon(Icons.auto_awesome,
                color: Colors.white.withOpacity(0.95), size: 30),
          ),
          Positioned(
            left: 18,
            top: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withOpacity(0.22)),
              ),
              child: const Text(
                'Ahorra con estilo',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 72,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.7,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: 15,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 18,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                BobbingCoin(
                  icon: Icons.savings,
                  background: Colors.white.withOpacity(0.26),
                ),
                const SizedBox(width: 10),
                BobbingCoin(
                  icon: Icons.trending_up_rounded,
                  background: Colors.white.withOpacity(0.18),
                ),
                const SizedBox(width: 10),
                BobbingCoin(
                  icon: Icons.star_rounded,
                  background: Colors.white.withOpacity(0.22),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BobbingCoin extends StatefulWidget {
  const BobbingCoin({super.key, required this.icon, required this.background});

  final IconData icon;
  final Color background;

  @override
  State<BobbingCoin> createState() => _BobbingCoinState();
}

class _BobbingCoinState extends State<BobbingCoin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final y = -math.sin(_controller.value * math.pi) * 4;
        return Transform.translate(
          offset: Offset(0, y),
          child: child,
        );
      },
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: widget.background,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        child: Icon(widget.icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 0.08),
  });

  final Widget child;
  final Duration delay;
  final Offset offset;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.delay != Duration.zero) {
        await Future<void>.delayed(widget.delay);
      }
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 450),
      opacity: _visible ? 1 : 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        offset: _visible ? Offset.zero : widget.offset,
        child: widget.child,
      ),
    );
  }
}

class PreviewPhoneShowcase extends StatelessWidget {
  const PreviewPhoneShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 560,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          _PhoneFrame(
            title: 'Inicio',
            child: _PreviewDashboardMock(),
          ),
          SizedBox(width: 14),
          _PhoneFrame(
            title: 'Importar',
            child: _PreviewImportMock(),
          ),
          SizedBox(width: 14),
          _PhoneFrame(
            title: 'Bancos',
            child: _PreviewBanksMock(),
          ),
        ],
      ),
    );
  }
}

class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(36),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCF8),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 100,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  const Spacer(),
                  const Icon(Icons.battery_full, size: 16),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _PreviewDashboardMock extends StatelessWidget {
  const _PreviewDashboardMock();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Gastado este mes', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFFE7E1D5),
              borderRadius: BorderRadius.circular(99),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.72,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1F8F6A), Color(0xFFFFA726)],
                  ),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const _MiniCard(title: 'Presupuesto', value: '\$1.250.000'),
          const SizedBox(height: 10),
          const _MiniCard(title: 'Restante', value: '\$325.000'),
          const SizedBox(height: 14),
          const Text('Ultimos gastos',
              style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          const _MiniTile(title: 'Mercado', subtitle: 'Compra con tarjeta'),
          const _MiniTile(title: 'Cafe', subtitle: 'Efectivo'),
          const _MiniTile(title: 'Uber', subtitle: 'Notificacion importada'),
        ],
      ),
    );
  }
}

class _PreviewImportMock extends StatelessWidget {
  const _PreviewImportMock();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pegar texto',
              style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Container(
            height: 160,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F0E3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE0D2BC)),
            ),
            child: const Text(
              'Bancolombia aprobó compra por \$45.000 en MERCADO MAYORISTA.',
              style: TextStyle(height: 1.4),
            ),
          ),
          const SizedBox(height: 12),
          const _MiniCard(title: 'Banco', value: 'Bancolombia'),
          const SizedBox(height: 10),
          const _MiniCard(title: 'Monto', value: '\$45.000'),
          const SizedBox(height: 10),
          const _MiniCard(title: 'Categoria', value: 'Compra'),
        ],
      ),
    );
  }
}

class _PreviewBanksMock extends StatelessWidget {
  const _PreviewBanksMock();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _MiniBankCard(name: 'Bancolombia', active: true),
          SizedBox(height: 10),
          _MiniBankCard(name: 'Nu', active: true),
          SizedBox(height: 10),
          _MiniBankCard(name: 'Nequi', active: true),
          SizedBox(height: 10),
          _MiniBankCard(name: 'Davivienda', active: true),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E0D2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade700)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _MiniTile extends StatelessWidget {
  const _MiniTile({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F4EC),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const CircleAvatar(
                radius: 18, child: Icon(Icons.receipt_long, size: 16)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  Text(subtitle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBankCard extends StatelessWidget {
  const _MiniBankCard({required this.name, required this.active});

  final String name;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E0D2)),
      ),
      child: Row(
        children: [
          CircleAvatar(child: Text(name.isNotEmpty ? name[0] : '?')),
          const SizedBox(width: 12),
          Expanded(
            child:
                Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          Switch(value: active, onChanged: null),
        ],
      ),
    );
  }
}
