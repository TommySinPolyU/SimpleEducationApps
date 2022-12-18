import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:smeapp/Components/CourseContentUploader/FilesUploader.dart';
import 'package:smeapp/Components/CourseContentUploader/LinkSelecter.dart';

import 'FilesSelecter.dart';
import 'UploadMaterialPage.dart';
import '../../main.dart';

import '../../Helper/ComponentsList.dart';
import 'package:http/http.dart' as http;
import '../../Helper/global_setting.dart' as globals;
import 'package:intl/intl.dart';
import 'package:smeapp/Helper/Localizations.dart';

class PreviewUploadPage extends StatefulWidget {
  PreviewUploadPage_State createState() => PreviewUploadPage_State();
}

class PreviewUploadPage_State extends State {
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

  @override
  Widget build(BuildContext context) {

    // region UI - Field Labels
    final label_startDateTime = Padding(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_StartDateTimeLabelText],
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
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_EndDateTimeLabelText],
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
      padding: EdgeInsets.only(left: 20,right: 20),
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
    // endregion

    if(globals.material_isEditing){
      // Reload The Stored Variables into form.
      if(globals.editMaterial_Title?.isNotEmpty ?? false) _newTitleController.text = globals.editMaterial_Title;
      if(globals.editMaterial_Desc?.isNotEmpty ?? false) _newDescController.text = globals.editMaterial_Desc;
      //if(globals.editMaterial_RequiredTime?.isNotEmpty ?? false) _newRequiredTimeController.text = globals.editMaterial_RequiredTime;
      if(globals.editMaterial_FullStartTime.toString()?.isNotEmpty ?? false) _newStartDateTimeController.text = globals.editMaterial_FullStartTime.toString();
      if(globals.editMaterial_FullEndTime.toString()?.isNotEmpty ?? false) _newEndDateTimeController.text = globals.editMaterial_FullEndTime.toString();
    } else {
      // Reload The Stored Variables into form.
      if(globals.newMaterial_Title?.isNotEmpty ?? false) _newTitleController.text = globals.newMaterial_Title;
      if(globals.newMaterial_Desc?.isNotEmpty ?? false) _newDescController.text = globals.newMaterial_Desc;
      //if(globals.newMaterial_RequiredTime?.isNotEmpty ?? false) _newRequiredTimeController.text = globals.newMaterial_RequiredTime;
      if(globals.newMaterial_FullStartTime.toString()?.isNotEmpty ?? false) _newStartDateTimeController.text = globals.newMaterial_FullStartTime.toString();
      if(globals.newMaterial_FullEndTime.toString()?.isNotEmpty ?? false) _newEndDateTimeController.text = globals.newMaterial_FullEndTime.toString();
    }

    if ((globals.newMaterial_FilesUploader_fileList.length + globals.materialEditor_AttachmentThumb.length) == 0) {
      globals.fileListThumb_Preview = [
        InkWell(
          child: Container(
              alignment: Alignment.center,
              child: Text(Localizations_Text[globals
                  .CurrentLang][Localizations_Text_Identifier
                  .Material_Preview_NoAnyAttachment],
                style: TextStyle(fontSize: globals.fontSize_Middle, fontWeight: FontWeight.bold),)
          ),
        )
      ];
    }

    return Scaffold(
      backgroundColor: appBGColor,
        appBar: AppBar(
          backgroundColor: appTitleBarColor,
          centerTitle: true,
          title: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_Preview_Title],
          style: TextStyle(fontSize: globals.fontSize_Title),),
        ),
      body: Stack(
        children: <Widget>[
          Padding(padding: EdgeInsets.only(top:15, right: 15, left: 15, bottom: 200),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: ListView(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(top: 15),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                    width: double.infinity,
                                    child: _titleField
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 15),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                    width: double.infinity,
                                    child: _descField
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 15),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                    width: double.infinity,
                                    child: _startDateTimeField
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 15),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                    width: double.infinity,
                                    child: _endDateTimeField
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      child: ListView.builder(
                          padding: EdgeInsets.only(left: 0,right: 0, top:10),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: globals.server_AttachmentsThumb_Preview.length, // number of items in your list
                          //here the implementation of itemBuilder. take a look at flutter docs to see details
                          itemBuilder: (BuildContext context, int Itemindex){
                            return globals.server_AttachmentsThumb_Preview[Itemindex]; // return your widget
                          }
                      ),
                      visible: globals.server_AttachmentsThumb_Preview.length > 0,),
                    Visibility(
                      child: ListView.builder(
                          padding: EdgeInsets.only(left: 0,right: 0, top:10),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: globals.fileListThumb_Preview.length, // number of items in your list
                          //here the implementation of itemBuilder. take a look at flutter docs to see details
                          itemBuilder: (BuildContext context, int Itemindex){
                            return globals.fileListThumb_Preview[Itemindex]; // return your widget
                          }
                      ),
                      visible: globals.fileListThumb_Preview.length > 0,),
                    Visibility(
                      child: ListView.builder(
                          padding: EdgeInsets.only(left: 0,right: 0, top:10),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: globals.server_AttachmentsDeleteThumb_Preview.length, // number of items in your list
                          //here the implementation of itemBuilder. take a look at flutter docs to see details
                          itemBuilder: (BuildContext context, int Itemindex){
                            return globals.server_AttachmentsDeleteThumb_Preview[Itemindex]; // return your widget
                          }
                      ),
                      visible: globals.server_AttachmentsDeleteThumb_Preview.length > 0,),
                    Visibility(
                      child: ListView.builder(
                          padding: EdgeInsets.only(left: 0,right: 0, top:10),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: globals.server_LinksThumb_Preview.length, // number of items in your list
                          //here the implementation of itemBuilder. take a look at flutter docs to see details
                          itemBuilder: (BuildContext context, int Itemindex){
                            return globals.server_LinksThumb_Preview[Itemindex]; // return your widget
                          }
                      ),
                      visible: globals.server_LinksThumb_Preview.length > 0,),
                    Visibility(
                      child: ListView.builder(
                          padding: EdgeInsets.only(left: 0,right: 0, top:10),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: globals.linksThumb_Preview.length, // number of items in your list
                          //here the implementation of itemBuilder. take a look at flutter docs to see details
                          itemBuilder: (BuildContext context, int Itemindex){
                            return globals.linksThumb_Preview[Itemindex]; // return your widget
                          }
                      ),
                      visible: globals.linksThumb_Preview.length > 0,),
                    Visibility(
                      child: ListView.builder(
                          padding: EdgeInsets.only(left: 0,right: 0, top:10),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: globals.server_LinksDeleteThumb_Preview.length, // number of items in your list
                          //here the implementation of itemBuilder. take a look at flutter docs to see details
                          itemBuilder: (BuildContext context, int Itemindex){
                            return globals.server_LinksDeleteThumb_Preview[Itemindex]; // return your widget
                          }
                      ),
                      visible: globals.server_LinksDeleteThumb_Preview.length > 0,),
                  ],
                ),
              ),
            ],
          ),)
        ],
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
                          Navigator.of(context).pop(),
                          Navigator.of(context).push(globals.gotoPage(UploadMaterialPage(),Duration(seconds: 0, milliseconds: 0))),
                        },
                        label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_Preview_EditDetails],
                        style: TextStyle(fontSize: globals.fontSize_Small),),
                        icon: Icon(Icons.edit),
                      ),
                      Padding(padding:  EdgeInsets.only(top: 6,bottom: 6),),
                      FloatingActionButton.extended(
                        backgroundColor: Colors.blueGrey,
                        heroTag: null,
                        onPressed: () => {
                          Navigator.of(context).pop(),
                          Navigator.of(context).pop(),
                          Navigator.of(context).pop(),
                          Navigator.of(context).push(globals.gotoPage(UploadMaterialPage(),Duration(seconds: 0, milliseconds: 0))),
                          globals.fileListReloaded = false,
                          Navigator.of(context).push(globals.gotoPage(FilesSelecter(),Duration(seconds: 0, milliseconds: 0))),
                        },
                        label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_Preview_EditAttachment],
                        style: TextStyle(fontSize: globals.fontSize_Small),),
                        icon: Icon(Icons.attach_file),
                      ),
                      Padding(padding:  EdgeInsets.only(top: 6,bottom: 6),),
                      FloatingActionButton.extended(
                        backgroundColor: Colors.blueGrey,
                        heroTag: null,
                        onPressed: () => {
                          Navigator.of(context).pop(),
                          Navigator.of(context).pop(),
                          Navigator.of(context).pop(),
                          Navigator.of(context).push(globals.gotoPage(UploadMaterialPage(),Duration(seconds: 0, milliseconds: 0))),
                          globals.fileListReloaded = false,
                          Navigator.of(context).push(globals.gotoPage(FilesSelecter(),Duration(seconds: 0, milliseconds: 0))),
                          globals.linksListReloaded = false,
                          Navigator.of(context).push(globals.gotoPage(LinkSelecter(),Duration(seconds: 0, milliseconds: 0))),
                        },
                        label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_Preview_EditLinks],
                          style: TextStyle(fontSize: globals.fontSize_Small),),
                        icon: Icon(Icons.link_rounded),
                      ),
                    ],
                  ),
                  FloatingActionButton.extended(
                    heroTag: null,
                    onPressed: () async {
                      globals.isRetry = false;
                      globals.newMaterial_FilesUploader_failFilesList = new List<File>();
                      Navigator.of(context)
                          .pushAndRemoveUntil(globals.gotoPage(globals.filesUploader_GUI_Page,Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false);
                    },
                    label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.ConfirmUpload],
                    style: TextStyle(fontSize: globals.fontSize_Small),),
                    icon: Icon(Icons.cloud_upload),
                  ),
                ],
              )
            )
        )
    );
  }
}