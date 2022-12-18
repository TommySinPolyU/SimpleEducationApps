import 'dart:math';

import 'package:smeapp/Components/Survey/WebBrowser.dart';
import 'package:smeapp/CustomWidget/CustomDialog.dart';
import '../../Helper/ComponentsList.dart';
import 'dart:io';
import '../../Helper/global_setting.dart' as globals;
import 'package:path/path.dart';
import 'dart:async';
import 'package:smeapp/Helper/Localizations.dart';
import 'PreviewUploadPage.dart';

class LinkSelecter extends StatefulWidget{
  LinkSelecter({Key key}) : super(key: key);
  @override
  LinkSelecter_State createState() => LinkSelecter_State();
}

class LinkSelecter_State extends State<LinkSelecter> {
  // region Variables Initialization
  String _widgetTitle = "";
  // Boolean variable for Floating Button.
  bool visible_floatButtom = true;
  dialog_Status _dialog_status;
  String dialog_Msg;
  // endregion

  final _newlinkNameController = TextEditingController();
  final _newlinkURLController = TextEditingController();

  //int _filesLimitRemaining = fileTotalNumberLimit - globals.newMaterial_FilesUploader_fileList.length - globals.materialEditor_AttachmentThumb.length + globals.materialEditor_deleteAttachmentFilesName.length;

  // region State Initialization
  @override
  void initState() {
    super.initState();
  }
  // endregion

  // region Build
  @override
  Widget build(BuildContext context) {
    final label_newlinkname = Padding(
      padding: EdgeInsets.only(left: 20,right: 20, top: 10),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_NewLinks_Dialog_NameLabel],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Middle,
            color: appPrimaryColor),
      ),
    );
    final label_newlinkurl = Padding(
      padding: EdgeInsets.only(left: 20,right: 20, top: 10),
      child: Text(
        Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_NewLinks_Dialog_URLLabel],
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: globals.fontSize_Middle,
            color: appPrimaryColor),
      ),
    );
    final newlink_dialog = Container(
      child: Column(
        children: [
          InkWell(
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54)
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      label_newlinkname,
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          textAlign: TextAlign.right,
                          controller: _newlinkNameController,
                          keyboardType: TextInputType.multiline,
                          maxLength: 32,
                          maxLines: 1,
                          style: TextStyle(
                            color: appPrimaryColor,
                            fontSize: globals.fontSize_Middle,
                          ),
                          onChanged: (text) {

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
              ),
            ),
          ),
          // New Pw Checker: Input Again
          InkWell(
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54)
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      label_newlinkurl,
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          textAlign: TextAlign.right,
                          controller: _newlinkURLController,
                          keyboardType: TextInputType.multiline,
                          maxLength: 1024,
                          maxLines: 1,
                          style: TextStyle(
                            color: appPrimaryColor,
                            fontSize: globals.fontSize_Middle,
                          ),
                          onChanged: (text) {

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
              ),
            ),
          ),
        ],
      ),
    );

    void _linksListReload() async{
      List<Widget> thumbs = new List<Widget>();
      List<Widget> thumbs_forPreview = new List<Widget>();
      VoidCallback deleteSelection;
      //print("FileslistReload");

      //_filesLimitRemaining = fileTotalNumberLimit - globals.newMaterial_FilesUploader_fileList.length - globals.materialEditor_AttachmentThumb.length + globals.materialEditor_deleteAttachmentFilesName.length;

      // region Title of Server-side Attachment
      if(globals.materialEditor_LinksThumb.length > 0){
        await thumbs.add(Container(
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_ServerLinks],
                        style: TextStyle(fontSize: globals.fontSize_Middle, fontWeight: FontWeight.bold),)
                    ]
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Divider(
                          height: 15,
                          thickness: 3,
                          color: Colors.black
                      ),
                    )
                  ],
                )
              ],
            )
        ));
      }
      // endregion

      // region Reload attachment of content from server response
      if(globals.materialEditor_LinksThumb.length > 0){
        List<Widget> _linksthumbs = new List<Widget>();
        List<Widget> _linksthumbs_Preview = new List<Widget>();
        List<Widget> _linksDelete_thumbs_Preview = new List<Widget>();

        if(globals.materialEditor_CurrentLinksStatus.where((element) => element == true).toList().length > 0){
          await _linksthumbs_Preview.add(Container(
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_ServerLinks_WillKeep],
                          style: TextStyle(fontSize: globals.fontSize_Middle, fontWeight: FontWeight.bold),)
                      ]
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Divider(
                            height: 15,
                            thickness: 3,
                            color: Colors.black
                        ),
                      )
                    ],
                  )
                ],
              )
          ));
        }

        if(globals.materialEditor_deleteLinksName.length > 0){
          await _linksDelete_thumbs_Preview.add(Container(
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_ServerLinks_WillDelete],
                          style: TextStyle(fontSize: globals.fontSize_Middle, fontWeight: FontWeight.bold),)
                      ]
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Divider(
                            height: 15,
                            thickness: 3,
                            color: Colors.black
                        ),
                      )
                    ],
                  )
                ],
              )
          ));
        }

        for(int i = 0; i < globals.materialEditor_LinksThumb.length; i++){
          Widget flatbtn_delete = SizedBox(
              width: double.infinity,
              child: FlatButton(
                onPressed: () async => {
                  if(!globals.materialEditor_deleteLinksName.contains(globals.materialListItem.att_list[i + globals.materialEditor_AttachmentThumb.length].attName)){
                    globals.materialEditor_deleteLinksName.add(globals.materialListItem.att_list[i + globals.materialEditor_AttachmentThumb.length].attName),
                    globals.materialEditor_keepLinksName.remove(globals.materialListItem.att_list[i + globals.materialEditor_AttachmentThumb.length].attName),
                    setState(() {
                      globals.materialEditor_CurrentLinksStatus[i] = false;
                    })
                  },
                  //print("Keep Files: " + globals.materialEditor_keepAttachmentFilesName.join(",")),
                  //print("Delete Files: " + globals.materialEditor_deleteAttachmentFilesName.join(",")),
                  //print(globals.materialEditor_CurrentAttachmentStatus),
                  _linksListReload(),
                },
                child: globals.materialEditor_CurrentLinksStatus[i] ? new Icon(Icons.delete_forever) : new Icon(Icons.undo),
              )
          );

          print(globals.materialListItem.att_list[i + globals.materialEditor_AttachmentThumb.length].attName + ", " +
              globals.materialListItem.att_list[i + globals.materialEditor_AttachmentThumb.length].attPath + ", " +
              globals.materialListItem.att_list[i + globals.materialEditor_AttachmentThumb.length].attExt + "\n");
          // region Add Thumb to thumbs list
          // Identified URL Extension ==> Output URL Container
          if(globals.materialListItem.att_list[i + globals.materialEditor_AttachmentThumb.length].attExt.toLowerCase() == "url"){
            await _linksthumbs.add(Padding(
              padding: (EdgeInsets.only(top:5, bottom: 5)),
              child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54)
                  ),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      Row(
                          children: <Widget>[
                            Expanded(
                              flex: 6,
                              child: Text((globals.materialListItem.att_list[i + globals.materialEditor_AttachmentThumb.length].attName + "\n" +
                                  globals.materialListItem.att_list[i + globals.materialEditor_AttachmentThumb.length].attPath + ""), style: TextStyle(
                                  color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                            ),
                            Expanded(
                                flex: 2,
                                child: url_Icon
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    // Preview Image Button
                                    children: <Widget>[
                                      Flexible(
                                        child: Card(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              SizedBox(
                                                  width: double.infinity,
                                                  child: FlatButton(
                                                    child: Icon(Icons.remove_red_eye),
                                                    onPressed: () async => {
                                                      globals.browser_url = globals.materialListItem.att_list[i + globals.materialEditor_AttachmentThumb.length].attPath,
                                                      globals.browser_Title = globals.materialListItem.att_list[i + globals.materialEditor_AttachmentThumb.length].attName,
                                                      Navigator.of(context).push(globals.gotoPage(WebBrowser(),Duration(seconds: 0, milliseconds: 500))),
                                                    },
                                                  )
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Remove Attachment Button
                                  Row(
                                    children: <Widget>[
                                      Flexible(
                                        child: Card(
                                          child: Column(
                                            children: <Widget>[
                                              flatbtn_delete
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ]
                      ),
                      Container(
                          decoration: BoxDecoration(
                            border: null,
                            color:  globals.materialEditor_CurrentLinksStatus[i] ? Colors.lightGreenAccent : Colors.redAccent,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              globals.materialEditor_CurrentLinksStatus[i]
                                  ? Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_ServerLinks_Keep],
                                style: TextStyle(color: Colors.black),)
                                  : Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_ServerLinks_Delete],
                                style: TextStyle(color: Colors.white),),
                            ],
                          )
                      )
                    ],
                  )
              ),
            ));

            if(globals.materialEditor_CurrentLinksStatus[i])
              await _linksthumbs_Preview.add(Padding(
                padding: (EdgeInsets.only(top:5, bottom: 5)),
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        border: Border.all(color: Colors.black54)
                    ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: <Widget>[
                        Row(
                            children: <Widget>[
                              Expanded(
                                flex: 7,
                                child: Text(globals.materialListItem.att_list[i + globals.materialEditor_AttachmentThumb.length].attName + "\n(" + globals.materialListItem.att_list[i + globals.materialEditor_AttachmentThumb.length].attPath + ")", style: TextStyle(color: appPrimaryColor,  fontSize: globals.fontSize_Middle),),
                              ),
                              Expanded(
                                  flex: 3,
                                  child: url_Icon
                              ),
                            ]
                        ),
                      ],
                    )
                ),
              ));
            else
              await _linksDelete_thumbs_Preview.add(Padding(
                padding: (EdgeInsets.only(top:5, bottom: 5)),
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.redAccent,
                        border: Border.all(color: Colors.black54)
                    ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: <Widget>[
                        Row(
                            children: <Widget>[
                              Expanded(
                                flex: 7,
                                child: Text(globals.materialListItem.att_list[i + globals.materialEditor_AttachmentThumb.length].attName + "\n(" + globals.materialListItem.att_list[i + globals.materialEditor_AttachmentThumb.length].attPath + ")", style: TextStyle(color: appPrimaryColor,  fontSize: globals.fontSize_Middle),),
                              ),
                              Expanded(
                                  flex: 3,
                                  child: url_Icon
                              ),
                            ]
                        ),
                      ],
                    )
                ),
              ));
          }
          // endregion
        }

        globals.materialEditor_LinksThumb = _linksthumbs;
        globals.server_LinksThumb_Preview = _linksthumbs_Preview;
        globals.server_LinksDeleteThumb_Preview = _linksDelete_thumbs_Preview;
        await thumbs.add(
            InkWell(
              child: Container(
                child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: globals.materialEditor_LinksThumb.length, // number of items in your list
                    //here the implementation of itemBuilder. take a look at flutter docs to see details
                    itemBuilder: (BuildContext context, int Itemindex){
                      return globals.materialEditor_LinksThumb[Itemindex]; // return your widget
                    }
                ),
              ),
            )
        );
      }
      //endregion

      //region Title of New Attachment List
      await thumbs.add(Container(
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Divider(
                        height: 15,
                        thickness: 3,
                        color: Colors.black
                    ),
                  )
                ],
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_NewLinks],
                      style: TextStyle(fontSize: globals.fontSize_Middle, fontWeight: FontWeight.bold),)
                  ]
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Divider(
                        height: 15,
                        thickness: 3,
                        color: Colors.black
                    ),
                  )
                ],
              )
            ],
          )
      ));
      //endregion

      // region Reload attachment of selected files by user from selector
      if(globals.newMaterial_FilesUploader_linksList.length > 0) {
        await thumbs_forPreview.add(Container(
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_NewLinks_WillAdd],
                        style: TextStyle(fontSize: globals.fontSize_Middle, fontWeight: FontWeight.bold),)
                    ]
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Divider(
                          height: 15,
                          thickness: 3,
                          color: Colors.black
                      ),
                    )
                  ],
                )
              ],
            )
        ));
        globals.newMaterial_FilesUploader_linksList.forEach((k,v) async => {
          deleteSelection = () =>
          {
            globals.newMaterial_FilesUploader_linksList.remove(k),
            globals.linksListReloaded = false,
            Navigator.pop(context),
            Navigator.of(context).push(globals.gotoPage(LinkSelecter(), Duration(seconds: 0))),
          },
          //print("Loading Element: " + element.path);

          //region Add Thumb to thumbs list
          await thumbs.add(Padding(
            padding: (EdgeInsets.only(top: 5, bottom: 5)),
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54)
                ),
                padding: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    Row(
                        children: <Widget>[
                          Expanded(
                            flex: 6,
                            child: Text(k + "\n" +
                                v + "", style: TextStyle(
                                color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                          ),
                          Expanded(
                              flex: 2,
                              child: url_Icon
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: <Widget>[
                                // Preview Image Button
                                Row(
                                  children: <Widget>[
                                    Flexible(
                                      child: Card(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: <Widget>[
                                            FlatButton(
                                              onPressed: () =>
                                              {
                                                globals.browser_url = v,
                                                globals.browser_Title = k,
                                                Navigator.of(context).push(globals.gotoPage(WebBrowser(),Duration(seconds: 0, milliseconds: 500))),
                                              },
                                              child: Column(
                                                children: <Widget>[
                                                  Icon(Icons.remove_red_eye)
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ), Row(
                                  // Remove Attachment Button
                                  children: <Widget>[
                                    Flexible(
                                      child: Card(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: <Widget>[
                                            FlatButton(
                                              onPressed: deleteSelection,
                                              child: Column(
                                                children: <Widget>[
                                                  Icon(Icons.cancel)
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ]
                    ),
                  ],
                )
            ),
          )),
          await thumbs_forPreview.add(Padding(
            padding: (EdgeInsets.only(top: 5, bottom: 5)),
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54)
                ),
                padding: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    Row(
                        children: <Widget>[
                          Expanded(
                            flex: 7,
                            child: Text(k + "\n" +
                                v + "", style: TextStyle(
                                color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                          ),
                          Expanded(
                              flex: 3,
                              child: url_Icon
                          ),
                        ]
                    ),
                  ],
                )
            ),
          )),
        });
      }
      //endregion
      //endregion

      setState(()  {
        //print("SetState");
        globals.linksThumb = thumbs;
        globals.linksThumb_Preview = thumbs_forPreview;
      });
      globals.linksListReloaded = true;
      visible_floatButtom = true;
    }

    /* pickFiles:
      Open the files picker when call this function
    */
    /*
    Future pickFiles() async {
      List<File> removedFiles = new List<File>();
      globals.fileListReloaded = false;
      Future.delayed(Duration.zero, () => {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) =>
              CustomDialog_Confirm(
                showButton: false,
                dialog_type: dialog_Status.Loading,
                description: Localizations_Text[globals
                    .CurrentLang][Localizations_Text_Identifier
                    .Material_FilesSelecter_LoadingFilesList],
              ),
        )
      });
      FilePickerResult result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: globals.allowedExtensions,
        allowMultiple: true,
      );

      if(result != null) {
        //List<File> files = toFileList(result.paths);
        List<File> files = result.paths.map((path) => File(path)).toList();
        if (files != null && files.length > 0) {
          if(files.length <= fileTotalNumberLimit && ((globals.newMaterial_FilesUploader_fileList.length + globals.materialEditor_AttachmentThumb.length - globals.materialEditor_deleteAttachmentFilesName.length) + files.length) <= fileTotalNumberLimit){
            _dialog_status = dialog_Status.Success;
            files.forEach((element) {
              int fileSizeInBytes = element.lengthSync();
              // Check File Size
              if(fileSizeInBytes <= fileSizeLimitInBytes) {
                globals.newMaterial_FilesUploader_fileList.add(element);
              } else {
                removedFiles.add(element);
              }
            });

            if(removedFiles.length > 0){
              dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_SizeWarningTitle];
              _dialog_status = dialog_Status.Error;
              removedFiles.forEach((element) {
                dialog_Msg += basename(element.path);
                if(removedFiles.last != element){
                  dialog_Msg += '\n\n';
                }
              });
            }
          } else {
            _dialog_status = dialog_Status.Error;
            dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_OverLimitOfSelection];
          }
        }
      }

      Navigator.of(context).pop();

      setState(() {

      });

      if(_dialog_status == dialog_Status.Error) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) =>
              CustomDialog_Confirm(
                dialog_type: _dialog_status,
                description: dialog_Msg,
              ),
        );
      }
    }
    */

    Future addLink() async{
      globals.linksListReloaded = false;
      if(_newlinkNameController.text.isNotEmpty && _newlinkURLController.text.isNotEmpty){
        _dialog_status = dialog_Status.Success;
        dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_InsertLinkSuccess];
        globals.newMaterial_FilesUploader_linksList[_newlinkNameController.text] = _newlinkURLController.text;
        _newlinkNameController.text = "";
        _newlinkURLController.text = "";
      } else {
        _dialog_status = dialog_Status.Error;
        dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_UploadFormNotAllFill];
      }

      if(_dialog_status == dialog_Status.Success){
        Navigator.of(context).pop();
      }

      setState(() {

      });

      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            CustomDialog_Confirm(
              dialog_type: _dialog_status,
              description: dialog_Msg,
            ),
      );
    }

    if (globals.newMaterial_FilesUploader_linksList.length == 0 && globals.materialEditor_LinksThumb.length == 0) {
      print("call Reload: Length Check 0");
      globals.linksThumb = [
        InkWell(
          child: Container(
              alignment: Alignment.center,
              child: Text(Localizations_Text[globals
                  .CurrentLang][Localizations_Text_Identifier
                  .Material_FilesSelecter_AddLinksManual],
                style: TextStyle(fontSize: globals.fontSize_Middle, fontWeight: FontWeight.bold),)
          ),
        )
      ];
    }
    else {
      if(globals.linksListReloaded != true) {
        print("call Reload");
        _linksListReload();
      }
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: appTitleBarColor,
          title: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_UploadLinks],
            style: TextStyle(fontSize: globals.fontSize_Title),),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ),
        body: Center(
            child: Padding(
              padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 90),
              child: ListView.builder(
                  itemCount: globals.linksThumb.length, // number of items in your list
                  //here the implementation of itemBuilder. take a look at flutter docs to see details
                  itemBuilder: (BuildContext context, int Itemindex){
                    return globals.linksThumb[Itemindex]; // return your widget
                  }),
            )
        ),
        floatingActionButtonLocation:
        FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(left: 6, right: 6, bottom: 24),
          child: Visibility(
            visible: visible_floatButtom,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FloatingActionButton.extended(
                  heroTag: 'FAB5',
                  onPressed: () async => {
                    showDialog(
                      useSafeArea: true,
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) =>
                          CustomDialog_Selection(
                            dialog_type: dialog_Status.Custom,
                            title: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_AddLinks],
                            desc_to_widget: true,
                            desc_widget: newlink_dialog,
                            image: Icon(Icons.add_link),
                            callback_Confirm: () async => {
                              addLink()
                            },
                          ),
                    ),
                  },
                  label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_AddLinks],
                    style: TextStyle(fontSize: globals.fontSize_Normal),),
                  icon: Icon(Icons.add),
                ),
                FloatingActionButton.extended(
                  heroTag: 'FAB6',
                  onPressed: () async {
                    //FilesUploader.uploadAllFiles(globals.newMaterial_FilesUploader_fileList);
                    Navigator.of(context).push(globals.gotoPage(PreviewUploadPage(),Duration(seconds: 0, milliseconds: 500)));
                  },
                  label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Preview],
                    style: TextStyle(fontSize: globals.fontSize_Normal),),
                  icon: Icon(Icons.remove_red_eye),
                )
              ],
            ),
          ),
        )
    );
  }
// endregion
}
