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

$Table_Materials = table_Materials;
$Table_Attachment = table_Attachment;

$creatorUID=$obj['CUID'];
$creatorUName=$obj['CUName'];
$title=$obj['Title'];
$foldername=$obj['foldername'];
$unitfolder=$obj['UnitFolder'];
$coursefolder=$obj['CourseFolder'];

$destination_dir = $_SERVER['DOCUMENT_ROOT']."/"."uploads/" . $coursefolder . '/' . $unitfolder . '/' . $foldername . '/';

if (!file_exists($destination_dir)) {
    mkdir($destination_dir, 0755, true);
}

$unitID=$obj['UnitID'];
$courseID=$obj['CourseID'];
$title=$obj['Title'];
$desc=$obj['Description'];
$attachments=$obj['Attachment'];
$requiredTime=$obj['RequiredTime'];
$period_Start=$obj['Period_Start'];
$period_End=$obj['Period_End'];

date_default_timezone_set("Asia/Hong_Kong");
$currenttime = date("Y-m-d H:i:s");

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

    $SQL_Insert_Materials = $conn->prepare(
        "INSERT INTO $Table_Materials(courseID, unitID, foldername, Title, Description, Attachment, Required_Time, Period_Start, Period_End, creatorID, createdBy) 
        VALUES(?,?,?,?,?,?,?,?,?,?,?)"
    );
    $SQL_Insert_Materials->execute(array($courseID,$unitID,$foldername,$title,$desc,$attachments,$requiredTime,$period_Start,$period_End, $creatorUID, $creatorUName));
    
    $atts = explode(",", $attachments);

    for($x = 0; $x < count($atts); $x++){
        if($atts[$x] != "" || !empty($atts[$x])){
            $SQL_Insert_Attachment = $conn->prepare(
                "INSERT INTO $Table_Attachment(courseID, unitID, matID, foldername, filename) 
                VALUES(?,?,?,?,?)"
            );
            $SQL_Insert_Attachment->execute(array($courseID, $unitID, $Last_MID, $foldername, $atts[$x]));
        }
    }
  
    $Result = array();
    $Result["StatusCode"] = $statuscode["OK"];
    $Result["Folder"] = $foldername;
    $Result["Message"] = "Records has been inserted into DB.";
}

$JSON_result = json_encode($Result,JSON_PRETTY_PRINT);

print_r($JSON_result);

?>