<?php
header('Content-Type: application/json');
include($_SERVER['DOCUMENT_ROOT']."/Secret/MySQL/config.php");

$Results = array();
$statuscode = array(
    "OK" => 1000,
    "Error" => 1001,
);

// Storing the received JSON into $json variable.
$json = file_get_contents('php://input');
 
// Decode the received JSON and Store into $obj variable.
$obj = json_decode($json,true);

$Table_Courses = table_Courses;
$Table_CourseUnits = table_Units;
$Table_Materials = table_Materials;
$Table_Module_Progress = table_Module_Progress;
$Table_Attachment = table_Attachment;
$Table_AttachmentChecker = table_AttachmentChecker;

if(isset($obj['MID'])){
    $materialID=$obj['MID'];

    if(isset($materialID)){
        $SQL_Get_Material = $conn->prepare(
            "SELECT * FROM $Table_Materials WHERE ID = ?"
        );
        $SQL_Get_Material->execute(array($materialID));
        $material_count = $SQL_Get_Material->rowCount();
        
        if($material_count > 0){
    
            while($row = $SQL_Get_Material->fetch()) {
                $unitID = $row['unitID'];
                $courseID = $row['courseID'];
                $materialFolder = $row['foldername'];
            }

            $SQL_Get_CourseUnit = $conn->prepare(
                "SELECT * FROM $Table_CourseUnits WHERE unitID = ?"
            );
            $SQL_Get_CourseUnit->execute(array($unitID));
            $courseunit_count = $SQL_Get_CourseUnit->rowCount();

            if($courseunit_count > 0){
                while($row = $SQL_Get_CourseUnit->fetch()) {
                    $unitFolder = $row['folderName'];
                }
                $SQL_Get_Course = $conn->prepare(
                    "SELECT * FROM $Table_Courses WHERE courseID = ?"
                );
                $SQL_Get_Course->execute(array($courseID));
                $course_count = $SQL_Get_Course->rowCount();
        
                if($course_count > 0){
                    while($row = $SQL_Get_Course->fetch()) {
                        $courseFolder = $row['courseFolder'];
                    }
        
                    $dir_absolute = $_SERVER['DOCUMENT_ROOT']."/"."uploads/" . $courseFolder . "/" . $unitFolder . "/" . $materialFolder;
                    if(removeDir($dir_absolute)){
                        $SQL_Delete_AttachmentsCheck = $conn->prepare(
                            "DELETE FROM $Table_AttachmentChecker WHERE matID = ?"
                        );
                        $SQL_Delete_AttachmentsCheck->execute(array($materialID));

                        $SQL_Delete_Attachments = $conn->prepare(
                            "DELETE FROM $Table_Attachment WHERE matID = ?"
                        );
                        $SQL_Delete_Attachments->execute(array($materialID));

                        $SQL_Delete_MatProgress = $conn->prepare(
                            "DELETE FROM $Table_Module_Progress WHERE matID = ?"
                        );
                        $SQL_Delete_MatProgress->execute(array($materialID));

                        $SQL_Delete_Material = $conn->prepare(
                            "DELETE FROM $Table_Materials WHERE ID = ?"
                        );
                        $SQL_Delete_Material->execute(array($materialID));
        
                        $Results["StatusCode"] = $statuscode["OK"];
                        $Results["CID"] = $courseID;
                        $Results["MID"] = $materialID;
                        $Results["Msg"] = "Material has been Successfully Deleted!";
                    } else {
                        $SQL_Delete_AttachmentsCheck = $conn->prepare(
                            "DELETE FROM $Table_AttachmentChecker WHERE matID = ?"
                        );
                        $SQL_Delete_AttachmentsCheck->execute(array($materialID));

                        $SQL_Delete_Attachments = $conn->prepare(
                            "DELETE FROM $Table_Attachment WHERE matID = ?"
                        );
                        $SQL_Delete_Attachments->execute(array($materialID));

                        $SQL_Delete_MatProgress = $conn->prepare(
                            "DELETE FROM $Table_Module_Progress WHERE matID = ?"
                        );
                        $SQL_Delete_MatProgress->execute(array($materialID));

                        $SQL_Delete_Material = $conn->prepare(
                            "DELETE FROM $Table_Materials WHERE ID = ?"
                        );
                        $SQL_Delete_Material->execute(array($materialID));
    
                        $Results["StatusCode"] = $statuscode["OK"];
                        $Results["CID"] = $courseID;
                        $Results["MID"] = $materialID;
                        $Results["Msg"] = "Fail to Delete Folder, Material Folder Not Found!";
                    }
                } else {
                    $Results["StatusCode"] = $statuscode["Error"];
                    $Results["CID"] = $courseID;
                    $Results["MID"] = $materialID;
                    $Results["Msg"] = "Fail to Delete Folder, Course Folder Not Found!";
                }
            } else {
                $Results["StatusCode"] = $statuscode["Error"];
                $Results["CID"] = $courseID;
                $Results["MID"] = $materialID;
                $Results["Msg"] = "Fail to Delete Folder, Course Unit Folder Not Found!";
            }
    

        } else {
            $Results["StatusCode"] = $statuscode["Error"];
            $Results["MID"] = $materialID;
            $Results["Msg"] = "Material Record Not Found";
        }
    } else {
        $Results["StatusCode"] = $statuscode["Error"];
        $Results["MID"] = $materialID;
        $Results["Msg"] = "MID Not Found";
    }
} else {
    $Results["StatusCode"] = $statuscode["Error"];
    $Results["Msg"] = "Not Found";
}


$JSON_result = json_encode($Results, JSON_PRETTY_PRINT);

print_r($JSON_result);

function removeDir($dir) {
    if (is_dir($dir)) {
        $objects = scandir($dir);
        foreach ($objects as $object) {
            if ($object != "." && $object != "..") {
                if (filetype($dir."/".$object) == "dir") 
                    removeDir($dir."/".$object); 
                else unlink   ($dir."/".$object);
            }
        }
        reset($objects);
        rmdir($dir);
        return true;
    }
    return false;
}
?>

