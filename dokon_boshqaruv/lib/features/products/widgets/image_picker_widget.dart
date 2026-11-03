import '../../../src/adaptive_colors.dart';
import '../../../src/l10n/app_strings.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerWidget extends StatefulWidget {
  final String? initialImagePath;
  final Function(String?) onImageSelected;

  const ImagePickerWidget({
    super.key,
    this.initialImagePath,
    required this.onImageSelected,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.initialImagePath;
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isProcessing = true);

    try {
      final mobile =
          !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS);
      if (mobile && source == ImageSource.camera) {
        final status = await Permission.camera.request();
        if (!mounted) return;
        if (!status.isGranted) {
          throw FormatException(tr('m202'));
        }
      }
      // Gallery uses the OS picker; Windows has no mobile photos permission.

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        final extension = image.name.split('.').last.toLowerCase();
        final size = await image.length();
        if (!{'jpg', 'jpeg', 'png', 'webp'}.contains(extension)) {
          throw FormatException(tr('m184'));
        }
        if (size > 5 * 1024 * 1024) {
          throw FormatException(tr('m406'));
        }
        if (!mounted) return;
        setState(() => _imagePath = image.path);
        widget.onImageSelected(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: adaptiveColor(context, Colors.white),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(e is FormatException ? e.message : tr('m412')),
                ),
              ],
            ),
            backgroundColor: adaptiveColor(context, Colors.red),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final supportsCamera =
            kIsWeb ||
            defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: adaptiveColor(context, Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  tr('m409'),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                if (supportsCamera)
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: adaptiveColor(context, Colors.blue[50]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.photo_camera_rounded,
                        color: adaptiveColor(
                          context,
                          Colors.blue[700]!,
                          foreground: true,
                        ),
                      ),
                    ),
                    title: Text(
                      tr('m197'),
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(tr('m591')),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: adaptiveColor(context, Colors.green[50]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.photo_library_rounded,
                      color: adaptiveColor(
                        context,
                        Colors.green[700]!,
                        foreground: true,
                      ),
                    ),
                  ),
                  title: Text(
                    tr('m150'),
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(tr('m272')),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_imagePath != null)
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: adaptiveColor(context, Colors.red[50]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.delete_rounded,
                        color: adaptiveColor(
                          context,
                          Colors.red[700]!,
                          foreground: true,
                        ),
                      ),
                    ),
                    title: Text(
                      tr('m410'),
                      style: TextStyle(
                        color: adaptiveColor(
                          context,
                          Colors.red,
                          foreground: true,
                        ),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(tr('m251')),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _imagePath = null;
                      });
                      widget.onImageSelected(null);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(tr('m407')),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: _isProcessing ? null : _showImageSourceDialog,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: _imagePath != null || _isProcessing ? 220 : null,
          constraints: const BoxConstraints(minHeight: 220),
          padding: _imagePath == null && !_isProcessing
              ? const EdgeInsets.all(16)
              : EdgeInsets.zero,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: _imagePath == null
                ? LinearGradient(
                    colors: [
                      adaptiveColor(context, Colors.grey[100]!),
                      adaptiveColor(context, Colors.grey[50]!),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: _isProcessing
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(tr('m605')),
                    ],
                  ),
                )
              : _imagePath != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _imagePath!.startsWith('http')
                          ? Image.network(
                              _imagePath!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Center(child: Icon(Icons.broken_image)),
                            )
                          : FutureBuilder<Uint8List>(
                              future: XFile(_imagePath!).readAsBytes(),
                              builder: (context, snapshot) => snapshot.hasData
                                  ? Image.memory(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                    )
                                  : Center(child: CircularProgressIndicator()),
                            ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          color: adaptiveColor(context, Colors.black54),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: adaptiveColor(
                                context,
                                Colors.black.withValues(alpha: 0.3),
                              ),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit_rounded,
                                color: adaptiveColor(
                                  context,
                                  Colors.white,
                                  foreground: true,
                                ),
                                size: 20,
                              ),
                              onPressed: _showImageSourceDialog,
                              tooltip: tr('m411'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: adaptiveColor(context, Colors.black54),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: adaptiveColor(context, Colors.green),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                tr('m408'),
                                style: TextStyle(
                                  color: adaptiveColor(
                                    context,
                                    Colors.white,
                                    foreground: true,
                                  ),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: adaptiveColor(context, Colors.blue[50]!),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_photo_alternate_rounded,
                        size: 48,
                        color: adaptiveColor(
                          context,
                          Colors.blue[700]!,
                          foreground: true,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      tr('m250'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: adaptiveColor(context, Colors.blue[50]!),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tr('m77'),
                        style: TextStyle(
                          fontSize: 13,
                          color: adaptiveColor(
                            context,
                            Colors.blue[700]!,
                            foreground: true,
                          ),
                          fontWeight: FontWeight.w500,
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
