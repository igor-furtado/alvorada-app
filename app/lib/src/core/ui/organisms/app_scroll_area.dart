import 'package:flutter/material.dart';

class AppScrollArea extends StatefulWidget {
  const AppScrollArea({required this.child, this.axis = Axis.vertical, this.controller, super.key});

  final Widget child;
  final Axis axis;
  final ScrollController? controller;

  @override
  State<AppScrollArea> createState() => _AppScrollAreaState();
}

class _AppScrollAreaState extends State<AppScrollArea> {
  ScrollController? _ownedController;

  ScrollController get _controller => widget.controller ?? (_ownedController ??= ScrollController());

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scrollbar(
    controller: _controller,
    thumbVisibility: true,
    child: SingleChildScrollView(
      controller: _controller,
      scrollDirection: widget.axis,
      child: widget.child,
    ),
  );
}
