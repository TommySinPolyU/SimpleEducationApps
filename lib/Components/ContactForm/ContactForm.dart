import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:smeapp/Components/ContactForm/PreviewContactFormPage.dart';
import 'package:smeapp/Components/CourseCreator/PreviewCoursePage.dart';
import 'package:smeapp/Components/Survey/PreviewSurveyPage.dart';
import '../../Helper/ComponentsList.dart';
import '../../Helper/global_setting.dart' as globals;
import 'package:intl/intl.dart';
import 'package:smeapp/Helper/Localizations.dart';

class ContactForm extends StatefulWidget {
  ContactForm_State createState() => ContactForm_State();
}

class ContactForm_State extends State {
  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "", dialog_Msg_Title = "";
  Image dialog_image;

  // Boolean variable for CircularProgressIndicator.
  bool visible_Loading = false;
  // Boolean variable for New Course Form.
  bool visible_UploadForm = true;
  // Boolean variable for Floating Button.
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
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _showFloatingButton());
  }

  @override
  Widget build(BuildContext context) {
    List<String> Current_NameTitleList;
    String current_nameTitle = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Contact_Form_Lable_NameTitle_Mr];

    if(globals.CurrentLang == Localizations_Language_Identifier.Language_TC){
      Current_NameTitleList = NameTitle_TC;
    } else if(globals.CurrentLang == Localizations_Language_Identifier.Language_Eng){
      Current_NameTitleList = NameTitle;
    }

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
                  fontSize: globals.fontSize_Normal,
                ),
                onChanged: (text) {
                  globals.newEmail_Title = text;
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
                    prefixIcon: label_title,
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
                  fontSize: globals.fontSize_Normal,
                ),
                onChanged: (text) {
                  globals.newEmail_Desc = text;
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
                    prefixIcon: label_desc,
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
                    style: TextStyle(
                      color: appPrimaryColor,
                      fontSize: globals.fontSize_Normal,
                    ),
                    onChanged: (text) {
                      globals.newEmail_ReplyEmail = text;
                    },
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
                                        child: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Contact_Form_Lable_ReplyEmail_Desc])
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
      onTap: () => {
        SelectDialog.showModal<String>(
          context,
          label: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Contact_Form_Lable_NameTitle],
          selectedValue: current_nameTitle,
          items: Current_NameTitleList,
          showSearchBox: false,
          onChange: (String selected) => {
            setState(() {
              current_nameTitle = selected;
              globals.newEmail_NameTitle = current_nameTitle;
              _newNameTitleController.text = globals.newEmail_NameTitle;
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


    // Reset Form Confirm Function
    void resetForm() async{
      globals.newEmail_Title = null;
      globals.newEmail_Desc = null;
      globals.newEmail_LastName = null;
      globals.newEmail_NameTitle = null;
      globals.newEmail_ReplyEmail = null;
      Navigator.of(context).pop();
      Navigator.of(context).push(globals.gotoPage(ContactForm(),Duration(seconds: 0, milliseconds: 0)));
    }

    void ResetForm_Checker() => {
      _dialogStatus = dialog_Status.Warning,
      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.ResetFormWarning],
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => CustomDialog_Selection(
            dialog_type: _dialogStatus,
            description: dialog_Msg,
            callback_Confirm: resetForm
        ),
      )
    };
    DateTime _start, _end;
    void PreviewEmail() => {
      if(!(_newDescController.text.isEmpty || _newTitleController.text.isEmpty ||
          _newLastNameController.text.isEmpty || _newNameTitleController.text.isEmpty ||
          _newReplyEmailController.text.isEmpty)){
        globals.newEmail_Desc = _newDescController.text,
        globals.newEmail_Title = _newTitleController.text,
        globals.newEmail_LastName = _newLastNameController.text,
        globals.newEmail_NameTitle = _newNameTitleController.text,
        globals.newEmail_ReplyEmail = _newReplyEmailController.text,
        Navigator.of(context).push(globals.gotoPage(PreviewContactFormPage(),Duration(seconds: 0, milliseconds: 500))),
      } else {
        _dialogStatus = dialog_Status.Error,
        dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_UploadFormNotAllFill],
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => CustomDialog_Confirm(
            dialog_type: dialog_Status.Error,
            description: dialog_Msg,
          ),
        )
      }
    };

    String _appbarTitle;

    // Reload The Stored Variables into form.
    _appbarTitle = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.SendEmail];
    if (globals.newEmail_Title?.isNotEmpty ?? false) _newTitleController.text = globals.newEmail_Title;
    if (globals.newEmail_Desc?.isNotEmpty ?? false) _newDescController.text = globals.newEmail_Desc;
    if (globals.newEmail_ReplyEmail?.isNotEmpty ?? false) _newReplyEmailController.text = globals.newEmail_ReplyEmail;
    if (globals.newEmail_NameTitle?.isNotEmpty ?? false) _newNameTitleController.text = globals.newEmail_NameTitle;
    if (globals.newEmail_LastName?.isNotEmpty ?? false) _newLastNameController.text = globals.newEmail_LastName;

    return Scaffold(
        backgroundColor: appBGColor,
        appBar: AppBar(
          backgroundColor: appTitleBarColor,
          centerTitle: true,
          title: Text(_appbarTitle,
          style: TextStyle(fontSize: globals.fontSize_Title),),
        ),
        body: Container(
            child: new Padding(
                padding: EdgeInsets.only(top: 10, bottom: 80, left: 20, right: 20),
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Visibility(
                      visible: visible_UploadForm,
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
                )
            )
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
            padding: const EdgeInsets.only(left: 9, right: 9, bottom: 24),
            child: Visibility(
              visible: visible_floatButtom,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FloatingActionButton.extended(
                    heroTag: 'FAB1',
                    onPressed: () async {
                      ResetForm_Checker();
                    },
                    label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_UploadFormReset],
                    style: TextStyle(fontSize: globals.fontSize_Normal),),
                    icon: Icon(Icons.clear),
                    backgroundColor: Colors.red,
                  ),
                  FloatingActionButton.extended(
                    heroTag: 'FAB2',
                    onPressed: () async {
                      PreviewEmail();
                    },
                    label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Contact_Form_Lable_Preview],
                    style: TextStyle(fontSize: globals.fontSize_Normal),),
                    icon: Icon(Icons.remove_red_eye),
                    backgroundColor: appTitleBarColor,
                  )
                ],
              ),
            )
        )
    );
  }
}