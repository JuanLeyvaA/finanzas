import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_identity.dart';
import '../controller.dart';
import '../widgets.dart';

class LaunchScreen extends StatelessWidget {
  const LaunchScreen({super.key, required this.controller});

  final PresuCoController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: controller.beginOnboarding,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF08050D), Color(0xFF2A103F), Color(0xFF5C197B), Color(0xFF09060E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              const Positioned(
                top: 104,
                right: 18,
                child: AnimatedAnimalSticker(
                  emoji: '🐰',
                  size: 76,
                  backgroundColor: Color(0x66FFFFFF),
                ),
              ),
              const Positioned(
                bottom: 118,
                left: 18,
                child: AnimatedAnimalSticker(
                  emoji: '🦄',
                  size: 82,
                  backgroundColor: Color(0x66FFFFFF),
                ),
              ),
              Positioned(
                top: -32,
                right: -20,
                child: _GlowBlob(color: const Color(0xFFFFC857).withOpacity(0.35), size: 190),
              ),
              Positioned(
                top: 120,
                left: -48,
                child: _GlowBlob(color: const Color(0xFF7EE2B8).withOpacity(0.24), size: 240),
              ),
              Positioned(
                bottom: 80,
                right: -40,
                child: _GlowBlob(color: const Color(0xFFB3A6FF).withOpacity(0.22), size: 220),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
                  child: Column(
                    children: [
                      FadeSlideIn(
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1F8F6A), Color(0xFFFFA726)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1F8F6A).withOpacity(0.18),
                                    blurRadius: 18,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'P',
                                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PresuCo',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: Colors.white,
                                        ),
                                  ),
                                  Text(
                                    'Bienvenida, $fixedUserName',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: Colors.white.withOpacity(0.28)),
                              ),
                              child: const Text(
                                'Toca para seguir',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FadeSlideIn(
                                  delay: const Duration(milliseconds: 70),
                                  child: Text(
                                    'Bienvenida, $fixedUserName',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                          fontSize: 42,
                                          height: 1.02,
                                          color: Colors.white,
                                          shadows: const [
                                            Shadow(
                                              color: Color(0x55000000),
                                              blurRadius: 18,
                                              offset: Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                FadeSlideIn(
                                  delay: const Duration(milliseconds: 120),
                                  child: Text(
                                    'Una app colorida, suave y pensada para automatizar el registro de gastos con el minimo esfuerzo.',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      height: 1.35,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 22),
                                FadeSlideIn(
                                  delay: const Duration(milliseconds: 150),
                                  child: Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.68),
                                      borderRadius: BorderRadius.circular(38),
                                      border: Border.all(color: const Color(0x22FFFFFF)),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x14000000),
                                          blurRadius: 28,
                                          offset: Offset(0, 12),
                                        ),
                                      ],
                                    ),
                                    child: const AnimalGrid(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 260),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.26)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.touch_app_rounded, color: Colors.white),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Toca en cualquier parte para entrar a la configuracion',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimalGrid extends StatelessWidget {
  const AnimalGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final animals = <_AnimalData>[
      _AnimalData('🐷', const Color(0xFFE65C9A)),
      _AnimalData('🦊', const Color(0xFFF08A39)),
      _AnimalData('🐤', const Color(0xFFF4C542)),
      _AnimalData('🐱', const Color(0xFFB274FF)),
      _AnimalData('🦄', const Color(0xFF7B7CFF)),
      _AnimalData('🐶', const Color(0xFF34C76F)),
      _AnimalData('🦉', const Color(0xFF5677FF)),
      _AnimalData('🐼', const Color(0xFF4FB7E8)),
      _AnimalData('🐢', const Color(0xFF39C8AE)),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: animals.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final animal = animals[index];
        return AnimatedAnimalTile(
          emoji: animal.emoji,
          color: animal.color,
          delay: Duration(milliseconds: 35 * index),
        );
      },
    );
  }
}

class AnimatedAnimalTile extends StatefulWidget {
  const AnimatedAnimalTile({
    super.key,
    required this.emoji,
    required this.color,
    required this.delay,
  });

  final String emoji;
  final Color color;
  final Duration delay;

  @override
  State<AnimatedAnimalTile> createState() => _AnimatedAnimalTileState();
}

class _AnimatedAnimalTileState extends State<AnimatedAnimalTile> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1800 + widget.delay.inMilliseconds),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(widget.delay);
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final bounce = math.sin(t * math.pi * 2) * 5;
        final rotation = math.sin(t * math.pi * 2) * 0.03;
        return Transform.translate(
          offset: Offset(0, bounce),
          child: Transform.rotate(
            angle: rotation,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.25),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 9,
              right: 9,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.28),
                ),
              ),
            ),
            Center(
              child: Text(
                widget.emoji,
                style: const TextStyle(fontSize: 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimalData {
  const _AnimalData(this.emoji, this.color);

  final String emoji;
  final Color color;
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.color, required this.size});

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
          colors: [color, color.withOpacity(0.0)],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}
