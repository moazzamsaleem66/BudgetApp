import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lifestyle/features/budget/presentation/pages/splash_screen.dart';

void main() {
  testWidgets('splash screen renders PocketBoss branding', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashView()));

    expect(find.text('PocketBoss'), findsOneWidget);
    expect(find.text('Smart way to manage your money'), findsOneWidget);
  });
}
