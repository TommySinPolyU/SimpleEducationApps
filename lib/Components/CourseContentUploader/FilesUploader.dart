import 'package:flutter/cupertino.dart';

import '../../Helper/ComponentsList.dart';
import 'dart:io';
import 'package:http/http.dart' as http hide File;
import '../../Helper/global_setting.dart' as globals;
import 'package:path/path.dart';
import 'dart:async';
import 'package:smeapp/Helper/Localizations.dart';

// MultipartRequest Function with Progress
// Refer to https://stackoverflow.com/questions/53727911/how-to-get-progress-event-while-uploading-file-on-http-multipartrequest-request
class MultipartRequest extends http.MultipartRequest {
  /// Creates a new [MultipartRequest].
  MultipartRequest(
      String method,
      Uri url, {
        this.onProgress,
      }) : super(method, url);

  final void Function(int bytes, int totalBytes) onProgress;

  /// Freezes all mutable fields and returns a single-subscription [ByteStream]
  /// that will emit the request body.
  http.ByteStream finalize() {
    final byteStream = super.finalize();
    if (onProgress == null) return byteStream;

    final total = this.contentLength;
    int bytes = 0;

    final t = StreamTransformer.fromHandlers(
      handleData: (List<int> data, EventSink<List<int>> sink) {
        bytes += data.length;
        onProgress(bytes, total);
        sink.add(data);
      },
    );
    final stream = byteStream.transform(t);
    return http.ByteStream(stream);
  }
}

class FilesUploader {
  // Dialog Information
  static dialog_Status _dialogStatus = dialog_Status.Error;
  static String dialog_Msg = "", dialog_Msg_Title = "";
  static Image dialog_image;
  // Method for file upload
  static Future<bool> uploadFile(File file, int fileIndex) async {
    //print('index: ' + fileIndex.toString() + ', ' +file.path);
    bool upload_status = false;
    String fileName = basename(file.path);
    String fileExtension = extension(file.path);

    // Get base file name
    //print("File base name: $fileName");
    //print("File Extension: $fileExtension");


    var request = MultipartRequest(
      'POST',
      Uri.parse(Upload_URL),
      onProgress: (int bytes, int total) async {
        final progress = bytes / total;
        globals.filesUploader_State_Key.currentState.fileUploadProgressReload(fileIndex, bytes: bytes, totals: total);
        if(progress >= 1.0)
        {
          upload_status = true;
          //await pr.hide();
        }
        else {
          //print('progress: $progress ($bytes/$total)');
        }
      },
    );

    request.files.add(
        await http.MultipartFile.fromPath(
            'file', file.path
        )
    );
    request.fields['coursefolder'] = globals.selectedCourse.courseFolder;
    request.fields['unitfolder'] = globals.selectedCourseUnit.unitFolder;
    request.fields['foldername'] = globals.foldername;

    try {
      await request.send().then((response) async => {
        if(response.statusCode == 200 || response.statusCode == 201) {
          response.stream.transform(utf8.decoder).listen((value) {
            globals.filePath_Ser_Results.add(jsonDecode(value));
          })
        }
      });
      //region Error Handler
    } on TimeoutException catch (e) {
      //print("Error" + e.toString());
      String connectionResult = await globals.checkConnection(globals.filesUploader_State_Key.currentContext);
      globals.filesUploader_State_Key.currentState.fileUploadProgressReload(fileIndex, isFail: true, errorMsg: connectionResult);
      globals.newMaterial_FilesUploader_failFilesList.add(file);
    } on SocketException catch(_){
      //print("Error" + _.toString());
      String connectionResult = await globals.checkConnection(globals.filesUploader_State_Key.currentContext);
      globals.filesUploader_State_Key.currentState.fileUploadProgressReload(fileIndex, isFail: true, errorMsg: connectionResult);
      globals.newMaterial_FilesUploader_failFilesList.add(file);
    } catch(_){
      //print("Error" + _.toString());
      String connectionResult = await globals.checkConnection(globals.filesUploader_State_Key.currentContext);
      globals.filesUploader_State_Key.currentState.fileUploadProgressReload(fileIndex, isFail: true, errorMsg: connectionResult);
      globals.newMaterial_FilesUploader_failFilesList.add(file);
    }
    //endregion
    return upload_status;
  }

  static void uploadAllFiles(List<File> fileList) async {
    List<bool> uploadedFiles_Status = new List<bool>();
    List<File> _failFiles = new List<File>();
    bool getting_folder_error = false;

    if(globals.isRetry != true)
      globals.filePath_Ser_Results = new List<Map<String, dynamic>>();

    globals.filesUploader_State_Key.currentState.setVisible_Floatbutton(false);
    if(globals.isRetry != true){
      globals.newMaterial_FilesUploader_failFilesList = new List<File>();
    } else {
      globals.filesUploader_State_Key.currentState.filesListReload();
    }

    //print(globals.foldername);
    //region Get Folder Name from Server
    if(globals.foldername == null){
      var CreateFolder_Data = {
        'CourseFolder': globals.selectedCourse.courseFolder,
        'UnitFolder': globals.selectedCourseUnit.unitFolder,
        'Title': globals.newMaterial_Title,
      };

      try {
        // Call Web API and try to get a result from Server
        var response_code = await http.post(
            Get_MaterialsFolder_URL, body: json.encode(CreateFolder_Data, toEncodable: globals.dateTimeSerializer)).timeout(
            Duration(seconds: Connection_Timeout_TimeLimit));

        // Getting Server response into variable.
        Map<String, dynamic> response_code_JSON = jsonDecode(response_code.body);

        if(response_code.statusCode == 200) {
          // There are no any error at inserting to DB.
          if (response_code_JSON['StatusCode'] == 1000) {
            //print(response_code_JSON);
            globals.filesUploader_State_Key.currentState.insertProgressReload(0,
                successMsg: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesUploader_ServerResponseSuccess]);
            getting_folder_error = false;
            globals.foldername = response_code_JSON['FolderName'];
            globals.selectedMaterialID = response_code_JSON['Last_MID'];
          } else {
            _dialogStatus = dialog_Status.Error;
            dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesUploader_InsertFail];
            globals.filesUploader_State_Key.currentState.insertProgressReload(0, isFail: true, errorMsg: dialog_Msg);
            getting_folder_error = true;
            globals.foldername = null;
          }
        }
      } on TimeoutException catch (_) {
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
        globals.filesUploader_State_Key.currentState.insertProgressReload(0, isFail: true, errorMsg: dialog_Msg);
        getting_folder_error = true;
        globals.foldername = null;
        //print(_.toString());
      } on Error catch(_) {
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error];
        globals.filesUploader_State_Key.currentState.insertProgressReload(0, isFail: true, errorMsg: dialog_Msg);
        getting_folder_error = true;
        globals.foldername = null;
        //print(_.toString());
      } on SocketException catch(_){
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error];
        globals.filesUploader_State_Key.currentState.insertProgressReload(0, isFail: true, errorMsg: dialog_Msg);
        getting_folder_error = true;
        globals.foldername = null;
        //print(_.toString());
      } on FormatException catch(_) {
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error_FormatException];
        globals.filesUploader_State_Key.currentState.insertProgressReload(0, isFail: true, errorMsg: dialog_Msg);
        getting_folder_error = true;
        globals.foldername = null;
        //print(_.toString());
      }
    } else {
      globals.filesUploader_State_Key.currentState.insertProgressReload(0,
          successMsg: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesUploader_ServerResponseSuccess]);
      getting_folder_error = false;
    }
    //endregion

    if (fileList.length > 0){
      _failFiles = globals.newMaterial_FilesUploader_failFilesList;
      globals.newMaterial_FilesUploader_failFilesList = new List<File>();
      for(File file in fileList){
        bool uploadStatus;
        if(globals.isRetry == true){
          if(!_failFiles.contains(file)) {
            uploadStatus = true;
            uploadedFiles_Status.add(uploadStatus);
            globals.filesUploader_State_Key.currentState.fileUploadProgressReload(
                globals.newMaterial_FilesUploader_fileList.indexOf(file), bytes: file.lengthSync(), totals: file.lengthSync());
            continue;
          }
        }
        if(getting_folder_error != true){
          String connectionResult = await globals.checkConnection(globals.filesUploader_State_Key.currentContext);
          if(connectionResult != "Success"){
            globals.filesUploader_State_Key.currentState.fileUploadProgressReload(fileList.indexOf(file), isFail: true, errorMsg: connectionResult);
            uploadStatus = false;
            globals.newMaterial_FilesUploader_failFilesList.add(file);
          } else {
            uploadStatus = await uploadFile(file, fileList.indexOf(file));
          }
        } else {
          globals.filesUploader_State_Key.currentState.fileUploadProgressReload(fileList.indexOf(file), isFail: true, errorMsg: "Loading Folder Error");
          uploadStatus = false;
          globals.newMaterial_FilesUploader_failFilesList.add(file);
        }
        uploadedFiles_Status.add(uploadStatus);
      }
    }

    String attachmentsPathString = "", linksNameString = "", linksString = "";
    if(globals.material_isEditing && globals.materialEditor_keepAttachmentFilesName.length > 0){
      attachmentsPathString += globals.materialEditor_keepAttachmentFilesName.join(",");
      if(globals.filePath_Ser_Results.length > 0){
        attachmentsPathString += ",";
      }
    }

    for(int i = 0; i < globals.filePath_Ser_Results.length; i++){
      attachmentsPathString += globals.filePath_Ser_Results[i]['filename'];
      if(i != globals.filePath_Ser_Results.length - 1)
        attachmentsPathString += ",";
    }

    linksNameString = globals.newMaterial_FilesUploader_linksList.keys.toList().join(",");
    linksString = globals.newMaterial_FilesUploader_linksList.values.toList().join(",");

    print("Insert Link Names: " + globals.newMaterial_FilesUploader_linksList.keys.toList().join(",") + "\n");
    print("Insert Link URL: " + globals.newMaterial_FilesUploader_linksList.values.toList().join(",") + "\n");
    //print("Course Folder Name: "+globals.selectedCourse.courseFolder);
    //print(attachmentsPathString);

    //region insert into DB

    if(!uploadedFiles_Status.contains(false)){

      var insertDB_Data;

      if(!globals.material_isEditing){
        insertDB_Data = {
          'CUID': globals.UserData_UID,'CUName': globals.UserData_username,
          'CourseFolder': globals.selectedCourse.courseFolder, 'CourseID': globals.selectedCourse.courseID,
          'UnitID': globals.selectedCourseUnit.unitID,'UnitFolder': globals.selectedCourseUnit.unitFolder,
          'foldername': globals.foldername, 'Title': globals.newMaterial_Title,
          'Description': globals.newMaterial_Desc, 'RequiredTime': null,
          'Period_Start': globals.newMaterial_FullStartTime , 'Period_End': globals.newMaterial_FullEndTime,
          'Attachment': attachmentsPathString, 'LinksName': linksNameString, 'Links': linksString,
        };
      } else {
        insertDB_Data = {
          'CUID': globals.UserData_UID,'CUName': globals.UserData_username,
          'CourseFolder': globals.selectedCourse.courseFolder, 'CourseID': globals.selectedCourse.courseID,
          'MID': globals.selectedMaterial.materialID,
          'UnitID': globals.selectedCourseUnit.unitID,'UnitFolder': globals.selectedCourseUnit.unitFolder,
          'MaterialsFolder': globals.selectedMaterial.materialFolder, 'Title': globals.editMaterial_Title,
          'Description': globals.editMaterial_Desc, 'RequiredTime': null,
          'Period_Start': globals.editMaterial_FullStartTime , 'Period_End': globals.editMaterial_FullEndTime,
          'Attachment': attachmentsPathString,
          'Attachment_Delete': globals.materialEditor_deleteAttachmentFilesName.join(","),
          'LinksName': linksNameString, 'Links': linksString, 'Links_Delete': globals.materialEditor_deleteLinksName.join(","),
        };
      }

      //print(insertDB_Data);

      try {
        // Call Web API and try to get a result from Server
        var response_code;

        if(!globals.material_isEditing){
          response_code = await http.post(
              InsertMaterial_URL, body: json.encode(insertDB_Data, toEncodable: globals.dateTimeSerializer)).timeout(
              Duration(seconds: Connection_Timeout_TimeLimit));
        } else {
          response_code = await http.post(
              UpdateMaterial_URL, body: json.encode(insertDB_Data, toEncodable: globals.dateTimeSerializer)).timeout(
              Duration(seconds: Connection_Timeout_TimeLimit));
        }

        // Getting Server response into variable.
        Map<String, dynamic> response_code_JSON = jsonDecode(response_code.body);

        if(response_code.statusCode == 200) {
          // There are no any error at inserting to DB.
          if (response_code_JSON['StatusCode'] == 1000) {
            globals.filesUploader_State_Key.currentState.insertProgressReload(globals.fileListThumb.length - 1,
                successMsg: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesUploader_InsertSuccess]);
            _dialogStatus = dialog_Status.Success;
            dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesUploader_InsertSuccess];
          } else {
            _dialogStatus = dialog_Status.Error;
            dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesUploader_InsertFail];
            globals.filesUploader_State_Key.currentState.insertProgressReload(globals.fileListThumb.length - 1, isFail: true, errorMsg: dialog_Msg);
            uploadedFiles_Status.add(false);
          }
        }
      } on TimeoutException catch (_) {
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
        globals.filesUploader_State_Key.currentState.insertProgressReload(globals.fileListThumb.length - 1, isFail: true, errorMsg: dialog_Msg);
        uploadedFiles_Status.add(false);
        //print(_.toString());
      } on Error catch(_) {
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error];
        globals.filesUploader_State_Key.currentState.insertProgressReload(globals.fileListThumb.length - 1, isFail: true, errorMsg: dialog_Msg);
        uploadedFiles_Status.add(false);
        //print(_.toString());
      } on SocketException catch(_){
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error];
        globals.filesUploader_State_Key.currentState.insertProgressReload(globals.fileListThumb.length - 1, isFail: true, errorMsg: dialog_Msg);
        uploadedFiles_Status.add(false);
        //print(_.toString());
      } on FormatException catch(_) {
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error_FormatException];
        globals.filesUploader_State_Key.currentState.insertProgressReload(globals.fileListThumb.length - 1, isFail: true, errorMsg: dialog_Msg);
        uploadedFiles_Status.add(false);
        print(_.toString());
      }

      showDialog(
        barrierDismissible: false,
        context: globals.filesUploader_State_Key.currentContext,
        builder: (BuildContext context) => CustomDialog_Confirm(
          dialog_type: _dialogStatus,
          description: dialog_Msg,
        ),
      );
    } else {
      // There are some error at uploading file.
      _dialogStatus = dialog_Status.Error;
      dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error];
      globals.filesUploader_State_Key.currentState.insertProgressReload(globals.fileListThumb.length - 1, isFail: true, errorMsg: dialog_Msg);
      uploadedFiles_Status.add(false);
    }
      /*
    else {
      if(_failFiles.length == 0){
        var updateDB_Data = {
          'MID': globals.selectedCourse.courseFolder, 'CourseID': globals.selectedCourse.courseID,
          'Title': globals.newMaterial_Title,
          'Description': globals.newMaterial_Desc, 'RequiredTime': null,
          'Period_Start': globals.newMaterial_FullStartTime , 'Period_End': globals.newMaterial_FullEndTime,
          'Attachment': attachmentsPathString,
        };

        try {
          // Call Web API and try to get a result from Server
          var response_code = await http.post(
              UpdateMaterial_URL, body: json.encode(updateDB_Data, toEncodable: globals.dateTimeSerializer)).timeout(
              Duration(seconds: Connection_Timeout_TimeLimit));

          // Getting Server response into variable.
          Map<String, dynamic> response_code_JSON = jsonDecode(response_code.body);

          if(response_code.statusCode == 200) {
            // There are no any error at inserting to DB.
            if (response_code_JSON['StatusCode'] == 1000) {
              globals.filesUploader_State_Key.currentState.insertProgressReload(globals.fileListThumb.length - 1);
              _dialogStatus = dialog_Status.Success;
              dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesUploader_InsertSuccess];
              print(response_code_JSON);
            } else {
              _dialogStatus = dialog_Status.Error;
              dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesUploader_InsertFail];
              globals.filesUploader_State_Key.currentState.insertProgressReload(globals.fileListThumb.length - 1, isFail: true, errorMsg: dialog_Msg);
              uploadedFiles_Status.add(false);
            }
          }
        } on TimeoutException catch (_) {
          _dialogStatus = dialog_Status.Error;
          dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
          globals.filesUploader_State_Key.currentState.insertProgressReload(globals.fileListThumb.length - 1, isFail: true, errorMsg: dialog_Msg);
          uploadedFiles_Status.add(false);
          print(_.toString());
        } on Error catch(_) {
          _dialogStatus = dialog_Status.Error;
          dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error];
          globals.filesUploader_State_Key.currentState.insertProgressReload(globals.fileListThumb.length - 1, isFail: true, errorMsg: dialog_Msg);
          uploadedFiles_Status.add(false);
          print(_.toString());
        } on SocketException catch(_){
          _dialogStatus = dialog_Status.Error;
          dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error];
          globals.filesUploader_State_Key.currentState.insertProgressReload(globals.fileListThumb.length - 1, isFail: true, errorMsg: dialog_Msg);
          uploadedFiles_Status.add(false);
          print(_.toString());
        }

        showDialog(
          barrierDismissible: false,
          context: globals.filesUploader_State_Key.currentContext,
          builder: (BuildContext context) => CustomDialog_Confirm(
            dialog_type: _dialogStatus,
            description: dialog_Msg,
          ),
        );
      } else {
        // There are some error at uploading file.
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Connection_Error];
        globals.filesUploader_State_Key.currentState.insertProgressReload(globals.fileListThumb.length - 1, isFail: true, errorMsg: dialog_Msg);
        uploadedFiles_Status.add(false);
      }
    }
      */
    //endregion

    //print(uploadedFiles_Status);
    //print(globals.newMaterial_FilesUploader_failFilesList);
    globals.filesUploader_State_Key.currentState.setVisible_Floatbutton(true);
    if(uploadedFiles_Status.contains(false)){
      globals.filesUploader_State_Key.currentState.setVisible_RetryButton(true);
      globals.filesUploader_State_Key.currentState.setVisible_FinishButton(false);
    } else {
      globals.filesUploader_State_Key.currentState.setVisible_RetryButton(false);
      globals.filesUploader_State_Key.currentState.setVisible_FinishButton(true);
      globals.foldername = null;
    }
  }
}

class FilesUploader_GUI extends StatefulWidget{
  FilesUploader_GUI({Key key}) : super(key: key);
  @override
  FilesUploader_GUI_State createState() => FilesUploader_GUI_State();
}

class FilesUploader_GUI_State extends State<FilesUploader_GUI> {
  bool visible_floatButton = false;
  bool visible_RetryButton = false;
  bool visible_FinishButton = false;

  @override
  void initState() {
    super.initState();
    filesListReload();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => FilesUploader.uploadAllFiles(globals.newMaterial_FilesUploader_fileList));
  }
  void setVisible_Floatbutton(bool isVisible){
    setState(() {
      visible_floatButton = isVisible;
    });
  }
  void setVisible_RetryButton(bool isVisible){
    setState(() {
      visible_RetryButton = isVisible;
    });
  }
  void setVisible_FinishButton(bool isVisible){
    setState(() {
      visible_FinishButton = isVisible;
    });
  }
  void fileUploadProgressReload(int listIndex, {int bytes, int totals, bool isFail = false, String errorMsg = ""}){
    File _currentFile = globals.newMaterial_FilesUploader_fileList[listIndex];
    Widget _currentThumb = globals.fileListThumb[listIndex+1];
    String fileNameandProgress;
    Widget uploadStatus;
    if(isFail){
      fileNameandProgress = basename(_currentFile.path) + "\n(" +
          Localizations_Text[globals
              .CurrentLang][Localizations_Text_Identifier
              .Material_FilesUploader_Fail] + ")";
      uploadStatus = Container(
        height: tips_error_Icon.height,
        width: tips_error_Icon.width,
        decoration: BoxDecoration(
          image: DecorationImage(image: tips_error_Icon.image),
        ),
        child: FlatButton(
          onPressed: () => {
            showDialog(
              barrierDismissible: false,
              context: globals.filesUploader_State_Key.currentContext,
              builder: (BuildContext context) =>
                  CustomDialog_Confirm(
                    dialog_type: dialog_Status.Error,
                    description: errorMsg,
                  ),
            )
          },
          child: null,
        ),
      );
    } else {
      if ((bytes.toDouble() / totals.toDouble()) < 1.0) {
        fileNameandProgress = basename(_currentFile.path) + "\n" +
            Localizations_Text[globals
                .CurrentLang][Localizations_Text_Identifier
                .Material_FilesUploader_Uploading] +
            "(" + bytes.toStringAsFixed(0) + '/' + totals.toStringAsFixed(0) +
            ")";
        uploadStatus = CircularProgressIndicator();
      } else {
        fileNameandProgress = basename(_currentFile.path) + "\n(" +
            Localizations_Text[globals
                .CurrentLang][Localizations_Text_Identifier
                .Material_FilesUploader_Success] + ")";
        uploadStatus = tips_success_Icon;
      }
    }
    // Identified Image Extension ==> Output Image Container
    if (globals.picExt.contains(extension(_currentFile.path).toLowerCase())) {
      _currentThumb = Container(
          child: Column(
            children: <Widget>[
              Row(
                  children: <Widget>[
                    Expanded(
                      flex: 7,
                      child: Text(fileNameandProgress, style: TextStyle(color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                    ),
                    Expanded(
                        flex: 2,
                        child: image_Icon
                    ),
                    Expanded(
                        flex: 1,
                        child: uploadStatus
                    ),
                  ]
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Divider(
                        height: 15,
                        thickness: 5,
                        color: Colors.black
                    ),
                  )
                ],
              )
            ],
          )
      );
    }
    // Identified Document Extension ==> Output Doc Container
    else if(globals.docExt.contains(extension(_currentFile.path).toLowerCase())){
      _currentThumb = Container(
          child: Column(
            children: <Widget>[
              Row(
                  children: <Widget>[
                    Expanded(
                      flex: 7,
                      child: Text(fileNameandProgress, style: TextStyle(color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                    ),
                    Expanded(
                        flex: 2,
                        child: doc_Icon
                    ),
                    Expanded(
                        flex: 1,
                        child: uploadStatus
                    ),
                  ]
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Divider(
                        height: 15,
                        thickness: 5,
                        color: Colors.black
                    ),
                  )
                ],
              )
            ],
          )
      );
    }
    // Identified PDF Extension ==> Output PDF Container
    else if(extension(_currentFile.path).toLowerCase() == '.pdf'){
      _currentThumb = Container(
          child: Column(
            children: <Widget>[
              Row(
                  children: <Widget>[
                    Expanded(
                      flex: 7,
                      child: Text(fileNameandProgress, style: TextStyle(color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                    ),
                    Expanded(
                        flex: 2,
                        child: pdf_Icon
                    ),
                    Expanded(
                        flex: 1,
                        child: uploadStatus
                    ),
                  ]
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Divider(
                        height: 15,
                        thickness: 5,
                        color: Colors.black
                    ),
                  )
                ],
              )
            ],
          )
      );
    }
    // Identified MP3 Extension ==> Output Music Container
    else if(extension(_currentFile.path).toLowerCase() == '.mp3'){
      _currentThumb = Container(
          child: Column(
            children: <Widget>[
              Row(
                  children: <Widget>[
                    Expanded(
                      flex: 7,
                      child: Text(fileNameandProgress, style: TextStyle(color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                    ),
                    Expanded(
                        flex: 2,
                        child: music_Icon
                    ),
                    Expanded(
                        flex: 1,
                        child: uploadStatus
                    ),
                  ]
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Divider(
                        height: 15,
                        thickness: 5,
                        color: Colors.black
                    ),
                  )
                ],
              )
            ],
          )
      );
    }
    // Identified MP4 Extension ==> Output Video Container
    else if(extension(_currentFile.path).toLowerCase() == '.mp4'){
      _currentThumb = Container(
          child: Column(
            children: <Widget>[
              Row(
                  children: <Widget>[
                    Expanded(
                      flex: 7,
                      child: Text(fileNameandProgress, style: TextStyle(color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                    ),
                    Expanded(
                        flex: 2,
                        child: video_Icon
                    ),
                    Expanded(
                        flex: 1,
                        child: uploadStatus
                    ),
                  ]
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Divider(
                        height: 15,
                        thickness: 5,
                        color: Colors.black
                    ),
                  )
                ],
              )
            ],
          )
      );
    }
    else if(extension(_currentFile.path).toLowerCase() == '.zip'){
      _currentThumb = Container(
          child: Column(
            children: <Widget>[
              Row(
                  children: <Widget>[
                    Expanded(
                      flex: 7,
                      child: Text(fileNameandProgress, style: TextStyle(color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                    ),
                    Expanded(
                        flex: 2,
                        child: zip_Icon
                    ),
                    Expanded(
                        flex: 1,
                        child: uploadStatus
                    ),
                  ]
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Divider(
                        height: 15,
                        thickness: 5,
                        color: Colors.black
                    ),
                  )
                ],
              )
            ],
          )
      );
    }

    setState(() {
      globals.fileListThumb[listIndex+1] = _currentThumb;
    });
  }
  void insertProgressReload(int listIndex, {String successMsg, bool isFail = false, String errorMsg = ""}){
    Widget _currentThumb = globals.fileListThumb[listIndex];
    Widget uploadStatus;
    String statusText;
    if(isFail){
      statusText = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesUploader_InsertFail];
      uploadStatus = Container(
        height: tips_error_Icon.height,
        width: tips_error_Icon.width,
        decoration: BoxDecoration(
          image: DecorationImage(image: tips_error_Icon.image),
        ),
        child: FlatButton(
          onPressed: () => {
            showDialog(
              barrierDismissible: false,
              context: globals.filesUploader_State_Key.currentContext,
              builder: (BuildContext context) =>
                  CustomDialog_Confirm(
                    dialog_type: dialog_Status.Error,
                    description: errorMsg,
                  ),
            )
          },
          child: null,
        ),
      );
    } else {
      statusText = successMsg;
      uploadStatus = tips_success_Icon;
    }
    _currentThumb = Container(
        child: Column(
          children: <Widget>[
            Row(
                children: <Widget>[
                  Expanded(
                    flex: 9,
                    child: Text(statusText, style: TextStyle(color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                  ),
                  Expanded(
                      flex: 1,
                      child: uploadStatus
                  ),
                ]
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Divider(
                      height: 15,
                      thickness: 5,
                      color: Colors.black
                  ),
                )
              ],
            )
          ],
        )
    );

    setState(() {
      globals.fileListThumb[listIndex] = _currentThumb;
    });
  }
  void filesListReload(){
    List<Widget> thumbs = new List<Widget>();
    List<File> _failFiles = new List<File>();
    _failFiles = globals.newMaterial_FilesUploader_failFilesList;

    // Getting Folder Name From Server
    thumbs.add(Container(
        child: Column(
          children: <Widget>[
            Row(
                children: <Widget>[
                  Expanded(
                    flex: 9,
                    child: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesUploader_LoadingServerResponse], style: TextStyle(color: appPrimaryColor, fontWeight: FontWeight.bold, fontSize: globals.fontSize_Middle),),
                  ),
                  Expanded(
                      flex: 1,
                      child: CircularProgressIndicator()
                  ),
                ]
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Divider(
                      height: 15,
                      thickness: 5,
                      color: Colors.black
                  ),
                )
              ],
            )
          ],
        )
    ));

    for(File element in globals.newMaterial_FilesUploader_fileList){
      // Get File Size
      String fileSizeDisplay;
      int fileSizeInBytes = element.lengthSync();
      double fileSizeInKB = fileSizeInBytes / 1024;
      double fileSizeInMB = fileSizeInKB / 1024;
      if(fileSizeInMB >= 1.0)
        fileSizeDisplay = fileSizeInMB.toStringAsFixed(2) + " MB";
      else {
        fileSizeDisplay = fileSizeInKB.toStringAsFixed(2) + " KB";
      }

      String filenameandStatus = basename(element.path) + "\n(" +
          Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesUploader_WaitforUpload] +
          fileSizeDisplay + ")";

      // Identified Image Extension ==> Output Image Container
      if (globals.picExt.contains(extension(element.path).toLowerCase())) {
        thumbs.add(Container(
            child: Column(
              children: <Widget>[
                Row(
                    children: <Widget>[
                      Expanded(
                        flex: 7,
                        child: Text(filenameandStatus, style: TextStyle(color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                      ),
                      Expanded(
                          flex: 2,
                          child: image_Icon
                      ),
                      Expanded(
                          flex: 1,
                          child: CircularProgressIndicator()
                      ),
                    ]
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Divider(
                          height: 15,
                          thickness: 5,
                          color: Colors.black
                      ),
                    )
                  ],
                )
              ],
            )
        ));
      }
      // Identified Document Extension ==> Output Doc Container
      else if(globals.docExt.contains(extension(element.path).toLowerCase())){
        thumbs.add(Container(
            child: Column(
              children: <Widget>[
                Row(
                    children: <Widget>[
                      Expanded(
                        flex: 7,
                        child: Text(filenameandStatus, style: TextStyle(color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                      ),
                      Expanded(
                          flex: 2,
                          child: doc_Icon
                      ),
                      Expanded(
                          flex: 1,
                          child: CircularProgressIndicator()
                      ),
                    ]
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Divider(
                          height: 15,
                          thickness: 5,
                          color: Colors.black
                      ),
                    )
                  ],
                )
              ],
            )
        ));
      }
      // Identified PDF Extension ==> Output PDF Container
      else if(extension(element.path).toLowerCase() == '.pdf'){
        thumbs.add(Container(
            child: Column(
              children: <Widget>[
                Row(
                    children: <Widget>[
                      Expanded(
                        flex: 7,
                        child: Text(filenameandStatus, style: TextStyle(color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                      ),
                      Expanded(
                          flex: 2,
                          child: pdf_Icon
                      ),
                      Expanded(
                          flex: 1,
                          child: CircularProgressIndicator()
                      ),
                    ]
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Divider(
                          height: 15,
                          thickness: 5,
                          color: Colors.black
                      ),
                    )
                  ],
                )
              ],
            )
        ));
      }
      // Identified MP3 Extension ==> Output Music Container
      else if(extension(element.path).toLowerCase() == '.mp3'){
        thumbs.add(Container(
            child: Column(
              children: <Widget>[
                Row(
                    children: <Widget>[
                      Expanded(
                        flex: 7,
                        child: Text(filenameandStatus, style: TextStyle(color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                      ),
                      Expanded(
                          flex: 2,
                          child: music_Icon
                      ),
                      Expanded(
                          flex: 1,
                          child: CircularProgressIndicator()
                      ),
                    ]
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Divider(
                          height: 15,
                          thickness: 5,
                          color: Colors.black
                      ),
                    )
                  ],
                )
              ],
            )
        ));
      }
      // Identified MP4 Extension ==> Output Video Container
      else if(extension(element.path).toLowerCase() == '.mp4'){
        thumbs.add(Container(
            child: Column(
              children: <Widget>[
                Row(
                    children: <Widget>[
                      Expanded(
                        flex: 7,
                        child: Text(filenameandStatus, style: TextStyle(color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                      ),
                      Expanded(
                          flex: 2,
                          child: video_Icon
                      ),
                      Expanded(
                          flex: 1,
                          child: CircularProgressIndicator()
                      ),
                    ]
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Divider(
                          height: 15,
                          thickness: 5,
                          color: Colors.black
                      ),
                    )
                  ],
                )
              ],
            )
        ));
      }
      else if(extension(element.path).toLowerCase() == '.zip'){
        thumbs.add(Container(
            child: Column(
              children: <Widget>[
                Row(
                    children: <Widget>[
                      Expanded(
                        flex: 7,
                        child: Text(filenameandStatus, style: TextStyle(color: appPrimaryColor, fontSize: globals.fontSize_Middle),),
                      ),
                      Expanded(
                          flex: 2,
                          child: zip_Icon
                      ),
                      Expanded(
                          flex: 1,
                          child: CircularProgressIndicator()
                      ),
                    ]
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Divider(
                          height: 15,
                          thickness: 5,
                          color: Colors.black
                      ),
                    )
                  ],
                )
              ],
            )
        ));
      }
    }

    thumbs.add(Container(
        child: Column(
          children: <Widget>[
            Row(
                children: <Widget>[
                  Expanded(
                    flex: 9,
                    child: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesUploader_Inserting], style: TextStyle(color: appPrimaryColor, fontWeight: FontWeight.bold, fontSize: globals.fontSize_Middle),),
                  ),
                  Expanded(
                      flex: 1,
                      child: CircularProgressIndicator()
                  ),
                ]
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Divider(
                      height: 15,
                      thickness: 5,
                      color: Colors.black
                  ),
                )
              ],
            )
          ],
        )
    ));

    setState(() {
      globals.fileListThumb = thumbs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: () async => null,
        child:Scaffold(
            appBar: AppBar(
              backgroundColor: appTitleBarColor,
              title: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesUploader_Title],
              style: TextStyle(fontSize: globals.fontSize_Title),),
              centerTitle: true,
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
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                child: Visibility(
                    visible: visible_floatButton,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Visibility(
                          visible: visible_RetryButton,
                          child: FloatingActionButton.extended(
                            backgroundColor: Colors.redAccent,
                            heroTag: null,
                            onPressed: () => {
                              globals.isRetry = true,
                              FilesUploader.uploadAllFiles(globals.newMaterial_FilesUploader_fileList),
                            },
                            label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesUploader_Retry],
                            style: TextStyle(fontSize: globals.fontSize_Normal),),
                            icon: Icon(Icons.refresh),
                          ),
                        ),
                        Visibility(
                          visible: visible_FinishButton,
                          child: FloatingActionButton.extended(
                            heroTag: null,
                            onPressed: () async => {
                              globals.newMaterial_Title = null,
                              globals.newMaterial_Desc = null,
                              globals.newMaterial_SDate = null,
                              globals.newMaterial_STime = null,
                              globals.newMaterial_EDate = null,
                              globals.newMaterial_ETime = null,
                              globals.newMaterial_FullStartTime = null,
                              globals.newMaterial_FullEndTime = null,
                              globals.newMaterial_FilesUploader_fileList = new List<File>(),
                              globals.newMaterial_FilesUploader_linksList = new Map<String, String>(),
                              globals.editMaterial_Title = null,
                              globals.editMaterial_Desc = null,
                              globals.editMaterial_SDate = null,
                              globals.editMaterial_STime = null,
                              globals.editMaterial_EDate = null,
                              globals.editMaterial_ETime = null,
                              globals.editMaterial_FullStartTime = null,
                              globals.editMaterial_FullEndTime = null,
                              globals.materialEditor_AttachmentThumb = List<Widget>(),
                              globals.materialEditor_keepAttachmentFilesName = List<String>(),
                              globals.materialEditor_deleteAttachmentFilesName = List<String>(),
                              globals.materialEditor_CurrentAttachmentStatus = List<bool>(),
                              globals.materialEditor_LinksThumb = new List<Widget>(),
                              globals.materialEditor_CurrentLinksStatus = List<bool>(),
                              globals.materialEditor_deleteLinksName = List<String>(),
                              globals.materialEditor_keepLinksName = List<String>(),
                              globals.server_LinksDeleteThumb_Preview = List<Widget>(),
                              globals.server_LinksThumb_Preview = List<Widget>(),
                              globals.server_AttachmentsThumb_Preview = List<Widget>(),
                              globals.server_AttachmentsDeleteThumb_Preview = List<Widget>(),
                              globals.courseListReloaded = false,
                              globals.courseUnitListReloaded = false,
                              globals.materialListReloaded = false,
                              globals.materialsReloaded = false,
                              if(await fetchCourses(context, isAdminCheck: 'true')){
                                if(await fetchCourseUnits(context, globals.selectedCourse.courseID)){
                                  if(await fetchMaterials(context, globals.selectedCourse.courseID, globals.selectedCourseUnit.unitID)){
                                    if(await fetchContentMaterials(context, globals.selectedCourse.courseID, globals.selectedCourseUnit.unitID, globals.selectedMaterialID)){
                                      Navigator.of(context)
                                          .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
                                      Navigator.of(context).push(globals.gotoPage(globals.CourseList_Page, Duration(seconds: 0, milliseconds: 0))),
                                      Navigator.of(context).push(globals.gotoPage(globals.CourseUnitList_Page, Duration(seconds: 0, milliseconds: 0))),
                                      Navigator.of(context).push(globals.gotoPage(globals.CourseUnit_Page, Duration(seconds: 0, milliseconds: 0))),
                                      Navigator.of(context).push(globals.gotoPage(globals.CourseContent_Page, Duration(seconds: 0, milliseconds: 0)))
                                    }
                                  }
                                }
                              },
                            },
                            label: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Material_FilesUploader_FinishSubmission],
                            style: TextStyle(fontSize: globals.fontSize_Normal),),
                            icon: Icon(Icons.cloud_upload),
                          ),
                        )
                      ],
                    )
                )
            )
        )
    );
  }
}