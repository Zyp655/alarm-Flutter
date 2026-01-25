import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    } catch (e) {
      print("Error setting location: $e");
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleClassNotification({
    required int id,
    required String subject,
    required String room,
    required DateTime startTime,
    required int minutesBefore,
    required bool isRepeating,
  }) async {
    final scheduledDate = startTime.subtract(Duration(minutes: minutesBefore));

    if (!isRepeating && scheduledDate.isBefore(DateTime.now())) {
      return;
    }

    final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Sắp đến giờ học: $subject',
      'Phòng: $room. Bắt đầu lúc ${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}',
      tzScheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'schedule_channel_exact',
          'Lịch học (Chính xác)',
          channelDescription: 'Thông báo nhắc nhở lịch học chính xác',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          visibility: NotificationVisibility.public,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: isRepeating
          ? DateTimeComponents.dayOfWeekAndTime
          : null,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> scheduleExamNotification({
    required int id,
    required String subject,
    required String room,
    required DateTime startTime,
    required int minutesBefore,
  }) async {
    final studyReminderTime = startTime.subtract(const Duration(hours: 24));
    if (studyReminderTime.isAfter(DateTime.now())) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id + 100000, // Offset to avoid collision
        '📚 Nhắc nhở ôn thi: $subject',
        'Còn 24h nữa là đến giờ thi môn $subject. Hãy ôn tập kỹ nhé!',
        tz.TZDateTime.from(studyReminderTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'exam_study_channel',
            'Nhắc nhở ôn thi',
            channelDescription: 'Nhắc nhở trước 24h để ôn tập',
            importance: Importance.high,
            priority: Priority.high,
            color: Colors.blue,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }

    final examReminderTime = startTime.subtract(
      Duration(minutes: minutesBefore),
    );
    if (examReminderTime.isAfter(DateTime.now())) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        ' SẮP THI: $subject',
        'Phòng thi: $room. Giờ thi: ${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}. Đừng đến muộn!',
        tz.TZDateTime.from(examReminderTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'exam_alert_channel',
            'Lịch Thi (Quan trọng)',
            channelDescription: 'Thông báo lịch thi quan trọng',
            importance: Importance.max,
            priority: Priority.max, 
            playSound: true,
            color: Colors.red,
            styleInformation: BigTextStyleInformation(''),
          ),
          iOS: DarwinNotificationDetails(),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  Future<void> scheduleAssignmentNotification({
    required int id,
    required String title,
    required DateTime dueDate,
  }) async {
    final reminderTime = dueDate.subtract(const Duration(hours: 24));
    if (reminderTime.isAfter(DateTime.now())) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id + 200000,
        ' Nhắc nhở bài tập: $title',
        'Hạn nộp bài là ngày mai lúc ${dueDate.hour}:${dueDate.minute.toString().padLeft(2, '0')}. Hãy hoàn thành sớm!',
        tz.TZDateTime.from(reminderTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'assignment_channel',
            'Bài Tập',
            channelDescription: 'Nhắc nhở hạn nộp bài tập',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }

    final urgentTime = dueDate.subtract(const Duration(hours: 1));
    if (urgentTime.isAfter(DateTime.now())) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id + 300000,
        ' GẤP: Sắp hết hạn nộp bài $title',
        'Chỉ còn 1 giờ nữa là hết hạn nộp bài!',
        tz.TZDateTime.from(urgentTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'assignment_urgent_channel',
            'Bài Tập (Khẩn cấp)',
            channelDescription: 'Thông báo khẩn cấp về hạn nộp bài',
            importance: Importance.max,
            priority: Priority.max,
            color: Colors.red,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } else if (dueDate.isAfter(DateTime.now())) {
      await flutterLocalNotificationsPlugin.show(
        id + 300000,
        '⚡ GẤP: Sắp hết hạn nộp bài $title',
        'Hạn nộp: ${dueDate.hour}:${dueDate.minute.toString().padLeft(2, '0')}. Hãy nộp bài ngay!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'assignment_urgent_channel',
            'Bài Tập (Khẩn cấp)',
            channelDescription: 'Thông báo khẩn cấp về hạn nộp bài',
            importance: Importance.max,
            priority: Priority.max,
            color: Colors.red,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  }

  Future<void> showWarningNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'teacher_warning_channel',
          'Cảnh báo Học tập',
          channelDescription: 'Thông báo nguy cơ cấm thi hoặc trượt môn',
          importance: Importance.max,
          priority: Priority.high,
          color: Color(0xFFFF0000),
          playSound: true,
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancel(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
