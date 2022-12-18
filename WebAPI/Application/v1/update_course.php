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

$Table_Courses = table_Courses;
$Table_CourseAccessible = table_CourseAccessible;

$CourseID=$obj['CID'];

// Get Last Auto Increment ID.
$SQL_Get_Course = $conn->prepare(
    "SELECT * FROM $Table_Courses WHERE courseID  = ?"
);
$SQL_Get_Course->execute(array($CourseID));
$count = $SQL_Get_Course->rowCount();

if($count == 1){

    $courseName=$obj['courseName'];
    $courseDesc=$obj['courseDesc'];
    $coursePeriod_Start=$obj['coursePeriod_Start'];
    $coursePeriod_End=$obj['coursePeriod_End'];
    $allow_groups=$obj['Groups'];

    $groups_array = explode(',', $allow_groups);

    date_default_timezone_set("Asia/Hong_Kong");

    $SQL_Update_Course = $conn->prepare(
        "UPDATE $Table_Courses SET courseName = ?, courseDesc = ?, coursePeriod_Start = ?, coursePeriod_End = ? WHERE courseID  = ?"
    );
    $SQL_Update_Course->execute(array($courseName, $courseDesc, $coursePeriod_Start, $coursePeriod_End, $CourseID));

    $SQL_Delete_CourseAccessible = $conn->prepare(
        "DELETE FROM $Table_CourseAccessible WHERE courseID = ?"
    );
    $SQL_Delete_CourseAccessible->execute(array($CourseID));

    for($i = 0; $i < count($groups_array); $i++){
        $SQL_Insert_GroupAccess = $conn->prepare(
            "INSERT INTO $Table_CourseAccessible(courseID, usergroup) 
            VALUES(?,?)"
        );
        $SQL_Insert_GroupAccess->execute(array($CourseID, $groups_array[$i]));
    }

    $Result = array();
    $Result["StatusCode"] = $statuscode["OK"];
    $Result["Message"] = "Records has been updated.";
}


$JSON_result = json_encode($Result,JSON_PRETTY_PRINT);

print_r($JSON_result);

?>