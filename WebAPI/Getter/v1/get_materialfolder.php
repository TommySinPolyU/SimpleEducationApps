<?php
include($_SERVER['DOCUMENT_ROOT']."/Secret/MySQL/config.php");

$Result = array();
$statuscode = array(
    "OK" => 1000,
    "AUTO_INCREMENT NOT FOUND" => 1001,
);

// Storing the received JSON into $json variable.
$json = file_get_contents('php://input');
 
// Decode the received JSON and Store into $obj variable.
$obj = json_decode($json,true);

$Table_Materials = table_Materials;

// Get Last Auto Increment ID.
$SQL_Get_MID = $conn->prepare(
    "SELECT AUTO_INCREMENT FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?"
);
$SQL_Get_MID->execute(array(DB_NAME,$Table_Materials));
$count = $SQL_Get_MID->rowCount();

if($count == 1){
    while($row = $SQL_Get_MID->fetch()) {
        $Last_MID = (int)$row['AUTO_INCREMENT'];
    }
    $title=$obj['Title'];
    $foldername= "M".$Last_MID . "_" . uniqid();
    $coursefolder=$obj['CourseFolder'];
    $unitfolder=$obj['UnitFolder'];

    $destination_dir = $_SERVER['DOCUMENT_ROOT']."/"."uploads/" . $coursefolder . '/' . $unitfolder . '/' . $foldername . '/';

    if (!file_exists($destination_dir)) {
        mkdir($destination_dir, 0755, true);
    }

    $Result = array();
    $Result["StatusCode"] = $statuscode["OK"];
    $Result["FolderName"] = $foldername;
    $Result["Last_MID"] = $Last_MID;
    $Result["Destination"] = $destination_dir;

} else {
    $Result = array();
    $Result["StatusCode"] = $statuscode["AUTO_INCREMENT NOT FOUND"];
    $Result["Message"] = "AUTO_INCREMENT NOT FOUND, Please Check the code or DB Setting again";
}


$JSON_result = json_encode($Result,JSON_PRETTY_PRINT);

print_r($JSON_result);

?>