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
$Table_Unit_Progress = table_Unit_Progress;
$Table_Module_Progress = table_Module_Progress;
$Table_Attachment = table_Attachment;
$Table_AttachmentChecker = table_AttachmentChecker;

if(isset($obj['UnitID'])){
    $unitID=$obj['UnitID'];
    if(isset($unitID)){
        $SQL_Get_CourseUnit = $conn->prepare(
            "SELECT * FROM $Table_CourseUnits WHERE unitID = ?"
        );
        $SQL_Get_CourseUnit->execute(array($unitID));
        $unit_count = $SQL_Get_CourseUnit->rowCount();
        
        if($unit_count > 0){
            while($row = $SQL_Get_CourseUnit->fetch()) {
                $unitFolder = $row['folderName'];
                $courseID = $row['courseID'];
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
                $dir_absolute = $_SERVER['DOCUMENT_ROOT']."/"."uploads/" . $courseFolder . '/' . $unitFolder;
                if(removeDir($dir_absolute)){
                    $SQL_Delete_AttachmentsCheck = $conn->prepare(
                        "DELETE FROM $Table_AttachmentChecker WHERE unitID = ?"
                    );
                    $SQL_Delete_AttachmentsCheck->execute(array($unitID));

                    $SQL_Delete_Attachments = $conn->prepare(
                        "DELETE FROM $Table_Attachment WHERE unitID = ?"
                    );
                    $SQL_Delete_Attachments->execute(array($unitID));

                    $SQL_Delete_MatProgress = $conn->prepare(
                        "DELETE FROM $Table_Module_Progress WHERE unitID = ?"
                    );
                    $SQL_Delete_MatProgress->execute(array($unitID));
                    
                    $SQL_Set_CourseUnitRedirectToNull = $conn->prepare(
                        "UPDATE $Table_CourseUnits SET to_moduleID = ? WHERE courseID = ?"
                    );
                    $SQL_Set_CourseUnitRedirectToNull->execute(array(NULL,$courseID));

                    $SQL_Delete_Material = $conn->prepare(
                        "DELETE FROM $Table_Materials WHERE unitID = ?"
                    );
                    $SQL_Delete_Material->execute(array($unitID));

                    $SQL_Delete_UnitProgress = $conn->prepare(
                        "DELETE FROM $Table_Unit_Progress WHERE unitID = ?"
                    );
                    $SQL_Delete_UnitProgress->execute(array($unitID));
            
                    $SQL_Delete_CourseUnit = $conn->prepare(
                        "DELETE FROM $Table_CourseUnits WHERE unitID = ?"
                    );
                    $SQL_Delete_CourseUnit->execute(array($unitID));

                    $Results["StatusCode"] = $statuscode["OK"];
                    $Results["CID"] = $courseID;
                    $Results["Msg"] = "Course Unit has been Successfully Deleted!";
                } else {
                    $SQL_Delete_AttachmentsCheck = $conn->prepare(
                        "DELETE FROM $Table_AttachmentChecker WHERE unitID = ?"
                    );
                    $SQL_Delete_AttachmentsCheck->execute(array($unitID));

                    $SQL_Delete_Attachments = $conn->prepare(
                        "DELETE FROM $Table_Attachment WHERE unitID = ?"
                    );
                    $SQL_Delete_Attachments->execute(array($unitID));

                    $SQL_Delete_MatProgress = $conn->prepare(
                        "DELETE FROM $Table_Module_Progress WHERE unitID = ?"
                    );
                    $SQL_Delete_MatProgress->execute(array($unitID));
                    
                    $SQL_Set_CourseUnitRedirectToNull = $conn->prepare(
                        "UPDATE $Table_CourseUnits SET to_moduleID = ? WHERE courseID = ?"
                    );
                    $SQL_Set_CourseUnitRedirectToNull->execute(array(NULL,$courseID));

                    $SQL_Delete_Material = $conn->prepare(
                        "DELETE FROM $Table_Materials WHERE unitID = ?"
                    );
                    $SQL_Delete_Material->execute(array($unitID));

                    $SQL_Delete_UnitProgress = $conn->prepare(
                        "DELETE FROM $Table_Unit_Progress WHERE unitID = ?"
                    );
                    $SQL_Delete_UnitProgress->execute(array($unitID));
            
                    $SQL_Delete_CourseUnit = $conn->prepare(
                        "DELETE FROM $Table_CourseUnits WHERE unitID = ?"
                    );
                    $SQL_Delete_CourseUnit->execute(array($unitID));
    
                    $Results["StatusCode"] = $statuscode["OK"];
                    $Results["CID"] = $courseID;
                    $Results["Msg"] = "Fail to Delete Record, Folder Not Found!";
                }
            } else {
                $Results["StatusCode"] = $statuscode["Error"];
                $Results["CID"] = $courseID;
                $Results["UnitID"] = $unitID;
                $Results["Msg"] = "Record Not Found";
            }

        } else {
            $Results["StatusCode"] = $statuscode["Error"];
            $Results["UnitID"] = $unitID;
            $Results["Msg"] = "Record Not Found";
        }
    } else {
        $Results["StatusCode"] = $statuscode["Error"];
        $Results["UnitID"] = $unitID;
        $Results["Msg"] = "UnitID Not Found";
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

