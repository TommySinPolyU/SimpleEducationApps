import 'dart:ui';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smeapp/Components/Survey/SurveyEditor.dart';
import 'package:smeapp/Components/Survey/WebBrowser.dart';
import '../../Helper/ComponentsList.dart';
import '../../Helper/global_setting.dart' as globals;
import 'package:smeapp/Helper/Localizations.dart';
import 'package:select_dialog/select_dialog.dart';
import '../../Helper/JsonItemConvertor.dart';
import 'package:http/http.dart' as http;

class SurveyListPage extends StatefulWidget{
  SurveyListPage({Key key}) : super(key: key);
  @override
  SurveyListPage_State createState() => SurveyListPage_State();
}

class SurveyListPage_State extends State<SurveyListPage> {
  @override
  void initState() {
    super.initState();
  }

  void _surveyListReload(List<SurveyListItem> surveylist) async {
    List<Widget> thumbs = new List<Widget>();
    globals.surveyListThumb = new List<Widget>();
    //print("Course List Reload");

    for (int i=0; i < surveylist.length; i++) {
      Color listitemBgColor;
      Color textColor = Colors.black87;
      if(globals.canUpload){
        if(DateTime.now().toUtc().isBefore(surveylist[i].surveyPeriod_End) && surveylist[i].surveyPeriod_Start.isAfter(DateTime.now().toUtc())){
          listitemBgColor = Colors.orange;
        } else if(surveylist[i].surveyPeriod_End.isBefore(DateTime.now().toUtc()) && DateTime.now().toUtc().isAfter(surveylist[i].surveyPeriod_Start)) {
          listitemBgColor = Colors.redAccent;
        } else {
          listitemBgColor = Colors.green;
        }
      } else {
        listitemBgColor = Colors.green;
      }

      //print("Loading Element: " + surveylist[i].surveyName);
      // region Item Output UI Design
      final itemTile = ListTile(
          leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  surveylist[i].surveyID.toString(),
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: globals.fontSize_SubTitle),
                )
              ],
          ),
          title: Text(
            surveylist[i].surveyName,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: globals.fontSize_SubTitle),
          ),
          // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

          subtitle: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.play_arrow, color: Colors.white,),
                  Padding(padding: EdgeInsets.only(right: 5),),
                  Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(
                      surveylist[i].surveyPeriod_Start), style: TextStyle(color: Colors.white))
                ],
              ),
              Row(
                children: <Widget>[
                  Icon(Icons.not_interested, color: Colors.white,),
                  Padding(padding: EdgeInsets.only(right: 5),),
                  Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(
                      surveylist[i].surveyPeriod_End), style: TextStyle(color: Colors.white))
                ],
              )
            ],
          ),

          isThreeLine: true,

          trailing:
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.keyboard_arrow_right, color: Colors.white)
              ],
            ),

      );
      final itemCard = Card(
        elevation: 8.0,
        child: Container(
          decoration: BoxDecoration(color: listitemBgColor),
          child: new GestureDetector(
            onTap: () async => {
              globals.selectedSurvey = surveylist[i],
              // Go To Survey Page
              Navigator.of(context).push(globals.gotoPage(WebBrowser(), Duration(seconds: 0, milliseconds: 500))),
            },
            child: itemTile,
          ),
        ),
      );

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
                                  surveylist[i].surveyName,
                                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: globals.fontSize_SubTitle),
                                ),
                                alignment: Alignment.centerLeft,
                              )
                            ],
                          ),
                          flex: 9,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Icon(Icons.circle, color: listitemBgColor,)
                            ],
                          ),
                          flex: 1,
                        )
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
                            child: FlatButton.icon(
                                onPressed: () => {
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) => CustomDialog_Confirm(
                                      dialog_type: dialog_Status.Custom,
                                      title: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_Editor_Desc],
                                      description: surveylist[i].surveyDesc,
                                      image: Icon(Icons.description),
                                      buttonText: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Close],
                                    ),
                                  )
                                },
                                icon: Icon(Icons.description, color: Colors.black54,),
                                label: Text(
                                  Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_Editor_Desc],
                                  style: TextStyle(color: Colors.black, fontSize: globals.fontSize_Normal),)
                            ),
                          ),
                        ),
                      ],
                    ),
                  // endregion
                  // region View Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FlatButton.icon(
                              onPressed: () => {
                                globals.selectedSurvey = surveylist[i],
                                globals.browser_Title = globals.selectedSurvey.surveyName,
                                globals.browser_url = globals.selectedSurvey.surveyURL,
                                globals.browser_url = globals.browser_url.replaceAll("Data.UID", globals.UserData_UID),
                                globals.browser_url = globals.browser_url.replaceAll("Data.UserName", globals.UserData_username),
                                globals.browser_url = globals.browser_url.replaceAll("Data.RegisCode", globals.UserData_regisCode),
                                //print(globals.browser_url),
                                // Go To Survey Page
                                Navigator.of(context).push(globals.gotoPage(WebBrowser(), Duration(seconds: 0, milliseconds: 500))),
                              },
                              icon: Icon(Icons.remove_red_eye, color: Colors.black54,),
                              label: Text(
                                Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_ListPage_ViewSurvey],
                                style: TextStyle(color: Colors.black, fontSize: globals.fontSize_Normal),)
                          ),
                        ),
                      ),
                    ],
                  ),
                  // endregion
                  // region Administration Function
                  // Edit Survey Button
                  Visibility(
                    visible: globals.canUpload,
                    child: Container(color: Colors.black38, height: 1),
                  ),
                  Visibility(
                    visible: globals.canUpload,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Container(
                                decoration: BoxDecoration(),
                                child: FlatButton.icon(
                                    onPressed: () async => {
                                      globals.survey_isEditing = true,
                                      globals.edit_isSurveyDataLoaded = false,
                                      globals.selectedSurvey = surveylist[i],
                                      if(await fetchUserGroup(context, containsAdmin: "0")){
                                        if(await fetchSurveyData(context, surveylist[i].surveyID)){
                                          globals.editSurvey_Title = globals.selectedSurvey.surveyName,
                                          globals.editSurvey_Desc = globals.selectedSurvey.surveyDesc,
                                          globals.editSurvey_STime = DateFormat('HH:mm:ss').format(globals.selectedSurvey.surveyPeriod_Start),
                                          globals.editSurvey_SDate = DateFormat('yyyy-MM-dd').format(globals.selectedSurvey.surveyPeriod_Start),
                                          globals.editSurvey_ETime = DateFormat('HH:mm:ss').format(globals.selectedSurvey.surveyPeriod_End),
                                          globals.editSurvey_EDate = DateFormat('yyyy-MM-dd').format(globals.selectedSurvey.surveyPeriod_End),
                                          globals.editSurvey_URL = globals.selectedSurvey.surveyURL,
                                          globals.edit_isSurveyDataLoaded = true,
                                            Navigator.of(context).push(globals.gotoPage(SurveyEditor(), Duration(seconds: 0, milliseconds: 500)))
                                        }
                                      }
                                    },
                                    icon: Icon(Icons.edit, color: Colors.black54,),
                                    label: Text(
                                      Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_Editor_Edit_AppBarTitle],
                                      style: TextStyle(color: Colors.black, fontSize: globals.fontSize_Normal),)
                                ),
                              ),
                            )
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: globals.canUpload,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(top: 5,left: 5,right: 5),
                              child: Container(
                                decoration: BoxDecoration(),
                                child: FlatButton.icon(
                                    onPressed: () async => {
                                      globals.survey_isEditing = false,
                                      if(await fetchSurveyData(context, surveylist[i].surveyID)){
                                        globals.newSurvey_Title = surveylist[i].surveyName,
                                        globals.newSurvey_Desc = surveylist[i].surveyDesc,
                                        globals.newSurvey_STime = DateFormat('HH:mm:ss').format(surveylist[i].surveyPeriod_Start),
                                        globals.newSurvey_SDate = DateFormat('yyyy-MM-dd').format(surveylist[i].surveyPeriod_Start),
                                        globals.newSurvey_ETime = DateFormat('HH:mm:ss').format(surveylist[i].surveyPeriod_End),
                                        globals.newSurvey_EDate = DateFormat('yyyy-MM-dd').format(surveylist[i].surveyPeriod_End),
                                        Navigator.of(context).push(globals.gotoPage(SurveyEditor(),Duration(seconds: 0, milliseconds: 500))),
                                      }
                                    },
                                    icon: Icon(Icons.copy, color: Colors.black54,),
                                    label: Text(
                                      Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_ListPage_DuplicateDetails],
                                      style: TextStyle(color: Colors.black, fontSize: globals.fontSize_Normal),)
                                ),
                              ),
                            )
                        ),
                      ],
                    ),
                  ),
                  // Delete Survey Button
                  Visibility(
                    visible: globals.canUpload,
                    child: Container(color: Colors.black38, height: 1),
                  ),
                  Visibility(
                    visible: globals.canUpload,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Container(
                                decoration: BoxDecoration(color: Colors.redAccent),
                                child: FlatButton.icon(
                                    onPressed: () => {
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) => CustomDialog_Selection(
                                          dialog_type: dialog_Status.Warning,
                                          description:
                                          Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_ListPage_DeleteSurvey_Warning_Opening] +
                                              surveylist[i].surveyName +
                                              Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_ListPage_DeleteSurvey_Warning_Ending],
                                          callback_Confirm: () => {
                                            Navigator.of(context).pop(),
                                            _removeSurvey(surveylist[i])
                                          },
                                        ),
                                      )
                                    },
                                    icon: Icon(Icons.delete_forever, color: Colors.white,),
                                    label: Text(
                                      Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_ListPage_DeleteSurvey],
                                      style: TextStyle(color: Colors.white, fontSize: globals.fontSize_Normal),)
                                ),
                              ),
                            )
                        ),
                      ],
                    ),
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
      globals.surveyListThumb = thumbs;
    });
    globals.surveyListReloaded = true;
  }

  void _removeSurvey(SurveyListItem survey) async {
    // Dialog Information
    dialog_Status _dialogStatus = dialog_Status.Error;
    String dialog_Msg = "";
    final remove_data = {'SurveyID': survey.surveyID};
    try {
      // Call Web API and try to get a result from Server
      var response_code = await http.post(
          DeleteSurvey_URL, body: json.encode(remove_data)).timeout(
          Duration(seconds: Connection_Timeout_TimeLimit));

      // Getting Server response into variable.
      Map<String, dynamic> response_code_JSON = jsonDecode(response_code.body);

      if(response_code.statusCode == 200) {
        // There are no any error in login procedure.
        //debugPrint(response_code.body);
        if(response_code_JSON['StatusCode'] == 1000){
          _dialogStatus = dialog_Status.Success;
          dialog_Msg = survey.surveyName + Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_ListPage_DeleteSurvey_Success];
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) => CustomDialog_Confirm(
              dialog_type: _dialogStatus,
              description: dialog_Msg,
              callback_Confirm: () async => {
                globals.surveyListReloaded = false,
                if(await fetchSurvey(context, isAdminCheck: 'true')){
                  globals.survey_list_filter_option = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.StatusFilter_All],
                  Navigator.of(context)
                      .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
                  Navigator.of(context).push(globals.gotoPage(globals.SurveyList_Page, Duration(seconds: 0, milliseconds: 0))),
                }
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

  @override
  Widget build(BuildContext context) {

    if(globals.surveyListReloaded != true) {
      //print("call Reload");
      _surveyListReload(globals.surveyList);
    }

    List<String> _filterSelection;
    if(globals.CurrentLang == Localizations_Language_Identifier.Language_Eng){
      _filterSelection = Course_Filter;
    } else if(globals.CurrentLang == Localizations_Language_Identifier.Language_TC){
      _filterSelection = Course_Filter_TC;
    }

    String _selected = globals.survey_list_filter_option;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_ListPage_AppBarTitle],
          style: TextStyle(fontSize: globals.fontSize_Title),),
          centerTitle: true,
          actions: <Widget>[
            FlatButton(
              onPressed: () async => {
                globals.surveyListReloaded = false,
                if(globals.canUpload){
                  // Fetch Survey
                  if(await fetchSurvey(context,isAdminCheck: 'true')){
                    globals.survey_list_filter_option = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.StatusFilter_All],
                    Navigator.of(context)
                        .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
                    Navigator.of(context).push(globals.gotoPage(globals.SurveyList_Page, Duration(seconds: 0, milliseconds: 0))),
                  }
                } else {
                    if(await fetchSurvey(context, queryparam: "isOpening")){
                      globals.survey_list_filter_option = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.StatusFilter_Opening],
                      Navigator.of(context)
                          .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
                      Navigator.of(context).push(globals.gotoPage(globals.SurveyList_Page, Duration(seconds: 0, milliseconds: 0))),
                    }
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
                  child: Padding(
                    padding: EdgeInsets.only(top:10),
                    child: ButtonTheme(
                      minWidth: 300.0,
                      height: 40.0,
                      child: FlatButton.icon(
                        icon: Icon(Icons.build),
                        label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_ListPage_StatusFilter] + ": " + globals.survey_list_filter_option,
                        style: TextStyle(fontSize: globals.fontSize_Big),),
                        textColor: Colors.white,
                        color: Colors.redAccent,
                        onPressed: () =>  {
                          SelectDialog.showModal<String>(
                            context,
                            label: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_ListPage_StatusFilter],
                            selectedValue: _selected,
                            items: _filterSelection,
                            showSearchBox: false,
                            onChange: (String selected) async => {
                              globals.surveyListReloaded = false,
                              if(selected == _filterSelection[1]){
                                // Fetch Survey isOpening
                                if(await fetchSurvey(context, queryparam: "isOpening")){
                                  globals.survey_list_filter_option = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.StatusFilter_Opening],
                                  Navigator.of(context)
                                      .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
                                  Navigator.of(context).push(globals.gotoPage(globals.SurveyList_Page, Duration(seconds: 0, milliseconds: 0))),
                                }
                              } else if(selected == _filterSelection[3]) {
                                // Fetch Survey isExpired
                                if(await fetchSurvey(context, queryparam: "isExpired")){
                                  globals.survey_list_filter_option = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.StatusFilter_Expired],
                                  Navigator.of(context)
                                      .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
                                  Navigator.of(context).push(globals.gotoPage(globals.SurveyList_Page, Duration(seconds: 0, milliseconds: 0))),
                                }
                              } else if(selected == _filterSelection[2]){
                                // Fetch Survey isComingSoon
                                if(await fetchSurvey(context, queryparam: "isComingSoon")){
                                  globals.survey_list_filter_option = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.StatusFilter_Coming],
                                  Navigator.of(context)
                                      .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
                                  Navigator.of(context).push(globals.gotoPage(globals.SurveyList_Page, Duration(seconds: 0, milliseconds: 0))),
                                }
                              } else if(selected == _filterSelection[0]){
                                // Fetch Survey ALL
                                if(await fetchSurvey(context, isAdminCheck: 'true')){
                                  globals.survey_list_filter_option = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.StatusFilter_All],
                                  Navigator.of(context)
                                      .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
                                  Navigator.of(context).push(globals.gotoPage(globals.SurveyList_Page, Duration(seconds: 0, milliseconds: 0))),
                                }
                              }
                            },
                          )
                        },
                      ),
                    ),
                  ),
                ),
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
                                icon: Icon(Icons.add),
                                label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_Editor_Create_AppBarTitle],
                                style: TextStyle(fontSize: globals.fontSize_Big),),
                                textColor: Colors.white,
                                color: Colors.lightBlue,
                                onPressed: () async => {
                                  globals.survey_isEditing = false,
                                  globals.edit_isSurveyDataLoaded = false,
                                  if(await fetchUserGroup(context, containsAdmin: "0")){
                                    Navigator.of(context).push(globals.gotoPage(SurveyEditor(), Duration(seconds: 0, milliseconds: 500)))
                                  }
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
                        itemCount: globals.surveyListThumb.length, // number of items in your list
                        //here the implementation of itemBuilder. take a look at flutter docs to see details
                        itemBuilder: (BuildContext context, int Itemindex){
                          return globals.surveyListThumb[Itemindex]; // return your widget
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