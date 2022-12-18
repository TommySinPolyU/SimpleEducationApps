<?php
include($_SERVER['DOCUMENT_ROOT']."/Secret/MySQL/config.php");

// Checking the validation of API Account Token
require_once($_SERVER['DOCUMENT_ROOT']."/Account/v1/check_token.php");

// Storing the received JSON into $json variable.
$json = file_get_contents('php://input');

if($json == null){
    exit;
}

$statuscode = array(
    "OK" => 1000,
    "Error" => 1001,
);

$Result = array();

$Table_ac = table_ac;
$Table_userinfo = table_userinfo;
$Table_ApplicationSetting = table_ApplicationSetting;

// Decode the received JSON and Store into $obj variable.
$obj = json_decode($json,true);

/*
$username=$obj['UserName'];
$password=$obj['PW'];

$SQL_getPW_Hash = $conn->prepare("SELECT * FROM $Table_ac WHERE Email = ? OR username = ?");
$SQL_getPW_Hash->execute(array($username, $username));
$count = $SQL_getPW_Hash->rowCount();
*/

$AppCode=$obj['AppCode'];
$Version=$obj['Version'];

$SQL_CheckAppSetting = $conn->prepare("SELECT * FROM $Table_ApplicationSetting");
$SQL_CheckAppSetting->execute();

while($row = $SQL_CheckAppSetting->fetch()) {
    $Server_AppCode = $row['AppCode'];
    $Server_Version = $row['Version'];
}

if($AppCode != $Server_AppCode || $Version != $Server_Version){
    exit;
}

$uid=$obj['UID'];
$SQL_GetData = $conn->prepare("SELECT * FROM $Table_ac WHERE UID = ?");
$SQL_GetData->execute(array($uid));
$count = $SQL_GetData->rowCount();
while($row = $SQL_GetData->fetch()) {
    $Result_Email = $row['email'];
}

if($count == 1){
    
    $SQL_getACData = $conn->prepare("SELECT * FROM $Table_userinfo WHERE UID = ?");
    $SQL_getACData->execute(array($uid));
    while($row = $SQL_getACData->fetch()) {
        $Result_FirstName = $row['firstname'];
        $Result_LastName = $row['lastname'];
        $Result_Gender = $row['Gender'];
        $Result_NickName = $row['nickname'];
    }
    
    $Result = array();
    $Result["StatusCode"] = $statuscode["OK"];
    
    $Result["LastName"] = $Result_LastName;
    $Result["NickName"] = $Result_NickName;
    $Result["Gender"] = $Result_Gender;
    $Result["FirstName"] = $Result_FirstName;
    $Result["Email"] = $Result_Email;
} else {
    $Result["StatusCode"] = $statuscode["Error"];
}

$JSON_result = json_encode($Result);
print_r($JSON_result);

?>
