import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smeapp/Components/CourseContentUploader/UploadMaterialPage.dart';
import 'package:smeapp/Components/CourseCreator/CourseEditor.dart';
import 'package:smeapp/Components/CourseUnitCreator/CourseUnitEditor.dart';
import 'package:smeapp/CustomWidget/CustomDialog.dart';
import 'package:smeapp/Helper/refresh_page_function.dart';
import '../../Helper/ComponentsList.dart';
import '../../Helper/global_setting.dart' as globals;
import 'dart:io';
import 'package:smeapp/Helper/Localizations.dart';
import '../../Helper/JsonItemConvertor.dart';
import 'package:marquee/marquee.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:http/http.dart' as http;

class CourseUnitListPage extends StatefulWidget{
  CourseUnitListPage({Key key}) : super(key: key);
  @override
  CourseUnitListPage_State createState() => CourseUnitListPage_State();
}

class CourseUnitListPage_State extends State<CourseUnitListPage> {
  @override
  void initState() {
    super.initState();
  }

  void _unitListReload(List<CourseUnitListItem> courseUnitList) async {
    List<Widget> thumbs = new List<Widget>();
    globals.courseUnitListThumb = new List<Widget>();
    //print("Course List Reload");
    for (int i=0; i < courseUnitList.length; i++) {
      Color listitemBgColor;
      Color textColor = Colors.black87;
      if(DateTime.now().toUtc().isBefore(courseUnitList[i].unitPeriod_End) && courseUnitList[i].unitPeriod_Start.isAfter(DateTime.now().toUtc())){
        listitemBgColor = Colors.orange;
      } else if(courseUnitList[i].unitPeriod_End.isBefore(DateTime.now().toUtc()) && DateTime.now().toUtc().isAfter(courseUnitList[i].unitPeriod_Start)) {
        listitemBgColor = Colors.redAccent;
      } else {
        listitemBgColor = Colors.green;
      }
      //print("Loading Element: " + courseUnitList[i].unitName);
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
                                  courseUnitList[i].unitName,
                                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: globals.fontSize_Big,),
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
                  // region View Details and Module Button
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            Visibility(
                              visible: !(courseUnitList[i].attachment_Checked_Count == 0 && courseUnitList[i].unitModuleAttachmentCount == 0) ?
                              courseUnitList[i].attachment_Checked_Count / courseUnitList[i].unitModuleAttachmentCount == 1 :
                              true,
                              child: tips_success_Icon,
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 7,
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: FlatButton.icon(
                                  onPressed: () => {
                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context) => CustomDialog_Confirm(
                                        dialog_type: dialog_Status.Custom,
                                        title: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseUnit_Page_ViewDescription],
                                        description: courseUnitList[i].unitDesc,
                                        image: Icon(Icons.description),
                                        buttonText: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Close],
                                      ),
                                    )
                                  },
                                  icon: Icon(Icons.description, color: Colors.black54,),
                                  label: Text(
                                    Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseUnit_Page_ViewDescription],
                                    style: TextStyle(color: Colors.black, fontSize: globals.fontSize_Normal),)
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FlatButton.icon(
                                  onPressed: () async => {
                                    globals.materialListReloaded = false,
                                    globals.selectedUnitID = courseUnitList[i].unitID,
                                    globals.selectedCourseUnit = courseUnitList[i],
                                    if(await Check_Token(context)){
                                      if(await fetchCourseData(context, globals.selectedCourse.courseID)){
                                        if(await fetchMaterials(context, globals.selectedCourse.courseID, globals.selectedCourseUnit.unitID, queryparam: globals.canUpload ? "All" : "isOpening")){
                                          if(await update_progress(context, progress_Table.Unit, courseID: globals.selectedCourse.courseID, unitID: globals.selectedCourseUnit.unitID)){
                                            if(globals.canUpload||!globals.selectedCourseUnit.skip_moduleSelection || (globals.selectedCourseUnit.skip_moduleSelection && globals.selectedCourseUnit.to_moduleID == null && globals.materialList.length == 0)){
                                              if(globals.canUpload){
                                                globals.materials_list_filter_option = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.StatusFilter_All],
                                              },
                                              globals.moduleSelectionSkipped = false,
                                              Navigator.of(context)
                                                  .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
                                              Navigator.of(context).push(globals.gotoPage(globals.CourseList_Page, Duration(seconds: 0, milliseconds: 0))),
                                              Navigator.of(context).push(globals.gotoPage(globals.CourseUnitList_Page, Duration(seconds: 0, milliseconds: 0))),
                                              Navigator.of(context).push(globals.gotoPage(
                                                  globals.CourseUnit_Page,
                                                  Duration(seconds: 0, milliseconds: 500))).then((value) => Refresh_Page_Manager.refresh_CourseUnitListPage(context)),
                                            } else {
                                              globals.moduleSelectionSkipped = true,
                                              globals.materialsReloaded = false,
                                              if(globals.selectedCourseUnit.to_moduleID != null){
                                                globals.selectedMaterial = globals.materialList.firstWhere((element) => element.materialID == int.parse(globals.selectedCourseUnit.to_moduleID))
                                              } else {
                                                globals.selectedMaterial = globals.materialList[0]
                                              },
                                              globals.selectedMaterialID = globals.selectedMaterial.materialID,
                                              if(await fetchContentMaterials(context, globals.selectedCourse.courseID, globals.selectedCourseUnit.unitID, globals.selectedMaterial.materialID)){
                                                if(await update_progress(context, progress_Table.Module,
                                                    courseID: globals.selectedCourse.courseID, unitID: globals.selectedCourseUnit.unitID, matID: globals.selectedMaterial.materialID)){
                                                  Navigator.of(context)
                                                      .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
                                                  Navigator.of(context).push(globals.gotoPage(globals.CourseList_Page, Duration(seconds: 0, milliseconds: 0))),
                                                  Navigator.of(context).push(globals.gotoPage(globals.CourseUnitList_Page, Duration(seconds: 0, milliseconds: 0))),
                                                  //Navigator.of(context).push(globals.gotoPage(globals.CourseUnit_Page, Duration(seconds: 0, milliseconds: 0))),
                                                  Navigator.of(context).push(globals.gotoPage(
                                                      globals.CourseContent_Page,
                                                      Duration(seconds: 0, milliseconds: 500))).then((value) => Refresh_Page_Manager.refresh_CourseUnitListPage(context)),
                                                }
                                              }

                                            }
                                          }
                                        }
                                      },
                                    },
                                  },
                                  icon: Icon(Icons.remove_red_eye, color: Colors.black54,),
                                  label: Text(
                                    Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseUnitListPage_ViewUnit],
                                    style: TextStyle(color: Colors.black, fontSize: globals.fontSize_Normal),)
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Container(color: Colors.black38, height: 1),
                  // endregion
                  Container(color: Colors.black38, height: 1),
                  // region Progress Bar of Attachments
                  /*
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 10, right: 20, left: 15, bottom: 5),
                                  child: Text( Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Progress_Unit_AttTotal_Title],
                                      style: TextStyle(fontSize: 14)),
                                ),
                              )
                            ],
                          )
                      ),
                      Expanded(
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 10, right: 20, left: 15, bottom: 5),
                                  child: Text(courseUnitList[i].attachment_Checked_Count.toString() + ' / ' + courseUnitList[i].unitModuleAttachmentCount.toString(),
                                      style: TextStyle(fontSize: 14)),
                                ),
                              )
                            ],
                          )
                      )
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 10, right: 15, left: 15),
                              child: new LinearPercentIndicator(
                                width: MediaQuery.of(context).size.width - 80,
                                animation: true,
                                lineHeight: 20.0,
                                animationDuration: 1000,
                                percent: !(courseUnitList[i].attachment_Checked_Count == 0 && courseUnitList[i].unitModuleAttachmentCount == 0) ?
                                courseUnitList[i].attachment_Checked_Count / courseUnitList[i].unitModuleAttachmentCount : 1.0,
                                center: Text( !(courseUnitList[i].attachment_Checked_Count == 0 && courseUnitList[i].unitModuleAttachmentCount == 0) ?
                                   ((courseUnitList[i].attachment_Checked_Count / courseUnitList[i].unitModuleAttachmentCount)*100).toStringAsFixed(2) + '%' :
                                  '100.00%',
                                  style: TextStyle(fontSize: 14),),
                                linearStrokeCap: LinearStrokeCap.roundAll,
                                progressColor: Colors.greenAccent,
                              ),
                            ),
                          )
                      )
                    ],
                  ),
                  */
                  // endregion
                  // region Progress Bar of Module
                  /*
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 10, right: 20, left: 15, bottom: 5),
                                  child: Text( Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Progress_Unit_ModuleTotal_Title],
                                      style: TextStyle(fontSize: 14)),
                                ),
                              )
                            ],
                          )
                      ),
                      Expanded(
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 10, right: 20, left: 15, bottom: 5),
                                  child: Text(courseUnitList[i].module_Finished_Count.toString() + ' / ' + courseUnitList[i].unitModuleCount.toString(),
                                      style: TextStyle(fontSize: 14)),
                                ),
                              )
                            ],
                          )
                      )
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 10, right: 15, left: 15),
                              child: new LinearPercentIndicator(
                                width: MediaQuery.of(context).size.width - 80,
                                animation: true,
                                lineHeight: 20.0,
                                animationDuration: 1000,
                                percent: !(courseUnitList[i].module_Finished_Count == 0 && courseUnitList[i].unitModuleCount == 0) ?
                                courseUnitList[i].module_Finished_Count / courseUnitList[i].unitModuleCount : 1.0,
                                center: Text(!(courseUnitList[i].module_Finished_Count == 0 && courseUnitList[i].unitModuleCount == 0) ?
                                  ((courseUnitList[i].module_Finished_Count / courseUnitList[i].unitModuleCount)*100).toStringAsFixed(2) + '%':
                                  '100.00%',
                                  style: TextStyle(fontSize: 14),),
                                linearStrokeCap: LinearStrokeCap.roundAll,
                                progressColor: Colors.greenAccent,
                              ),
                            ),
                          )
                      )
                    ],
                  ),
                  */
                  // endregion
                  // region Administration Function
                  // Edit Course Unit Button
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
                              padding: EdgeInsets.only(top: 5,left: 5,right: 5),
                              child: Container(
                                decoration: BoxDecoration(),
                                child: FlatButton.icon(
                                    onPressed: () async => {
                                      globals.edit_isCourseUnitDataLoaded = false,
                                      globals.courseunit_isEditing = true,
                                      globals.selectedCourseUnit = courseUnitList[i],
                                      if(await fetchMaterials(context, globals.selectedCourse.courseID, globals.selectedCourseUnit.unitID)){
                                        globals.editCourseUnit_Title = globals.selectedCourseUnit.unitName,
                                        globals.editCourseUnit_Desc = globals.selectedCourseUnit.unitDesc,
                                        globals.editCourseUnit_STime = DateFormat('HH:mm:ss').format(globals.selectedCourseUnit.unitPeriod_Start),
                                        globals.editCourseUnit_SDate = DateFormat('yyyy-MM-dd').format(globals.selectedCourseUnit.unitPeriod_Start),
                                        globals.editCourseUnit_ETime = DateFormat('HH:mm:ss').format(globals.selectedCourseUnit.unitPeriod_End),
                                        globals.editCourseUnit_EDate = DateFormat('yyyy-MM-dd').format(globals.selectedCourseUnit.unitPeriod_End),
                                        globals.skip_moduleselection = globals.selectedCourseUnit.skip_moduleSelection ? 1 : 0,
                                        globals.edit_isCourseUnitDataLoaded = true,
                                        if(await fetchCourseUnitData(context, globals.selectedCourseUnit.unitID)){
                                          Navigator.of(context).push(globals.gotoPage(CourseUnitEditor(),Duration(seconds: 0, milliseconds: 500))),
                                        },
                                      },
                                    },
                                    icon: Icon(Icons.edit, color: Colors.black54,),
                                    label: Text(
                                      Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseUnitPage_EditDetails],
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
                                      globals.courseunit_isEditing = false,
                                      //globals.selectedCourseUnit = courseUnitList[i],
                                      if(await fetchCourseUnitData(context, courseUnitList[i].unitID)){
                                        globals.newCourseUnit_Title = courseUnitList[i].unitName,
                                        globals.newCourseUnit_Desc = courseUnitList[i].unitDesc,
                                        globals.newCourseUnit_STime = DateFormat('HH:mm:ss').format(courseUnitList[i].unitPeriod_Start),
                                        globals.newCourseUnit_SDate = DateFormat('yyyy-MM-dd').format(courseUnitList[i].unitPeriod_Start),
                                        globals.newCourseUnit_ETime = DateFormat('HH:mm:ss').format(courseUnitList[i].unitPeriod_End),
                                        globals.newCourseUnit_EDate = DateFormat('yyyy-MM-dd').format(courseUnitList[i].unitPeriod_End),
                                        globals.skip_moduleselection = 0,
                                        globals.editCourseUnit_SelectedGoToMaterial = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseUnitCreator_Creator_SkipModuleSelection_Default],
                                        Navigator.of(context).push(globals.gotoPage(CourseUnitEditor(),Duration(seconds: 0, milliseconds: 500))),
                                      },
                                    },
                                    icon: Icon(Icons.copy, color: Colors.black54,),
                                    label: Text(
                                      Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseUnitPage_DuplicateDetails],
                                      style: TextStyle(color: Colors.black, fontSize: globals.fontSize_Normal),)
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
            padding: EdgeInsets.only(top:5, bottom: 5),
            child: itemCard_new,
          )
      ));
    }

    setState(() {
      //print("SetState");
      globals.courseUnitListThumb = thumbs;
    });
    globals.courseUnitListReloaded = true;
  }

  void _removeCourse() async {
    // Dialog Information
    dialog_Status _dialogStatus = dialog_Status.Error;
    String dialog_Msg = "";
    final remove_data = {'CID': globals.selectedCourse.courseID};
    try {
      // Call Web API and try to get a result from Server
      var response_code = await http.post(
          DeleteCourse_URL, body: json.encode(remove_data)).timeout(
          Duration(seconds: Connection_Timeout_TimeLimit));

      // Getting Server response into variable.
      Map<String, dynamic> response_code_JSON = jsonDecode(response_code.body);

      //print(remove_data);

      if(response_code.statusCode == 200) {
        // There are no any error in login procedure.
        if(response_code_JSON['StatusCode'] == 1000){
          _dialogStatus = dialog_Status.Success;
          dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_Page_DeleteSuccess];
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) => CustomDialog_Confirm(
              dialog_type: _dialogStatus,
              description: dialog_Msg,
              callback_Confirm: () async => {
                globals.courseListReloaded = false,
                if(await fetchCourses(context, isAdminCheck: 'true')){
                  Navigator.of(context)
                      .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
                  Navigator.of(context).push(globals.gotoPage(globals.CourseList_Page,Duration(seconds: 0, milliseconds: 0))),
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
      //print(_.toString());
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

    if(globals.courseUnitListReloaded != true) {
      //print("call Reload");
      _unitListReload(globals.courseUnitList);
    }

    /*
    Widget marquee_appbar_text;
    if(globals.selectedCourse.courseName.length > 16){
      marquee_appbar_text = Marquee(
        text: globals.selectedCourse.courseName,
        style: TextStyle(fontWeight: FontWeight.bold),
        scrollAxis: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        blankSpace: 20.0,
        velocity: 100.0,
        pauseAfterRound: Duration(seconds: 0),
        startPadding: 0.0,
        accelerationDuration: Duration(seconds: 0),
        accelerationCurve: Curves.linear,
        decelerationDuration: Duration(milliseconds: 0),
        decelerationCurve: Curves.easeOut,
      );
    } else {
      marquee_appbar_text = Text(globals.selectedCourse.courseName);
    }
    */

    if (globals.courseUnitList.length == 0) {
      globals.courseUnitListThumb = [
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

    List<String> _filterSelection;
    if(globals.CurrentLang == Localizations_Language_Identifier.Language_Eng){
      _filterSelection = Course_Filter;
    } else if(globals.CurrentLang == Localizations_Language_Identifier.Language_TC){
      _filterSelection = Course_Filter_TC;
    }

    String _selected = globals.courseUnit_list_filter_option;

    final _TitleUI = Padding(
      padding: EdgeInsets.only(top:15, left: 15, right: 15),
      child: Container(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      globals.selectedCourse.courseName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: globals.fontSize_SubTitle,
                          color: appPrimaryColor),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(Icons.play_arrow, color: Colors.black,),
                              Padding(padding: EdgeInsets.only(right: 5),),
                              Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(
                                  globals.selectedCourse.coursePeriod_Start), style: TextStyle(color: Colors.black, fontSize: globals.fontSize_Normal))
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Icon(Icons.not_interested, color: Colors.black,),
                              Padding(padding: EdgeInsets.only(right: 5),),
                              Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(
                                  globals.selectedCourse.coursePeriod_End), style: TextStyle(color: Colors.black, fontSize: globals.fontSize_Normal))
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: FlatButton.icon(
                              icon: Icon(Icons.description),
                              label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_Page_ViewDescription],
                                  style: TextStyle(fontSize: globals.fontSize_Normal)),
                              textColor: Colors.white,
                              color: Colors.lightGreen,
                              onPressed: () =>  {
                                showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (BuildContext context) => CustomDialog_Confirm(
                                    dialog_type: dialog_Status.Custom,
                                    title: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_Page_ViewDescription],
                                    description: globals.selectedCourse.courseDesc,
                                    image: Icon(Icons.description),
                                    buttonText: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Close],
                                  ),
                                )
                              },
                            ),
                          )
                      )
                    ],
                  ),
                  Divider(
                    height: 20,
                    color: Colors.lightBlue,
                    thickness: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
        appBar: AppBar(
          backgroundColor: appTitleBarColor,
          title: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseUnitPage_AppBarTitle],
          style: TextStyle(fontSize: globals.fontSize_Title),),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () async => {
                Refresh_Page_Manager.refresh_CourseUnitListPage(context)
              },
              child: Icon(Icons.refresh, color: Colors.white,),)
          ],
        ),
        body: Stack(
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                _TitleUI,
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
                                label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_Page_AddContent],
                                    style: TextStyle(fontSize: globals.fontSize_Normal)),
                                textColor: Colors.white,
                                color: Colors.lightBlue,
                                onPressed: () => {
                                  globals.courseunit_isEditing = false,
                                  Navigator.of(context).push(globals.gotoPage(CourseUnitEditor(),Duration(seconds: 0, milliseconds: 500))),
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(width: 15,),
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              width: double.infinity,
                              child: FlatButton.icon(
                                icon: Icon(Icons.edit),
                                label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_Page_EditDetails],
                                    style: TextStyle(fontSize: globals.fontSize_Normal)),
                                textColor: Colors.white,
                                color: Colors.lightBlue,
                                onPressed: () async => {
                                  globals.edit_isCourseDataLoaded = false,
                                  globals.course_isEditing = true,
                                  if(await fetchUserGroup(context, containsAdmin: '0')){
                                    if(await fetchCourseData(context, globals.selectedCourse.courseID)){
                                      globals.editCourse_Title = globals.selectedCourse.courseName,
                                      globals.editCourse_Desc = globals.selectedCourse.courseDesc,
                                      globals.editCourse_STime = DateFormat('HH:mm:ss').format(globals.selectedCourse.coursePeriod_Start),
                                      globals.editCourse_SDate = DateFormat('yyyy-MM-dd').format(globals.selectedCourse.coursePeriod_Start),
                                      globals.editCourse_ETime = DateFormat('HH:mm:ss').format(globals.selectedCourse.coursePeriod_End),
                                      globals.editCourse_EDate = DateFormat('yyyy-MM-dd').format(globals.selectedCourse.coursePeriod_End),
                                      globals.edit_isCourseDataLoaded = true,
                                      Navigator.of(context).push(globals.gotoPage(CourseEditor(),Duration(seconds: 0, milliseconds: 500))),
                                    }
                                  },
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(width: 15,)
                    ],
                  ),
                ), // Course Creator and Editor Buttons
                Visibility(
                  visible: globals.canUpload,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: ButtonTheme(
                      minWidth: 300.0,
                      height: 40.0,
                      child: FlatButton.icon(
                        icon: Icon(Icons.build),
                        label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_Page_UnitStatusFilter]
                            + ": " + globals.courseUnit_list_filter_option,
                            style: TextStyle(fontSize: globals.fontSize_Normal)),
                        textColor: Colors.white,
                        color: Colors.redAccent,
                        onPressed: () =>  {
                          SelectDialog.showModal<String>(
                            context,
                            label: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_Page_UnitStatusFilter],
                            selectedValue: _selected,
                            items: _filterSelection,
                            showSearchBox: false,
                            onChange: (String selected) async => {
                              globals.courseUnitListReloaded = false,
                              if(selected == _filterSelection[1]){
                                if(await fetchCourseUnits(context, globals.selectedCourse.courseID, queryparam: "isOpening")){
                                  globals.courseUnit_list_filter_option = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.StatusFilter_Opening],
                                  Navigator.of(context)
                                      .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
                                  Navigator.of(context).push(globals.gotoPage(globals.CourseList_Page, Duration(seconds: 0, milliseconds: 0))),
                                  Navigator.of(context).push(globals.gotoPage(globals.CourseUnitList_Page, Duration(seconds: 0, milliseconds: 0))),
                                }
                              } else if(selected == _filterSelection[3]) {
                                if(await fetchCourseUnits(context, globals.selectedCourse.courseID, queryparam: "isExpired")){
                                  globals.courseUnit_list_filter_option = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.StatusFilter_Expired],
                                  Navigator.of(context)
                                      .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
                                  Navigator.of(context).push(globals.gotoPage(globals.CourseList_Page, Duration(seconds: 0, milliseconds: 0))),
                                  Navigator.of(context).push(globals.gotoPage(globals.CourseUnitList_Page, Duration(seconds: 0, milliseconds: 0))),
                                }
                              } else if(selected == _filterSelection[2]){
                                if(await fetchCourseUnits(context, globals.selectedCourse.courseID, queryparam: "isComingSoon")){
                                  globals.courseUnit_list_filter_option = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.StatusFilter_Coming],
                                  Navigator.of(context)
                                      .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
                                  Navigator.of(context).push(globals.gotoPage(globals.CourseList_Page, Duration(seconds: 0, milliseconds: 0))),
                                  Navigator.of(context).push(globals.gotoPage(globals.CourseUnitList_Page, Duration(seconds: 0, milliseconds: 0))),
                                }
                              } else if(selected == _filterSelection[0]){
                                if(await fetchCourseUnits(context, globals.selectedCourse.courseID)){
                                  globals.courseUnit_list_filter_option = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.StatusFilter_All],
                                  Navigator.of(context)
                                      .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
                                  Navigator.of(context).push(globals.gotoPage(globals.CourseList_Page, Duration(seconds: 0, milliseconds: 0))),
                                  Navigator.of(context).push(globals.gotoPage(globals.CourseUnitList_Page, Duration(seconds: 0, milliseconds: 0))),
                                }
                              }
                            },
                          )
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseUnitListPage_UnitSelectionTitle], style: TextStyle(fontSize: globals.fontSize_Middle),),
                      Divider(
                        height: 20,
                        color: Colors.lightBlue,
                        thickness: 3,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                      padding: EdgeInsets.only(left: 10,right: 10),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: globals.courseUnitListThumb.length, // number of items in your list
                      //here the implementation of itemBuilder. take a look at flutter docs to see details
                      itemBuilder: (BuildContext context, int Itemindex){
                        return globals.courseUnitListThumb[Itemindex]; // return your widget
                      }
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
                                icon: Icon(Icons.delete_forever),
                                label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_Page_Delete],
                                    style: TextStyle(fontSize: globals.fontSize_Middle)),
                                textColor: Colors.white,
                                color: Colors.redAccent,
                                onPressed: () async => {
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) => CustomDialog_Selection(
                                      dialog_type: dialog_Status.Warning,
                                      description: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_Page_DeleteWarning],
                                      callback_Confirm: () => {
                                        Navigator.of(context).pop(),
                                        _removeCourse(),
                                      },
                                    ),
                                  )
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
              ],
            ),
          ],
        )
        /*Center(
          child: ListView.builder(
              itemCount: globals.materialListThumb.length, // number of items in your list
              //here the implementation of itemBuilder. take a look at flutter docs to see details
              itemBuilder: (BuildContext context, int Itemindex){
                return globals.materialListThumb[Itemindex]; // return your widget
              }
          ),
        ),

         */
    );
  }
}