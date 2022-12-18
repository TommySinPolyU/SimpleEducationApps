<?php
include($_SERVER['DOCUMENT_ROOT']."/Secret/MySQL/config.php");

$Result = array();
$statuscode = array(
    "OK" => 1000,
    "TableNameNotFound" => 1001
);

// Storing the received JSON into $json variable.
$json = file_get_contents('php://input');
 
// Decode the received JSON and Store into $obj variable.
$obj = json_decode($json,true);

date_default_timezone_set("Asia/Hong_Kong");
$currenttime = date("Y-m-d H:i:s");

$Table_Course_Progress = table_Course_Progress;
$Table_Unit_Progress = table_Unit_Progress;
$Table_Module_Progress = table_Module_Progress;
$Table_AttachmentChecker = table_AttachmentChecker;

if(isset($obj["UpdateTable"])){
    $update_table = $obj["UpdateTable"];
    if($update_table == "Course"){
        $userID = $obj["UID"];
        $courseID = $obj["CourseID"];
        $SQL_Get_CourseProgress = $conn->prepare(
            "SELECT * FROM $Table_Course_Progress WHERE userID  = ? AND courseID = ?"
        );
        $SQL_Get_CourseProgress->execute(array($userID,$courseID));
        $count = $SQL_Get_CourseProgress->rowCount();

        if($count == 0){
            $SQL_Insert_CourseProgress = $conn->prepare(
                "INSERT INTO $Table_Course_Progress(userID, courseID, start_date, last_open_date) 
                VALUES(?,?,?,?)"
            );
            $SQL_Insert_CourseProgress->execute(array($userID,$courseID,$currenttime,$currenttime));
        } else {
            $SQL_Update_CourseProgress = $conn->prepare(
                "UPDATE $Table_Course_Progress SET 
                last_open_date = ? 
                WHERE userID = ? AND courseID = ?"
            );
            $SQL_Update_CourseProgress->execute(array($currenttime,$userID,$courseID));
        }
        $Result = array();
        $Result["StatusCode"] = $statuscode["OK"];
        $Result["Message"] = "Record has been successfully inserted / updated";
    } else if($update_table == "Unit"){
        $userID = $obj["UID"];
        $courseID = $obj["CourseID"];
        $unitID = $obj["UnitID"];
        $SQL_Get_UnitProgress = $conn->prepare(
            "SELECT * FROM $Table_Unit_Progress WHERE userID  = ? AND courseID = ? AND unitID = ?"
        );
        $SQL_Get_UnitProgress->execute(array($userID,$courseID,$unitID));
        $count = $SQL_Get_UnitProgress->rowCount();

        if($count == 0){
            $SQL_Insert_UnitProgress = $conn->prepare(
                "INSERT INTO $Table_Unit_Progress(userID, courseID, unitID, start_date, last_open_date) 
                VALUES(?,?,?,?,?)"
            );
            $SQL_Insert_UnitProgress->execute(array($userID,$courseID,$unitID,$currenttime,$currenttime));
        } else {
            $SQL_Update_UnitProgress = $conn->prepare(
                "UPDATE $Table_Unit_Progress SET 
                last_open_date = ? 
                WHERE userID = ? AND courseID = ? AND unitID = ?"
            );
            $SQL_Update_UnitProgress->execute(array($currenttime,$userID,$courseID, $unitID));
        }
        $Result = array();
        $Result["StatusCode"] = $statuscode["OK"];
        $Result["Message"] = "Record has been successfully inserted / updated";
    } else if($update_table == "Module"){
        $userID = $obj["UID"];
        $courseID = $obj["CourseID"];
        $unitID = $obj["UnitID"];
        $moduleID = $obj["MaterialID"];
        $SQL_Get_ModuleProgress = $conn->prepare(
            "SELECT * FROM $Table_Module_Progress WHERE userID  = ? AND courseID = ? AND unitID = ? AND matID = ?"
        );
        $SQL_Get_ModuleProgress->execute(array($userID,$courseID,$unitID, $moduleID));
        $count = $SQL_Get_ModuleProgress->rowCount();

        if($count == 0){
            $SQL_Insert_ModuleProgress = $conn->prepare(
                "INSERT INTO $Table_Module_Progress(userID, courseID, unitID, matID, start_date, last_open_date) 
                VALUES(?,?,?,?,?,?)"
            );
            $SQL_Insert_ModuleProgress->execute(array($userID,$courseID,$unitID,$moduleID,$currenttime,$currenttime));
        } else {
            $SQL_Update_ModuleProgress = $conn->prepare(
                "UPDATE $Table_Module_Progress SET 
                last_open_date = ? 
                WHERE userID = ? AND courseID = ? AND unitID = ? AND matID = ?"
            );
            $SQL_Update_ModuleProgress->execute(array($currenttime,$userID,$courseID,$unitID,$moduleID));
        }
        $Result = array();
        $Result["StatusCode"] = $statuscode["OK"];
        $Result["Message"] = "Record has been successfully inserted / updated";
    } else if($update_table == "Attachment"){
        $userID = $obj["UID"];
        $courseID = $obj["CourseID"];
        $unitID = $obj["UnitID"];
        $moduleID = $obj["MaterialID"];
        $attID = $obj["AttID"];
        $att_status = $obj['check_status'];
        $SQL_Get_Attachment_Check = $conn->prepare(
            "SELECT * FROM $Table_AttachmentChecker WHERE userID  = ? AND courseID = ? AND unitID = ? AND matID = ? AND attID = ?"
        );
        $SQL_Get_Attachment_Check->execute(array($userID,$courseID,$unitID, $moduleID, $attID));
        $count = $SQL_Get_Attachment_Check->rowCount();

        if($count == 0){
            $SQL_Insert_Attachment_Check = $conn->prepare(
                "INSERT INTO $Table_AttachmentChecker(userID, courseID, unitID, matID, attID, download_date, check_status) 
                VALUES(?,?,?,?,?,?,?)"
            );
            $SQL_Insert_Attachment_Check->execute(array($userID,$courseID,$unitID,$moduleID,$attID,$currenttime,$att_status));
        } else {
            $SQL_Update_Attachment_Check = $conn->prepare(
                "UPDATE $Table_AttachmentChecker SET 
                check_status = ?, download_date = ?
                WHERE userID = ? AND courseID = ? AND unitID = ? AND matID = ? AND attID = ?"
            );
            $SQL_Update_Attachment_Check->execute(array($att_status, $currenttime,$userID,$courseID,$unitID,$moduleID,$attID));
        }
        $Result = array();
        $Result["StatusCode"] = $statuscode["OK"];
        $Result["Message"] = "Record has been successfully inserted / updated";
    }
} else {
    $Result = array();
    $Result["StatusCode"] = $statuscode["TableNameNotFound"];
    $Result["Message"] = "Table Name Not Found.";
}

$JSON_result = json_encode($Result,JSON_PRETTY_PRINT);

print_r($JSON_result);
?>