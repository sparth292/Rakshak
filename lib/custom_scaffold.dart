import 'package:flutter/material.dart';
class CustomScaffold extends StatelessWidget {
  const CustomScaffold({super.key, required this.child, required this.resizeToAvoidBottomInset});
  final Widget child;
  final bool resizeToAvoidBottomInset;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Image.asset(
            "assets/images/login_bg.png",
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          Center(
            child: SafeArea(
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}