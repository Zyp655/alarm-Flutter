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
