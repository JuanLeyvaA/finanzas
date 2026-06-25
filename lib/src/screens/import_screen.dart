import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controller.dart';
import '../automation_payload.dart';
import '../formatters.dart';
import '../models.dart';
import '../widgets.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key, required this.controller});

  final PresuCoController controller;

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.text = widget.controller.draft?.rawText ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryPasteClipboard());
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.controller.draft;
    final currency = widget.controller.profile.currency;
    final automationUri = draft?.rawText == null || draft!.rawText.trim().isEmpty
        ? null
        : buildAutomationUri(baseUri: Uri.base, text: draft.rawText);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      children: [
        FadeSlideIn(
          child: AnimalSectionBanner(
            title: 'Importar gasto',
            subtitle:
                'Pega una notificacion, un correo o texto compartido y PresuCo intenta registrarlo casi solo.',
            currency: currency,
            animals: const ['🐼', '🐱', '🐧', '🦁', '🐰', '🐸'],
          ),
        ),
        const SizedBox(height: 14),
        FadeSlideIn(
          child: GlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pegar texto o notificacion', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Pega aqui el mensaje del movimiento y la app intentara entender cuanto fue, de donde salio y como guardarlo mejor.',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _textController,
                  minLines: 6,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    hintText: 'Ejemplo: Bancolombia aprobó compra por \$45.000 en MERCADO...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: widget.controller.parseText,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: 180,
                      child: FilledButton(
                        onPressed: draft?.amount == null
                            ? null
                            : () async {
                                if (draft!.hasCurrencyMismatch(currency)) {
                                  final shouldContinue = await _confirmCurrencyMismatch(draft, currency);
                                  if (shouldContinue != true) {
                                    return;
                                  }
                                }
                                await widget.controller.importDraft();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Gasto guardado.')),
                                  );
                                }
                              },
                        child: Text(draft?.canAutoImport == true ? 'Guardar solo' : 'Registrar gasto'),
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: OutlinedButton(
                        onPressed: _tryPasteClipboard,
                        child: const Text('Pegar portapapeles'),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: OutlinedButton(
                        onPressed: () {
                          _textController.clear();
                          widget.controller.clearDraft();
                        },
                        child: const Text('Limpiar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        FadeSlideIn(
          delay: const Duration(milliseconds: 60),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Como funciona la importacion', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Solo necesitas traer el texto del movimiento. PresuCo intenta leerlo, entender cuanto fue, detectar el banco y dejarte el gasto casi listo para guardar.',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 12),
                const _AutomationChannel(
                  title: '1. Pegas o compartes el texto',
                  subtitle: 'Puede venir de una notificacion, un SMS, un correo o algo que copies manualmente.',
                ),
                const SizedBox(height: 10),
                const _AutomationChannel(
                  title: '2. La app lo interpreta',
                  subtitle: 'PresuCo intenta reconocer el valor, el banco y el tipo de compra automaticamente.',
                ),
                const SizedBox(height: 10),
                const _AutomationChannel(
                  title: '3. Confirmas y guardas',
                  subtitle: 'Si algo falta o no coincide, lo corriges rapido y despues lo registras.',
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: automationUri == null
                        ? null
                        : () async {
                            await Clipboard.setData(ClipboardData(text: automationUri.toString()));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Enlace de captura copiado.')),
                              );
                            }
                          },
                    icon: const Icon(Icons.link_rounded),
                    label: const Text('Copiar enlace de captura'),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  automationUri == null
                      ? 'Cuando pegues un texto aqui, tambien podras copiar un enlace listo para usar en Atajos y acelerar este proceso.'
                      : 'Ese enlace puede usarse como accion final en un Atajo para abrir PresuCo con el texto ya listo para importar.',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          child: draft != null
              ? _DraftPreview(
                  draft: draft,
                  activeCurrency: currency,
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 14),
        FadeSlideIn(
          delay: const Duration(milliseconds: 80),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Atajos sugeridos', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                SizedBox(height: 10),
                Text('- Notificacion recibida -> enviar texto a PresuCo'),
                Text('- Compartir texto -> PresuCo'),
                Text('- Abrir app -> pegar desde portapapeles'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _tryPasteClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) {
      return;
    }

    if (_textController.text.trim() == text) {
      return;
    }

    setState(() {
      _textController.text = text;
    });
    final imported = await widget.controller.ingestText(text, autoImport: true);
    final mismatch = widget.controller.draft?.hasCurrencyMismatch(widget.controller.profile.currency) ?? false;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            imported
                ? 'Texto detectado y guardado automaticamente.'
                : mismatch
                    ? 'La notificacion parece venir en otra divisa. Revisa antes de guardar.'
                    : 'Texto detectado desde el portapapeles.',
          ),
        ),
      );
    }
  }

  Future<bool?> _confirmCurrencyMismatch(ParsedTransactionDraft draft, AppCurrency activeCurrency) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar divisa'),
          content: Text(
            'La notificacion parece venir en ${draft.detectedCurrency?.label ?? 'otra divisa'}, pero la app esta en ${activeCurrency.label}. Quieres guardar el gasto de todas formas?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Revisar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}

class _AutomationChannel extends StatelessWidget {
  const _AutomationChannel({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F4EA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9DEC9)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_mode_rounded, color: Color(0xFF1F8F6A)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DraftPreview extends StatelessWidget {
  const _DraftPreview({
    required this.draft,
    required this.activeCurrency,
  });

  final ParsedTransactionDraft draft;
  final AppCurrency activeCurrency;

  @override
  Widget build(BuildContext context) {
    final mismatch = draft.hasCurrencyMismatch(activeCurrency);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Detectamos esto', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          if (mismatch)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1DB),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFC857)),
              ),
              child: Text(
                'La notificacion parece venir en ${draft.detectedCurrency?.label ?? 'otra divisa'}. Confirma si el gasto coincide con la divisa activa: ${activeCurrency.label}.',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          _Row(label: 'Estado', value: draft.recognized ? 'Reconocido' : 'Revisar'),
          _Row(label: 'Confianza', value: draft.confidenceLabel),
          _Row(label: 'Divisa detectada', value: draft.detectedCurrency?.label ?? 'No detectada'),
          _Row(label: 'Banco', value: draft.bank ?? 'No identificado'),
          _Row(
            label: 'Monto',
            value: draft.amount == null
                ? 'No detectado'
                : formatMoney(draft.amount!, draft.detectedCurrency ?? activeCurrency),
          ),
          _Row(label: 'Categoria', value: draft.category),
          _Row(label: 'Nota', value: draft.note),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: draft.confidence / 100,
              minHeight: 10,
              backgroundColor: const Color(0xFFE9E2D5),
              valueColor: AlwaysStoppedAnimation<Color>(
                draft.canAutoImport ? const Color(0xFF1F8F6A) : const Color(0xFFF28C28),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            draft.canAutoImport && !mismatch
                ? 'Se puede guardar automaticamente.'
                : mismatch
                    ? 'La autoimportacion se detuvo para evitar guardar una divisa equivocada.'
                    : draft.hint,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

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
          Flexible(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
