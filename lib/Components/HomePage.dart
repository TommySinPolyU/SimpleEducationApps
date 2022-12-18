import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smeapp/Components/ContactForm/ContactForm.dart';
import 'package:smeapp/Components/Survey/SurveyEditor.dart';
import 'CourseCreator/CourseEditor.dart';
import '../Helper/ComponentsList.dart';
import '../Helper/global_setting.dart' as globals;
import 'package:smeapp/Helper/Localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget{
  HomePage({Key key}) : super(key: key);
  HomePage_State createState() => HomePage_State();
}

class HomePage_State extends State {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screen_size = MediaQuery.of(context).size;

    final double gridview_itemHeight = (screen_size.height) / 10;
    final double gridview_iconSize = (screen_size.height - kToolbarHeight - 24) / 18;
    final double gridview_itemWidth = screen_size.width;
    Email tech_email;

    // Logo
    final logo = CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: globals.screen_size.width / 6,
      child: appLogo,
    );

    final flatbtn_addcourse = FlatButton(
      onPressed: () async => {
        globals.course_isEditing = false,
        if(await fetchUserGroup(context, containsAdmin: "0")){
          Navigator.of(context).push(globals.gotoPage(
              CourseEditor(), Duration(seconds: 0, milliseconds: 500)))
        }
      },
      color: appBGColor,
      padding: EdgeInsets.only(top: 10),
        child: Row( // Replace with a Row for horizontal icon + text
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.library_add, size: gridview_iconSize,),
                ],
              ),
            ),
            Expanded(
              flex: 6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.CourseCreator_Creator_AppBarTitle],
                      style: TextStyle(fontSize: globals.fontSize_SubTitle),),
                  )
                ],
              ),
            ),
          ],
        ),
    );

    final flatbtn_addsurvey = FlatButton(
      onPressed: () async => {
        globals.survey_isEditing = false,
        globals.edit_isSurveyDataLoaded = false,
        if(await fetchUserGroup(context, containsAdmin: "0")){
          Navigator.of(context).push(globals.gotoPage(SurveyEditor(), Duration(seconds: 0, milliseconds: 500)))
        }
      },
      color: appBGColor,
      padding: EdgeInsets.only(top: 10),
      child:
      Row( // Replace with a Row for horizontal icon + text
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.post_add, size: gridview_iconSize,),
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_Editor_Create_AppBarTitle],
                      style: TextStyle(fontSize: globals.fontSize_SubTitle)),
                )
              ],
            ),
          ),
        ],
      ),
    );

    final flatbtn_viewcourses = FlatButton(
      onPressed: () async => {
        globals.courseListReloaded = false,
        if(globals.canUpload){
          if(await Check_Token(context)){
            if(await fetchCourses(context, isAdminCheck: 'true')){
              globals.course_list_filter_option = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.StatusFilter_All],
              Navigator.of(context).push(globals.gotoPage(globals.CourseList_Page, Duration(seconds: 0, milliseconds: 500)))
            }
          },
        } else {
          if(await Check_Token(context)){
            if(await fetchCourses(context, queryparam: "isOpening")){
              globals.course_list_filter_option = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.StatusFilter_Opening],
              Navigator.of(context).push(globals.gotoPage(globals.CourseList_Page, Duration(seconds: 0, milliseconds: 500)))
            }
          },
        }
      },
      color: appBGColor,
      padding: EdgeInsets.only(top: 10),
      child:
      Row( // Replace with a Row for horizontal icon + text
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.collections_bookmark, size: gridview_iconSize,),
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Course_View_Title],
                      style: TextStyle(fontSize: globals.fontSize_SubTitle)),
                )
              ],
            ),
          ),
        ],
      ),
    );

    final flatbtn_viewsurvey = FlatButton(
      onPressed: () async => {
        globals.surveyListReloaded = false,
        if(globals.canUpload){
          if(await Check_Token(context)){
            if(await fetchSurvey(context, isAdminCheck: 'true')){
              globals.survey_list_filter_option = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.StatusFilter_All],
              Navigator.of(context).push(globals.gotoPage(globals.SurveyList_Page, Duration(seconds: 0, milliseconds: 500)))
            }
          },
        } else {
          if(await Check_Token(context)){
            if(await fetchSurvey(context, queryparam: "isOpening")){
              globals.survey_list_filter_option = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.StatusFilter_Opening],
              Navigator.of(context).push(globals.gotoPage(globals.SurveyList_Page, Duration(seconds: 0, milliseconds: 500)))
            }
          },
        }
      },
      color: appBGColor,
      padding: EdgeInsets.only(top: 10),
      child:
      Row( // Replace with a Row for horizontal icon + text
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.announcement, size: gridview_iconSize,),
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_AppBarTitle],
                      style: TextStyle(fontSize: globals.fontSize_SubTitle)),
                )
              ],
            ),
          ),
        ],
      ),
    );

    final flatbtn_sendemail = FlatButton(
      onPressed: () async => {
        globals.newEmail_LastName = globals.Profiles_Lastname,
        globals.newEmail_ReplyEmail = globals.Profiles_Email,
        Navigator.of(context).push(globals.gotoPage(ContactForm(), Duration(seconds: 0, milliseconds: 500)))
      },
      color: appBGColor,
      padding: EdgeInsets.only(top: 10),
      child:
      Row( // Replace with a Row for horizontal icon + text
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.email, size: gridview_iconSize,),
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.SendEmail],
                      style: TextStyle(fontSize: globals.fontSize_SubTitle)),
                )
              ],
            ),
          ),
        ],
      ),
    );

    final gridview_researcher = Scrollbar(
      child: GridView.count(
        primary: false,
        childAspectRatio: (gridview_itemWidth / gridview_itemHeight),
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        crossAxisCount: 1,
        physics: ScrollPhysics(),
        shrinkWrap: true,
        children: <Widget>[
          flatbtn_addcourse,
          flatbtn_viewcourses,
          flatbtn_addsurvey,
          flatbtn_viewsurvey,
          flatbtn_sendemail,
          //flatbtn_tech_support
        ],
      ),
    );

    final gridview_normal = Scrollbar(
      child: GridView.count(
        primary: false,
        childAspectRatio: (gridview_itemWidth / gridview_itemHeight),
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        crossAxisCount: 1,
        physics: ScrollPhysics(),
        shrinkWrap: true,
        children: <Widget>[
          flatbtn_viewcourses,
          flatbtn_viewsurvey,
          flatbtn_sendemail,
          //flatbtn_tech_support
        ],
      ),
    );

    Widget _gridView;
    if(globals.canUpload){
      _gridView = gridview_researcher;
    } else
      _gridView = gridview_normal;

    return Scaffold(
        backgroundColor: appBGColor,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: appTitleBarColor,
          title: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.HomePageText],
          style: TextStyle(fontSize: globals.fontSize_Title),),
        ),
        body: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 30, right: 30, bottom: 60),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: logo,
                    flex: 3,
                  ),
                  Expanded(
                    child: _gridView,
                    flex: 7,
                  ),
                ],
              ),
            )
          ],
        )
    );

  }
}