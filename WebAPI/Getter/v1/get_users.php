<?php
header('Content-Type: application/json');
include($_SERVER['DOCUMENT_ROOT']."/Secret/MySQL/config.php");
// Storing the received JSON into $json variable.
$json = file_get_contents('php://input');

// Checking the validation of API Account Token
require_once($_SERVER['DOCUMENT_ROOT']."/Account/v1/check_token.php");

$statuscode = array(
    1000 => "OK",
    1001 => "Record Not Found",
);

$Results = array();

$Table_UserInfo = table_userinfo;
$Table_UserSubGroup = table_UserSubGroups;

// Decode the received JSON and Store into $obj variable.
$obj = json_decode($json,true);
/*
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
*/

$SQL_GetUserData = $conn->prepare("SELECT * FROM $Table_UserInfo");
$SQL_GetUserData->execute();
$count = $SQL_GetUserData->rowCount();
if($count >= 1){
    $Results["Message"] = "Access granted:";
    $Results["RecordsCount"] = $count;
    $Results["StatusCode"] = $statuscode[1000];
    $Results["Results"] = array();
    while($row = $SQL_GetUserData->fetch()) {
        $Result_Single = array();
        $Result_Single["UID"] = $row['UID'];
        $Result_Single["LastName"] = $row['lastname'];
        $Result_Single["FirstName"] = $row['firstname'];
        $Result_Single["NickName"] = $row['nickname'];
        $Result_Single["SubGroups"] = array();
        $SQL_GetUserSubGroups = $conn->prepare("SELECT * FROM $Table_UserSubGroup WHERE UID = ?");
        $SQL_GetUserSubGroups->execute(array($row['UID']));
        while($row_subgroup = $SQL_GetUserSubGroups->fetch()){
            array_push($Result_Single["SubGroups"], $row_subgroup['subgroup']);
        }
        array_push($Results["Results"], $Result_Single);
    }
} else {
    $Results["Results"] = array();
}




$JSON_result = json_encode($Results, JSON_PRETTY_PRINT);
print_r($JSON_result);
?>