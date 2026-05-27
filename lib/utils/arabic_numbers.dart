String toArabicDigits(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  
  String result = input;
  for (int i = 0; i < english.length; i++) {
    result = result.replaceAll(english[i], arabic[i]);
  }
  return result;
}

String formatMinutesToDuration(int minutes, String langCode) {
  final hours = minutes ~/ 60;
  final mins = minutes % 60;
  
  String label;
  if (hours > 0) {
    label = '${hours}h ${mins}m';
  } else {
    label = '${mins}m';
  }
  
  if (langCode == 'ur' || langCode == 'ar') {
    return toArabicDigits(label);
  }
  return label;
}
