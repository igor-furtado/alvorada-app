import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:material_ui/material_ui.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const EstudosApp());
  if (kIsWeb) SemanticsBinding.instance.ensureSemantics();
}
