// The attachment picture ashlar update --preview draws, from the site's demo.
import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/attachment.dart';

class AttachmentDemo extends StatelessWidget {
  const AttachmentDemo({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 520,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AttachmentGroup(
          children: [
            Attachment(
              title: 'quarterly-report.pdf',
              description: '2.4 MB',
              icon: AshlarIconsRoundedStroke.fileText,
              onPressed: () {},
              actions: [
                AttachmentAction(
                  icon: AshlarIconsRoundedStroke.download,
                  label: 'Download',
                  onPressed: () {},
                ),
              ],
            ),
            const Attachment(
              title: 'site-photos.zip',
              description: 'Uploading, 64%',
              state: AttachmentState.uploading,
            ),
          ],
        ),
        const SizedBox(height: 16),
        AttachmentGroup(
          children: [
            Attachment(
              title: 'budget.xlsx',
              description: 'Too large to send.',
              state: AttachmentState.error,
              actions: [
                AttachmentAction(
                  icon: AshlarIconsRoundedStroke.rotateCw,
                  label: 'Try again',
                  onPressed: () {},
                ),
              ],
            ),
            Attachment(
              title: 'notes.md',
              description: 'Not sent yet',
              state: AttachmentState.idle,
              size: AttachmentSize.sm,
              actions: [
                AttachmentAction(
                  icon: AshlarIconsRoundedStroke.x,
                  label: 'Remove',
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        const AttachmentGroup(
          children: [
            Attachment(
              title: 'design.fig',
              description: 'Reading it',
              axis: Axis.vertical,
              icon: AshlarIconsRoundedStroke.frame,
              state: AttachmentState.processing,
            ),
            Attachment(
              title: 'logo.svg',
              description: '12 KB',
              axis: Axis.vertical,
              icon: AshlarIconsRoundedStroke.image,
            ),
          ],
        ),
      ],
    ),
  );
}
