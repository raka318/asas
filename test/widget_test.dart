import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:asas/main.dart';

void main() {
  testWidgets('Memastikan aplikasi dapat dimuat tanpa error', (WidgetTester tester) async {
    // Arrange & Act: Memuat widget utama MyApp tanpa parameter tambahan
    await tester.pumpWidget(const MyApp());

    // Assert: Memastikan komponen utama MaterialApp berhasil dirender di layar
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}