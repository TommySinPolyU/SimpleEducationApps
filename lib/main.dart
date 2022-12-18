import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smeapp/CustomWidget/CustomDialog.dart';
import 'Helper/global_setting.dart' as globals;
import 'Helper/ComponentsList.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'Components/BottomNavigationBar.dart';
import 'package:smeapp/Helper/Localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'background_main.dart';
import 'package:store_redirect/store_redirect.dart';

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }

  // Or do other work.
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext context){
    return super.createHttpClient(context)
      ..badCertificateCallback = ((X509Certificate cert, String host, int port) {
        final isValidHost = host == Server_Host;
        return isValidHost;
      });
  }
}

/*
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
NotificationAppLaunchDetails notificationAppLaunchDetails;
*/
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /*
  notificationAppLaunchDetails =
  await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  await NotificationSetting.initNotifications(flutterLocalNotificationsPlugin);
  */
  HttpOverrides.global = new MyHttpOverrides();
  runApp(RestartWidget(child: SMEApp()));

  var channel = const MethodChannel('com.eduhk.smeapp/background_service');
  var callbackHandle = PluginUtilities.getCallbackHandle(backgroundMain);
  channel.invokeMethod('startService', callbackHandle.toRawHandle());
}

class SMEApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primaryColor: appPrimaryColor,
          fontFamily: 'TaipeiSansTC'
        ),
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
        supportedLocales: [
          const Locale.fromSubtags(languageCode: 'en'), // generic English 'en'
          const Locale.fromSubtags(languageCode: 'zh'), // generic Chinese 'zh'
          const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'), // generic simplified Chinese 'zh_Hans'
          const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'), // generic traditional Chinese 'zh_Hant'
          const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN'), // 'zh_Hans_CN'
          const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'), // 'zh_Hant_TW'
          const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'HK'), // 'zh_Hant_HK'
          // ... other locales the app supports
        ],
      home: Scaffold(
        body: InitializationPage(),
        resizeToAvoidBottomInset: false,
      ),
    );
  }
}

/*
InitializationPage
Initialize the application with prefs values and reload the language
*/
class InitializationPage extends StatefulWidget{
  @override
  _InitializationPage_State createState() => _InitializationPage_State();
}

class _InitializationPage_State extends State<InitializationPage> {
  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "", dialog_Msg_Title = "";
  Image dialog_image;

  List<bool> permission_bool = new List<bool>();

  @override
  void initState() {
    super.initState();
    //_requestPermissions();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _ReloadPrefs());
  }
/*
  void _requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
 */

  _fontSizeSetting() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    globals.screen_size = MediaQuery.of(context).size;
    print("" + (globals.screen_size.height).toString() + ", " + (globals.screen_size.width).toString());

    // Font Size Setting
    if(prefs.getInt(Pref_FontSize) == null) {
      if(globals.screen_size.width <= 400){
        prefs.setInt(Pref_FontSize, 0);
      } else if (globals.screen_size.width <= 600 && globals.screen_size.width > 400){
        prefs.setInt(Pref_FontSize, 1);
      } else if (globals.screen_size.width < 800 && globals.screen_size.width > 600){
        prefs.setInt(Pref_FontSize, 2);
      } else {
        prefs.setInt(Pref_FontSize, 3);
      }
    }

    setState(() {
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

    globals.fontSizes = [
      globals.fontSize_Title,
      globals.fontSize_SubTitle,
      globals.fontSize_Big,
      globals.fontSize_Middle,
      globals.fontSize_Normal,
      globals.fontSize_Small
    ];
  }

  _ReloadPrefs() async {
    await _fontSizeSetting();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Locale deviceLocale = Localizations.localeOf(context);
    
    if(deviceLocale.toString().contains('en') && prefs.getString(Setting_Language) == null) // Change Application Language to English when first start, if User device language is en.
      prefs.setString(Setting_Language, Localizations_Language_Identifier.Language_Eng.toString());
    else if(deviceLocale.toString().contains('zh') && prefs.getString(Setting_Language) == null) // Change Application Language to TC when first start, if User device language is zh.
      prefs.setString(Setting_Language, Localizations_Language_Identifier.Language_TC.toString());
    else if(!(deviceLocale.toString().contains('en') || deviceLocale.toString().contains('zh')) &&
        prefs.getString(Setting_Language) == null) // Default Language, Change Application Language to English when first start, if User device language is not supported language.
      prefs.setString(Setting_Language, Localizations_Language_Identifier.Language_TC.toString());

    setState(() {
      if (Localizations_Language_Identifier.values.toString().contains(
          prefs.getString(Setting_Language)))
        globals.CurrentLang =
        (Localizations_Language_Identifier.values.firstWhere((e) =>
        e.toString() ==
            prefs.getString(Setting_Language)));
      else
        globals.CurrentLang = Localizations_Language_Identifier.Language_TC;
    });

    if(globals.screen_size.width <= 400){
      globals.defaultFontSize = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier
          .fontSize_Small];
      prefs.setInt(Pref_DefaultFontSize, 0);
    } else if (globals.screen_size.width <= 600 && globals.screen_size.width > 400){
      globals.defaultFontSize = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier
          .fontSize_Middle];
      prefs.setInt(Pref_DefaultFontSize, 1);
    } else if (globals.screen_size.width < 800 && globals.screen_size.width > 600){
      globals.defaultFontSize = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier
          .fontSize_Large];
      prefs.setInt(Pref_DefaultFontSize, 2);
    } else {
      globals.defaultFontSize = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier
          .fontSize_ExtraLarge];
      prefs.setInt(Pref_DefaultFontSize, 3);
    }


    // Tips for Internet Connection when first time run.
    if(prefs.getBool(Pref_isFirstTimeRun) == null) {
      dialog_Msg =
      Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier
          .Internet_ConnectionTips];
      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            CustomDialog_Confirm(
              dialog_type: dialog_Status.Warning,
              description: dialog_Msg,
              callback_Confirm: () =>
              {
                prefs.setBool(Pref_isFirstTimeRun, true),
                Navigator.of(context).pop()
              },
            ),
      );
    }
    await _permissionChecker();
  }

  Future<void> _permissionChecker() async{
    permission_bool.clear();
    //await permission_bool.add(await Permission.notification.status == PermissionStatus.granted);
    await permission_bool.add(await Permission.storage.status == PermissionStatus.granted);
    if(permission_bool.contains(false)) {
      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Permission_Titleforasking] +
          Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Permission_askforStorage] + '\n' +
          //Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Permission_askforNotification] +
          Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Permission_Endingforasking] ;
      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            CustomDialog_Confirm(
              dialog_type: dialog_Status.Warning,
              description: dialog_Msg,
              callback_Confirm: () =>
              {
                _permission_SendRequest(),
                Navigator.of(context).pop()
              },
            ),
      );
    }
    setState(() {

    });
  }

  Future<void> _permission_SendRequest() async{
    Map<Permission, PermissionStatus> statuses = await [
      //Permission.notification,
      Permission.storage,
    ].request();
    if(//statuses[Permission.notification] == PermissionStatus.permanentlyDenied ||
        statuses[Permission.storage] == PermissionStatus.permanentlyDenied){
      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Permission_isPermanentlyDenied];
      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            CustomDialog_Confirm(
              dialog_type: dialog_Status.Error,
              description: dialog_Msg,
              buttonText: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.GoToApplicationSetting],
              callback_Confirm: () =>
              {
                Navigator.of(context).pop(),
                openAppSettings(),
                SystemChannels.platform.invokeMethod('SystemNavigator.pop')
              },
            ),
      );
    }
    await _permissionChecker();
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    if(permission_bool.isNotEmpty && !permission_bool.contains(false)){
      // If all required permissions are allowed.
      return new WillPopScope(
          onWillPop: () async => showDialog<bool>(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) => CustomDialog_Selection(
              dialog_type: dialog_Status.Warning,
              description: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.ExitAppWarningText],
              callback_Confirm: () => {
                SystemChannels.platform.invokeMethod('SystemNavigator.pop')
              },
            ),
          ),
          child: Scaffold(
            body: VerifyPage(), // VerifyPage can be convert to MainPage for skipping the Version Verification Process
            resizeToAvoidBottomInset: false,
          )
      );
    } else {
      // If any of the required permissions are not allowed.
      return new WillPopScope(
          onWillPop: () async => showDialog<bool>(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) => CustomDialog_Selection(
              dialog_type: dialog_Status.Warning,
              description: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.ExitAppWarningText],
              callback_Confirm: () => {
                SystemChannels.platform.invokeMethod('SystemNavigator.pop')
              },
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  child: CircularProgressIndicator(),
                  width: 100,
                  height: 100,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.loadingText],
                      style: TextStyle(fontSize: globals.fontSize_Big)),
                )
              ],
            ),
          )
      );
    }
  }
}

/*
VerifyPage
Execute the Version Verification Process by compare the AppCode and AppVersion between Server and Client.
*/
class VerifyPage extends StatefulWidget {
  @override
  _VerifyPageState createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "", dialog_Msg_Title = "", dialog_confirmText = "";
  Image dialog_image;
  bool isVerifying = true, hasError = false;

  Future AppVerifyProcess() async {
    isVerifying = true;
    if(globals.isVerified){
      return;
    }

    String platform_str = "";
    if(Platform.isAndroid){
      platform_str = "Android";
    } else if(Platform.isIOS){
      platform_str = "iOS";
    }
    
    var Application_Verifier_Data = {
      "AppCode": Application_Identifier_Code, "Version": Application_Version,
      "System": platform_str};
    print(Application_Verifier_Data);
    try {
      // Call Web API and try to get a result from Server
      var response_code = await http.post(
          Verifier_URL, body: json.encode(Application_Verifier_Data)).timeout(Duration(seconds: Connection_Timeout_TimeLimit));

      // Getting Server response into variable.
      Map<String, dynamic> response_code_JSON = jsonDecode(response_code.body);

      if(response_code.statusCode == 200) {
        debugPrint(response_code.body);
        if(response_code_JSON['Verifier_StatusCode'].contains(1000)){
          _dialogStatus = dialog_Status.Success;
          globals.isVerified = true;
        } else {
          _dialogStatus = dialog_Status.Error;
          globals.isVerified = false;
          if(response_code_JSON['Verifier_StatusCode'].contains(9998)){
            dialog_Msg = (Theme.of(context).platform == TargetPlatform.android) ?
            Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Verifier_Error_IncorrectAppCode_Android] :
            Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Verifier_Error_IncorrectAppCode_IOS];
            dialog_confirmText = (Theme.of(context).platform == TargetPlatform.android) ?
            Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.GoToAppStore_Android] :
            Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.GoToAppStore_IOS];
          }
          if(response_code_JSON['Verifier_StatusCode'].contains(9999)){
            dialog_Msg = (Theme.of(context).platform == TargetPlatform.android) ?
            Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Verifier_Error_IncorrectAppVersion_Android] :
            Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Verifier_Error_IncorrectAppVersion_IOS];
            dialog_confirmText = (Theme.of(context).platform == TargetPlatform.android) ?
            Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.GoToAppStore_Android] :
            Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.GoToAppStore_IOS];
          }
        }
      }
    } on TimeoutException catch (e) {
      hasError = true;
      globals.isVerified = false;
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
      dialog_confirmText = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Retry];
    } on Error catch(_) {
      hasError = true;
      globals.isVerified = false;
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error];
      dialog_confirmText = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Retry];
    } on SocketException catch(_){
      hasError = true;
      globals.isVerified = false;
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error];
      dialog_confirmText = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Retry];
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

    if(!globals.isVerified) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => CustomDialog_Selection(
          dialog_type: _dialogStatus,
          description: dialog_Msg,
          buttonText_Confirm: dialog_confirmText,
          buttonText_Cancel: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Exit],
          callback_Cancel: () => {
            if(Theme.of(context).platform == TargetPlatform.android){
              SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
            }
            else if(Theme.of(context).platform == TargetPlatform.iOS){
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) => CustomDialog_Confirm(
                  dialog_type: dialog_Status.Warning,
                  description: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Exit_iOS_Warning],
                )
              )
            }
          },
          callback_Confirm: () => {
            if(!hasError)
              StoreRedirect.redirect(androidAppId: "com.dsgshk.eduhk.smeresapp", iOSAppId: "1565682266")
            else if(hasError){
              RestartWidget.restartApp(context),
            }
            //
          },
        ),
      );
    }
    isVerifying = false;
    setState(() {
      globals.PageIndex = 1;
    });
  }

  @override
  void initState() {
    super.initState();
    AppVerifyProcess();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children;
    if (globals.isVerified) {
      return Scaffold(
        body: MainPage(),
        resizeToAvoidBottomInset: false,
      );
    } else {
      children = <Widget>[
        SizedBox(
          child: CircularProgressIndicator(),
          width: 100,
          height: 100,
        ),
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.loadingText],
              style: TextStyle(fontSize: globals.fontSize_Big),),
        )
      ];
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        ),
      );
    }
  }
}

/*
MainPage
A App Main UI Processor for handle the Setting, Main Center Content and Bottom Navigation Bar.
*/

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  @override
  void initState() {
    super.initState();
    globals.firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) =>
              CustomDialog_Confirm(
                dialog_type: dialog_Status.Custom,
                title: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_NotificationManager_Insidetitle],
                image: notification_Icon,
                description: message.containsKey('notification') ? message['notification']['body'] : message.containsKey('aps') ? message['aps']['alert']['body'] : "",
              ),
        );
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        //_navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        //_navigateToItemDetail(message);
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return new WillPopScope(
        onWillPop: () async => showDialog<bool>(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => CustomDialog_Selection(
              dialog_type: dialog_Status.Warning,
              description: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.ExitAppWarningText],
              callback_Confirm: () => {
                SystemChannels.platform.invokeMethod('SystemNavigator.pop')
              },
          ),
        ),
        child:Scaffold(
          body: BottomBarWidget(),
          resizeToAvoidBottomInset: false,
        )
    );
  }
}

/*
RestartWidget
A Public Widget Contains an Application Restart method for whole project.
a function "restartApp" can call from all dart files to restart the app.
*/

class RestartWidget extends StatefulWidget {
  RestartWidget({this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>().restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
