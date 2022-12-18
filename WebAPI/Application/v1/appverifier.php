<?php
include($_SERVER['DOCUMENT_ROOT']."/Secret/MySQL/config.php");

$result = array();
$checkercode = array();
$statuscode = array(
    "OK" => 1000,
    "AppCode_NotMatch" => 9998,
    "Version_NotMatch" => 9999,
);

$Table_ApplicationSetting = table_ApplicationSetting;

// Storing the received JSON into $json variable.
$json = file_get_contents('php://input');
 
// Decode the received JSON and Store into $obj variable.
$obj = json_decode($json,true);

$AppCode=$obj['AppCode'];
$Version=$obj['Version'];
$DeviceSystem=$obj['System'];

$SQL_CheckAppSetting = $conn->prepare("SELECT * FROM $Table_ApplicationSetting");
$SQL_CheckAppSetting->execute();

while($row = $SQL_CheckAppSetting->fetch()) {
    $Server_AppCode = $row['AppCode'];
    $Server_Version = $row['Version'];
    $Server_System = $row['System'];
    if($Server_System != $DeviceSystem){
        continue;
    }

    if($AppCode != $Server_AppCode){
        $checkercode = array();
        array_push($checkercode, $statuscode["AppCode_NotMatch"]);
    }
    
    if($Version != $Server_Version){
        $checkercode = array();
        array_push($checkercode, $statuscode["Version_NotMatch"]);
    }

    if($Version == $Server_Version && $AppCode == $Server_AppCode){
        $checkercode = array();
        array_push($checkercode, $statuscode["OK"]);
    }

    if($Server_System == $DeviceSystem){
        break;
    }
}

$result["Verifier_StatusCode"] = $checkercode;
$JSON_result = json_encode($result);

print_r($JSON_result);

?>