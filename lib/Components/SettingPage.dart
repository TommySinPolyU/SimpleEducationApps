import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Helper/ComponentsList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Helper/global_setting.dart' as globals;
import 'package:smeapp/Helper/Localizations.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "", dialog_Msg_Title = "";
  Image dialog_image;

  // Boolean variable for Setting Page.
  bool visible_SettingPage = true;

  int isautoLogin = 0;
  int isnotificationOn = 0;
  int fontSizeSet = 0;

  String techsupport_email_body;

  final techsupport_email_userinfo = "應用程式版本 Version of Apps: " + Application_Version +
      "<br>=================================<br>" +
      "用戶資料 User Information:<br>用戶編號 UID: " + globals.UserData_UID +
      "<br>用戶註冊碼 User Registration Code: "+ globals.UserData_regisCode+
      "<br>=================================<br>";

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  
  @override
  void initState() {
    super.initState();
    _ReloadPrefs();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => initPlatformState());
  }

  Future<void> initPlatformState() async {
    Map<String, dynamic> deviceData;


    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }



    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
      if (Platform.isAndroid) {
        techsupport_email_body = //"=================================<br>" +
            Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.TechSupport_Label_UserDeviceInformation] + "<br>" +
            Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.TechSupport_Label_Manufacturer] +  _deviceData['manufacturer'] + "<br>" +
            Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.TechSupport_Label_UserDeviceModel] +  _deviceData['model'] + ", " + _deviceData['product'] + "<br>" +
            Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.TechSupport_Label_UserDeviceVersion] +  _deviceData['version.sdkInt'].toString() + ", " + _deviceData['version.incremental'] +
            "<br>=================================<br>" +
            Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.TechSupport_Question_Title] + "<br><br>" +
            Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.TechSupport_Attachment_Title];
      } else if (Platform.isIOS) {
        techsupport_email_body = //"=================================<br>" +
            Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.TechSupport_Label_UserDeviceInformation] + "<br>" +
            Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.TechSupport_Label_Manufacturer] +  "Apple" + "<br>" +
            Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.TechSupport_Label_UserDeviceModel] +  _deviceData['model'] + ", " + _deviceData['systemName'] + "<br>" +
            Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.TechSupport_Label_UserDeviceVersion] +  _deviceData['systemVersion'] +
            "<br>=================================<br>" +
            Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.TechSupport_Question_Title] + "<br>" +
            Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.TechSupport_Attachment_Title] + "<br>";
      }
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
      'systemFeatures': build.systemFeatures,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  _ReloadPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isautoLogin = prefs.getInt(Pref_AutoLogin) ?? 0;
      isnotificationOn = prefs.getInt(Pref_NotificationPermission) ?? 0;
      fontSizeSet = prefs.getInt(Pref_FontSize);
      //print("FontSize: " + fontSizeSet.toString());
      if(Localizations_Language_Identifier.values.toString().contains(prefs.getString(Setting_Language)))
        globals.CurrentLang = (Localizations_Language_Identifier.values.firstWhere((e) => e.toString() ==
            prefs.getString(Setting_Language)));
      else
        globals.CurrentLang = Localizations_Language_Identifier.Language_Eng;
    });
  }

  _UploadPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(Setting_Language, globals.CurrentLang.toString());
    prefs.setInt(Pref_NotificationPermission, isnotificationOn);
    prefs.setInt(Pref_FontSize, fontSizeSet);
    RestartWidget.restartApp(context);
  }

  Future local_logoutProcess() async {
    /*
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      visible_SettingPage = false;
      globals.visible_Loading = true;
    });

    globals.state_BottomBar.setState(() {

    });

    var logout_data = {
      'UID': (prefs.getString(Pref_Profiles_UID) ?? "")};

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
          dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Logout_Success];
          _dialogStatus = dialog_Status.Success;
          globals.isLoggedIn = false;
          globals.state_BottomBar.setState(() {
            globals.PageIndex = 0;
          });
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString(Pref_Profiles_UID, "");
          prefs.setString(Pref_Profiles_Nickname, "");
          prefs.setString(Pref_Profiles_Firstname, "");
          prefs.setString(Pref_Profiles_Lastname, "");
          prefs.setString(Pref_Profiles_Email, "");
          prefs.setString(Pref_Profiles_Gender, "");
          prefs.setString(Pref_User_RegisCode, "");
          prefs.setString(Pref_User_SaltedPassword, "");
          prefs.setString(Pref_User_UserName, "");
          prefs.setBool(Pref_AutoLogin, false);
          //globals.PageIndex = 0;
        } else {
          dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Logout_Error_TopLine];
        }
        setState(() {
          visible_SettingPage = true;
          globals.visible_Loading = false;
        });
      } else {
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error] + "(" + response_code.statusCode + ")";
        setState(() {
          visible_SettingPage = true;
          globals.visible_Loading = false;
        });
      }
    } on TimeoutException catch (e) {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
      setState(() {
        visible_SettingPage = true;
        globals.visible_Loading = false;
      });
    } on Error catch(_) {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error];
      setState(() {
        visible_SettingPage = true;
        globals.visible_Loading = false;
      });
    } on SocketException catch(_){
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error];
      setState(() {
        visible_SettingPage = true;
        globals.visible_Loading = false;
      });
    } on FormatException catch(_) {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error_FormatException];
      setState(() {
        visible_SettingPage = true;
        globals.visible_Loading = false;
      });
    }

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

    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog_Confirm(
        title: dialog_Msg_Title,
        description: dialog_Msg,
        buttonText: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Confirm],
        image: dialog_image,
      ),
    );

    globals.state_BottomBar.setState(() {

    });
    */
    logoutProcess(context, clear_data: true);
  }

  @override
  Widget build(BuildContext context) {
    Email tech_email;

    Future<void> _permission_SendRequest() async {;
      Map<Permission, PermissionStatus> statuses = await [
        Permission.notification,
      ].request();
      if (statuses[Permission.notification] == PermissionStatus.denied || statuses[Permission.notification] == PermissionStatus.permanentlyDenied) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt(Pref_NotificationPermission, 0);
        List<String> topics = [];
        List<String> remove_topics = [];
        topics = prefs.containsKey('Subscribed_Topics') ? prefs.getStringList('Subscribed_Topics') : [];
        //firebaseMessaging.deleteInstanceID();

        topics.forEach((element) {
          //print("Unsubscribed: " + element);
          globals.firebaseMessaging.unsubscribeFromTopic(element);
          remove_topics.add(element);
        });

        remove_topics.forEach((element) {
          topics.remove(element);
        });
        setState(() {
          isnotificationOn = 0;
        });
        dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Permission_NotificationDenied];
        await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) =>
              CustomDialog_Selection(
                dialog_type: dialog_Status.Warning,
                description: dialog_Msg,
                buttonText_Confirm: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.GoToApplicationSetting],
                callback_Confirm: () =>
                {
                  Navigator.of(context).pop(),
                  openAppSettings(),
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop')
                },
                leftbtn_flex: 7,
                rightbtn_flex: 4,
              ),
        );
      } else if (statuses[Permission.notification] == PermissionStatus.granted) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt(Pref_NotificationPermission, 1);
        List<String> topics = [];
        List<String> remove_topics = [];
        topics = prefs.containsKey('Subscribed_Topics') ? prefs.getStringList('Subscribed_Topics') : [];
        //firebaseMessaging.deleteInstanceID();

        topics.forEach((element) {
          //print("Unsubscribed: " + element);
          globals.firebaseMessaging.unsubscribeFromTopic(element);
          remove_topics.add(element);
        });

        remove_topics.forEach((element) {
          topics.remove(element);
        });

        globals.userSubGroup.forEach((element) {
          String topic_name = "GroupMessage_" + element.replaceAll(" ", "_");
          topics.add(topic_name);
        });

        topics.add("GroupMessage_All");

        topics.forEach((element) {
          print("Subscribed: " + element + "\n");
          globals.firebaseMessaging.subscribeToTopic(element);
        });

        prefs.setStringList("Subscribed_Topics", topics);
        setState(() {
          isnotificationOn = 1;
        });
      }
    }

    final Label_Language = Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 15),
          child: Icon(Icons.language),
        ),
        Padding(
          padding: EdgeInsets.only(left: 20,right: 60),
          child: Text(
            Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.languageButtonText],
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: globals.fontSize_Middle,
                color: appPrimaryColor),
          ),
        )
      ],
    );
    final Label_AutoLogin = Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 15),
          child: Icon(Icons.login),
        ),
        Padding(
          padding: EdgeInsets.only(left: 20,right: 0),
          child: Text(
            Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.autoLoginText],
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: globals.fontSize_Middle,
                color: appPrimaryColor),
          ),
        )
      ],
    );

    final Label_NotificationPermission = Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 15),
          child: Icon(Icons.notifications_active),
        ),
        Padding(
          padding: EdgeInsets.only(left: 20,right: 0),
          child: Text(
            Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.NotificationPermission],
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: globals.fontSize_Middle,
                color: appPrimaryColor),
          ),
        )
      ],
    );

    final Label_FontSizeSelection = Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 15),
          child: Icon(Icons.font_download_outlined),
        ),
        Padding(
          padding: EdgeInsets.only(left: 20,right: 0),
          child: Text(
            Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.fontSizeSelectorText],
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: globals.fontSize_Middle,
                color: appPrimaryColor),
          ),
        )
      ],
    );


    final language_controller = TextEditingController();
    language_controller.text = globals.CurrentLang.id;

    final languageSelection_new = InkWell(
      onTap: () => {
        SelectDialog.showModal<String>(
          context,
          label: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.languageButtonText],
          selectedValue: globals.CurrentLang.id,
          items: Localizations_Language_Identifier.values.map((Localizations_Language_Identifier value) {
            return value.id;
          }).toList(),
          titleStyle: TextStyle(fontSize: globals.fontSize_Middle),
          showSearchBox: false,
          onChange: (String selected) => {
            setState(() {
              if(globals.CurrentLang.id != selected) {
                //print(Localizations_Language_Identifier.values.firstWhere((e) => e.id == selected));
                //NotificationSetting.translate_AllNotification(globals.CurrentLang, Localizations_Language_Identifier.values.firstWhere((e) => e.id == selected));
                if (selected == Localizations_Language_Identifier.Language_TC.id)
                  globals.CurrentLang = Localizations_Language_Identifier.Language_TC;
                else if (selected == Localizations_Language_Identifier.Language_Eng.id)
                  globals.CurrentLang = Localizations_Language_Identifier.Language_Eng;
                _UploadPrefs();
              }
              language_controller.text = globals.CurrentLang.id;
            }),
          },
        )
      },
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black54)
        ),
        child: Row(
          children: <Widget>[
            Label_Language,
            Expanded(
              child: TextFormField(
                textAlign: TextAlign.right,
                controller: language_controller,
                readOnly: true,
                enabled: false,
                keyboardType: TextInputType.text,
                maxLength: 32,
                maxLines: 1,
                style: TextStyle(
                  color: appPrimaryColor,
                  fontSize: globals.fontSize_Normal,
                ),
                enableInteractiveSelection: false,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0,15,0,0),
                    counterText: "",
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.arrow_right),
                    )
                ),
              ),
            )
          ],
        ),
      ),
    );
    final autoLogin_Switch = InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black54)
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 15),
              child: Label_AutoLogin,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(padding: EdgeInsets.only(top:10, bottom: 10, right: 10),
                child: ToggleSwitch(
                  minWidth: 45.0,
                  minHeight: 35.0,
                  initialLabelIndex: isautoLogin,
                  cornerRadius: 20.0,
                  activeFgColor: Colors.white,
                  inactiveBgColor: Colors.grey,
                  inactiveFgColor: Colors.white,
                  labels: ['', ''],
                  icons: [
                    Icons.block,
                    Icons.check,
                  ],
                  iconSize: 30.0,
                  activeBgColors: [Colors.redAccent, Colors.blue],
                  onToggle: (val) async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setInt(Pref_AutoLogin, val);
                    setState(() {
                      isautoLogin = val;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
    final notificationpermission_Switch = InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black54)
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 15),
              child: Label_NotificationPermission,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(padding: EdgeInsets.only(top:10, bottom: 10, right: 10),
                child: ToggleSwitch(
                  minWidth: 45.0,
                  minHeight: 35.0,
                  initialLabelIndex: isnotificationOn,
                  cornerRadius: 20.0,
                  activeFgColor: Colors.white,
                  inactiveBgColor: Colors.grey,
                  inactiveFgColor: Colors.white,
                  labels: ['', ''],
                  icons: [
                    Icons.block,
                    Icons.check,
                  ],
                  iconSize: 30.0,
                  activeBgColors: [Colors.redAccent, Colors.blue],
                  onToggle: (val) async {
                    if(isnotificationOn == 0){
                      showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            CustomDialog_Selection(
                              dialog_type: dialog_Status.Custom,
                              image: notification_Icon,
                              title: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.NotificationPermission_Title],
                              description: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.NotificationPermission_Description],
                              buttonText_Confirm: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.NotificationPermission_Confirm],
                              callback_Confirm: () async =>
                              {
                                _permission_SendRequest(),
                                Navigator.of(context).pop(),
                              },
                              callback_Cancel: () => {
                                Navigator.of(context).pop(),
                                _ReloadPrefs()
                              },
                            ),
                      );
                    }
                    if(isnotificationOn == 1){
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setInt(Pref_NotificationPermission, 0);
                      List<String> topics = [];
                      List<String> remove_topics = [];
                      topics = prefs.containsKey('Subscribed_Topics') ? prefs.getStringList('Subscribed_Topics') : [];
                      //firebaseMessaging.deleteInstanceID();

                      topics.forEach((element) {
                        print("Unsubscribed: " + element);
                        globals.firebaseMessaging.unsubscribeFromTopic(element);
                        remove_topics.add(element);
                      });

                      remove_topics.forEach((element) {
                        topics.remove(element);
                      });
                      setState(() {
                        isnotificationOn = 0;
                      });
                    }
                    setState(() {
                      isnotificationOn = val;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );

    _fontSizeChange(SharedPreferences prefs, int value) async {
      prefs.setInt(Pref_FontSize, value);
      setState(() {
        fontSizeSet = value;
        globals.state_BottomBar.setState(() {
          if(prefs.getInt(Pref_FontSize) == 0){ // Small
            globals.fontSize_Title = 22;
            globals.fontSize_SubTitle = 19;
            globals.fontSize_Big = 17;
            globals.fontSize_Middle = 16;
            globals.fontSize_Normal = 14;
            globals.fontSize_Small = 12;
          } else if(prefs.getInt(Pref_FontSize) == 1){ // Middle
            globals.fontSize_Title = 24.5;
            globals.fontSize_SubTitle = 21.5;
            globals.fontSize_Big = 19.5;
            globals.fontSize_Middle = 18.5;
            globals.fontSize_Normal = 16.5;
            globals.fontSize_Small = 14.5;
          } else if(prefs.getInt(Pref_FontSize) == 2){ // Large
            globals.fontSize_Title = 28;
            globals.fontSize_SubTitle = 25;
            globals.fontSize_Big = 23;
            globals.fontSize_Middle = 22;
            globals.fontSize_Normal = 20;
            globals.fontSize_Small = 18;
          } else {  // Extra Large
            globals.fontSize_Title = (globals.screen_size.width / 100) + (globals.screen_size.height / 100) * 1.6;
            globals.fontSize_SubTitle = (globals.screen_size.width / 100) + (globals.screen_size.height / 100) * 1.45;
            globals.fontSize_Big = (globals.screen_size.width / 100) + (globals.screen_size.height / 100) * 1.35;
            globals.fontSize_Middle = (globals.screen_size.width / 100) + (globals.screen_size.height / 100) * 1.2;
            globals.fontSize_Normal = (globals.screen_size.width / 100) + (globals.screen_size.height / 100) * 1.1;
            globals.fontSize_Small = (globals.screen_size.width / 100) + (globals.screen_size.height / 100) * 1.0;
            globals.fontSize_Title <= 28 ? globals.fontSize_Title += (28 / 2.5) : globals.fontSize_Title = (globals.screen_size.width / 100) + (globals.screen_size.height / 100) * 1.6;
            globals.fontSize_SubTitle <= 25 ? globals.fontSize_SubTitle += (25 / 2.55) : globals.fontSize_SubTitle = (globals.screen_size.width / 100) + (globals.screen_size.height / 100) * 1.45;
            globals.fontSize_Big <= 23 ? globals.fontSize_Big += (23 / 2.575) : globals.fontSize_Big = (globals.screen_size.width / 100) + (globals.screen_size.height / 100) * 1.35;
            globals.fontSize_Middle <= 22 ? globals.fontSize_Middle += (22 / 2.25) : globals.fontSize_Middle = (globals.screen_size.width / 100) + (globals.screen_size.height / 100) * 1.2;
            globals.fontSize_Normal <= 20 ? globals.fontSize_Normal += (20 / 2.425) : globals.fontSize_Normal = (globals.screen_size.width / 100) + (globals.screen_size.height / 100) * 1.1;
            globals.fontSize_Small <= 18 ? globals.fontSize_Small += (18 / 2.4) : globals.fontSize_Small = (globals.screen_size.width / 100) + (globals.screen_size.height / 100) * 1.0;
          }
        });
      });
      _UploadPrefs();
    }
    List<String> _fontSizeLabel;
    List<Color> _fontSizeSelectedColors;
    if(globals.screen_size.width < 800){
      _fontSizeSelectedColors = [Colors.blue, Colors.blue, Colors.blue];
      _fontSizeLabel = [
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.fontSize_Small],
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.fontSize_Middle],
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.fontSize_Large],
      ];
    } else {
      _fontSizeSelectedColors = [Colors.blue, Colors.blue, Colors.blue, Colors.blue];
      _fontSizeLabel = [
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.fontSize_Small],
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.fontSize_Middle],
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.fontSize_Large],
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.fontSize_ExtraLarge],
      ];
    }

    final fontSize_Switch = InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black54)
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 15, bottom: 10),
              child: Row(
                children: <Widget>[
                  Label_FontSizeSelection,
                ],
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(padding: EdgeInsets.only(top:10, bottom: 10, right: 10),
                    child: ToggleSwitch(
                      minWidth: 60.0,
                      minHeight: 35.0,
                      initialLabelIndex: fontSizeSet,
                      cornerRadius: 20.0,
                      activeFgColor: Colors.white,
                      inactiveBgColor: Colors.grey,
                      inactiveFgColor: Colors.white,
                      labels: _fontSizeLabel,
                      activeBgColors: _fontSizeSelectedColors,
                      onToggle: (val) async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        int fontSize_Setting_Index = prefs.getInt(Pref_FontSize);
                        int default_fontSize_Setting_Index = prefs.getInt(Pref_DefaultFontSize);
                        if(default_fontSize_Setting_Index < val && val != fontSizeSet){
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) => CustomDialog_Selection(
                              dialog_type: dialog_Status.Warning,
                              description: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.fontSizeSelector_Warning],
                              buttonText_Confirm: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Confirm],
                              buttonText_Cancel: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Cancel],
                              callback_Confirm: () async => {
                                _fontSizeChange(prefs, val),
                                Navigator.of(context).pop(),
                              },
                              callback_Cancel: () async => {
                                Navigator.of(context).pop(),
                                setState(() {
                                  fontSizeSet = fontSize_Setting_Index;
                                }),
                              },
                            ),
                          );
                        } else{
                          if(val != fontSizeSet){
                            _fontSizeChange(prefs, val);
                          }
                        }

                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
                padding: EdgeInsets.only(left: 15, top: 10, bottom: 15),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.fontSizeSelectorDefaultDesc] + globals.defaultFontSize,
                        style: TextStyle(fontSize: globals.fontSize_Normal, fontStyle: FontStyle.italic),
                      ),
                    )
                  ],
                ),
            )
          ],
        ),
      ),
    );

    final button_Logout= Card(
      child: ListTile(
        leading: Icon(Icons.logout, size: 40, color: Colors.white,),
        tileColor: Colors.redAccent,
        title: Padding(
          padding: EdgeInsets.only(top: 0, bottom: 0),
          child: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.logoutButtonText],
              style: TextStyle(fontSize: globals.fontSize_Middle, fontWeight: FontWeight.bold,color: Colors.white), textAlign: TextAlign.right,),
        ),
        isThreeLine: false,
        onTap: () async =>  {
          local_logoutProcess()
        },
      ),
    );


    return Scaffold(
        backgroundColor: appBGColor,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: appTitleBarColor,
          title: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.settingButtonText],
            style: TextStyle(fontSize: globals.fontSize_Title),),
        ),
      /*
      Stack(
        children: <Widget>[
          Positioned.fill(
            child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(Application_Version, style: TextStyle(color: Colors.grey),)
            ),
          ),
        ],
      )

       */
        body: Stack(
          children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 35),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(15.0),
              children: [
                languageSelection_new,
                SizedBox(height: 30),
                fontSize_Switch,
                SizedBox(height: 30),
                notificationpermission_Switch,
                Visibility(
                  visible: globals.isLoggedIn,
                  child: SizedBox(height: 30),
                ),
                Visibility(
                  visible: globals.isLoggedIn,
                  child: autoLogin_Switch,
                ),
                Visibility(
                  visible: globals.isLoggedIn,
                  child: SizedBox(height: 30),
                ),
                Card(
                  child: ListTile(
                    leading: technicalSupport_Icon,
                    title: Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 0),
                      child: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.TechSupport_Label_Title],
                          style: TextStyle(fontSize: globals.fontSize_Middle, fontWeight: FontWeight.bold)),
                    ),
                    subtitle: Padding(
                      padding: EdgeInsets.only(top: 5, bottom: 5),
                      child: Text(
                        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.TechSupport_Label_Desc],
                        style: TextStyle(fontSize: globals.fontSize_Small, color: Colors.black54),
                      ),
                    ),
                    isThreeLine: true,
                    onTap: () async =>  {
                      tech_email = Email(
                        body: globals.isLoggedIn ? techsupport_email_userinfo + techsupport_email_body : techsupport_email_body,
                        subject: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.TechSupport_DefaultTitle],
                        recipients: ['sme@techsupport.dsgshk.com'],
                        isHTML: true,
                      ),
                      await FlutterEmailSender.send(tech_email).catchError((error) {
                        //print(error);
                      }),
                    },
                  ),
                ),
                Visibility(
                    visible: globals.isLoggedIn,
                    child: Align(
                        alignment: Alignment.center,
                        child: button_Logout
                    )
                ),
                Visibility(
                    visible: globals.isLoggedIn,
                    child: Align(
                        alignment: FractionalOffset.bottomCenter,
                        child: Text("UID: " + globals.UserData_UID + ", Registration Code: " + globals.UserData_regisCode,
                          style: TextStyle(color: Colors.grey, fontSize: globals.fontSize_Normal),textAlign: TextAlign.center,)
                    )
                ),
              ],
            ),
          ),
            Padding(
              padding: EdgeInsets.only(left: 12.0, right: 12.0, top: 0),
              child: Visibility(
                visible: visible_SettingPage,
                child: Column(
                  children: <Widget>[
                    Expanded(child:
                    Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(Application_Version, style: TextStyle(color: Colors.grey, fontSize: globals.fontSize_Normal),textAlign: TextAlign.center,)
                      ),
                    )
                    ),
                    //!globals.isLoggedIn ? SizedBox(height: MediaQuery.of(context).size.height/ 4) : SizedBox(height: 0,),

                  ],
                ),
              ),
              ),
          ],
        )
    );
  }
}