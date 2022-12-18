<?php
header('Content-Type: application/json');
include($_SERVER['DOCUMENT_ROOT']."/Secret/MySQL/config.php");
$Results = array();

// Checking the validation of API Account Token
require_once($_SERVER['DOCUMENT_ROOT']."/Account/v1/check_token.php");

$Table_Courses = table_Courses;
$Table_CourseUnits = table_Units;
$Table_Materials = table_Materials;
$Table_Attachment = table_Attachment;
$Table_AttachmentChecker = table_AttachmentChecker;

$courseID = $_GET['CID'];
$courseUnitID = $_GET['UnitID'];

$statuscode = array(
    1000 => "OK",
    1001 => "Record Not Found",
    1002 => "Unit Record Not Found",
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

$SQL_GetCourseUnitData = $conn->prepare("SELECT * FROM $Table_CourseUnits WHERE courseID = ? AND unitID = ?");
$SQL_GetCourseUnitData->execute(array($courseID, $courseUnitID));
$count_courseunit = $SQL_GetCourseUnitData->rowCount();

if($count_course > 0){
    if($count_courseunit > 0){
        if($_GET['isExpired']==true){
            $SQL_GetMaterialsData = $conn->prepare("
            SELECT $Table_Materials .* ,
            (SELECT COUNT(*) FROM $Table_Attachment WHERE $Table_Attachment.matID = $Table_Materials.ID) AS AttachmentCount
            FROM $Table_Materials 
            WHERE courseID = ? AND unitID = ? AND (CONVERT_TZ(CURRENT_TIMESTAMP, '+00:00', '+08:00') > Period_End)
            ORDER BY orderID");
        } else if($_GET['isComingSoon']==true){
            $SQL_GetMaterialsData = $conn->prepare("
            SELECT $Table_Materials .* ,
            (SELECT COUNT(*) FROM $Table_Attachment WHERE $Table_Attachment.matID = $Table_Materials.ID) AS AttachmentCount
            FROM $Table_Materials 
            WHERE courseID = ? AND unitID = ? AND (Period_Start > CONVERT_TZ(CURRENT_TIMESTAMP, '+00:00', '+08:00'))
            ORDER BY orderID");
        } else if($_GET['isOpening']){
            $SQL_GetMaterialsData = $conn->prepare("
            SELECT $Table_Materials .* ,
            (SELECT COUNT(*) FROM $Table_Attachment WHERE $Table_Attachment.matID = $Table_Materials.ID) AS AttachmentCount
            FROM $Table_Materials 
            WHERE courseID = ? AND unitID = ? AND (CONVERT_TZ(CURRENT_TIMESTAMP, '+00:00', '+08:00')) BETWEEN Period_Start AND Period_End
            ORDER BY orderID");
        } else {
            $SQL_GetMaterialsData = $conn->prepare("
            SELECT $Table_Materials .* ,
            (SELECT COUNT(*) FROM $Table_Attachment WHERE $Table_Attachment.matID = $Table_Materials.ID) AS AttachmentCount
            FROM $Table_Materials 
            WHERE courseID = ? AND unitID = ?
            ORDER BY orderID");
        }
        
        $SQL_GetMaterialsData->execute(array($courseID, $courseUnitID));
        $count = $SQL_GetMaterialsData->rowCount();
    
        while($row = $SQL_GetCourseData->fetch()) {
            $courseFolder = $row['courseFolder'];
        }

        while($row = $SQL_GetCourseUnitData->fetch()) {
            $courseunitFolder = $row['folderName'];
        }
        
        if($count >= 0){
            $Results = array();
            $Results["RecordIDs"] = array();
            $Results["RecordsCount"] = $count;
            $Results["StatusCode"] = $statuscode[1000];
            $Results["Results"] = array();
            $Results["ModuleFinishedCount"] = 0;

            while($row = $SQL_GetMaterialsData->fetch()) {
                $Result_Single = array();
                $Result_Single["materialID"] = (int)$row['ID'];
                $Result_Single["materialName"] = $row['Title'];
                $Result_Single["materialDesc"] = $row['Description'];
                $Result_Single["material_RequiredTime"] = $row['Required_Time'];
                $Result_Single["material_Period_Start"] = $row['Period_Start'];
                $Result_Single["material_Period_End"] = $row['Period_End'];
                $Result_Single["material_Folder"] = $row['foldername'];
                $Result_Single["Attachment_Count"] = (int)$row['AttachmentCount'];
                $Result_Single["Attachments"] = array();
                $Attachments_DownloadDate = array();
                $Attachments_Check_Status = array();
                $Result_Single["CheckedCount"] = 0;

                $SQL_GetAttachments = $conn->prepare("
                SELECT *
                FROM $Table_Attachment 
                WHERE courseID = ? AND unitID = ? AND matID = ? ORDER BY orderID");
                $SQL_GetAttachments->execute(array($courseID, $courseUnitID, $row['ID']));
                $att_count = $SQL_GetAttachments->rowCount();

                if($att_count > 0){
                    $att_count_index = 0;
                    $checked_att_count = 0;
                    while($att_row = $SQL_GetAttachments->fetch()){
                        $att_name = $att_row["filename"];
                        $att_id = $att_row["attID"];
                        if(isset($_GET['UID'])){
                            $userID = $_GET['UID'];
                            $SQL_Get_Attachment_Check = $conn->prepare(
                                "SELECT * FROM $Table_AttachmentChecker WHERE userID  = ? AND courseID = ? AND unitID = ? AND matID = ? AND attID = ?"
                            );
                            $SQL_Get_Attachment_Check->execute(array($userID,$courseID,$courseUnitID, $Result_Single["materialID"], $att_id));
                            $count_att_check = $SQL_Get_Attachment_Check->rowCount();
                    
                            if($count_att_check == 0){
                                $SQL_Insert_Attachment_Check = $conn->prepare(
                                    "INSERT INTO $Table_AttachmentChecker(userID, courseID, unitID, matID, attID, download_date, check_status) 
                                    VALUES(?,?,?,?,?,?,?)"
                                );
                                $SQL_Insert_Attachment_Check->execute(array(
                                    $userID,$courseID,$courseUnitID,$Result_Single["materialID"],$att_id,null,0));
                                array_push($Attachments_Check_Status, 0);
                                array_push($Attachments_DownloadDate, null);
                            } else {
                                while($att_check_row = $SQL_Get_Attachment_Check->fetch()){
                                    array_push($Attachments_Check_Status, $att_check_row['check_status']);
                                    array_push($Attachments_DownloadDate, $att_check_row['download_date']);
                                    if($att_check_row['check_status'] == 1){
                                        $checked_att_count = $checked_att_count + 1;
                                    }
                                }
                            }
                            if($checked_att_count == $att_count){
                                $Result_Single["Status"] = "Finished";
                                $Results["ModuleFinishedCount"] = $Results["ModuleFinishedCount"] + 1;
                            }
                        }
                        $destination_dir = $_SERVER['SERVER_NAME']."/"."uploads/" . $courseFolder . '/' . $courseunitFolder . '/' . $row['foldername'] . '/' . $att_name;
                        $dir_absolute = $_SERVER['DOCUMENT_ROOT']."/"."uploads/" . $courseFolder . '/' . $courseunitFolder. '/' .  $row['foldername'] . '/' . $att_name;
                        
                        $Result_Single["CheckedCount"] = $checked_att_count;



                        if(file_exists($dir_absolute) && $att_name != ""){
                            $Attachment_Single = array();
                            $path_info = mb_pathinfo($destination_dir);
                            $base_filename = $path_info['basename'];
                            $base_fileext = $path_info['extension'];
                            $Attachment_Single["ID"] = (int)$att_row["attID"];
                            $Attachment_Single["Name"] = $att_row["filename"];
                            $Attachment_Single["Path"] = $destination_dir;
                            if(is_file($dir_absolute))
                                $Attachment_Single["Size"] = filesize($dir_absolute);

                            $Attachment_Single["Extension"] = $base_fileext;
                            if(isset($_GET['UID'])){
                                $Attachment_Single["Check_Status"] = (bool)$Attachments_Check_Status[$att_count_index];
                                $Attachment_Single["Last_DownloadDate"] = $Attachments_DownloadDate[$att_count_index];
                            }  
                                
                            array_push($Result_Single["Attachments"], $Attachment_Single);
                            $att_count_index = $att_count_index + 1;
                        }
                    }
                }

                /*
                if(!empty($row['Attachment'])){
                    $Result_Single["material_Attachment"] = $row['Attachment'];
                    $attachments = explode(",", $Result_Single["material_Attachment"]);
                    $destination_dir = $_SERVER['SERVER_NAME']."/"."uploads/" . $courseFolder . '/' . $courseunitFolder . '/' . $Result_Single["material_Folder"] . '/';
                    for($i = 0;$i < count($attachments); $i++){
                        $dir_absolute = $_SERVER['DOCUMENT_ROOT']."/"."uploads/" . $courseFolder . '/' . $courseunitFolder. '/' .  $Result_Single["material_Folder"] . '/';
                        if(file_exists($dir_absolute.$attachments[$i])){
                            $path_info = mb_pathinfo($destination_dir.$attachments[$i]);
                            $base_filename = $path_info['basename'];
                            $base_fileext = $path_info['extension'];
                            if(is_file($dir_absolute.$base_filename))
                                array_push($Result_Single["material_Attachment_Size"], filesize($dir_absolute.$base_filename));
                            array_push($Result_Single["material_Attachment_Path"], $destination_dir . $attachments[$i]);
                            array_push($Result_Single["material_Attachment_Name"], $base_filename);
                            array_push($Result_Single["material_Attachment_Extension"], $base_fileext);
                        }
                    }
                }
                if(count($Result_Single["material_Attachment_Path"]) == 0)
                    $Result_Single["material_Attachment"] = "";
                */
                if(!isset($_GET['UID']))
                    unset($Results["ModuleFinishedCount"]);
                array_push($Results["Results"], $Result_Single);
                array_push($Results["RecordIDs"], $Result_Single["materialID"]);
            }
        }
    } else {
        $Results = array();
        $Results["Searching CID"] = $courseID;
        $Results["StatusCode"] = $statuscode[1002];
    }
} else {
    $Results = array();
    $Results["Searching CID"] = $courseID;
    $Results["StatusCode"] = $statuscode[1001];
}


if(isset($_GET['MID'])){
    if($count >= 1){
        if(in_array($_GET['MID'], $Results["RecordIDs"])){
            $JSON_result = json_encode(
                $Results["Results"][array_search($_GET['MID'], $Results["RecordIDs"])], 
                JSON_PRETTY_PRINT);
        } else {
            $Results["Results"] = array();
            $Results["Searching MID"] = $_GET['MID'];
            $Results["StatusCode"] = $statuscode[1001];
            $JSON_result = json_encode($Results, JSON_PRETTY_PRINT);
        }
    } else {
        $Results = array();
        $Results["CID"] = $_GET['CID'];
        $Results["MID"] = $_GET['MID'];
        $Results["StatusCode"] = $statuscode[1001];
        $JSON_result = json_encode($Results, JSON_PRETTY_PRINT);
    }
} else {
    $JSON_result = json_encode($Results, JSON_PRETTY_PRINT);
}


print_r($JSON_result);

function mb_pathinfo($filepath) {
    preg_match('%^(.*?)[\\\\/]*(([^/\\\\]*?)(\.([^\.\\\\/]+?)|))[\\\\/\.]*$%im',$filepath,$m);
    if($m[1]) $ret['dirname']=$m[1];
    if($m[2]) $ret['basename']=$m[2];
    if($m[5]) $ret['extension']=$m[5];
    if($m[3]) $ret['filename']=$m[3];
    return $ret;
}
?>