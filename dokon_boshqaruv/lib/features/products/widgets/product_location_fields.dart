import 'package:flutter/material.dart';

class ProductLocationFields extends StatelessWidget {
  final TextEditingController warehouse;
  final TextEditingController section;
  final TextEditingController shelf;
  const ProductLocationFields({
    super.key,
    required this.warehouse,
    required this.section,
    required this.shelf,
  });
  Widget field(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon,
  ) => TextFormField(
    controller: controller,
    maxLength: 100,
    textCapitalization: TextCapitalization.sentences,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      border: const OutlineInputBorder(),
    ),
    validator: (value) =>
        (value?.trim().length ?? 0) > 100 ? '100 belgigacha kiriting' : null,
  );
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('Mahsulot manzili', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 6),
      const Text('Qaysi ombor, bo‘lim va polkada turganini belgilang.'),
      const SizedBox(height: 16),
      field(
        warehouse,
        'Ombor',
        'Masalan: Asosiy ombor',
        Icons.warehouse_outlined,
      ),
      const SizedBox(height: 8),
      field(section, 'Bo‘lim', 'Masalan: B bo‘lim', Icons.view_quilt_outlined),
      const SizedBox(height: 8),
      field(
        shelf,
        'Polka',
        'Masalan: 3-qator, 2-polka',
        Icons.view_agenda_outlined,
      ),
    ],
  );
}
