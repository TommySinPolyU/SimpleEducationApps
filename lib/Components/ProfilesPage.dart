import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smeapp/Components/Reminder/ReminderListPage.dart';
import 'package:smeapp/Components/UserManager/UserGroupManagerPage.dart';
import 'package:smeapp/CustomWidget/CustomDialog.dart';

import '../Helper/ComponentsList.dart';
import 'package:http/http.dart' as http;
import '../Helper/global_setting.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smeapp/Helper/Localizations.dart';

class ProfilesPage extends StatefulWidget{
  ProfilesPage_State createState() => ProfilesPage_State();
}

class ProfilesPage_State extends State<ProfilesPage>{
  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "", dialog_Msg_Title = "";
  Image dialog_image;

  // Boolean variable for Login Form.
  bool visible_Profiles= false;

  final _newPwController = TextEditingController();
  final _newPwAgainController = TextEditingController();
  final _newEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _UploadPref());
  }

  _ReloadPrefs() async {
    setState(() {
      visible_Profiles = false;
      globals.visible_Loading = true;
    });
    globals.state_BottomBar.setState(() {

    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    /*
    if(prefs.getString(Pref_Proiles_Nickname) == "" ||
       prefs.getString(Pref_Proiles_Firstname) == "" ||
       prefs.getString(Pref_Proiles_Lastname) == "" ||
       prefs.getString(Pref_Proiles_Email) == "" ||
       prefs.getString(Pref_Proiles_Gender) == ""){
    */
      var getprofiles_data = {
        "AppCode": Application_Identifier_Code, "Version": Application_Version,
        'UID' : globals.UserData_UID
      };
      try {
        // Call Web API and try to get a result from Server
        var response_code = await http.post(
            Get_ProfilesData_URL, body: json.encode(getprofiles_data), headers: {'Authorization':  'JWT ' + globals.userToken}).timeout(Duration(seconds: Connection_Timeout_TimeLimit));

        // Getting Server response into variable.
        Map<String, dynamic> response_code_JSON = jsonDecode(response_code.body);

        if(response_code.statusCode == 200) {
          if(response_code_JSON['StatusCode']==1000){
            _dialogStatus = dialog_Status.Success;
            //globals.Profiles_Nickname = response_code_JSON['NickName'];
            globals.Profiles_Firstname = response_code_JSON['FirstName'];
            globals.Profiles_Lastname = response_code_JSON['LastName'];
            globals.Profiles_Email = response_code_JSON['Email'];
            globals.Profiles_Gender = response_code_JSON['Gender'];
            _UploadPref();
          } else {
            dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_Error_LoadingFailed]  + "(" + response_code.statusCode + ")";
          }
        }
      } on TimeoutException catch (e) {
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
      } on Error catch(_) {
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error];
      } on SocketException catch(_){
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error];
      } on FormatException catch(_) {
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error_FormatException];
      }
    /*else {
      Profiles_Nickname = (prefs.getString(Pref_Proiles_Nickname) ?? "");
      Profiles_Firstname = (prefs.getString(Pref_Proiles_Firstname) ?? "");
      Profiles_Lastname = (prefs.getString(Pref_Proiles_Lastname) ?? "");
      Profiles_Email = (prefs.getString(Pref_Proiles_Email) ?? "");
      Profiles_Gender = (prefs.getString(Pref_Proiles_Gender) ?? "");
    }
    */

    switch(_dialogStatus){
      case dialog_Status.Success:
        dialog_Msg_Title = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Tips_Success];
        dialog_image = tips_success_Icon;
        break;
      case dialog_Status.Error:
        dialog_Msg_Title = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Tips_Error];
        dialog_image = tips_error_Icon;
        break;
    }

    if(dialog_Msg.isNotEmpty) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => CustomDialog_Confirm(
          dialog_type: _dialogStatus,
          description: dialog_Msg,
        ),
      );
      setState(() {
        visible_Profiles = false;
        globals.visible_Loading = false;
      });

      globals.state_BottomBar.setState(() {

      });
    } else {
      setState(() {
        visible_Profiles = true;
        globals.visible_Loading = false;
      });
      globals.state_BottomBar.setState(() {

      });
    }
  }

  _UploadPref() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.setString(Pref_Profiles_Nickname, globals.Profiles_Nickname);
    prefs.setString(Pref_Profiles_Firstname, globals.Profiles_Firstname);
    prefs.setString(Pref_Profiles_Lastname, globals.Profiles_Lastname);
    prefs.setString(Pref_Profiles_Email, globals.Profiles_Email);
    prefs.setString(Pref_Profiles_Gender, globals.Profiles_Gender);
  }

  @override
  Widget build(BuildContext context) {
    final label_newpw = Padding(
      padding: EdgeInsets.only(left: 20,right: 20, top: 10),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.loginPwHintText],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Middle,
            color: appPrimaryColor),
      ),
    );
    final label_newcheckpw = Padding(
      padding: EdgeInsets.only(left: 20,right: 20, top: 10),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_ChangePassword_DoubleCheck],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Middle,
            color: appPrimaryColor),
      ),
    );
    final label_pw_condition = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Signup_PWManual],
        textAlign: TextAlign.left,
        //overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Normal
            ,
            color: Colors.black54),
      ),
    );
    final label_newEmail = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.EmailHintText],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Middle,
            color: appPrimaryColor),
      ),
    );
    final label_newEmail_Desc = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_ChangeDefaultEmail_InBoxDesc],
        textAlign: TextAlign.left,
        //overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Normal,
            color: Colors.black54),
      ),
    );
    final password_change_dialog = Container(
      child: Column(
        children: [
          // New Pw
          InkWell(
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54)
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      label_newpw,
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          textAlign: TextAlign.right,
                          controller: _newPwController,
                          keyboardType: TextInputType.multiline,
                          maxLength: 32,
                          maxLines: 1,
                          obscureText: true,
                          style: TextStyle(
                            color: appPrimaryColor,
                            fontSize: globals.fontSize_Middle,
                          ),
                          onChanged: (text) {

                          },
                          buildCounter: (_, {currentLength, maxLength, isFocused}) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                          padding: const EdgeInsets.only(left: 22),
                                          alignment: Alignment.centerLeft,
                                          child: Text("")
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                          padding: const EdgeInsets.only(right: 10),
                                          alignment: Alignment.centerRight,
                                          child: Text(currentLength.toString() + "/" + maxLength.toString())
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(0,15,0,0),
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: Icon(Icons.input),
                              )
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          // New Pw Checker: Input Again
          InkWell(
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54)
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      label_newcheckpw,
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          textAlign: TextAlign.right,
                          controller: _newPwAgainController,
                          keyboardType: TextInputType.multiline,
                          maxLength: 32,
                          maxLines: 1,
                          obscureText: true,
                          style: TextStyle(
                            color: appPrimaryColor,
                            fontSize: globals.fontSize_Middle,
                          ),
                          onChanged: (text) {

                          },
                          buildCounter: (_, {currentLength, maxLength, isFocused}) => Padding(
                            padding: const EdgeInsets.only(bottom: 0),
                            child: Row(
                              children: <Widget>[

                              ],
                            ),
                          ),
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(0,15,0,0),
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: Icon(Icons.input),
                              )
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          InkWell(
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54)
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Padding(
                        padding: EdgeInsets.only(top:15, bottom: 5),
                        child: label_pw_condition,
                      ))
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    final email_change_dialog = Container(
      child: Column(
        children: [
          InkWell(
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54)
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Padding(
                        padding: EdgeInsets.only(top:15, bottom: 15),
                        child: label_newEmail_Desc,
                      ))
                    ],
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54)
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      textAlign: TextAlign.right,
                      controller: _newEmailController,
                      keyboardType: TextInputType.emailAddress,
                      maxLength: 256,
                      maxLines: null,
                      style: TextStyle(
                        color: appPrimaryColor,
                        fontSize: globals.fontSize_Middle,
                      ),
                      onChanged: (text) {

                      },
                      buildCounter: (_, {currentLength, maxLength, isFocused}) => Padding(
                        padding: const EdgeInsets.only(bottom: 0),
                        child: Row(
                          children: <Widget>[

                          ],
                        ),
                      ),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(0,15,0,0),
                          prefixIcon: label_newEmail,
                          prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(Icons.input),
                          )
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );

    String subGroups = ""; int groupcount = 0;
    globals.userSubGroup.forEach((element) {
      if(groupcount != globals.userSubGroup.length - 1) {
        subGroups += element + "\n";
      } else {
        subGroups += element;
      }
      groupcount++;
    });

    final _TitleUI = Padding(
      padding: EdgeInsets.only(top:15, left: 15, right: 15),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Image.asset('assets/images/user_icon.png', fit: BoxFit.contain,
                                  height: 75.0,
                                  width: 75.0,)
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 7,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text(globals.Profiles_Firstname + ', ' + globals.Profiles_Lastname,
                                  style: TextStyle(fontSize: globals.fontSize_Big, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              /*
                              Row(
                                children: <Widget>[
                                  Text(globals.Profiles_Nickname,
                                  style: TextStyle(fontSize: 15)),
                                ],
                              ),

                               */
                              Row(
                                children: <Widget>[
                                  Text(globals.Profiles_Email,
                                      style: TextStyle(fontSize: globals.fontSize_Middle))
                                ],
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  Padding(
                      padding: EdgeInsets.only(top:10, bottom: 5),
                      child: Row(
                        children: [
                          Visibility(
                              visible: groupcount > 0,
                              child: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_SubGroup_Prefix], style: TextStyle(fontSize: globals.fontSize_Small),)
                          ),
                        ],
                      ),
                  ),
                  Row(
                    children: [
                      Text(groupcount == 0 ? Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_SubGroup_NoGroup] : subGroups, style: TextStyle(fontSize: globals.fontSize_Small),)
                    ],
                  ),
                  Divider(
                    height: 20,
                    color: Colors.lightBlue,
                    thickness: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final regex_all = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[a-zA-Z])(?=.*[*!@#&]).{9,}$');
    final regex_Upper = RegExp(r'^(?=.*[A-Z])(?=.*[a-zA-Z]).{1,}$');
    final regex_Lower = RegExp(r'^(?=.*[a-z])(?=.*[a-zA-Z]).{1,}$');
    final regex_SpecChar = RegExp(r'^(?=.*[*!@#&]).{1,}$');
    final regex_length = RegExp(r'^.{9,}$');
    final regex_email = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    return Scaffold(
        resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: appTitleBarColor,
        title: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.ProfilesLabelText],
        style: TextStyle(fontSize: globals.fontSize_Title),),
      ),
        body: Container(
          child: Column(
            children: [
              _TitleUI,
              Expanded(child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.all(15.0),
                children: <Widget>[
                  // Course List Button for Checking the progress of courses
                  Card(
                    child: ListTile(
                      leading: course_Icon,
                      title: Padding(
                        padding: EdgeInsets.only(top: 15, bottom: 5),
                        child: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_ViewCourseProgress_title],
                            style: TextStyle(fontSize: globals.fontSize_Middle, fontWeight: FontWeight.bold)),
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: 5, bottom: 15),
                        child: Text(
                          Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_ViewCourseProgress_Desc],
                          style: TextStyle(fontSize: globals.fontSize_Normal, color: Colors.black54),
                        ),
                      ),
                      isThreeLine: true,
                      onTap: () async =>  {
                        globals.courseListReloaded = false,
                        if(globals.canUpload){
                          if(await Check_Token(context)){
                            if(await fetchCourses(context, isAdminCheck: 'true')){
                              globals.course_list_filter_option = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.StatusFilter_All],
                              Navigator.of(context).push(globals.gotoPage(globals.CourseList_Page, Duration(seconds: 0, milliseconds: 500)))
                            }
                          },
                        } else {
                          if(await Check_Token(context)){
                            if(await fetchCourses(context, queryparam: "isOpening")){
                              globals.course_list_filter_option = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.StatusFilter_Opening],
                              Navigator.of(context).push(globals.gotoPage(globals.CourseList_Page, Duration(seconds: 0, milliseconds: 500)))
                            }
                          },
                        }
                      },
                    ),
                  ),
                  // Survey List Button
                  Card(
                    child: ListTile(
                      leading: survey_Icon,
                      title: Padding(
                        padding: EdgeInsets.only(top: 15, bottom: 5),
                        child: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_ViewSurvey_title],
                            style: TextStyle(fontSize: globals.fontSize_Middle, fontWeight: FontWeight.bold)),
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: 5, bottom: 15),
                        child: Text(
                          Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_ViewSurvey_Desc],
                          style: TextStyle(fontSize: globals.fontSize_Normal, color: Colors.black54),
                        ),
                      ),
                      isThreeLine: true,
                      onTap: () async =>  {
                        globals.surveyListReloaded = false,
                        if(globals.canUpload){
                          if(await Check_Token(context)){
                            if(await fetchSurvey(context, isAdminCheck: 'true')){
                              globals.survey_list_filter_option = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.StatusFilter_All],
                              Navigator.of(context).push(globals.gotoPage(globals.SurveyList_Page, Duration(seconds: 0, milliseconds: 500)))
                            }
                          },
                        } else {
                          if(await Check_Token(context)){
                            if(await fetchSurvey(context, queryparam: "isOpening")){
                              globals.survey_list_filter_option = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.StatusFilter_Opening],
                              Navigator.of(context).push(globals.gotoPage(globals.SurveyList_Page, Duration(seconds: 0, milliseconds: 500)))
                            }
                          },
                        }
                      },
                    ),
                  ),
                  // Notification Manager
                  /*
                Card(
                  child: ListTile(
                    leading: notification_Icon,
                    title: Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 5),
                      child: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_NotificationManager_title],
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    subtitle: Padding(
                      padding: EdgeInsets.only(top: 5, bottom: 10),
                      child: Text(
                        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_NotificationManager_Desc],
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ),
                    isThreeLine: true,
                    onTap: () async =>  {
                      globals.reminderListReloaded = false,
                      await NotificationSetting.getNotificationList(flutterLocalNotificationsPlugin),
                      Navigator.of(context).push(globals.gotoPage(ReminderListPage(), Duration(seconds: 0, milliseconds: 500)))
                    },
                  ),
                ),*/
                  Visibility(
                    visible: globals.canUpload,
                    child: Card(
                      child: ListTile(
                        leading: usergroup_manager_Icon,
                        title: Padding(
                          padding: EdgeInsets.only(top: 15, bottom: 5),
                          child: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_UserGroupSetting_title],
                              style: TextStyle(fontSize: globals.fontSize_Middle, fontWeight: FontWeight.bold)),
                        ),
                        subtitle: Padding(
                          padding: EdgeInsets.only(top: 5, bottom: 15),
                          child: Text(
                            Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_UserGroupSetting_Desc],
                            style: TextStyle(fontSize: globals.fontSize_Normal, color: Colors.black54),
                          ),
                        ),
                        isThreeLine: true,
                        onTap: () async =>  {
                          if(await fetchUserGroup(context, containsAdmin: "0")){
                            globals.groupListReloaded = false,
                            Navigator.of(context).push(globals.gotoPage(UserGroupManagerPage(), Duration(seconds: 0, milliseconds: 500)))
                          }
                        },
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: changePw_Icon,
                      title: Padding(
                        padding: EdgeInsets.only(top: 15, bottom: 5),
                        child: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_ChangePassword_title],
                            style: TextStyle(fontSize: globals.fontSize_Middle, fontWeight: FontWeight.bold)),
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: 5, bottom: 15),
                        child: Text(
                          Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_ChangePassword_Desc],
                          style: TextStyle(fontSize: globals.fontSize_Normal, color: Colors.black54),
                        ),
                      ),
                      isThreeLine: true,
                      onTap: () async =>  {
                        if(await Check_Token(context)){
                          showDialog(
                            useSafeArea: true,
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) =>
                                CustomDialog_Selection(
                                  dialog_type: dialog_Status.Custom,
                                  title: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_ChangePassword_title],
                                  desc_to_widget: true,
                                  desc_widget: password_change_dialog,
                                  image: changePw_Icon,
                                  callback_Confirm: () async => {
                                    if(!(_newPwController.text.isEmpty || _newPwAgainController.text.isEmpty)){
                                      if(_newPwController.text != _newPwAgainController.text){
                                        _dialogStatus = dialog_Status.Warning,
                                        dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_ChangePassword_DoubleCheck_Failed],
                                      } else {
                                        if(_newPwController.text.contains(regex_all)){
                                          //All matched
                                          if(await changePassword(context, _newPwController.text)){
                                            _dialogStatus = dialog_Status.Success,
                                            dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_ChangePassword_Success],
                                            Navigator.of(context).pop(),
                                            showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (BuildContext context) => CustomDialog_Confirm(
                                                dialog_type: _dialogStatus,
                                                description: dialog_Msg,
                                                callback_Confirm: () async => {
                                                  await logoutProcess(context, passwordchanged: true),
                                                },
                                              ),
                                            )
                                          }
                                        } else {
                                          _dialogStatus = dialog_Status.Warning,
                                          dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_ChangePassword_Condition_Check_TopMsg] + '\n',
                                          if(!_newPwController.text.contains(regex_length)){
                                            dialog_Msg += Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_ChangePassword_Condition_Length] + '\n',
                                          },
                                          if(!_newPwController.text.contains(regex_Upper)){
                                            dialog_Msg += Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_ChangePassword_Condition_ContainUpper] + '\n',
                                          },
                                          if(!_newPwController.text.contains(regex_Lower)){
                                            dialog_Msg += Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_ChangePassword_Condition_ContainLower] + '\n',
                                          },
                                          if(!_newPwController.text.contains(regex_SpecChar)){
                                            dialog_Msg += Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_ChangePassword_Condition_SpecialCharacter] + '\n',
                                          }
                                        },
                                      },

                                      if(_dialogStatus == dialog_Status.Warning){
                                        showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) => CustomDialog_Confirm(
                                            dialog_type: _dialogStatus,
                                            description: dialog_Msg,
                                          ),
                                        )
                                      }
                                    } else {
                                      _dialogStatus = dialog_Status.Error,
                                      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_UploadFormNotAllFill],
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) => CustomDialog_Confirm(
                                          dialog_type: _dialogStatus,
                                          description: dialog_Msg,
                                        ),
                                      )
                                    }
                                  },
                                ),
                          ),
                        }
                      },
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: changeEmail_Icon,
                      title: Padding(
                        padding: EdgeInsets.only(top: 15, bottom: 5),
                        child: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_ChangeDefaultEmail_title],
                            style: TextStyle(fontSize: globals.fontSize_Middle, fontWeight: FontWeight.bold)),
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: 5, bottom: 15),
                        child: Text(
                          Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_ChangeDefaultEmail_Desc],
                          style: TextStyle(fontSize: globals.fontSize_Normal, color: Colors.black54),
                        ),
                      ),
                      isThreeLine: true,
                      onTap: () async =>  {
                        if(await Check_Token(context)){
                          showDialog(
                            useSafeArea: true,
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) =>
                                CustomDialog_Selection(
                                  dialog_type: dialog_Status.Custom,
                                  title: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_ChangeDefaultEmail_title],
                                  desc_to_widget: true,
                                  desc_widget: email_change_dialog,
                                  image: changeEmail_Icon,
                                  callback_Confirm: () async => {
                                    if(!(_newEmailController.text.isEmpty)){
                                      if(_newEmailController.text.contains(regex_email)){
                                        //All matched
                                        if(await changeEmail(context, _newEmailController.text)){
                                          if(await sendValidationRequest(context, globals.UserData_username)){
                                            _dialogStatus = dialog_Status.Success,
                                            dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_ChangeDefaultEmail_Success],
                                            Navigator.of(context).pop(),
                                            showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (BuildContext context) => CustomDialog_Confirm(
                                                dialog_type: _dialogStatus,
                                                description: dialog_Msg,
                                                callback_Confirm: () async => {
                                                  await logoutProcess(context, emailchanged: true),
                                                },
                                              ),
                                            )
                                          }
                                        }
                                      } else {
                                        _dialogStatus = dialog_Status.Warning,
                                        dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_ChangeDefaultEmail_FormatError],
                                      },

                                      if(_dialogStatus == dialog_Status.Warning){
                                        showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) => CustomDialog_Confirm(
                                            dialog_type: _dialogStatus,
                                            description: dialog_Msg,
                                          ),
                                        )
                                      }
                                    } else {
                                      _dialogStatus = dialog_Status.Error,
                                      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_UploadFormNotAllFill],
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) => CustomDialog_Confirm(
                                          dialog_type: _dialogStatus,
                                          description: dialog_Msg,
                                        ),
                                      )
                                    }
                                  },
                                ),
                          ),
                        }
                      },
                    ),
                  ),
                ],
              ),)
            ],
          ),
        )
    );
  }
}