import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app.dart';

/// A consistent product stage: the full package remains visible at any aspect ratio.
class ProductPhoto extends ConsumerWidget {
  final String? image;
  final String name;
  final double radius;
  final EdgeInsets padding;
  const ProductPhoto({
    super.key,
    required this.image,
    required this.name,
    this.radius = 0,
    this.padding = const EdgeInsets.fromLTRB(16, 34, 16, 12),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final raw = image?.trim() ?? '';
    final base = Uri.parse(ref.read(apiProvider).dio.options.baseUrl);
    final parsed = Uri.tryParse(raw);
    final resolved = parsed == null ? null : base.resolveUri(parsed);
    final valid =
        raw.isNotEmpty &&
        resolved != null &&
        (resolved.scheme == 'https' || resolved.scheme == 'http') &&
        resolved.host.isNotEmpty;
    final colors = Theme.of(context).colorScheme;
    Widget placeholder() => Center(
      child: Icon(
        Icons.inventory_2_outlined,
        size: 36,
        color: colors.onSurfaceVariant.withValues(alpha: 0.45),
      ),
    );
    return Semantics(
      label: name,
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: ColoredBox(
          color: colors.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8EDF2)),
              ),
              child: Padding(
                padding: padding,
                child: !valid
                    ? placeholder()
                    : Image.network(
                        resolved.toString(),
                        key: ValueKey(resolved.toString()),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        filterQuality: FilterQuality.medium,
                        excludeFromSemantics: true,
                        frameBuilder: (context, child, frame, synchronous) {
                          if (synchronous || frame != null) return child;
                          return Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.primary,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stack) => placeholder(),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
