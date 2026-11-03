// ignore_for_file: depend_on_referenced_packages, avoid_print
// Runs the normal flutter_test declarations inside the official flutter_tester
// engine when the Flutter shell tool is unavailable. Not part of app startup.
import 'dart:io';
import 'package:test_api/src/backend/declarer.dart';
import 'package:test_api/src/backend/group.dart';
import 'package:test_api/src/backend/test.dart';
import 'package:test_api/src/backend/suite.dart';
import 'package:test_api/src/backend/suite_platform.dart';
import 'package:test_api/src/backend/runtime.dart';
import 'package:test_api/src/backend/state.dart';
import '../test/features/pos/cart_provider_test.dart' as cart;
import '../test/barcode_lookup_test.dart' as barcode;
import '../test/account_settings_test.dart' as account;
import '../test/widget_test.dart' as startup;
import '../test/redesign_test.dart' as redesign;
import '../test/api_and_queue_regression_test.dart' as offline;
import '../test/product_deletion_test.dart' as deletion;
import '../test/action_layout_test.dart' as actions;
import '../test/localization_auth_regression_test.dart' as authLocale;
import '../test/report_period_regression_test.dart' as reportPeriod;

Future<void> main() async {
  late Suite currentSuite;
  var passed = 0, failed = 0;
  Future<void> run(Group group, List<Group> parents) async {
    final groups = [...parents, group];
    for (final entry in group.entries) {
      if (entry is Group) {
        await run(entry, groups);
      } else if (entry is Test) {
        final live = entry.load(currentSuite, groups: groups);
        live.onError.listen((e) {
          print('ERROR ${entry.name}: $e');
        });
        await live.run();
        if (live.state.result == Result.success) {
          passed++;
          print('PASS ${entry.name}');
        } else {
          failed++;
          print('FAIL ${entry.name}');
        }
        await live.close();
      }
    }
  }

  for (final register in [
    cart.main,
    barcode.main,
    account.main,
    startup.main,
    redesign.main,
    offline.main,
    deletion.main,
    actions.main,
    authLocale.main,
    reportPeriod.main
  ]) {
    final declarer = Declarer();
    declarer.declare(register);
    currentSuite = Suite(declarer.build(), SuitePlatform(Runtime.vm));
    await run(currentSuite.group, []);
  }
  print('HEADLESS RESULT: $passed passed, $failed failed');
  exit(failed == 0 ? 0 : 1);
}
