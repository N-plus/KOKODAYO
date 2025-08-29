import 'package:flutter/material.dart';
import 'package:kokodayo/simple_provider.dart';

import 'app_state.dart';
import 'screens/role_selection.dart';
import 'screens/parent_code_screen.dart';
import 'screens/child_pairing_screen.dart';
import 'screens/parent_home_screen.dart';
import 'screens/child_alarm_screen.dart';
import 'screens/settings_help_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const KokodayoApp(),
    ),
  );
}

class KokodayoApp extends StatelessWidget {
  const KokodayoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kokodayo',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const RoleSelectionScreen(),
        '/parentCode': (context) => const ParentCodeScreen(),
        '/childPair': (context) => const ChildPairingScreen(),
        '/parentHome': (context) => const ParentHomeScreen(),
        '/childAlarm': (context) => const ChildAlarmScreen(),
        '/settings': (context) => const SettingsHelpScreen(),
      },
    );
  }
}
