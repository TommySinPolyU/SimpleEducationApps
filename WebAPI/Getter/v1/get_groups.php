<?php
header('Content-Type: application/json');
include($_SERVER['DOCUMENT_ROOT']."/Secret/MySQL/config.php");

// Checking the validation of API Account Token
require_once($_SERVER['DOCUMENT_ROOT']."/Account/v1/check_token.php");

$Results = array();

$Table_UserInfo = table_userinfo;
$Table_SubGroup = table_SubGroups;
$Table_UserSubGroup = table_UserSubGroups;

$statuscode = array(
    1000 => "OK",
    1001 => "Record Not Found",
);

/*
$except_admin = $_GET['containAdmin'];

if($except_admin == 0){
    $SQL_GetGroupData = $conn->prepare("SELECT * FROM $Table_SubGroup WHERE IsAdmin = 0");
} else {
    $SQL_GetGroupData = $conn->prepare("SELECT * FROM $Table_SubGroup");
}
*/
/*
if(!isset($_GET['groupID'])){
    $SQL_GetGroupData = $conn->prepare("
    SELECT $Table_SubGroup.*, Count(*) AS UserCount 
    FROM $Table_SubGroup
    INNER JOIN $Table_UserSubGroup ON $Table_UserSubGroup.subgroup = $Table_SubGroup.name
    GROUP BY $Table_UserSubGroup.subgroup"
    );
    $SQL_GetGroupData->execute();

    $count = $SQL_GetGroupData->rowCount();

    if($count >= 1){
        $Results = array();
        $Results["RecordsCount"] = $count;
        $Results["StatusCode"] = $statuscode[1000];
        $Results["Results"] = array();
        while($row = $SQL_GetGroupData->fetch()) {
            $Result_Single = array();
            $Result_Single["GroupID"] = $row['subgroupID'];
            $Result_Single["GroupName"] = $row['name'];
            $Result_Single["UserCount"] = $row['UserCount'];
            array_push($Results["Results"], $Result_Single);
        }
    } else {
        $Results["Results"] = array();
    }
} else {

}
*/

$SQL_GetGroupData = $conn->prepare("
SELECT $Table_SubGroup.*, Count($Table_UserSubGroup.subgroup) AS UserCount 
FROM $Table_SubGroup
LEFT JOIN $Table_UserSubGroup ON $Table_UserSubGroup.subgroup = $Table_SubGroup.name
GROUP BY $Table_SubGroup.name"
);
$SQL_GetGroupData->execute();

$count = $SQL_GetGroupData->rowCount();

if($count >= 1){
$Results = array();
$Results["RecordsCount"] = $count;
$Results["StatusCode"] = $statuscode[1000];
$Results["Results"] = array();

while($row = $SQL_GetGroupData->fetch()) {
    $Result_Single = array();
    $Result_Single["GroupID"] = $row['subgroupID'];
    $Result_Single["GroupName"] = $row['name'];
    $Result_Single["UserCount"] = $row['UserCount'];
    $Result_Single["Users"] = array();

    $SQL_GetGroupUserData = $conn->prepare("
        SELECT $Table_SubGroup.name ,$Table_UserInfo.*
        FROM $Table_SubGroup
        INNER JOIN $Table_UserSubGroup ON $Table_UserSubGroup.subgroup = $Table_SubGroup.name
        INNER JOIN $Table_UserInfo ON $Table_UserInfo.UID = $Table_UserSubGroup.UID
        WHERE $Table_SubGroup.subgroupID = ?
        GROUP BY $Table_UserInfo.UID"
    );
    $SQL_GetGroupUserData->execute(array($row['subgroupID']));

    while($row_user = $SQL_GetGroupUserData->fetch()) {
        $Result_UserSingle = array();
        $Result_UserSingle["UID"] = $row_user['UID'];
        $Result_UserSingle["LastName"] = $row_user['lastname'];
        $Result_UserSingle["FirstName"] = $row_user['firstname'];
        $Result_UserSingle["NickName"] = $row_user['nickname'];
        array_push($Result_Single["Users"], $Result_UserSingle);
    }

    array_push($Results["Results"], $Result_Single);
}
} else {
    $Results["StatusCode"] = $statuscode[1001];
    $Results["Results"] = array();
}


$JSON_result = json_encode($Results, JSON_PRETTY_PRINT);
print_r($JSON_result);
?>