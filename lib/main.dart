import 'package:flutter/material.dart';
import 'package:fuel_efficiency_record/pages/dashboard.dart';
import 'package:fuel_efficiency_record/pages/refuel_entry_details.dart';
import 'package:fuel_efficiency_record/pages/refuel_history.dart';
import 'package:fuel_efficiency_record/pages/vehicles_list.dart';
import 'package:fuel_efficiency_record/routes/android13_style_route.dart';

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
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/vehicles_list':
            return Android13StyleRoute(widget: const VehiclesListPage());
          case '/dashboard':
            return Android13StyleRoute(
              widget: DashboardPage(
                dashboardArgs: settings.arguments as DashboardPageArgs,
              ),
            );
          case '/refuel_history':
            return Android13StyleRoute(
              widget: RefuelHistoryPage(
                refuelHistoryArgs: settings.arguments as RefuelHistoryPageArgs,
              ),
            );
          case '/refuel_entry_details':
            return Android13StyleRoute(
              widget: RefuelEntryDetailsPage(
                refuelEntryArgs:
                    settings.arguments as RefuelEntryDetailsPageArgs,
              ),
            );
        }
        return null;
      },
      initialRoute: '/vehicles_list',
      debugShowCheckedModeBanner: false,
    );
  }
}
