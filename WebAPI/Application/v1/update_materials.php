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
$Table_AttachmentChecker = table_AttachmentChecker;

$CourseID=$obj['CourseID'];
$UnitID=$obj['UnitID'];
$MaterialID=$obj['MID'];
$foldername=$obj['MaterialsFolder'];
$unitfolder=$obj['UnitFolder'];
$coursefolder=$obj['CourseFolder'];


// Get Last Auto Increment ID.
$SQL_Get_Material = $conn->prepare(
    "SELECT * FROM $Table_Materials WHERE ID = ? || foldername = ?"
);
$SQL_Get_Material->execute(array($MaterialID,$foldername));
$count = $SQL_Get_Material->rowCount();

if($count == 1){
    $destination_dir = $_SERVER['DOCUMENT_ROOT']."/"."uploads/" . $coursefolder . '/' . $unitfolder . '/' . $foldername . '/';

    //print $destination_dir . PHP_EOL;

    if (!file_exists($destination_dir)) {
        mkdir($destination_dir, 0755, true);
    }
    
    $title=$obj['Title'];
    $desc=$obj['Description'];
    $attachments=$obj['Attachment'];
    $delete_attachments=$obj['Attachment_Delete'];
    $requiredTime=$obj['RequiredTime'];
    $period_Start=$obj['Period_Start'];
    $period_End=$obj['Period_End'];
    
    if(!empty($delete_attachments)){
        $delete_attachments_array = explode(",", $delete_attachments);

        for($i = 0; $i < count($delete_attachments_array); $i++){
            $file_path = $destination_dir . $delete_attachments_array[$i];

            $SQL_Delete_Attachments_Checker = $conn->prepare(
                "DELETE FROM $Table_AttachmentChecker WHERE EXISTS (
                    SELECT 
                    $Table_AttachmentChecker.attID FROM $Table_AttachmentChecker
                INNER JOIN $Table_Attachment ON $Table_Attachment.attID = $Table_AttachmentChecker.attID
                WHERE $Table_Attachment.filename = '?')"
            );
            $SQL_Delete_Attachments_Checker->execute(array($delete_attachments_array[$i]));
            
            $SQL_Delete_Attachments = $conn->prepare(
                "DELETE FROM $Table_Attachment WHERE courseID = ? AND unitID = ? AND matID = ? AND filename = ?"
            );
            $SQL_Delete_Attachments->execute(array($CourseID, $UnitID, $MaterialID, $delete_attachments_array[$i]));
    
            //print $file_path.PHP_EOL;
            if (file_exists($file_path)) {
                unlink($file_path);
            }
        }
    }

    date_default_timezone_set("Asia/Hong_Kong");
    $currenttime = date("Y-m-d H:i:s");



    $SQL_Update_Materials = $conn->prepare(
        "UPDATE $Table_Materials SET Title = ?, Description = ?, Attachment = ?, Period_Start = ?, Period_End = ? WHERE ID = ? OR foldername = ?"
    );
    $SQL_Update_Materials->execute(array($title, $desc, $attachments, $period_Start, $period_End, $MaterialID, $foldername));

    if(!empty($attachments)){
        $atts = explode(",", $attachments);

        for($x = 0; $x < count($atts); $x++){
            $SQL_GetAttachment = $conn->prepare("SELECT * FROM $Table_Attachment WHERE courseID = ? AND unitID = ? AND matID = ? AND filename = ?");
            $SQL_GetAttachment->execute(array($CourseID, $UnitID, $MaterialID, $atts[$x]));
            $count_att = $SQL_GetAttachment->rowCount();
            
            if($count_att == 0){
                $SQL_Insert_Attachment = $conn->prepare(
                    "INSERT INTO $Table_Attachment(courseID, unitID, matID, foldername, filename) 
                    VALUES(?,?,?,?,?)"
                );
                $SQL_Insert_Attachment->execute(array($CourseID, $UnitID, $MaterialID, $foldername, $atts[$x]));
            }
        }
    }

    $Result = array();
    $Result["StatusCode"] = $statuscode["OK"];
    $Result["dest"] = $destination_dir;
    $Result["Message"] = "Records has been updated.";
}


$JSON_result = json_encode($Result,JSON_PRETTY_PRINT);

print_r($JSON_result);

?>