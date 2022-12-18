import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:smeapp/Components/CourseCreator/PreviewCoursePage.dart';
import 'package:smeapp/Components/Survey/PreviewSurveyPage.dart';
import 'package:smeapp/Helper/JsonItemConvertor.dart';
import '../../Helper/ComponentsList.dart';
import '../../Helper/global_setting.dart' as globals;
import 'package:intl/intl.dart';
import 'package:smeapp/Helper/Localizations.dart';

class SurveyEditor extends StatefulWidget {
  SurveyEditor(){
    if(globals.survey_isEditing){

    } else {
      globals.selected_group = [];
    }
  }
  SurveyEditor_State createState() => SurveyEditor_State();
}

class SurveyEditor_State extends State {
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
  final _newLinkController = TextEditingController();
  final _newStartDateController = TextEditingController();
  final _newEndDateController = TextEditingController();
  final _newStartTimeController = TextEditingController();
  final _newEndTimeController = TextEditingController();
  final _group_add_name_controller = TextEditingController();

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
  Widget build(BuildContext maincontext) {

    // region UI - Field Labels
    final label_startDate = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_Editor_StartDate],
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
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_Editor_StartTime],
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
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_Editor_EndDate],
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
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_Editor_EndTime],
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
    // endregion

    final group_add_dialog = Container(
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 0,right: 0, bottom: 10),
                child: Text(
                  Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseCreator_Creator_AddNewGroup],
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: globals.fontSize_Big,
                      color: appPrimaryColor),
                ),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54)
                    ),
                    child: TextFormField(
                      onTap: () {

                      },
                      textAlign: TextAlign.left,
                      controller: _group_add_name_controller,
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                      style: TextStyle(
                        color: appPrimaryColor,
                        fontSize: globals.fontSize_Middle,
                      ),
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
              )
            ],
          )
        ],
      ),
    );


    final _items = globals.groupList
        .map((group) => MultiSelectItem<GroupListItem>(group, group.groupName + " (" + group.userCount.toString() + ")"))
        .toList();

    // region UI - Form Input Fields
    final _groupField = InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black54)
        ),
        child: Column(
          children: <Widget>[
            Row(children: [
              Expanded(
                child: MultiSelectDialogField(
                  initialValue: globals.selected_group,
                  buttonText: Text(
                    Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseCreator_Creator_Groups],
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: globals.fontSize_Big,
                        color: appPrimaryColor),
                  ),
                  title: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseCreator_Creator_Groups]),
                  items: _items,
                  listType: MultiSelectListType.CHIP,
                  selectedColor: Colors.blueAccent,
                  unselectedColor: Colors.grey,
                  selectedItemsTextStyle: TextStyle(color: Colors.white),
                  itemsTextStyle: TextStyle(color: Colors.white),
                  confirmText: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Confirm]),
                  cancelText: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Cancel]),
                  onConfirm: (values){
                    setState(() {
                      globals.selected_group = values;
                    });
                  },
                  chipDisplay: MultiSelectChipDisplay(
                    chipColor: Colors.blueAccent,
                    textStyle: TextStyle(color: Colors.white),
                    items: globals.selected_group.map((e) => MultiSelectItem(e, e.groupName + "(" + e.userCount.toString() + ")")).toList(),
                    onTap: (value) {
                      T cast<T>(x) => x is T ? x : null;
                      GroupListItem _selected = cast(value);
                      final widget_userlist = Container(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 10, right: 10),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: FlatButton.icon(
                                          icon: Icon(Icons.settings),
                                          label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.GroupUser_Setting],
                                            style: TextStyle(fontSize: globals.fontSize_Normal),),
                                          textColor: Colors.white,
                                          color: Colors.lightGreen,
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            if(await(fetchUsers(maincontext))){
                                              final _users = globals.userList
                                                  .map((user) => MultiSelectItem<UserListItem>(user, user.UID + ": " + user.firstName + ', ' + user.lastName,))
                                                  .toList();
                                              //_users.forEach((element) {print(element.value);});
                                              globals.selected_user = [];
                                              _selected.users.forEach((element) {
                                                //print(element.nickName);
                                                if(globals.userList.any((check) => check.UID == element.UID)){
                                                  globals.selected_user.add(globals.userList.firstWhere((user) => user.UID == element.UID));
                                                }
                                              });
                                              //final widget_userselection = ;
                                              showDialog(
                                                  barrierDismissible: false,
                                                  context: maincontext,
                                                  builder: (BuildContext context) {
                                                    return MultiSelectDialog(
                                                      initialValue: globals.selected_user,
                                                      /*
                                                buttonText: Text(
                                                  Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.GroupUser_ListButton],
                                                  textAlign: TextAlign.left,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 18.0,
                                                      color: appPrimaryColor),
                                                ),
                                                */
                                                      title: Text(
                                                          Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.GroupUser_ListTitle_Start] +
                                                              _selected.groupName+
                                                              Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.GroupUser_ListTitle_End]
                                                      ),
                                                      items: _users,
                                                      listType: MultiSelectListType.LIST,
                                                      searchable: true,
                                                      selectedColor: Colors.blueAccent,
                                                      unselectedColor: Colors.grey,
                                                      selectedItemsTextStyle: TextStyle(color: Colors.black),
                                                      itemsTextStyle: TextStyle(color: Colors.black),
                                                      confirmText: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Confirm]),
                                                      cancelText: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Cancel]),
                                                      onConfirm: (users_list) async{
                                                        globals.selected_user = users_list;
                                                        if(await(updateUserGroup(maincontext, _selected.groupName, globals.selected_user))){
                                                          globals.edit_isSurveyDataLoaded = false;
                                                          globals.survey_isEditing = true;
                                                          if(await fetchUserGroup(maincontext, containsAdmin: '0')){
                                                            _dialogStatus = dialog_Status.Success;
                                                            dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.GroupUser_Setting_Upload_Success];
                                                            if(await fetchSurveyData(maincontext, globals.selectedSurvey.surveyID)){
                                                              _dialogStatus = dialog_Status.Success;
                                                              dialog_Msg =
                                                              Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier
                                                                  .GroupUser_Setting_Upload_Success];
                                                              showDialog(
                                                                barrierDismissible: false,
                                                                context: maincontext,
                                                                builder: (BuildContext context) =>
                                                                    CustomDialog_Confirm(
                                                                      dialog_type: _dialogStatus,
                                                                      description: dialog_Msg,
                                                                      callback_Confirm: () => {
                                                                        Navigator.of(maincontext)
                                                                            .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
                                                                        globals.edit_isSurveyDataLoaded = true,
                                                                        Navigator.of(maincontext).push(globals.gotoPage(SurveyEditor(),Duration(seconds: 0, milliseconds: 0))),
                                                                      },
                                                                    ),
                                                              );
                                                            }
                                                          };
                                                        }
                                                      },
                                                    );
                                                  }
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 5, bottom: 20),
                                      child: _selected.users.length > 0 ? ListView.builder(
                                          padding: EdgeInsets.only(left: 10,right: 10),
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          itemCount: _selected.users.length, // number of items in your list
                                          //here the implementation of itemBuilder. take a look at flutter docs to see details
                                          itemBuilder: (BuildContext context, int Itemindex){
                                            return Text(
                                              _selected.users[Itemindex].UID + ": " + _selected.users[Itemindex].firstName + ', ' + _selected.users[Itemindex].lastName,
                                              style: TextStyle(fontSize: globals.fontSize_Big,height: 1.5),);// return your widget
                                          }
                                      ) : Padding(
                                        padding: EdgeInsets.only(left: 10,right: 10),
                                        child: Text(
                                          Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseCreator_Creator_GroupUsers_NULL],
                                          style: TextStyle(fontSize: globals.fontSize_Big,height: 1.5),),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ));
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) =>
                            CustomDialog_Confirm(
                                dialog_type: dialog_Status.Custom,
                                title: _selected.groupName + Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseCreator_Creator_GroupUsers],
                                desc_to_widget: true,
                                desc_widget: widget_userlist,
                                image: Icon(Icons.people)
                            ),
                      );
                    },
                  ),
                ),
              ),
            ],),
            Row(children: [
              Expanded(child:
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: FlatButton.icon(
                    icon: Icon(Icons.group_add),
                    label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseCreator_Creator_AddNewGroup],
                      style: TextStyle(fontSize: globals.fontSize_Normal),),
                    textColor: Colors.white,
                    color: Colors.lightBlue,
                    onPressed: () async => {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) =>
                            CustomDialog_Selection(
                                dialog_type: dialog_Status.Custom,
                                title: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseCreator_Creator_AddNewGroup],
                                callback_Confirm: () async => {
                                  if(_group_add_name_controller.text.isNotEmpty){
                                    if(!globals.groupList.any((element) => element.groupName == _group_add_name_controller.text)){
                                      if(await insertUserGroup(context, _group_add_name_controller.text)){
                                        _dialogStatus = dialog_Status.Success,
                                        dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.GroupUser_Setting_Upload_Success],
                                        showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) =>
                                              CustomDialog_Confirm(
                                                dialog_type: _dialogStatus,
                                                description: dialog_Msg,
                                                callback_Confirm: () async => {
                                                  globals.edit_isSurveyDataLoaded = false,
                                                  globals.survey_isEditing = true,
                                                  if(await fetchUserGroup(context, containsAdmin: '0')){
                                                    if(await fetchSurveyData(context, globals.selectedSurvey.surveyID)){
                                                      Navigator.of(context)
                                                          .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
                                                      globals.edit_isSurveyDataLoaded = true,
                                                      Navigator.of(context).push(globals.gotoPage(SurveyEditor(),Duration(seconds: 0, milliseconds: 0))),
                                                    }
                                                  },
                                                },
                                              ),
                                        ),
                                      },
                                    } else {
                                      _dialogStatus = dialog_Status.Warning,
                                      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.GroupUser_Setting_Upload_NameExits],
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) =>
                                            CustomDialog_Confirm(
                                              dialog_type: _dialogStatus,
                                              description: dialog_Msg,
                                            ),
                                      ),
                                    }
                                  } else {
                                    _dialogStatus = dialog_Status.Warning,
                                    dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.GroupUser_Setting_Upload_NameNull],
                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context) =>
                                          CustomDialog_Confirm(
                                            dialog_type: _dialogStatus,
                                            description: dialog_Msg,
                                          ),
                                    ),
                                  }

                                },
                                desc_to_widget: true,
                                desc_widget: group_add_dialog,
                                image: Icon(Icons.group_add)
                            ),
                      ),
                    },
                  ),
                ),
              )
              )
            ],)
          ],
        ) ,
      ),
    );
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
                    maxLength: 32,
                    maxLines: null,
                    style: TextStyle(
                      color: appPrimaryColor,
                      fontSize: globals.fontSize_Middle,
                    ),
                    onChanged: (text) {
                      if(globals.survey_isEditing)
                        globals.editSurvey_Title = text;
                      else
                        globals.newSurvey_Title = text;
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
                      if(globals.survey_isEditing)
                        globals.editSurvey_Desc = text;
                      else
                        globals.newSurvey_Desc = text;
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
    final _linkField = InkWell(
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
                  child: label_link,
                ))
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    textAlign: TextAlign.right,
                    controller: _newLinkController,
                    keyboardType: TextInputType.multiline,
                    maxLength: null,
                    maxLines: null,
                    style: TextStyle(
                      color: appPrimaryColor,
                      fontSize: globals.fontSize_Middle,
                    ),
                    onChanged: (text) {
                      if(globals.survey_isEditing)
                        globals.editSurvey_URL = text;
                      else
                        globals.newSurvey_URL = text;
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
                                    child: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_Editor_LinkDesc],
                                      style: TextStyle(fontSize: globals.fontSize_Small,color: Colors.black54),)
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
        child: Row(
          children: <Widget>[
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
                            if(globals.survey_isEditing) {
                              globals.editSurvey_SDate = DateFormat('yyyy-MM-dd').format(date).toString();
                              _newStartDateController.text = globals.editSurvey_SDate;
                            } else {
                              globals.newSurvey_SDate = DateFormat('yyyy-MM-dd').format(date).toString();
                              _newStartDateController.text = globals.newSurvey_SDate;
                            }
                          }, onConfirm: (date) {
                            if(globals.survey_isEditing) {
                              globals.editSurvey_SDate = DateFormat('yyyy-MM-dd').format(date).toString();
                              _newStartDateController.text = globals.editSurvey_SDate;
                            } else {
                              globals.newSurvey_SDate = DateFormat('yyyy-MM-dd').format(date).toString();
                              _newStartDateController.text = globals.newSurvey_SDate;
                            }
                          }, currentTime: _currentDateTime, locale: LocaleType.zh);
                      break;
                    case Localizations_Language_Identifier.Language_Eng:
                      DatePicker.showDatePicker(context,
                          showTitleActions: true,
                          //minTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                          maxTime: new DateTime(DateTime.now().year + 99, DateTime.december , 31), onChanged: (date) {
                            if(globals.survey_isEditing) {
                              globals.editSurvey_SDate = DateFormat('yyyy-MM-dd').format(date).toString();
                              _newStartDateController.text = globals.editSurvey_SDate;
                            } else {
                              globals.newSurvey_SDate = DateFormat('yyyy-MM-dd').format(date).toString();
                              _newStartDateController.text = globals.newSurvey_SDate;
                            }
                          }, onConfirm: (date) {
                            if(globals.survey_isEditing) {
                              globals.editSurvey_SDate = DateFormat('yyyy-MM-dd').format(date).toString();
                              _newStartDateController.text = globals.editSurvey_SDate;
                            } else {
                              globals.newSurvey_SDate = DateFormat('yyyy-MM-dd').format(date).toString();
                              _newStartDateController.text = globals.newSurvey_SDate;
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
                                child: Text("")
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
                    prefixIcon: label_startDate,
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
    final _startTimeField = InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black54)
        ),
        child: Row(
          children: <Widget>[
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
                            if(globals.survey_isEditing) {
                              globals.editSurvey_STime = DateFormat('HH:mm:ss').format(time).toString();
                              _newStartTimeController.text = globals.editSurvey_STime;
                            } else {
                              globals.newSurvey_STime = DateFormat('HH:mm:ss').format(time).toString();
                              _newStartTimeController.text = globals.newSurvey_STime;
                            }
                          }, onConfirm: (time) {
                            if(globals.survey_isEditing) {
                              globals.editSurvey_STime = DateFormat('HH:mm:ss').format(time).toString();
                              _newStartTimeController.text = globals.editSurvey_STime;
                            } else {
                              globals.newSurvey_STime = DateFormat('HH:mm:ss').format(time).toString();
                              _newStartTimeController.text = globals.newSurvey_STime;
                            }
                          }, currentTime: _currentDateTime, locale: LocaleType.zh);
                      break;
                    case Localizations_Language_Identifier.Language_Eng:
                      DatePicker.showTimePicker(context,
                          showTitleActions: true,
                          onChanged: (time) {
                            if(globals.survey_isEditing) {
                              globals.editSurvey_STime = DateFormat('HH:mm:ss').format(time).toString();
                              _newStartTimeController.text = globals.editSurvey_STime;
                            } else {
                              globals.newSurvey_STime = DateFormat('HH:mm:ss').format(time).toString();
                              _newStartTimeController.text = globals.newSurvey_STime;
                            }
                          }, onConfirm: (time) {
                            if(globals.survey_isEditing) {
                              globals.editSurvey_STime = DateFormat('HH:mm:ss').format(time).toString();
                              _newStartTimeController.text = globals.editSurvey_STime;
                            } else {
                              globals.newSurvey_STime = DateFormat('HH:mm:ss').format(time).toString();
                              _newStartTimeController.text = globals.newSurvey_STime;
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
                                child: Text("")
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
                    prefixIcon: label_startTime,
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
    final _endDateField = InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black54)
        ),
        child: Row(
          children: <Widget>[
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
                            if(globals.survey_isEditing) {
                              globals.editSurvey_EDate = DateFormat('yyyy-MM-dd').format(date).toString();
                              _newEndDateController.text = globals.editSurvey_EDate;
                            } else {
                              globals.newSurvey_EDate = DateFormat('yyyy-MM-dd').format(date).toString();
                              _newEndDateController.text = globals.newSurvey_EDate;
                            }
                          }, onConfirm: (date) {
                            if(globals.survey_isEditing) {
                              globals.editSurvey_EDate = DateFormat('yyyy-MM-dd').format(date).toString();
                              _newEndDateController.text = globals.editSurvey_EDate;
                            } else {
                              globals.newSurvey_EDate = DateFormat('yyyy-MM-dd').format(date).toString();
                              _newEndDateController.text = globals.newSurvey_EDate;
                            }
                          }, currentTime: _currentDateTime, locale: LocaleType.zh);
                      break;
                    case Localizations_Language_Identifier.Language_Eng:
                      DatePicker.showDatePicker(context,
                          showTitleActions: true,
                          //minTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                          maxTime: new DateTime(DateTime.now().year + 99, DateTime.december , 31), onChanged: (date) {
                            if(globals.survey_isEditing) {
                              globals.editSurvey_EDate = DateFormat('yyyy-MM-dd').format(date).toString();
                              _newEndDateController.text = globals.editSurvey_EDate;
                            } else {
                              globals.newSurvey_EDate = DateFormat('yyyy-MM-dd').format(date).toString();
                              _newEndDateController.text = globals.newSurvey_EDate;
                            }
                          }, onConfirm: (date) {
                            if(globals.survey_isEditing) {
                              globals.editSurvey_EDate = DateFormat('yyyy-MM-dd').format(date).toString();
                              _newEndDateController.text = globals.editSurvey_EDate;
                            } else {
                              globals.newSurvey_EDate = DateFormat('yyyy-MM-dd').format(date).toString();
                              _newEndDateController.text = globals.newSurvey_EDate;
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
                                child: Text("")
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
                    prefixIcon: label_endDate,
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
    final _endTimeField = InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black54)
        ),
        child: Row(
          children: <Widget>[
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
                            if(globals.survey_isEditing) {
                              globals.editSurvey_ETime = DateFormat('HH:mm:ss').format(time).toString();
                              _newEndTimeController.text = globals.editSurvey_ETime;
                            } else {
                              globals.newSurvey_ETime = DateFormat('HH:mm:ss').format(time).toString();
                              _newEndTimeController.text = globals.newSurvey_ETime;
                            }
                          }, onConfirm: (time) {
                            if(globals.survey_isEditing) {
                              globals.editSurvey_ETime = DateFormat('HH:mm:ss').format(time).toString();
                              _newEndTimeController.text = globals.editSurvey_ETime;
                            } else {
                              globals.newSurvey_ETime = DateFormat('HH:mm:ss').format(time).toString();
                              _newEndTimeController.text = globals.newSurvey_ETime;
                            }
                          }, currentTime: _currentDateTime, locale: LocaleType.zh);
                      break;
                    case Localizations_Language_Identifier.Language_Eng:
                      DatePicker.showTimePicker(context,
                          showTitleActions: true,
                          onChanged: (time) {
                            if(globals.survey_isEditing) {
                              globals.editSurvey_ETime = DateFormat('HH:mm:ss').format(time).toString();
                              _newEndTimeController.text = globals.editSurvey_ETime;
                            } else {
                              globals.newSurvey_ETime = DateFormat('HH:mm:ss').format(time).toString();
                              _newEndTimeController.text = globals.newSurvey_ETime;
                            }
                          }, onConfirm: (time) {
                            if(globals.survey_isEditing) {
                              globals.editSurvey_ETime = DateFormat('HH:mm:ss').format(time).toString();
                              _newEndTimeController.text = globals.editSurvey_ETime;
                            } else {
                              globals.newSurvey_ETime = DateFormat('HH:mm:ss').format(time).toString();
                              _newEndTimeController.text = globals.newSurvey_ETime;
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
                                child: Text("")
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
                    prefixIcon: label_endTime,
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
      globals.newSurvey_Title = null;
      globals.newSurvey_URL = null;
      globals.newSurvey_Desc = null;
      globals.newSurvey_SDate = null;
      globals.newSurvey_STime = null;
      globals.newSurvey_EDate = null;
      globals.newSurvey_ETime = null;
      globals.newSurvey_FullStartTime = null;
      globals.newSurvey_FullEndTime = null;
      globals.selected_group = [];
      Navigator.of(context).pop();
      globals.survey_isEditing = false;
      Navigator.of(context).push(globals.gotoPage(SurveyEditor(),Duration(seconds: 0, milliseconds: 0)));
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
    void PreviewSurvey() => {
      if(!(_newDescController.text.isEmpty || _newTitleController.text.isEmpty ||
          _newStartDateController.text.isEmpty || _newStartTimeController.text.isEmpty ||
          _newEndDateController.text.isEmpty || _newEndTimeController.text.isEmpty || _newLinkController.text.isEmpty || globals.selected_group.length == 0)){
        if(!globals.survey_isEditing){
          globals.newSurvey_Group = "",
          for(int i = 0; i < globals.selected_group.length;i++){
            if(i != globals.selected_group.length - 1){
              globals.newSurvey_Group +=
                  globals.selected_group[i].groupName + ",",
            } else {
              globals.newSurvey_Group += globals.selected_group[i].groupName,
            }
          },
          globals.newSurvey_URL = _newLinkController.text,
          globals.newSurvey_Desc = _newDescController.text,
          globals.newSurvey_Title = _newTitleController.text,
          globals.newSurvey_SDate = _newStartDateController.text,
          globals.newSurvey_STime = _newStartTimeController.text,
          globals.newSurvey_EDate = _newEndDateController.text,
          globals.newSurvey_ETime = _newEndTimeController.text,
          globals.newSurvey_FullStartTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(
                  DateTime.parse(globals.newSurvey_SDate + " " + globals.newSurvey_STime)
              ),
          globals.newSurvey_FullEndTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(
                  DateTime.parse(globals.newSurvey_EDate + " " + globals.newSurvey_ETime)
              ),
          _start = DateTime.parse(globals.newSurvey_FullStartTime),
          _end = DateTime.parse(globals.newSurvey_FullEndTime),
        } else {
          globals.editSurvey_Group = "",
          for(int i = 0; i < globals.selected_group.length;i++){
            if(i != globals.selected_group.length - 1){
              globals.editSurvey_Group +=
                  globals.selected_group[i].groupName + ",",
            } else {
              globals.editSurvey_Group += globals.selected_group[i].groupName,
            }
          },
          globals.editSurvey_URL = _newLinkController.text,
          globals.editSurvey_Desc = _newDescController.text,
          globals.editSurvey_Title = _newTitleController.text,
          globals.editSurvey_SDate = _newStartDateController.text,
          globals.editSurvey_STime = _newStartTimeController.text,
          globals.editSurvey_EDate = _newEndDateController.text,
          globals.editSurvey_ETime = _newEndTimeController.text,
          globals.editSurvey_FullStartTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(
              DateTime.parse(globals.editSurvey_SDate + " " + globals.editSurvey_STime)
          ),
          globals.editSurvey_FullEndTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(
              DateTime.parse(globals.editSurvey_EDate + " " + globals.editSurvey_ETime)
          ),
          _start = DateTime.parse(globals.editSurvey_FullStartTime),
          _end = DateTime.parse(globals.editSurvey_FullEndTime),
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
            Navigator.of(context).push(globals.gotoPage(PreviewSurveyPage(),Duration(seconds: 0, milliseconds: 500))),
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
    if(!globals.survey_isEditing) {
      _appbarTitle = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_Editor_Create_AppBarTitle];
      if (globals.newSurvey_Title?.isNotEmpty ?? false) _newTitleController.text = globals.newSurvey_Title;
      if (globals.newSurvey_Desc?.isNotEmpty ?? false) _newDescController.text = globals.newSurvey_Desc;
      if (globals.newSurvey_SDate?.isNotEmpty ?? false) _newStartDateController.text = globals.newSurvey_SDate;
      if (globals.newSurvey_STime?.isNotEmpty ?? false) _newStartTimeController.text = globals.newSurvey_STime;
      if (globals.newSurvey_EDate?.isNotEmpty ?? false) _newEndDateController.text = globals.newSurvey_EDate;
      if (globals.newSurvey_ETime?.isNotEmpty ?? false) _newEndTimeController.text = globals.newSurvey_ETime;
      if (globals.newSurvey_URL?.isNotEmpty ?? false) _newLinkController.text = globals.newSurvey_URL;
    } else {
      _appbarTitle = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_Editor_Edit_AppBarTitle];
      if (globals.editSurvey_Title?.isNotEmpty ?? false) _newTitleController.text = globals.editSurvey_Title;
      if (globals.editSurvey_Desc?.isNotEmpty ?? false) _newDescController.text = globals.editSurvey_Desc;
      if (globals.editSurvey_SDate?.isNotEmpty ?? false) _newStartDateController.text = globals.editSurvey_SDate;
      if (globals.editSurvey_STime?.isNotEmpty ?? false) _newStartTimeController.text = globals.editSurvey_STime;
      if (globals.editSurvey_EDate?.isNotEmpty ?? false) _newEndDateController.text = globals.editSurvey_EDate;
      if (globals.editSurvey_ETime?.isNotEmpty ?? false) _newEndTimeController.text = globals.editSurvey_ETime;
      if (globals.editSurvey_URL?.isNotEmpty ?? false) _newLinkController.text = globals.editSurvey_URL;
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
                            _groupField,
                            Padding(padding: EdgeInsets.symmetric(vertical: 8.0),),
                            _linkField,
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
                    visible: !globals.survey_isEditing,
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
                      PreviewSurvey();
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