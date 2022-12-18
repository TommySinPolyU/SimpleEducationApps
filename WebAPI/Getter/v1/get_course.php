<?php
// Include and Initialization
header('Content-Type: application/json');
include($_SERVER['DOCUMENT_ROOT']."/Secret/MySQL/config.php");

$Results = array();
$statuscode = array(
    1000 => "OK",
    1001 => "Record Not Found",
    1002 => "Token Not Found",
);

// Checking the validation of API Account Token
require_once($_SERVER['DOCUMENT_ROOT']."/Account/v1/check_token.php");

#region API Part: Only Executing when API Token are valid.
$Table_Courses = table_Courses;
$Table_CourseUnits = table_Units;
$Table_Materials = table_Materials;
$Table_Attachment = table_Attachment;
$Table_AttachmentChecker = table_AttachmentChecker;
$Table_CourseAccessible = table_CourseAccessible;
$Table_UserSubGroup = table_UserSubGroups;

// Get Last Auto Increment ID.
$SQL_Get_CID = $conn->prepare(
    "SELECT AUTO_INCREMENT FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?"
);
$SQL_Get_CID->execute(array(DB_NAME,$Table_Courses));

while($row = $SQL_Get_CID->fetch()) {
    $Last_CID = (int)$row['AUTO_INCREMENT'];
}

$currenttime = date("Y-m-d H:i:s");
$timestamp = strtotime($currenttime);

if(!isset($_GET['isExpired'])){
    $_GET['isExpired'] = false;
}
if(!isset($_GET['isComingSoon'])){
    $_GET['isComingSoon'] = false;
}
if(!isset($_GET['isOpening'])){
    $_GET['isOpening'] = false;
}

if(isset($_GET['isAdmin'])){
    if($_GET['isAdmin'] == 'false')
        $_GET['isAdmin']= false;
    else
        $_GET['isAdmin'] = true;
} else {
    $_GET['isAdmin'] = false;
}

if($_GET['isAdmin'] == true || !isset($_GET['UID'])){
    if($_GET['isExpired']==true){
        $SQL_GetCourseData = $conn->prepare("
        SELECT DISTINCT $Table_Courses.*,
        (SELECT COUNT(*) FROM $Table_CourseUnits WHERE $Table_CourseUnits.courseID = $Table_Courses.courseID) AS UnitCount
        FROM $Table_Courses 
        WHERE CONVERT_TZ(CURRENT_TIMESTAMP, '+00:00', '+08:00') > coursePeriod_End
        ORDER BY orderID");
    } else if($_GET['isComingSoon']==true){
        $SQL_GetCourseData = $conn->prepare("
        SELECT DISTINCT $Table_Courses.*,
        (SELECT COUNT(*) FROM $Table_CourseUnits WHERE $Table_CourseUnits.courseID = $Table_Courses.courseID) AS UnitCount
        FROM $Table_Courses 
        WHERE coursePeriod_Start > CONVERT_TZ(CURRENT_TIMESTAMP, '+00:00', '+08:00')
        ORDER BY orderID");
    } else if($_GET['isOpening']){
        $SQL_GetCourseData = $conn->prepare("
        SELECT DISTINCT $Table_Courses.*,
        (SELECT COUNT(*) FROM $Table_CourseUnits WHERE $Table_CourseUnits.courseID = $Table_Courses.courseID) AS UnitCount
        FROM $Table_Courses WHERE (CONVERT_TZ(CURRENT_TIMESTAMP, '+00:00', '+08:00')) BETWEEN coursePeriod_Start AND coursePeriod_End
        ORDER BY orderID");
    } else {
        $SQL_GetCourseData = $conn->prepare("
        SELECT DISTINCT $Table_Courses.*,
        (SELECT COUNT(*) FROM $Table_CourseUnits WHERE $Table_CourseUnits.courseID = $Table_Courses.courseID) AS UnitCount
        FROM $Table_Courses
        ORDER BY orderID
        ");
    }
} else {
    //$user_group = $_GET['UserGroup'];
    $subgroup_array = array();
    $SQL_GetUserSubgroup = $conn->prepare("
        SELECT * 
        FROM $Table_UserSubGroup
        WHERE UID = ?
    ");
    $SQL_GetUserSubgroup->execute(array($_GET['UID']));
    while($row_subgroup = $SQL_GetUserSubgroup->fetch()){
        array_push($subgroup_array, $row_subgroup['subgroup']);
    }

    $subgroup_array_string = "'" .implode("','", $subgroup_array  ) . "'"; 

    if($_GET['isExpired']==true){
        $SQL_GetCourseData = $conn->prepare("
        SELECT DISTINCT $Table_Courses.*,
        (SELECT COUNT(*) FROM $Table_CourseUnits WHERE $Table_CourseUnits.courseID = $Table_Courses.courseID) AS UnitCount
        FROM $Table_Courses 
        INNER JOIN $Table_CourseAccessible ON $Table_CourseAccessible.courseID = $Table_Courses.courseID
        WHERE CONVERT_TZ(CURRENT_TIMESTAMP, '+00:00', '+08:00') > coursePeriod_End AND $Table_CourseAccessible.usergroup IN ($subgroup_array_string)
        GROUP BY $Table_Courses.courseID");
    } else if($_GET['isComingSoon']==true){
        $SQL_GetCourseData = $conn->prepare("
        SELECT DISTINCT $Table_Courses.*,
        (SELECT COUNT(*) FROM $Table_CourseUnits WHERE $Table_CourseUnits.courseID = $Table_Courses.courseID) AS UnitCount
        FROM $Table_Courses
        INNER JOIN $Table_CourseAccessible ON $Table_CourseAccessible.courseID = $Table_Courses.courseID 
        WHERE coursePeriod_Start > CONVERT_TZ(CURRENT_TIMESTAMP, '+00:00', '+08:00') AND $Table_CourseAccessible.usergroup IN ($subgroup_array_string)
        GROUP BY $Table_Courses.courseID");
    } else if($_GET['isOpening']){
        $SQL_GetCourseData = $conn->prepare("
        SELECT DISTINCT $Table_Courses.*,
        (SELECT COUNT(*) FROM $Table_CourseUnits WHERE $Table_CourseUnits.courseID = $Table_Courses.courseID) AS UnitCount
        FROM $Table_Courses 
        INNER JOIN $Table_CourseAccessible ON $Table_CourseAccessible.courseID = $Table_Courses.courseID
        WHERE (CONVERT_TZ(CURRENT_TIMESTAMP, '+00:00', '+08:00')) BETWEEN coursePeriod_Start AND coursePeriod_End AND $Table_CourseAccessible.usergroup IN ($subgroup_array_string)
        GROUP BY $Table_Courses.courseID");
    } else {
        $SQL_GetCourseData = $conn->prepare("
        SELECT DISTINCT $Table_Courses.*,
        (SELECT COUNT(*) FROM $Table_CourseUnits WHERE $Table_CourseUnits.courseID = $Table_Courses.courseID) AS UnitCount
        FROM $Table_Courses
        INNER JOIN $Table_CourseAccessible ON $Table_CourseAccessible.courseID = $Table_Courses.courseID
        WHERE $Table_CourseAccessible.usergroup IN ($subgroup_array_string)
        GROUP BY $Table_Courses.courseID
        ");
    }
}

$SQL_GetCourseData->execute();
$count = $SQL_GetCourseData->rowCount();

if($count >= 1){
    $Results = array();
    $Results["RecordsCount"] = $count;
    $Results["StatusCode"] = $statuscode[1000];
    $Results["Results"] = array();

    while($row = $SQL_GetCourseData->fetch()) {
        $Result_Single = array();
        $Result_Single["StatusCode"] = $statuscode[1000];
        $Result_Single["courseID"] = $row['courseID'];
        $Result_Single["courseName"] = $row['courseName'];
        $Result_Single["courseDesc"] = $row['courseDesc'];
        $Result_Single["coursePeriod_Start"] = $row['coursePeriod_Start'];
        $Result_Single["coursePeriod_End"] = $row['coursePeriod_End'];
        $Result_Single["courseFolder"] = $row['courseFolder'];
        $Result_Single["Unit_Count"] = (int)$row['UnitCount'];

        $Result_Single["Result_CourseAccessible"] = array();
        $SQL_GetCourseAccessible = $conn->prepare("
        SELECT *
        FROM $Table_CourseAccessible 
        WHERE courseID = ?");
        $SQL_GetCourseAccessible->execute(array($row['courseID']));
        while($group_row = $SQL_GetCourseAccessible->fetch()) {
            array_push($Result_Single["Result_CourseAccessible"], $group_row['usergroup']);
        }
        
        if(isset($_GET['UID'])){
            $SQL_GetCourseAtt_Check = $conn->prepare("
            SELECT *
            FROM $Table_AttachmentChecker 
            WHERE courseID = ? AND userID = ? AND check_status = 1");
            $SQL_GetCourseAtt_Check->execute(array($row['courseID'], $_GET['UID']));
            $count_checked = $SQL_GetCourseAtt_Check->rowCount();
            $Result_Single["Attachment_Checked_Count"] = (int)$count_checked;
            $Result_Single["Module_Finished_Count"] = 0;
            $Result_Single["Unit_Finished_Count"] = 0;
            $Result_Single["Module_Attachment_Count"] = 0;
            $Result_Single["Unit_Module_Count"] = 0;

            $SQL_GetUnitsAttCount= $conn->prepare(
                "
                SELECT COUNT($Table_Attachment.matID) as ModuleAttCount
                FROM $Table_CourseUnits
                LEFT JOIN $Table_Materials ON $Table_Materials.unitID = $Table_CourseUnits.unitID
                LEFT JOIN $Table_Attachment ON $Table_Attachment.matID = $Table_Materials.ID
                WHERE $Table_CourseUnits.courseID = ?
                GROUP BY $Table_CourseUnits.unitID
                "
            );
            $SQL_GetUnitsAttCount->execute(array($row['courseID']));
            while($unit_att_row = $SQL_GetUnitsAttCount->fetch()) {
                if($unit_att_row['ModuleAttCount'] == 0){
                    $Result_Single["Unit_Finished_Count"] += 1;
                }
                $Result_Single["Module_Attachment_Count"]  += (int)$unit_att_row['ModuleAttCount'];
            }

            $SQL_GetModuleCount= $conn->prepare(
                "
                SELECT COUNT($Table_Materials.unitID) as ModuleAttCount
                FROM $Table_CourseUnits
                LEFT JOIN $Table_Materials ON $Table_Materials.unitID = $Table_CourseUnits.unitID
                WHERE $Table_CourseUnits.courseID = ?
                GROUP BY $Table_CourseUnits.unitID
                "
            );
            $SQL_GetModuleCount->execute(array($row['courseID']));
            while($unit_module_row = $SQL_GetModuleCount->fetch()) {
                $Result_Single["Unit_Module_Count"]  += (int)$unit_module_row['ModuleAttCount'];
            }

            $SQL_GetUnitsModuleChecked = $conn->prepare(
                "
                    SELECT SUM(if ($Table_AttachmentChecker.check_status = 1, 1,0)) as ModuleCheckedCount ,
                    COUNT($Table_AttachmentChecker.check_status) as ModuleAttCount
                    FROM $Table_CourseUnits
                    INNER JOIN $Table_Materials ON $Table_Materials.courseID = $Table_CourseUnits.courseID
                    INNER JOIN $Table_Attachment ON $Table_Attachment.matID = $Table_Materials.ID
                    INNER JOIN $Table_AttachmentChecker ON $Table_AttachmentChecker.attID = $Table_Attachment.attID
                    WHERE $Table_AttachmentChecker.userID = ? AND $Table_CourseUnits.courseID = ?
                    GROUP BY $Table_Materials.ID
                "
            );
            $SQL_GetUnitsModuleChecked->execute(array($_GET['UID'], $row['courseID']));
            while($module_check_row = $SQL_GetUnitsModuleChecked->fetch()) {
                if($module_check_row['ModuleCheckedCount'] == $module_check_row['ModuleAttCount']){
                    $Result_Single["Module_Finished_Count"] += 1;
                }
            }

            /*
            $SQL_GetModuleNull= $conn->prepare(
                "
                SELECT $Table_Materials.ID, $Table_Courses.courseID,COUNT($Table_Materials.matID) as ModuleAttCount
                FROM $Table_Courses
                LEFT JOIN $Table_Materials ON $Table_Materials.courseID = $Table_Courses.courseID
                LEFT JOIN $Table_Attachment ON $Table_Attachment.matID = $Table_Materials.ID
                WHERE $Table_Courses.courseID = ?
                GROUP BY $Table_Materials.ID
                "
            );
            $SQL_GetModuleNull->execute(array($row['courseID']));
            while($unit_module_null_row = $SQL_GetModuleNull->fetch()) {
                if($unit_module_null_row['ModuleAttCount'] == 0){
                    $Result_Single["Module_Finished_Count"] += 1;
                }
            }
            */

            $SQL_GetUnitsChecked = $conn->prepare(
                "
                    SELECT SUM(if ($Table_AttachmentChecker.check_status = 1, 1,0)) as ModuleCheckedCount ,
                    (COUNT(tb_att_checker.check_status)) as ModuleAttCount
                    FROM $Table_CourseUnits
                    INNER JOIN $Table_Materials ON $Table_Materials.unitID = $Table_CourseUnits.unitID
                    INNER JOIN $Table_Attachment ON $Table_Attachment.matID = $Table_Materials.ID
                    INNER JOIN $Table_AttachmentChecker ON $Table_AttachmentChecker.attID = $Table_Attachment.attID
                    WHERE $Table_AttachmentChecker.userID = ? AND $Table_CourseUnits.courseID = ?
                    GROUP BY $Table_CourseUnits.unitID
                "
            );
            $SQL_GetUnitsChecked->execute(array($_GET['UID'], $row['courseID']));
            while($unit_check_row = $SQL_GetUnitsChecked->fetch()) {
                if($unit_check_row['ModuleCheckedCount'] == $unit_check_row['ModuleAttCount']){
                    $Result_Single["Unit_Finished_Count"] += 1;
                }
            }

        }
        array_push($Results["Results"], $Result_Single);
    }
} else {
    $Results["Results"] = array();
}


if(isset($_GET['CID'])){
    if($_GET['CID'] > 0 && $_GET['CID'] <= $Last_CID){
        $JSON_result = json_encode(
            $Results["Results"][array_search($_GET['CID'], array_column($Results["Results"], 'courseID'))], 
            JSON_PRETTY_PRINT);
    } else {
        $Results = array();
        $Results["CID"] = $_GET['CID'];
        $Results["StatusCode"] = $statuscode[1001];
        $JSON_result = json_encode($Results, JSON_PRETTY_PRINT);
    }
} else {
    $JSON_result = json_encode($Results, JSON_PRETTY_PRINT);
}
print_r($JSON_result);
#endregion
?>