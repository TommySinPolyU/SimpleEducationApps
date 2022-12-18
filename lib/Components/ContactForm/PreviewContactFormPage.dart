import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:smeapp/Components/ContactForm/ContactForm.dart';
import 'package:smeapp/Components/Survey/SurveyEditor.dart';

import '../../main.dart';

import '../../Helper/ComponentsList.dart';
import 'package:http/http.dart' as http;
import '../../Helper/global_setting.dart' as globals;
import 'package:smeapp/Helper/Localizations.dart';

class PreviewContactFormPage extends StatefulWidget {
  PreviewContactFormPage_State createState() => PreviewContactFormPage_State();
}

class PreviewContactFormPage_State extends State {
  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "", dialog_Msg_Title = "";
  Image dialog_image;

  // Boolean variable for CircularProgressIndicator.
  bool visible_Loading = false;
  // Boolean variable for Preview Form.
  bool visible_PreviewForm = true;
  // Boolean variable for Upload Button.
  bool visible_floatButtom = false;

  final _newTitleController = TextEditingController();
  final _newDescController = TextEditingController();
  final _newNameTitleController = TextEditingController();
  final _newReplyEmailController = TextEditingController();
  final _newLastNameController = TextEditingController();

  void _showFloatingButton(){
    setState(() {
      visible_floatButtom = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _showFloatingButton();
  }

  Future<void> _resetandreload() async{
    globals.newEmail_Title = null;
    globals.newEmail_Desc = null;
    globals.newEmail_LastName = null;
    globals.newEmail_NameTitle = null;
    globals.newEmail_ReplyEmail = null;
  }

  Future<void> sendEmail() async{
    var insert_data;

    Future.delayed(Duration.zero, () => {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            CustomDialog_Confirm(
              showButton: false,
              dialog_type: dialog_Status.Loading,
              description: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier
                  .Contact_Form_Sending],
            ),
      )
    });

    try{
      // Call Web API and try to get a result from Server
      var response_code;


      insert_data = {
        'UID': globals.UserData_UID,'UserName': globals.UserData_username,
        'LastName': globals.newEmail_LastName,
        'Title': globals.newEmail_Title, 'Body': globals.newEmail_Desc, 'NameTitle': globals.newEmail_NameTitle, 'ReplyEmail': globals.newEmail_ReplyEmail, 'Language': globals.CurrentLang.id
      };

      response_code = await http.post(
          SendEmailToResearchers_URL, body: json.encode(
          insert_data, toEncodable: globals.dateTimeSerializer), headers: {'Authorization':  'JWT ' + globals.userToken}).timeout(
          Duration(seconds: 15));

      //print(insert_data);

      // Getting Server response into variable.
      Map<String, dynamic> response_code_JSON = jsonDecode(response_code.body);

      if(response_code.statusCode == 200) {
        // There are no any error at inserting to DB.
        Navigator.of(context).pop();
        //print(response_code_JSON);
        if (response_code_JSON['StatusCode'] == 1000) {
          _dialogStatus = dialog_Status.Success;

          dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Contact_Form_Sent_Success];

          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) => CustomDialog_Confirm(
              dialog_type: _dialogStatus,
              description: dialog_Msg,
              callback_Confirm: () async => {
                await _resetandreload(),
                Navigator.of(context)
                    .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
              },
            ),
          );
        } else if(response_code_JSON['StatusCode'] == 1002){
          _dialogStatus = dialog_Status.Error;
          dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Contact_Form_Sent_OverLimit];
        } else {
          _dialogStatus = dialog_Status.Error;
          dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Contact_Form_Sent_Failed];
        }
      }
    } on TimeoutException catch (e) {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
    } on Error catch(_) {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_Editor_Creator_Fail];
      //print(_.toString());
    } on SocketException catch(_){
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error];
    } on FormatException catch(_) {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error_FormatException];
    }

    if(_dialogStatus == dialog_Status.Error){
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => CustomDialog_Confirm(
          dialog_type: _dialogStatus,
          description: dialog_Msg,
          callback_Confirm: () => {
            Navigator.of(context)
                .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
            Navigator.of(context).push(globals.gotoPage(ContactForm(), Duration(seconds: 0, milliseconds: 0))),
            Navigator.of(context).push(globals.gotoPage(PreviewContactFormPage(), Duration(seconds: 0, milliseconds: 0))),
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    // region UI - Field Labels
    final label_title = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Contact_Form_Lable_Title],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Middle,
            color: appPrimaryColor),
      ),
    );
    final label_desc = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Contact_Form_Lable_Desc],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Middle,
            color: appPrimaryColor),
      ),
    );
    final label_replyEmail = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Contact_Form_Lable_ReplyEmail],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Middle,
            color: appPrimaryColor),
      ),
    );
    final label_nameTitle = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Contact_Form_Lable_NameTitle],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Middle,
            color: appPrimaryColor),
      ),
    );
    final label_lastname = Padding(
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
    // endregion

    // region UI - Form Input Fields
    final _titleField = InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black54)
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                textAlign: TextAlign.right,
                controller: _newTitleController,
                keyboardType: TextInputType.text,
                maxLength: 128,
                maxLines: null,
                style: TextStyle(
                  color: appPrimaryColor,
                  fontSize: 0,
                ),
                enableInteractiveSelection: false,
                readOnly: true,
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
                                child: Text(_newTitleController.text, style: TextStyle(fontSize: globals.fontSize_Normal),)
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0,15,0,0),
                    prefixIcon: label_title,
                    prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                    border: InputBorder.none,
                ),
              ),
            )
          ],
        ) ,
      ),
    );
    final _descField = InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black54)
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                textAlign: TextAlign.right,
                controller: _newDescController,
                keyboardType: TextInputType.multiline,
                maxLength: 1000,
                maxLines: null,
                style: TextStyle(
                  color: appPrimaryColor,
                  fontSize: 0,
                ),
                enableInteractiveSelection: false,
                readOnly: true,
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
                                child: Text(_newDescController.text, style: TextStyle(fontSize: globals.fontSize_Normal),)
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0,15,0,0),
                    prefixIcon: label_desc,
                    prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                    border: InputBorder.none,
                ),
              ),
            )
          ],
        ) ,
      ),
    );
    final _replyEmailField = InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black54)
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: label_replyEmail,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    textAlign: TextAlign.right,
                    controller: _newReplyEmailController,
                    keyboardType: TextInputType.text,
                    maxLength: 256,
                    maxLines: null,
                    readOnly: true,
                    style: TextStyle(
                      color: appPrimaryColor,
                      fontSize: globals.fontSize_Normal,
                    ),
                    buildCounter: (_, {currentLength, maxLength, isFocused}) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        children: [
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                        padding: const EdgeInsets.only(left: 22),
                                        alignment: Alignment.centerLeft,
                                        child: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Contact_Form_Lable_ReplyEmail_Desc],
                                        style: TextStyle(fontSize: globals.fontSize_Small),)
                                    )
                                  ],
                                ),
                              ),
                            ],
                          )
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
        ) ,
      ),
    );
    final _nameTitleSelection = InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black54)
        ),
        child: Row(
          children: <Widget>[
            label_nameTitle,
            Expanded(
              child: TextFormField(
                textAlign: TextAlign.right,
                controller: _newNameTitleController,
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
    final _lastNameField = InkWell(
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
                maxLength: 32,
                maxLines: null,
                readOnly: true,
                style: TextStyle(
                  color: appPrimaryColor,
                  fontSize: globals.fontSize_Normal,
                ),
                onChanged: (text) {
                  globals.newEmail_LastName = text;
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
                    ],
                  ),
                ),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0,15,0,0),
                    prefixIcon: label_lastname,
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
    // endregion

    if (globals.newEmail_Title?.isNotEmpty ?? false) _newTitleController.text = globals.newEmail_Title;
    if (globals.newEmail_Desc?.isNotEmpty ?? false) _newDescController.text = globals.newEmail_Desc;
    if (globals.newEmail_ReplyEmail?.isNotEmpty ?? false) _newReplyEmailController.text = globals.newEmail_ReplyEmail;
    if (globals.newEmail_NameTitle?.isNotEmpty ?? false) _newNameTitleController.text = globals.newEmail_NameTitle;
    if (globals.newEmail_LastName?.isNotEmpty ?? false) _newLastNameController.text = globals.newEmail_LastName;

    String _confirmLabelText, _previewTitleText;
    _confirmLabelText = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Contact_Form_Lable_Send];
    _previewTitleText = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Contact_Form_Lable_Preview];

    return Scaffold(
        backgroundColor: appBGColor,
        appBar: AppBar(
          backgroundColor: appTitleBarColor,
          centerTitle: true,
          title: Text(_previewTitleText,
          style: TextStyle(fontSize: globals.fontSize_Title),),
        ),
        body: Container(
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 75, top: 10),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 24.0, right: 24.0),
              children: <Widget>[
                Visibility(
                  visible: visible_PreviewForm,
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Padding(padding: EdgeInsets.only(top: 12, bottom: 12)),
                        _nameTitleSelection,
                        Padding(padding: EdgeInsets.symmetric(vertical: 8.0),),
                        _lastNameField,
                        Padding(padding: EdgeInsets.symmetric(vertical: 8.0),),
                        _replyEmailField,
                        Padding(padding: EdgeInsets.symmetric(vertical: 8.0),),
                        _titleField,
                        Padding(padding: EdgeInsets.symmetric(vertical: 8.0),),
                        _descField,
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: visible_Loading,
                  child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            child: CircularProgressIndicator(),
                            width: 60,
                            height: 60,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.loadingText],
                            style: TextStyle(fontSize: globals.fontSize_Big),),
                          )
                        ],
                      )
                  ),
                )
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
            child: Visibility(
                visible: visible_floatButtom,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        FloatingActionButton.extended(
                          backgroundColor: Colors.blueGrey,
                          heroTag: null,
                          onPressed: () => {
                              Navigator.of(context).pop(),
                              Navigator.of(context).pop(),
                              Navigator.of(context).push(globals.gotoPage(ContactForm(),Duration(seconds: 0, milliseconds: 0))),
                          },
                          label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_Preview_EditDetails],
                          style: TextStyle(fontSize: globals.fontSize_Normal),),
                          icon: Icon(Icons.edit),
                        ),
                      ],
                    ),
                    FloatingActionButton.extended(
                      heroTag: null,
                      onPressed: () async {
                        await sendEmail();
                      },
                      label: Text(_confirmLabelText,
                      style: TextStyle(fontSize: globals.fontSize_Normal),),
                      icon: Icon(Icons.cloud_upload),
                    ),
                  ],
                )
            )
        )
    );
  }
}