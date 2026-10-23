// The slider picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/slider.dart';

class SliderDemo extends StatefulWidget {
  const SliderDemo({super.key});

  @override
  State<SliderDemo> createState() => _SliderDemoState();
}

class _SliderDemoState extends State<SliderDemo> {
  double volume = .5, price = 200;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 320,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Slider(value: volume, onChanged: (v) => setState(() => volume = v), semanticLabel: 'Volume'),
        const SizedBox(height: 24),
        Text('Up to \$${price.round()}'),
        const SizedBox(height: 8),
        Slider(
          value: price,
          min: 0,
          max: 500,
          step: 25,
          onChanged: (v) => setState(() => price = v),
          semanticLabel: 'Highest price',
          semanticFormat: (v) => '\$${v.round()}',
        ),
      ],
    ),
  );
}
