import 'package:intl/intl.dart';
import 'package:smeapp/CustomWidget/CustomDialog.dart';

import 'JsonItemConvertor.dart';
import 'global_setting.dart';
import 'ComponentsList.dart';
import 'JsonItemConvertor.dart';
import 'Localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/cupertino.dart';

import 'global_setting.dart';
import 'global_setting.dart';

Future logoutProcess(BuildContext context, {bool clear_data = false, bool passwordchanged = false, bool emailchanged = false}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "";

  var logout_data = {
    'UID': (UserData_UID ?? "")};

  try {
    // Call Web API and try to get a result from Server
    var response_code = await http.post(
        Logout_URL, body: json.encode(logout_data)).timeout(Duration(seconds: Connection_Timeout_TimeLimit));

    // Getting Server response into variable.
    Map<String, dynamic> response_code_JSON = jsonDecode(response_code.body);

    // If Web call Success than Hide the CircularProgressIndicator.
    if(response_code.statusCode == 200) {
      // There are no any error in login procedure.
      if(response_code_JSON['StatusCode'].contains(1000)){
        _dialogStatus = dialog_Status.Success;
        dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Logout_Success];
      }
    } else {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error] + "(" + response_code.statusCode + ")";
    }
  } on Error catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
  }/* on TimeoutException catch (e) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on SocketException catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
  } on FormatException catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error_FormatException];
  }*/

  _dialogStatus = dialog_Status.Success;
  dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Logout_Success];

  isLoggedIn = false;
  state_BottomBar.setState(() {
    PageIndex = 1;
  });
  prefs.setString(Pref_Profiles_UID, "");
  prefs.setString(Pref_Profiles_Nickname, "");
  prefs.setString(Pref_Profiles_Firstname, "");
  prefs.setString(Pref_Profiles_Lastname, "");
  prefs.setString(Pref_Profiles_Email, "");
  prefs.setString(Pref_Profiles_Gender, "");
  prefs.setBool(Pref_SaveAccount, true);

  if(passwordchanged){
    prefs.setString(Pref_User_SaltedPassword, "");
    prefs.setString(Pref_User_UserName, UserData_username);
    prefs.setBool(Pref_SaveAccount, true);
    prefs.setInt(Pref_AutoLogin, 0);
  }

  if(emailchanged){
    prefs.setString(Pref_User_UserName, UserData_username);
    prefs.setBool(Pref_SaveAccount, true);
    prefs.setInt(Pref_AutoLogin, 0);
  }

  if(clear_data) {
    prefs.setString(Pref_User_RegisCode, "");
    prefs.setString(Pref_User_SaltedPassword, "");
    prefs.setString(Pref_User_UserName, "");
    prefs.setInt(Pref_AutoLogin, 0);
    prefs.setBool(Pref_SaveAccount, false);
    List<String> topics = [];
    List<String> remove_topics = [];
    topics = prefs.containsKey('Subscribed_Topics') ? prefs.getStringList('Subscribed_Topics') : [];
    //firebaseMessaging.deleteInstanceID();

    topics.forEach((element) {
      print("Unsubscribed: " + element);
      firebaseMessaging.unsubscribeFromTopic(element);
      remove_topics.add(element);
    });

    remove_topics.forEach((element) {
      topics.remove(element);
    });
    if(prefs.getInt(Pref_NotificationPermission) == 1) {
      topics.add("GroupMessage_All");
    }

    topics.forEach((element) {
      print("Subscribed: " + element + "\n");
      firebaseMessaging.subscribeToTopic(element);
    });

    prefs.setStringList("Subscribed_Topics", topics);
  }

  Navigator.of(context)
      .pushAndRemoveUntil(
      gotoPage(MainPage(), Duration(seconds: 0, milliseconds: 0)), (
      Route<dynamic> route) => false);

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) =>
        CustomDialog_Confirm(
          dialog_type: _dialogStatus,
          description: dialog_Msg,
          callback_Confirm: () => {
            //region Reset Contact Form Inputted Data
            newEmail_Title = null,
            newEmail_Desc = null,
            newEmail_LastName = null,
            newEmail_NameTitle = null,
            newEmail_ReplyEmail = null,
            //endregion
            //region Reset Survey Form Inputted Data
            newSurvey_Title = null,
            newSurvey_URL = null,
            newSurvey_Desc = null,
            newSurvey_SDate = null,
            newSurvey_STime = null,
            newSurvey_EDate = null,
            newSurvey_ETime = null,
            newSurvey_FullStartTime = null,
            newSurvey_FullEndTime = null,
            selected_group = [],
            survey_isEditing = false,
            //endregion
            //region Reset Course Form Inputted Data
            newCourse_Title = null,
            newCourse_Desc = null,
            newCourse_SDate = null,
            newCourse_STime = null,
            newCourse_EDate = null,
            newCourse_ETime = null,
            newCourse_FullStartTime = null,
            newCourse_FullEndTime = null,
            selected_group = [],
            course_isEditing = false,
            //endregion
            //region Reset Course Unit Form Inputted Data
            newCourseUnit_Title = null,
            newCourseUnit_Desc = null,
            newCourseUnit_SDate = null,
            newCourseUnit_STime = null,
            newCourseUnit_EDate = null,
            newCourseUnit_ETime = null,
            newCourseUnit_FullStartTime = null,
            newCourseUnit_FullEndTime = null,
            courseunit_isEditing = false,
            //endregion
            //region Reset Material Form Inputted Data
            newMaterial_Title = null,
            newMaterial_Desc = null,
            //globals.newMaterial_RequiredTime = null;
            newMaterial_SDate = null,
            newMaterial_STime = null,
            newMaterial_EDate = null,
            newMaterial_ETime = null,
            newMaterial_FullStartTime = null,
            newMaterial_FullEndTime = null,
            newMaterial_FilesUploader_fileList = new List<File>(),
            //endregion
            Navigator.of(context).pop(),
          },
        ),
  );
}

// Checking the validation of Access Token
Future<bool> Check_Token(BuildContext context) async{

  Future.delayed(Duration.zero, () => {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Confirm(
            showButton: false,
            dialog_type: dialog_Status.Loading,
            description: Localizations_Text[CurrentLang][Localizations_Text_Identifier
                .Connection_TokenChecking],
          ),
    )
  });

  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "";

  VoidCallback relogin_Callback = () async => {
    //print("Called"),
    Navigator.of(context).pop(),
    await logoutProcess(context, clear_data: false),
  };

  Uri uri = Uri.parse(CheckToken_URL);
  //print(uri);

  try {
    final response = await http.get(uri, headers: {'Authorization':  'JWT $userToken'}).
    timeout(Duration(seconds: Connection_Timeout_TimeLimit));
    //print(response.statusCode);
    if (response.statusCode == 200) {
      _dialogStatus = dialog_Status.Success;
    } else {
      _dialogStatus = dialog_Status.Warning;
      dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_TokenError];
      //print(response.body);
    }
  } on TimeoutException catch (e) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on Error catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
  } on SocketException catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
  } on FormatException catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error_FormatException];
  } on HandshakeException catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on Exception catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  }

  Navigator.of(context).pop();

  if(_dialogStatus != dialog_Status.Success) {
    if(_dialogStatus == dialog_Status.Error) {
      Navigator.of(context)
          .pushAndRemoveUntil(
          gotoPage(MainPage(), Duration(seconds: 0, milliseconds: 0)), (
          Route<dynamic> route) => false);
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            CustomDialog_Confirm(
              dialog_type: _dialogStatus,
              description: dialog_Msg,
            ),
      );
    }

    if(_dialogStatus == dialog_Status.Warning) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            CustomDialog_Confirm(
              dialog_type: _dialogStatus,
              description: dialog_Msg,
              callback_Confirm: relogin_Callback,
              buttonText: Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_ReloginBtn],
            ),
      );
    }
    return false;
  } else
    return true;
}

// Fetch User Group List
Future<bool> fetchUserGroup(BuildContext context, {String containsAdmin}) async{
  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "";

  /*
  Future.delayed(Duration.zero, () => {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Confirm(
            showButton: false,
            dialog_type: dialog_Status.Loading,
            description: Localizations_Text[CurrentLang][Localizations_Text_Identifier
                .Course_View_LoadingList],
          ),
    )
  });
  */


  Uri uri = Uri.parse(Get_GroupsData_URL);
  /*
  uri = uri.replace(queryParameters: <String, String>{'containAdmin': containsAdmin});
  print(uri);
  */

  try {
    final response = await http.get(uri, headers: {'Authorization':  'JWT $userToken'}).
    timeout(Duration(seconds: Connection_Timeout_TimeLimit));
    List<GroupListItem> _groupList = new List<GroupListItem>();
    if (response.statusCode == 200) {
      _dialogStatus = dialog_Status.Success;
      _groupList = GroupList.fromJson(json.decode(response.body)).results;
      groupList = _groupList;
    } else {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
    }
  } on TimeoutException catch (e) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on Error catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
  } on SocketException catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
  } on HandshakeException catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on Exception catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  }

  debugPrint("" + groupList.length.toString());

  //Navigator.of(context).pop();

  if(_dialogStatus != dialog_Status.Success) {
    Navigator.of(context)
        .pushAndRemoveUntil(gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false);
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Confirm(
            dialog_type: _dialogStatus,
            description: dialog_Msg,
          ),
    );
    return false;
  } else
    return true;
}

// Fetch Users List
Future<bool> fetchUsers(BuildContext context) async{
  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "";

  Future.delayed(Duration.zero, () => {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Confirm(
            showButton: false,
            dialog_type: dialog_Status.Loading,
            description: Localizations_Text[CurrentLang][Localizations_Text_Identifier
                .GroupUser_GettingUsersList],
          ),
    )
  });



  Uri uri = Uri.parse(Get_UsersData_URL);
  /*
  uri = uri.replace(queryParameters: <String, String>{'containAdmin': containsAdmin});

  */
  debugPrint(uri.toString());
  try {
    final response = await http.get(uri, headers: {'Authorization':  'JWT $userToken'}).
    timeout(Duration(seconds: Connection_Timeout_TimeLimit));
    List<UserListItem> _userList = new List<UserListItem>();
    if (response.statusCode == 200) {
      _dialogStatus = dialog_Status.Success;
      _userList = UserList.fromJson(json.decode(response.body)).results;
      userList = _userList;
    } else {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
    }
  } on TimeoutException catch (e) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on Error catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
    debugPrint(_.toString());
  } on SocketException catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
    debugPrint(_.toString());
  } on HandshakeException catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on Exception catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  }

  debugPrint(userList.length.toString());

  Navigator.of(context).pop();

  if(_dialogStatus != dialog_Status.Success) {
    Navigator.of(context)
        .pushAndRemoveUntil(gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false);
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Confirm(
            dialog_type: _dialogStatus,
            description: dialog_Msg,
          ),
    );
    return false;
  } else
    return true;
}

// Update User Group List
Future<bool> updateUserGroup(BuildContext context, String Groupname, List<UserListItem> selected_user ) async{
  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "";


  Uri uri = Uri.parse(UpdateGroupUsers_URL);
  /*
  uri = uri.replace(queryParameters: <String, String>{'containAdmin': containsAdmin});
  debugPrint(uri.toString());
  */

  String list_users = "";
  for(int i = 0; i < selected_user.length; i++){
    list_users += (selected_user[i].UID);
    if(i < selected_user.length - 1){
      list_users += ",";
    }
  }

  var update_data = {
    'GroupName': Groupname,
    'Users_Select': list_users != "" ? list_users : null,
  };

  debugPrint(update_data.toString());

  try {
    final response = await http.post(
        uri, body: json.encode(update_data), headers: {'Authorization':  'JWT $userToken'}).timeout(
        Duration(seconds: Connection_Timeout_TimeLimit));
    if (response.statusCode == 200) {
      _dialogStatus = dialog_Status.Success;
    } else {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
      debugPrint(response.body.toString());
    }
  } on TimeoutException catch (e) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
    debugPrint(e.toString());
  } on Error catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
    debugPrint(_.toString());
  } on SocketException catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
    debugPrint(_.toString());
  } on FormatException catch (_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error_FormatException];
    debugPrint(_.toString());
  } on HandshakeException catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on Exception catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  }

  if(_dialogStatus != dialog_Status.Success) {
    Navigator.of(context)
        .pushAndRemoveUntil(gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false);
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Confirm(
            dialog_type: _dialogStatus,
            description: dialog_Msg,
          ),
    );
    return false;
  } else
    return true;
}

// Verify Email
Future<bool> sendValidationRequest(BuildContext context, String username) async{
  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "";

  Future.delayed(Duration.zero, () => {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Confirm(
            showButton: false,
            dialog_type: dialog_Status.Loading,
            description: Localizations_Text[CurrentLang][Localizations_Text_Identifier
                .ResendValidationEmail_Sending],
          ),
    )
  });

  Uri uri = Uri.parse(SendEmailValidation_URL);

  var update_data = {
    'Username': username,
    'Language': CurrentLang.id,
    'AppCode': Application_Identifier_Code,
    'Version': Application_Version
  };

  debugPrint(update_data.toString());

  try {
    final response = await http.post(
        uri, body: json.encode(update_data), headers: {'Authorization':  'JWT $userToken'}).timeout(
        Duration(seconds: Connection_Timeout_TimeLimit));
    Map<String, dynamic> response_code_JSON = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if(response_code_JSON['StatusCode'] == 1000){
        _dialogStatus = dialog_Status.Success;
      } else if(response_code_JSON['StatusCode'] == 1002){
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.SendResetPWRequest_ACNotFound];
      } else if(response_code_JSON['StatusCode'] == 1003){
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.SendResetPWRequest_ApplicationInvaild];
      } else {
        debugPrint(response_code_JSON.toString());
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.SendValidationRequest_Failed];
      }
    } else {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
      debugPrint(response.body.toString());
    }
  } on TimeoutException catch (e) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
    debugPrint(e.toString());
  } on Error catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
    debugPrint(_.toString());
  } on SocketException catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
    debugPrint(_.toString());
  } on FormatException catch (_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error_FormatException];
    debugPrint(_.toString());
  } on HandshakeException catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on Exception catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  }

  Navigator.of(context).pop();

  if(_dialogStatus != dialog_Status.Success) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Confirm(
            dialog_type: _dialogStatus,
            description: dialog_Msg,
          ),
    );
    return false;
  } else
    return true;
}


// Change Password
Future<bool> changePassword(BuildContext context, String newPassword) async{
  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "";

  Uri uri = Uri.parse(ChangePassword_URL);

  var update_data = {
    'UID': UserData_UID,
    'Password': newPassword,
  };

  debugPrint(update_data.toString());

  try {
    final response = await http.post(
        uri, body: json.encode(update_data), headers: {'Authorization':  'JWT $userToken'}).timeout(
        Duration(seconds: Connection_Timeout_TimeLimit));
    Map<String, dynamic> response_code_JSON = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if(response_code_JSON['StatusCode'] == 1000){
        _dialogStatus = dialog_Status.Success;
      } else {
        debugPrint(response_code_JSON.toString());
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Profiles_ChangePassword_Failed];
      }
    } else {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
      debugPrint(response.body.toString());
    }
  } on TimeoutException catch (e) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
    debugPrint(e.toString());
  } on Error catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
    debugPrint(_.toString());
  } on SocketException catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
    debugPrint(_.toString());
  } on FormatException catch (_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error_FormatException];
    debugPrint(_.toString());
  } on HandshakeException catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on Exception catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  }

  if(_dialogStatus != dialog_Status.Success) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Confirm(
            dialog_type: _dialogStatus,
            description: dialog_Msg,
          ),
    );
    return false;
  } else
    return true;
}

// Change Email
Future<bool> changeEmail(BuildContext context, String newEmail) async{
  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "";

  Uri uri = Uri.parse(ChangeEmail_URL);

  var update_data = {
    'UID': UserData_UID,
    'Email': newEmail,
  };

  debugPrint(update_data.toString());

  try {
    final response = await http.post(
        uri, body: json.encode(update_data), headers: {'Authorization':  'JWT $userToken'}).timeout(
        Duration(seconds: Connection_Timeout_TimeLimit));
    Map<String, dynamic> response_code_JSON = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if(response_code_JSON['StatusCode'] == 1000){
        _dialogStatus = dialog_Status.Success;
      } else if (response_code_JSON['StatusCode'] == 1002) {
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Profiles_ChangeDefaultEmail_Exists];
      } else {
        debugPrint(response_code_JSON.toString());
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Profiles_ChangeDefaultEmail_Failed];
      }
    } else {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
      debugPrint(response.body.toString());
    }
  } on TimeoutException catch (e) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
    debugPrint(e.toString());
  } on Error catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
    debugPrint(_.toString());
  } on SocketException catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
    debugPrint(_.toString());
  } on FormatException catch (_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error_FormatException];
    debugPrint(_.toString());
  } on HandshakeException catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on Exception catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  }

  if(_dialogStatus != dialog_Status.Success) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Confirm(
            dialog_type: _dialogStatus,
            description: dialog_Msg,
          ),
    );
    return false;
  } else
    return true;
}

// Change Password
Future<bool> sendResetPWRequest(BuildContext context, String username, String email) async{
  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "";
  bool isunvalidemail = false;

  Future.delayed(Duration.zero, () => {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Confirm(
            showButton: false,
            dialog_type: dialog_Status.Loading,
            description: Localizations_Text[CurrentLang][Localizations_Text_Identifier
                .SendResetPWRequest_Sending],
          ),
    )
  });

  Uri uri = Uri.parse(ResetPassword_URL);

  var update_data = {
    'Username': username,
    'Email': email,
    'Language': CurrentLang.id,
    'AppCode': Application_Identifier_Code,
    'Version': Application_Version
  };

  debugPrint(update_data.toString());

  try {
    final response = await http.post(
        uri, body: json.encode(update_data), headers: {'Authorization':  'JWT $userToken'}).timeout(
        Duration(seconds: Connection_Timeout_TimeLimit));
    Map<String, dynamic> response_code_JSON = jsonDecode(response.body);
    if (response.statusCode == 200) {

      if(response_code_JSON['StatusCode'] == 1000){
        _dialogStatus = dialog_Status.Success;
      } else if(response_code_JSON['StatusCode'] == 1002){
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.SendResetPWRequest_ACNotFound];
      } else if(response_code_JSON['StatusCode'] == 1003){
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.SendResetPWRequest_ApplicationInvaild];
      } else if(response_code_JSON['StatusCode'] == 1004){
        isunvalidemail = true;
        _dialogStatus = dialog_Status.Error;
        dialog_Msg += Localizations_Text[CurrentLang][Localizations_Text_Identifier.Login_Error_Unverified_Email];
      } else {
        debugPrint(response_code_JSON.toString());
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.SendResetPWRequest_Failed];
      }
    } else {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
      debugPrint(response.body.toString());
    }
  } on TimeoutException catch (e) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
    debugPrint(e.toString());
  } on Error catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
    debugPrint(_.toString());
  } on SocketException catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
    debugPrint(_.toString());
  } on FormatException catch (_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error_FormatException];
    debugPrint(_.toString());
  } on HandshakeException catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on Exception catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  }

  Navigator.of(context).pop();

  if(isunvalidemail){
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Selection(
            dialog_type: _dialogStatus,
            description: dialog_Msg,
            buttonText_Confirm: Localizations_Text[CurrentLang][Localizations_Text_Identifier.ResendValidationEmailButtonTitle],
            callback_Confirm: () async => {
              if(await sendValidationRequest(context, username)){
                _dialogStatus = dialog_Status.Success,
                dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.ResendValidationEmail_Success],
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) => CustomDialog_Confirm(
                    dialog_type: _dialogStatus,
                    description: dialog_Msg,
                    callback_Confirm: () => {
                      Navigator.of(context)
                          .pushAndRemoveUntil(
                          gotoPage(MainPage(), Duration(seconds: 0, milliseconds: 0)), (
                          Route<dynamic> route) => false),
                    },
                  ),
                )
              }
            },
            leftbtn_flex: 7,
            rightbtn_flex: 4,
          ),
    );
    return false;
  }

  else if(_dialogStatus != dialog_Status.Success) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Confirm(
            dialog_type: _dialogStatus,
            description: dialog_Msg,
          ),
    );
    return false;
  } else
    return true;
}

// Update User Group List
Future<bool> insertUserGroup(BuildContext context, String Groupname) async{
  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "";

  var insert_data;
  try{
    // Call Web API and try to get a result from Server
    var response_code;

    insert_data = {
      'GroupName': Groupname,
    };

    response_code = await http.post(
    InsertUserGroup_URL, body: json.encode(
    insert_data,)).timeout(
    Duration(seconds: Connection_Timeout_TimeLimit));

    debugPrint(insert_data.toString());

    if(response_code.statusCode == 200) {
      // There are no any error at inserting to DB.
      _dialogStatus = dialog_Status.Success;
    } else {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.CourseCreator_EditingFail];
    }
  } on TimeoutException catch (e) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on Error catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.CourseCreator_EditingFail];
    debugPrint(_.toString());
  } on SocketException catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
  } on FormatException catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error_FormatException];
  } on HandshakeException catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on Exception catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  }

  if(_dialogStatus != dialog_Status.Success) {
    Navigator.of(context)
        .pushAndRemoveUntil(gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false);
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Confirm(
            dialog_type: _dialogStatus,
            description: dialog_Msg,
          ),
    );
    return false;
  } else
    return true;
}

// Fetch Course List
Future<bool> fetchCourses(BuildContext context, {String queryparam, String isAdminCheck = "false"}) async {
  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "";

  Future.delayed(Duration.zero, () => {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Confirm(
            showButton: false,
            dialog_type: dialog_Status.Loading,
            description: Localizations_Text[CurrentLang][Localizations_Text_Identifier
                .Course_View_LoadingList],
          ),
    )
  });

  Uri uri = Uri.parse(Get_CoursesData_URL);
  if(queryparam != null)
    uri = uri.replace(queryParameters: <String, String>{'UID': UserData_UID, queryparam: 'true', 'isAdmin': isAdminCheck});
  else
    uri = uri.replace(queryParameters: <String, String>{'UID': UserData_UID, 'isAdmin': isAdminCheck});
  debugPrint(uri.toString());

  try {
    final response = await http.get(uri, headers: {'Authorization':  'JWT $userToken'}).
    timeout(Duration(seconds: Connection_Timeout_TimeLimit));

    List<CourseListItem> _courseList = new List<CourseListItem>();

    // Getting Server response into variable.
    Map<String, dynamic> response_code_JSON = jsonDecode(response.body);
    debugPrint(response_code_JSON['StatusCode'].toString());
    if (response.statusCode == 200) {
      //debugPrint(response_code_JSON['StatusCode'].toString());
      _dialogStatus = dialog_Status.Success;
      _courseList = CourseList.fromJson(json.decode(response.body)).results;
      courseList = _courseList;
      if(courseList.length == 0){
        _dialogStatus = dialog_Status.Warning;
        dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Course_View_NoCourses];
      }
    } else {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_TokenError];
    }
  } on TimeoutException catch (e) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on Error catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
  } on SocketException catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
  } on FormatException catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error_FormatException];
  } on HandshakeException catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on Exception catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  }

  debugPrint(courseList.length.toString());

  Navigator.of(context).pop();

  if(_dialogStatus != dialog_Status.Success) {
    Navigator.of(context)
        .pushAndRemoveUntil(gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false);
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Confirm(
            dialog_type: _dialogStatus,
            description: dialog_Msg,
          ),
    );
    return false;
  } else
    return true;
}

Future<bool> fetchCourseUnits(BuildContext context, int courseID, {String queryparam}) async {
  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "";

  Future.delayed(Duration.zero, () => {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Confirm(
            showButton: false,
            dialog_type: dialog_Status.Loading,
            description: Localizations_Text[CurrentLang][Localizations_Text_Identifier
                .CourseUnitListPage_LoadingList],
          ),
    )
  });

  Uri uri = Uri.parse(Get_CourseUnitData_URL);
  if(queryparam != null)
    uri = uri.replace(queryParameters: <String, String>{'CID': courseID.toString(), 'UID': UserData_UID, queryparam: 'true'});
  else
    uri = uri.replace(queryParameters: <String, String>{'CID': courseID.toString(), 'UID': UserData_UID});
  debugPrint(uri.toString());

  try {
    final response = await http.get(uri, headers: {'Authorization':  'JWT $userToken'}).
    timeout(Duration(seconds: Connection_Timeout_TimeLimit));
    List<CourseUnitListItem> _courseUnitList = new List<CourseUnitListItem>();

    if (response.statusCode == 200) {
      _dialogStatus = dialog_Status.Success;
      _courseUnitList = CourseUnitList.fromJson(json.decode(response.body)).results;
      courseUnitList = _courseUnitList;
    } else {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
    }
  } on TimeoutException catch (e) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on Error catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
    debugPrint(_.toString());
  } on SocketException catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
  } on FormatException catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error_FormatException];
  } on HandshakeException catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on Exception catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  }

  //debugPrint(courseUnitList.length.toString());

  Navigator.of(context).pop();

  if(_dialogStatus != dialog_Status.Success) {
    Navigator.of(context)
        .pushAndRemoveUntil(gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false);
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Confirm(
            dialog_type: _dialogStatus,
            description: dialog_Msg,
          ),
    );
    return false;
  } else
    return true;
}

Future<bool> fetchMaterialContentData(BuildContext context, int ModuleID) async{
  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "";

  Uri uri = Uri.parse(Get_MaterialsData_URL);
  uri = uri.replace(queryParameters: <String, String>{
    'CID': selectedCourse.courseID.toString(),'UnitID': selectedCourseUnit.unitID.toString(), 'MID': ModuleID.toString()});
  debugPrint(uri.toString());
  Future.delayed(Duration.zero, () => {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Confirm(
            showButton: false,
            dialog_type: dialog_Status.Loading,
            description: Localizations_Text[CurrentLang][Localizations_Text_Identifier
                .Course_ContentPage_Editor_LoadingData],
          ),
    )
  });
  try {
    // Call Web API and try to get a result from Server
    var response_code = await http.get(
        uri, headers: {'Authorization':  'JWT $userToken'}).timeout(Duration(seconds: Connection_Timeout_TimeLimit));

    MaterialListItem materialListItem = MaterialListItem.fromJson(json.decode(response_code.body));

    if(response_code.statusCode == 200) {
      _dialogStatus = dialog_Status.Success;
      editMaterial_Title = materialListItem.materialName;
      editMaterial_Desc = materialListItem.materialDesc;
      editMaterial_STime = DateFormat('HH:mm:ss').format(materialListItem.materialPeriod_Start);
      editMaterial_SDate = DateFormat('yyyy-MM-dd').format(materialListItem.materialPeriod_Start);
      editMaterial_ETime = DateFormat('HH:mm:ss').format(materialListItem.materialPeriod_End);
      editMaterial_EDate = DateFormat('yyyy-MM-dd').format(materialListItem.materialPeriod_End);

      // region Loading Attachments for UI Elements
      List<Widget> thumbs = new List<Widget>();
      List<Widget> _linkthumbs = new List<Widget>();
      materialEditor_AttachmentThumb = new List<Widget>();
      materialEditor_keepAttachmentFilesName = List<String>();
      materialEditor_deleteAttachmentFilesName = List<String>();
      materialEditor_CurrentAttachmentStatus = List<bool>();

      materialEditor_LinksThumb = new List<Widget>();
      materialEditor_CurrentLinksStatus = List<bool>();
      materialEditor_deleteLinksName = List<String>();
      materialEditor_keepLinksName = List<String>();
      foldername = materialListItem.materialFolder;

      debugPrint("Materials List Reload");
      for (int i=0; i < materialListItem.att_list.length; i++) {
        print(materialListItem.att_list[i].attName + ", " + materialListItem.att_list[i].attPath + ", " + materialListItem.att_list[i].attExt + "\n");
        if(materialListItem.att_list[i].attExt != "URL") {
          thumbs.add(Container());
          materialEditor_CurrentAttachmentStatus.add(true);
          materialEditor_keepAttachmentFilesName.add(
              materialListItem.att_list[i].attName);
        } else {
          _linkthumbs.add(Container());
          materialEditor_CurrentLinksStatus.add(true);
          materialEditor_keepLinksName.add(
              materialListItem.att_list[i].attName);
        }
        //endregion
      }
      materialEditor_AttachmentThumb = thumbs;
      materialEditor_LinksThumb = _linkthumbs;

      // endregion

      edit_isMaterialDataLoaded = true;
    }
  } on TimeoutException catch (_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
    debugPrint(_.toString());
  } on Error catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
    debugPrint(_.toString());
  } on SocketException catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
    debugPrint(_.toString());
  } on FormatException catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error_FormatException];
  } on HandshakeException catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on Exception catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  }

  Navigator.of(context).pop();

  if(_dialogStatus != dialog_Status.Success){
    edit_isMaterialDataLoaded = false;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => CustomDialog_Confirm(
        dialog_type: _dialogStatus,
        description: dialog_Msg,
      ),
    );
    return false;
  } else {
    return true;
  }
}

Future<bool> fetchCourseData(BuildContext context, int CourseID) async{
  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "";
  bool isOutdated = false;

  Uri uri = Uri.parse(Get_CoursesData_URL);
  uri = uri.replace(queryParameters: <String, String>{'CID': CourseID.toString()});
  debugPrint(uri.toString());

  Future.delayed(Duration.zero, () => {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Confirm(
            showButton: false,
            dialog_type: dialog_Status.Loading,
            description: Localizations_Text[CurrentLang][Localizations_Text_Identifier
                .Course_Edit_LoadingData],
          ),
    )
  });


  try {
    // Call Web API and try to get a result from Server
    var response_code = await http.get(
        uri, headers: {'Authorization':  'JWT $userToken'}).timeout(Duration(seconds: Connection_Timeout_TimeLimit));

    Map<String, dynamic> responseJSON = jsonDecode(response_code.body);

    CourseListItem courseListItem = CourseListItem.fromJson(json.decode(response_code.body));
    selectedCourse = courseListItem;

    selected_group = [];
    selectedCourse.courseAccessibleGroup.forEach((element) {
      if(groupList.any((check) => check.groupName == element)){
        selected_group.add(groupList.firstWhere((group) => group.groupName == element));
      }
    });

    if(response_code.statusCode == 200) {
      _dialogStatus = dialog_Status.Success;

      if(responseJSON['StatusCode'] != "OK"){
        isOutdated = true;
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Course_Page_CourseNotFound];
      } else {
        if(!(DateTime.now().isBefore(selectedCourse.coursePeriod_End) || canUpload)){
          isOutdated = true;
          _dialogStatus = dialog_Status.Error;
          dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Course_Page_CourseOutdated];
        } else {

        }
      }
    }

  } on TimeoutException catch (_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
    debugPrint(_.toString());
  } on Error catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
    debugPrint(_.toString());
  } on SocketException catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
    debugPrint(_.toString());
  } on FormatException catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error_FormatException];
  } on HandshakeException catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on Exception catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  }

  Navigator.of(context).pop();

  if(_dialogStatus != dialog_Status.Success){
    Navigator.of(context)
        .pushAndRemoveUntil(gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false);
    if(canUpload){
      if(await fetchCourses(context, isAdminCheck: 'true')){
        course_list_filter_option = Localizations_Text[CurrentLang][Localizations_Text_Identifier.StatusFilter_All];
        Navigator.of(context).push(gotoPage(CourseList_Page, Duration(seconds: 0, milliseconds: 0)));
      }
    } else {
      if(await fetchCourses(context, queryparam: "isOpening")){
        course_list_filter_option = Localizations_Text[CurrentLang][Localizations_Text_Identifier.StatusFilter_Opening];
        Navigator.of(context).push(gotoPage(CourseList_Page, Duration(seconds: 0, milliseconds: 0)));
      }
    }
    edit_isCourseDataLoaded = false;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => CustomDialog_Confirm(
        dialog_type: _dialogStatus,
        description: dialog_Msg,
      ),
    );
    return false;
  } else {
    return true;
  }
}

Future<bool> fetchCourseUnitData(BuildContext context, int UnitID) async{
  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "";

  Uri uri = Uri.parse(Get_CourseUnitData_URL);
  uri = uri.replace(queryParameters: <String, String>{'CID': selectedCourse.courseID.toString(), 'UnitID': UnitID.toString()});
  debugPrint(uri.toString());
  Future.delayed(Duration.zero, () => {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Confirm(
            showButton: false,
            dialog_type: dialog_Status.Loading,
            description: Localizations_Text[CurrentLang][Localizations_Text_Identifier
                .Course_Edit_LoadingData],
          ),
    )
  });
  try {
    // Call Web API and try to get a result from Server
    var response_code = await http.get(
        uri, headers: {'Authorization':  'JWT $userToken'}).timeout(Duration(seconds: Connection_Timeout_TimeLimit));

    debugPrint(response_code.body.toString());

    CourseUnitListItem courseUnitListItem = CourseUnitListItem.fromJson(json.decode(response_code.body));
    selectedCourseUnit = courseUnitListItem;

    if(selectedCourseUnit.skip_moduleSelection == true && selectedCourseUnit.to_moduleID != null){
      MaterialListItem goto_material =  materialList.firstWhere((element) => element.materialID == int.parse(selectedCourseUnit.to_moduleID));
      editCourseUnit_SelectedGoToMaterial = goto_material.materialID.toString() + "|" + goto_material.materialName;
    } else {
      editCourseUnit_SelectedGoToMaterial = Localizations_Text[CurrentLang][Localizations_Text_Identifier.CourseUnitCreator_Creator_SkipModuleSelection_Default];
    }

    if(response_code.statusCode == 200) {
      _dialogStatus = dialog_Status.Success;
      if(!(DateTime.now().isBefore(selectedCourseUnit.unitPeriod_End) || canUpload)){
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Course_Page_CourseOutdated];
      }
    }



  } on TimeoutException catch (_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on Error catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
    debugPrint(_.toString());
  } on SocketException catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
    debugPrint(_.toString());
  } on FormatException catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error_FormatException];
  } on HandshakeException catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on Exception catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  }

  Navigator.of(context).pop();

  if(_dialogStatus != dialog_Status.Success){
    Navigator.of(context)
        .pushAndRemoveUntil(gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false);
    Navigator.of(context).push(gotoPage(CourseList_Page, Duration(seconds: 0, milliseconds: 0)));
    edit_isCourseDataLoaded = false;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => CustomDialog_Confirm(
        dialog_type: _dialogStatus,
        description: dialog_Msg,
      ),
    );
    return false;
  } else {
    return true;
  }
}

Future<bool> fetchMaterials(BuildContext context, int courseID, int unitID, {String queryparam}) async {
  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "";

  Future.delayed(Duration.zero, () => {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Confirm(
            showButton: false,
            dialog_type: dialog_Status.Loading,
            description: Localizations_Text[CurrentLang][Localizations_Text_Identifier
                .Course_Page_LoadingMaterialList],
          ),
    )
  });

  try {
    Uri uri = Uri.parse(Get_MaterialsData_URL);
    if(queryparam != null)
      uri = uri.replace(queryParameters: <String, String>{'CID': courseID.toString(),'UnitID': unitID.toString(), 'UID': UserData_UID ,queryparam: 'true'});
    else
      uri = uri.replace(queryParameters: <String, String>{'CID': courseID.toString(),'UnitID': unitID.toString(), 'UID': UserData_UID});
    debugPrint(uri.toString());
    final response = await http.get(uri, headers: {'Authorization':  'JWT $userToken'}).timeout(Duration(seconds: Connection_Timeout_TimeLimit));
    List<MaterialListItem> _materialList = new List<MaterialListItem>();
    if (response.statusCode == 200) {
      //print(response.body);
      _dialogStatus = dialog_Status.Success;
      _materialList = MaterialList.fromJson(json.decode(response.body)).results;
      materialList = _materialList;
      courseUnitMaterialsNameList = new List<String>();
      courseUnitMaterialsNameList.add(Localizations_Text[CurrentLang][Localizations_Text_Identifier.CourseUnitCreator_Creator_SkipModuleSelection_Default]);
      materialList.forEach((element) {
        courseUnitMaterialsNameList.add(element.materialID.toString() + "|" + element.materialName);
      });
    } else {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
    }
  } on TimeoutException catch (e) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on Error catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
  } on SocketException catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
  } on FormatException catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error_FormatException];
  } on HandshakeException catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on Exception catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  }

  Navigator.of(context).pop();

  if(_dialogStatus != dialog_Status.Success) {
    Navigator.of(context)
        .pushAndRemoveUntil(gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false);
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Confirm(
            dialog_type: _dialogStatus,
            description: dialog_Msg,
          ),
    );
    return false;
  } else
    return true;
}

Future<bool> fetchContentMaterials(BuildContext context,int courseID, int unitID, int materialID) async {
  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "";

  Future.delayed(Duration.zero, () => {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Confirm(
            showButton: false,
            dialog_type: dialog_Status.Loading,
            description: Localizations_Text[CurrentLang][Localizations_Text_Identifier
                .Course_ContentPage_LoadingAttachmentList],
          ),
    )
  });

  Uri uri = Uri.parse(Get_MaterialsData_URL);
  if(courseID != null && materialID != null)
    uri = uri.replace(queryParameters: <String, String>{'CID': courseID.toString(), 'UnitID': unitID.toString(), 'MID': materialID.toString(), 'UID': UserData_UID});
  debugPrint(uri.toString());

  try {
    final response = await http.get(uri, headers: {'Authorization':  'JWT $userToken'}).timeout(Duration(seconds: Connection_Timeout_TimeLimit));
    materialListItem = new MaterialListItem();
    module_AttachmentCheckingStatus = new List<bool>();
    if (response.statusCode == 200) {
      _dialogStatus = dialog_Status.Success;
      materialListItem = MaterialListItem.fromJson(json.decode(response.body));
      selectedMaterial = materialListItem;
      if(!(DateTime.now().isBefore(selectedMaterial.materialPeriod_End) || canUpload)){
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Course_ContentPage_ContentOutdated];
      }
      // Reload
      for(int i = 0; i < selectedMaterial.att_list.length; i++){
        module_AttachmentCheckingStatus.add(selectedMaterial.att_list[i].check_status);
      }

    } else {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
    }
  } on TimeoutException catch (e) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on Error catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
    debugPrint(_.toString());
  } on SocketException catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
  } on FormatException catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error_FormatException];
    debugPrint(_.toString());
  } on HandshakeException catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on Exception catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  }

  Navigator.of(context).pop();

  if(_dialogStatus == dialog_Status.Error) {
    Navigator.of(context)
        .pushAndRemoveUntil(gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false);
    Navigator.of(context).push(gotoPage(CourseList_Page, Duration(seconds: 0, milliseconds: 0)));
    Navigator.of(context).push(gotoPage(CourseUnit_Page, Duration(seconds: 0, milliseconds: 0)));
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Confirm(
            dialog_type: _dialogStatus,
            description: dialog_Msg,
          ),
    );
    return false;
  } else
    return true;
}

Future<bool> fetchSurvey(BuildContext context, {String queryparam, String isAdminCheck = "false"}) async {
  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "";

  Future.delayed(Duration.zero, () => {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Confirm(
            showButton: false,
            dialog_type: dialog_Status.Loading,
            description: Localizations_Text[CurrentLang][Localizations_Text_Identifier
                .Survey_ListPage_LoadingList],
          ),
    )
  });

  Uri uri = Uri.parse(Get_SurveyData_URL);
  if(queryparam != null)
    uri = uri.replace(queryParameters: <String, String>{queryparam: 'true','UID': UserData_UID, 'isAdmin': isAdminCheck});
  else {
    uri = uri.replace(queryParameters: <String, String>{'UID': UserData_UID,'isAdmin': isAdminCheck});
  }
  debugPrint(uri.toString());

  try {
    final response = await http.get(uri, headers: {'Authorization':  'JWT $userToken'}).
    timeout(Duration(seconds: Connection_Timeout_TimeLimit));
    List<SurveyListItem> _surveyList = new List<SurveyListItem>();
    if (response.statusCode == 200) {
      _dialogStatus = dialog_Status.Success;
      _surveyList = SurveyList.fromJson(json.decode(response.body)).results;
      surveyList = _surveyList;
    } else {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
      debugPrint(response.body.toString());
    }
  } on TimeoutException catch (e) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on Error catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
    debugPrint(_.toString());
  } on SocketException catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
    debugPrint(_.toString());
  } on FormatException catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error_FormatException];
  } on HandshakeException catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on Exception catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  }

  debugPrint(surveyList.length.toString());
  if(surveyList.length == 0){
    _dialogStatus = dialog_Status.Warning;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Survey_ListPage_NoSurvey];
  }

  Navigator.of(context).pop();

  if(_dialogStatus != dialog_Status.Success) {
    Navigator.of(context)
        .pushAndRemoveUntil(gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false);
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Confirm(
            dialog_type: _dialogStatus,
            description: dialog_Msg,
          ),
    );
    return false;
  } else
    return true;
}

Future<bool> fetchSurveyData(BuildContext context, int SurveyID) async {
  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "";

  Future.delayed(Duration.zero, () => {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Confirm(
            showButton: false,
            dialog_type: dialog_Status.Loading,
            description: Localizations_Text[CurrentLang][Localizations_Text_Identifier
                .Survey_Editor_LoadingSurveyData],
          ),
    )
  });

  Uri uri = Uri.parse(Get_SurveyData_URL);
  uri = uri.replace(queryParameters: <String, String>{"SurveyID": SurveyID.toString()});
  debugPrint(uri.toString());

  try {
    final response = await http.get(uri, headers: {'Authorization':  'JWT $userToken'}).
    timeout(Duration(seconds: Connection_Timeout_TimeLimit));

    if (response.statusCode == 200) {
      _dialogStatus = dialog_Status.Success;
      SurveyListItem surveyListItem = SurveyListItem.fromJson(json.decode(response.body));
      selectedSurvey = surveyListItem;

      selected_group = [];
      selectedSurvey.surveyAccessibleGroup.forEach((element) {
        if(groupList.any((check) => check.groupName == element)){
          selected_group.add(groupList.firstWhere((group) => group.groupName == element));
        }
      });

    } else {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
    }
  } on TimeoutException catch (e) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on Error catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
  } on SocketException catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
  } on FormatException catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error_FormatException];
  } on HandshakeException catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on Exception catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  }

  debugPrint(surveyList.length.toString());
  if(surveyList.length == 0){
    _dialogStatus = dialog_Status.Warning;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Survey_ListPage_NoSurvey];
  }

  Navigator.of(context).pop();

  if(_dialogStatus != dialog_Status.Success) {
    Navigator.of(context)
        .pushAndRemoveUntil(gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false);
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Confirm(
            dialog_type: _dialogStatus,
            description: dialog_Msg,
          ),
    );
    return false;
  } else
    return true;
}

enum progress_Table{
  Course,
  Unit,
  Module,
  Attachment
}

extension progress_table_name on progress_Table{

  String get id{
    switch(this){
      case progress_Table.Course:
        return "Course";
        break;
      case progress_Table.Attachment:
        return "Attachment";
        break;
      case progress_Table.Unit:
        return "Unit";
        break;
      case progress_Table.Module:
        return "Module";
        break;
    }
  }
}

Future<bool> update_progress(BuildContext context, progress_Table table_name, {int courseID, int unitID, int matID, int attID, int check_status}) async {
  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "";

  Future.delayed(Duration.zero, () => {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Confirm(
            showButton: false,
            dialog_type: dialog_Status.Loading,
            description: Localizations_Text[CurrentLang][Localizations_Text_Identifier
                .Progress_Updating],
          ),
    )
  });

  var update_data = {
    'UpdateTable': table_name.id,
    'UID': int.parse(UserData_UID),
    'CourseID': courseID ?? -1,
    'UnitID': unitID ?? -1,
    'MaterialID': matID ?? -1,
    'AttID': attID ?? -1,
    'check_status': check_status ?? 0,
  };

  debugPrint(update_data.toString());

  try {
    // Call Web API and try to get a result from Server
    var response_code = await http.post(
        UpdateProgress_URL, body: json.encode(update_data), headers: {'Authorization':  'JWT $userToken'}).timeout(
        Duration(seconds: Connection_Timeout_TimeLimit));

    // Getting Server response into variable.
    Map<String, dynamic> response_code_JSON = jsonDecode(response_code.body);

    // If Web call Success than Hide the CircularProgressIndicator.
    if (response_code.statusCode == 200) {
      debugPrint(response_code.body.toString());
      // There are no any error in login procedure.
      if (response_code_JSON['StatusCode'] == 1000) {
        _dialogStatus = dialog_Status.Success;
      } else {
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
      }
    }
  } on TimeoutException catch (e) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on Error catch (_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
    debugPrint(_.toString());
  } on SocketException catch (_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
  } on FormatException catch (_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error_FormatException];
    debugPrint(_.toString());
  } on HandshakeException catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on Exception catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  }

  Navigator.of(context).pop();

  if(_dialogStatus != dialog_Status.Success) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Confirm(
            dialog_type: _dialogStatus,
            description: dialog_Msg,
          ),
    );
    return false;
  } else
    return true;
}