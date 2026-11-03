import 'package:flutter/material.dart';

/// Equal-width actions on roomy screens, full-width on narrow screens.
/// The primary action stays last (right on desktop, bottom on mobile).
class ActionButtons extends StatelessWidget {
  final List<Widget> children;
  const ActionButtons({super.key, required this.children});

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final stacked = box.maxWidth < 420 ||
            MediaQuery.textScalerOf(context).scale(16) > 20;
        if (stacked) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  children[i],
                ],
              ]);
        }
        return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: children[i]),
          ],
        ]);
      });
}
