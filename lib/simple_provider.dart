import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// A very small subset of the functionality offered by the `provider` package.
/// It is sufficient for the sample app which only needs a [ChangeNotifier]
/// based provider with `watch`/`read` helpers on [BuildContext].
class ChangeNotifierProvider<T extends ChangeNotifier> extends StatefulWidget {
  const ChangeNotifierProvider({
    Key? key,
    required this.create,
    required this.child,
  }) : super(key: key);

  final T Function(BuildContext) create;
  final Widget child;

  @override
  State<ChangeNotifierProvider<T>> createState() => _ChangeNotifierProviderState<T>();

  static T _watch<T extends ChangeNotifier>(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<_InheritedProvider<T>>();
    assert(provider != null, 'No ChangeNotifierProvider<$T> found in context');
    return provider!.notifier!;
  }

  static T _read<T extends ChangeNotifier>(BuildContext context) {
    final element =
        context.getElementForInheritedWidgetOfExactType<_InheritedProvider<T>>();
    final provider = element?.widget as _InheritedProvider<T>?;
    assert(provider != null, 'No ChangeNotifierProvider<$T> found in context');
    return provider!.notifier!;
  }
}

class _ChangeNotifierProviderState<T extends ChangeNotifier>
    extends State<ChangeNotifierProvider<T>> {
  late T _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = widget.create(context);
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedProvider<T>(notifier: _notifier, child: widget.child);
  }
}

class _InheritedProvider<T extends ChangeNotifier> extends InheritedNotifier<T> {
  const _InheritedProvider({
    Key? key,
    required T notifier,
    required Widget child,
  }) : super(key: key, notifier: notifier, child: child);
}

extension SimpleProviderContext on BuildContext {
  /// Obtain the nearest provided [ChangeNotifier] and subscribe to changes.
  T watch<T extends ChangeNotifier>() =>
      ChangeNotifierProvider._watch<T>(this);

  /// Obtain the nearest provided [ChangeNotifier] without subscribing.
  T read<T extends ChangeNotifier>() =>
      ChangeNotifierProvider._read<T>(this);
}
