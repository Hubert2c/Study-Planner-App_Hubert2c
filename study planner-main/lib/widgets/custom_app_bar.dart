import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    this.title = '',
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title.isEmpty 
          ? Row(
              children: [
                Image.asset(
                  'assets/dplanner-logo.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ],
            )
          : Text(title),
      leading: title.isEmpty ? null : leading,
      actionsPadding: const EdgeInsets.all(12),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
