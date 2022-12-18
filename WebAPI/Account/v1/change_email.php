<?php
header('Content-Type: application/json');
include($_SERVER['DOCUMENT_ROOT']."/Secret/MySQL/config.php");
// Storing the received JSON into $json variable.
$json = file_get_contents('php://input');
 
// Decode the received JSON and Store into $obj variable.
$obj = json_decode($json,true);



$Table_ac = table_ac;
$UID=$obj['UID'];

// Checking the validation of API Account Token
require_once($_SERVER['DOCUMENT_ROOT']."/Account/v1/check_token.php");

$Result = array();
$statuscode = array(
    "Success" => 1000,
    "Invaild_Expired" => 1001,
    "Email_Exists" => 1002,
);

$SQL_Get_User = $conn->prepare(
    "SELECT * FROM $Table_ac WHERE UID = ?"
);
$SQL_Get_User->execute(array($UID));
$count = $SQL_Get_User->rowCount();

if($count == 1){
    $newEmail=$obj['Email'];
    date_default_timezone_set("Asia/Hong_Kong");
    
    $SQL_CheckRepeatability_Email= $conn->prepare("SELECT email FROM $Table_ac WHERE email = ?");
    $SQL_CheckRepeatability_Email->execute(array($newEmail));
    $Email_count = $SQL_CheckRepeatability_Email->rowCount();
    if($Email_count == 0){
        $SQL_Update_Email = $conn->prepare(
            "UPDATE $Table_ac SET email = ?, emailverified = ? WHERE UID = ?"
        );
        $SQL_Update_Email->execute(array($newEmail, 0, $UID));
    
        $Result = array();
        $Result["StatusCode"] = $statuscode["Success"];
        $Result["Message"] = "Records has been updated.";
    } else {
        $Result = array();
        $Result["StatusCode"] = $statuscode["Email_Exists"];
        $Result["Message"] = "Email Exists";
    }
}

$JSON_result = json_encode($Result,JSON_PRETTY_PRINT);

print_r($JSON_result);

?>