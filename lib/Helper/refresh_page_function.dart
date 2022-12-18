import 'package:intl/intl.dart';

import 'global_setting.dart';
import 'ComponentsList.dart';
import 'JsonItemConvertor.dart';
import 'Localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'global_setting.dart' as globals;

class Refresh_Page_Manager{
  static refresh_CourseListPage(BuildContext context) async => {
    if(await Check_Token(context)){
      if(globals.canUpload){
        if(await fetchCourses(context, isAdminCheck: 'true')){
          globals.courseListReloaded = false,
          Navigator.of(context)
              .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
          Navigator.of(context).push(globals.gotoPage(globals.CourseList_Page, Duration(seconds: 0, milliseconds: 0))),
        }
      } else {
        if(await fetchCourses(context, queryparam: "isOpening")){
          globals.courseListReloaded = false,
          Navigator.of(context)
              .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
          Navigator.of(context).push(globals.gotoPage(globals.CourseList_Page, Duration(seconds: 0, milliseconds: 0))),
        }
      }
    },
  };

  static refresh_CourseUnitListPage(BuildContext context) async => {
    if(await Check_Token(context)){
      if(globals.canUpload){
        if(await fetchCourseUnits(context, globals.selectedCourse.courseID)){
          globals.courseUnitListReloaded = false,
          Navigator.of(context)
              .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
          Navigator.of(context).push(globals.gotoPage(globals.CourseList_Page, Duration(seconds: 0, milliseconds: 0))),
          Navigator.of(context).push(globals.gotoPage(globals.CourseUnitList_Page, Duration(seconds: 0, milliseconds: 0)))
              .then((value) => value?refresh_CourseListPage(globals.CourseList_State_Key.currentContext):null),
        }
      } else {
        if(await fetchCourseUnits(context, globals.selectedCourse.courseID,queryparam: "isOpening")){
          globals.courseUnitListReloaded = false,
          Navigator.of(context)
              .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
          Navigator.of(context).push(globals.gotoPage(globals.CourseList_Page, Duration(seconds: 0, milliseconds: 0))),
          Navigator.of(context).push(globals.gotoPage(globals.CourseUnitList_Page, Duration(seconds: 0, milliseconds: 0)))
              .then((value) => value?refresh_CourseListPage(globals.CourseList_State_Key.currentContext):null),
        }
      }
    },
  };

  static refresh_UnitModulePage(BuildContext context) async => {
    globals.materialsReloaded = false,
    if(await Check_Token(context)){
      if(await fetchContentMaterials(context, globals.selectedCourse.courseID, globals.selectedCourseUnit.unitID, globals.selectedMaterial.materialID)){
        if(await update_progress(context, progress_Table.Module,
            courseID: globals.selectedCourse.courseID, unitID: globals.selectedCourseUnit.unitID, matID: globals.selectedMaterial.materialID)){
          Navigator.of(context)
              .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
          Navigator.of(context).push(globals.gotoPage(globals.CourseList_Page, Duration(seconds: 0, milliseconds: 0))),
          Navigator.of(context).push(globals.gotoPage(globals.CourseUnitList_Page, Duration(seconds: 0, milliseconds: 0))),
          if(!globals.moduleSelectionSkipped){
            Navigator.of(context).push(globals.gotoPage(globals.CourseUnit_Page, Duration(seconds: 0, milliseconds: 0))),
            Navigator.of(context).push(globals.gotoPage(
                globals.CourseContent_Page,
                Duration(seconds: 0, milliseconds: 0))).then((value) => value?Refresh_Page_Manager.refresh_CourseUnitPage(globals.CourseUnitPageState_Key.currentContext):null),
          } else {
            Navigator.of(context).push(globals.gotoPage(
                globals.CourseContent_Page,
                Duration(seconds: 0, milliseconds: 0))).then((value) => value?Refresh_Page_Manager.refresh_CourseUnitListPage(globals.CourseUnitListPage_StateKey.currentContext):null),
          }
        }
      }
    },
  };

  static refresh_CourseUnitPage(BuildContext context) async => {
    if(await Check_Token(context)){
      if(globals.canUpload){
        if(await fetchMaterials(context, globals.selectedCourse.courseID, globals.selectedCourseUnit.unitID)){
          globals.materialListReloaded = false,
          Navigator.of(context)
              .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
          Navigator.of(context).push(globals.gotoPage(globals.CourseList_Page, Duration(seconds: 0, milliseconds: 0))),
          Navigator.of(context).push(globals.gotoPage(globals.CourseUnitList_Page, Duration(seconds: 0, milliseconds: 0))),
          Navigator.of(context).push(globals.gotoPage(globals.CourseUnit_Page, Duration(seconds: 0, milliseconds: 0)))
              .then((value) => value?refresh_CourseUnitListPage(globals.CourseUnitListPage_StateKey.currentContext):null),
        }
      } else {
        if(await fetchMaterials(context, globals.selectedCourse.courseID, globals.selectedCourseUnit.unitID, queryparam: "isOpening")){
          globals.materialListReloaded = false,
          Navigator.of(context)
              .pushAndRemoveUntil(globals.gotoPage(MainPage(),Duration(seconds: 0, milliseconds: 0)), (Route<dynamic> route) => false),
          Navigator.of(context).push(globals.gotoPage(globals.CourseList_Page, Duration(seconds: 0, milliseconds: 0))),
          Navigator.of(context).push(globals.gotoPage(globals.CourseUnitList_Page, Duration(seconds: 0, milliseconds: 0))),
          Navigator.of(context).push(globals.gotoPage(globals.CourseUnit_Page, Duration(seconds: 0, milliseconds: 0)))
              .then((value) => value?refresh_CourseUnitListPage(globals.CourseUnitListPage_StateKey.currentContext):null),
        }
      }
    },
  };
}