import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sahiyar_club/controllers/splash_controller.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final SplashController splashController = Get.find<SplashController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          SizedBox.expand(
            child: Image.asset('assets/images/bg.png', fit: BoxFit.cover),
          ),

          // Optional overlay content (e.g. logo, loader)
          Center(
            child: SizedBox.fromSize(
              size: Size(300, 300),
              child: Hero(
                tag: "logo",
                child: Image.asset(
                  'assets/images/sc_logo.png',
                  height: 300,
                  width: 300,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
