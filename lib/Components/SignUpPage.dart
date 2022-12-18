import 'dart:io';

import '../Helper/ComponentsList.dart';
import 'package:http/http.dart' as http;
import '../Helper/global_setting.dart' as globals;
import 'package:smeapp/Helper/Localizations.dart';
import 'package:select_dialog/select_dialog.dart';

import 'Survey/WebBrowser.dart';


class SignUpPage extends StatefulWidget {
  SignUpPage_State createState() => SignUpPage_State();
}

class SignUpPage_State extends State {

  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "", dialog_Msg_Title = "";
  Image dialog_image;

  // Boolean variable for SignUp Form.
  bool visible_RegisterForm = true;
  List<String> Current_GenderList;
  int isUserPolicyAccepted = 0;
  int isPrivacyPolicyAccepted = 0;
  bool allvalid = false;
  bool accountexists = false;

  String current_gender = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Text_male];

  final _newIdController = TextEditingController();
  final _newPwController = TextEditingController();
  final _newEmailController = TextEditingController();
  final _newFirstNameController = TextEditingController();
  final _newLastNameController = TextEditingController();
  final _newNickNameController = TextEditingController();
  final _newGenderController = TextEditingController();
  final _newInvitationCodeController = TextEditingController();
  final _textfieldFocusNode = new FocusNode();

  final regex_all = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[a-zA-Z])(?=.*[*!@#&]).{9,}$');
  final regex_Upper = RegExp(r'^(?=.*[A-Z])(?=.*[a-zA-Z]).{1,}$');
  final regex_Lower = RegExp(r'^(?=.*[a-z])(?=.*[a-zA-Z]).{1,}$');
  final regex_SpecChar = RegExp(r'^(?=.*[*!@#&]).{1,}$');
  final regex_length = RegExp(r'^.{9,}$');
  final regex_email = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  Future<bool> _registrationSubmit(BuildContext context) async {
    String gender_To_Server;

    // Getting value from Controller
    String username = _newIdController.text;
    String email = _newEmailController.text;
    String password = _newPwController.text;
    String firstname = _newFirstNameController.text;
    String lastname = _newLastNameController.text;
    String nickname = _newNickNameController.text;
    String gender = _newGenderController.text;
    String inivationcode = _newInvitationCodeController.text;

    // Convert the Gender to The Server Side Format.
    if(gender == Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Text_male]){
      gender_To_Server = "M";
    } else if (gender == Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Text_Female]){
      gender_To_Server = "F";
    } else {
      gender_To_Server = "O";
    }

    var register_data = {
      'UserName': username, 'EMAIL': email, 'PW': password,
      'FirstName': firstname, 'LastName': lastname,
      'Nickname': nickname, 'Gender': gender_To_Server,
      'INVCODE': inivationcode};
    // Call Web API and try to get a result from Server
    try {
      var response_code = await http.post(
          Register_URL, body: json.encode(register_data)).timeout(Duration(seconds: Connection_Timeout_TimeLimit));

      // Getting Server response into variable.
      Map<String, dynamic> response_code_JSON = jsonDecode(response_code.body);

      // If Web call Success than Hide the CircularProgressIndicator.
      if(response_code.statusCode == 200) {
        print(response_code_JSON);
        // There are no any error in registration procedure.
        if(response_code_JSON['StatusCode'].contains(1003)){
          _dialogStatus = dialog_Status.Error;
          dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Register_Error_IPLimited];
          return false;
        }
        else if(response_code_JSON['StatusCode'].contains(1000)){
          if(await sendValidationRequest(context, username)){
            Navigator.of(context).pop();
            _dialogStatus = dialog_Status.Success;
            dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Register_Success];
            return true;
          }
        } else {
          _dialogStatus = dialog_Status.Error;
          dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Register_Error_TopLine];
          if(response_code_JSON['StatusCode'].contains(1001)){
            dialog_Msg += Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Register_Error_EmailExists];
          }
          if(response_code_JSON['StatusCode'].contains(1002)){
            dialog_Msg += Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Register_Error_UserExists];
          }
          if(response_code_JSON['StatusCode'].contains(1004)){
            dialog_Msg += Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Register_Error_INVCodeLimited];
          }
          if(response_code_JSON['StatusCode'].contains(1005)){
            dialog_Msg += Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Register_Error_INVCodeError];
          }
          return false;
        }
      } else {
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error];
        return false;
      }
    } on TimeoutException catch (e) {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
      return false;
    } on Error catch(_) {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error];
      return false;
    }
    on SocketException catch(_){
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error];
      return false;
    } on FormatException catch(_) {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error_FormatException];
      return false;
    }
  }

  Future registrationProcess() async {
    FocusScope.of(context).unfocus();
    setState(() {
      allvalid = false;
      visible_RegisterForm = false;
      globals.visible_Loading = true;
    });

    globals.state_BottomBar.setState(() {

    });

    // Getting value from Controller
    String username = _newIdController.text;
    String email = _newEmailController.text;
    String password = _newPwController.text;
    String firstname = _newFirstNameController.text;
    String lastname = _newLastNameController.text;
    String nickname = _newNickNameController.text;
    String gender = _newGenderController.text;
    String inivationcode = _newInvitationCodeController.text;

    if(username.isNotEmpty && email.isNotEmpty && password.isNotEmpty && firstname.isNotEmpty &&
       lastname.isNotEmpty && nickname.isNotEmpty && gender.isNotEmpty && inivationcode.isNotEmpty && isUserPolicyAccepted == 1 && isPrivacyPolicyAccepted == 1) {
        if(_newPwController.text.contains(regex_all)){
          if(_newEmailController.text.contains(regex_email)){
            allvalid = true;
            showDialog(
              context: context,
              builder: (BuildContext context) =>
                  CustomDialog_Selection(
                    dialog_type: dialog_Status.Warning,
                    title: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Signup_Confirmation_Title],
                    description: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Signup_Confirmation_Desc] + _newEmailController.text,
                    buttonText_Confirm: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Signup_Confirmation_Confirm],
                    buttonText_Cancel: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Signup_Confirmation_Cancel],
                    callback_Confirm: () async
                    {
                      if(await _registrationSubmit(context)){
                        print("Return True");
                        setState(() {
                          visible_RegisterForm = true;
                          globals.visible_Loading = false;
                        });
                        globals.state_BottomBar.setState(() {
                          globals.PageIndex = 1;
                        });
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) => CustomDialog_Confirm(
                            dialog_type: _dialogStatus,
                            description: dialog_Msg,
                          ),
                        );
                      } else {
                        print("Return False");
                        setState(() {
                          visible_RegisterForm = true;
                          globals.visible_Loading = false;
                        });
                        Navigator.of(context).pop();
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) => CustomDialog_Confirm(
                            dialog_type: _dialogStatus,
                            description: dialog_Msg,
                          ),
                        );
                      }
                    },
                    callback_Cancel: () => {
                      Navigator.of(context).pop(),
                    },
                  ),
            );
          } else {
            _dialogStatus = dialog_Status.Warning;
            dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_ChangeDefaultEmail_FormatError];
          }
        } else {
          _dialogStatus = dialog_Status.Warning;
          dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_ChangePassword_Condition_Check_TopMsg] + '\n';
          if(!_newPwController.text.contains(regex_length)){
          dialog_Msg += Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_ChangePassword_Condition_Length] + '\n';
          }
          if(!_newPwController.text.contains(regex_Upper)){
          dialog_Msg += Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_ChangePassword_Condition_ContainUpper] + '\n';
          }
          if(!_newPwController.text.contains(regex_Lower)){
          dialog_Msg += Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_ChangePassword_Condition_ContainLower] + '\n';
          }
          if(!_newPwController.text.contains(regex_SpecChar)){
          dialog_Msg += Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_ChangePassword_Condition_SpecialCharacter] + '\n';
          }
        }
      } else {
      _dialogStatus = dialog_Status.Error;
      // Not fill all fields
      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Register_Error_NotFillAll_TopLine];
      if(firstname.isEmpty){
        dialog_Msg += Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.FirstNameHintText]+"\n";
      }
      if(lastname.isEmpty){
        dialog_Msg += Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.LastNameHintText]+"\n";
      }
      if(nickname.isEmpty){
        dialog_Msg += Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.NickNameHintText]+"\n";
      }
      if(email.isEmpty){
        dialog_Msg += Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.EmailHintText]+"\n";
      }
      if(gender.isEmpty){
        dialog_Msg += Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.GenderHintText]+"\n";
      }
      if(username.isEmpty){
        dialog_Msg += Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.loginIdHintText]+"\n";
      }
      if(password.isEmpty){
        dialog_Msg += Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.loginPwHintText]+"\n";
      }
      if(inivationcode.isEmpty){
        dialog_Msg += Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.InvitationHintText]+"\n";
      }
      if(isPrivacyPolicyAccepted != 1 || isUserPolicyAccepted != 1){
        dialog_Msg += Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.UnAcceptedPolicyText]+"\n";
      }
    }

    switch(_dialogStatus){
      case dialog_Status.Success:
        dialog_Msg_Title = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Tips_Success];
        dialog_image = tips_success_Icon;
        break;
      case dialog_Status.Warning:
        dialog_Msg_Title = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Tips_Warning];
        dialog_image = tips_warning_Icon;
        break;
      case dialog_Status.Error:
        dialog_Msg_Title = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Tips_Error];
        dialog_image = tips_error_Icon;
        break;
    }

    if(_dialogStatus != dialog_Status.Success){
      setState(() {
        visible_RegisterForm = true;
        globals.visible_Loading = false;
      });
    }

    if(!allvalid){
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => CustomDialog_Confirm(
          dialog_type: _dialogStatus,
          description: dialog_Msg,
        ),
      );
    }

    globals.state_BottomBar.setState(() {

    });

}
  @override
  Widget build(BuildContext context) {

    if(globals.CurrentLang == Localizations_Language_Identifier.Language_TC){
      Current_GenderList = GenderList_TC;
    } else if(globals.CurrentLang == Localizations_Language_Identifier.Language_Eng){
      Current_GenderList = GenderList;
    }

    // region UI - Field Labels
    final Label_Profilesdata = Text(
      Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Register_ProfilesLabelText],
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: globals.fontSize_SubTitle,
          color: appPrimaryColor),
    );

    final Label_AccountData = Text(
      Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.AccountLabelText],
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: globals.fontSize_SubTitle,
          color: appPrimaryColor),
    );

    final label_GenderSelection = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.GenderHintText],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Middle,
            color: appPrimaryColor),
      ),
    );

    final label_firstName = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.FirstNameHintText],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Middle,
            color: appPrimaryColor),
      ),
    );

    final label_lastName = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.LastNameHintText],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Middle,
            color: appPrimaryColor),
      ),
    );

    final label_nickName = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.NickNameHintText],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Middle,
            color: appPrimaryColor),
      ),
    );

    final label_email = Padding(
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

    final label_loginId = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.loginIdHintText],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Middle,
            color: appPrimaryColor),
      ),
    );

    final label_loginPw = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
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

    final label_invitationCode = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.InvitationHintText],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Middle,
            color: appPrimaryColor),
      ),
    );
    final label_acceptUserPolicy = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.AcceptUserPolicyHintText],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Middle,
            color: appPrimaryColor),
      ),
    );
    final label_acceptPrivacyPolicy = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.AcceptPrivacyPolicyHintText],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Middle,
            color: appPrimaryColor),
      ),
    );
    // endregion


    // region UI - Form Input Fields
    final firstnameTextfield_new = InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black54)
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                textAlign: TextAlign.right,
                controller: _newFirstNameController,
                keyboardType: TextInputType.text,
                maxLength: 16,
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
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Container(
                                padding: const EdgeInsets.only(right: 10),
                                alignment: Alignment.centerRight,
                                child: Text(currentLength.toString() + "/" + maxLength.toString(), style: TextStyle(fontSize: globals.fontSize_Small),)
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0,15,0,0),
                    prefixIcon: label_firstName,
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
    final lastnameTextfield_new = InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black54)
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                textAlign: TextAlign.right,
                controller: _newLastNameController,
                keyboardType: TextInputType.text,
                maxLength: 16,
                maxLines: 1,
                style: TextStyle(
                  color: appPrimaryColor,
                    fontSize: globals.fontSize_Normal
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
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Container(
                                padding: const EdgeInsets.only(right: 10),
                                alignment: Alignment.centerRight,
                                child: Text(currentLength.toString() + "/" + maxLength.toString(), style: TextStyle(fontSize: globals.fontSize_Small),)
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0,15,0,0),
                    prefixIcon: label_lastName,
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
    final nicknameTextfield_new = InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black54)
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                textAlign: TextAlign.right,
                controller: _newNickNameController,
                keyboardType: TextInputType.text,
                maxLength: 32,
                maxLines: 1,
                style: TextStyle(
                  color: appPrimaryColor,
                  fontSize: globals.fontSize_Normal
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
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Container(
                                padding: const EdgeInsets.only(right: 10),
                                alignment: Alignment.centerRight,
                                child: Text(currentLength.toString() + "/" + maxLength.toString(), style: TextStyle(fontSize: globals.fontSize_Small),)
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0,15,0,0),
                    prefixIcon: label_nickName,
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
    final emailTextfield_new = InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black54)
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                textAlign: TextAlign.right,
                controller: _newEmailController,
                keyboardType: TextInputType.emailAddress,
                maxLength: 64,
                maxLines: 1,
                style: TextStyle(
                  color: appPrimaryColor,
                    fontSize: globals.fontSize_Normal
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
                                child: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Signup_EmailManual],
                                  style: TextStyle(fontSize: globals.fontSize_Small,color: Colors.black54),)
                            )
                          ],
                        ),
                        flex: 10,
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: <Widget>[
                            Container(
                                padding: const EdgeInsets.only(right: 10),
                                alignment: Alignment.centerRight,
                                child: Text(currentLength.toString() + "/" + maxLength.toString(), style: TextStyle(fontSize: globals.fontSize_Small),)
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0,15,0,0),
                    prefixIcon: label_email,
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
                controller: _newIdController,
                keyboardType: TextInputType.text,
                maxLength: 32,
                maxLines: 1,
                style: TextStyle(
                  color: appPrimaryColor,
                    fontSize: globals.fontSize_Normal
                ),
                buildCounter: (_, {currentLength, maxLength, isFocused}) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Container(
                                padding: const EdgeInsets.only(left: 24),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Signup_IDManual],
                                style: TextStyle(fontSize: globals.fontSize_Small,color: Colors.black54),)
                            )
                          ],
                        ),
                        flex: 7,
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: <Widget>[
                            Container(
                                padding: const EdgeInsets.only(right: 10),
                                alignment: Alignment.centerRight,
                                child: Text(currentLength.toString() + "/" + maxLength.toString(), style: TextStyle(fontSize: globals.fontSize_Small),)
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0,15,0,0),
                    prefixIcon: label_loginId,
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
                controller: _newPwController,
                keyboardType: TextInputType.text,
                maxLength: 32,
                maxLines: 1,
                obscureText: true,
                style: TextStyle(
                  color: appPrimaryColor,
                    fontSize: globals.fontSize_Normal
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
                                child: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Signup_PWManual],
                                  style: TextStyle(fontSize: globals.fontSize_Small,color: Colors.black54),)
                            )
                          ],
                        ),
                        flex: 10,
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: <Widget>[
                            Container(
                                padding: const EdgeInsets.only(right: 10),
                                alignment: Alignment.centerRight,
                                child: Text(currentLength.toString() + "/" + maxLength.toString(), style: TextStyle(fontSize: globals.fontSize_Small),)
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0,15,0,0),
                    prefixIcon:label_loginPw,
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
    final genderSelection_new = InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black54)
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                onTap: () => {
                  FocusScope.of(context).unfocus(),
                  SelectDialog.showModal<String>(
                    context,
                    label: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.GenderHintText],
                    selectedValue: current_gender,
                    items: Current_GenderList,
                    showSearchBox: false,
                    onChange: (String selected) => {
                      setState(() {
                        current_gender = selected;
                        _newGenderController.text = current_gender;
                      }),
                    },
                  )
                },
                enableInteractiveSelection: false,
                textAlign: TextAlign.right,
                controller: _newGenderController,
                readOnly: true,
                keyboardType: TextInputType.text,
                maxLength: 8,
                maxLines: 1,
                style: TextStyle(
                  color: appPrimaryColor,
                    fontSize: globals.fontSize_Normal
                ),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0,15,0,0),
                    prefixIcon: label_GenderSelection,
                    prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                    counterText: "",
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.arrow_right),
                    )
                ),
              ),
            )
          ],
        ) ,
      ),
    );
    final invitationCodeTextfield_new = InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black54)
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                textAlign: TextAlign.right,
                controller: _newInvitationCodeController,
                keyboardType: TextInputType.text,
                maxLength: 32,
                maxLines: 1,
                obscureText: false,
                style: TextStyle(
                  color: appPrimaryColor,
                    fontSize: globals.fontSize_Normal
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
                                child: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Signup_InvitationCodeManual],
                                  style: TextStyle(fontSize: globals.fontSize_Small,color: Colors.black54),)
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
                    prefixIcon:label_invitationCode,
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
    String langcode;
    final acceptUserPolicy_Switch = InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black54)
        ),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    label_acceptUserPolicy
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    children: [
                      Padding(padding: EdgeInsets.only(top:10, bottom: 10, right: 10),
                        child: ToggleSwitch(
                          minWidth: 45.0,
                          minHeight: 35.0,
                          initialLabelIndex: isUserPolicyAccepted,
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
                            FocusScope.of(context).unfocus();
                            if(val == 1){
                              globals.browser_Title = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Signup_UserPolicyTitle];
                              globals.browser_url = UserPolicy_URL;
                              if(globals.CurrentLang.id == Localizations_Language_Identifier.Language_TC.id){
                                langcode = "zh-hk";
                              } else {
                                langcode = "en-gb";
                              }
                              globals.browser_url = globals.browser_url.replaceAll("LangCode", langcode);
                              Navigator.of(context).push(globals.gotoPage(WebBrowser(), Duration(seconds: 0, milliseconds: 500)));
                            }
                            setState(() {
                              isUserPolicyAccepted = val;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top:0, bottom:10, left:20, right:20),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.blueGrey),
                      child: FlatButton.icon(
                          onPressed: () => {
                            FocusScope.of(context).unfocus(),
                            /*
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) => CustomDialog_Confirm(
                                dialog_type: dialog_Status.Custom,
                                title: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Signup_UserPolicyTitle],
                                description: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Signup_PolicyManual],
                                image: Icon(Icons.description),
                                buttonText: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Close],
                              ),
                            )
                            */
                            globals.browser_Title = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Signup_UserPolicyTitle],
                            globals.browser_url = UserPolicy_URL,
                            if(globals.CurrentLang.id == Localizations_Language_Identifier.Language_TC.id){
                              langcode = "zh-hk",
                            } else {
                              langcode = "en-gb",
                            },
                            globals.browser_url = globals.browser_url.replaceAll("LangCode", langcode),
                            Navigator.of(context).push(globals.gotoPage(WebBrowser(), Duration(seconds: 0, milliseconds: 500))),
                          },
                          icon: Icon(Icons.description, color: Colors.white70,),
                          label: Text(
                            Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Signup_UserPolicyTitle],
                            style: TextStyle(color: Colors.white, fontSize: globals.fontSize_Normal),)
                      ),
                    ),
                  ),
                ),
              ],
            ),
      ])),
    );
    final acceptPrivacyPolicy_Switch = InkWell(
      child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black54)
          ),
          child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        label_acceptPrivacyPolicy
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        children: [
                          Padding(padding: EdgeInsets.only(top:10, bottom: 10, right: 10),
                            child: ToggleSwitch(
                              minWidth: 45.0,
                              minHeight: 35.0,
                              initialLabelIndex: isPrivacyPolicyAccepted,
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
                                if(val == 1){
                                  FocusScope.of(context).unfocus();
                                  globals.browser_Title = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Signup_PrivacyPolicyTitle];
                                  globals.browser_url = PrivacyPolicy_URL;
                                  if(globals.CurrentLang.id == Localizations_Language_Identifier.Language_TC.id){
                                      langcode = "zh-hk";
                                    } else {
                                      langcode = "en-gb";
                                    }
                                    globals.browser_url = globals.browser_url.replaceAll("LangCode", langcode);
                                  Navigator.of(context).push(globals.gotoPage(WebBrowser(), Duration(seconds: 0, milliseconds: 500)));
                                }
                                setState(() {
                                  isPrivacyPolicyAccepted = val;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top:0, bottom:10, left:20, right:20),
                        child: Container(
                          decoration: BoxDecoration(color: Colors.blueGrey),
                          child: FlatButton.icon(
                              onPressed: () => {
                                FocusScope.of(context).unfocus(),
                                /*
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) => CustomDialog_Confirm(
                                dialog_type: dialog_Status.Custom,
                                title: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Signup_UserPolicyTitle],
                                description: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Signup_PolicyManual],
                                image: Icon(Icons.description),
                                buttonText: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Close],
                              ),
                            )
                            */
                                globals.browser_Title = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Signup_PrivacyPolicyTitle],
                                globals.browser_url = PrivacyPolicy_URL,
                                if(globals.CurrentLang.id == Localizations_Language_Identifier.Language_TC.id){
                                  langcode = "zh-hk",
                                } else {
                                  langcode = "en-gb",
                                },
                                globals.browser_url = globals.browser_url.replaceAll("LangCode", langcode),
                                Navigator.of(context).push(globals.gotoPage(WebBrowser(), Duration(seconds: 0, milliseconds: 500))),
                              },
                              icon: Icon(Icons.description, color: Colors.white70,),
                              label: Text(
                                Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Signup_PrivacyPolicyTitle],
                                style: TextStyle(color: Colors.white, fontSize: globals.fontSize_Normal),)
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ])),
    );
    // endregion

    // SignUp Button
    final signUpButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: SizedBox(
          width: double.infinity,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          onPressed: () => {
            registrationProcess()
          },
          color: appTitleBarColor,
          child: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.signupButtonText], style: TextStyle(color: appBGColor, fontSize: globals.fontSize_Normal)),
        ),
      )
    );

    return Scaffold(
      backgroundColor: appBGColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: appTitleBarColor,
        title: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.signupButtonText],
        style: TextStyle(fontSize: globals.fontSize_Title),),
      ),
      body: Container(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            Visibility(
              visible: visible_RegisterForm,
              child: Center(
                child: Column(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(top: 18),),
                    Label_Profilesdata,
                    Padding(padding: EdgeInsets.only(top: 12, bottom: 12)),
                    firstnameTextfield_new,
                    Padding(padding: EdgeInsets.only(top: 6, bottom: 6)),
                    lastnameTextfield_new,
                    Padding(padding: EdgeInsets.only(top: 6, bottom: 6)),
                    nicknameTextfield_new,
                    Padding(padding: EdgeInsets.only(top: 6, bottom: 6)),
                    emailTextfield_new,
                    Padding(padding: EdgeInsets.only(top: 6, bottom: 6)),
                    genderSelection_new,
                    Padding(padding: EdgeInsets.only(top: 6, bottom: 6)),
                    Label_AccountData,
                    Padding(padding: EdgeInsets.only(top: 12, bottom: 6)),
                    loginIDTextfield_new,
                    Padding(padding: EdgeInsets.only(top: 6, bottom: 6)),
                    loginPWTextfield_new,
                    Padding(padding: EdgeInsets.only(top: 6, bottom: 6)),
                    invitationCodeTextfield_new,
                    Padding(padding: EdgeInsets.only(top: 6, bottom: 6)),
                    acceptUserPolicy_Switch,
                    Padding(padding: EdgeInsets.only(top: 6, bottom: 6)),
                    acceptPrivacyPolicy_Switch,
                    signUpButton
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