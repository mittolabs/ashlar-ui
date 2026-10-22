// Tests for Chart export. Copied into your app by `ashlar add chart-export` with the
// component: they check what it promises, so change them as you change it.
import 'dart:convert';
import 'dart:typed_data';

import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/chart_export.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a PNG and a PDF of what it wraps', (tester) async {
    final export = ChartExportController();
    await tester.pumpWidget(
      AshlarApp(
        home: Center(
          child: ChartExport(
            controller: export,
            child: Container(width: 120, height: 60, color: const Color(0xFF336699)),
          ),
        ),
      ),
    );
    final png = (await tester.runAsync(() => export.png(pixelRatio: 1)))!;
    expect(png.sublist(1, 4), utf8.encode('PNG'));
    final pdf = (await tester.runAsync(() => export.pdf(pixelRatio: 1, title: 'Sales')))!;
    final text = latin1.decode(pdf);
    expect(text, startsWith('%PDF-1.4'));
    expect(text, contains('/Width 120 /Height 60'));
    expect(text, contains('/MediaBox [0 0 90.00 45.00]'));
    expect(text, contains('/Title (Sales)'));
    expect(text.trimRight(), endsWith('%%EOF'));
  });

  test('a PDF lays transparent pixels on its background, and its table finds each part', () {
    // Two pixels: opaque red, and fully transparent.
    final pdf = chartPdf(
      rgba: Uint8List.fromList([255, 0, 0, 255, 0, 0, 0, 0]),
      width: 2,
      height: 1,
    );
    final bytes = latin1.decode(pdf);
    final start = bytes.indexOf('stream\n', bytes.indexOf('/Subtype /Image')) + 7;
    expect(pdf.sublist(start, start + 6), [255, 0, 0, 255, 255, 255]);
    // Each offset in the table points at its object.
    final xref = int.parse(RegExp(r'startxref\n(\d+)').firstMatch(bytes)!.group(1)!);
    final table = bytes.substring(xref).split('\n').skip(3).take(6);
    for (final (i, line) in table.indexed) {
      final at = int.parse(line.substring(0, 10));
      expect(bytes.substring(at), startsWith('${i + 1} 0 obj'));
    }
  });

  testWidgets('without its widget on screen, it says so', (tester) async {
    expect(() => ChartExportController().png(), throwsStateError);
  });
}
