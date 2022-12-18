import 'dart:io';

import 'package:firebase_core/firebase_core.dart';

import '../Helper/ComponentsList.dart';
import 'package:http/http.dart' as http;
import '../Helper/global_setting.dart' as globals;
import 'package:encrypt/encrypt.dart' as encryption;
import 'package:smeapp/Helper/Localizations.dart';


class LoginPage extends StatefulWidget{
  LoginPage_State createState() => LoginPage_State();
}

class LoginPage_State extends State {
  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "", dialog_Msg_Title = "";
  Image dialog_image;

  // Boolean variable for Login Form.
  bool visible_LoginForm = true;
  bool isautoLogin = false;
  bool isunvalidemail = false;

  final _loginIdController = TextEditingController();
  final _loginPwController = TextEditingController();

  final _forgetPW_UserNameController = TextEditingController();
  final _forgetPW_EmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => autoFillInLoginForm());
  }

  Future loginProcess() async {
    setState(() {
      visible_LoginForm = false;
      globals.visible_Loading = true;
    });

    globals.state_BottomBar.setState(() {

    });

    // Getting value from Controller
    String username = _loginIdController.text;
    String password = _loginPwController.text;
    isunvalidemail = false;
    if(username.isNotEmpty && password.isNotEmpty){
      var login_data = {
        'UserName': username, 'PW': password};

      setState(() {
        _loginPwController.text = "";
      });

      try {
        // Call Web API and try to get a result from Server
        var response_code = await http.post(
            Login_URL, body: json.encode(login_data)).timeout(Duration(seconds: Connection_Timeout_TimeLimit));

        // Getting Server response into variable.
        Map<String, dynamic> response_code_JSON = jsonDecode(response_code.body);

        //debugPrint(response_code.statusCode.toString());

        // If Web call Success than Hide the CircularProgressIndicator.
        if(response_code.statusCode == 200) {

          // There are no any error in login procedure.
          //debugPrint(response_code.body);
          if(response_code_JSON['StatusCode'].contains(1000)){
            dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Login_Success];
            _dialogStatus = dialog_Status.Success;
            globals.isLoggedIn = true;
            globals.state_BottomBar.setState(() {

            });
            SharedPreferences prefs = await SharedPreferences.getInstance();
            globals.UserData_UID = response_code_JSON['UID'];
            prefs.setString(Pref_Profiles_UID, globals.UserData_UID);
            prefs.setString(Pref_Profiles_Nickname, "");
            prefs.setString(Pref_Profiles_Firstname, "");
            prefs.setString(Pref_Profiles_Lastname, "");
            prefs.setString(Pref_Profiles_Email, "");
            prefs.setString(Pref_Profiles_Gender, "");
            globals.UserData_regisCode = response_code_JSON['RegisCode'];
            globals.UserData_username = response_code_JSON['Username'];
            prefs.setString(Pref_User_RegisCode, globals.UserData_regisCode);
            prefs.setBool(Pref_SaveAccount, isautoLogin);
            prefs.setInt(Pref_AutoLogin, 1);
            //print("[UserData]\nUsername: " + globals.UserData_username +"\nUID: " + globals.UserData_UID);


            globals.isAdmin = response_code_JSON['IsAdmin'];
            globals.canRead = response_code_JSON['CanRead'];
            globals.canUpload = response_code_JSON['CanUpload'];
            globals.canViewData = response_code_JSON['CanViewData'];
            globals.canModify = response_code_JSON['CanModify'];
            globals.userGroup = response_code_JSON['UserGroup'];
            globals.userToken = response_code_JSON['JWT_Token'];
            globals.userSubGroup = List.from(response_code_JSON['UserSubGroup']);

            if(prefs.getInt(Pref_NotificationPermission) == 1){
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
            }

            if(!prefs.getBool(Pref_SaveAccount)) {
              prefs.setString(Pref_User_SaltedPassword, "");
              prefs.setString(Pref_User_UserName, "");
            }
            else {
              final iv = encryption.IV.fromUtf8(response_code_JSON['RegisCode']);
              final SaltedPassword = encryption_Tools.encrypt(password, iv: iv);
              prefs.setString(Pref_User_SaltedPassword, SaltedPassword.base64);
              prefs.setString(Pref_User_UserName, username);
            }
            globals.PageIndex = 1;

          } else {
            _dialogStatus = dialog_Status.Error;
            dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Login_Error_TopLine];
            if(response_code_JSON['StatusCode'].contains(1001)){
              dialog_Msg += Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Login_Error_IncorrectPassword];
            }
            if(response_code_JSON['StatusCode'].contains(1002)){
              dialog_Msg += Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Login_Error_IncorrectUserName];
            }
            if(response_code_JSON['StatusCode'].contains(1003)){
              isunvalidemail = true;
              dialog_Msg += Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Login_Error_Unverified_Email];
            }
            globals.PageIndex = 1;
          }
          setState(() {
            visible_LoginForm = true;
            globals.visible_Loading = false;
          });
        } else {
          _dialogStatus = dialog_Status.Error;
          dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error] + "(" + response_code.statusCode + ")";
          setState(() {
            visible_LoginForm = true;
            globals.visible_Loading = false;
          });
        }
      } on TimeoutException catch (e) {
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
        setState(() {
          visible_LoginForm = true;
          globals.visible_Loading = false;
        });
      } on Error catch(_) {
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error];
        setState(() {
          visible_LoginForm = true;
          globals.visible_Loading = false;
        });
      } on SocketException catch(_){
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error];
        setState(() {
          visible_LoginForm = true;
          globals.visible_Loading = false;
        });
      } on FormatException catch(_) {
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error_FormatException];
        setState(() {
          visible_LoginForm = true;
          globals.visible_Loading = false;
        });
      }

    } else {
      _dialogStatus = dialog_Status.Error;
      // Not fill all fields
      setState(() {
        visible_LoginForm = true;
        globals.visible_Loading = false;
      });
      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Login_Error_NotFillAll_TopLine];
      if(username.isEmpty){
        dialog_Msg += Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.loginIdHintText]+"\n";
      }
      if(password.isEmpty){
        dialog_Msg += Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.loginPwHintText]+"\n";
      }
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

    if(isunvalidemail){
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
          CustomDialog_Selection(
            dialog_type: _dialogStatus,
            description: dialog_Msg,
            buttonText_Confirm: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.ResendValidationEmailButtonTitle],
            callback_Confirm: () async => {
              if(await sendValidationRequest(context, username)){
                _dialogStatus = dialog_Status.Success,
                dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.ResendValidationEmail_Success],
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) => CustomDialog_Confirm(
                    dialog_type: _dialogStatus,
                    description: dialog_Msg,
                    callback_Confirm: () => {
                      Navigator.of(context)
                          .pushAndRemoveUntil(
                          globals.gotoPage(MainPage(), Duration(seconds: 0, milliseconds: 0)), (
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
    } else {
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

    globals.state_BottomBar.setState(() {
      globals.visible_Loading = false;
    });
    await loadingProfile();
  }

  Future loadingProfile() async{
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
  }

  Future autoFillInLoginForm () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool pref_isSaveAccount = prefs.getBool(Pref_SaveAccount) ?? false;

    if(pref_isSaveAccount) {
      String SaltedPassword = prefs.getString(Pref_User_SaltedPassword) ?? "";
      String UserRegisCode = prefs.getString(Pref_User_RegisCode) ?? "";
      final iv = encryption.IV.fromUtf8(UserRegisCode);
      // Getting value from Controller
      _loginIdController.text = prefs.getString(Pref_User_UserName) ?? "";
      if(SaltedPassword != "") {
        _loginPwController.text =
            encryption_Tools.decrypt64(SaltedPassword, iv: iv) ?? "";
      } else {
        _loginPwController.text = "";
      }
      setState(() {
        isautoLogin = true;
      });
      int auto_login = prefs.getInt(Pref_AutoLogin);
      if(auto_login == 1){
        loginProcess();
      }
    } else {
      return;
    }
  }

  /*
  Future autoLogin() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool pref_isAutoLogin = prefs.getBool(Pref_AutoLogin) ?? false;
    if(pref_isAutoLogin) {
      String SaltedPassword = prefs.getString(Pref_User_SaltedPassword) ?? "";
      String UserRegisCode = prefs.getString(Pref_User_RegisCode) ?? "";
      print(SaltedPassword);
      print(UserRegisCode);
      final iv = encryption.IV.fromUtf8(UserRegisCode);
      // Getting value from Controller
      _loginIdController.text = prefs.getString(Pref_User_UserName) ?? "";
      _loginPwController.text =
          encryption_Tools.decrypt64(SaltedPassword, iv: iv) ?? "";
      isautoLogin = true;
      loginProcess();
    } else {
      return;
    }
  }
  */

  @override
  Widget build(BuildContext context) {
    var screen_size = MediaQuery.of(context).size;
    // Logo
    final logo = CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: globals.screen_size.width / 10,
      child: appLogo,
    );

    // region UI - Field Labels
    final label_loginID = Padding(
      padding: EdgeInsets.only(left: 20,right: 0),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.loginIdHintText],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: appPrimaryColor,
            fontSize: globals.fontSize_Middle),
      ),
    );
    final label_loginPW = Padding(
      padding: EdgeInsets.only(left: 20,right: 0),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.loginPwHintText],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: appPrimaryColor,
            fontSize: globals.fontSize_Middle),
      ),
    );
    final label_ResetPWDesc = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.SendResetPWRequest_Desc],
        textAlign: TextAlign.left,
        //overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black54,
            fontSize: globals.fontSize_Middle),
      ),
    );
    final label_ResetPW_ID = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: AutoSizeText(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.loginIdHintText],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black54,
            fontSize: globals.fontSize_Middle),
      ),
    );
    final label_ResetPW_Email = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: AutoSizeText(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.EmailHintText],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black54,
            fontSize: globals.fontSize_Middle),
      ),
    );
    // endregion


    // region UI - Form Input Fields
    final loginIDTextfield_new = InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black54)
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                textAlign: TextAlign.right,
                controller: _loginIdController,
                keyboardType: TextInputType.text,
                maxLength: 32,
                maxLines: 1,
                style: TextStyle(
                  color: appPrimaryColor,
                  fontSize: globals.fontSize_Normal,
                ),
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
                        flex: 8,
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Container(
                                padding: const EdgeInsets.only(right: 10),
                                alignment: Alignment.centerRight,
                                child: Text("")
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0,15,0,0),
                    counterText: "",
                    prefixIcon: label_loginID,
                    prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.input),
                    )
                ),
              ),
            )
          ],
        ) ,
      ),
    );
    final loginPWTextfield_new = InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black54)
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                textAlign: TextAlign.right,
                controller: _loginPwController,
                keyboardType: TextInputType.text,
                maxLength: 32,
                maxLines: 1,
                obscureText: true,
                style: TextStyle(
                  color: appPrimaryColor,
                  fontSize: globals.fontSize_Normal,
                ),
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
                        flex: 8,
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Container(
                                padding: const EdgeInsets.only(right: 10),
                                alignment: Alignment.centerRight,
                                child: Text("")
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0,15,0,0),
                    counterText: "",
                    prefixIcon:label_loginPW,
                    prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.input),
                    )
                ),
              ),
            )
          ],
        ) ,
      ),
    );
    final password_change_dialog = Container(
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
                        child: label_ResetPWDesc,
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
                      controller: _forgetPW_UserNameController,
                      keyboardType: TextInputType.multiline,
                      maxLength: 256,
                      maxLines: 1,
                      style: TextStyle(
                        color: appPrimaryColor,
                        fontSize: globals.fontSize_Normal,
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
                          prefixIcon: label_ResetPW_ID,
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
                      controller: _forgetPW_EmailController,
                      keyboardType: TextInputType.multiline,
                      maxLength: 256,
                      maxLines: 1,
                      style: TextStyle(
                        color: appPrimaryColor,
                        fontSize: globals.fontSize_Normal,
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
                          prefixIcon: label_ResetPW_Email,
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
    // endregion

    // Login Button
    final loginButton = Card(
      child: ListTile(
        leading: Icon(Icons.login, size: 40, color: Colors.white,),
        tileColor: Colors.blueAccent,
        title: Padding(
          padding: EdgeInsets.only(top: 0, bottom: 0),
          child: AutoSizeText(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.loginButtonText],
            style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: globals.fontSize_Middle),
            textAlign: TextAlign.right),
        ),
        isThreeLine: false,
        onTap: () async =>  {
          loginProcess()
        },
      ),
    );

    final forgetPWButton = Card(
      child: ListTile(
        leading: Image.asset('assets/images/forgot_password.png', width: 40, height: 40, color: Colors.white,),
        tileColor: Colors.deepOrangeAccent,
        title: Padding(
          padding: EdgeInsets.only(top: 0, bottom: 0),
          child: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.SendResetPWRequest_BtnTitle],
            style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: globals.fontSize_Middle), textAlign: TextAlign.right),
        ),
        isThreeLine: false,
        onTap: () async =>  {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) => CustomDialog_Selection(
              dialog_type: dialog_Status.Custom,
              title: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.SendResetPWRequest_Title],
              desc_to_widget: true,
              desc_widget: password_change_dialog,
              image: changePw_Icon,
              callback_Confirm: () async => {
                if(!(_forgetPW_UserNameController.text.isEmpty && _forgetPW_EmailController.text.isEmpty)){
                  if(await sendResetPWRequest(context, _forgetPW_UserNameController.text, _forgetPW_EmailController.text)){
                    _dialogStatus = dialog_Status.Success,
                    dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.SendResetPWRequest_Success],
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) => CustomDialog_Confirm(
                        dialog_type: _dialogStatus,
                        description: dialog_Msg,
                        callback_Confirm: () => {
                            Navigator.of(context)
                                .pushAndRemoveUntil(
                            globals.gotoPage(MainPage(), Duration(seconds: 0, milliseconds: 0)), (
                            Route<dynamic> route) => false),
                        },
                      ),
                    )
                  },
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
            )
          )

        },
      ),
    );

    final login_autologin_Checkbox = Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Container(
        child: CheckboxListTile(
          title: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.loginRememberAccountText],
          style: TextStyle(fontSize: globals.fontSize_Big),),
          value: isautoLogin,
          onChanged: (newValue){
            setState(() {
              isautoLogin = newValue;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ),
    );

    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: appBGColor,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: appTitleBarColor,
          title: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.loginButtonText],
            style: TextStyle(fontSize: globals.fontSize_Title),),
        ),
        body: Center(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(left: 24.0, right: 24.0),
            children: <Widget>[
              Visibility(
                visible: visible_LoginForm,
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Padding(padding: EdgeInsets.only(top: 12, bottom: 12),),
                      logo,
                      Padding(padding: EdgeInsets.only(top: 12, bottom: 12),),
                      loginIDTextfield_new,
                      Padding(padding: EdgeInsets.only(top: 12, bottom: 12),),
                      loginPWTextfield_new,
                      Padding(padding: EdgeInsets.only(top: 12, bottom: 6),),
                      login_autologin_Checkbox,
                      Padding(padding: EdgeInsets.only(top: 6, bottom: 12),),
                      loginButton,
                      Padding(padding: EdgeInsets.only(top: 12, bottom: 12),),
                      forgetPWButton
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }
}
