import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Helper/ComponentsList.dart';
import '../../Helper/global_setting.dart' as globals;
import 'package:smeapp/Helper/Localizations.dart';
import 'package:smeapp/Helper/JsonItemConvertor.dart';
import 'package:http/http.dart' as http;

class UserGroupManagerPage extends StatefulWidget{
  UserGroupManagerPage({Key key}) : super(key: key);
  @override
  UserGroupManagerPage_State createState() => UserGroupManagerPage_State();
}

class UserGroupManagerPage_State extends State<UserGroupManagerPage> {
  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "";

  @override
  void initState() {
    super.initState();
  }

  void _removeUserGroup(GroupListItem group) async {
    // Dialog Information
    dialog_Status _dialogStatus = dialog_Status.Error;
    String dialog_Msg = "";
    final remove_data = {'GroupID': group.groupID};
    try {
      // Call Web API and try to get a result from Server
      var response_code = await http.post(
          DeleteGroup_URL, body: json.encode(remove_data)).timeout(
          Duration(seconds: Connection_Timeout_TimeLimit));

      // Getting Server response into variable.
      Map<String, dynamic> response_code_JSON = jsonDecode(response_code.body);

      if(response_code.statusCode == 200) {
        // There are no any error in login procedure.
        //debugPrint(response_code.body);
        if(response_code_JSON['StatusCode'] == 1000){
          _dialogStatus = dialog_Status.Success;
          dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_UserGroupSetting_DeleteSuccess] + group.groupName;
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) => CustomDialog_Confirm(
              dialog_type: _dialogStatus,
              description: dialog_Msg,
              callback_Confirm: () async => {
                if(await fetchUserGroup(context, containsAdmin: '0')){
                  globals.groupListReloaded = false,
                  Navigator.of(context)
                      .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
                  Navigator.of(context).push(globals.gotoPage(UserGroupManagerPage(),Duration(seconds: 0, milliseconds: 0))),
                },
              },
            ),
          );
        }
      }
    } on TimeoutException catch (e) {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
    } on Error catch (_) {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error];
    } on SocketException catch (_) {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error];
    } on FormatException catch(_) {
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error_FormatException];
    }
  }

  final _group_add_name_controller = TextEditingController();

  void _userGroupListReload(List<GroupListItem> _groupList, {bool afterupdated = false}) async {
    List<Widget> thumbs = new List<Widget>();
    globals.groupListThumb = new List<Widget>();
    //print("User Group List Reload");
    SharedPreferences prefs = await SharedPreferences.getInstance();

    for (int i=0; i < _groupList.length; i++) {
      Color listitemBgColor = Colors.white;
      Color textColor = Colors.black87;

      final widget_userlist = Container(
        child: Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 5, bottom: 20),
                      child: _groupList[i].users.length > 0 ? ListView.builder(
                          padding: EdgeInsets.only(left: 10,right: 10),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: _groupList[i].users.length, // number of items in your list
                          //here the implementation of itemBuilder. take a look at flutter docs to see details
                          itemBuilder: (BuildContext context, int Itemindex){
                            return Text(
                              _groupList[i].users[Itemindex].UID + ": " + _groupList[i].users[Itemindex].firstName + ', ' + _groupList[i].users[Itemindex].lastName,
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
          ),
        ),
      );

      // region Item Output UI Design
      final itemCard_new = Card(
        elevation: 8.0,
        child: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: Container(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // region Title Row
                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Align(
                                child: Text(
                                  _groupList[i].groupName,
                                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: globals.fontSize_SubTitle),
                                ),
                                alignment: Alignment.centerLeft,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // endregion
                  Container(color: Colors.black38, height: 1),

                  // region Description Button
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
                                            child: Text(
                                                Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.GroupUser_List_UsersCount_Title] + _groupList[i].userCount.toString(),
                                            style: TextStyle(fontSize: globals.fontSize_Middle,color: Colors.black54),),
                                          ),
                                        ),
                                      ],
                                    ),
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
                                                  if(await(fetchUsers(context))){
                                                    final _users = globals.userList
                                                        .map((user) => MultiSelectItem<UserListItem>(user, user.UID + ": " + user.firstName + ', ' + user.lastName,))
                                                        .toList();
                                                    //_users.forEach((element) {print(element.value);});
                                                    globals.selected_user = [];
                                                    _groupList[i].users.forEach((element) {
                                                      //print(element.nickName);
                                                      if(globals.userList.any((check) => check.UID == element.UID)){
                                                        globals.selected_user.add(globals.userList.firstWhere((user) => user.UID == element.UID));
                                                      }
                                                    });
                                                    //final widget_userselection = ;
                                                    showDialog(
                                                        barrierDismissible: false,
                                                        context: context,
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
                                                                    _groupList[i].groupName+
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
                                                              if(await(updateUserGroup(context, _groupList[i].groupName, globals.selected_user))){
                                                                if(await fetchUserGroup(context, containsAdmin: "0")){
                                                                  _dialogStatus = dialog_Status.Success;
                                                                  dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.GroupUser_Setting_Upload_Success];
                                                                  globals.groupListReloaded = false;
                                                                  _userGroupListReload(globals.groupList, afterupdated: true);
                                                                }
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
                                    /*
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 5, bottom: 20),
                                            child: _groupList[i].users.length > 0 ? ListView.builder(
                                                padding: EdgeInsets.only(left: 10,right: 10),
                                                scrollDirection: Axis.vertical,
                                                shrinkWrap: true,
                                                itemCount: _groupList[i].users.length, // number of items in your list
                                                //here the implementation of itemBuilder. take a look at flutter docs to see details
                                                itemBuilder: (BuildContext context, int Itemindex){
                                                  return Text(
                                                    _groupList[i].users[Itemindex].UID + ": " + _groupList[i].users[Itemindex].firstName + ', ' + _groupList[i].users[Itemindex].lastName,
                                                    style: TextStyle(fontSize: 18,height: 1.5),);// return your widget
                                                }
                                            ) : Padding(
                                              padding: EdgeInsets.only(left: 10,right: 10),
                                              child: Text(
                                                Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseCreator_Creator_GroupUsers_NULL],
                                                style: TextStyle(fontSize: 18,height: 1.5),),
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                    */
                                  ],
                                ))
                          ),
                        ),
                      ],
                    ),
                  // endregion
                  // region View User List Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FlatButton.icon(
                              onPressed: () => {
                                showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (BuildContext context) => CustomDialog_Confirm(
                                      dialog_type: dialog_Status.Custom,
                                      title: _groupList[i].groupName + Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseCreator_Creator_GroupUsers],
                                      desc_to_widget: true,
                                      desc_widget: widget_userlist,
                                      image: Icon(Icons.people)
                                  ),
                                )
                              },
                              icon: Icon(Icons.assignment_ind, color: Colors.black54,),
                              label: Text(
                                Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_UserGroupSetting_ViewUsers],
                                style: TextStyle(color: Colors.black),)
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FlatButton.icon(
                              onPressed: () => {
                                showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (BuildContext context) => CustomDialog_Selection(
                                    dialog_type: dialog_Status.Warning,
                                    description:
                                    Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_UserGroupSetting_DeleteWarning] + _groupList[i].groupName,
                                    callback_Confirm: () async => {
                                      Navigator.of(context).pop(),
                                      _removeUserGroup(_groupList[i]),
                                    },
                                  ),
                                )
                              },
                              icon: Icon(Icons.delete_forever, color: Colors.red,),
                              label: Text(
                                Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_UserGroupSetting_Delete],
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),)
                          ),
                        ),
                      ),
                    ],
                  ),
                  // endregion
                ],
              ),
            ),
          ),
        ),
      );

      //endregion
      await thumbs.add(
          Container(
          child: Padding(
            child: itemCard_new,
            padding: EdgeInsets.only(top: 5, bottom: 5),
          )
      ));
    }

    setState(() {
      //print("SetState");
      globals.groupListThumb = thumbs;
    });

    if(afterupdated) {
      _dialogStatus = dialog_Status.Success;
      dialog_Msg =
      Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier
          .GroupUser_Setting_Upload_Success];
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

    globals.groupListReloaded = true;
  }

  @override
  Widget build(BuildContext context) {
    final _items = globals.groupList
        .map((group) => MultiSelectItem<GroupListItem>(group, group.groupName + " (" + group.userCount.toString() + ")"))
        .toList();

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

    if(globals.groupListReloaded != true) {
      //print("call Reload");
      _userGroupListReload(globals.groupList);
    }

    if (globals.groupList.length == 0) {
      globals.groupListThumb = [
        InkWell(
          child: Container(
              alignment: Alignment.center,
              child: Text(Localizations_Text[globals
                  .CurrentLang][Localizations_Text_Identifier
                  .Course_Page_NoAnyContent],
                style: TextStyle(fontSize: globals.fontSize_Normal, fontWeight: FontWeight.bold),)
          ),
        )
      ];
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Profiles_UserGroupSetting_title],
          style: TextStyle(fontSize: globals.fontSize_Title),),
          centerTitle: true,
          actions: <Widget>[
            FlatButton(
              onPressed: () async => {
                  if(await fetchUserGroup(context, containsAdmin: "0")){
                    globals.groupListReloaded = false,
                    _userGroupListReload(globals.groupList),
                  }
                },
              child: Icon(Icons.refresh, color: Colors.white,),)
          ],
        ),
        body: Stack(
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Visibility(
                  visible: globals.canUpload,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[

                      SizedBox(width: 15,),
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: <Widget>[
                            SizedBox(
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
                                                                if(await fetchUserGroup(context, containsAdmin: '0')){
                                                                  globals.groupListReloaded = false,
                                                                  Navigator.of(context)
                                                                      .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
                                                                  Navigator.of(context).push(globals.gotoPage(UserGroupManagerPage(),Duration(seconds: 0, milliseconds: 0))),
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
                            )
                          ],
                        ),
                      ),
                      SizedBox(width: 15,)


                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 20),
                    child: ListView.builder(
                        padding: EdgeInsets.only(left: 10,right: 10),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: globals.groupListThumb.length, // number of items in your list
                        //here the implementation of itemBuilder. take a look at flutter docs to see details
                        itemBuilder: (BuildContext context, int Itemindex){
                          return globals.groupListThumb[Itemindex]; // return your widget
                        }
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
    );
  }
}