import 'package:flutter/material.dart';
import 'package:dplanner/widgets/custom_app_bar.dart';
import 'package:dplanner/widgets/custom_bottom_navigation.dart';
import 'package:dplanner/widgets/custom_floating_action_button.dart';

class MainLayout extends StatelessWidget {
  final Widget body;
  final String? title;
  final int currentIndex;
  final VoidCallback? onFloatingActionPressed;
  final String? floatingActionTooltip;
  final Future<dynamic> Function()? onCalendarPressed;

  const MainLayout({
    super.key,
    required this.body,
    this.title,
    required this.currentIndex,
    this.onFloatingActionPressed,
    this.floatingActionTooltip,
    this.onCalendarPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: title ?? ''),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          ),
        ),
        child: body,
      ),
      floatingActionButton: onFloatingActionPressed != null
          ? CustomFloatingActionButton(
              onPressed: onFloatingActionPressed!,
              tooltip: floatingActionTooltip ?? 'Add new task',
            )
          : null,
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              break;
            case 1:
              if (onCalendarPressed != null) {
                onCalendarPressed!();
              } else {
                Navigator.pushNamed(context, '/calendar');
              }
              break;
            case 2:
              Navigator.pushNamed(context, '/settings');
              break;
          }
        },
      ),
    );
  }
}
