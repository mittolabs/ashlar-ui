// The tool call picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/tool_call.dart';

class ToolCallDemo extends StatelessWidget {
  const ToolCallDemo({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 560,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ToolCall(
          title: 'Look up this week\'s orders',
          name: 'list_orders',
          input: '{"branch": "westlands"}',
          output: '{"count": 38, "late": 3}',
        ),
        const SizedBox(height: 10),
        const ToolCall(title: 'Find the rider', name: 'get_rider', status: ToolCallStatus.running),
        const SizedBox(height: 10),
        ToolCall(
          title: 'Message three customers',
          name: 'send_sms',
          status: ToolCallStatus.approval,
          input: '{"orders": [1042, 1057, 1063]}',
          approval: 'Send an SMS about the delay to Wanjiru, Otieno and Njeri?',
          onApprove: () {},
          onDeny: () {},
        ),
      ],
    ),
  );
}
