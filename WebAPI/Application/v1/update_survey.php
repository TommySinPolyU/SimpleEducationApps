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

$Table_Survey = table_Survey;
$Table_Survey_Accessable = table_SurveyAccessible;

$SurveyID=$obj['SurveyID'];

$SQL_Get_Survey = $conn->prepare(
    "SELECT * FROM $Table_Survey WHERE ID = ?"
);
$SQL_Get_Survey->execute(array($SurveyID));
$count = $SQL_Get_Survey->rowCount();

if($count == 1){

    $surveyName=$obj['Title'];
    $surveyDesc=$obj['Description'];
    $surveyLink=$obj['Link'];
    $surveyPeriod_Start=$obj['Period_Start'];
    $surveyPeriod_End=$obj['Period_End'];

    $allow_groups=$obj['Groups'];
    $groups_array = explode(',', $allow_groups);

    date_default_timezone_set("Asia/Hong_Kong");

    $SQL_Update_Survey = $conn->prepare(
        "UPDATE $Table_Survey SET Title = ?, Description = ?, Link = ?, Period_Start = ?, Period_End = ? WHERE ID  = ?"
    );
    $SQL_Update_Survey->execute(array($surveyName, $surveyDesc, $surveyLink, $surveyPeriod_Start, $surveyPeriod_End, $SurveyID));

    $SQL_Delete_SurveyAccessible = $conn->prepare(
        "DELETE FROM $Table_Survey_Accessable WHERE survey_id = ?"
    );
    $SQL_Delete_SurveyAccessible->execute(array($SurveyID));

    for($i = 0; $i < count($groups_array); $i++){
        $SQL_Insert_GroupAccess = $conn->prepare(
            "INSERT INTO $Table_Survey_Accessable(survey_id, usergroup) 
            VALUES(?,?)"
        );
        $SQL_Insert_GroupAccess->execute(array($SurveyID, $groups_array[$i]));
    }

    $Result = array();
    $Result["StatusCode"] = $statuscode["OK"];
    $Result["Message"] = "Records has been updated.";
}


$JSON_result = json_encode($Result,JSON_PRETTY_PRINT);

print_r($JSON_result);

?>