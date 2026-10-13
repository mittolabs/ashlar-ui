// The input-otp picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/input_otp.dart';

class InputOtpDemo extends StatelessWidget {
  const InputOtpDemo({super.key});

  @override
  Widget build(BuildContext context) => InputOtp(
    groups: const [3, 3],
    onCompleted: (code) {
      // Check the code.
    },
  );
}
