import 'package:flutter/material.dart';

/// A [SafeArea] with an enabled toggle
class SimpleSafeArea extends StatelessWidget {
  /// Constructor for [SimpleSafeArea]
  const SimpleSafeArea({
    super.key,
    this.enabled = true,
    required this.child,
  });

  /// Wrap [child] with [SafeArea]
  final bool enabled;

  /// Child widget to wrap
  final Widget child;

  @override
  Widget build(BuildContext context) => SafeArea(
        left: enabled,
        top: enabled,
        right: enabled,
        bottom: enabled,
        child: child,
      );
}
