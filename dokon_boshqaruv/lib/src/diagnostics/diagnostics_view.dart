import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_diagnostics.dart';

Future<void> showDiagnosticsDialog(BuildContext context) async {
  final report = AppDiagnostics.instance.report();
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Diagnostika hisoboti'),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: SelectableText(
            report,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Yopish'),
        ),
        FilledButton.icon(
          onPressed: () async {
            try {
              await Clipboard.setData(ClipboardData(text: report));
              if (!dialogContext.mounted) return;
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Hisobot nusxalandi. Chatga yuborishingiz mumkin.',
                  ),
                ),
              );
            } catch (_) {
              if (!dialogContext.mounted) return;
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Nusxalab bo‘lmadi. Matnni belgilab nusxalang.',
                  ),
                ),
              );
            }
          },
          icon: const Icon(Icons.copy),
          label: const Text('Nusxalash'),
        ),
      ],
    ),
  );
}
