// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:catalogo_peliculas/main.dart'; // Importa el archivo main.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MyWidget has a title and message', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MovieCatalogApp()); // Usando MyApp correctamente, ya que fue importado.

    // Verify that our counter starts at 0.
    expect(find.text('Movie Catalog'), findsOneWidget);
  });
}
