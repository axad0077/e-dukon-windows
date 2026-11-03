import '../adaptive_colors.dart';
import '../l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app.dart';
import 'home_screen.dart';

class ChangePassword extends ConsumerStatefulWidget {
  final bool isFirstTime;

  const ChangePassword({super.key, this.isFirstTime = false});

  @override
  ConsumerState<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends ConsumerState<ChangePassword> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool busy = false;
  String? error;
  bool obscureOld = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    return PopScope(
      canPop: !widget.isFirstTime,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isFirstTime ? tr('m367') : tr('m364')),
          automaticallyImplyLeading: !widget.isFirstTime,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    widget.isFirstTime ? Icons.security : Icons.password,
                    size: 64,
                    color: widget.isFirstTime ? Colors.orange : Colors.blue,
                  ),
                  SizedBox(height: 16),
                  Text(
                    widget.isFirstTime ? tr('m361') : tr('m364'),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.isFirstTime ? tr('m578') : tr('m577'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: adaptiveColor(context, Colors.blueGrey,
                            foreground: true)),
                  ),
                  if (widget.isFirstTime)
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Card(
                        color: adaptiveColor(context, Colors.orange[50]!),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(Icons.info,
                                  color: adaptiveColor(
                                      context, Colors.orange[700]!)),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  tr('m80'),
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 32),
                  TextField(
                    controller: oldPasswordController,
                    obscureText: obscureOld,
                    decoration: InputDecoration(
                      labelText: tr('m189'),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureOld ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() => obscureOld = !obscureOld);
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: newPasswordController,
                    obscureText: obscureNew,
                    decoration: InputDecoration(
                      labelText: tr('m582'),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNew ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() => obscureNew = !obscureNew);
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirm,
                    decoration: InputDecoration(
                      labelText: tr('m587'),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_clock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirm
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() => obscureConfirm = !obscureConfirm);
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Card(
                    color: adaptiveColor(context, Color(0xFFF3F4F6)),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr('m359'),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(tr('m662')),
                          Text(tr('m660')),
                          Text(tr('m663')),
                          Text(tr('m659')),
                        ],
                      ),
                    ),
                  ),
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
                  FilledButton(
                    onPressed: busy ? null : _changePassword,
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(busy ? tr('m320') : tr('m364')),
                  ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: widget.isFirstTime
                        ? null
                        : () => Navigator.pop(context),
                    child: Text(widget.isFirstTime ? tr('m358') : tr('m57')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _changePassword() async {
    setState(() {
      busy = true;
      error = null;
    });

    // Validation
    if (oldPasswordController.text.isEmpty) {
      setState(() {
        error = tr('m190');
        busy = false;
      });
      return;
    }

    if (newPasswordController.text.isEmpty) {
      setState(() {
        error = tr('m586');
        busy = false;
      });
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      setState(() {
        error = tr('m585');
        busy = false;
      });
      return;
    }

    if (newPasswordController.text.length < 10) {
      setState(() {
        error = tr('m584');
        busy = false;
      });
      return;
    }

    if (oldPasswordController.text == newPasswordController.text) {
      setState(() {
        error = tr('m583');
        busy = false;
      });
      return;
    }

    try {
      final result = await ref.read(apiProvider).changePassword(
            oldPasswordController.text,
            newPasswordController.text,
            confirmPasswordController.text,
          );

      if (!mounted) return;

      // Show success dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(tr('m296')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle,
                  color: adaptiveColor(context, Colors.green), size: 48),
              SizedBox(height: 16),
              Text(result['message'] ?? tr('m360')),
              SizedBox(height: 16),
              Text(
                widget.isFirstTime ? tr('m127') : tr('m579'),
                textAlign: TextAlign.center,
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () async {
                if (widget.isFirstTime) {
                  // For first-time change, go to Home screen directly
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => HomeScreen()),
                      (route) => false,
                    );
                  }
                } else {
                  // For regular password change, logout and go to login
                  await ref.read(apiProvider).logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => Login()),
                      (route) => false,
                    );
                  }
                }
              },
              child: Text(widget.isFirstTime ? tr('m107') : tr('m219')),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = friendlyFailure(e);
        busy = false;
      });
    }
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
