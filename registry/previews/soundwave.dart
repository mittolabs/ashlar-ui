// The soundwave picture ashlar update --preview draws, from the site's demo.
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/soundwave.dart';
import 'package:ashlar_ui_gallery/ui/theme.dart';

/// Levels as speech gives them: louder in bursts, quiet between words.
final _levels = [
  for (var i = 0; i < 90; i++)
    (math.sin(i / 3) * .5 + .5) * (math.sin(i / 11) * .4 + .6) * (i % 17 < 3 ? .15 : 1),
];

class SoundwaveDemo extends StatelessWidget {
  const SoundwaveDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    return SizedBox(
      width: 360,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Soundwave(levels: _levels, height: 40, semanticLabel: 'Listening'),
          const SizedBox(height: 8),
          Text('Listening… 0:07', style: t.text.sm.copyWith(color: t.colors.mutedForeground)),
          const SizedBox(height: 20),
          Soundwave(levels: const [], height: 24),
        ],
      ),
    );
  }
}
