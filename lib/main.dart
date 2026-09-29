import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

export 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ixopirijqdohqkfozwrc.supabase.co',
    publishableKey: 'sb_publishable_gp5XY23yOFakmZMtzZo0RQ_4wKiAHBf',
  );
  runApp(const TmdsApp());
}
