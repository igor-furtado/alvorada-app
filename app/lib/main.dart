import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // O pacote ainda não compila seus IconData tipados no Flutter atual. A fonte
  // Light é carregada com um nome próprio para evitar que o otimizador remova
  // glifos referenciados pelo mapa compatível em AppIcons.
  final phosphorFont = FontLoader('AlvoradaPhosphor')
    ..addFont(
      rootBundle.load('packages/phosphor_flutter/lib/fonts/Phosphor-Light.ttf'),
    );
  await phosphorFont.load();

  runApp(const EstudosApp());
  if (kIsWeb) SemanticsBinding.instance.ensureSemantics();
}
