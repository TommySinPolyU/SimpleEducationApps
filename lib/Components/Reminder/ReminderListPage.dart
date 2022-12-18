/*
 Replaced by FirebaseMessaging
*/
/*
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Helper/ComponentsList.dart';
import '../../Helper/global_setting.dart' as globals;
import 'package:smeapp/Helper/Localizations.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ReminderListPage extends StatefulWidget{
  ReminderListPage({Key key}) : super(key: key);
  @override
  ReminderListPage_State createState() => ReminderListPage_State();
}

class ReminderListPage_State extends State<ReminderListPage> {
  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "";

  final _reminderStartTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _reminderListReload(List<PendingNotificationRequest> pendingNotificationRequests) async {
    List<Widget> thumbs = new List<Widget>();
    globals.reminderListThumb = new List<Widget>();
    print("Reminder List Reload");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (int i=0; i < pendingNotificationRequests.length; i++) {
      Color listitemBgColor = Colors.white;
      Color textColor = Colors.black87;
      List<String> _currentNotification = prefs.getStringList("notification_"+pendingNotificationRequests[i].id.toString());
      print("Loading Element: " + pendingNotificationRequests[i].title);
      print(_currentNotification);
      tz.TZDateTime _currentNotification_Time = tz.TZDateTime.parse(tz.local, _currentNotification[4]);
      print(DateFormat("HH:mm:ss").format(_currentNotification_Time));

      final reminder_setting_selection = Container(
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 0,right: 0, bottom: 10),
                    child: Text(
                        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseCreator_Creator_Title] + ": " + _currentNotification[2].split('- ')[1],
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 16.0,
                          color: appPrimaryColor),
                    ),
                  )
                ],
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 0,right: 0, bottom: 10),
                  child: Text(
                    Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.NotificationManager_SettingCourseReminder_TimeTitle],
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: appPrimaryColor),
                  ),
                )
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black54)
                      ),
                      child: TextFormField(
                        onTap: () {
                          // region onTap Function ==> handle selection of Time
                          FocusScope.of(context).unfocus();
                          DateTime _currentDateTime;
                          _currentDateTime = _reminderStartTimeController.text.isNotEmpty
                              ? DateFormat("HH:mm").parse(_reminderStartTimeController.text)
                              : DateTime(0,0,0,0,0,0);
                          switch(globals.CurrentLang){
                            case Localizations_Language_Identifier.Language_TC:
                              DatePicker.showTimePicker(context,
                                  showTitleActions: true,
                                  showSecondsColumn: false,
                                  onChanged: (time) {
                                    _reminderStartTimeController.text = DateFormat('HH:mm').format(time).toString();
                                  }, onConfirm: (time) {
                                    _reminderStartTimeController.text = DateFormat('HH:mm').format(time).toString();
                                  }, currentTime: _currentDateTime, locale: LocaleType.zh);
                              break;
                            case Localizations_Language_Identifier.Language_Eng:
                              DatePicker.showTimePicker(context,
                                  showTitleActions: true,
                                  showSecondsColumn: false,
                                  onChanged: (time) {
                                    _reminderStartTimeController.text = DateFormat('HH:mm').format(time).toString();
                                  }, onConfirm: (time) {
                                    _reminderStartTimeController.text = DateFormat('HH:mm').format(time).toString();
                                  }, currentTime: _currentDateTime, locale: LocaleType.en);
                              break;
                          }
                          // endregion
                        },
                        textAlign: TextAlign.right,
                        controller: _reminderStartTimeController,
                        keyboardType: TextInputType.text,
                        maxLines: 1,
                        style: TextStyle(
                          color: appPrimaryColor,
                          fontSize: 16,
                        ),
                        readOnly: true,
                        enableInteractiveSelection: false,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(0,15,0,0),
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              icon: Icon(Icons.input),
                            )
                        ),
                      ),
                    )
                )
              ],
            )
          ],
        ),
      );

      // region Item Output UI Design
      final itemCard_new = Card(
        elevation: 8.0,
        child: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: Container(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // region Title Row
                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Align(
                                child: Text(
                                  pendingNotificationRequests[i].title,
                                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20),
                                ),
                                alignment: Alignment.centerLeft,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // endregion
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Align(
                              child: Text(
                                Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_NotificationManager_TimeTitle_Opening] +
                                DateFormat("HH:mm").format(_currentNotification_Time) +
                                Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_NotificationManager_TimeTitle_Ending],
                                style: TextStyle(color: textColor, fontSize: 16),
                              ),
                              alignment: Alignment.centerLeft,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(color: Colors.black38, height: 1),
                  // region Description Button
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: FlatButton.icon(
                                onPressed: () => {
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) => CustomDialog_Confirm(
                                      dialog_type: dialog_Status.Custom,
                                      title: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_NotificationManager_ViewNotificationDesc],
                                      description: pendingNotificationRequests[i].body,
                                      image: Icon(Icons.description),
                                      buttonText: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Close],
                                    ),
                                  )
                                },
                                icon: Icon(Icons.description, color: Colors.black54,),
                                label: Text(
                                  Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_NotificationManager_ViewNotificationDesc],
                                  style: TextStyle(color: Colors.black),)
                            ),
                          ),
                        ),
                      ],
                    ),
                  // endregion
                  Align(
                    alignment: Alignment.centerRight,
                    child: FlatButton.icon(
                        onPressed: () async => {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) =>
                                CustomDialog_Selection(
                                  dialog_type: dialog_Status.Custom,
                                  title: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.NotificationManager_AddCourseReminder],
                                  desc_to_widget: true,
                                  desc_widget: reminder_setting_selection,
                                  image: add_notification_Icon,
                                  callback_Confirm: () async => {
                                    if(_reminderStartTimeController.text.isNotEmpty){
                                      if(tz.TZDateTime.local(
                                          tz.TZDateTime.now(tz.local).year, tz.TZDateTime.now(tz.local).month, tz.TZDateTime.now(tz.local).day,
                                          DateFormat("HH:mm").parse(_reminderStartTimeController.text).hour,
                                          DateFormat("HH:mm").parse(_reminderStartTimeController.text).minute,
                                          0).isAfter(tz.TZDateTime.now(tz.local))){
                                        NotificationSetting.scheduleNotification(
                                            flutterLocalNotificationsPlugin,
                                            Notification_BodyType.values[int.parse(_currentNotification[6])],
                                            _currentNotification[1],
                                            _currentNotification[2],
                                            _currentNotification[3],
                                            tz.TZDateTime.local(
                                                tz.TZDateTime.now(tz.local).year, tz.TZDateTime.now(tz.local).month, tz.TZDateTime.now(tz.local).day,
                                                DateFormat("HH:mm").parse(_reminderStartTimeController.text).hour,
                                                DateFormat("HH:mm").parse(_reminderStartTimeController.text).minute,
                                                0),
                                            repeatFrequency: RepeatInterval.daily),
                                        _dialogStatus = dialog_Status.Success,
                                        dialog_Msg = _currentNotification[2].split('- ')[1] + '\n' +
                                            Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.NotificationManager_ReminderAdded],

                                      } else {
                                        NotificationSetting.scheduleNotification(
                                            flutterLocalNotificationsPlugin,
                                            Notification_BodyType.values[int.parse(_currentNotification[6])],
                                            _currentNotification[1],
                                            _currentNotification[2],
                                            _currentNotification[3],
                                            tz.TZDateTime.local(
                                                tz.TZDateTime.now(tz.local).year, tz.TZDateTime.now(tz.local).month, tz.TZDateTime.now(tz.local).day + 1,
                                                DateFormat("HH:mm").parse(_reminderStartTimeController.text).hour,
                                                DateFormat("HH:mm").parse(_reminderStartTimeController.text).minute,
                                                0),
                                            repeatFrequency: RepeatInterval.daily),
                                        _dialogStatus = dialog_Status.Success,
                                        dialog_Msg = _currentNotification[2].split('- ')[1] + '\n' +
                                            Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.NotificationManager_ReminderAdded],

                                      }
                                    } else {
                                      _dialogStatus = dialog_Status.Error,
                                      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.NotificationManager_SettingCourseReminder_TimeFieldNull],
                                    },

                                    Navigator.of(context).pop(),

                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context) =>
                                          CustomDialog_Confirm(
                                            dialog_type: _dialogStatus,
                                            description: dialog_Msg,
                                            callback_Confirm: () async => {
                                              await NotificationSetting.getNotificationList(flutterLocalNotificationsPlugin),
                                              globals.reminderListReloaded = false,
                                              _reminderListReload(globals.reminderList),
                                              Navigator.of(context).pop(),
                                            },
                                          ),
                                    )
                                  },
                                ),
                          ),
                        },
                        icon: add_notification_Icon,
                        label: Text(
                          Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.NotificationManager_AddCourseReminder],
                          style: TextStyle(color: Colors.black, fontSize: 14),)
                    ),
                  ),
                  // region View Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FlatButton.icon(
                              onPressed: () => {
                                showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (BuildContext context) => CustomDialog_Selection(
                                    dialog_type: dialog_Status.Warning,
                                    description:
                                    Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_NotificationManager_DeleteWarning],
                                    callback_Confirm: () async => {
                                      await NotificationSetting.turnOffNotificationById(flutterLocalNotificationsPlugin, pendingNotificationRequests[i].id),
                                      globals.reminderListReloaded = false,
                                      await NotificationSetting.getNotificationList(flutterLocalNotificationsPlugin),
                                      _reminderListReload(globals.reminderList),
                                      Navigator.of(context).pop(),
                                    },
                                  ),
                                )
                              },
                              icon: Icon(Icons.delete_forever, color: Colors.black54,),
                              label: Text(
                                Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_NotificationManager_Delete],
                                style: TextStyle(color: Colors.black),)
                          ),
                        ),
                      ),
                    ],
                  ),
                  // endregion
                ],
              ),
            ),
          ),
        ),
      );

      //endregion
      await thumbs.add(
          Container(
          child: Padding(
            child: itemCard_new,
            padding: EdgeInsets.only(top: 5, bottom: 5),
          )
      ));
    }

    setState(() {
      print("SetState");
      globals.reminderListThumb = thumbs;
    });
    globals.reminderListReloaded = true;
  }

  @override
  Widget build(BuildContext context) {

    if(globals.reminderListReloaded != true) {
      print("call Reload");
      _reminderListReload(globals.reminderList);
    }

    if (globals.reminderList.length == 0) {
      globals.reminderListThumb = [
        InkWell(
          child: Container(
              alignment: Alignment.center,
              child: Text(Localizations_Text[globals
                  .CurrentLang][Localizations_Text_Identifier
                  .Course_Page_NoAnyContent],
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),)
          ),
        )
      ];
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_NotificationManager_Insidetitle]),
          centerTitle: true,
          actions: <Widget>[
            FlatButton(
              onPressed: () async => {
                globals.reminderListReloaded = false,
                NotificationSetting.getNotificationList(flutterLocalNotificationsPlugin),
                _reminderListReload(globals.reminderList),
                },
              child: Icon(Icons.refresh, color: Colors.white,),)
          ],
        ),
        body: Stack(
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Visibility(
                  visible: globals.canUpload,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      /*
                      SizedBox(width: 15,),
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              width: double.infinity,
                              child: FlatButton.icon(
                                icon: Icon(Icons.add),
                                label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_Editor_Create_AppBarTitle]),
                                textColor: Colors.white,
                                color: Colors.lightBlue,
                                onPressed: () async => {
                                  globals.survey_isEditing = false,
                                  globals.edit_isSurveyDataLoaded = false,
                                  Navigator.of(context).push(globals.gotoPage(SurveyEditor(), Duration(seconds: 0, milliseconds: 500)))
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(width: 15,)

                       */
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 20),
                    child: ListView.builder(
                        padding: EdgeInsets.only(left: 10,right: 10),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: globals.reminderListThumb.length, // number of items in your list
                        //here the implementation of itemBuilder. take a look at flutter docs to see details
                        itemBuilder: (BuildContext context, int Itemindex){
                          return globals.reminderListThumb[Itemindex]; // return your widget
                        }
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
    );
 import 'package:smeapp/Helper/ComponentsList.dart';
 }
}

*/