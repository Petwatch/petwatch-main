//palette.dart
import 'package:flutter/material.dart';

class Palette {
  static const MaterialColor petWatchGreen = const MaterialColor(
    0xff5db075, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    const <int, Color>{
      50: const Color(0xff549e69), //10%
      100: const Color(0xff4a8d5e), //20%
      200: const Color(0xff417b52), //30%
      300: const Color(0xff386a46), //40%
      400: const Color(0xff2f583b), //50%
      500: const Color(0xff25462f), //60%
      600: const Color(0xff1c3523), //70%
      700: const Color(0xff132317), //80%
      800: const Color(0xff09120c), //90%
      900: const Color(0xff000000), //100%
    },
  );
} // you can define define int 500 as the default shade and add your lighter tints above and darker tints below.
