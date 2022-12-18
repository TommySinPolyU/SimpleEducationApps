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

$Table_Survey = table_Survey;
$Table_Survey_Accessable = table_SurveyAccessible;

if(isset($obj['SurveyID'])){
    $SurveyID=$obj['SurveyID'];
    $SQL_Get_Survey = $conn->prepare(
        "SELECT * FROM $Table_Survey WHERE ID = ?"
    );
    $SQL_Get_Survey->execute(array($SurveyID));
    $count = $SQL_Get_Survey->rowCount();
    if($count > 0){
        $SQL_Delete_Survey_Access = $conn->prepare(
            "DELETE FROM $Table_Survey_Accessable WHERE survey_id = ?"
        );
        $SQL_Delete_Survey_Access->execute(array($SurveyID));

        $SQL_Delete_Survey = $conn->prepare(
            "DELETE FROM $Table_Survey WHERE ID = ?"
        );
        $SQL_Delete_Survey->execute(array($SurveyID));

        $Results["StatusCode"] = $statuscode["OK"];
        $Results["SurveyID"] = $SurveyID;
        $Results["Msg"] = "Survey has been Successfully Deleted!";
    } else {
        $Results["StatusCode"] = $statuscode["Error"];
        $Results["SurveyID"] = $SurveyID;
        $Results["Msg"] = "Survey Record Not Found";
    }
} else {
    $Results["StatusCode"] = $statuscode["Error"];
    $Results["Msg"] = "SurveyID Not Found in URL";
}

$JSON_result = json_encode($Results, JSON_PRETTY_PRINT);

print_r($JSON_result);
?>

