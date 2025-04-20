import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Tijuana'));
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> requestNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}

Future<void> showNotification() async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'yourchannelid',
        'yourchannelname',
        importance: Importance.max,
      );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    'Hello, World!',
    'This is a notification message.',
    platformChannelSpecifics,
  );
}

Future<void> notificationProgramada(
  DateTime fechaHora,
  String titulo,
  String mensaje,
  String nombreCliente,
  String fechaServicio,
) async {
  final BigTextStyleInformation bigTextStyleInformation =
      BigTextStyleInformation(
        '''
        <b>El servicio con titulo $nombreCliente</b>,<br><br>
        con descripción: $mensaje<br><br>
        <i>Fecha del servicio:</i> <b>$fechaServicio</b><br><br>        ''',
        htmlFormatBigText: true,
        contentTitle: '<b>$titulo</b>',
        htmlFormatContentTitle: true,
        summaryText: 'Recordatorio de servicio',
        htmlFormatSummaryText: true,
      );
  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    titulo,
    "Fecha Servicio: $fechaServicio",
    tz.TZDateTime.from(fechaHora, tz.local),
    NotificationDetails(
      android: AndroidNotificationDetails(
        'your channel id',
        'your channel name',
        channelDescription: 'your channel description',
        styleInformation: bigTextStyleInformation,
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
}
