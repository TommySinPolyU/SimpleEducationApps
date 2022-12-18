import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:smeapp/Components/CourseCreator/CourseEditor.dart';
import 'package:smeapp/CustomWidget/CustomDialog.dart';
import 'package:smeapp/Helper/fetch_data_function.dart';
import 'package:smeapp/Helper/refresh_page_function.dart';
import '../../Helper/ComponentsList.dart';
import '../../Helper/global_setting.dart' as globals;
import 'package:smeapp/Helper/Localizations.dart';
import 'package:select_dialog/select_dialog.dart';
import '../../Helper/JsonItemConvertor.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class CourseListPage extends StatefulWidget{
  CourseListPage({Key key}) : super(key: key);
  @override
  CourseListPage_State createState() => CourseListPage_State();
}

class CourseListPage_State extends State<CourseListPage> {
  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "";

  final _reminderStartTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _courseListReload(List<CourseListItem> courselist) async {
    List<Widget> thumbs = new List<Widget>();
    globals.courseListThumb = new List<Widget>();
    //print("Course List Reload");

    for (int i=0; i < courselist.length; i++) {
      Color listitemBgColor;
      Color textColor = Colors.black87;
      if(globals.canUpload){
        if(DateTime.now().toUtc().isBefore(courselist[i].coursePeriod_End) && courselist[i].coursePeriod_Start.isAfter(DateTime.now().toUtc())){
          listitemBgColor = Colors.orange;
        } else if(courselist[i].coursePeriod_End.isBefore(DateTime.now().toUtc()) && DateTime.now().toUtc().isAfter(courselist[i].coursePeriod_Start)) {
          listitemBgColor = Colors.redAccent;
        } else {
          listitemBgColor = Colors.green;
        }
      } else
        listitemBgColor = Colors.green;

      //print("Loading Element: " + courselist[i].courseName);
      // region Item Output UI Design

      final reminder_setting_selection = Container(
        child: Column(
          children: [
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
                        fontSize: globals.fontSize_Normal,
                        color: appPrimaryColor),
                  ),
                )
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 0,right: 0, bottom: 10),
                  child: Text(
                    Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseCreator_Creator_Title] + ": " + courselist[i].courseName,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: globals.fontSize_Normal,
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
                          fontSize: globals.fontSize_Normal,
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
                                  courselist[i].courseName,
                                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: globals.fontSize_Big),
                                ),
                                alignment: Alignment.centerLeft,
                              )
                            ],
                          ),
                          flex: 9,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Icon(Icons.circle, color: listitemBgColor,)
                            ],
                          ),
                          flex: 1,
                        )
                      ],
                    ),
                  ),
                  // endregion
                  Container(color: Colors.black38, height: 1),
                  // region View Details and Module Button
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            Visibility(
                              visible: courselist[i].attachment_Checked_Count / courselist[i].moduleAttachmentCount == 1,
                              child: tips_success_Icon,
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 7,
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: FlatButton.icon(
                                  onPressed: () => {
                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context) => CustomDialog_Confirm(
                                        dialog_type: dialog_Status.Custom,
                                        title: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_Page_ViewDescription],
                                        description: courselist[i].courseDesc,
                                        image: Icon(Icons.description),
                                        buttonText: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Close],
                                      ),
                                    )
                                  },
                                  icon: Icon(Icons.description, color: Colors.black54,),
                                  label: Text(
                                    Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_Page_ViewDescription],
                                    style: TextStyle(color: Colors.black, fontSize: globals.fontSize_Normal),)
                              ),
                            ),
                            /*
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
                                                      Notification_BodyType.CourseReminder,
                                                      courselist[i].courseID.toString(),
                                                      Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.NotificationManager_CourseReminderTitle] +
                                                          courselist[i].courseName,
                                                      Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.NotificationManager_CourseReminderContentOpening],
                                                      tz.TZDateTime.local(
                                                          tz.TZDateTime.now(tz.local).year, tz.TZDateTime.now(tz.local).month, tz.TZDateTime.now(tz.local).day,
                                                          DateFormat("HH:mm").parse(_reminderStartTimeController.text).hour,
                                                          DateFormat("HH:mm").parse(_reminderStartTimeController.text).minute,
                                                          0),
                                                      repeatFrequency: RepeatInterval.daily),
                                                  _dialogStatus = dialog_Status.Success,
                                                  dialog_Msg = courselist[i].courseName + '\n'+
                                                      Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.NotificationManager_ReminderAdded],

                                                } else {
                                                  NotificationSetting.scheduleNotification(
                                                      flutterLocalNotificationsPlugin,
                                                      Notification_BodyType.CourseReminder,
                                                      courselist[i].courseID.toString(),
                                                      Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.NotificationManager_CourseReminderTitle] +
                                                          courselist[i].courseName,
                                                      Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.NotificationManager_CourseReminderContentOpening],
                                                      tz.TZDateTime.local(
                                                          tz.TZDateTime.now(tz.local).year, tz.TZDateTime.now(tz.local).month, tz.TZDateTime.now(tz.local).day + 1,
                                                          DateFormat("HH:mm").parse(_reminderStartTimeController.text).hour,
                                                          DateFormat("HH:mm").parse(_reminderStartTimeController.text).minute,
                                                          DateFormat("HH:mm").parse(_reminderStartTimeController.text).second),
                                                      repeatFrequency: RepeatInterval.daily),
                                                  _dialogStatus = dialog_Status.Success,
                                                  dialog_Msg = courselist[i].courseName + '\n' +
                                                      Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.NotificationManager_ReminderAdded],

                                                }
                                              } else {
                                                _dialogStatus = dialog_Status.Error,
                                                dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.NotificationManager_SettingCourseReminder_TimeFieldNull]
                                              },

                                              Navigator.of(context).pop(),
                                              showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder: (BuildContext context) =>
                                                    CustomDialog_Confirm(
                                                      dialog_type: _dialogStatus,
                                                      description: dialog_Msg,
                                                    ),
                                              ),
                                            },
                                          ),
                                      ),
                                  },
                                  icon: add_notification_Icon,
                                  label: Text(
                                    Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.NotificationManager_AddCourseReminder],
                                    style: TextStyle(color: Colors.black, fontSize: 14),)
                              ),
                            ),*/
                            Align(
                              alignment: Alignment.centerRight,
                              child: FlatButton.icon(
                                  onPressed: () async => {
                                    globals.courseUnitListReloaded = false,
                                    globals.selectedCourse = courselist[i],
                                    if(await Check_Token(context)){
                                      if(await fetchCourseData(context, globals.selectedCourse.courseID)){
                                        if(await fetchCourseUnits(context,globals.selectedCourse.courseID, queryparam: globals.canUpload ? 'All' : "isOpening")){
                                          if(await update_progress(context, progress_Table.Course, courseID: globals.selectedCourse.courseID)){
                                            globals.courseUnit_list_filter_option =
                                            globals.canUpload ? Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.StatusFilter_All] :
                                            Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.StatusFilter_Opening],
                                            Navigator.of(context)
                                                .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
                                            Navigator.of(context).push(globals.gotoPage(globals.CourseList_Page, Duration(seconds: 0, milliseconds: 0))),
                                            Navigator.of(context).push(globals.gotoPage(globals.CourseUnitList_Page, Duration(seconds: 0, milliseconds: 500))).
                                            then((value) => Refresh_Page_Manager.refresh_CourseListPage(context)),
                                          }
                                        }
                                      },
                                    },
                                  },
                                  icon: Icon(Icons.remove_red_eye, color: Colors.black54,),
                                  label: Text(
                                    Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_View_ViewCourse],
                                    style: TextStyle(color: Colors.black, fontSize: globals.fontSize_Normal),)
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Container(color: Colors.black38, height: 1),
                  // endregion
                  Container(color: Colors.black38, height: 1),
                  // region Progress Bar of Attachments
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 10, right: 0, left: 15, bottom: 5),
                                  child: Text( Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Progress_Unit_AttTotal_Title],
                                      style: TextStyle(fontSize: globals.fontSize_Normal)),
                                ),
                              )
                            ],
                          )
                      ),
                      Expanded(
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 10, right: 20, left: 0, bottom: 5),
                                  child: Text(courselist[i].attachment_Checked_Count.toString() + ' / ' + courselist[i].moduleAttachmentCount.toString(),
                                      style: TextStyle(fontSize: globals.fontSize_Normal)),
                                ),
                              )
                            ],
                          )
                      )
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 10, right: 15, left: 15),
                              child: new LinearPercentIndicator(
                                width: MediaQuery.of(context).size.width - 80,
                                animation: true,
                                lineHeight: 35.0,
                                animationDuration: 1000,
                                percent: !(courselist[i].attachment_Checked_Count == 0 && courselist[i].moduleAttachmentCount == 0) ?
                                courselist[i].attachment_Checked_Count / courselist[i].moduleAttachmentCount : 1.0,
                                center: Text(!(courselist[i].attachment_Checked_Count == 0 && courselist[i].moduleAttachmentCount == 0) ?
                                  ((courselist[i].attachment_Checked_Count / courselist[i].moduleAttachmentCount)*100).toStringAsFixed(2) + '%':
                                  "100.00%",
                                  style: TextStyle(fontSize: globals.fontSize_Normal),),
                                linearStrokeCap: LinearStrokeCap.roundAll,
                                progressColor: Colors.greenAccent,
                              ),
                            ),
                          )
                      )
                    ],
                  ),
                  // endregion
                  // region Progress Bar of Module
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 10, right: 0, left: 15, bottom: 5),
                                  child: Text( Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Progress_Course_ModuleTotal_Title],
                                      style: TextStyle(fontSize: globals.fontSize_Normal)),
                                ),
                              )
                            ],
                          )
                      ),
                      Expanded(
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 10, right: 20, left: 0, bottom: 5),
                                  child: Text(courselist[i].module_Finished_Count.toString() + ' / ' + courselist[i].unitModuleCount.toString(),
                                      style: TextStyle(fontSize: globals.fontSize_Normal)),
                                ),
                              )
                            ],
                          )
                      )
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 10, right: 15, left: 15),
                              child: new LinearPercentIndicator(
                                width: MediaQuery.of(context).size.width - 80,
                                animation: true,
                                lineHeight: 35.0,
                                animationDuration: 1000,
                                percent: !(courselist[i].module_Finished_Count == 0 && courselist[i].unitModuleCount == 0) ?
                                courselist[i].module_Finished_Count / courselist[i].unitModuleCount :
                                1.0,
                                center: Text(!(courselist[i].module_Finished_Count == 0 && courselist[i].unitModuleCount == 0) ?
                                  ((courselist[i].module_Finished_Count / courselist[i].unitModuleCount)*100).toStringAsFixed(2) + '%':
                                  "100.00%",
                                  style: TextStyle(fontSize: globals.fontSize_Normal),),
                                linearStrokeCap: LinearStrokeCap.roundAll,
                                progressColor: Colors.greenAccent,
                              ),
                            ),
                          )
                      )
                    ],
                  ),
                  // endregion
                  // region Progress Bar of Unit
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 10, right: 0, left: 15, bottom: 5),
                                  child: Text( Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Progress_Course_UnitTotal_Title],
                                      style: TextStyle(fontSize: globals.fontSize_Normal)),
                                ),
                              )
                            ],
                          )
                      ),
                      Expanded(
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 10, right: 20, left: 0, bottom: 5),
                                  child: Text(courselist[i].unit_Finished_Count.toString() + ' / ' + courselist[i].courseUnitCount.toString(),
                                      style: TextStyle(fontSize: globals.fontSize_Normal)),
                                ),
                              )
                            ],
                          )
                      )
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 10, right: 15, left: 15),
                              child: new LinearPercentIndicator(
                                width: MediaQuery.of(context).size.width - 80,
                                animation: true,
                                lineHeight: 35.0,
                                animationDuration: 1000,
                                percent: !(courselist[i].unit_Finished_Count == 0 && courselist[i].courseUnitCount == 0) ?
                                courselist[i].unit_Finished_Count / courselist[i].courseUnitCount : 1.0,
                                center: Text(!(courselist[i].unit_Finished_Count == 0 && courselist[i].courseUnitCount == 0) ?
                                  ((courselist[i].unit_Finished_Count / courselist[i].courseUnitCount)*100).toStringAsFixed(2) + '%' :
                                  "100.00%",
                                  style: TextStyle(fontSize: globals.fontSize_Normal),),
                                linearStrokeCap: LinearStrokeCap.roundAll,
                                progressColor: Colors.greenAccent,
                              ),
                            ),
                          )
                      )
                    ],
                  ),
                  // endregion
                  // region Administration Function
                  // Edit Course Button
                  Visibility(
                    visible: globals.canUpload,
                    child: Container(color: Colors.black38, height: 1),
                  ),
                  Visibility(
                    visible: globals.canUpload,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(top: 5,left: 5,right: 5),
                              child: Container(
                                decoration: BoxDecoration(),
                                child: FlatButton.icon(
                                    onPressed: () async => {
                                      globals.edit_isCourseDataLoaded = false,
                                      globals.course_isEditing = true,
                                      globals.selectedCourse = courselist[i],
                                      if(await fetchUserGroup(context, containsAdmin: '0')){
                                        if(await fetchCourseData(context, globals.selectedCourse.courseID)){
                                          globals.editCourse_Title = globals.selectedCourse.courseName,
                                          globals.editCourse_Desc = globals.selectedCourse.courseDesc,
                                          globals.editCourse_STime = DateFormat('HH:mm:ss').format(globals.selectedCourse.coursePeriod_Start),
                                          globals.editCourse_SDate = DateFormat('yyyy-MM-dd').format(globals.selectedCourse.coursePeriod_Start),
                                          globals.editCourse_ETime = DateFormat('HH:mm:ss').format(globals.selectedCourse.coursePeriod_End),
                                          globals.editCourse_EDate = DateFormat('yyyy-MM-dd').format(globals.selectedCourse.coursePeriod_End),
                                          globals.edit_isCourseDataLoaded = true,
                                          Navigator.of(context).push(globals.gotoPage(CourseEditor(),Duration(seconds: 0, milliseconds: 500))),
                                        }
                                      },
                                    },
                                    icon: Icon(Icons.edit, color: Colors.black54,),
                                    label: Text(
                                      Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_Page_EditDetails],
                                      style: TextStyle(color: Colors.black, fontSize: globals.fontSize_Normal),)
                                ),
                              ),
                            )
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: globals.canUpload,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(top: 5,left: 5,right: 5),
                              child: Container(
                                decoration: BoxDecoration(),
                                child: FlatButton.icon(
                                    onPressed: () async => {
                                      globals.course_isEditing = false,
                                      if(await fetchCourseData(context, courselist[i].courseID)){
                                        globals.newCourse_Title = courselist[i].courseName,
                                        globals.newCourse_Desc = courselist[i].courseDesc,
                                        globals.newCourse_STime = DateFormat('HH:mm:ss').format(courselist[i].coursePeriod_Start),
                                        globals.newCourse_SDate = DateFormat('yyyy-MM-dd').format(courselist[i].coursePeriod_Start),
                                        globals.newCourse_ETime = DateFormat('HH:mm:ss').format(courselist[i].coursePeriod_End),
                                        globals.newCourse_EDate = DateFormat('yyyy-MM-dd').format(courselist[i].coursePeriod_End),
                                        Navigator.of(context).push(globals.gotoPage(CourseEditor(),Duration(seconds: 0, milliseconds: 500))),
                                      }
                                    },
                                    icon: Icon(Icons.copy, color: Colors.black54,),
                                    label: Text(
                                      Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_View_DuplicateDetails],
                                      style: TextStyle(color: Colors.black, fontSize: globals.fontSize_Normal),)
                                ),
                              ),
                            )
                        ),
                      ],
                    ),
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
            padding: EdgeInsets.only(top:5, bottom: 5),
            child: itemCard_new,
          )
      ));
    }

    setState(() {
      //print("SetState");
      globals.courseListThumb = thumbs;
    });
    globals.courseListReloaded = true;
  }

  @override
  Widget build(BuildContext context) {

    if(globals.courseListReloaded != true) {
      //print("call Reload");
      _courseListReload(globals.courseList);
    }

    List<String> _filterSelection;
    if(globals.CurrentLang == Localizations_Language_Identifier.Language_Eng){
      _filterSelection = Course_Filter;
    } else if(globals.CurrentLang == Localizations_Language_Identifier.Language_TC){
      _filterSelection = Course_Filter_TC;
    }

    String _selected = globals.course_list_filter_option;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrangeAccent,
          title: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_View_Title],
          style: TextStyle(fontSize: globals.fontSize_Title),),
          centerTitle: true,
          actions: <Widget>[
            FlatButton(
              onPressed: () async => {
                Refresh_Page_Manager.refresh_CourseListPage(context)
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
                  child: Padding(
                    padding: EdgeInsets.only(top:10),
                    child: ButtonTheme(
                      minWidth: 300.0,
                      height: 40.0,
                      child: FlatButton.icon(
                        icon: Icon(Icons.build),
                        label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_View_StatusFilter] + ": " + globals.course_list_filter_option,
                          style: TextStyle(fontSize: globals.fontSize_Normal),),
                        textColor: Colors.white,
                        color: Colors.redAccent,
                        onPressed: () =>  {
                          SelectDialog.showModal<String>(
                            context,
                            label: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_View_StatusFilter],
                            selectedValue: _selected,
                            items: _filterSelection,
                            showSearchBox: false,
                            onChange: (String selected) async => {
                              globals.courseListReloaded = false,
                              if(selected == _filterSelection[1]){
                                if(await fetchCourses(context, queryparam: "isOpening", isAdminCheck: 'true')){
                                  globals.course_list_filter_option = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.StatusFilter_Opening],
                                  Navigator.of(context)
                                      .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
                                  Navigator.of(context).push(globals.gotoPage(globals.CourseList_Page, Duration(seconds: 0, milliseconds: 0))),
                                }
                              } else if(selected == _filterSelection[3]) {
                                if(await fetchCourses(context, queryparam: "isExpired", isAdminCheck: 'true')){
                                  globals.course_list_filter_option = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.StatusFilter_Expired],
                                  Navigator.of(context)
                                      .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
                                  Navigator.of(context).push(globals.gotoPage(globals.CourseList_Page, Duration(seconds: 0, milliseconds: 0))),
                                }
                              } else if(selected == _filterSelection[2]){
                                if(await fetchCourses(context, queryparam: "isComingSoon", isAdminCheck: 'true')){
                                  globals.course_list_filter_option = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.StatusFilter_Coming],
                                  Navigator.of(context)
                                      .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
                                  Navigator.of(context).push(globals.gotoPage(globals.CourseList_Page, Duration(seconds: 0, milliseconds: 0))),
                                }
                              } else if(selected == _filterSelection[0]){
                                if(await fetchCourses(context, isAdminCheck: 'true')){
                                  globals.course_list_filter_option = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.StatusFilter_All],
                                  Navigator.of(context)
                                      .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
                                  Navigator.of(context).push(globals.gotoPage(globals.CourseList_Page, Duration(seconds: 0, milliseconds: 0))),
                                }
                              }
                            },
                          )
                        },
                      ),
                    ),
                  ),
                ), // Filter for admin and researcher to view the course by status
                Visibility(
                  visible: globals.canUpload,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(width: 15,),
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              width: double.infinity,
                              child: FlatButton.icon(
                                icon: Icon(Icons.add),
                                label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseCreator_Creator_AppBarTitle],
                                style: TextStyle(fontSize: globals.fontSize_Normal),),
                                textColor: Colors.white,
                                color: Colors.lightBlue,
                                onPressed: () async => {
                                  globals.course_isEditing = false,
                                  if(await fetchUserGroup(context, containsAdmin: "0"))
                                    Navigator.of(context).push(globals.gotoPage(CourseEditor(),Duration(seconds: 0, milliseconds: 500)))
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(width: 15,)
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
                        itemCount: globals.courseListThumb.length, // number of items in your list
                        //here the implementation of itemBuilder. take a look at flutter docs to see details
                        itemBuilder: (BuildContext context, int Itemindex){
                          return globals.courseListThumb[Itemindex]; // return your widget
                        }
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
    );
  }
}