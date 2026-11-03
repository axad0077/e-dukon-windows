import '../adaptive_colors.dart';
import '../l10n/app_strings.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app.dart';

class ActivateAccount extends ConsumerStatefulWidget {
  const ActivateAccount({super.key});

  @override
  ConsumerState<ActivateAccount> createState() => _ActivateAccountState();
}

class _ActivateAccountState extends ConsumerState<ActivateAccount> {
  final codeController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool busy = false;
  String? error;
  bool obscurePassword = true;
  bool obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.lock_open,
                  size: 64,
                  color: adaptiveColor(context, Colors.blue),
                ),
                SizedBox(height: 16),
                Text(
                  tr('m161'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  tr('m11'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: adaptiveColor(context, Colors.blueGrey,
                          foreground: true)),
                ),
                SizedBox(height: 32),

                // Aktivatsiya kodi
                TextField(
                  controller: codeController,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: tr('m24'),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.vpn_key),
                  ),
                ),
                SizedBox(height: 16),

                // Yangi parol
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: tr('m582'),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Parolni tasdiqlash
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirm,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: tr('m366'),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirm
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureConfirm = !obscureConfirm;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 12),

                // Parol talablari
                Card(
                  color: adaptiveColor(context, Color(0xFFF3F4F6)),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('m359'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(tr('m662')),
                        Text(
                          tr('m661'),
                        ),
                        Text(tr('m663')),
                      ],
                    ),
                  ),
                ),

                // Xatolik xabari
                if (error != null)
                  Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Card(
                      color: adaptiveColor(context, Colors.red[50]!),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          error!,
                          style: TextStyle(
                              color: adaptiveColor(context, Colors.red,
                                  foreground: true)),
                        ),
                      ),
                    ),
                  ),

                SizedBox(height: 24),

                // Aktivatsiya tugmasi
                FilledButton(
                  onPressed: busy ? null : _activate,
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    busy ? tr('m26') : tr('m161'),
                  ),
                ),
                SizedBox(height: 16),

                TextButton(
                  onPressed: busy
                      ? null
                      : () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => Login(),
                            ),
                          );
                        },
                  child: Text(tr('m221')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _activate() async {
    if (busy) return;

    final code = codeController.text.trim();
    final password = passwordController.text;
    final confirmation = confirmPasswordController.text;

    // Mahalliy tekshiruvlar
    if (code.isEmpty) {
      setState(() => error = tr('m25'));
      return;
    }

    if (password.isEmpty) {
      setState(() => error = tr('m363'));
      return;
    }

    if (password != confirmation) {
      setState(() => error = tr('m362'));
      return;
    }

    if (password.length < 10) {
      setState(() {
        error = tr('m357');
      });
      return;
    }

    setState(() {
      busy = true;
      error = null;
    });

    try {
      final result = await ref.read(apiProvider).activateAccount(
            code,
            password,
          );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: Text(tr('m296')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle,
                color: adaptiveColor(context, Colors.green),
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                result['message']?.toString() ?? tr('m160'),
              ),
              SizedBox(height: 8),
              Text(tr('m568', [result['username'] ?? ''])),
              SizedBox(height: 16),
              Text(
                tr('m128'),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => Login(),
                  ),
                );
              },
              child: Text(tr('m220')),
            ),
          ],
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;

      final data = e.response?.data;
      var message = tr('m23');

      if (data is Map) {
        final errorData = data['error'];

        if (errorData is Map && errorData['message'] != null) {
          message = errorData['message'].toString();
        } else if (data['detail'] != null) {
          message = data['detail'].toString();
        } else if (data['message'] != null) {
          message = data['message'].toString();
        } else {
          message = tr('m443', [data.toString()]);
        }
      } else if (e.response == null) {
        message = tr('m448');
      } else if (data != null) {
        message = data.toString();
      } else {
        message = tr('m153', [e.response?.statusCode]);
      }

      setState(() {
        error = tr('m27', [message]);
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = friendlyFailure(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  @override
  void dispose() {
    codeController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
