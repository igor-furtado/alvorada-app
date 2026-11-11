import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const EstudosApp());
  if (kIsWeb) SemanticsBinding.instance.ensureSemantics();
}
