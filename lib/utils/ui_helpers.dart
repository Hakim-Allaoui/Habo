import 'package:flutter/material.dart';

/// A widget that can be used to force a rebuild of a specific part of the UI
class RebuildHelper extends StatefulWidget {
  final Widget Function(BuildContext) builder;
  final Object watchObject;

  const RebuildHelper({
    Key? key,
    required this.builder,
    required this.watchObject,
  }) : super(key: key);

  @override
  _RebuildHelperState createState() => _RebuildHelperState();
}

class _RebuildHelperState extends State<RebuildHelper> {
  late Object _watchedObject;

  @override
  void initState() {
    super.initState();
    _watchedObject = widget.watchObject;
  }

  @override
  void didUpdateWidget(RebuildHelper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.watchObject != _watchedObject) {
      setState(() {
        _watchedObject = widget.watchObject;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}

/// Extension method to rebuild a widget when a specific object changes
extension RebuildExtensions on Widget {
  Widget rebuildOn(Object watchObject) {
    return RebuildHelper(
      watchObject: watchObject,
      builder: (_) => this,
    );
  }
}
