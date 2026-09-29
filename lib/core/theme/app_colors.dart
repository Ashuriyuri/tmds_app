import 'package:flutter/material.dart';

abstract final class AppColors {
  static const burgundy = Color(0xff8b0d1b);
  static const burgundyDark = Color(0xff5c0913);
  static const burgundyLight = Color(0xfffdf2f3);
  static const ink = Color(0xff1e293b);
  static const paper = Color(0xfff8fafc);
  static const muted = Color(0xff64748b);
  static const border = Color(0xffe2e8f0);

  // Status colors matching Figma
  static const statusInProgressBg = Color(0xfffff7ed);
  static const statusInProgressText = Color(0xffc2410c);

  static const statusPendingBg = Color(0xffeff6ff);
  static const statusPendingText = Color(0xff1d4ed8);

  static const statusCompletedBg = Color(0xffecfdf5);
  static const statusCompletedText = Color(0xff059669);

  static const success = Color(0xff10b981);
  static const warning = Color(0xfff59e0b);
}
