<?php
header('Content-Type: application/json');
include($_SERVER['DOCUMENT_ROOT']."/Secret/MySQL/config.php");
date_default_timezone_set("Asia/Hong_Kong");

$Result = array();
$statuscode = array(
    "OK" => 1000,
);

$Table_Survey = table_Survey;
$Table_Survey_Accessable = table_SurveyAccessible;

// Storing the received JSON into $json variable.
$json = file_get_contents('php://input');
 
// Decode the received JSON and Store into $obj variable.
$obj = json_decode($json,true);


$creatorUID=$obj['CUID'];
$creatorUName=$obj['CUName'];
$title=$obj['Title'];
$desc=$obj['Description'];
$link=$obj['Link'];
$period_Start=$obj['Period_Start'];
$period_End=$obj['Period_End'];

$allow_groups=$obj['Groups'];
$groups_array = explode(',', $allow_groups);

// Get Last Auto Increment ID.
$SQL_Get_SID = $conn->prepare(
    "SELECT AUTO_INCREMENT FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?"
);
$SQL_Get_SID->execute(array(DB_NAME,$Table_Survey));
$count = $SQL_Get_SID->rowCount();

if($count == 1){
    while($row = $SQL_Get_SID->fetch()) {
        $Last_SID = (int)$row['AUTO_INCREMENT'];
    }
}


/*
$title="Testing";
$desc="Test Inserting";
$period_Start=date("Y-m-d h:m:s",time());
$period_End=date("Y-m-d h:m:s",time());
*/

//$currenttime = date("Y-m-d H:i:s");

$SQL_Insert_Survey = $conn->prepare(
    "INSERT INTO $Table_Survey(Title, Description, Link, Period_Start, Period_End, creatorID, createdBy) 
    VALUES(?,?,?,?,?,?,?)"
);
$SQL_Insert_Survey->execute(array($title,$desc,$link,$period_Start,$period_End, $creatorUID, $creatorUName));

for($i = 0; $i < count($groups_array); $i++){
    $SQL_Insert_GroupAccess = $conn->prepare(
        "INSERT INTO $Table_Survey_Accessable(survey_id, usergroup) 
        VALUES(?,?)"
    );
    $SQL_Insert_GroupAccess->execute(array($Last_SID, $groups_array[$i]));
}

$Result = array();
$Result["StatusCode"] = $statuscode["OK"];
$JSON_result = json_encode($Result,JSON_PRETTY_PRINT);

print_r($JSON_result);

?>