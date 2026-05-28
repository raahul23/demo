class DateTimeUtils {
  static DateTime now() => DateTime.now();

  static String formatDate(DateTime dateTime) {
    final month = _monthAbbrev(dateTime.month);
    return "$month ${dateTime.day}, ${dateTime.year}";
  }

  static String formatDateTime(DateTime dateTime) {
    final month = _monthAbbrev(dateTime.month);
    return "$month ${dateTime.day}, ${formatTime24(dateTime)}";
  }

  static String formatTime24(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final suffix = dateTime.hour >= 12 ? "PM" : "AM";
    return "${_twoDigits(hour)}:${_twoDigits(dateTime.minute)} $suffix";
  }

  static String formatTime12(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final suffix = dateTime.hour >= 12 ? "PM" : "AM";
    return "${_twoDigits(hour)}:${_twoDigits(dateTime.minute)} $suffix";
  }

  static String dayLabel(DateTime dateTime, {DateTime? reference}) {
    final now = reference ?? DateTime.now();
    if (_isSameDate(dateTime, now)) return "Today";
    final yesterday = now.subtract(const Duration(days: 1));
    if (_isSameDate(dateTime, yesterday)) return "Yesterday";
    return formatDate(dateTime);
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, "0");

  static String _monthAbbrev(int month) {
    switch (month) {
      case 1:
        return "Jan";
      case 2:
        return "Feb";
      case 3:
        return "Mar";
      case 4:
        return "Apr";
      case 5:
        return "May";
      case 6:
        return "Jun";
      case 7:
        return "Jul";
      case 8:
        return "Aug";
      case 9:
        return "Sep";
      case 10:
        return "Oct";
      case 11:
        return "Nov";
      case 12:
        return "Dec";
      default:
        return "";
    }
  }

  static bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
