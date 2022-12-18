<?php
header('Content-Type: application/json');
include($_SERVER['DOCUMENT_ROOT']."/Secret/MySQL/config.php");
date_default_timezone_set("Asia/Hong_Kong");

$Result = array();
$statuscode = array(
    "OK" => 1000,
);

$Table_Courses = table_Courses;
$Table_CourseAccessible = table_CourseAccessible;

// Storing the received JSON into $json variable.
$json = file_get_contents('php://input');
 
// Decode the received JSON and Store into $obj variable.
$obj = json_decode($json,true);


$creatorUID=$obj['CUID'];
$creatorUName=$obj['CUName'];
$title=$obj['Title'];
$desc=$obj['Description'];
$period_Start=$obj['Period_Start'];
$period_End=$obj['Period_End'];
$allow_groups=$obj['Groups'];

$groups_array = explode(',', $allow_groups);

/*
$title="Testing";
$desc="Test Inserting";
$period_Start=date("Y-m-d h:m:s",time());
$period_End=date("Y-m-d h:m:s",time());
*/

//$currenttime = date("Y-m-d H:i:s");

// Get Last Auto Increment ID.
$SQL_Get_CID = $conn->prepare(
    "SELECT AUTO_INCREMENT FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?"
);
$SQL_Get_CID->execute(array(DB_NAME,$Table_Courses));
$count = $SQL_Get_CID->rowCount();

if($count == 1){
    while($row = $SQL_Get_CID->fetch()) {
        $Last_CID = (int)$row['AUTO_INCREMENT'];
    }
}

$foldername = "C".$Last_CID . "_" . uniqid();

$SQL_Insert_Materials = $conn->prepare(
    "INSERT INTO $Table_Courses(courseName, courseDesc, coursePeriod_Start, coursePeriod_End, courseFolder, creatorID, createdBy) 
    VALUES(?,?,?,?,?,?,?)"
);
$SQL_Insert_Materials->execute(array($title,$desc,$period_Start,$period_End,$foldername, $creatorUID, $creatorUName));


$destination_dir = $_SERVER['DOCUMENT_ROOT']."/"."uploads/" . $foldername . '/';

if (!file_exists($destination_dir)) {
    mkdir($destination_dir, 0755, true);
}

for($i = 0; $i < count($groups_array); $i++){
    $SQL_Insert_GroupAccess = $conn->prepare(
        "INSERT INTO $Table_CourseAccessible(courseID, usergroup) 
        VALUES(?,?)"
    );
    $SQL_Insert_GroupAccess->execute(array($Last_CID, $groups_array[$i]));
}

$Result = array();
$Result["StatusCode"] = $statuscode["OK"];
$Result["Last_CID"] = $Last_CID;
$JSON_result = json_encode($Result,JSON_PRETTY_PRINT);

print_r($JSON_result);

?>