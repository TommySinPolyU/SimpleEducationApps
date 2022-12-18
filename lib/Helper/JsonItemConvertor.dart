class GroupList{
  final List<GroupListItem> results;
  GroupList({
    this.results,
  });
  factory GroupList.fromJson(Map json){
    return GroupList(
        results: (json['Results'] as List).map((i) => GroupListItem.fromJson(i)).toList(),
    );
  }
}

class UserList{
  final List<UserListItem> results;
  UserList({
    this.results,
  });
  factory UserList.fromJson(Map json){
    return UserList(
      results: (json['Results'] as List).map((i) => UserListItem.fromJson(i)).toList(),
    );
  }
}

class UserListItem{
  final String lastName;
  final String firstName;
  final String nickName;
  final String UID;

  UserListItem({
    this.lastName,
    this.firstName,
    this.nickName,
    this.UID
  });

  factory UserListItem.fromJson(Map<String, dynamic> json) {
    return UserListItem(
      lastName: json['LastName'],
      firstName: json['FirstName'],
      nickName: json['NickName'],
      UID: json['UID'],
    );
  }
}

class GroupListItem{
  final int groupID;
  final String groupName;
  final int userCount;
  final List<UserListItem> users;

  GroupListItem({
    this.groupID,
    this.groupName,
    this.userCount,
    this.users
  });

  factory GroupListItem.fromJson(Map<String, dynamic> json) {
    return GroupListItem(
      groupID: int.parse(json['GroupID']),
      groupName: json['GroupName'],
      userCount: int.parse(json['UserCount']),
      users: (json['Users'] as List).map((i) => UserListItem.fromJson(i)).toList(),
    );
  }
}

class CourseList {
  final List<CourseListItem> results;
  final int count;

  CourseList({
    this.results,
    this.count,
  });

  factory CourseList.fromJson(Map json){
    return CourseList(
        results: (json['Results'] as List).map((i) => CourseListItem.fromJson(i)).toList(),
        count: json['RecordsCount'] as int
    );
  }
}

class CourseListItem {
  final int courseID, courseUnitCount, unitModuleCount, moduleAttachmentCount, attachment_Checked_Count, module_Finished_Count, unit_Finished_Count;
  final String courseName, courseDesc, courseFolder;
  final DateTime coursePeriod_Start, coursePeriod_End;
  final List<String> courseAccessibleGroup;

  CourseListItem({
    this.courseID,
    this.courseName,
    this.courseDesc,
    this.coursePeriod_Start,
    this.coursePeriod_End,
    this.courseFolder,
    this.courseUnitCount,
    this.unitModuleCount,
    this.moduleAttachmentCount,
    this.attachment_Checked_Count,
    this.module_Finished_Count,
    this.unit_Finished_Count,
    this.courseAccessibleGroup
  });

  factory CourseListItem.fromJson(Map<String, dynamic> json) {
    return CourseListItem(
      courseID: int.parse(json['courseID']),
      courseName: json['courseName'],
      courseDesc: json['courseDesc'],
      coursePeriod_Start: DateTime.parse(json['coursePeriod_Start'].toString()),
      coursePeriod_End: DateTime.parse(json['coursePeriod_End'].toString()),
      courseFolder: json['courseFolder'],
      courseUnitCount: json['Unit_Count'],
      unitModuleCount: json['Unit_Module_Count'],
      moduleAttachmentCount: json['Module_Attachment_Count'],
      attachment_Checked_Count: json['Attachment_Checked_Count'],
      module_Finished_Count: json['Module_Finished_Count'],
      unit_Finished_Count: json['Unit_Finished_Count'],
      courseAccessibleGroup: List.from(json['Result_CourseAccessible'])
    );
  }
}

class CourseUnitList {
  final List<CourseUnitListItem> results;
  final int count;

  CourseUnitList({
    this.results,
    this.count,
  });

  factory CourseUnitList.fromJson(Map json){
    return CourseUnitList(
        results: (json['Results'] as List).map((i) => CourseUnitListItem.fromJson(i)).toList(),
        count: json['RecordsCount'] as int
    );
  }
}

class CourseUnitListItem {
  final int unitID, unitModuleCount, unitModuleAttachmentCount, attachment_Checked_Count, module_Finished_Count;
  final String unitName, unitDesc, unitFolder;
  final DateTime unitPeriod_Start, unitPeriod_End;
  final bool skip_moduleSelection;
  final String to_moduleID;

  CourseUnitListItem({
    this.unitID,
    this.unitName,
    this.unitDesc,
    this.unitPeriod_Start,
    this.unitPeriod_End,
    this.unitFolder,
    this.unitModuleCount,
    this.unitModuleAttachmentCount,
    this.attachment_Checked_Count,
    this.module_Finished_Count,
    this.skip_moduleSelection,
    this.to_moduleID
  });

  factory CourseUnitListItem.fromJson(Map<String, dynamic> json) {
    return CourseUnitListItem(
      unitID: json['unitID'],
      unitName: json['unitName'],
      unitDesc: json['unitDesc'],
      unitPeriod_Start: DateTime.parse(json['unit_Period_Start'].toString()),
      unitPeriod_End: DateTime.parse(json['unit_Period_End'].toString()),
      unitFolder: json['unit_Folder'],
      unitModuleCount: json['Module_Count'],
      unitModuleAttachmentCount: json['Attachment_Count'],
      attachment_Checked_Count: json['Attachment_Checked_Count'],
      module_Finished_Count: json['Module_Finished_Count'],
      skip_moduleSelection: json['skip_moduleselection'] as bool ?? false,
      to_moduleID: json['to_moduleID'],
    );
  }
}

class MaterialList {
  final List<MaterialListItem> results;
  final int count;

  MaterialList({
    this.results,
    this.count,
  });

  factory MaterialList.fromJson(Map json){
    return MaterialList(
        results: (json['Results'] as List).map((i) => MaterialListItem.fromJson(i)).toList(),
        count: json['RecordsCount'] as int
    );
  }
}

class AttachmentListItem{
  final int attID, attSize;
  final String attName, attPath, attExt;
  final bool check_status;
  final String download_datetime;

  AttachmentListItem({
    this.attID,
    this.attSize,
    this.attName,
    this.attPath,
    this.attExt,
    this.check_status,
    this.download_datetime
  });

  factory AttachmentListItem.fromJson(Map<String, dynamic> json) {
    return AttachmentListItem(
      attID: json['ID'],
      attSize: json['Size'],
      attName: json['Name'],
      attPath: json['Path'],
      attExt: json['Extension'],
      check_status: json['Check_Status'] as bool ?? false,
      download_datetime: json['Last_DownloadDate'],
    );
  }
}

class MaterialListItem {
  final int materialID, att_count, checked_count;
  final String materialName, materialDesc, materialFolder;
  final DateTime materialPeriod_Start, materialPeriod_End;
  final List<AttachmentListItem> att_list;

  MaterialListItem({
    this.materialID,
    this.materialName,
    this.materialDesc,
    this.materialFolder,
    this.materialPeriod_Start,
    this.materialPeriod_End,
    this.att_count,
    this.att_list,
    this.checked_count
  });

  factory MaterialListItem.fromJson(Map<String, dynamic> json) {
    return MaterialListItem(
      materialID: json['materialID'],
      materialName: json['materialName'],
      materialDesc: json['materialDesc'],
      materialFolder: json['material_Folder'],
      materialPeriod_Start: DateTime.parse(json['material_Period_Start'].toString()),
      materialPeriod_End: DateTime.parse(json['material_Period_End'].toString()),
      att_count: json['Attachment_Count'],
      att_list: (json['Attachments'] as List).map((i) => AttachmentListItem.fromJson(i)).toList(),
      checked_count: json['CheckedCount'],
    );
  }
}

class SurveyList {
  final List<SurveyListItem> results;
  final int count;

  SurveyList({
    this.results,
    this.count,
  });

  factory SurveyList.fromJson(Map json){
    print((json['Results']));
    return SurveyList(
        results: (json['Results'] as List).map((i) => SurveyListItem.fromJson(i)).toList(),
        count: json['RecordsCount'] as int
    );
  }
}

class SurveyListItem {
  final int surveyID;
  final String surveyName, surveyDesc, surveyURL;
  final DateTime surveyPeriod_Start, surveyPeriod_End;
  final List<String> surveyAccessibleGroup;

  SurveyListItem({
    this.surveyID,
    this.surveyName,
    this.surveyDesc,
    this.surveyURL,
    this.surveyPeriod_Start,
    this.surveyPeriod_End,
    this.surveyAccessibleGroup
  });

  factory SurveyListItem.fromJson(Map<String, dynamic> json) {
    return SurveyListItem(
      surveyID: int.parse(json['SurveyID']),
      surveyName: json['SurveyTitle'],
      surveyDesc: json['SurveyDesc'],
      surveyURL: json['SurveyLink'],
      surveyPeriod_Start: DateTime.parse(json['SurveyPeriod_Start'].toString()),
      surveyPeriod_End: DateTime.parse(json['SurveyPeriod_End'].toString()),
      surveyAccessibleGroup: List.from(json['Result_SurveyAccessible'])
    );
  }
}