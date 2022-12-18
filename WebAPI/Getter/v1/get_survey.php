<?php
header('Content-Type: application/json');
include($_SERVER['DOCUMENT_ROOT']."/Secret/MySQL/config.php");
$Results = array();

// Checking the validation of API Account Token
require_once($_SERVER['DOCUMENT_ROOT']."/Account/v1/check_token.php");

$Table_Survey = table_Survey;
$Table_Survey_Accessable = table_SurveyAccessible;
$Table_UserSubGroup = table_UserSubGroups;

$statuscode = array(
    1000 => "OK",
    1001 => "Record Not Found",
);

$SQL_Get_LastSurveyID = $conn->prepare(
    "SELECT AUTO_INCREMENT FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?"
);
$SQL_Get_LastSurveyID->execute(array(DB_NAME,$Table_Survey));

while($row = $SQL_Get_LastSurveyID->fetch()) {
    $Last_ID = (int)$row['AUTO_INCREMENT'];
}

$currenttime = date("Y-m-d H:i:s");
$timestamp = strtotime($currenttime);

if(!isset($_GET['isExpired'])){
    $_GET['isExpired'] = false;
}
if(!isset($_GET['isComingSoon'])){
    $_GET['isComingSoon'] = false;
}
if(!isset($_GET['isOpening'])){
    $_GET['isOpening'] = false;
}

if(isset($_GET['isAdmin'])){
    if($_GET['isAdmin'] == 'false')
        $_GET['isAdmin']= false;
    else
        $_GET['isAdmin'] = true;
} else {
    $_GET['isAdmin'] = false;
}

if($_GET['isAdmin'] == true || !isset($_GET['UID'])){
    if($_GET['isExpired']==true){
        $SQL_GetSurveyData = $conn->prepare("SELECT * FROM $Table_Survey WHERE CONVERT_TZ(CURRENT_TIMESTAMP, '+00:00', '+08:00') > Period_End OR CURRENT_TIMESTAMP > Period_End");
    } else if($_GET['isComingSoon']==true){
        $SQL_GetSurveyData = $conn->prepare("SELECT * FROM $Table_Survey WHERE Period_Start > CONVERT_TZ(CURRENT_TIMESTAMP, '+00:00', '+08:00') OR Period_Start > CURRENT_TIMESTAMP");
    } else if($_GET['isOpening']){
        $SQL_GetSurveyData = $conn->prepare("SELECT * FROM $Table_Survey WHERE NOT(CONVERT_TZ(CURRENT_TIMESTAMP, '+00:00', '+08:00') > Period_End OR CURRENT_TIMESTAMP > Period_End AND 
        Period_Start > CONVERT_TZ(CURRENT_TIMESTAMP, '+00:00', '+08:00') OR Period_Start > CURRENT_TIMESTAMP)");
    } else {
        $SQL_GetSurveyData = $conn->prepare("SELECT * FROM $Table_Survey");
    }
} else {
    //$user_group = $_GET['UserGroup'];
    $subgroup_array = array();
    $SQL_GetUserSubgroup = $conn->prepare("
        SELECT * 
        FROM $Table_UserSubGroup
        WHERE UID = ?
    ");
    $SQL_GetUserSubgroup->execute(array($_GET['UID']));
    while($row_subgroup = $SQL_GetUserSubgroup->fetch()){
        array_push($subgroup_array, $row_subgroup['subgroup']);
    }

    $subgroup_array_string = "'" .implode("','", $subgroup_array  ) . "'"; 

    if($_GET['isExpired']==true){
        $SQL_GetSurveyData = $conn->prepare("
        SELECT DISTINCT $Table_Survey.*
        FROM $Table_Survey 
        INNER JOIN $Table_Survey_Accessable ON $Table_Survey_Accessable.survey_id = $Table_Survey.ID
        WHERE CONVERT_TZ(CURRENT_TIMESTAMP, '+00:00', '+08:00') > Period_End AND $Table_Survey_Accessable.usergroup IN ($subgroup_array_string)
        GROUP BY $Table_Survey.ID");
    } else if($_GET['isComingSoon']==true){
        $SQL_GetSurveyData = $conn->prepare("
        SELECT DISTINCT $Table_Survey.*
        FROM $Table_Survey
        INNER JOIN $Table_Survey_Accessable ON $Table_Survey_Accessable.survey_id = $Table_Survey.ID 
        WHERE Period_Start > CONVERT_TZ(CURRENT_TIMESTAMP, '+00:00', '+08:00') AND $Table_Survey_Accessable.usergroup IN ($subgroup_array_string)
        GROUP BY $Table_Survey.ID");
    } else if($_GET['isOpening']){
        $SQL_GetSurveyData = $conn->prepare("
        SELECT DISTINCT $Table_Survey.*
        FROM $Table_Survey 
        INNER JOIN $Table_Survey_Accessable ON $Table_Survey_Accessable.survey_id = $Table_Survey.ID
        WHERE (CONVERT_TZ(CURRENT_TIMESTAMP, '+00:00', '+08:00')) BETWEEN Period_Start AND Period_End AND $Table_Survey_Accessable.usergroup IN ($subgroup_array_string)
        GROUP BY $Table_Survey.ID");
    } else {
        $SQL_GetSurveyData = $conn->prepare("
        SELECT DISTINCT $Table_Survey.*
        FROM $Table_Survey
        INNER JOIN $Table_Survey_Accessable ON $Table_Survey_Accessable.survey_id = $Table_Survey.ID
        WHERE $Table_Survey_Accessable.usergroup IN ($subgroup_array_string)
        GROUP BY $Table_Survey.ID
        ");
    }
}



$SQL_GetSurveyData->execute();
$count = $SQL_GetSurveyData->rowCount();

if($count >= 1){
    $Results = array();
    $Results["RecordsCount"] = $count;
    $Results["StatusCode"] = $statuscode[1000];
    $Results["Results"] = array();
    while($row = $SQL_GetSurveyData->fetch()) {
        $Result_Single = array();
        $Result_Single["SurveyID"] = $row['ID'];
        $Result_Single["SurveyTitle"] = $row['Title'];
        $Result_Single["SurveyDesc"] = $row['Description'];
        $Result_Single["SurveyPeriod_Start"] = $row['Period_Start'];
        $Result_Single["SurveyPeriod_End"] = $row['Period_End'];
        $Result_Single["SurveyLink"] = $row['Link'];

        $Result_Single["Result_SurveyAccessible"] = array();
        $SQL_GetSurveyAccessible = $conn->prepare("
        SELECT *
        FROM $Table_Survey_Accessable 
        WHERE survey_id = ?");
        $SQL_GetSurveyAccessible->execute(array($row['ID']));
        while($group_row = $SQL_GetSurveyAccessible->fetch()) {
            array_push($Result_Single["Result_SurveyAccessible"], $group_row['usergroup']);
        }

        array_push($Results["Results"], $Result_Single);
    }
} else {
    $Results["Results"] = array();
}


if(isset($_GET['SurveyID'])){
    if($_GET['SurveyID'] > 0 && $_GET['SurveyID'] <= $Last_ID){
        $JSON_result = json_encode(
            $Results["Results"][array_search($_GET['SurveyID'], array_column($Results["Results"], 'SurveyID'))], 
            JSON_PRETTY_PRINT);
    } else {
        $Results = array();
        $Results["SurveyID"] = $_GET['SurveyID'];
        $Results["StatusCode"] = $statuscode[1001];
        $JSON_result = json_encode($Results, JSON_PRETTY_PRINT);
    }
} else {
    $JSON_result = json_encode($Results, JSON_PRETTY_PRINT);
}


print_r($JSON_result);
?>