import 'package:atpl_flashing_app/common_widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final bool showDrawer;

  const MainLayout({
    super.key,
    required this.child,
    required this.title,
    this.showDrawer = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: (isMobile && showDrawer) ? CustomDrawer() : null,
      appBar: isMobile
          ? AppBar(
              title: Text(title,
                  style: const TextStyle(color: Colors.white, fontSize: 18)),
              backgroundColor: const Color(0xFF0055BB),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile && showDrawer) CustomDrawer(),
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: !isMobile
                  ? AppBar(
                      backgroundColor: Colors.white,
                      elevation: 1,
                      title: Text(title,
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    )
                  : null,
              body: child,
            ),
          ),
        ],
      ),
    );
  }
}