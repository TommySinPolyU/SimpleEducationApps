<?php
header('Content-Type: application/json');
include($_SERVER['DOCUMENT_ROOT']."/Secret/MySQL/config.php");
date_default_timezone_set("Asia/Hong_Kong");


$Result = array();
$statuscode = array(
    "OK" => 1000,
);

$Table_SubGroup = table_SubGroups;

// Storing the received JSON into $json variable.
$json = file_get_contents('php://input');
 
// Decode the received JSON and Store into $obj variable.
$obj = json_decode($json,true);

$groupName=$obj['GroupName'];
//$groupName=$_GET['GroupName'];

$SQL_Insert_Group = $conn->prepare(
    "INSERT INTO $Table_SubGroup(name) 
    VALUES(?)"
);
$SQL_Insert_Group->execute(array($groupName));

$Result = array();
$Result["StatusCode"] = $statuscode["OK"];
$JSON_result = json_encode($Result,JSON_PRETTY_PRINT);

print_r($JSON_result);

?>