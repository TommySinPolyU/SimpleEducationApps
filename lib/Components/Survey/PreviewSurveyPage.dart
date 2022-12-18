import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:smeapp/Components/Survey/SurveyEditor.dart';

import '../../main.dart';

import '../../Helper/ComponentsList.dart';
import 'package:http/http.dart' as http;
import '../../Helper/global_setting.dart' as globals;
import 'package:smeapp/Helper/Localizations.dart';

class PreviewSurveyPage extends StatefulWidget {
  PreviewSurveyPage_State createState() => PreviewSurveyPage_State();
}

class PreviewSurveyPage_State extends State {
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
  final _newLinkController = TextEditingController();
  final _newStartDateTimeController = TextEditingController();
  final _newEndDateTimeController = TextEditingController();

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
    globals.newSurvey_Title = null;
    globals.newSurvey_Desc = null;
    globals.newSurvey_SDate = null;
    globals.newSurvey_STime = null;
    globals.newSurvey_EDate = null;
    globals.newSurvey_ETime = null;
    globals.newSurvey_FullStartTime = null;
    globals.newSurvey_FullEndTime = null;
    globals.newSurvey_Group = null;
    globals.editSurvey_Title = null;
    globals.editSurvey_Desc = null;
    globals.editSurvey_SDate = null;
    globals.editSurvey_STime = null;
    globals.editSurvey_EDate = null;
    globals.editSurvey_ETime = null;
    globals.editSurvey_FullStartTime = null;
    globals.editSurvey_FullEndTime = null;
    globals.editSurvey_Group = null;
    globals.surveyListReloaded = false;
    // Loading Survey List
    if(await fetchSurvey(context, isAdminCheck: 'true')){
      globals.survey_list_filter_option = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.StatusFilter_All];
    Navigator.of(context)
        .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false);
    Navigator.of(context).push(globals.gotoPage(globals.SurveyList_Page, Duration(seconds: 0, milliseconds: 0)));
    }
  }

  Future<void> _insertDataToDB(bool isEditing) async{
    var insert_data;
    if(await Check_Token(context)){
      try{
        // Call Web API and try to get a result from Server
        var response_code;
        if(isEditing){
          insert_data = {
            'Groups': globals.editSurvey_Group,
            'SurveyID': globals.selectedSurvey.surveyID,
            'Title': globals.editSurvey_Title, 'Description': globals.editSurvey_Desc,
            'Link' : globals.editSurvey_URL,
            'Period_Start': globals.editSurvey_FullStartTime, 'Period_End': globals.editSurvey_FullEndTime};
          response_code = await http.post(
              UpdateSurvey_URL, body: json.encode(
              insert_data, toEncodable: globals.dateTimeSerializer), headers: {'Authorization':  'JWT ' + globals.userToken}).timeout(
              Duration(seconds: Connection_Timeout_TimeLimit));
          //print(UpdateSurvey_URL);
        } else {
          //SharedPreferences prefs = await SharedPreferences.getInstance();
          //final String _cUID = prefs.getString(Pref_Profiles_UID), _cUName = prefs.getString(Pref_User_UserName);
          insert_data = {
            'Groups': globals.newSurvey_Group,
            'CUID': globals.UserData_UID,'CUName': globals.UserData_username,
            'Title': globals.newSurvey_Title, 'Description': globals.newSurvey_Desc,
            'Link' : globals.newSurvey_URL,
            'Period_Start': globals.newSurvey_FullStartTime, 'Period_End': globals.newSurvey_FullEndTime};
          response_code = await http.post(
              InsertSurvey_URL, body: json.encode(
              insert_data, toEncodable: globals.dateTimeSerializer), headers: {'Authorization':  'JWT ' + globals.userToken}).timeout(
              Duration(seconds: Connection_Timeout_TimeLimit));
          //print(InsertSurvey_URL);
        }

        //print(insert_data);
        // Getting Server response into variable.
        Map<String, dynamic> response_code_JSON = jsonDecode(response_code.body);

        if(response_code.statusCode == 200) {
          // There are no any error at inserting to DB.

          if (response_code_JSON['StatusCode'] == 1000) {
            _dialogStatus = dialog_Status.Success;

            if(!isEditing) {
              dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_Editor_Creator_InsertSuccess];
            } else {
              dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_Editor_Creator_UpdateSuccess];
            }

            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) => CustomDialog_Confirm(
                dialog_type: _dialogStatus,
                description: dialog_Msg,
                callback_Confirm: () async => {
                  await _resetandreload()
                },
              ),
            );
          } else {
            _dialogStatus = dialog_Status.Error;
            dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_Editor_Creator_Fail];
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
        print(_.message);
      }

      if(_dialogStatus == dialog_Status.Error){
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => CustomDialog_Confirm(
            dialog_type: _dialogStatus,
            description: dialog_Msg,
          ),
        );
      }
    } else {

    }
  }

  @override
  Widget build(BuildContext context) {

    // region UI - Field Labels
    final label_startDateTime = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_Editor_Preview_StartDateTime],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Big,
            color: appPrimaryColor),
      ),
    );
    final label_endDateTime = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_Editor_Preview_EndDateTime],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Big,
            color: appPrimaryColor),
      ),
    );
    final label_title = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_Editor_Title],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Big,
            color: appPrimaryColor),
      ),
    );
    final label_desc = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_Editor_Desc],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Big,
            color: appPrimaryColor),
      ),
    );
    final label_link = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_Editor_Link],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Big,
            color: appPrimaryColor),
      ),
    );
    final label_group= Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseCreator_Creator_Groups],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Big,
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
                maxLength: 32,
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
                                child: Text(_newTitleController.text, style: TextStyle(fontSize: globals.fontSize_Middle),)
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
                                child: Text(_newDescController.text, style: TextStyle(fontSize: globals.fontSize_Middle),)
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
    final _groupField = InkWell(
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
                                padding: const EdgeInsets.only(left: 6),
                                alignment: Alignment.centerLeft,
                                child: MultiSelectChipDisplay(
                                  chipColor: Colors.blueAccent,
                                  textStyle: TextStyle(color: Colors.white),
                                  items: globals.selected_group.map((e) => MultiSelectItem(e, e.groupName)).toList(),
                                )
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(0,15,0,0),
                  prefixIcon: label_group,
                  prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                  border: InputBorder.none,
                ),
              ),
            )
          ],
        ) ,
      ),
    );
    final _startDateTimeField = InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black54)
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                textAlign: TextAlign.right,
                controller: _newStartDateTimeController,
                keyboardType: TextInputType.text,
                maxLines: 1,
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
                                child: Text(_newStartDateTimeController.text, style: TextStyle(fontSize: globals.fontSize_Middle),)
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0,15,0,0),
                    prefixIcon: label_startDateTime,
                    prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                    border: InputBorder.none,
                ),
              ),
            )
          ],
        ) ,
      ),
    );
    final _endDateTimeField = InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black54)
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                textAlign: TextAlign.right,
                controller: _newEndDateTimeController,
                keyboardType: TextInputType.text,
                maxLines: 1,
                style: TextStyle(
                  color: appPrimaryColor,
                  fontSize: 0,
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
                                child: Text(_newEndDateTimeController.text, style: TextStyle(fontSize: globals.fontSize_Middle),)
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                readOnly: true,
                enableInteractiveSelection: false,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0,15,0,0),
                    prefixIcon: label_endDateTime,
                    prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                    border: InputBorder.none,
                ),
              ),
            )
          ],
        ) ,
      ),
    );
    final _linkField = InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black54)
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                textAlign: TextAlign.right,
                controller: _newLinkController,
                keyboardType: TextInputType.text,
                maxLength: null,
                maxLines: 1,
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
                                child: Text(_newLinkController.text, style: TextStyle(fontSize: globals.fontSize_Middle),)
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(0,15,0,0),
                  prefixIcon: label_link,
                  prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                  border: InputBorder.none,
                ),
              ),
            )
          ],
        ) ,
      ),
    );
    // endregion

    if(globals.survey_isEditing){
      // Reload The Stored Variables into form.
      if(globals.editSurvey_Title?.isNotEmpty ?? false) _newTitleController.text = globals.editSurvey_Title;
      if(globals.editSurvey_Desc?.isNotEmpty ?? false) _newDescController.text = globals.editSurvey_Desc;
      if(globals.editSurvey_FullStartTime.toString()?.isNotEmpty ?? false) _newStartDateTimeController.text = globals.editSurvey_FullStartTime.toString();
      if(globals.editSurvey_FullEndTime.toString()?.isNotEmpty ?? false) _newEndDateTimeController.text = globals.editSurvey_FullEndTime.toString();
      if(globals.editSurvey_URL?.isNotEmpty ?? false) _newLinkController.text = globals.editSurvey_URL;
    } else {
      // Reload The Stored Variables into form.
      if(globals.newSurvey_Title?.isNotEmpty ?? false) _newTitleController.text = globals.newSurvey_Title;
      if(globals.newSurvey_Desc?.isNotEmpty ?? false) _newDescController.text = globals.newSurvey_Desc;
      if(globals.newSurvey_FullStartTime.toString()?.isNotEmpty ?? false) _newStartDateTimeController.text = globals.newSurvey_FullStartTime.toString();
      if(globals.newSurvey_FullEndTime.toString()?.isNotEmpty ?? false) _newEndDateTimeController.text = globals.newSurvey_FullEndTime.toString();
      if(globals.newSurvey_URL?.isNotEmpty ?? false) _newLinkController.text = globals.newSurvey_URL;
    }

    String _confirmLabelText, _previewTitleText;
    if(globals.survey_isEditing){
      _confirmLabelText = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Editing_Confirm];
      _previewTitleText = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_Editor_Edit_AppBarTitle];
    } else {
      _confirmLabelText = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.ConfirmUpload];
      _previewTitleText = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_Editor_Create_AppBarTitle];
    }

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
                        _titleField,
                        Padding(padding: EdgeInsets.symmetric(vertical: 8.0),),
                        _descField,
                        Padding(padding: EdgeInsets.symmetric(vertical: 8.0),),
                        _groupField,
                        Padding(padding: EdgeInsets.symmetric(vertical: 8.0),),
                        _linkField,
                        Padding(padding: EdgeInsets.symmetric(vertical: 8.0),),
                        _startDateTimeField,
                        Padding(padding: EdgeInsets.symmetric(vertical: 8.0),),
                        _endDateTimeField,
                        Padding(padding: EdgeInsets.symmetric(vertical: 8.0),),
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
                            width: 100,
                            height: 100,
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
                              Navigator.of(context).push(globals.gotoPage(SurveyEditor(),Duration(seconds: 0, milliseconds: 0))),
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
                        await _insertDataToDB(globals.survey_isEditing);
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