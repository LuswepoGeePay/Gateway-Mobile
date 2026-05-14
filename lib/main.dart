import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gateway_mobile/app.dart';
import 'package:gateway_mobile/bindings/general_bindings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load all storage buckets in parallel to speed up startup
  await Future.wait([GetStorage.init()]);

  GeneralBindings().dependencies();

  // Request location permissions without blocking the app launch

  runApp(const MyApp());
}
