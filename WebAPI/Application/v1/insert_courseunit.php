<?php
header('Content-Type: application/json');
include($_SERVER['DOCUMENT_ROOT']."/Secret/MySQL/config.php");
date_default_timezone_set("Asia/Hong_Kong");

$Result = array();
$statuscode = array(
    "OK" => 1000,
);

$Table_CourseUnits = table_Units;

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
$courseID=$obj['CourseID'];
$coursefolder=$obj['CourseFolder'];
$skip_moduleselection=$obj['Skip_Selection'];
$to_moduleID=$obj['ToModule'];

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
$SQL_Get_CID->execute(array(DB_NAME,$Table_CourseUnits));
$count = $SQL_Get_CID->rowCount();

if($count == 1){
    while($row = $SQL_Get_CID->fetch()) {
        $Last_UnitID = (int)$row['AUTO_INCREMENT'];
    }
}

$foldername = "CUnit".$Last_UnitID . "_" . uniqid();

$SQL_Insert_Unit = $conn->prepare(
    "INSERT INTO $Table_CourseUnits(courseID,Title, Description, Period_Start, Period_End, folderName, creatorID, createdBy,skip_moduleselection,to_moduleID) 
    VALUES(?,?,?,?,?,?,?,?,?,?)"
);
$SQL_Insert_Unit->execute(array($courseID,$title,$desc,$period_Start,$period_End,$foldername, $creatorUID, $creatorUName,$skip_moduleselection,$to_moduleID));


$destination_dir = $_SERVER['DOCUMENT_ROOT']."/"."uploads/". $coursefolder . '/' . $foldername . '/';

if (!file_exists($destination_dir)) {
    mkdir($destination_dir, 0755, true);
}


$Result = array();
$Result["StatusCode"] = $statuscode["OK"];
$Result["CID"] = $courseID;
$Result["Last_UnitID"] = $Last_UnitID;
$JSON_result = json_encode($Result,JSON_PRETTY_PRINT);

print_r($JSON_result);

?>