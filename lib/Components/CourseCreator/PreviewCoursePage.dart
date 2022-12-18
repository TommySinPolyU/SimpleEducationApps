import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:smeapp/Components/CourseCreator/CourseEditor.dart';

import '../../main.dart';
import 'package:smeapp/Helper/JsonItemConvertor.dart';
import '../../Helper/ComponentsList.dart';
import 'package:http/http.dart' as http;
import '../../Helper/global_setting.dart' as globals;
import 'package:intl/intl.dart';
import 'package:smeapp/Helper/Localizations.dart';

class PreviewCoursePage extends StatefulWidget {
  PreviewCoursePage_State createState() => PreviewCoursePage_State();
}

class PreviewCoursePage_State extends State {
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
    globals.newCourse_Title = null;
    globals.newCourse_Desc = null;
    globals.newCourse_SDate = null;
    globals.newCourse_STime = null;
    globals.newCourse_EDate = null;
    globals.newCourse_ETime = null;
    globals.newCourse_FullStartTime = null;
    globals.newCourse_FullEndTime = null;
    globals.newCourse_Groups = null;
    globals.editCourse_Title = null;
    globals.editCourse_Desc = null;
    globals.editCourse_SDate = null;
    globals.editCourse_STime = null;
    globals.editCourse_EDate = null;
    globals.editCourse_ETime = null;
    globals.editCourse_FullStartTime = null;
    globals.editCourse_FullEndTime = null;
    globals.editCourse_Groups = null;
    globals.courseListReloaded = false;
    globals.courseUnitListReloaded = false;
    if(await fetchCourses(context, isAdminCheck: 'true')) {
      globals.courseUnit_list_filter_option = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.StatusFilter_All];
      if(!globals.course_isEditing)
        globals.selectedCourse = globals.courseList.firstWhere((element) => element.courseID == globals.selectedCourseID);
      if(await fetchCourseData(context, globals.selectedCourse.courseID)) {
        if(await fetchCourseUnits(context, globals.selectedCourse.courseID)) {
          Navigator.of(context).pushAndRemoveUntil(globals.gotoPage(MainPage(), Duration(seconds: 0, milliseconds: 0)), (
              Route<dynamic> route) => false);
          Navigator.of(context).push(globals.gotoPage(globals.CourseList_Page, Duration(seconds: 0, milliseconds: 0)));
          Navigator.of(context).push(globals.gotoPage(globals.CourseUnitList_Page, Duration(seconds: 0, milliseconds: 0)));
        }
      }
    } else{

    }
  }

  Future<void> _insertDataToDB(bool isEditing) async{
    var insert_data;
    try{
      // Call Web API and try to get a result from Server
      var response_code;
      if(isEditing){
        insert_data = {
          'Groups': globals.editCourse_Groups,
          'CID': globals.selectedCourse.courseID,'courseName': globals.editCourse_Title, 'courseDesc': globals.editCourse_Desc, 'coursePeriod_Start': globals.editCourse_FullStartTime, 'coursePeriod_End': globals.editCourse_FullEndTime};
        response_code = await http.post(
            UpdateCourse_URL, body: json.encode(
            insert_data, toEncodable: globals.dateTimeSerializer)).timeout(
            Duration(seconds: Connection_Timeout_TimeLimit));
      } else {
        insert_data = {
          'Groups': globals.newCourse_Groups,
          'CUID': globals.UserData_UID,'CUName': globals.UserData_username,
          'Title': globals.newCourse_Title, 'Description': globals.newCourse_Desc, 'Period_Start': globals.newCourse_FullStartTime, 'Period_End': globals.newCourse_FullEndTime};
        response_code = await http.post(
            InsertCourse_URL, body: json.encode(
            insert_data, toEncodable: globals.dateTimeSerializer)).timeout(
            Duration(seconds: Connection_Timeout_TimeLimit));
      }
      //print(insert_data);
      // Getting Server response into variable.
      Map<String, dynamic> response_code_JSON = jsonDecode(response_code.body);

      if(response_code.statusCode == 200) {
        // There are no any error at inserting to DB.

        if (response_code_JSON['StatusCode'] == 1000) {
          _dialogStatus = dialog_Status.Success;

          if(!isEditing) {
            dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseCreator_InsertSuccess];
            globals.selectedCourseID = response_code_JSON['Last_CID'];
          } else {
            dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseCreator_EditingSuccess];
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
          dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseCreator_EditingFail];
        }
      }
    } on TimeoutException catch (e) {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
    } on Error catch(_) {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseCreator_EditingFail];
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
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    // region UI - Field Labels
    final label_startDateTime = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseCreator_Preview_StartDateTime],
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
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseCreator_Preview_EndDateTime],
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
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseCreator_Creator_Title],
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
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseCreator_Creator_Desc],
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
                maxLength: 100,
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
    // endregion

    if(globals.course_isEditing){
      // Reload The Stored Variables into form.
      if(globals.editCourse_Title?.isNotEmpty ?? false) _newTitleController.text = globals.editCourse_Title;
      if(globals.editCourse_Desc?.isNotEmpty ?? false) _newDescController.text = globals.editCourse_Desc;
      if(globals.editCourse_FullStartTime.toString()?.isNotEmpty ?? false) _newStartDateTimeController.text = globals.editCourse_FullStartTime.toString();
      if(globals.editCourse_FullEndTime.toString()?.isNotEmpty ?? false) _newEndDateTimeController.text = globals.editCourse_FullEndTime.toString();
    } else {
      // Reload The Stored Variables into form.
      if(globals.newCourse_Title?.isNotEmpty ?? false) _newTitleController.text = globals.newCourse_Title;
      if(globals.newCourse_Desc?.isNotEmpty ?? false) _newDescController.text = globals.newCourse_Desc;
      if(globals.newCourse_FullStartTime.toString()?.isNotEmpty ?? false) _newStartDateTimeController.text = globals.newCourse_FullStartTime.toString();
      if(globals.newCourse_FullEndTime.toString()?.isNotEmpty ?? false) _newEndDateTimeController.text = globals.newCourse_FullEndTime.toString();
    }

    String _confirmLabelText, _previewTitleText;
    if(globals.course_isEditing){
      _confirmLabelText = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Editing_Confirm];
      _previewTitleText = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.EditingPreview_AppBarTitle];
    } else {
      _confirmLabelText = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.ConfirmUpload];
      _previewTitleText = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseCreator_Preview_AppBarTitle];
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
              padding: EdgeInsets.only(left: 12.0, right: 12.0),
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
                              //Navigator.of(context).pop(),
                              //Navigator.of(context).push(globals.gotoPage(CourseEditor(),Duration(seconds: 0, milliseconds: 0))),
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
                        await _insertDataToDB(globals.course_isEditing);
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