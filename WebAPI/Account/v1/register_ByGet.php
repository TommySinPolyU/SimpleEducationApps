<?php
include($_SERVER['DOCUMENT_ROOT']."/Secret/MySQL/config.php");

$result = array();
$checkercode = array();
$statuscode = array(
    1000 => "OK",
    1001 => "Email_Exists",
    1002 => "UserName_Exists",
    1003 => "Not Fill All Fields",
    1004 => "Password Length Must Longer than 8"
);

$Table_ac = table_ac;
$Table_userinfo = table_userinfo;
 
$newusername=$_GET['UserName'];
$newpassword=$_GET['PW'];
$newfirstname=$_GET['FirstName'];
$newlastname=$_GET['LastName'];
//$newnickname=$_GET['NickName'];
$newemail=$_GET['EMAIL'];
$newgender=$_GET['Gender'];

if(isset($newemail) && isset($newfirstname) && isset($newgender) &&
    isset($newlastname) /*&& isset($newnickname)*/ && isset($newpassword) && isset($newusername)){
        if(strlen($newpassword) > 8 ){
            // Check is Account is exists.
            date_default_timezone_set("Asia/Hong_Kong");
            $currenttime = date("Y-m-d H:i:s");

            $SQL_CheckRepeatability_Username= $conn->prepare("SELECT username FROM $Table_ac WHERE username = ?");
            $SQL_CheckRepeatability_Username->execute(array($newusername));
            $UserName_count = $SQL_CheckRepeatability_Username->rowCount();

            $SQL_CheckRepeatability_Email= $conn->prepare("SELECT email FROM $Table_ac WHERE email = ?");
            $SQL_CheckRepeatability_Email->execute(array($newemail));
            $Email_count = $SQL_CheckRepeatability_Email->rowCount();

            if($UserName_count > 0){
                array_push($checkercode, $statuscode[1002]);
            }
            if($Email_count > 0){
                array_push($checkercode, $statuscode[1001]);
            }

            // Register Successfully
            if($UserName_count == 0 && $Email_count == 0){
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
                $SQL_Regist_Profiles->execute(array($Result_UID, $newlastname, $newfirstname, NULL, $newgender));

                $checkercode = array();
                array_push($checkercode, $statuscode[1000]);
        }
    } else {
        $checkercode = array();
        array_push($checkercode, $statuscode[1004]);
    }
} else {
    $checkercode = array();
    array_push($checkercode, $statuscode[1003]);
}



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
                     .'0123456789!@#$%^&*'); // and any other characters
    shuffle($seed); // probably optional since array_is randomized; this may be redundant
    $rand = '';
    foreach (array_rand($seed, 3) as $k) $rand .= $seed[$k];
	return $rand;
}

?>