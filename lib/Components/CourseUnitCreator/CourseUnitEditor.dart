import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:smeapp/Components/CourseCreator/PreviewCoursePage.dart';
import 'package:smeapp/Components/CourseUnitCreator/PreviewCourseUnitPage.dart';
import '../../Helper/ComponentsList.dart';
import '../../Helper/global_setting.dart' as globals;
import 'package:intl/intl.dart';
import 'package:smeapp/Helper/Localizations.dart';

class CourseUnitEditor extends StatefulWidget {
  CourseUnitEditor_State createState() => CourseUnitEditor_State();
}

class CourseUnitEditor_State extends State {
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
  final _newStartDateController = TextEditingController();
  final _newEndDateController = TextEditingController();
  final _newStartTimeController = TextEditingController();
  final _newEndTimeController = TextEditingController();
  final _newdefaultModuleController = TextEditingController();

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
    if(!globals.courseunit_isEditing){
      globals.courseUnitMaterialsNameList = new List<String>();
      globals.skip_moduleselection = 0;
      globals.courseUnitMaterialsNameList.add(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseUnitCreator_Creator_SkipModuleSelection_Default]);
      globals.editCourseUnit_SelectedGoToMaterial = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseUnitCreator_Creator_SkipModuleSelection_Default];
    }
  }

  @override
  Widget build(BuildContext context) {
    // region UI - Field Labels
    final label_startDate = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseUnitCreator_Creator_StartDate],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Big,
            color: appPrimaryColor),
      ),
    );
    final label_startTime = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseUnitCreator_Creator_StartTime],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Big,
            color: appPrimaryColor),
      ),
    );
    final label_endDate = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseUnitCreator_Creator_EndDate],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Big,
            color: appPrimaryColor),
      ),
    );
    final label_endTime = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseUnitCreator_Creator_EndTime],
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
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Padding(
                  padding: EdgeInsets.only(top:15, bottom: 5),
                  child: label_title,
                ))
              ],
            ),
            Row(
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
                      fontSize: globals.fontSize_Middle,
                    ),
                    onChanged: (text) {
                      if(globals.courseunit_isEditing)
                        globals.editCourseUnit_Title = text;
                      else
                        globals.newCourseUnit_Title = text;
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
                        contentPadding: EdgeInsets.fromLTRB(15,15,0,0),
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
          ],
        ),
      ),
    );
    final _descField = InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black54)
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Padding(
                  padding: EdgeInsets.only(top:15, bottom: 5),
                  child: label_desc,
                ))
              ],
            ),
            Row(
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
                      fontSize: globals.fontSize_Middle,
                    ),
                    onChanged: (text) {
                      if(globals.courseunit_isEditing)
                        globals.editCourseUnit_Desc = text;
                      else
                        globals.newCourseUnit_Desc = text;
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
                        contentPadding: EdgeInsets.fromLTRB(15,15,0,0),
                        prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
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
        ),
      ),
    );
    final _startDateField = InkWell(
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
                  child: label_startDate,
                ))
              ],
            ),
            Row(
              children: [
                Expanded(child: TextFormField(
                  onTap: () {
                    // region onTap Function ==> handle selection of Date
                    FocusScope.of(context).unfocus();
                    DateTime _currentDateTime;
                    _currentDateTime = _newStartDateController.text.isNotEmpty
                        ? DateFormat("yyyy-MM-dd").parse(_newStartDateController.text)
                        : DateTime.now();
                    switch(globals.CurrentLang){
                      case Localizations_Language_Identifier.Language_TC:
                        DatePicker.showDatePicker(context,
                            showTitleActions: true,
                            //minTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                            maxTime: new DateTime(DateTime.now().year + 99, DateTime.december , 31), onChanged: (date) {
                              if(globals.courseunit_isEditing) {
                                globals.editCourseUnit_SDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                _newStartDateController.text = globals.editCourseUnit_SDate;
                              } else {
                                globals.newCourseUnit_SDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                _newStartDateController.text = globals.newCourseUnit_SDate;
                              }
                            }, onConfirm: (date) {
                              if(globals.courseunit_isEditing) {
                                globals.editCourseUnit_SDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                _newStartDateController.text = globals.editCourseUnit_SDate;
                              } else {
                                globals.newCourseUnit_SDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                _newStartDateController.text = globals.newCourseUnit_SDate;
                              }
                            }, currentTime: _currentDateTime, locale: LocaleType.zh);
                        break;
                      case Localizations_Language_Identifier.Language_Eng:
                        DatePicker.showDatePicker(context,
                            showTitleActions: true,
                            //minTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                            maxTime: new DateTime(DateTime.now().year + 99, DateTime.december , 31), onChanged: (date) {
                              if(globals.courseunit_isEditing) {
                                globals.editCourseUnit_SDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                _newStartDateController.text = globals.editCourseUnit_SDate;
                              } else {
                                globals.newCourseUnit_SDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                _newStartDateController.text = globals.newCourseUnit_SDate;
                              }
                            }, onConfirm: (date) {
                              if(globals.courseunit_isEditing) {
                                globals.editCourseUnit_SDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                _newStartDateController.text = globals.editCourseUnit_SDate;
                              } else {
                                globals.newCourseUnit_SDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                _newStartDateController.text = globals.newCourseUnit_SDate;
                              }
                            }, currentTime: _currentDateTime, locale: LocaleType.en);
                        break;
                    }
                    // endregion
                  },
                  textAlign: TextAlign.right,
                  controller: _newStartDateController,
                  keyboardType: TextInputType.text,
                  maxLines: 1,
                  style: TextStyle(
                    color: appPrimaryColor,
                    fontSize: globals.fontSize_Middle,
                  ),
                  buildCounter: (_, {currentLength, maxLength, isFocused}) => Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: Row(
                      children: <Widget>[

                      ],
                    ),
                  ),
                  readOnly: true,
                  enableInteractiveSelection: false,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(0,15,0,0),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(Icons.input),
                      )
                  ),
                ),)
              ],
            )
          ],
        ) ,
      ),
    );
    final _startTimeField = InkWell(
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
                  child: label_startTime,
                ))
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    onTap: () {
                      // region onTap Function ==> handle selection of Time
                      FocusScope.of(context).unfocus();
                      DateTime _currentDateTime;
                      _currentDateTime = _newStartTimeController.text.isNotEmpty
                          ? DateFormat("HH:mm:ss").parse(_newStartTimeController.text)
                          : DateTime(0,0,0,0,0,0);
                      switch(globals.CurrentLang){
                        case Localizations_Language_Identifier.Language_TC:
                          DatePicker.showTimePicker(context,
                              showTitleActions: true,
                              onChanged: (time) {
                                if(globals.courseunit_isEditing) {
                                  globals.editCourseUnit_STime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newStartTimeController.text = globals.editCourseUnit_STime;
                                } else {
                                  globals.newCourseUnit_STime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newStartTimeController.text = globals.newCourseUnit_STime;
                                }
                              }, onConfirm: (time) {
                                if(globals.courseunit_isEditing) {
                                  globals.editCourseUnit_STime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newStartTimeController.text = globals.editCourseUnit_STime;
                                } else {
                                  globals.newCourseUnit_STime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newStartTimeController.text = globals.newCourseUnit_STime;
                                }
                              }, currentTime: _currentDateTime, locale: LocaleType.zh);
                          break;
                        case Localizations_Language_Identifier.Language_Eng:
                          DatePicker.showTimePicker(context,
                              showTitleActions: true,
                              onChanged: (time) {
                                if(globals.courseunit_isEditing) {
                                  globals.editCourseUnit_STime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newStartTimeController.text = globals.editCourseUnit_STime;
                                } else {
                                  globals.newCourseUnit_STime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newStartTimeController.text = globals.newCourseUnit_STime;
                                }
                              }, onConfirm: (time) {
                                if(globals.courseunit_isEditing) {
                                  globals.editCourseUnit_STime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newStartTimeController.text = globals.editCourseUnit_STime;
                                } else {
                                  globals.newCourseUnit_STime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newStartTimeController.text = globals.newCourseUnit_STime;
                                }
                              }, currentTime: _currentDateTime, locale: LocaleType.en);
                          break;
                      }
                      // endregion
                    },
                    textAlign: TextAlign.right,
                    controller: _newStartTimeController,
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                    style: TextStyle(
                      color: appPrimaryColor,
                      fontSize: globals.fontSize_Middle,
                    ),
                    buildCounter: (_, {currentLength, maxLength, isFocused}) => Padding(
                      padding: const EdgeInsets.only(bottom: 0),
                      child: Row(
                        children: <Widget>[

                        ],
                      ),
                    ),
                    readOnly: true,
                    enableInteractiveSelection: false,
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
    final _endDateField = InkWell(
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
                  child: label_endDate,
                ))
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    onTap: () {
                      // region onTap Function ==> handle selection of Date
                      FocusScope.of(context).unfocus();
                      DateTime _currentDateTime;
                      _currentDateTime = _newEndDateController.text.isNotEmpty
                          ? DateFormat("yyyy-MM-dd").parse(_newEndDateController.text)
                          : DateTime.now();
                      switch(globals.CurrentLang){
                        case Localizations_Language_Identifier.Language_TC:
                          DatePicker.showDatePicker(context,
                              showTitleActions: true,
                              //minTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                              maxTime: new DateTime(DateTime.now().year + 99, DateTime.december , 31), onChanged: (date) {
                                if(globals.courseunit_isEditing) {
                                  globals.editCourseUnit_EDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                  _newEndDateController.text = globals.editCourseUnit_EDate;
                                } else {
                                  globals.newCourseUnit_EDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                  _newEndDateController.text = globals.newCourseUnit_EDate;
                                }
                              }, onConfirm: (date) {
                                if(globals.courseunit_isEditing) {
                                  globals.editCourseUnit_EDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                  _newEndDateController.text = globals.editCourseUnit_EDate;
                                } else {
                                  globals.newCourseUnit_EDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                  _newEndDateController.text = globals.newCourseUnit_EDate;
                                }
                              }, currentTime: _currentDateTime, locale: LocaleType.zh);
                          break;
                        case Localizations_Language_Identifier.Language_Eng:
                          DatePicker.showDatePicker(context,
                              showTitleActions: true,
                              //minTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                              maxTime: new DateTime(DateTime.now().year + 99, DateTime.december , 31), onChanged: (date) {
                                if(globals.courseunit_isEditing) {
                                  globals.editCourseUnit_EDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                  _newEndDateController.text = globals.editCourseUnit_EDate;
                                } else {
                                  globals.newCourseUnit_EDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                  _newEndDateController.text = globals.newCourseUnit_EDate;
                                }
                              }, onConfirm: (date) {
                                if(globals.courseunit_isEditing) {
                                  globals.editCourseUnit_EDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                  _newEndDateController.text = globals.editCourseUnit_EDate;
                                } else {
                                  globals.newCourseUnit_EDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                  _newEndDateController.text = globals.newCourseUnit_EDate;
                                }
                              }, currentTime: _currentDateTime, locale: LocaleType.en);
                          break;
                      }
                      // endregion
                    },
                    textAlign: TextAlign.right,
                    controller: _newEndDateController,
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                    style: TextStyle(
                      color: appPrimaryColor,
                      fontSize: globals.fontSize_Middle,
                    ),
                    buildCounter: (_, {currentLength, maxLength, isFocused}) => Padding(
                      padding: const EdgeInsets.only(bottom: 0),
                      child: Row(
                        children: <Widget>[

                        ],
                      ),
                    ),
                    readOnly: true,
                    enableInteractiveSelection: false,
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
    final _endTimeField = InkWell(
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
                  child: label_endTime,
                ))
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    onTap: () {
                      // region onTap Function ==> handle selection of Time
                      FocusScope.of(context).unfocus();
                      DateTime _currentDateTime;
                      _currentDateTime = _newEndTimeController.text.isNotEmpty
                          ? DateFormat("HH:mm:ss").parse(_newEndTimeController.text)
                          : DateTime(0,0,0,0,0,0);
                      switch(globals.CurrentLang){
                        case Localizations_Language_Identifier.Language_TC:
                          DatePicker.showTimePicker(context,
                              showTitleActions: true,
                              onChanged: (time) {
                                if(globals.courseunit_isEditing) {
                                  globals.editCourseUnit_ETime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newEndTimeController.text = globals.editCourseUnit_ETime;
                                } else {
                                  globals.newCourseUnit_ETime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newEndTimeController.text = globals.newCourseUnit_ETime;
                                }
                              }, onConfirm: (time) {
                                if(globals.courseunit_isEditing) {
                                  globals.editCourseUnit_ETime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newEndTimeController.text = globals.editCourseUnit_ETime;
                                } else {
                                  globals.newCourseUnit_ETime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newEndTimeController.text = globals.newCourseUnit_ETime;
                                }
                              }, currentTime: _currentDateTime, locale: LocaleType.zh);
                          break;
                        case Localizations_Language_Identifier.Language_Eng:
                          DatePicker.showTimePicker(context,
                              showTitleActions: true,
                              onChanged: (time) {
                                if(globals.courseunit_isEditing) {
                                  globals.editCourseUnit_ETime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newEndTimeController.text = globals.editCourseUnit_ETime;
                                } else {
                                  globals.newCourseUnit_ETime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newEndTimeController.text = globals.newCourseUnit_ETime;
                                }
                              }, onConfirm: (time) {
                                if(globals.courseunit_isEditing) {
                                  globals.editCourseUnit_ETime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newEndTimeController.text = globals.editCourseUnit_ETime;
                                } else {
                                  globals.newCourseUnit_ETime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newEndTimeController.text = globals.newCourseUnit_ETime;
                                }
                              }, currentTime: _currentDateTime, locale: LocaleType.en);
                          break;
                      }
                      // endregion
                    },
                    textAlign: TextAlign.right,
                    controller: _newEndTimeController,
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                    style: TextStyle(
                      color: appPrimaryColor,
                      fontSize: globals.fontSize_Middle,
                    ),
                    buildCounter: (_, {currentLength, maxLength, isFocused}) => Padding(
                      padding: const EdgeInsets.only(bottom: 0),
                      child: Row(
                        children: <Widget>[

                        ],
                      ),
                    ),
                    readOnly: true,
                    enableInteractiveSelection: false,
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
                        onToggle: (val) async {
                          setState(() {
                            globals.skip_moduleselection = val;
                          });
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
            Row(
              children: [
                Expanded(child: Padding(
                    padding: EdgeInsets.only(top:15, bottom: 15, left: 20, right: 20),
                    child: Text(
                      Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseUnitCreator_Creator_SkipModuleSelection_Checkbox_Desc],
                      textAlign: TextAlign.left,
                      //overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: globals.fontSize_Normal,
                          color: Colors.black54),
                    )
                ))
              ],
            )
          ],
        ),
      ),
    );
    final _skipToModuleSelection = InkWell(
      onTap: () => {
        SelectDialog.showModal<String>(
          context,
          label: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseUnitCreator_Creator_SkipModuleSelection],
          selectedValue: globals.editCourseUnit_SelectedGoToMaterial,
          items: globals.courseUnitMaterialsNameList,
          showSearchBox: false,
          onChange: (String selected) => {
            setState(() {
              globals.editCourseUnit_SelectedGoToMaterial = selected;
              _newdefaultModuleController.text = globals.editCourseUnit_SelectedGoToMaterial;
            }),
          },
        )
      },
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
            Row(
              children: [
                Expanded(child: Padding(
                    padding: EdgeInsets.only(top:15, bottom: 15, left: 20, right: 20),
                    child: Text(
                      Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseUnitCreator_Creator_SkipModuleSelection_Desc],
                      textAlign: TextAlign.left,
                      //overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: globals.fontSize_Normal,
                          color: Colors.black54),
                    )
                ))
              ],
            )
          ],
        ),
      ),
    );
    // endregion


    // Reset Form Confirm Function
    void resetForm() async{
      globals.newCourseUnit_Title = null;
      globals.newCourseUnit_Desc = null;
      globals.newCourseUnit_SDate = null;
      globals.newCourseUnit_STime = null;
      globals.newCourseUnit_EDate = null;
      globals.newCourseUnit_ETime = null;
      globals.newCourseUnit_FullStartTime = null;
      globals.newCourseUnit_FullEndTime = null;
      Navigator.of(context).pop();
      globals.courseunit_isEditing = false;
      Navigator.of(context).push(globals.gotoPage(CourseUnitEditor(),Duration(seconds: 0, milliseconds: 0)));
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
    void PreviewCourse() => {
      if(!(_newDescController.text.isEmpty || _newTitleController.text.isEmpty ||
          _newStartDateController.text.isEmpty || _newStartTimeController.text.isEmpty ||
          _newEndDateController.text.isEmpty || _newEndTimeController.text.isEmpty)){
        if(!globals.courseunit_isEditing){
          globals.newCourseUnit_Desc = _newDescController.text,
          globals.newCourseUnit_Title = _newTitleController.text,
          globals.newCourseUnit_SDate = _newStartDateController.text,
          globals.newCourseUnit_STime = _newStartTimeController.text,
          globals.newCourseUnit_EDate = _newEndDateController.text,
          globals.newCourseUnit_ETime = _newEndTimeController.text,
          globals.newCourseUnit_FullStartTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(
                  DateTime.parse(globals.newCourseUnit_SDate + " " + globals.newCourseUnit_STime)
              ),
          globals.newCourseUnit_FullEndTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(
                  DateTime.parse(globals.newCourseUnit_EDate + " " + globals.newCourseUnit_ETime)
              ),
          _start = DateTime.parse(globals.newCourseUnit_FullStartTime),
          _end = DateTime.parse(globals.newCourseUnit_FullEndTime),
        } else {
          globals.editCourseUnit_Desc = _newDescController.text,
          globals.editCourseUnit_Title = _newTitleController.text,
          globals.editCourseUnit_SDate = _newStartDateController.text,
          globals.editCourseUnit_STime = _newStartTimeController.text,
          globals.editCourseUnit_EDate = _newEndDateController.text,
          globals.editCourseUnit_ETime = _newEndTimeController.text,
          globals.editCourseUnit_FullStartTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(
              DateTime.parse(globals.editCourseUnit_SDate + " " + globals.editCourseUnit_STime)
          ),
          globals.editCourseUnit_FullEndTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(
              DateTime.parse(globals.editCourseUnit_EDate + " " + globals.editCourseUnit_ETime)
          ),
          _start = DateTime.parse(globals.editCourseUnit_FullStartTime),
          _end = DateTime.parse(globals.editCourseUnit_FullEndTime),
        },
        if(_end.isBefore(_start) || _end.isAtSameMomentAs(_start)){
          _dialogStatus = dialog_Status.Error,
          dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.DateTimeSettingError_EndBeforeStart],
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) => CustomDialog_Confirm(
              dialog_type: dialog_Status.Error,
              description: dialog_Msg,
            ),
          )
        }
          else
            Navigator.of(context).push(globals.gotoPage(PreviewCourseUnitPage(),Duration(seconds: 0, milliseconds: 500))),
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
    if(!globals.courseunit_isEditing) {
      _appbarTitle = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseUnitCreator_Creator_AppBarTitle];
      if (globals.newCourseUnit_Title?.isNotEmpty ?? false) _newTitleController.text = globals.newCourseUnit_Title;
      if (globals.newCourseUnit_Desc?.isNotEmpty ?? false) _newDescController.text = globals.newCourseUnit_Desc;
      if (globals.newCourseUnit_SDate?.isNotEmpty ?? false) _newStartDateController.text = globals.newCourseUnit_SDate;
      if (globals.newCourseUnit_STime?.isNotEmpty ?? false) _newStartTimeController.text = globals.newCourseUnit_STime;
      if (globals.newCourseUnit_EDate?.isNotEmpty ?? false) _newEndDateController.text = globals.newCourseUnit_EDate;
      if (globals.newCourseUnit_ETime?.isNotEmpty ?? false) _newEndTimeController.text = globals.newCourseUnit_ETime;
      _newdefaultModuleController.text = globals.editCourseUnit_SelectedGoToMaterial;
    } else {
      _appbarTitle = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseUnitCreator_Editor_AppBarTitle];
      if(globals.editCourseUnit_Title?.isNotEmpty ?? false) _newTitleController.text = globals.editCourseUnit_Title;
      if(globals.editCourseUnit_Desc?.isNotEmpty ?? false) _newDescController.text = globals.editCourseUnit_Desc;
      if(globals.editCourseUnit_SDate?.isNotEmpty ?? false) _newStartDateController.text = globals.editCourseUnit_SDate;
      if(globals.editCourseUnit_STime?.isNotEmpty ?? false) _newStartTimeController.text = globals.editCourseUnit_STime;
      if(globals.editCourseUnit_EDate?.isNotEmpty ?? false) _newEndDateController.text = globals.editCourseUnit_EDate;
      if(globals.editCourseUnit_ETime?.isNotEmpty ?? false) _newEndTimeController.text = globals.editCourseUnit_ETime;
      _newdefaultModuleController.text = globals.editCourseUnit_SelectedGoToMaterial;
    }

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
                            _titleField,
                            Padding(padding: EdgeInsets.symmetric(vertical: 8.0),),
                            _descField,
                            Padding(padding: EdgeInsets.symmetric(vertical: 8.0),),
                            //_newRequiredTime,
                            Padding(padding: EdgeInsets.symmetric(vertical: 8.0),),
                            _startDateField,
                            Padding(padding: EdgeInsets.symmetric(vertical: 8.0),),
                            _startTimeField,
                            Padding(padding: EdgeInsets.symmetric(vertical: 8.0),),
                            _endDateField,
                            Padding(padding: EdgeInsets.symmetric(vertical: 8.0),),
                            _endTimeField,
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
                )
            )
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
            padding: const EdgeInsets.only(left: 6, right: 6, bottom: 24),
            child: Visibility(
              visible: visible_floatButtom,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Visibility(
                    visible: !globals.courseunit_isEditing,
                    child: FloatingActionButton.extended(
                      heroTag: 'FAB1',
                      onPressed: () async {
                        ResetForm_Checker();
                      },
                      label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_UploadFormReset],
                      style: TextStyle(fontSize: globals.fontSize_Normal),),
                      icon: Icon(Icons.clear),
                      backgroundColor: Colors.red,
                    ),
                  ),
                  FloatingActionButton.extended(
                    heroTag: 'FAB2',
                    onPressed: () async {
                      PreviewCourse();
                    },
                    label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Preview],
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