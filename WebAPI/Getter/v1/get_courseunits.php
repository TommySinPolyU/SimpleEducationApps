<?php
header('Content-Type: application/json');
include($_SERVER['DOCUMENT_ROOT']."/Secret/MySQL/config.php");
$Results = array();

// Checking the validation of API Account Token
require_once($_SERVER['DOCUMENT_ROOT']."/Account/v1/check_token.php");

#region API Part: Only Executing when API Token are valid.
$Table_Courses = table_Courses;
$Table_CourseUnits = table_Units;
$Table_Materials = table_Materials;
$Table_Attachment = table_Attachment;
$Table_AttachmentChecker = table_AttachmentChecker;

$courseID = $_GET['CID'];

$statuscode = array(
    1000 => "OK",
    1001 => "Record Not Found",
);

if(!isset($_GET['isExpired'])){
    $_GET['isExpired'] = false;
}
if(!isset($_GET['isComingSoon'])){
    $_GET['isComingSoon'] = false;
}
if(!isset($_GET['isOpening'])){
    $_GET['isOpening'] = false;
}

$SQL_GetCourseData = $conn->prepare("SELECT * FROM $Table_Courses WHERE courseID = ?");
$SQL_GetCourseData->execute(array($courseID));
$count_course = $SQL_GetCourseData->rowCount();

if($count_course > 0){

    if($_GET['isExpired']==true){
        $SQL_GetUnitsData = $conn->prepare("
        SELECT $Table_CourseUnits.* ,
        (SELECT COUNT(*) FROM $Table_Materials WHERE $Table_Materials.unitID = $Table_CourseUnits.unitID) AS ModuleCount
        FROM $Table_CourseUnits 
        WHERE courseID = ? AND (CONVERT_TZ(CURRENT_TIMESTAMP, '+00:00', '+08:00') > Period_End)
        ORDER BY orderID");
    } else if($_GET['isComingSoon']==true){
        $SQL_GetUnitsData = $conn->prepare("
        SELECT $Table_CourseUnits.* ,
        (SELECT COUNT(*) FROM $Table_Materials WHERE $Table_Materials.unitID = $Table_CourseUnits.unitID) AS ModuleCount
        FROM $Table_CourseUnits 
        WHERE courseID = ? AND (Period_Start > CONVERT_TZ(CURRENT_TIMESTAMP, '+00:00', '+08:00'))
        ORDER BY orderID");
    } else if($_GET['isOpening']){
        $SQL_GetUnitsData = $conn->prepare("
        SELECT $Table_CourseUnits.* ,
        (SELECT COUNT(*) FROM $Table_Materials WHERE $Table_Materials.unitID = $Table_CourseUnits.unitID) AS ModuleCount
        FROM $Table_CourseUnits 
        WHERE courseID = ? AND (CONVERT_TZ(CURRENT_TIMESTAMP, '+00:00', '+08:00')) BETWEEN Period_Start AND Period_End
        ORDER BY orderID");
    } else {
        $SQL_GetUnitsData = $conn->prepare("
        SELECT $Table_CourseUnits.* ,
        (SELECT COUNT(*) FROM $Table_Materials WHERE $Table_Materials.unitID = $Table_CourseUnits.unitID) AS ModuleCount
        FROM $Table_CourseUnits 
        WHERE courseID = ?
        ORDER BY orderID");
    }

    $SQL_GetUnitsData->execute(array($courseID));
    $count = $SQL_GetUnitsData->rowCount();

    if($count >= 0){
        $Results = array();
        $Results["RecordIDs"] = array();
        $Results["RecordsCount"] = $count;
        $Results["StatusCode"] = $statuscode[1000];
        $Results["Results"] = array();

        while($row = $SQL_GetUnitsData->fetch()) {
            $Result_Single = array();
            $Result_Single["unitID"] = (int)$row['unitID'];
            $Result_Single["unitName"] = $row['Title'];
            $Result_Single["unitDesc"] = $row['Description'];
            $Result_Single["unit_Period_Start"] = $row['Period_Start'];
            $Result_Single["unit_Period_End"] = $row['Period_End'];
            $Result_Single["unit_Folder"] = $row['folderName'];
            $Result_Single["skip_moduleselection"] = (bool)$row['skip_moduleselection'];
            $Result_Single["to_moduleID"] = $row['to_moduleID'];
            $Result_Single["Module_Count"] = (int)$row['ModuleCount'];
            $Result_Single["Module_Finished_Count"] = 0;
            

            if(isset($_GET['UID'])){
                $SQL_GetUnitsAtt_Check = $conn->prepare("
                SELECT *
                FROM $Table_AttachmentChecker 
                WHERE courseID = ? AND unitID = ? AND userID = ? AND check_status = 1");
                $SQL_GetUnitsAtt_Check->execute(array($courseID, $row['unitID'], $_GET['UID']));
                $count_checked = $SQL_GetUnitsAtt_Check->rowCount();
                $Result_Single["Attachment_Checked_Count"] = $count_checked;
                $Result_Single["Attachment_Count"] = 0;

                $SQL_GetUnitsAttCount = $conn->prepare(
                    "
                    SELECT 
                    COUNT($Table_Attachment.attID) AS UnitAttCount
                    FROM $Table_CourseUnits
                    INNER JOIN $Table_Materials ON $Table_Materials.unitID = $Table_CourseUnits.unitID
                    INNER JOIN $Table_Attachment ON $Table_Attachment.matID = $Table_Materials.ID
                    WHERE $Table_CourseUnits.unitID = ?
                    GROUP BY $Table_CourseUnits.unitID
                    "
                );
                $SQL_GetUnitsAttCount->execute(array($row['unitID']));

                while($UnitsAtt_row = $SQL_GetUnitsAttCount->fetch()) {
                    $Result_Single["Attachment_Count"] = (int)$UnitsAtt_row['UnitAttCount'];
                }

                /*
                $SQL_GetModuleNull= $conn->prepare(
                    "
                    SELECT $Table_Materials.ID, $Table_CourseUnits.unitID,COUNT($Table_Attachment.matID) as ModuleAttCount
                    FROM $Table_CourseUnits
                    LEFT JOIN $Table_Materials ON $Table_Materials.unitID = $Table_CourseUnits.unitID
                    LEFT JOIN $Table_Attachment ON $Table_Attachment.matID = $Table_Materials.ID
                    WHERE $Table_CourseUnits.unitID = ?
                    GROUP BY $Table_Materials.ID
                    "
                );
                $SQL_GetModuleNull->execute(array($row['unitID']));
                while($unit_module_null_row = $SQL_GetModuleNull->fetch()) {
                    if($unit_module_null_row['ModuleAttCount'] == 0){
                        $Result_Single["Module_Finished_Count"] += 1;
                    }
                }
                */

                $SQL_GetUnitsModuleChecked = $conn->prepare(
                    "
                        SELECT SUM(if ($Table_AttachmentChecker.check_status = 1, 1,0)) as ModuleCheckedCount ,
                        COUNT($Table_AttachmentChecker.check_status) as ModuleAttCount,
                        COUNT($Table_Attachment.attID) as UnitAttCount
                        FROM $Table_Materials
                        INNER JOIN $Table_Attachment ON $Table_Attachment.matID = $Table_Materials.ID
                        INNER JOIN $Table_AttachmentChecker ON $Table_AttachmentChecker.attID = $Table_Attachment.attID
                        WHERE $Table_AttachmentChecker.userID = ? AND $Table_Materials.unitID = ?
                        GROUP BY $Table_Materials.ID
                    "
                );
                $SQL_GetUnitsModuleChecked->execute(array($_GET['UID'], $row['unitID']));
                while($module_check_row = $SQL_GetUnitsModuleChecked->fetch()) {
                    if($module_check_row['ModuleCheckedCount'] == $module_check_row['ModuleAttCount']){
                        $Result_Single["Module_Finished_Count"] += 1;
                    }
                }

            }
            array_push($Results["Results"], $Result_Single);
            array_push($Results["RecordIDs"], $Result_Single["unitID"]);
        }
    }
} else {
    $Results = array();
    $Results["Searching CID"] = $courseID;
    $Results["StatusCode"] = $statuscode[1001];
}


if(isset($_GET['UnitID'])){
    if($count >= 1){
        if(in_array($_GET['UnitID'], $Results["RecordIDs"])){
            $JSON_result = json_encode(
                $Results["Results"][array_search($_GET['UnitID'], $Results["RecordIDs"])], 
                JSON_PRETTY_PRINT);
        } else {
            $Results["Results"] = array();
            $Results["Searching UnitID"] = $_GET['UnitID'];
            $Results["StatusCode"] = $statuscode[1001];
            $JSON_result = json_encode($Results, JSON_PRETTY_PRINT);
        }
    } else {
        $Results = array();
        $Results["CID"] = $_GET['CID'];
        $Results["UnitID"] = $_GET['UnitID'];
        $Results["StatusCode"] = $statuscode[1001];
        $JSON_result = json_encode($Results, JSON_PRETTY_PRINT);
    }
} else {
    $JSON_result = json_encode($Results, JSON_PRETTY_PRINT);
}
print_r($JSON_result);
#endregion

function mb_pathinfo($filepath) {
    preg_match('%^(.*?)[\\\\/]*(([^/\\\\]*?)(\.([^\.\\\\/]+?)|))[\\\\/\.]*$%im',$filepath,$m);
    if($m[1]) $ret['dirname']=$m[1];
    if($m[2]) $ret['basename']=$m[2];
    if($m[5]) $ret['extension']=$m[5];
    if($m[3]) $ret['filename']=$m[3];
    return $ret;
}
?>