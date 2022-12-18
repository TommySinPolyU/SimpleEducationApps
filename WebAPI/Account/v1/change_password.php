<?php
header('Content-Type: application/json');
include($_SERVER['DOCUMENT_ROOT']."/Secret/MySQL/config.php");
// Storing the received JSON into $json variable.
$json = file_get_contents('php://input');
 
// Decode the received JSON and Store into $obj variable.
$obj = json_decode($json,true);


$Result = array();
$statuscode = array(
    "Success" => 1000,
    "Invaild_Expired" => 1001,
);


$Table_ac = table_ac;
$Table_ResetPWRecords = table_ResetPWRecords;
$UID=$obj['UID'];

// Checking the validation of API Account Token
if(isset($obj['ResetFromLink'])){
    $SQL_Get_ResetRecord = $conn->prepare(
        "SELECT * FROM $Table_ResetPWRecords WHERE UID = ?"
    );
    $SQL_Get_ResetRecord->execute(array($UID));
    $count = $SQL_Get_ResetRecord->rowCount();
    if($count > 0){
        while($row_reset_record = $SQL_Get_ResetRecord->fetch()) {
            $resetCode = $row_reset_record['resetCode'];
            $DB_IssueDate = $row_reset_record['resetDate'];
        }
        $DB_IssueDate = (strtotime($DB_IssueDate));
        $minutes_diff = abs($DB_IssueDate - time()) / 60;
        if($resetCode != $obj['resetCode'] || $minutes_diff >= 30){
            $Result = array();
            $Result["StatusCode"] = $statuscode["Invaild_Expired"];
            http_response_code(417);
            $JSON_result = json_encode($Result,JSON_PRETTY_PRINT);
            print_r($JSON_result);
            exit;
        }
    }
}

if(!isset($obj['ResetFromLink'])){
    require_once($_SERVER['DOCUMENT_ROOT']."/Account/v1/check_token.php");
}

$statuscode = array(
    "Success" => 1000,
    "Invaild_Expired" => 1001,
);

$SQL_Get_User = $conn->prepare(
    "SELECT * FROM $Table_ac WHERE UID = ?"
);
$SQL_Get_User->execute(array($UID));
$count = $SQL_Get_User->rowCount();

if($count == 1){
    $newPassword=$obj['Password'];
    $hashedPW = password_hash($newPassword, PASSWORD_DEFAULT); // Convert Password To Hashed Value
    date_default_timezone_set("Asia/Hong_Kong");

    $SQL_Update_Password = $conn->prepare(
        "UPDATE $Table_ac SET password = ? WHERE UID = ?"
    );
    $SQL_Update_Password->execute(array($hashedPW, $UID));
    
    $SQL_Delete_AllUserRecords = $conn->prepare(
        "DELETE FROM $Table_ResetPWRecords WHERE UID = ?"
    );
    $SQL_Delete_AllUserRecords->execute(array($UID));

    $Result = array();
    $Result["StatusCode"] = $statuscode["Success"];
    $Result["Message"] = "Records has been updated.";
}

$JSON_result = json_encode($Result,JSON_PRETTY_PRINT);

print_r($JSON_result);

?>