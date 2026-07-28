import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kumayokeru_app/app.dart';
import 'package:kumayokeru_app/core/config/flavor.dart';

void main() {
  testWidgets('ホーム画面がアプリ名を表示する', (WidgetTester tester) async {
    AppConfig.setFlavor(Flavor.dev);

    await tester.pumpWidget(
      const ProviderScope(child: KumaYokeruApp()),
    );

    expect(find.text('登山のお守り'), findsOneWidget);
  });
}
