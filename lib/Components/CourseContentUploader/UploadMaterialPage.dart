import 'dart:io';

import 'package:flutter/rendering.dart';
import 'FilesSelecter.dart';

import '../../Helper/ComponentsList.dart';
import '../../Helper/global_setting.dart' as globals;
import 'package:intl/intl.dart';
import 'package:smeapp/Helper/Localizations.dart';

class UploadMaterialPage extends StatefulWidget {
  UploadMaterialPage({Key key}) : super(key: key);
  UploadMaterialPage_State createState() => UploadMaterialPage_State();
}

class UploadMaterialPage_State extends State {
  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "", dialog_Msg_Title = "";
  Image dialog_image;

  // Boolean variable for CircularProgressIndicator.
  bool visible_Loading = false;
  // Boolean variable for SignUp Form.
  bool visible_UploadForm = true;
  // Boolean variable for Floating Button.
  bool visible_floatButtom = false;

  final _newTitleController = TextEditingController();
  final _newDescController = TextEditingController();
  //final _newRequiredTimeController = TextEditingController();
  final _newStartDateController = TextEditingController();
  final _newEndDateController = TextEditingController();
  final _newStartTimeController = TextEditingController();
  final _newEndTimeController = TextEditingController();

  // Files Variables
  List<Widget> fileListThumb;
  List<File> fileList = new List<File>();

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
    // region UI - Field Labels
    final label_startDate = Padding(
      padding: EdgeInsets.only(left: 20,right: 0),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_StartDateLabelText],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Big,
            color: appPrimaryColor),
      ),
    );
    final label_startTime = Padding(
      padding: EdgeInsets.only(left: 20,right: 0),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_StartTimeLabelText],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Big,
            color: appPrimaryColor),
      ),
    );
    final label_endDate = Padding(
      padding: EdgeInsets.only(left: 20,right: 0),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_EndDateLabelText],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Big,
            color: appPrimaryColor),
      ),
    );
    final label_endTime = Padding(
      padding: EdgeInsets.only(left: 20,right: 0),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_EndTimeLabelText],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Big,
            color: appPrimaryColor),
      ),
    );
    final label_title = Padding(
      padding: EdgeInsets.only(left: 20,right: 0),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_TitleLabelText],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Big,
            color: appPrimaryColor),
      ),
    );
    final label_desc = Padding(
      padding: EdgeInsets.only(left: 20,right: 0),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_DescLabelText],
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
                      if(globals.material_isEditing)
                        globals.editMaterial_Title = text;
                      else
                        globals.newMaterial_Title = text;
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
        ) ,
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
                      if(globals.material_isEditing)
                        globals.editMaterial_Desc = text;
                      else
                        globals.newMaterial_Desc = text;
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
                Expanded(
                  child: TextFormField(
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
                                if(globals.material_isEditing) {
                                  globals.editMaterial_SDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                  _newStartDateController.text = globals.editMaterial_SDate;
                                } else {
                                  globals.newMaterial_SDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                  _newStartDateController.text = globals.newMaterial_SDate;
                                }
                              }, onConfirm: (date) {
                                if(globals.material_isEditing) {
                                  globals.editMaterial_SDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                  _newStartDateController.text = globals.editMaterial_SDate;
                                } else {
                                  globals.newMaterial_SDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                  _newStartDateController.text = globals.newMaterial_SDate;
                                }
                              }, currentTime: _currentDateTime, locale: LocaleType.zh);
                          break;
                        case Localizations_Language_Identifier.Language_Eng:
                          DatePicker.showDatePicker(context,
                              showTitleActions: true,
                              //minTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                              maxTime: new DateTime(DateTime.now().year + 99, DateTime.december , 31), onChanged: (date) {
                                if(globals.material_isEditing) {
                                  globals.editMaterial_SDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                  _newStartDateController.text = globals.editMaterial_SDate;
                                } else {
                                  globals.newMaterial_SDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                  _newStartDateController.text = globals.newMaterial_SDate;
                                }
                              }, onConfirm: (date) {
                                if(globals.material_isEditing) {
                                  globals.editMaterial_SDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                  _newStartDateController.text = globals.editMaterial_SDate;
                                } else {
                                  globals.newMaterial_SDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                  _newStartDateController.text = globals.newMaterial_SDate;
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
                  ),
                )
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
                                if(globals.material_isEditing) {
                                  globals.editMaterial_STime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newStartTimeController.text = globals.editMaterial_STime;
                                } else {
                                  globals.newMaterial_STime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newStartTimeController.text = globals.newMaterial_STime;
                                }
                              }, onConfirm: (time) {
                                if(globals.material_isEditing) {
                                  globals.editMaterial_STime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newStartTimeController.text = globals.editMaterial_STime;
                                } else {
                                  globals.newMaterial_STime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newStartTimeController.text = globals.newMaterial_STime;
                                }
                              }, currentTime: _currentDateTime, locale: LocaleType.zh);
                          break;
                        case Localizations_Language_Identifier.Language_Eng:
                          DatePicker.showTimePicker(context,
                              showTitleActions: true,
                              onChanged: (time) {
                                if(globals.material_isEditing) {
                                  globals.editMaterial_STime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newStartTimeController.text = globals.editMaterial_STime;
                                } else {
                                  globals.newMaterial_STime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newStartTimeController.text = globals.newMaterial_STime;
                                }
                              }, onConfirm: (time) {
                                if(globals.material_isEditing) {
                                  globals.editMaterial_STime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newStartTimeController.text = globals.editMaterial_STime;
                                } else {
                                  globals.newMaterial_STime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newStartTimeController.text = globals.newMaterial_STime;
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
                                if(globals.material_isEditing) {
                                  globals.editMaterial_EDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                  _newEndDateController.text = globals.editMaterial_EDate;
                                } else {
                                  globals.newMaterial_EDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                  _newEndDateController.text = globals.newMaterial_EDate;
                                }
                              }, onConfirm: (date) {
                                if(globals.material_isEditing) {
                                  globals.editMaterial_EDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                  _newEndDateController.text = globals.editMaterial_EDate;
                                } else {
                                  globals.newMaterial_EDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                  _newEndDateController.text = globals.newMaterial_EDate;
                                }
                              }, currentTime: _currentDateTime, locale: LocaleType.zh);
                          break;
                        case Localizations_Language_Identifier.Language_Eng:
                          DatePicker.showDatePicker(context,
                              showTitleActions: true,
                              //minTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                              maxTime: new DateTime(DateTime.now().year + 99, DateTime.december , 31), onChanged: (date) {
                                if(globals.material_isEditing) {
                                  globals.editMaterial_EDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                  _newEndDateController.text = globals.editMaterial_EDate;
                                } else {
                                  globals.newMaterial_EDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                  _newEndDateController.text = globals.newMaterial_EDate;
                                }
                              }, onConfirm: (date) {
                                if(globals.material_isEditing) {
                                  globals.editMaterial_EDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                  _newEndDateController.text = globals.editMaterial_EDate;
                                } else {
                                  globals.newMaterial_EDate = DateFormat('yyyy-MM-dd').format(date).toString();
                                  _newEndDateController.text = globals.newMaterial_EDate;
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
                                if(globals.material_isEditing) {
                                  globals.editMaterial_ETime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newEndTimeController.text = globals.editMaterial_ETime;
                                } else {
                                  globals.newMaterial_ETime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newEndTimeController.text = globals.newMaterial_ETime;
                                }
                              }, onConfirm: (time) {
                                if(globals.material_isEditing) {
                                  globals.editMaterial_ETime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newEndTimeController.text = globals.editMaterial_ETime;
                                } else {
                                  globals.newMaterial_ETime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newEndTimeController.text = globals.newMaterial_ETime;
                                }
                              }, currentTime: _currentDateTime, locale: LocaleType.zh);
                          break;
                        case Localizations_Language_Identifier.Language_Eng:
                          DatePicker.showTimePicker(context,
                              showTitleActions: true,
                              onChanged: (time) {
                                if(globals.material_isEditing) {
                                  globals.editMaterial_ETime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newEndTimeController.text = globals.editMaterial_ETime;
                                } else {
                                  globals.newMaterial_ETime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newEndTimeController.text = globals.newMaterial_ETime;
                                }
                              }, onConfirm: (time) {
                                if(globals.material_isEditing) {
                                  globals.editMaterial_ETime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newEndTimeController.text = globals.editMaterial_ETime;
                                } else {
                                  globals.newMaterial_ETime = DateFormat('HH:mm:ss').format(time).toString();
                                  _newEndTimeController.text = globals.newMaterial_ETime;
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
    // endregion

    // Reset Form Confirm Function
    void resetForm() async{
      globals.newMaterial_Title = null;
      globals.newMaterial_Desc = null;
      //globals.newMaterial_RequiredTime = null;
      globals.newMaterial_SDate = null;
      globals.newMaterial_STime = null;
      globals.newMaterial_EDate = null;
      globals.newMaterial_ETime = null;
      globals.newMaterial_FullStartTime = null;
      globals.newMaterial_FullEndTime = null;
      globals.newMaterial_FilesUploader_fileList = new List<File>();
      Navigator.of(context).pop();
      Navigator.of(context).push(globals.gotoPage(UploadMaterialPage(),Duration(seconds: 0, milliseconds: 0)));
    }

    // Select Reset Form Button
    /*
    final button_ResetForm = Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(
          width: double.infinity,
          child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            onPressed: () => {
              _dialogStatus = dialog_Status.Warning,
              dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_UploadFormReset_Warning],
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) => CustomDialog_Selection(
                  dialog_type: _dialogStatus,
                  description: dialog_Msg,
                  callback_Confirm: resetForm
                ),
              )
            },
            color: Colors.redAccent,
            child: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_UploadFormReset], style: TextStyle(color: Colors.white)),
          ),
        )
    );
    */

    // Upload Documents Button
    /*
    final button_UploadDocument = Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(
          width: double.infinity,
          child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            onPressed: () => {},
            color: appGreyColor,
            child: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_UploadAttachment], style: TextStyle(color: Colors.white)),
          ),
        )
    );
    */

    void ResetForm_Checker() => {
      _dialogStatus = dialog_Status.Warning,
      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_UploadFormReset_Warning],
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
    void UploadDocument() => {
      if(!(_newDescController.text.isEmpty || _newTitleController.text.isEmpty || //_newRequiredTimeController.text.isEmpty ||
          _newStartDateController.text.isEmpty || _newStartTimeController.text.isEmpty ||
          _newEndDateController.text.isEmpty || _newEndTimeController.text.isEmpty)){
        if(!globals.material_isEditing){
          globals.newMaterial_Desc = _newDescController.text,
          globals.newMaterial_Title = _newTitleController.text,
          //globals.newMaterial_RequiredTime = _newRequiredTimeController.text,
          globals.newMaterial_SDate = _newStartDateController.text,
          globals.newMaterial_STime = _newStartTimeController.text,
          globals.newMaterial_EDate = _newEndDateController.text,
          globals.newMaterial_ETime = _newEndTimeController.text,
          globals.newMaterial_FullStartTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(
              DateTime.parse(globals.newMaterial_SDate + " " + globals.newMaterial_STime)
          ),
          globals.newMaterial_FullEndTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(
              DateTime.parse(globals.newMaterial_EDate + " " + globals.newMaterial_ETime)
          ),
          _start = DateTime.parse(globals.newMaterial_FullStartTime),
          _end = DateTime.parse(globals.newMaterial_FullEndTime),
        } else {
          globals.editMaterial_Desc = _newDescController.text,
          globals.editMaterial_Title = _newTitleController.text,
          globals.editMaterial_SDate = _newStartDateController.text,
          globals.editMaterial_STime = _newStartTimeController.text,
          globals.editMaterial_EDate = _newEndDateController.text,
          globals.editMaterial_ETime = _newEndTimeController.text,
          globals.editMaterial_FullStartTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(
              DateTime.parse(globals.editMaterial_SDate + " " + globals.editMaterial_STime)
          ),
          globals.editMaterial_FullEndTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(
              DateTime.parse(globals.editMaterial_EDate + " " + globals.editMaterial_ETime)
          ),
          _start = DateTime.parse(globals.editMaterial_FullStartTime),
          _end = DateTime.parse(globals.editMaterial_FullEndTime),
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
        } else
          {
            globals.fileListReloaded = false,
            Navigator.of(context).push(globals.gotoPage(globals.CourseContentEditor_AttachmentSelector, Duration(seconds: 0, milliseconds: 500))),
          }
      } else {
        _dialogStatus = dialog_Status.Error,
        dialog_Msg_Title = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Tips_Error],
        dialog_image = tips_error_Icon,
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
    if(!globals.material_isEditing) {
      _appbarTitle = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_NewLearningMaterial];
      if (globals.newMaterial_Title?.isNotEmpty ?? false) _newTitleController.text = globals.newMaterial_Title;
      if (globals.newMaterial_Desc?.isNotEmpty ?? false) _newDescController.text = globals.newMaterial_Desc;
      //if(globals.newMaterial_RequiredTime?.isNotEmpty ?? false) _newRequiredTimeController.text = globals.newMaterial_RequiredTime;
      if (globals.newMaterial_SDate?.isNotEmpty ?? false) _newStartDateController.text = globals.newMaterial_SDate;
      if (globals.newMaterial_STime?.isNotEmpty ?? false) _newStartTimeController.text = globals.newMaterial_STime;
      if (globals.newMaterial_EDate?.isNotEmpty ?? false) _newEndDateController.text = globals.newMaterial_EDate;
      if (globals.newMaterial_ETime?.isNotEmpty ?? false) _newEndTimeController.text = globals.newMaterial_ETime;
    } else {
      _appbarTitle = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_ContentPage_Editor_AppBarTitle];
      if(globals.editMaterial_Title?.isNotEmpty ?? false) _newTitleController.text = globals.editMaterial_Title;
      if(globals.editMaterial_Desc?.isNotEmpty ?? false) _newDescController.text = globals.editMaterial_Desc;
      if(globals.editMaterial_SDate?.isNotEmpty ?? false) _newStartDateController.text = globals.editMaterial_SDate;
      if(globals.editMaterial_STime?.isNotEmpty ?? false) _newStartTimeController.text = globals.editMaterial_STime;
      if(globals.editMaterial_EDate?.isNotEmpty ?? false) _newEndDateController.text = globals.editMaterial_EDate;
      if(globals.editMaterial_ETime?.isNotEmpty ?? false) _newEndTimeController.text = globals.editMaterial_ETime;
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
                  visible: !globals.material_isEditing,
                  child: FloatingActionButton.extended(
                    heroTag: 'FAB1',
                    onPressed: () async {
                      ResetForm_Checker();
                    },
                    label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_UploadFormReset],
                    style: TextStyle(fontSize: globals.fontSize_Small),),
                    icon: Icon(Icons.clear),
                    backgroundColor: Colors.red,
                  ),
                ),
                FloatingActionButton.extended(
                  heroTag: 'FAB2',
                  onPressed: () async {
                    UploadDocument();
                  },
                  label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_UploadAttachment],
                  style: TextStyle(fontSize: globals.fontSize_Small),),
                  icon: Icon(Icons.attachment),
                  backgroundColor: appTitleBarColor,
                )
              ],
            ),
          )
        )
    );
  }

}