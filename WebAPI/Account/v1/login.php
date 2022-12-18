<?php
include($_SERVER['DOCUMENT_ROOT']."/Secret/MySQL/config.php");
require $_SERVER['DOCUMENT_ROOT']."/Secret/php-jwt/vendor/autoload.php";
use \Firebase\JWT\JWT;
// Storing the received JSON into $json variable.
$json = file_get_contents('php://input');
if($json == null){
    exit;
}

$result = array();
$statuscode = array(
    "OK" => 1000,
    "Incorrect_Password" => 1001,
    "Incorrect_Email/UserName" => 1002,
    "Unverified_Email" => 1003,
);

$Table_ac = table_ac;
$Table_userinfo = table_userinfo;
$Table_userloginrecord = table_userloginrecord;
$Table_GroupPermission = table_GroupPermission;
$Table_ApplicationSetting = table_ApplicationSetting;
$Table_UserSubGroup = table_UserSubGroups;

// Decode the received JSON and Store into $obj variable.
$obj = json_decode($json,true);

$username=$obj['UserName'];
$password=$obj['PW'];

$SQL_CheckAppSetting = $conn->prepare("SELECT * FROM $Table_ApplicationSetting");
$SQL_CheckAppSetting->execute();

while($row = $SQL_CheckAppSetting->fetch()) {
    $Server_AppCode = $row['AppCode'];
}

$SQL_getPW_Hash = $conn->prepare("SELECT * FROM $Table_ac WHERE Email = ? OR username = ?");
$SQL_getPW_Hash->execute(array($username, $username));
$count = $SQL_getPW_Hash->rowCount();

if($count>0){
    $currenttime = date("Y-m-d H:i:s");
    $clientIP = get_client_ip();
    
    while($row = $SQL_getPW_Hash->fetch()) {
        $Result_PW_Hash = $row['password'];
        $Result_UID = $row['UID'];
		$Result_RegisterCode = $row['regist_code'];
        $Result_Group = $row['UserGroup'];
        $Result_EmailVerifyStatus = $row['emailverified'];
    }
    
    if($Result_EmailVerifyStatus == 1) {
        if(password_verify($password,$Result_PW_Hash)){
            $SQL_Login_Records = $conn->prepare("SELECT * FROM $Table_userloginrecord WHERE UID = ?");
            $SQL_Login_Records->execute(array($Result_UID));
    
            while($row = $SQL_Login_Records->fetch()) {
                $previoustime = $row['LoginDateTime'];
                $diff = round(abs(strtotime($currenttime) - strtotime($previoustime)) / 60,2);
                $SQL_Login_UpdateRecord = $conn->prepare("UPDATE $Table_userloginrecord SET LogoutDateTime = ?, RunTimes = ? WHERE UID = ? AND LoginDateTime = ? AND LogoutDateTime IS NULL");
                $SQL_Login_UpdateRecord->execute(array($currenttime, $diff, $Result_UID, $previoustime));
            }
    
            $SQL_Login_InsertRecord = $conn->prepare("INSERT INTO $Table_userloginrecord(UID, LoginDateTime, FromIP) VALUES(?,?,?)");
            $SQL_Login_InsertRecord->execute(array($Result_UID, $currenttime, $clientIP));
    
            $SQL_Check_GroupPermission = $conn->prepare("SELECT * FROM $Table_GroupPermission WHERE GroupName = ?");
            $SQL_Check_GroupPermission->execute(array($Result_Group));
            
            while($row = $SQL_Check_GroupPermission->fetch()) {
                $Result_CanUpload = $row['CanUpload'];
                $Result_CanRead = $row['CanRead'];
                $Result_CanViewData = $row['CanViewData'];
                $Result_CanModify = $row['CanModify'];
                $Result_IsAdmin = $row['IsAdmin'];
            }
    
            $subgroup_array = array();
            $SQL_GetUserSubgroup = $conn->prepare("
                SELECT * 
                FROM $Table_UserSubGroup
                WHERE UID = ?
            ");
            $SQL_GetUserSubgroup->execute(array($Result_UID));
            while($row_subgroup = $SQL_GetUserSubgroup->fetch()){
                array_push($subgroup_array, $row_subgroup['subgroup']);
            }
        
            //$subgroup_array_string = "'" .implode("','", $subgroup_array  ) . "'"; 
    
            $result["UID"] = $Result_UID;
            $result["CanUpload"] = (bool)$Result_CanUpload;
            $result["CanRead"] = (bool)$Result_CanRead;
            $result["CanViewData"] = (bool)$Result_CanViewData;
            $result["CanModify"] = (bool)$Result_CanModify;
            $result["IsAdmin"] = (bool)$Result_IsAdmin;
            $result["RegisCode"] = $Result_RegisterCode;
            $result["UserGroup"] = (string)$Result_Group;
            $result["UserSubGroup"] = $subgroup_array;
    
            // Genarate the Token for Accessing API
            $issuer_claim = $_SERVER['HTTP_HOST'];
            $audience_claim = $Result_RegisterCode;
            $issuedat_claim = time(); // issued at
            $notbefore_claim = $issuedat_claim; //not before in seconds
            $expire_claim = $issuedat_claim + 86400;// 86400; // expire time in seconds
            $user_token = array(
                "iss" => $issuer_claim,
                "aud" => $audience_claim,
                "iat" => $issuedat_claim,
                "nbf" => $notbefore_claim,
                "exp" => $expire_claim,
                "data" => array(
                    "UID" => $Result_UID,
                    "RegisCode" => $Result_RegisterCode,
            ));
            $jwt = JWT::encode($user_token, $Server_AppCode);
            $result["JWT_Token"] = (string)$jwt;
    
            $checkercode = array();
            array_push($checkercode, $statuscode["OK"]);
    
        } else {
            $checkercode = array();
            array_push($checkercode, $statuscode["Incorrect_Password"]);
        }
    } else {
        $checkercode = array();
        array_push($checkercode, $statuscode["Unverified_Email"]);
    }
} else {
    $checkercode = array();
    array_push($checkercode, $statuscode["Incorrect_Email/UserName"]);
}

$result["StatusCode"] = $checkercode;
$JSON_result = json_encode($result);
print_r($JSON_result);

// Function to get the client IP address
function get_client_ip() {
    $ipaddress = $_SERVER['REMOTE_ADDR'];
    return $ipaddress;
}

?>