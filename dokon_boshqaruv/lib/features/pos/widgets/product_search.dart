import '../../../src/adaptive_colors.dart';
import '../../../src/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../products/widgets/barcode_scanner_dialog.dart';

class ProductSearch extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController barcodeController;
  final Function(String) onSearch;
  final Future<void> Function(String)? onBarcodeSubmitted;

  const ProductSearch({
    super.key,
    required this.controller,
    required this.barcodeController,
    required this.onSearch,
    this.onBarcodeSubmitted,
  });

  @override
  State<ProductSearch> createState() => _ProductSearchState();
}

class _ProductSearchState extends State<ProductSearch> {
  Timer? _debounce;
  bool _hasFocus = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: 350), () {
      widget.onSearch(query);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    final supportsCamera = kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: widget.barcodeController,
          focusNode: _focusNode,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (value) async {
            final barcode = value.trim();
            if (barcode.isEmpty || widget.onBarcodeSubmitted == null) return;
            await widget.onBarcodeSubmitted!(barcode);
            widget.barcodeController.clear();
            if (mounted) _focusNode.requestFocus();
          },
          decoration: InputDecoration(
            labelText: tr('m456'),
            hintText: tr('m226'),
            prefixIcon: Icon(Icons.qr_code_2_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: adaptiveColor(context, Colors.white),
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Focus(
                onFocusChange: (hasFocus) =>
                    setState(() => _hasFocus = hasFocus),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: _hasFocus
                        ? [
                            BoxShadow(
                              color: adaptiveColor(context, Color(0x331565C0)),
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: TextField(
                    controller: widget.controller,
                    onChanged: _onSearchChanged,
                    onSubmitted: widget.onSearch,
                    decoration: InputDecoration(
                      hintText: tr('m457'),
                      hintStyle: TextStyle(
                        color: adaptiveColor(context, Colors.grey[400]!,
                            foreground: true),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: _hasFocus ? Color(0xFF1565C0) : Colors.grey[400],
                        size: 22,
                      ),
                      suffixIcon: widget.controller.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                widget.controller.clear();
                                widget.onSearch('');
                                setState(() {});
                              },
                              child: Container(
                                margin: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      adaptiveColor(context, Colors.grey[200]!),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: adaptiveColor(context, Colors.grey,
                                      foreground: true),
                                ),
                              ),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: adaptiveColor(context, Color(0xFF1565C0),
                              foreground: true),
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: adaptiveColor(context, Colors.white),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            // Barcode scanner button
            if (supportsCamera)
              Tooltip(
                message: tr('m454'),
                child: Material(
                  color: adaptiveColor(context, Colors.transparent),
                  child: InkWell(
                    onTap: () async {
                      final code = await showDialog<String>(
                        context: context,
                        builder: (_) => BarcodeScannerDialog(),
                      );
                      if (code != null && code.trim().isNotEmpty && mounted) {
                        await widget.onBarcodeSubmitted?.call(code.trim());
                        widget.barcodeController.clear();
                        _focusNode.requestFocus();
                      }
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: adaptiveColor(context, Color(0x441565C0)),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.qr_code_scanner_rounded,
                        color: adaptiveColor(context, Colors.white,
                            foreground: true),
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
