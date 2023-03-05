import 'package:flutter/material.dart';

class Android13StyleRoute extends PageRoute {
  Android13StyleRoute({
    required this.widget,
  });

  final Widget widget;

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 150);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) => widget;

  @override
  bool get maintainState => true;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final offsetAnim = animation.drive(Tween(
      begin: const Offset(0.2, 0),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeInOutQuint)));
    final fadeAnim = animation.drive(Tween(
      begin: 0.0,
      end: 1.0,
    ).chain(CurveTween(curve: Curves.easeInOutQuint)));
    final secondaryOffsetAnim = secondaryAnimation.drive(Tween(
      begin: Offset.zero,
      end: const Offset(-0.2, 0),
    ).chain(CurveTween(curve: Curves.easeInOutQuint)));
    final secondaryFadeAnim = secondaryAnimation.drive(Tween(
      begin: 1.0,
      end: 0.0,
    ).chain(CurveTween(curve: Curves.easeInOutQuint)));

    return SlideTransition(
      position: offsetAnim,
      child: FadeTransition(
        opacity: fadeAnim,
        child: SlideTransition(
          position: secondaryOffsetAnim,
          child: FadeTransition(
            opacity: secondaryFadeAnim,
            child: child,
          ),
        ),
      ),
    );
  }
}
