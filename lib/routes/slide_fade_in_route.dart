import 'package:flutter/material.dart';

class SlideFadeInRoute extends PopupRoute {
  SlideFadeInRoute({
    required this.widget,
  });

  final Widget widget;

  @override
  Color? get barrierColor => Colors.black54;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // return ScaleTransition(
    //   scale: animation.drive(Tween(begin: 0.3, end: 1.0).chain(CurveTween(curve: Curves.easeOut))),
    //   child: child,
    // );
    return SlideTransition(
      position: animation.drive(
          Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).chain(
              CurveTween(
                  curve: Curves.easeOutExpo))),
      child: FadeTransition(
        opacity: animation.drive(Tween(begin: 0.3, end: 1.0).chain(CurveTween(
            curve: Curves.easeOutExpo))),
        child: child,
      ),
    );
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return widget;
  }
}

// class _SpreadTransition extends AnimatedWidget {
//   const _SpreadTransition({
//     required this.animation,
//     required this.child,
//   }): super(listenable: animation);
//
//   final Animation<double> animation;
//   final Widget child;
//
//   @override
//   Widget build(BuildContext context) {
//     return
//   }
// }
