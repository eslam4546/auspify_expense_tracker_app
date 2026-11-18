import 'package:flutter/material.dart';

/// Centralized utility for resolving Category IconData safely without lint warnings.
class IconHelper {
  IconHelper._();

  /// Returns [IconData] for a dynamic [codePoint].
  static IconData getCategoryIcon(int codePoint) {
    // ignore: non_const_argument_for_const_parameter
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }
}

