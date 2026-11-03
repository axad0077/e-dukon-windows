import '../../../src/adaptive_colors.dart';
import '../../../src/l10n/app_strings.dart';

import 'package:flutter/material.dart';

class UnitSelector extends StatelessWidget {
  final String? value;
  final Function(String?) onChanged;
  final String? labelText;
  final bool enabled;

  const UnitSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.labelText,
    this.enabled = true,
  });

  static Map<String, UnitInfo> get units => {
    'dona': UnitInfo(
      icon: Icons.circle_outlined,
      label: tr('unitPiece'),
      description: tr('unitPieceDesc'),
      color: Colors.blue,
    ),
    'pachka': UnitInfo(
      icon: Icons.inventory_2_outlined,
      label: tr('unitPack'),
      description: tr('unitPackDesc'),
      color: Colors.deepPurple,
    ),
    'butilka': UnitInfo(
      icon: Icons.local_drink_outlined,
      label: tr('unitBottle'),
      description: tr('unitBottleDesc'),
      color: Colors.cyan,
    ),
    'gramm': UnitInfo(
      icon: Icons.scale,
      label: tr('unitGram'),
      description: tr('weight'),
      color: Colors.green,
    ),
    'ml': UnitInfo(
      icon: Icons.water_drop,
      label: tr('unitMl'),
      description: tr('volume'),
      color: Colors.cyan,
    ),
    'kg': UnitInfo(
      icon: Icons.scale_rounded,
      label: tr('unitKg'),
      description: tr('weight'),
      color: Colors.green,
    ),
    'litr': UnitInfo(
      icon: Icons.water_drop_outlined,
      label: tr('unitLitre'),
      description: tr('volume'),
      color: Colors.cyan,
    ),
    'metr': UnitInfo(
      icon: Icons.straighten_rounded,
      label: tr('unitMetre'),
      description: tr('length'),
      color: Colors.orange,
    ),
    'quti': UnitInfo(
      icon: Icons.inventory_2_outlined,
      label: tr('unitBox'),
      description: tr('boxed'),
      color: Colors.purple,
    ),
    'paket': UnitInfo(
      icon: Icons.shopping_bag_outlined,
      label: tr('unitBag'),
      description: tr('bagged'),
      color: Colors.brown,
    ),
    'm²': UnitInfo(
      icon: Icons.crop_square_rounded,
      label: tr('unitSquare'),
      description: tr('area'),
      color: Colors.indigo,
    ),
    'm³': UnitInfo(
      icon: Icons.view_in_ar_rounded,
      label: tr('unitCubic'),
      description: tr('volume'),
      color: Colors.teal,
    ),
  };

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    final selectedUnit = value != null ? units[value!] : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (labelText != null)
          Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              labelText!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: adaptiveColor(
                  context,
                  Colors.grey[700]!,
                  foreground: true,
                ),
              ),
            ),
          ),
        InkWell(
          onTap: enabled ? () => _showUnitPicker(context) : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: enabled ? Colors.white : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: enabled ? Colors.grey[300]! : Colors.grey[200]!,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (selectedUnit?.color ?? Colors.grey).withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    selectedUnit?.icon ?? Icons.straighten_rounded,
                    color: selectedUnit?.color ?? Colors.grey,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedUnit?.label ?? tr('m315'),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (selectedUnit != null)
                        Text(
                          selectedUnit.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: adaptiveColor(
                              context,
                              Colors.grey[600]!,
                              foreground: true,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  color: enabled ? Colors.grey[600] : Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showUnitPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Handle bar
                Container(
                  margin: EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: adaptiveColor(context, Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Title
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: adaptiveColor(context, Colors.blue[50]!),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.straighten_rounded,
                          color: adaptiveColor(
                            context,
                            Colors.blue[700]!,
                            foreground: true,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tr('m315'),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1),
                // Units list
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: units.length,
                    itemBuilder: (context, index) {
                      final entry = units.entries.elementAt(index);
                      final unitKey = entry.key;
                      final unitInfo = entry.value;
                      final isSelected = value == unitKey;

                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Material(
                          color: isSelected
                              ? unitInfo.color.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () {
                              onChanged(unitKey);
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? unitInfo.color
                                      : Colors.grey[200]!,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: unitInfo.color.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      unitInfo.icon,
                                      color: unitInfo.color,
                                      size: 28,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          unitInfo.label,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? unitInfo.color
                                                : Colors.black87,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          unitInfo.description,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: adaptiveColor(
                                              context,
                                              Colors.grey[600]!,
                                              foreground: true,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: unitInfo.color,
                                      size: 28,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class UnitInfo {
  final IconData icon;
  final String label;
  final String description;
  final Color color;

  const UnitInfo({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
  });
}
