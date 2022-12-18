/*
import 'dart:async';

import 'package:smeapp/Helper/Localizations.dart';

import 'ComponentsList.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:rxdart/subjects.dart';
import 'global_setting.dart' as globals;

enum Notification_BodyType {
  CourseReminder,
  LoginReminder,
  SystemReminder
}

class ReceivedNotification {
  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}

class NotificationSetting{
  static final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
  BehaviorSubject<ReceivedNotification>();

  static final BehaviorSubject<String> selectNotificationSubject =
  BehaviorSubject<String>();

  static SharedPreferences prefs;


  static Future<void> initNotifications(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    await _configureLocalTimeZone();
    prefs = await SharedPreferences.getInstance();
    var initializationSettingsAndroid = AndroidInitializationSettings('launcher_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) async {
          didReceiveLocalNotificationSubject.add(ReceivedNotification(
              id: id, title: title, body: body, payload: payload));
        });
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
          if (payload != null) {
            debugPrint('notification payload: ' + payload);
          }
          selectNotificationSubject.add(payload);
        });
    selectNotificationSubject.stream.listen((String payload) async {
      // your code
    });
  }

  static Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    String timezone = await FlutterNativeTimezone.getLocalTimezone();
    print(timezone);
    tz.setLocalLocation(tz.getLocation("Asia/Hong_Kong"));
  }

  static Future<void> scheduleNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
      Notification_BodyType notification_bodyType,
      String id,
      String title,
      String body,
      tz.TZDateTime scheduledNotificationDateTime,
      {RepeatInterval repeatFrequency}) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      id,
      'Reminder notifications',
      'Remember about it',
      icon: 'launcher_icon',
    );
    List<String> notification_data = new List<String> ();
    String noti_type = "DateTime";
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    /*
    if(scheduledNotificationDateTime.isBefore(now)){
      final int _daydiff = now.day - scheduledNotificationDateTime.day;
      print(_daydiff);
      scheduledNotificationDateTime = scheduledNotificationDateTime.add(Duration(days: _daydiff + 1));
    }
     */
    //scheduledNotificationDateTime = scheduledNotificationDateTime.subtract(Duration(days: 1));
    if(repeatFrequency != null) {
      print(repeatFrequency);
      await flutterLocalNotificationsPlugin.periodicallyShow(
          int.parse(id), title, body, repeatFrequency, platformChannelSpecifics, androidAllowWhileIdle: true);
    } else {
      await flutterLocalNotificationsPlugin.zonedSchedule(
          int.parse(id), title, body,
          scheduledNotificationDateTime, platformChannelSpecifics,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime);
    }
    notification_data.add(noti_type);
    notification_data.add(id);
    notification_data.add(title);
    notification_data.add(body);
    notification_data.add(scheduledNotificationDateTime.toString());
    notification_data.add(repeatFrequency.index.toString());
    notification_data.add(notification_bodyType.index.toString());
    prefs.setStringList("notification_" + id, notification_data);
  }

  static Future<void> scheduleNotificationPeriodically (
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
      Notification_BodyType notification_bodyType,
      String id,
      String title,
      String body,
      RepeatInterval interval) async {
    print("Set a Notification: " + id);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      id,
      'Reminder notifications',
      'Remember about it',
      icon: 'launcher_icon',
    );
    List<String> notification_data = new List<String> ();
    String noti_type = "Period";
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.periodicallyShow(
        int.parse(id), title, body, interval, platformChannelSpecifics, androidAllowWhileIdle: true);
    notification_data.add(noti_type);
    notification_data.add(id);
    notification_data.add(title);
    notification_data.add(body);
    notification_data.add(interval.index.toString());
    notification_data.add(notification_bodyType.index.toString());
    prefs.setStringList("notification_" + id, notification_data);
  }

  static Future<bool> getNotificationList(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
      globals.reminderList = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      await Future.forEach(globals.reminderList,(element) async {
        List<String> _currentNotificationData = new List<String>();
        _currentNotificationData = prefs.getStringList("notification_" + element.id.toString());
        Notification_BodyType _bodytype;
        await turnOffNotificationById(flutterLocalNotificationsPlugin, element.id);
        switch(_currentNotificationData[0]) {
          case "DateTime":
            _bodytype = Notification_BodyType.values[int.parse(_currentNotificationData[6])];
            if(_currentNotificationData[5] != null){
              switch(_bodytype){
                case Notification_BodyType.CourseReminder:
                  await scheduleNotification(
                      flutterLocalNotificationsPlugin,
                      _bodytype,
                      _currentNotificationData[1], // ID
                      _currentNotificationData[2], // Title
                      _currentNotificationData[3], // Body
                      tz.TZDateTime.parse(tz.local, _currentNotificationData[4]), // DateTime of Pushing the notification
                      repeatFrequency: RepeatInterval.values[int.parse(_currentNotificationData[5])] // The repeat frequency of the notification
                  );
                  break;
              }
            } else {
              switch(_bodytype){
                case Notification_BodyType.CourseReminder:
                  await scheduleNotification(
                      flutterLocalNotificationsPlugin,
                      _bodytype,
                      _currentNotificationData[1], // ID
                      _currentNotificationData[2], // Title
                      _currentNotificationData[3], // Body
                      tz.TZDateTime.parse(tz.local, _currentNotificationData[4]), // DateTime for pushing the notification
                      repeatFrequency: null
                  );
                  break;
              }
            }
            break;
        }
      });
      return true;
  }

  // translate all the notification in list to selected language
  // The Function will change all the Notification title and text to user-selected language
  static Future<void> translate_AllNotification(Localizations_Language_Identifier from, Localizations_Language_Identifier to) async{
    await getNotificationList(flutterLocalNotificationsPlugin);
    globals.reminderList.forEach((element) async {
      List<String> _currentNotificationData = new List<String>();
      _currentNotificationData = prefs.getStringList("notification_" + element.id.toString());
      Notification_BodyType _bodytype;
      await turnOffNotificationById(flutterLocalNotificationsPlugin, element.id);
      switch(_currentNotificationData[0]) {
        case "DateTime":
          _bodytype = Notification_BodyType.values[int.parse(_currentNotificationData[6])];
          if(_currentNotificationData[5] != null){
            switch(_bodytype){
              case Notification_BodyType.CourseReminder:
                await scheduleNotification(
                    flutterLocalNotificationsPlugin,
                    _bodytype,
                    _currentNotificationData[1], // ID
                    _currentNotificationData[2].replaceAll(
                        Localizations_Text[from][Localizations_Text_Identifier.NotificationManager_CourseReminderTitle],
                        Localizations_Text[to][Localizations_Text_Identifier.NotificationManager_CourseReminderTitle]), // Title
                    _currentNotificationData[3].replaceAll(
                        Localizations_Text[from][Localizations_Text_Identifier.NotificationManager_CourseReminderContentOpening],
                        Localizations_Text[to][Localizations_Text_Identifier.NotificationManager_CourseReminderContentOpening]), // // Body
                    tz.TZDateTime.parse(tz.local, _currentNotificationData[4]), // DateTime of Pushing the notification
                    repeatFrequency: RepeatInterval.values[int.parse(_currentNotificationData[5])] // The repeat frequency of the notification
                );
                break;
            }
          } else {
            switch(_bodytype){
              case Notification_BodyType.CourseReminder:
                await scheduleNotification(
                    flutterLocalNotificationsPlugin,
                    _bodytype,
                    _currentNotificationData[1], // ID
                    _currentNotificationData[2].replaceAll(
                        Localizations_Text[from][Localizations_Text_Identifier.NotificationManager_CourseReminderTitle],
                        Localizations_Text[to][Localizations_Text_Identifier.NotificationManager_CourseReminderTitle]), // Title
                    _currentNotificationData[3].replaceAll(
                        Localizations_Text[from][Localizations_Text_Identifier.NotificationManager_CourseReminderContentOpening],
                        Localizations_Text[to][Localizations_Text_Identifier.NotificationManager_CourseReminderContentOpening]), // Body
                    tz.TZDateTime.parse(tz.local, _currentNotificationData[4]), // DateTime for pushing the notification
                    repeatFrequency: null
                );
                break;
            }
          }
          break;
      }
    });
  }

  static Future<void> turnOffAllNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  static Future<void> turnOffNotificationById(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
      num id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    prefs.remove("notification_" + id.toString());
  }

}
*/