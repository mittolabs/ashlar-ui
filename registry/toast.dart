// Ashlar UI: Toast. Copied into your app by `ashlar add toast`; it is yours to change.

import 'dart:async';

import 'package:flutter/widgets.dart';

import 'theme.dart';

/// Shows a short message at the bottom of the screen that goes by itself after
/// [duration]. It stays while the pointer is over it, and a swipe sends it away. A screen
/// reader reads it out. Up to three show at once; the newest is at the bottom.
///
/// ```dart
/// showToast(context, title: 'Payment sent', description: 'KES 2,400 to Wanjiru.')
/// showToast(context, title: 'Event deleted', action: Button(size: ButtonSize.sm, onPressed: undo, child: Text('Undo')))
/// ```
void showToast(
  BuildContext context, {
  required String title,
  String? description,
  Widget? icon,
  Widget? action,
  Duration duration = const Duration(seconds: 4),
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  final host = _hosts[overlay] ??= _ToastHost(overlay, AshlarTheme.of(context));
  host.add(
    _Toast(
      title: title,
      description: description,
      icon: icon,
      action: action,
      duration: duration,
    ),
  );
}

final _hosts = Expando<_ToastHost>();

class _Toast {
  _Toast({
    required this.title,
    this.description,
    this.icon,
    this.action,
    required this.duration,
  });

  final String title;
  final String? description;
  final Widget? icon;
  final Widget? action;
  final Duration duration;
  final key = UniqueKey();
}

/// The column of toasts, in one entry on the root overlay.
class _ToastHost {
  _ToastHost(this.overlay, this.theme) {
    entry = OverlayEntry(
      builder: (_) => AshlarTheme(
        data: theme,
        child: _ToastStack(host: this),
      ),
    );
    overlay.insert(entry);
  }

  final OverlayState overlay;
  final AshlarThemeData theme;
  late final OverlayEntry entry;
  final toasts = ValueNotifier<List<_Toast>>([]);

  void add(_Toast toast) {
    final list = [...toasts.value, toast];
    toasts.value = list.length > 3 ? list.sublist(list.length - 3) : list;
  }

  void remove(_Toast toast) => toasts.value = [...toasts.value]..remove(toast);
}

class _ToastStack extends StatelessWidget {
  const _ToastStack({required this.host});

  final _ToastHost host;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return ValueListenableBuilder(
      valueListenable: host.toasts,
      builder: (context, toasts, _) => toasts.isEmpty
          ? const SizedBox.shrink()
          : Positioned(
              right: 16 + padding.right,
              bottom: 16 + padding.bottom,
              left: 16 + padding.left,
              child: Align(
                alignment: Alignment.bottomRight,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 356),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final toast in toasts)
                        Padding(
                          key: toast.key,
                          padding: const EdgeInsets.only(top: 8),
                          child: _ToastCard(
                            toast: toast,
                            onDone: () => host.remove(toast),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _ToastCard extends StatefulWidget {
  const _ToastCard({required this.toast, required this.onDone});

  final _Toast toast;
  final VoidCallback onDone;

  @override
  State<_ToastCard> createState() => _ToastCardState();
}

class _ToastCardState extends State<_ToastCard>
    with SingleTickerProviderStateMixin {
  late final _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  )..forward();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() => _timer = Timer(widget.toast.duration, _leave);

  Future<void> _leave() async {
    _timer?.cancel();
    if (!mounted) return;
    await _enter.reverse();
    widget.onDone();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final toast = widget.toast;
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.popover,
        borderRadius: BorderRadius.circular(t.radiusMd),
        border: Border.all(color: c.border),
        boxShadow: t.shadowLg,
      ),
      child: IconTheme.merge(
        data: IconThemeData(color: c.popoverForeground, size: 16),
        child: Row(
          children: [
            if (toast.icon != null) ...[toast.icon!, const SizedBox(width: 12)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    toast.title,
                    style: t.text.sm.copyWith(
                      color: c.popoverForeground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (toast.description != null)
                    Text(
                      toast.description!,
                      style: t.text.sm.copyWith(color: c.mutedForeground),
                    ),
                ],
              ),
            ),
            if (toast.action != null) ...[
              const SizedBox(width: 12),
              toast.action!,
            ],
          ],
        ),
      ),
    );
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final curve = CurvedAnimation(parent: _enter, curve: Curves.easeOut);
    return Semantics(
      liveRegion: true,
      container: true,
      child: MouseRegion(
        onEnter: (_) => _timer?.cancel(),
        onExit: (_) => _start(),
        child: Dismissible(
          key: toast.key,
          direction: DismissDirection.horizontal,
          onDismissed: (_) => widget.onDone(),
          child: still
              ? card
              : FadeTransition(
                  opacity: curve,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0, .5),
                      end: Offset.zero,
                    ).animate(curve),
                    child: card,
                  ),
                ),
        ),
      ),
    );
  }
}
