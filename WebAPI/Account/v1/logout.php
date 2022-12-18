<?php
// Storing the received JSON into $json variable.
$json = file_get_contents('php://input');
if($json == null){
    exit;
}

include($_SERVER['DOCUMENT_ROOT']."/Secret/MySQL/config.php");

$result = array();
$statuscode = array(
    "OK" => 1000,
);

$Table_ac = table_ac;
$Table_userloginrecord = table_userloginrecord;

// Decode the received JSON and Store into $obj variable.
$obj = json_decode($json,true);

$uid=$obj['UID'];

$currenttime = date("Y-m-d H:i:s");

$SQL_Login_Records = $conn->prepare("SELECT * FROM $Table_userloginrecord WHERE UID = ?");
$SQL_Login_Records->execute(array($uid));

while($row = $SQL_Login_Records->fetch()) {
    $previoustime = $row['LoginDateTime'];
    $diff = round(abs(strtotime($currenttime) - strtotime($previoustime)) / 60,2);
    $SQL_Login_UpdateRecord = $conn->prepare("UPDATE $Table_userloginrecord SET LogoutDateTime = ?, RunTimes = ? WHERE UID = ? AND LoginDateTime = ? AND LogoutDateTime IS NULL");
    $SQL_Login_UpdateRecord->execute(array($currenttime, $diff, $uid, $previoustime));
}

$checkercode = array();
array_push($checkercode, $statuscode["OK"]);

$result["StatusCode"] = $checkercode;
$JSON_result = json_encode($result);
print_r($JSON_result);

?>