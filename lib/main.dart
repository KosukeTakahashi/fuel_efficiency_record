import 'package:flutter/material.dart';
import 'package:fuel_efficiency_record/pages/dashboard.dart';
import 'package:fuel_efficiency_record/pages/refuel_history.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      // home: const DashboardPage(),
      // routes: {
      //   '/dashboard': (context) => const DashboardPage(),
      //   '/refuel_history': (context) => const RefuelHistoryPage(),
      // },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/dashboard':
            // return MaterialPageRoute(builder: (context) => const DashboardPage());
            return PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                  const DashboardPage(),
                transitionDuration: const Duration(milliseconds: 150),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  final offsetAnim = secondaryAnimation.drive(Tween(
                    begin: Offset.zero,
                    end: const Offset(-0.2, 0),
                  ).chain(CurveTween(curve: Curves.easeInOutQuint)));
                  final fadeAnim = secondaryAnimation.drive(Tween(
                    begin: 1.0,
                    end: 0.0,
                  ).chain(CurveTween(curve: Curves.easeInOutQuint)));
                  return SlideTransition(
                      position: offsetAnim,
                      child: FadeTransition(
                        opacity: fadeAnim,
                        child: child,
                      )
                  );
                }
            );
          case '/refuel_history':
            // return MaterialPageRoute(builder: (context) => const RefuelHistoryPage());
            return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const RefuelHistoryPage(),
              transitionDuration: const Duration(milliseconds: 150),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                final offsetAnim = animation.drive(Tween(
                  begin: const Offset(0.2, 0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeInOutQuint)));
                final fadeAnim = animation.drive(Tween(
                  begin: 0.0,
                  end: 1.0,
                ).chain(CurveTween(curve: Curves.easeInOutQuint)));
                return SlideTransition(
                  position: offsetAnim,
                  child: FadeTransition(
                    opacity: fadeAnim,
                    child: child,
                  )
                );
              }
            );
        }
        return null;
      },
      initialRoute: '/dashboard',
      debugShowCheckedModeBanner: false,
    );
  }
}
/*
Navigator.of(context).push(
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) {
      return Page2();
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final Offset begin = Offset(1.0, 0.0); // 右から左
      // final Offset begin = Offset(-1.0, 0.0); // 左から右
      final Offset end = Offset.zero;
      final Animatable<Offset> tween = Tween(begin: begin, end: end)
          .chain(CurveTween(curve: Curves.easeInOut));
      final Animation<Offset> offsetAnimation = animation.drive(tween);
      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  ),
);
 */