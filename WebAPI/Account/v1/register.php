<?php
// Storing the received JSON into $json variable.
$json = file_get_contents('php://input');
if($json == null){
    exit;
}

include($_SERVER['DOCUMENT_ROOT']."/Secret/MySQL/config.php");

$result = array();
$checkercode = array();
$statuscode = array(
    "OK" => 1000,
    "Email_Exists" => 1001,
    "UserName_Exists" => 1002,
    "IPLimited" => 1003,
    "INVCODE_Limited" => 1004,
    "INVCODE_Error" => 1005,
);

$Table_ac = table_ac;
$Table_userinfo = table_userinfo;
$Table_RegisterIpcheckRecord = table_RegisterIpcheckRecord;
$Table_InvitationCodes = table_InvitationCodes;
$Table_InvitationRecords = table_InvitationRecords;
$Table_UserSubGroups = table_UserSubGroups;
 
// Decode the received JSON and Store into $obj variable.
$obj = json_decode($json,true);

$newusername=$obj['UserName'];
$newpassword=$obj['PW'];
$newfirstname=$obj['FirstName'];
$newlastname=$obj['LastName'];
$newnickname=$obj['Nickname'];
$newemail=$obj['EMAIL'];
$newgender=$obj['Gender'];
$newinvitationcode=$obj['INVCODE'];
$diffdays = 1;

// Check is Account is exists.
date_default_timezone_set("Asia/Hong_Kong");
$currenttime = date("Y-m-d H:i:s");
$clientIP = get_client_ip();

$SQL_CheckIP = $conn->prepare("SELECT * FROM $Table_RegisterIpcheckRecord WHERE IP = ?");
$SQL_CheckIP->execute(array($clientIP));
$IPChecker_count = $SQL_CheckIP->rowCount();

if($IPChecker_count == 1){
    while($row = $SQL_CheckIP->fetch()) {
        $previousregistertime = $row['LastRegisterDate'];
    }
    
    $diff = abs(strtotime($currenttime) - strtotime($previousregistertime));
    
    //$diffyears = floor($diff / (365*60*60*24));
    //$diffmonths = floor(($diff - $diffyears * 365*60*60*24) / (30*60*60*24));
    //$diffdays = floor(($diff - $diffyears * 365*60*60*24 - $diffmonths*30*60*60*24)/ (60*60*24));
    
    // Debugging and Testing
    $diffyears = 1;
    $diffmonths = 1;
    $diffdays = 2;
}

if($diffdays < 1 && $diffmonths == 0 && $diffyears == 0){
    array_push($checkercode, $statuscode["IPLimited"]);
} else {
    $SQL_CheckRepeatability_Username= $conn->prepare("SELECT username FROM $Table_ac WHERE username = ?");
    $SQL_CheckRepeatability_Username->execute(array($newusername));
    $UserName_count = $SQL_CheckRepeatability_Username->rowCount();

    $SQL_CheckRepeatability_Email= $conn->prepare("SELECT email FROM $Table_ac WHERE email = ?");
    $SQL_CheckRepeatability_Email->execute(array($newemail));
    $Email_count = $SQL_CheckRepeatability_Email->rowCount();
    
    $SQL_CheckINVCODE = $conn->prepare("SELECT * FROM $Table_InvitationCodes WHERE code = ? AND (CONVERT_TZ(CURRENT_TIMESTAMP, '+00:00', '+08:00')) BETWEEN startdate AND enddate");
    $SQL_CheckINVCODE->execute(array($newinvitationcode));
    $INVCODE_count = $SQL_CheckINVCODE->rowCount();
    
    if($UserName_count > 0){
        array_push($checkercode, $statuscode["UserName_Exists"]);
    }
    if($Email_count > 0){
        array_push($checkercode, $statuscode["Email_Exists"]);
    }
    
    if($INVCODE_count != 1){
        array_push($checkercode, $statuscode["INVCODE_Error"]);
    } else {
        while($row = $SQL_CheckINVCODE->fetch()) {
            $Result_CodeID = $row['invcodeID'];
            $Result_RegisGroups = $row['preregis_groups'];
        }
        $SQL_CheckINVCODECOUNT = $conn->prepare("
            SELECT $Table_InvitationCodes.invcodeID AS CodeID, COUNT($Table_InvitationRecords.recordID) AS USERCOUNT, $Table_InvitationCodes.userlimit AS UserLimit
            FROM $Table_InvitationRecords
            INNER JOIN $Table_InvitationCodes ON $Table_InvitationRecords.invcodeID = $Table_InvitationCodes.invcodeID
            WHERE $Table_InvitationRecords.invcodeID = ?
        ");
        $SQL_CheckINVCODECOUNT->execute(array($Result_CodeID));
        while($row = $SQL_CheckINVCODECOUNT->fetch()) {
            $Result_UserCount = $row['USERCOUNT'];
            $Result_UserLimit = $row['UserLimit'];
        }
        if($Result_UserCount >= $Result_UserLimit){
             array_push($checkercode, $statuscode["INVCODE_Limited"]);
        }
    }

    // Register Successfully
    if($UserName_count == 0 && $Email_count == 0 && $INVCODE_count == 1 && ($Result_UserLimit == 0 || $Result_UserCount < $Result_UserLimit)){
        $hashedPW = password_hash($newpassword, PASSWORD_DEFAULT); // Convert Password To Hashed Value
        $Regist_Code = uniqid() . get_random_string();

        $SQL_Regist_AC = $conn->prepare("INSERT INTO $Table_ac(username,email,password,regist_date,regist_code) VALUES(?,?,?,?,?)");
        $SQL_Regist_AC->execute(array($newusername,$newemail,$hashedPW,$currenttime, $Regist_Code));

        $SQL_getUID = $conn->prepare("SELECT UID FROM $Table_ac WHERE username = ?");
        $SQL_getUID->execute(array($newusername));
        while($row = $SQL_getUID->fetch()) {
            $Result_UID = $row['UID'];
        }

        $SQL_Regist_Profiles = $conn->prepare("INSERT INTO $Table_userinfo(UID , lastname, firstname, nickname, Gender) VALUES(?, ?, ?, ?, ?)");
        $SQL_Regist_Profiles->execute(array($Result_UID, $newlastname, $newfirstname, $newnickname, $newgender));

        if($IPChecker_count > 0){
            $SQL_Regist_IP = $conn->prepare("UPDATE $Table_RegisterIpcheckRecord SET LastRegisterDate = ? WHERE IP = ?");
            $SQL_Regist_IP->execute(array($currenttime,$clientIP));
        } else {
            $SQL_Regist_IP = $conn->prepare("INSERT INTO $Table_RegisterIpcheckRecord(IP,LastRegisterDate) VALUES(?,?)");
            $SQL_Regist_IP->execute(array($clientIP,$currenttime));
        }
        
        $SQL_Regist_INVCODERecord = $conn->prepare("INSERT INTO $Table_InvitationRecords(invcodeID, useDate, UID) VALUES(?, ?, ?)");
        $SQL_Regist_INVCODERecord->execute(array($Result_CodeID,$currenttime,$Result_UID));
        
        if($Result_RegisGroups != NULL || $Result_RegisGroups != ""){
            $GroupNames = explode(",", $Result_RegisGroups);
            for($i = 0; $i < count($GroupNames); $i++){
                $SQL_Insert_New_UserToGroup= $conn->prepare(
                    "INSERT INTO $Table_UserSubGroups(UID, subgroup) VALUES(?,?)"
                );
                $SQL_Insert_New_UserToGroup->execute(array($Result_UID, $GroupNames[$i]));
            }
        }

        $checkercode = array();
        array_push($checkercode, $statuscode["OK"]);
    }
}

    //$info_sql = $conn->prepare("INSERT INTO $Table_userinfo(UID , NickName, Gender, Birthdate, Country) VALUES(?, ?, ?, ?, ?)");
	//$info_sql->execute(array($Result_UID, $nName, $gender, $birthdate, $country));

$result["StatusCode"] = $checkercode;
$JSON_result = json_encode($result);
print_r($JSON_result);

// Function to get the client IP address
function get_client_ip() {
	$ipaddress = $_SERVER['REMOTE_ADDR'];
	return $ipaddress;
}

function get_random_string(){
	$seed = str_split('abcdefghijklmnopqrstuvwxyz'
                     .'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
                     .'0123456789'); // and any other characters
    shuffle($seed); // probably optional since array_is randomized; this may be redundant
    $rand = '';
    foreach (array_rand($seed, 3) as $k) $rand .= $seed[$k];
	return $rand;
}

?>