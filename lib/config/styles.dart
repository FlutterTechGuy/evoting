import 'package:flutter/material.dart';

class BoxStyles {
  static const BoxDecoration gradientBox = BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Colors.green,
          ]));
}
