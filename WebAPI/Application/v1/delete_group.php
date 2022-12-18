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

$Table_CourseAccessible = table_CourseAccessible;
$Table_Survey_Accessable = table_SurveyAccessible;
$Table_SubGroup = table_SubGroups;
$Table_UserSubGroup = table_UserSubGroups;


if(isset($obj['GroupID'])){
    $GroupID=$obj['GroupID'];
    $SQL_Get_Group = $conn->prepare(
        "SELECT * FROM $Table_SubGroup WHERE subgroupID = ?"
    );
    $SQL_Get_Group->execute(array($GroupID));
    $count = $SQL_Get_Group->rowCount();
    if($count > 0){
        while($row = $SQL_Get_Group->fetch()){
            $subgroup_name = $row['name'];
        }

        $SQL_Delete_Survey_Access = $conn->prepare(
            "DELETE FROM $Table_Survey_Accessable WHERE usergroup = ?"
        );
        $SQL_Delete_Survey_Access->execute(array($subgroup_name));

        $SQL_Delete_GroupCourseAccessible = $conn->prepare(
            "DELETE FROM $Table_CourseAccessible WHERE usergroup = ?"
        );
        $SQL_Delete_GroupCourseAccessible->execute(array($subgroup_name));

        $SQL_Delete_GroupMembers = $conn->prepare(
            "DELETE FROM $Table_UserSubGroup WHERE subgroup = ?"
        );
        $SQL_Delete_GroupMembers->execute(array($subgroup_name));

        $SQL_Delete_Group = $conn->prepare(
            "DELETE FROM $Table_SubGroup WHERE subgroupID = ?"
        );
        $SQL_Delete_Group->execute(array($GroupID));

        $Results["StatusCode"] = $statuscode["OK"];
        $Results["GroupID"] = $GroupID;
        $Results["Msg"] = "Group has been Successfully Deleted!";
    } else {
        $Results["StatusCode"] = $statuscode["Error"];
        $Results["GroupID"] = $GroupID;
        $Results["Msg"] = "Group Record Not Found";
    }
} else {
    $Results["StatusCode"] = $statuscode["Error"];
    $Results["Msg"] = "GroupID Not Found in URL";
}

$JSON_result = json_encode($Results, JSON_PRETTY_PRINT);

print_r($JSON_result);
?>

