import 'package:flutter/material.dart';

class BannerOverlay extends StatelessWidget {
  final Widget child;
  final String bannerText;

  const BannerOverlay(
      {super.key, required this.child, this.bannerText = 'DEBUG'});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          right: 0,
          child: Banner(
            message: bannerText,
            location: BannerLocation.topEnd,
            color: Colors.red.withOpacity(0.6),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
