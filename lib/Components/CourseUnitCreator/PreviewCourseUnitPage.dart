import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:smeapp/Components/CourseCreator/CourseEditor.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:smeapp/Components/CourseUnitCreator/CourseUnitEditor.dart';

import '../../main.dart';

import '../../Helper/ComponentsList.dart';
import 'package:http/http.dart' as http;
import '../../Helper/global_setting.dart' as globals;
import 'package:intl/intl.dart';
import 'package:smeapp/Helper/Localizations.dart';

class PreviewCourseUnitPage extends StatefulWidget {
  PreviewCourseUnitPage_State createState() => PreviewCourseUnitPage_State();
}

class PreviewCourseUnitPage_State extends State {
  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "", dialog_Msg_Title = "";
  Image dialog_image;
  int _temp_unitID;

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
  final _newdefaultModuleController = TextEditingController();

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
    globals.newCourseUnit_Title = null;
    globals.newCourseUnit_Desc = null;
    globals.newCourseUnit_SDate = null;
    globals.newCourseUnit_STime = null;
    globals.newCourseUnit_EDate = null;
    globals.newCourseUnit_ETime = null;
    globals.newCourseUnit_FullStartTime = null;
    globals.newCourseUnit_FullEndTime = null;
    globals.editCourseUnit_Title = null;
    globals.editCourseUnit_Desc = null;
    globals.editCourseUnit_SDate = null;
    globals.editCourseUnit_STime = null;
    globals.editCourseUnit_EDate = null;
    globals.editCourseUnit_ETime = null;
    globals.editCourseUnit_FullStartTime = null;
    globals.editCourseUnit_FullEndTime = null;
    globals.courseListReloaded = false;
    globals.courseUnitListReloaded = false;
    globals.materialListReloaded = false;
    globals.skip_moduleselection = 0;
    if(await fetchCourses(context, isAdminCheck: 'true')) {
      globals.course_list_filter_option = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.StatusFilter_All];
      if(await fetchCourseData(context,globals.selectedCourse.courseID)) {
        if(await fetchCourseUnits(context, globals.selectedCourse.courseID)) {
          if(!globals.courseunit_isEditing)
            globals.selectedCourseUnit = globals.courseUnitList.firstWhere((element) => element.unitID == globals.selectedUnitID);
          if(await fetchCourseUnitData(context, globals.selectedCourseUnit.unitID)) {
            globals.courseUnit_list_filter_option = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.StatusFilter_All];
            globals.materials_list_filter_option = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.StatusFilter_All];
            if (await fetchMaterials(context, globals.selectedCourse.courseID, globals.selectedCourseUnit.unitID)) {
              Navigator.of(context).pushAndRemoveUntil(globals.gotoPage(MainPage(), Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false);
              Navigator.of(context).push(globals.gotoPage(globals.CourseList_Page, Duration(seconds: 0, milliseconds: 0)));
              Navigator.of(context).push(globals.gotoPage(globals.CourseUnitList_Page, Duration(seconds: 0, milliseconds: 0)));
              Navigator.of(context).push(globals.gotoPage(globals.CourseUnit_Page, Duration(seconds: 0, milliseconds: 0)));
            }
          }
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
      int tomodule_ID;

      if(isEditing){
        if(globals.editCourseUnit_SelectedGoToMaterial == Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseUnitCreator_Creator_SkipModuleSelection_Default]){
          tomodule_ID = null;
        } else {
          tomodule_ID = int.parse(globals.editCourseUnit_SelectedGoToMaterial.split("|")[0]);
        }
        insert_data = {
          'UnitID': globals.selectedCourseUnit.unitID,
          'Title': globals.editCourseUnit_Title, 'Description': globals.editCourseUnit_Desc,
          'Period_Start': globals.editCourseUnit_FullStartTime, 'Period_End': globals.editCourseUnit_FullEndTime,
          'Skip_Selection': globals.skip_moduleselection, 'ToModule': tomodule_ID};
        response_code = await http.post(
            UpdateCourseUnit_URL, body: json.encode(
            insert_data, toEncodable: globals.dateTimeSerializer)).timeout(
            Duration(seconds: Connection_Timeout_TimeLimit));
      } else {
        //SharedPreferences prefs = await SharedPreferences.getInstance();
        //final String _cUID = prefs.getString(Pref_Profiles_UID), _cUName = prefs.getString(Pref_User_UserName);
        insert_data = {
          'CUID': globals.UserData_UID,'CUName': globals.UserData_username,
          'Title': globals.newCourseUnit_Title, 'Description': globals.newCourseUnit_Desc,
          'Period_Start': globals.newCourseUnit_FullStartTime, 'Period_End': globals.newCourseUnit_FullEndTime,
          'CourseID': globals.selectedCourse.courseID, 'CourseFolder': globals.selectedCourse.courseFolder,
          'Skip_Selection': globals.skip_moduleselection, 'ToModule': null};
        response_code = await http.post(
            InsertCourseUnit_URL, body: json.encode(
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
            dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseUnitCreator_Creator_InsertSuccess];
            globals.selectedUnitID = response_code_JSON['Last_UnitID'];
          } else {
            dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseUnitCreator_Creator_EditingSuccess];
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
          dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseUnitCreator_EditingFail];
        }
      }
    } on TimeoutException catch (e) {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
    } on Error catch(_) {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseUnitCreator_EditingFail];
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
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseUnitCreator_Preview_StartDateTime],
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
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseUnitCreator_Preview_EndDateTime],
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
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseUnitCreator_Creator_Title],
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
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseUnitCreator_Creator_Desc],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Big,
            color: appPrimaryColor),
      ),
    );
    final label_skipselection = Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 20,right: 20),
          child: Text(
            Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseUnitCreator_Creator_SkipModuleSelection_Checkbox],
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: globals.fontSize_Big,
                color: appPrimaryColor),
          ),
        )
      ],
    );
    final label_skipToModuleSelection = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseUnitCreator_Creator_SkipModuleSelection],
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
    final _skipselectionCheckBoxField = InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black54)
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: [
                Expanded(child: Padding(
                  padding: EdgeInsets.only(top:15, bottom: 5),
                  child: label_skipselection,
                ))
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(padding: EdgeInsets.only(top:10, bottom: 10, right: 10),
                      child: ToggleSwitch(
                        minWidth: 45.0,
                        minHeight: 35.0,
                        initialLabelIndex: globals.skip_moduleselection,
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
                        changeOnTap: false,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
    final _skipToModuleSelection = InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black54)
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: [
                Expanded(child: Padding(
                  padding: EdgeInsets.only(top:15, bottom: 5),
                  child: label_skipToModuleSelection,
                ))
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    textAlign: TextAlign.right,
                    controller: _newdefaultModuleController,
                    readOnly: true,
                    enabled: false,
                    keyboardType: TextInputType.text,
                    maxLength: 64,
                    maxLines: null,
                    style: TextStyle(
                      color: appPrimaryColor,
                      fontSize: globals.fontSize_Middle,
                    ),
                    enableInteractiveSelection: false,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(0,10,10,10),
                        counterText: "",
                        border: InputBorder.none,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
    // endregion

    if(globals.courseunit_isEditing){
      // Reload The Stored Variables into form.
      if(globals.editCourseUnit_Title?.isNotEmpty ?? false) _newTitleController.text = globals.editCourseUnit_Title;
      if(globals.editCourseUnit_Desc?.isNotEmpty ?? false) _newDescController.text = globals.editCourseUnit_Desc;
      if(globals.editCourseUnit_FullStartTime.toString()?.isNotEmpty ?? false) _newStartDateTimeController.text = globals.editCourseUnit_FullStartTime.toString();
      if(globals.editCourseUnit_FullEndTime.toString()?.isNotEmpty ?? false) _newEndDateTimeController.text = globals.editCourseUnit_FullEndTime.toString();
      _newdefaultModuleController.text = globals.editCourseUnit_SelectedGoToMaterial;
    } else {
      // Reload The Stored Variables into form.
      if(globals.newCourseUnit_Title?.isNotEmpty ?? false) _newTitleController.text = globals.newCourseUnit_Title;
      if(globals.newCourseUnit_Desc?.isNotEmpty ?? false) _newDescController.text = globals.newCourseUnit_Desc;
      if(globals.newCourseUnit_FullStartTime.toString()?.isNotEmpty ?? false) _newStartDateTimeController.text = globals.newCourseUnit_FullStartTime.toString();
      if(globals.newCourseUnit_FullEndTime.toString()?.isNotEmpty ?? false) _newEndDateTimeController.text = globals.newCourseUnit_FullEndTime.toString();
      _newdefaultModuleController.text = globals.editCourseUnit_SelectedGoToMaterial;
    }

    String _confirmLabelText, _previewTitleText;
    if(globals.courseunit_isEditing){
      _confirmLabelText = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Editing_Confirm];
      _previewTitleText = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.EditingPreview_AppBarTitle];
    } else {
      _confirmLabelText = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.ConfirmUpload];
      _previewTitleText = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseUnitCreator_Creator_AppBarTitle];
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
            padding: EdgeInsets.only(left: 0, right: 0, bottom: 75, top: 10),
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
                        _startDateTimeField,
                        Padding(padding: EdgeInsets.symmetric(vertical: 8.0),),
                        _endDateTimeField,
                        Padding(padding: EdgeInsets.symmetric(vertical: 8.0),),
                        _skipselectionCheckBoxField,
                        Padding(padding: EdgeInsets.symmetric(vertical: 8.0),),
                        Visibility(
                          visible: globals.skip_moduleselection == 1 ? true : false,
                          child: _skipToModuleSelection,
                        ),
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
                              Navigator.of(context).push(globals.gotoPage(CourseUnitEditor(),Duration(seconds: 0, milliseconds: 0))),
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
                        await _insertDataToDB(globals.courseunit_isEditing);
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