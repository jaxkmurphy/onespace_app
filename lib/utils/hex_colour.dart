import 'package:flutter/material.dart';

class HexColor extends Color {
  HexColor(final String hex)
      : super(int.parse(hex.replaceFirst('#', '0xff')));
}