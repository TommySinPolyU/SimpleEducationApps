<?php
include($_SERVER['DOCUMENT_ROOT']."/Secret/MySQL/config.php");

$Result = array();
$statuscode = array(
    "OK" => 1000,
);

// Storing the received JSON into $json variable.
$json = file_get_contents('php://input');
 
// Decode the received JSON and Store into $obj variable.
$obj = json_decode($json,true);

$Table_CourseUnits = table_Units;

$UnitID=$obj['UnitID'];

// Get Last Auto Increment ID.
$SQL_Get_CourseUnit = $conn->prepare(
    "SELECT * FROM $Table_CourseUnits WHERE unitID  = ?"
);
$SQL_Get_CourseUnit->execute(array($UnitID));
$count = $SQL_Get_CourseUnit->rowCount();

if($count == 1){

    $unitName=$obj['Title'];
    $unitDesc=$obj['Description'];
    $unitPeriod_Start=$obj['Period_Start'];
    $unitPeriod_End=$obj['Period_End'];
    $skip_moduleselection=$obj['Skip_Selection'];
    $to_moduleID=$obj['ToModule'];

    date_default_timezone_set("Asia/Hong_Kong");

    $SQL_Update_CourseUnit = $conn->prepare(
        "UPDATE $Table_CourseUnits SET Title = ?, Description = ?, Period_Start = ?, Period_End = ?, skip_moduleselection = ?, to_moduleID = ? WHERE unitID  = ?"
    );
    $SQL_Update_CourseUnit->execute(array($unitName, $unitDesc, $unitPeriod_Start, $unitPeriod_End, $skip_moduleselection, $to_moduleID, $UnitID));

    $Result = array();
    $Result["StatusCode"] = $statuscode["OK"];
    $Result["Message"] = "Records has been updated.";
}


$JSON_result = json_encode($Result,JSON_PRETTY_PRINT);

print_r($JSON_result);

?>