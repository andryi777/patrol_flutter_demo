import 'package:flutter_riverpod_clean_architecture/main.dart' as app;
import 'package:patrol/patrol.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> testMain() async {
  await SharedPreferences.getInstance();
  app.main();
}
