// Ashlar UI: Chart export. Copied into your app by `ashlar add chart-export`; it is yours
// to change.
//
// A chart (or any widget) as a PNG or a one-page PDF, with no package: the picture from
// Flutter's own renderer, the PDF written here. What you do with the bytes (save, share,
// upload) is up to your app.

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Takes pictures of the [ChartExport] it is given to.
///
/// ```dart
/// final export = ChartExportController();
/// ChartExport(controller: export, child: BarChart(...));
/// final bytes = await export.pdf(title: 'Visitors');
/// ```
class ChartExportController {
  final _key = GlobalKey();

  RenderRepaintBoundary get _boundary {
    final r = _key.currentContext?.findRenderObject();
    if (r is! RenderRepaintBoundary) {
      throw StateError('The ChartExport for this controller is not on screen.');
    }
    return r;
  }

  /// The chart as an image, [pixelRatio] pixels to each logical one.
  Future<ui.Image> image({double pixelRatio = 2}) =>
      _boundary.toImage(pixelRatio: pixelRatio);

  /// The chart as a PNG.
  Future<Uint8List> png({double pixelRatio = 2}) async {
    final image = await this.image(pixelRatio: pixelRatio);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data!.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }

  /// The chart as a one-page PDF the size of the chart, on [background] (the chart's
  /// transparent parts are painted it), with [title] in the document's details.
  Future<Uint8List> pdf({
    double pixelRatio = 2,
    String? title,
    Color background = const Color(0xFFFFFFFF),
  }) async {
    final image = await this.image(pixelRatio: pixelRatio);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
      return chartPdf(
        rgba: data!.buffer.asUint8List(),
        width: image.width,
        height: image.height,
        pixelRatio: pixelRatio,
        title: title,
        background: background,
      );
    } finally {
      image.dispose();
    }
  }
}

/// Marks what a [ChartExportController] takes pictures of.
class ChartExport extends StatelessWidget {
  const ChartExport({super.key, required this.controller, required this.child});

  final ChartExportController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      RepaintBoundary(key: controller._key, child: child);
}

/// A one-page PDF holding a picture given as straight (not premultiplied) RGBA bytes,
/// [width] by [height] pixels; the page is the picture's size at 96 pixels an inch,
/// divided by [pixelRatio].
Uint8List chartPdf({
  required Uint8List rgba,
  required int width,
  required int height,
  double pixelRatio = 1,
  String? title,
  Color background = const Color(0xFFFFFFFF),
}) {
  // PDF pictures have no transparency here: lay each pixel on the background.
  final rgb = Uint8List(width * height * 3);
  final br = (background.r * 255).round(),
      bg = (background.g * 255).round(),
      bb = (background.b * 255).round();
  for (var p = 0, q = 0; p < rgba.length; p += 4, q += 3) {
    final a = rgba[p + 3];
    rgb[q] = (rgba[p] * a + br * (255 - a)) ~/ 255;
    rgb[q + 1] = (rgba[p + 1] * a + bg * (255 - a)) ~/ 255;
    rgb[q + 2] = (rgba[p + 2] * a + bb * (255 - a)) ~/ 255;
  }
  // Points are 1/72 inch; a logical pixel is 1/96.
  String n(double v) => v.toStringAsFixed(2);
  final pw = width / pixelRatio * .75, ph = height / pixelRatio * .75;
  final out = BytesBuilder(copy: false);
  final offsets = <int>[];
  void raw(String s) => out.add(latin1.encode(s));
  void obj(String body) {
    offsets.add(out.length);
    raw('${offsets.length} 0 obj\n$body\nendobj\n');
  }

  // Text in a PDF string: brackets and backslashes escaped, other characters dropped
  // unless they fit Latin-1.
  String text(String s) => s
      .replaceAll(r'\', r'\\')
      .replaceAll('(', r'\(')
      .replaceAll(')', r'\)')
      .runes
      .map((r) => r < 256 ? String.fromCharCode(r) : '?')
      .join();

  raw('%PDF-1.4\n%âãÏÓ\n');
  obj('<< /Type /Catalog /Pages 2 0 R >>');
  obj('<< /Type /Pages /Kids [3 0 R] /Count 1 >>');
  obj(
    '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 ${n(pw)} ${n(ph)}] '
    '/Resources << /XObject << /Im0 4 0 R >> >> /Contents 5 0 R >>',
  );
  offsets.add(out.length);
  raw(
    '4 0 obj\n<< /Type /XObject /Subtype /Image /Width $width /Height $height '
    '/ColorSpace /DeviceRGB /BitsPerComponent 8 /Length ${rgb.length} >>\nstream\n',
  );
  out.add(rgb);
  raw('\nendstream\nendobj\n');
  final draw = 'q ${n(pw)} 0 0 ${n(ph)} 0 0 cm /Im0 Do Q';
  obj('<< /Length ${draw.length} >>\nstream\n$draw\nendstream');
  obj('<< /Title (${text(title ?? 'Chart')}) /Producer (Ashlar UI) >>');
  final xref = out.length;
  raw('xref\n0 ${offsets.length + 1}\n0000000000 65535 f \n');
  for (final o in offsets) {
    raw('${o.toString().padLeft(10, '0')} 00000 n \n');
  }
  raw(
    'trailer\n<< /Size ${offsets.length + 1} /Root 1 0 R /Info ${offsets.length} 0 R >>\n'
    'startxref\n$xref\n%%EOF\n',
  );
  return out.toBytes();
}
