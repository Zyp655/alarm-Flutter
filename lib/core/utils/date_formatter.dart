class DateFormatter {
  DateFormatter._();

  static String formatRelativeTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút';
    if (diff.inHours < 24) return '${diff.inHours} giờ';
    if (diff.inDays < 7) return '${diff.inDays} ngày';
    return '${time.day}/${time.month}';
  }
}
