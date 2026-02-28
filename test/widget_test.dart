import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:justicecity_flutter/features/auth/auth_screen.dart';

void main() {
  testWidgets('auth screen renders inside ProviderScope', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AuthScreen(),
        ),
      ),
    );

    expect(find.text('Create an account'), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
  });
}
