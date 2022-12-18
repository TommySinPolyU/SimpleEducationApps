import 'dart:math';

import 'package:smeapp/Components/CourseContentUploader/LinkSelecter.dart';
import 'package:smeapp/CustomWidget/CustomDialog.dart';
import '../../Helper/ComponentsList.dart';
import 'dart:io';
import '../../Helper/global_setting.dart' as globals;
import 'package:path/path.dart';
import 'dart:async';
import 'package:smeapp/Helper/Localizations.dart';
import 'PreviewUploadPage.dart';

class FilesSelecter extends StatefulWidget{
  FilesSelecter({Key key}) : super(key: key);
  @override
  FilesSelecter_State createState() => FilesSelecter_State();
}

class FilesSelecter_State extends State<FilesSelecter> {
  // region Variables Initialization
  String _widgetTitle = "";
  // Boolean variable for Floating Button.
  bool visible_floatButtom = true;
  dialog_Status _dialog_status;
  String dialog_Msg;
  // endregion

  int _filesLimitRemaining = fileTotalNumberLimit - globals.newMaterial_FilesUploader_fileList.length -
      globals.materialEditor_AttachmentThumb.length + globals.materialEditor_deleteAttachmentFilesName.length;

  // region State Initialization
  @override
  void initState() {
    super.initState();
  }
  // endregion

  // region Build
  @override
  Widget build(BuildContext context) {
    void _filesListReload() async{
      List<Widget> thumbs = new List<Widget>();
      List<Widget> thumbs_forPreview = new List<Widget>();
      VoidCallback deleteSelection;
      //print("FileslistReload");

      _filesLimitRemaining = fileTotalNumberLimit - globals.newMaterial_FilesUploader_fileList.length -
          globals.materialEditor_AttachmentThumb.length + globals.materialEditor_deleteAttachmentFilesName.length;

      // region Counter of Remaining File Limit
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
                    Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_FilesRemaining] +
                        (_filesLimitRemaining).toString(),
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
      // endregion

      // region Title of Server-side Attachment
      if(globals.materialEditor_AttachmentThumb.length > 0){
        await thumbs.add(Container(
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_ServerAttachment],
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
      if(globals.materialEditor_AttachmentThumb.length > 0){
        List<Widget> _attachmentthumbs = new List<Widget>();
        List<Widget> _attachmentthumbs_Preview = new List<Widget>();
        List<Widget> _attachmentDelete_thumbs_Preview = new List<Widget>();

        if(globals.materialEditor_CurrentAttachmentStatus.where((element) => element == true).toList().length > 0){
          await _attachmentthumbs_Preview.add(Container(
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_ServerAttachment_WillKeep],
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

        if(globals.materialEditor_deleteAttachmentFilesName.length > 0){
          await _attachmentDelete_thumbs_Preview.add(Container(
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_ServerAttachment_WillDelete],
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

        for(int i = 0; i < globals.materialEditor_AttachmentThumb.length; i++){
          String fileSizeDisplay;
          if(globals.materialListItem.att_list[i].attExt != "URL"){
            int fileSizeInBytes = globals.materialListItem.att_list[i].attSize;
            double fileSizeInKB = fileSizeInBytes / 1024;
            double fileSizeInMB = fileSizeInKB / 1024;
            if(fileSizeInMB >= 1.0)
              fileSizeDisplay = fileSizeInMB.toStringAsFixed(2) + " MB";
            else {
              fileSizeDisplay = fileSizeInKB.toStringAsFixed(2) + " KB";
            }
          }
          Widget flatbtn_delete = SizedBox(
              width: double.infinity,
              child: FlatButton(
                onPressed: () async => {
                  if(!globals.materialEditor_deleteAttachmentFilesName.contains(globals.materialListItem.att_list[i].attName)){
                    globals.materialEditor_deleteAttachmentFilesName.add(globals.materialListItem.att_list[i].attName),
                    globals.materialEditor_keepAttachmentFilesName.remove(globals.materialListItem.att_list[i].attName),
                    setState(() {
                      globals.materialEditor_CurrentAttachmentStatus[i] = false;
                    })
                  } else {
                    if(_filesLimitRemaining > 0){
                      globals.materialEditor_deleteAttachmentFilesName.remove(globals.materialListItem.att_list[i].attName),
                      globals.materialEditor_keepAttachmentFilesName.add(globals.materialListItem.att_list[i].attName),
                      setState(() {
                        globals.materialEditor_CurrentAttachmentStatus[i] = true;
                      })
                    } else {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) =>
                            CustomDialog_Confirm(
                              dialog_type: dialog_Status.Error,
                              description: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_OverLimitOfSelection],
                            ),
                      ),
                    }
                  },
                  //print("Keep Files: " + globals.materialEditor_keepAttachmentFilesName.join(",")),
                  //print("Delete Files: " + globals.materialEditor_deleteAttachmentFilesName.join(",")),
                  //print(globals.materialEditor_CurrentAttachmentStatus),
                  _filesListReload(),
                },
                child: globals.materialEditor_CurrentAttachmentStatus[i] ? new Icon(Icons.delete_forever) : new Icon(Icons.undo),
              )
          );

          // region Add Thumb to thumbs list
          // Identified Image Extension ==> Output Image Container
          if (globals.picExt.contains('.'+globals.materialListItem.att_list[i].attExt.toLowerCase())) {
            await _attachmentthumbs.add(Padding(
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
                                child: Text((globals.materialListItem.att_list[i].attName + "\n(" +
                                    fileSizeDisplay + ")"), style: TextStyle(
                                    color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                              ),
                              Expanded(
                                  flex: 2,
                                  child: image_Icon
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
                                                        showDialog(
                                                            context: context,
                                                            builder: (image_preview) {
                                                              return Dialog(
                                                                elevation: 16,
                                                                child: Container(
                                                                    child: new Image.network(Server_Protocol + globals.materialListItem.att_list[i].attPath)
                                                                ),
                                                              );
                                                            })
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
                            color:  globals.materialEditor_CurrentAttachmentStatus[i] ? Colors.lightGreenAccent : Colors.redAccent,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              globals.materialEditor_CurrentAttachmentStatus[i]
                                  ? Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_ServerAttachment_Keep],
                              style: TextStyle(color: Colors.black),)
                                  : Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_ServerAttachment_Delete],
                              style: TextStyle(color: Colors.white),),
                            ],
                          )
                        )
                      ],
                    )
                ),
              ));
            if(globals.materialEditor_CurrentAttachmentStatus[i])
              await _attachmentthumbs_Preview.add(Padding(
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
                              child: Text(globals.materialListItem.att_list[i].attName + "\n(" + fileSizeDisplay + ")", style: TextStyle(color: appPrimaryColor,  fontSize: globals.fontSize_Middle),),
                            ),
                            Expanded(
                                flex: 3,
                                child: image_Icon
                            ),
                          ]
                      ),
                    ],
                  )
              ),
            ));
            else
              await _attachmentDelete_thumbs_Preview.add(Padding(
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
                                child: Text(globals.materialListItem.att_list[i].attName + "\n(" + fileSizeDisplay + ")", style: TextStyle(color: appPrimaryColor,  fontSize: globals.fontSize_Middle),),
                              ),
                              Expanded(
                                  flex: 3,
                                  child: image_Icon
                              ),
                            ]
                        ),
                      ],
                    )
                ),
              ));
          }
          // Identified Document Extension ==> Output Doc Container
          else if(globals.docExt.contains('.'+globals.materialListItem.att_list[i].attExt.toLowerCase())){
            await _attachmentthumbs.add(Padding(
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
                              child: Text((globals.materialListItem.att_list[i].attName + "\n(" +
                                  fileSizeDisplay + ")"), style: TextStyle(
                                  color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                            ),
                            Expanded(
                                flex: 2,
                                child: doc_Icon
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: <Widget>[
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
                            color:  globals.materialEditor_CurrentAttachmentStatus[i] ? Colors.lightGreenAccent : Colors.redAccent,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              globals.materialEditor_CurrentAttachmentStatus[i]
                                  ? Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_ServerAttachment_Keep],
                                style: TextStyle(color: Colors.black),)
                                  : Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_ServerAttachment_Delete],
                                style: TextStyle(color: Colors.white),),
                            ],
                          )
                      )
                    ],
                  )
              ),
            ));
            if(globals.materialEditor_CurrentAttachmentStatus[i])
              await _attachmentthumbs_Preview.add(Padding(
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
                                child: Text(globals.materialListItem.att_list[i].attName + "\n(" + fileSizeDisplay + ")", style: TextStyle(color: appPrimaryColor,  fontSize: globals.fontSize_Middle),),
                              ),
                              Expanded(
                                  flex: 3,
                                  child: doc_Icon
                              ),
                            ]
                        ),
                      ],
                    )
                ),
              ));
            else
              await _attachmentDelete_thumbs_Preview.add(Padding(
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
                                child: Text(globals.materialListItem.att_list[i].attName + "\n(" + fileSizeDisplay + ")", style: TextStyle(color: appPrimaryColor,  fontSize: globals.fontSize_Middle),),
                              ),
                              Expanded(
                                  flex: 3,
                                  child: doc_Icon
                              ),
                            ]
                        ),
                      ],
                    )
                ),
              ));
          }
          // Identified PDF Extension ==> Output PDF Container
          else if(globals.materialListItem.att_list[i].attExt.toLowerCase() == 'pdf'){
            await _attachmentthumbs.add(Padding(
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
                              child: Text((globals.materialListItem.att_list[i].attName + "\n(" +
                                  fileSizeDisplay + ")"), style: TextStyle(
                                  color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                            ),
                            Expanded(
                                flex: 2,
                                child: pdf_Icon
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: <Widget>[
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
                            color:  globals.materialEditor_CurrentAttachmentStatus[i] ? Colors.lightGreenAccent : Colors.redAccent,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              globals.materialEditor_CurrentAttachmentStatus[i]
                                  ? Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_ServerAttachment_Keep],
                                style: TextStyle(color: Colors.black),)
                                  : Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_ServerAttachment_Delete],
                                style: TextStyle(color: Colors.white),),
                            ],
                          )
                      )
                    ],
                  )
              ),
            ));
            if(globals.materialEditor_CurrentAttachmentStatus[i])
              await _attachmentthumbs_Preview.add(Padding(
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
                                child: Text(globals.materialListItem.att_list[i].attName + "\n(" + fileSizeDisplay + ")", style: TextStyle(color: appPrimaryColor,  fontSize: globals.fontSize_Middle),),
                              ),
                              Expanded(
                                  flex: 3,
                                  child: pdf_Icon
                              ),
                            ]
                        ),
                      ],
                    )
                ),
              ));
            else
              await _attachmentDelete_thumbs_Preview.add(Padding(
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
                                child: Text(globals.materialListItem.att_list[i].attName + "\n(" + fileSizeDisplay + ")", style: TextStyle(color: appPrimaryColor,  fontSize: globals.fontSize_Middle),),
                              ),
                              Expanded(
                                  flex: 3,
                                  child: pdf_Icon
                              ),
                            ]
                        ),
                      ],
                    )
                ),
              ));
          }
          // Identified MP3 Extension ==> Output Music Container
          else if(globals.materialListItem.att_list[i].attExt.toLowerCase() == 'mp3'){
            await _attachmentthumbs.add(Padding(
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
                              child: Text((globals.materialListItem.att_list[i].attName + "\n(" +
                                  fileSizeDisplay + ")"), style: TextStyle(
                                  color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                            ),
                            Expanded(
                                flex: 2,
                                child: music_Icon
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: <Widget>[
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
                            color:  globals.materialEditor_CurrentAttachmentStatus[i] ? Colors.lightGreenAccent : Colors.redAccent,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              globals.materialEditor_CurrentAttachmentStatus[i]
                                  ? Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_ServerAttachment_Keep],
                                style: TextStyle(color: Colors.black),)
                                  : Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_ServerAttachment_Delete],
                                style: TextStyle(color: Colors.white),),
                            ],
                          )
                      )
                    ],
                  )
              ),
            ));
            if(globals.materialEditor_CurrentAttachmentStatus[i])
              await _attachmentthumbs_Preview.add(Padding(
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
                                child: Text(globals.materialListItem.att_list[i].attName + "\n(" + fileSizeDisplay + ")", style: TextStyle(color: appPrimaryColor,  fontSize: globals.fontSize_Middle),),
                              ),
                              Expanded(
                                  flex: 3,
                                  child: music_Icon
                              ),
                            ]
                        ),
                      ],
                    )
                ),
              ));
            else
              await _attachmentDelete_thumbs_Preview.add(Padding(
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
                                child: Text(globals.materialListItem.att_list[i].attName + "\n(" + fileSizeDisplay + ")", style: TextStyle(color: appPrimaryColor,  fontSize: globals.fontSize_Middle),),
                              ),
                              Expanded(
                                  flex: 3,
                                  child: music_Icon
                              ),
                            ]
                        ),
                      ],
                    )
                ),
              ));
          }
          // Identified MP4 Extension ==> Output Video Container
          else if(globals.materialListItem.att_list[i].attExt.toLowerCase() == 'mp4'){
            await _attachmentthumbs.add(Padding(
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
                              child: Text((globals.materialListItem.att_list[i].attName + "\n(" +
                                  fileSizeDisplay + ")"), style: TextStyle(
                                  color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                            ),
                            Expanded(
                                flex: 2,
                                child: video_Icon
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: <Widget>[
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
                            color:  globals.materialEditor_CurrentAttachmentStatus[i] ? Colors.lightGreenAccent : Colors.redAccent,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              globals.materialEditor_CurrentAttachmentStatus[i]
                                  ? Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_ServerAttachment_Keep],
                                style: TextStyle(color: Colors.black),)
                                  : Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_ServerAttachment_Delete],
                                style: TextStyle(color: Colors.white),),
                            ],
                          )
                      )
                    ],
                  )
              ),
            ));
            if(globals.materialEditor_CurrentAttachmentStatus[i])
              await _attachmentthumbs_Preview.add(Padding(
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
                                child: Text(globals.materialListItem.att_list[i].attName + "\n(" + fileSizeDisplay + ")", style: TextStyle(color: appPrimaryColor,  fontSize: globals.fontSize_Middle),),
                              ),
                              Expanded(
                                  flex: 3,
                                  child: video_Icon
                              ),
                            ]
                        ),
                      ],
                    )
                ),
              ));
            else
              await _attachmentDelete_thumbs_Preview.add(Padding(
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
                                child: Text(globals.materialListItem.att_list[i].attName + "\n(" + fileSizeDisplay + ")", style: TextStyle(color: appPrimaryColor,  fontSize: globals.fontSize_Middle),),
                              ),
                              Expanded(
                                  flex: 3,
                                  child: video_Icon
                              ),
                            ]
                        ),
                      ],
                    )
                ),
              ));
          }
          else if(globals.materialListItem.att_list[i].attExt.toLowerCase() == 'zip'){
            await _attachmentthumbs.add(Padding(
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
                              child: Text((globals.materialListItem.att_list[i].attName + "\n(" +
                                  fileSizeDisplay + ")"), style: TextStyle(
                                  color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                            ),
                            Expanded(
                                flex: 2,
                                child: zip_Icon
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: <Widget>[
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
                            color:  globals.materialEditor_CurrentAttachmentStatus[i] ? Colors.lightGreenAccent : Colors.redAccent,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              globals.materialEditor_CurrentAttachmentStatus[i]
                                  ? Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_ServerAttachment_Keep],
                                style: TextStyle(color: Colors.black),)
                                  : Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_ServerAttachment_Delete],
                                style: TextStyle(color: Colors.white),),
                            ],
                          )
                      )
                    ],
                  )
              ),
            ));
            if(globals.materialEditor_CurrentAttachmentStatus[i])
              await _attachmentthumbs_Preview.add(Padding(
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
                                child: Text(globals.materialListItem.att_list[i].attName + "\n(" + fileSizeDisplay + ")", style: TextStyle(color: appPrimaryColor,  fontSize: globals.fontSize_Middle),),
                              ),
                              Expanded(
                                  flex: 3,
                                  child: zip_Icon
                              ),
                            ]
                        ),
                      ],
                    )
                ),
              ));
            else
              await _attachmentDelete_thumbs_Preview.add(Padding(
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
                                child: Text(globals.materialListItem.att_list[i].attName + "\n(" + fileSizeDisplay + ")", style: TextStyle(color: appPrimaryColor,  fontSize: globals.fontSize_Middle),),
                              ),
                              Expanded(
                                  flex: 3,
                                  child: zip_Icon
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
        globals.materialEditor_AttachmentThumb = _attachmentthumbs;
        globals.server_AttachmentsThumb_Preview = _attachmentthumbs_Preview;
        globals.server_AttachmentsDeleteThumb_Preview = _attachmentDelete_thumbs_Preview;
        await thumbs.add(
          InkWell(
            child: Container(
              child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                  itemCount: globals.materialEditor_AttachmentThumb.length, // number of items in your list
                  //here the implementation of itemBuilder. take a look at flutter docs to see details
                  itemBuilder: (BuildContext context, int Itemindex){
                    return globals.materialEditor_AttachmentThumb[Itemindex]; // return your widget
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
                    Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_NewAttachment],
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
      if(globals.newMaterial_FilesUploader_fileList.length > 0) {
        await thumbs_forPreview.add(Container(
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_NewAttachment_WillAdd],
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
        for (File element in globals.newMaterial_FilesUploader_fileList) {
          deleteSelection = () =>
          {
            globals.newMaterial_FilesUploader_fileList.remove(element),
            globals.fileListReloaded = false,
            Navigator.pop(context),
            Navigator.of(context).push(
                globals.gotoPage(FilesSelecter(), Duration(seconds: 0))),
          };
          //print("Loading Element: " + element.path);
          // Get File Size
          String fileSizeDisplay;
          int fileSizeInBytes = element.lengthSync();
          double fileSizeInKB = fileSizeInBytes / 1024;
          double fileSizeInMB = fileSizeInKB / 1024;
          if (fileSizeInMB >= 1.0)
            fileSizeDisplay = fileSizeInMB.toStringAsFixed(2) + " MB";
          else {
            fileSizeDisplay = fileSizeInKB.toStringAsFixed(2) + " KB";
          }

          //region Add Thumb to thumbs list
          // Identified Image Extension ==> Output Image Container
          if (globals.picExt.contains(extension(element.path).toLowerCase())) {
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
                              child: Text(basename(element.path) + "\n(" +
                                  fileSizeDisplay + ")", style: TextStyle(
                                  color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                            ),
                            Expanded(
                                flex: 2,
                                child: image_Icon
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
                                                  showDialog(
                                                      context: context,
                                                      builder: (image_preview) {
                                                        return Dialog(
                                                          elevation: 16,
                                                          child: Container(
                                                              child: new Image
                                                                  .file(element)
                                                          ),
                                                        );
                                                      })
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
            ));
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
                              child: Text(basename(element.path) + "\n(" +
                                  fileSizeDisplay + ")", style: TextStyle(
                                  color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                            ),
                            Expanded(
                                flex: 3,
                                child: image_Icon
                            ),
                          ]
                      ),
                    ],
                  )
              ),
            ));
          }
          // Identified Document Extension ==> Output Doc Container
          else if (globals.docExt.contains(extension(element.path).toLowerCase())) {
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
                              child: Text(basename(element.path) + "\n(" +
                                  fileSizeDisplay + ")", style: TextStyle(
                                  color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                            ),
                            Expanded(
                                flex: 2,
                                child: doc_Icon
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: <Widget>[
                                  Row(
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
            ));
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
                              child: Text(basename(element.path) + "\n(" +
                                  fileSizeDisplay + ")", style: TextStyle(
                                  color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                            ),
                            Expanded(
                                flex: 3,
                                child: doc_Icon
                            ),
                          ]
                      ),
                    ],
                  )
              ),
            ));
          }
          // Identified PDF Extension ==> Output PDF Container
          else if (extension(element.path).toLowerCase() == '.pdf') {
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
                              child: Text(basename(element.path) + "\n(" +
                                  fileSizeDisplay + ")", style: TextStyle(
                                  color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                            ),
                            Expanded(
                                flex: 2,
                                child: pdf_Icon
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: <Widget>[
                                  Row(
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
            ));
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
                              child: Text(basename(element.path) + "\n(" +
                                  fileSizeDisplay + ")", style: TextStyle(
                                  color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                            ),
                            Expanded(
                                flex: 3,
                                child: pdf_Icon
                            ),
                          ]
                      ),
                    ],
                  )
              ),
            ));
          }
          // Identified MP3 Extension ==> Output Music Container
          else if (extension(element.path).toLowerCase() == '.mp3') {
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
                              child: Text(basename(element.path) + "\n(" +
                                  fileSizeDisplay + ")", style: TextStyle(
                                  color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                            ),
                            Expanded(
                                flex: 2,
                                child: music_Icon
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: <Widget>[
                                  Row(
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
            ));
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
                              child: Text(basename(element.path) + "\n(" +
                                  fileSizeDisplay + ")", style: TextStyle(
                                  color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                            ),
                            Expanded(
                                flex: 3,
                                child: music_Icon
                            ),
                          ]
                      ),
                    ],
                  )
              ),
            ));
          }
          // Identified MP4 Extension ==> Output Video Container
          else if (extension(element.path).toLowerCase() == '.mp4') {
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
                              child: Text(basename(element.path) + "\n(" +
                                  fileSizeDisplay + ")", style: TextStyle(
                                  color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                            ),
                            Expanded(
                                flex: 2,
                                child: video_Icon
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: <Widget>[
                                  Row(
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
            ));
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
                              child: Text(basename(element.path) + "\n(" +
                                  fileSizeDisplay + ")", style: TextStyle(
                                  color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                            ),
                            Expanded(
                                flex: 3,
                                child: video_Icon
                            ),
                          ]
                      ),
                    ],
                  )
              ),
            ));
          }
          else if (extension(element.path).toLowerCase() == '.zip') {
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
                              child: Text(basename(element.path) + "\n(" +
                                  fileSizeDisplay + ")", style: TextStyle(
                                  color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                            ),
                            Expanded(
                                flex: 2,
                                child: zip_Icon
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: <Widget>[
                                  Row(
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
            ));
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
                              child: Text(basename(element.path) + "\n(" +
                                  fileSizeDisplay + ")", style: TextStyle(
                                  color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                            ),
                            Expanded(
                                flex: 3,
                                child: zip_Icon
                            ),
                          ]
                      ),
                    ],
                  )
              ),
            ));
          }
          else {
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
                              child: Text(basename(element.path) + "\n(" +
                                  fileSizeDisplay + ")", style: TextStyle(
                                  color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                            ),
                            Expanded(
                                flex: 2,
                                child: music_Icon
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: <Widget>[
                                  Row(
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
            ));
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
                              child: Text(basename(element.path) + "\n(" +
                                  fileSizeDisplay + ")", style: TextStyle(
                                  color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                            ),
                            Expanded(
                                flex: 3,
                                child: music_Icon
                            ),
                          ]
                      ),
                    ],
                  )
              ),
            ));
          }
        }
      }
      //endregion
      //endregion

      setState(()  {
        //print("SetState");
        globals.fileListThumb = thumbs;
        globals.fileListThumb_Preview = thumbs_forPreview;
      });
      globals.fileListReloaded = true;
      visible_floatButtom = true;
    }

    List<File> toFileList(List<String> FilePathStringList) {

      List<File> _fileList = new List<File>();
      for (String path in FilePathStringList){
        _fileList.add(File(path));
      }
      return _fileList;
    }

    /* pickFiles:
      Open the files picker when call this function
    */

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

    if (globals.newMaterial_FilesUploader_fileList.length == 0 && globals.materialEditor_AttachmentThumb.length == 0) {
      globals.fileListThumb = [
        InkWell(
          child: Container(
              alignment: Alignment.center,
              child: Text(Localizations_Text[globals
                  .CurrentLang][Localizations_Text_Identifier
                  .Material_FilesSelecter_Manual],
                style: TextStyle(fontSize: globals.fontSize_Middle, fontWeight: FontWeight.bold),)
          ),
        )
      ];
    }
    else {
      if(globals.fileListReloaded != true) {
        print("call Reload");
        _filesListReload();
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appTitleBarColor,
        title: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_UploadAttachment],
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
                itemCount: globals.fileListThumb.length, // number of items in your list
                //here the implementation of itemBuilder. take a look at flutter docs to see details
                itemBuilder: (BuildContext context, int Itemindex){
                  return globals.fileListThumb[Itemindex]; // return your widget
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
                heroTag: 'FAB3',
                onPressed: () async {
                  if ((_filesLimitRemaining) > 0) {
                    pickFiles();
                  } else {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) =>
                          CustomDialog_Confirm(
                            dialog_type: dialog_Status.Error,
                            description: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_OverLimitOfSelection],
                          ),
                    );
                  }
                },
                label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesSelecter_AddFiles],
                style: TextStyle(fontSize: globals.fontSize_Normal),),
                icon: Icon(Icons.add),
              ),
              FloatingActionButton.extended(
                heroTag: 'FAB4',
                onPressed: () async {
                  //FilesUploader.uploadAllFiles(globals.newMaterial_FilesUploader_fileList);
                  globals.linksListReloaded = false;
                  Navigator.of(context).push(globals.gotoPage(LinkSelecter(),Duration(seconds: 0, milliseconds: 500)));
                },
                label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_UploadLinks],
                style: TextStyle(fontSize: globals.fontSize_Normal),),
                icon: Icon(Icons.add_link),
              )
            ],
          ),
        ),
      )
    );
  }
  // endregion
}
