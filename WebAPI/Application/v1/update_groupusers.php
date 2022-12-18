<?php
header('Content-Type: application/json');
include($_SERVER['DOCUMENT_ROOT']."/Secret/MySQL/config.php");

$Result = array();
$statuscode = array(
    "OK" => 1000,
    "Failed" => 1001
);
$Table_UserSubGroups = table_UserSubGroups;

// Storing the received JSON into $json variable.
$json = file_get_contents('php://input');
 
// Decode the received JSON and Store into $obj variable.
$obj = json_decode($json,true);

/*
$GroupName=$_GET['GroupName'];
$selected_users=$_GET['Users_Select'];
$selected_users_array = explode(",", $selected_users);
*/

$GroupName=$obj['GroupName'];
if($obj['Users_Select'] != null){
    $selected_users=$obj['Users_Select'];
    $selected_users_array = explode(",", $selected_users);

    $SQL_Get_Current_GroupUserList = $conn->prepare(
        "SELECT * FROM $Table_UserSubGroups WHERE subgroup = ?"
    );
    $SQL_Get_Current_GroupUserList->execute(array($GroupName));
    $users_count = $SQL_Get_Current_GroupUserList->rowCount();

    $Result = array();

    $current_group_users = array();
    $add_users = array();
    $remove_users = array();

    try{
        if($users_count >= 1){
            while($row = $SQL_Get_Current_GroupUserList->fetch()) {
                array_push($current_group_users, $row["UID"]);
            }
            $Result["Current_Group"] = $GroupName; 
            $Result["Current_Group_Users"] = $current_group_users;
        }

        foreach ($current_group_users as $user) {
            if(!in_array($user,$selected_users_array)){
                // Remove Record From DB
                array_push($remove_users, $user);
                $SQL_Remove_User= $conn->prepare(
                    "DELETE FROM $Table_UserSubGroups WHERE UID = ? and subgroup = ?"
                );
                $SQL_Remove_User->execute(array($user, $GroupName));
            }
            $Result["Remove_Users"] = $remove_users;
        }

        foreach ($selected_users_array as $user) {
            if(!in_array($user,$current_group_users)){
                // Insert Record To DB
                array_push($add_users, $user);
                $SQL_Insert_New_User= $conn->prepare(
                    "INSERT INTO $Table_UserSubGroups(UID, subgroup) VALUES(?,?)"
                );
                $SQL_Insert_New_User->execute(array($user, $GroupName));
            }
            $Result["Add_Users"] = $add_users;
        }

        $Result["StatusCode"] = $statuscode["OK"];
        $Result["Message"] = "Records has been updated.";
    } catch (Exception $e){
        http_response_code(401);
        $Result["StatusCode"] = $statuscode["Failed"];
        $Result["Error Message"] = $e->getMessage();
    }
} else {
    $SQL_Remove_User= $conn->prepare(
        "DELETE FROM $Table_UserSubGroups WHERE subgroup = ?"
    );
    $SQL_Remove_User->execute(array($GroupName));
    $Result["StatusCode"] = $statuscode["OK"];
    $Result["Message"] = "Records has been updated.";
}


$JSON_result = json_encode($Result,JSON_PRETTY_PRINT);
print_r($JSON_result);

?>