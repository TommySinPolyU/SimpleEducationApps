import 'package:flutter/cupertino.dart';
import 'package:smeapp/Components/CourseContentUploader/FilesSelecter.dart';
import 'package:smeapp/Components/CourseContentUploader/UploadMaterialPage.dart';
import 'package:smeapp/Components/MaterialsViewer/UnitModulePage.dart';
import 'package:smeapp/Components/MaterialsViewer/CourseUnitListPage.dart';
import 'package:smeapp/Components/Survey/SurveyListPage.dart';
import 'package:smeapp/Components/UserManager/UserGroupManagerPage.dart';
import 'dart:io';
import 'package:smeapp/Helper/Localizations.dart';
import '../Components/CourseContentUploader/FilesUploader.dart';
import '../Components/MaterialsViewer/CourseListPage.dart';
import '../Components/MaterialsViewer/CourseUnitPage.dart';
import '../CustomWidget/CustomDialog.dart';
import 'JsonItemConvertor.dart';
import 'AppSetting.dart';
import 'ComponentsList.dart';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:ext_storage/ext_storage.dart';
import 'package:path_provider/path_provider.dart';

int PageIndex = 0;
Size screen_size;
// Font Size Setting at main.dart and SettingPage.dart
double fontSize_Title, fontSize_SubTitle, fontSize_Big, fontSize_Middle, fontSize_Normal, fontSize_Small;
List<double> fontSizes;
String defaultFontSize;

bool isLoggedIn = false;
bool isVerified = false;
bool isFirstRun = false;

// Boolean variable for CircularProgressIndicator.
bool visible_Loading = false;
State state_BottomBar;
Localizations_Language_Identifier CurrentLang = Localizations_Language_Identifier.Language_Eng;
String selectordialog_selectedOption;

FirebaseMessaging firebaseMessaging = FirebaseMessaging();

// Files Uploader
final filesUploader_State_Key = GlobalKey<FilesUploader_GUI_State>();
final filesUploader_GUI_Page = FilesUploader_GUI(key: filesUploader_State_Key);
bool fileListReloaded, isRetry, linksListReloaded;
String foldername = null;
List<Map<String, dynamic>> filePath_Ser_Results;
List<Widget> fileListThumb, fileListThumb_Preview;
List<File> newMaterial_FilesUploader_fileList = new List<File>();
List<File> newMaterial_FilesUploader_failFilesList = new List<File>();
List<Widget> linksThumb, linksThumb_Preview;
Map<String, String> newMaterial_FilesUploader_linksList = new Map<String, String>();
Map<String, String> newMaterial_FilesUploader_faillinksList = new Map<String, String>();
List<String> picExt = ['.jpg', '.jpeg', '.png'];
List<String> docExt = ['.doc', '.docx', '.txt', '.ppt', '.pptx'];
List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx','mp3','mp4', 'txt', 'zip', 'ppt', 'pptx'];

// Home Page
final Home_State_Key = GlobalKey<HomePage_State>();
final Home_Page = HomePage(key: Home_State_Key);

// Selected ID
int selectedCourseID, selectedUnitID, selectedMaterialID;

// Checked Count
int units_finishedCount, modules_finishedCount;

// Group List Setting
List<GroupListItem> groupList = new List<GroupListItem>();
List<GroupListItem> selected_group = new List<GroupListItem>();

// Users List Setting
List<UserListItem> userList = new List<UserListItem>();
List<UserListItem> selected_user = new List<UserListItem>();

// Course List Viewer
String course_list_filter_option = "All";
final CourseList_State_Key = GlobalKey<CourseListPage_State>();
final CourseList_Page = CourseListPage(key: CourseList_State_Key);
bool courseListReloaded;
List<Widget> courseListThumb = [Container()];
List<CourseListItem> courseList = new List<CourseListItem>();

// Course Unit List Viewer
String courseUnit_list_filter_option = "All";
final CourseUnitListPage_StateKey = GlobalKey<CourseUnitListPage_State>();
final CourseUnitList_Page = CourseUnitListPage(key: CourseUnitListPage_StateKey);
List<CourseUnitListItem> courseUnitList = new List<CourseUnitListItem>();
bool courseUnitListReloaded;
List<Widget> courseUnitListThumb = [Container()];

final SurveyListPageState_Key = GlobalKey<SurveyListPage_State>();
final SurveyList_Page = SurveyListPage(key: SurveyListPageState_Key);
String survey_list_filter_option = "All";

// Selected List Item
CourseListItem selectedCourse;
MaterialListItem selectedMaterial;
CourseUnitListItem selectedCourseUnit;
SurveyListItem selectedSurvey;

// In-build Browser
String browser_Title = "";
String browser_url = "";

// region Course Creator
bool course_isEditing, edit_isCourseDataLoaded;
//Upload Course Temp Var
String newCourse_Title="", newCourse_Desc, newCourse_SDate, newCourse_STime, newCourse_EDate, newCourse_ETime, newCourse_Groups;
// New Start Time and End Time For Course Creator
String newCourse_FullStartTime, newCourse_FullEndTime;
// Editing Course Temp Var
String editCourse_Title="", editCourse_Desc, editCourse_SDate, editCourse_STime, editCourse_EDate, editCourse_ETime, editCourse_Groups;
// Start Time and End Time For Course Editor
String editCourse_FullStartTime, editCourse_FullEndTime;
// endregion

// region Course Unit Creator
bool courseunit_isEditing, edit_isCourseUnitDataLoaded;
int skip_moduleselection = 0;
//Upload Course Temp Var
String newCourseUnit_Title="", newCourseUnit_Desc, newCourseUnit_SDate, newCourseUnit_STime, newCourseUnit_EDate, newCourseUnit_ETime;
// New Start Time and End Time For Course Creator
String newCourseUnit_FullStartTime, newCourseUnit_FullEndTime;
// Editing Course Temp Var
String editCourseUnit_Title="", editCourseUnit_Desc, editCourseUnit_SDate, editCourseUnit_STime, editCourseUnit_EDate, editCourseUnit_ETime;
// Start Time and End Time For Course Editor
String editCourseUnit_FullStartTime, editCourseUnit_FullEndTime;
List<String> courseUnitMaterialsNameList;
String editCourseUnit_SelectedGoToMaterial = "";
// endregion

// region Material Creator and Editor
bool material_isEditing, edit_isMaterialDataLoaded;
//Upload Material Temp Var
String newMaterial_Title="", newMaterial_Desc, newMaterial_SDate, newMaterial_STime, newMaterial_EDate, newMaterial_ETime; //newMaterial_RequiredTime
// New Start Time and End Time for Materials Uploader
String newMaterial_FullStartTime, newMaterial_FullEndTime;
// Editing Material Temp Var
String editMaterial_Title="", editMaterial_Desc, editMaterial_SDate, editMaterial_STime, editMaterial_EDate, editMaterial_ETime;
// Start Time and End Time For Course Editor
String editMaterial_FullStartTime, editMaterial_FullEndTime;
// endregion

// Survey Creator and Editor
List<SurveyListItem> surveyList = new List<SurveyListItem>();
List<Widget> surveyListThumb = [Container()];
bool survey_isEditing, edit_isSurveyDataLoaded;
// Creating Survey Temp Var
String newSurvey_Title="", newSurvey_Desc, newSurvey_SDate, newSurvey_STime, newSurvey_EDate, newSurvey_ETime, newSurvey_URL, newSurvey_Group;
// Start Time and End Time For Survey Creator
String newSurvey_FullStartTime, newSurvey_FullEndTime;
// Editing Survey Temp Var
String editSurvey_Title="", editSurvey_Desc, editSurvey_SDate, editSurvey_STime, editSurvey_EDate, editSurvey_ETime, editSurvey_URL, editSurvey_Group;
// Start Time and End Time For Survey Editor
String editSurvey_FullStartTime, editSurvey_FullEndTime;
// Survey Viewer

// Creating Contact Form Temp Var
String newEmail_Title="", newEmail_Desc, newEmail_ReplyEmail, newEmail_NameTitle, newEmail_LastName;

bool surveyListReloaded;

// Reminder
bool reminderListReloaded;
List<PendingNotificationRequest> reminderList = new List<PendingNotificationRequest>();
List<Widget> reminderListThumb = [Container()];

// User Group Manager
bool groupListReloaded;
List<Widget> groupListThumb = [Container()];


// Course Materials List Viewer
String materials_list_filter_option = "All";
final CourseUnitPageState_Key = GlobalKey<CourseUnitPage_State>();
final CourseUnit_Page = CourseUnitPage(key: CourseUnitPageState_Key);
bool materialListReloaded;
List<Widget> materialListThumb = [Container()];
List<MaterialListItem> materialList = new List<MaterialListItem>();
int selectedCourseIndex;
bool moduleSelectionSkipped;

// Course Content Materials Viewer
final CourseContentPage_Key = GlobalKey<CourseContentPage_State>();
final CourseContent_Page = CourseContentPage(key: CourseContentPage_Key);
bool materialsReloaded;
List<Widget> materialFilesThumb = [Container()];
List<Widget> server_AttachmentsThumb_Preview = [Container()];
List<Widget> server_AttachmentsDeleteThumb_Preview = [Container()];
MaterialListItem materialListItem;
List<bool> module_AttachmentCheckingStatus = List<bool>();
List<Widget> server_LinksThumb_Preview = [Container()];
List<Widget> server_LinksDeleteThumb_Preview = [Container()];


// Course Content Materials Editor
final CourseContentEditor_Key = GlobalKey<UploadMaterialPage_State>();
final CourseContentEditor_Page = UploadMaterialPage(key: CourseContentEditor_Key);
final CourseContentEditor_AttachmentSelector_Key = GlobalKey<FilesSelecter_State>();
final CourseContentEditor_AttachmentSelector = FilesSelecter(key: CourseContentEditor_AttachmentSelector_Key);
List<Widget> materialEditor_AttachmentThumb = [];
List<String> materialEditor_keepAttachmentFilesName;
List<String> materialEditor_deleteAttachmentFilesName;
List<bool> materialEditor_CurrentAttachmentStatus;

List<Widget> materialEditor_LinksThumb = [];
List<String> materialEditor_keepLinksName;
List<String> materialEditor_deleteLinksName;
List<bool> materialEditor_CurrentLinksStatus;

//User Permission Status
bool isAdmin = false;
bool canUpload = false;
bool canRead = false;
bool canViewData = false;
bool canModify = false;

//User Data
String UserData_regisCode = "";
String UserData_username = "";
String UserData_UID = "";
String /*Profiles_Nickname = "",*/ Profiles_Firstname = "", Profiles_Lastname = "",  Profiles_UID = "", Profiles_Email = "", Profiles_Gender = "";
String userGroup = "";
String userToken = "";
List<String> userSubGroup = [];

// Global Function
Route gotoPage(Widget page, Duration animationDuration) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: animationDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end);
      var curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: curve,
      );

      return FadeTransition(
        opacity: curvedAnimation,
        child: child,
      );
    },
  );
}

// Checking Internet Connection before upload each file to server,
// If an error occurs, it will return a error dialog and not continue to upload until the connect successful.
Future<String> checkConnection(BuildContext context) async{
  dialog_Status _dialogStatus;
  String dialog_Msg;
  try {
// Call Web API and try to get a result from Server
    var response_code = await http.post(
        Server_Root_URL).timeout(
        Duration(seconds: Connection_Timeout_TimeLimit));
    if(response_code.statusCode == 200){
      dialog_Msg = "Success";
    }
  } on TimeoutException catch (e) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
  } on SocketException catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
  } catch(_){
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
  } on FormatException catch(_) {
    _dialogStatus = dialog_Status.Error;
    dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error_FormatException];
  }
  /*
  if(_dialogStatus == dialog_Status.Error) {
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
  */
  return dialog_Msg;
}

// RandomString For Generate the folder name
final _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

// Convert Date Time to JSON Format.
dynamic dateTimeSerializer(dynamic object) {
  if (object is DateTime) {
    return object.toIso8601String();
  }
  return object;
}

Future<bool> downloadFile(BuildContext context, String url, {String filename, int filesize}) async {
  String _connectionResult = await checkConnection(context);
  dialog_Status _dialogStatus;
  String dialog_Msg;

  //Pre-checking of connection before start a download process
  if( _connectionResult == "Success"){
    if(await fetchContentMaterials(context, selectedCourse.courseID, selectedCourseUnit.unitID, selectedMaterial.materialID)){
      var httpClient = http.Client();
      var http_request = new http.Request("GET", Uri.parse(url));
      print(url);

        Future.delayed(Duration.zero, () =>
        {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) =>
                CustomDialog_Confirm(
                  showButton: false,
                  dialog_type: dialog_Status.Loading,
                  description: Localizations_Text[CurrentLang][Localizations_Text_Identifier
                      .DownloadFile_WaitForDownloadProcess],
                ),
          )
        });

      //region download file Process
      try {
        var response = httpClient.send(http_request).timeout(Duration(seconds: Connection_Timeout_TimeLimit));
        var response_get = await http.get(url).timeout(Duration(seconds: Connection_Timeout_TimeLimit));
        if(response_get.statusCode == 200){
          var platform = Theme.of(context).platform;
          String path;
          Directory appDocDir = await getApplicationDocumentsDirectory();
          if(platform == TargetPlatform.android)
            path = await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOWNLOADS);
          else if(platform == TargetPlatform.iOS)
            path = appDocDir.path;

          String savepath = path + '/' +filename;

            Navigator.of(context).pop();

          if(await File(savepath).exists()){
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) => CustomDialog_Selection(
                dialog_type: dialog_Status.Warning,
                description: Localizations_Text[CurrentLang][Localizations_Text_Identifier.DownloadFile_FileExists_Msg_Opening] +
                    filename+
                    Localizations_Text[CurrentLang][Localizations_Text_Identifier.DownloadFile_FileExists_Msg_Ending],
                buttonText_Confirm: Localizations_Text[CurrentLang][Localizations_Text_Identifier.DownloadFile_FileRedownload],
                buttonText_Cancel: Localizations_Text[CurrentLang][Localizations_Text_Identifier.Cancel],
                callback_Confirm: () async => {
                  File(savepath).delete(),
                  await downloadFile(context, url, filename: filename, filesize: filesize),
                },
              ),
            );
          } else {
            final ProgressDialog pr = ProgressDialog(CourseContentPage_Key.currentContext,type: ProgressDialogType.Download, isDismissible: false, showLogs: true);
            await pr.show();
            pr.update(
              progress: 0,
              message: filename + Localizations_Text[CurrentLang][Localizations_Text_Identifier.DownloadFile_FileDownloading],
              progressWidget: Container(
                  padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
              maxProgress: filesize.toDouble(),
              progressTextStyle: TextStyle(
                  color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
              messageTextStyle: TextStyle(
                  color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
            );
            List<List<int>> chunks = new List();
            int downloaded = 0;
            response.asStream().listen((http.StreamedResponse r) {
              //region initialize progress bar
              //endregion
              r.stream.listen((List<int> chunk) {
                // Display percentage of completion
                debugPrint('downloadPercentage: ${downloaded / filesize * 100}');

                chunks.add(chunk);
                downloaded += chunk.length;
                pr.update(
                  progress: downloaded.toDouble(),
                  message: filename + Localizations_Text[CurrentLang][Localizations_Text_Identifier.DownloadFile_FileDownloading],
                  progressWidget: Container(
                      padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
                  maxProgress: filesize.toDouble(),
                  progressTextStyle: TextStyle(
                      color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
                  messageTextStyle: TextStyle(
                      color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
                );
              }, onDone: () async {
                Future.delayed(Duration(seconds: 1)).then((value) {
                  pr.hide().whenComplete(() async {
                    // Display percentage of completion
                    debugPrint('downloadPercentage: ${downloaded / filesize * 100}');

                    // Save the file
                    File file = new File('$savepath');
                    final Uint8List bytes = Uint8List(filesize);
                    int offset = 0;
                    for (List<int> chunk in chunks) {
                      bytes.setRange(offset, offset + chunk.length, chunk);
                      offset += chunk.length;
                    }
                    await file.writeAsBytes(bytes);

                    _dialogStatus = dialog_Status.Success;
                    showDialog(
                      barrierDismissible: false,
                      context: CourseContentPage_Key.currentContext,
                      builder: (BuildContext context) => CustomDialog_Confirm(
                        dialog_type: dialog_Status.Success,
                        description: filename + "\n" + Localizations_Text[CurrentLang][Localizations_Text_Identifier.DownloadFile_Success],
                        callback_Confirm: () async =>  {
                          Navigator.of(CourseContentPage_Key.currentContext)
                              .pushAndRemoveUntil(gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
                          materialsReloaded = false,
                          Navigator.of(CourseContentPage_Key.currentContext).push(gotoPage(CourseList_Page, Duration(seconds: 0, milliseconds: 0))),
                          Navigator.of(CourseContentPage_Key.currentContext).push(gotoPage(CourseUnitList_Page, Duration(seconds: 0, milliseconds: 0))),
                          Navigator.of(CourseContentPage_Key.currentContext).push(gotoPage(CourseUnit_Page, Duration(seconds: 0, milliseconds: 0))),
                          Navigator.of(CourseContentPage_Key.currentContext).push(gotoPage(CourseContent_Page, Duration(seconds: 0, milliseconds: 0))),
                        },
                      ),
                    );
                  });
                });

              });
            });
          }
        }
        else {
          _dialogStatus = dialog_Status.Error;
          dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Course_ContentPage_AttachmentNotFound];
        }
      } on TimeoutException catch (e) {
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Timeout];
      } on Error catch(_) {
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.DownloadFile_Fail];
        print(_.toString());
      } on SocketException catch(_){
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error];
      } on FormatException catch(_) {
        _dialogStatus = dialog_Status.Error;
        dialog_Msg = Localizations_Text[CurrentLang][Localizations_Text_Identifier.Connection_Error_FormatException];
      }
      //endregion
    }
  }

  if(_dialogStatus == dialog_Status.Error) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomDialog_Confirm(
            dialog_type: _dialogStatus,
            description: dialog_Msg,
          ),
    );
    return false;
  } else
    return true;

}
