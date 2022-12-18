import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:smeapp/Components/Survey/WebBrowser.dart';
import 'package:smeapp/CustomWidget/CustomDialog.dart';
import 'package:smeapp/Helper/refresh_page_function.dart';
import '../../Helper/ComponentsList.dart';
import 'dart:io';
import '../../Helper/global_setting.dart' as globals;
import 'package:http/http.dart' as http hide File;
import 'dart:async';
import 'package:smeapp/Helper/Localizations.dart';
import '../../Helper/JsonItemConvertor.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';


class CourseContentPage extends StatefulWidget{
  CourseContentPage({Key key}) : super(key: key);
  @override
  CourseContentPage_State createState() => CourseContentPage_State();
}

class CourseContentPage_State extends State<CourseContentPage> {
  @override
  void initState() {
    super.initState();
  }

  void _removeMaterial() async {
    // Dialog Information
    dialog_Status _dialogStatus = dialog_Status.Error;
    String dialog_Msg = "";
    final remove_data = {'MID': globals.selectedMaterialID};
    try {
      // Call Web API and try to get a result from Server
      var response_code = await http.post(
          DeleteMaterial_URL, body: json.encode(remove_data)).timeout(
          Duration(seconds: Connection_Timeout_TimeLimit));

      // Getting Server response into variable.
      Map<String, dynamic> response_code_JSON = jsonDecode(response_code.body);

      if(response_code.statusCode == 200) {
        // There are no any error in login procedure.
        //debugPrint(response_code.body);
        if(response_code_JSON['StatusCode'] == 1000){
          _dialogStatus = dialog_Status.Success;
          dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_ContentPage_DeleteSuccess];
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) => CustomDialog_Confirm(
              dialog_type: _dialogStatus,
              description: dialog_Msg,
              callback_Confirm: () async => {
                if(await fetchMaterials(context, globals.selectedCourse.courseID, globals.selectedCourseUnit.unitID)){
                  Navigator.of(context)
                      .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
                  Navigator.of(context).push(globals.gotoPage(globals.CourseList_Page,Duration(seconds: 0, milliseconds: 0))),
                  globals.materialListReloaded = false,
                  Navigator.of(context).push(globals.gotoPage(globals.CourseUnit_Page,Duration(seconds: 0, milliseconds: 0))),
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

  void _contentmaterialListReload(MaterialListItem materialfilelist) async {
    List<Widget> thumbs = new List<Widget>();
    globals.materialFilesThumb = new List<Widget>();

    var platform = Theme.of(context).platform;
    String download_folder_path;
    Directory appDocDir = await getApplicationDocumentsDirectory();
    if(platform == TargetPlatform.android)
      download_folder_path = await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOWNLOADS);
    else if(platform == TargetPlatform.iOS)
      download_folder_path = appDocDir.path;

    //print(globals.module_AttachmentCheckingStatus);

    //print("Materials List Reload");
    for (int i=0; i < materialfilelist.att_list.length; i++) {
      Color listitemBgColor;
      Color textColor = Colors.black87;
      String fileSizeDisplay = "";
      String savepath = "";
      if(materialfilelist.att_list[i].attExt != "URL"){
        // Get File Size
        int fileSizeInBytes = materialfilelist.att_list[i].attSize;
        double fileSizeInKB = fileSizeInBytes / 1024;
        double fileSizeInMB = fileSizeInKB / 1024;
        if(fileSizeInMB >= 1.0)
          fileSizeDisplay = fileSizeInMB.toStringAsFixed(2) + " MB";
        else {
          fileSizeDisplay = fileSizeInKB.toStringAsFixed(2) + " KB";
        }
        savepath = download_folder_path + '/' +materialfilelist.att_list[i].attName;
      }
      //print(savepath);


      Widget flatbtn_download = FlatButton.icon(
        onPressed: () async => {
            if(await globals.downloadFile(
                globals.CourseContentPage_Key.currentContext,
                Server_Protocol + materialfilelist.att_list[i].attPath,
                filesize: materialfilelist.att_list[i].attSize,
                filename: materialfilelist.att_list[i].attName)){
              if(await Check_Token(context)){
                if(await update_progress(context, progress_Table.Attachment,
                    courseID: globals.selectedCourse.courseID,
                    unitID: globals.selectedCourseUnit.unitID,
                    matID: globals.selectedMaterial.materialID,
                    attID: materialfilelist.att_list[i].attID,
                    check_status: 0)){
                }
              },
            }
        },
        icon: Icon(Icons.cloud_download),
        label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_ContentPage_DownloadFile],
          style: TextStyle(fontSize: globals.fontSize_Normal),),
      );

      Widget flatbtn_open = FlatButton.icon(
        onPressed: () async => {
          OpenFile.open(savepath),
          Refresh_Page_Manager.refresh_UnitModulePage(context)
        },
        icon: Icon(Icons.input),
        label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_ContentPage_OpenFile],
          style: TextStyle(fontSize: globals.fontSize_Normal),),
      );

      Widget flatbtn_openweb = FlatButton.icon(
        onPressed: () async => {
          showDialog(
              context: context,
              builder: (BuildContext context) => CustomDialog_Selection(
                callback_Confirm: () => {
                  Navigator.of(context).pop(),
                  globals.browser_url = materialfilelist.att_list[i].attPath,
                  globals.browser_Title = materialfilelist.att_list[i].attName,
                  Navigator.of(context).push(globals.gotoPage(WebBrowser(),Duration(seconds: 0, milliseconds: 500))),
                },
                dialog_type: dialog_Status.Warning,
                title: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_ContentPage_OpenWebsiteWarning_Title],
                description: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_ContentPage_OpenWebsiteWarning],
                buttonText_Confirm: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_ContentPage_OpenFile],
              ))
        },
        icon: Icon(Icons.input),
        label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_ContentPage_OpenFile],
          style: TextStyle(fontSize: globals.fontSize_Normal),),
      );

      Widget flatbtn_markstatus = /*Visibility(
        visible: materialfilelist.att_list[i].download_datetime != null,
        child: */FlatButton.icon(
          onPressed: () async => {
            //print(globals.selectedCourse.courseID),
            //print(globals.selectedCourseUnit.unitID),
            //print(globals.selectedMaterial.materialID),
            //print(materialfilelist.att_list[i].attID),
            if(globals.module_AttachmentCheckingStatus[i] == true){
              if(await Check_Token(context)){
                if(await update_progress(context, progress_Table.Attachment,
                    courseID: globals.selectedCourse.courseID,
                    unitID: globals.selectedCourseUnit.unitID,
                    matID: globals.selectedMaterial.materialID,
                    attID: materialfilelist.att_list[i].attID,
                    check_status: 0)){
                  Refresh_Page_Manager.refresh_UnitModulePage(context),
                }
              },
            } else if (globals.module_AttachmentCheckingStatus[i] == false){
              if(await Check_Token(context)){
                if(await update_progress(context, progress_Table.Attachment,
                    courseID: globals.selectedCourse.courseID,
                    unitID: globals.selectedCourseUnit.unitID,
                    matID: globals.selectedMaterial.materialID,
                    attID: materialfilelist.att_list[i].attID,
                    check_status: 1)){
                  Refresh_Page_Manager.refresh_UnitModulePage(context),
                }
              },
            }
          },
          icon: globals.module_AttachmentCheckingStatus[i] ? new Icon(Icons.check_box_outlined) : new Icon(Icons.check_box_outline_blank),
          label: Text((globals.module_AttachmentCheckingStatus[i] ?
          Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_ContentPage_MarkedasNotComplete] :
          Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_ContentPage_MarkedasComplete]),
            style: TextStyle(fontSize: globals.fontSize_Normal,fontWeight: FontWeight.bold),),
        );//,
     // );

      //globals.module_AttachmentCheckingStatus[i] ? new Icon(Icons.check_circle_outline) : new Icon(Icons.check),

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
                                  materialfilelist.att_list[i].attName,
                                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: globals.fontSize_Middle),
                                ),
                                alignment: Alignment.centerLeft,
                              )
                            ],
                          ),
                          flex: 9,
                        ),
                        Expanded(
                            flex: 1,
                            child: globals.picExt.contains('.'+materialfilelist.att_list[i].attExt.toLowerCase()) ? image_Icon :
                                    globals.docExt.contains('.'+materialfilelist.att_list[i].attExt.toLowerCase()) ? doc_Icon :
                                    materialfilelist.att_list[i].attExt.toLowerCase() == 'pdf' ? pdf_Icon :
                                    materialfilelist.att_list[i].attExt.toLowerCase() == 'mp3' ? music_Icon :
                                    materialfilelist.att_list[i].attExt.toLowerCase() == 'mp4' ? video_Icon :
                                    materialfilelist.att_list[i].attExt.toLowerCase() == 'url' ? url_Icon : zip_Icon
                        ),
                      ],
                    ),
                  ),
                  // endregion
                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Align(
                                child: Text(
                                  fileSizeDisplay == "" ? materialfilelist.att_list[i].attPath : fileSizeDisplay,
                                  style: TextStyle(color: Colors.black45, fontSize: globals.fontSize_Small),
                                ),
                                alignment: Alignment.centerLeft,
                              )
                            ],
                          ),
                          flex: 9,
                        ),
                      ],
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 10), child: Container(color: Colors.black38, height: 1),),
                  // region Button
                  /*Visibility(
                    visible: await File(savepath).exists(),
                    child: */Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: flatbtn_markstatus,
                          ),
                        )
                      ],
                    ),
                  //),
                  Visibility(
                    visible: await File(savepath).exists(),
                    child: Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: flatbtn_open,
                          ),
                        )
                      ],
                    ),
                  ),
                  Visibility(
                    visible: materialfilelist.att_list[i].attExt.toLowerCase() == 'url',
                    child: Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: flatbtn_openweb,
                          ),
                        )
                      ],
                    ),
                  ),
                  Visibility(
                    visible: materialfilelist.att_list[i].attExt.toLowerCase() != 'url',
                    child: Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: flatbtn_download,
                          ),
                        )
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

      //region Add Thumb to thumbs list
      // Identified Image Extension ==> Output Image Container
      thumbs.add(itemCard_new);
      //endregion
      //print("Added: " + i.toString());
    }


    setState(() {
      //print("SetState");
      globals.materialFilesThumb = thumbs;
    });

    globals.materialsReloaded = true;
  }

  @override
  Widget build(BuildContext context) {
    //MaterialListItem currentContent = globals.materialList[globals.materialList.indexWhere((element) => element.materialID == globals.selectedMaterialID)];

    if(globals.materialsReloaded != true) {
      //print("call Reload");
      _contentmaterialListReload(globals.materialListItem);
      //print(globals.selectedMaterial.att_count);
    }

    if (globals.selectedMaterial.att_count == 0) {
      globals.materialFilesThumb = [
        InkWell(
          child: Container(
              alignment: Alignment.center,
              child: Text(Localizations_Text[globals
                  .CurrentLang][Localizations_Text_Identifier
                  .Course_ContentPage_NoAnyAttachment],
                style: TextStyle(fontSize: globals.fontSize_Normal, fontWeight: FontWeight.bold),)
          ),
        )
      ];
    }

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
                      globals.selectedMaterial.materialName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: globals.fontSize_Big,
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
                                  globals.selectedMaterial.materialPeriod_Start), style: TextStyle(color: Colors.black,fontSize: globals.fontSize_Normal))
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Icon(Icons.not_interested, color: Colors.black,),
                              Padding(padding: EdgeInsets.only(right: 5),),
                              Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(
                                  globals.selectedMaterial.materialPeriod_End), style: TextStyle(color: Colors.black,fontSize: globals.fontSize_Normal))
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
                              label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.UnitModule_Page_ViewDescription],
                                style: TextStyle(fontSize: globals.fontSize_Normal),),
                              textColor: Colors.white,
                              color: Colors.lightGreen,
                              onPressed: () =>  {
                                showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (BuildContext context) => CustomDialog_Confirm(
                                    dialog_type: dialog_Status.Custom,
                                    title: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.UnitModule_Page_ViewDescription],
                                    description: globals.selectedMaterial.materialDesc,
                                    image: Icon(Icons.description),
                                    buttonText: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Close],
                                  ),
                                )
                              },
                            ),
                          )
                      ),
                    ],
                  ),
                  Divider(
                    height: 20,
                    color: Colors.indigo,
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
          backgroundColor: Colors.indigo,
          title: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_ContentPage_AppBarTitle],
          style: TextStyle(fontSize: globals.fontSize_Title),),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(true),
          ),
          actions: <Widget>[
            FlatButton(
                onPressed: () async => {
                  Refresh_Page_Manager.refresh_UnitModulePage(context)
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
                                icon: Icon(Icons.edit),
                                label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_ContentPage_EditDetails],
                                    style: TextStyle(fontSize: globals.fontSize_Normal)),
                                textColor: Colors.white,
                                color: Colors.green,
                                onPressed: () async => {
                                  globals.edit_isMaterialDataLoaded = false,
                                  globals.material_isEditing = true,
                                  globals.fileListThumb = List<Widget>(),
                                  globals.fileListThumb_Preview = List<Widget>(),
                                  globals.linksThumb = List<Widget>(),
                                  globals.linksThumb_Preview = List<Widget>(),
                                  globals.newMaterial_FilesUploader_fileList = List<File>(),
                                  globals.newMaterial_FilesUploader_failFilesList = List<File>(),
                                  if(await fetchMaterialContentData(context, globals.selectedMaterial.materialID)){
                                    Navigator.of(context).push(globals.gotoPage(
                                        globals.CourseContentEditor_Page,
                                        Duration(
                                            seconds: 0, milliseconds: 500))),
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
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.ModulePage_AttachmentSelectionTitle], style: TextStyle(fontSize: globals.fontSize_Middle),),
                      Divider(
                        height: 20,
                        color: Colors.indigo,
                        thickness: 3,
                      ),
                    ],
                  ),
                ),
                // region Progress Bar of Attachments
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(top: 10, right: 0, left: 15, bottom: 5),
                                child: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Progress_Module_AttToal_Title],
                                    style: TextStyle(fontSize: globals.fontSize_Normal)),
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
                                padding: EdgeInsets.only(top: 10, right: 20, left: 0, bottom: 5),
                                child: Text(globals.selectedMaterial.checked_count.toString() + ' / ' + globals.selectedMaterial.att_count.toString(),
                                    style: TextStyle(fontSize: globals.fontSize_Normal)),
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
                              width: MediaQuery.of(context).size.width - 35,
                              animation: true,
                              lineHeight: 35.0,
                              animationDuration: 1000,
                              percent: !(globals.selectedMaterial.checked_count == 0 && globals.selectedMaterial.att_count == 0) ?
                              globals.selectedMaterial.checked_count / globals.selectedMaterial.att_count : 1.0,
                              center: Text(!(globals.selectedMaterial.checked_count == 0 && globals.selectedMaterial.att_count == 0) ?
                                ((globals.selectedMaterial.checked_count / globals.selectedMaterial.att_count)*100).toStringAsFixed(2) + '%' :
                                '100.00%',
                                style: TextStyle(fontSize: globals.fontSize_Normal),),
                              linearStrokeCap: LinearStrokeCap.roundAll,
                              progressColor: Colors.greenAccent,
                            ),
                          ),
                        )
                    )
                  ],
                ),
                // endregion
                Expanded(
                  child: ListView.builder(
                      padding: EdgeInsets.only(left: 10,right: 10, top:10),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: globals.materialFilesThumb.length, // number of items in your list
                      //here the implementation of itemBuilder. take a look at flutter docs to see details
                      itemBuilder: (BuildContext context, int Itemindex){
                        return globals.materialFilesThumb[Itemindex]; // return your widget
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
                                label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_ContentPage_Delete],
                                style: TextStyle(fontSize: globals.fontSize_Small),),
                                textColor: Colors.white,
                                color: Colors.redAccent,
                                onPressed: () async => {
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) => CustomDialog_Selection(
                                      dialog_type: dialog_Status.Warning,
                                      description: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_ContentPage_DeleteWarning],
                                      callback_Confirm: () => {
                                        Navigator.of(context).pop(),
                                        _removeMaterial(),
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