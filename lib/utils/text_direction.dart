import 'package:flutter/material.dart';

TextDirection textDirectionFor(String languageCode) {
  return (languageCode == 'ur' || languageCode == 'ar')
      ? TextDirection.rtl
      : TextDirection.ltr;
}
