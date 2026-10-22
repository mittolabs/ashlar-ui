// The plan picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/plan.dart';

class PlanDemo extends StatelessWidget {
  const PlanDemo({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 460,
    child: Plan(
      title: 'Move the orders table',
      steps: [
        PlanStep('Back up the table', status: PlanStepStatus.done),
        PlanStep('Make the new table', status: PlanStepStatus.done),
        PlanStep('Copy the rows across', status: PlanStepStatus.active, detail: '1.2M of 2M rows'),
        PlanStep('Switch reads over'),
        PlanStep('Drop the old table'),
      ],
    ),
  );
}
