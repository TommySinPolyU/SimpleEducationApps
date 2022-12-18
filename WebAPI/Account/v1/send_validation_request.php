<?php
header('Content-Type: application/json');
date_default_timezone_set("Asia/Hong_Kong");
mb_internal_encoding('UTF-8');
include($_SERVER['DOCUMENT_ROOT']."/Secret/MySQL/config.php");
// Import PHPMailer classes into the global namespace
// These must be at the top of your script, not inside a function
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;
use PHPMailer\PHPMailer\Exception;
// Load Composer's autoloader
 require $_SERVER['DOCUMENT_ROOT']."/Secret/PHPMailer/vendor/autoload.php";

$Result = array();
$statuscode = array(
    "OK" => 1000,
    "Failed" => 1001,
    "AccountNotFound" => 1002,
    "ApplicationInvaild" => 1003
);

// Instantiation and passing `true` enables exceptions
$mail = new PHPMailer(true);

// Storing the received JSON into $json variable.
$json = file_get_contents('php://input');
 
// Decode the received JSON and Store into $obj variable.
$obj = json_decode($json,true);

$currenttime = date("Y-m-d H:i:s");
$currentdate = date("Y-m-d");

$Table_ValidationRequest = table_ValidationRequest;
$Table_ac = table_ac;
$Table_ApplicationSetting = table_ApplicationSetting;


$username = $obj["Username"];
$MailerLanguage = $obj["Language"];
$AppCode=$obj['AppCode'];
$Version=$obj['Version'];

$SQL_CheckAppSetting = $conn->prepare("SELECT * FROM $Table_ApplicationSetting");
$SQL_CheckAppSetting->execute();

while($row = $SQL_CheckAppSetting->fetch()) {
    $Server_AppCode = $row['AppCode'];
    $Server_Version = $row['Version'];
}

if($AppCode != $Server_AppCode || $Version != $Server_Version){
    $Result = array();
    $Result["StatusCode"] = $statuscode["ApplicationInvaild"];
    $Result["ErrorMessage"] = "Application Invaild";
    exit;
}

if($MailerLanguage == "繁體中文"){
    $MailerLanguage = "zh-hk";
}  else {
    $MailerLanguage = "en-gb";
}

$SQL_FindUser = $conn->prepare("SELECT * FROM $Table_ac WHERE username = ?");
$SQL_FindUser->execute(array($username));
$count_account = $SQL_FindUser->rowCount();

if($count_account != 0){
    while($row = $SQL_FindUser->fetch()) {
        $MailerUID = $row["UID"];
        $regisCode = $row["regist_code"];
        $MailerReplyEmail = $row["email"];
    }
    $requestCode = uniqid($regisCode,false);
    $resetLink = "https://sme.dsgshk.com/Account/v1/email_validation.php"."?UID=".$MailerUID."&RequestCode=".$requestCode."&Lang=".$MailerLanguage;
    // Get Last Auto Increment ID.
    $SQL_Get_InquiryID = $conn->prepare(
        "SELECT AUTO_INCREMENT FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?"
    );
    $SQL_Get_InquiryID->execute(array(DB_NAME,$Table_ValidationRequest));
    $count = $SQL_Get_InquiryID->rowCount();
    
    if($count == 1){
        while($row = $SQL_Get_InquiryID->fetch()) {
            $Last_InquiryID = (int)$row['AUTO_INCREMENT'];
        }
    }
    
    try {
        // Send CC to Mailer
        $mail = new PHPMailer(true);
        //Server settings
        //$mail->SMTPDebug = SMTP::DEBUG_SERVER;                      // Enable verbose debug output
        $mail->isSMTP();                                            // Send using SMTP
        $mail->Host       = 'smtp.hostinger.com';                    // Set the SMTP server to send through
        $mail->SMTPAuth   = true;                                   // Enable SMTP authentication
        $mail->Username   = 'auto@sme.dsgshk.com';                   // SMTP username
        $mail->Password   = 'O~8f?dP]?/u';                               // SMTP password
        $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;         // Enable TLS encryption; `PHPMailer::ENCRYPTION_SMTPS` encouraged
        $mail->Port       = 587;                                    // TCP port to connect to, use 465 for `PHPMailer::ENCRYPTION_SMTPS` above
        $mail->CharSet = 'UTF-8';
    
        //Recipients
        $mail->setFrom('auto@sme.dsgshk.com', 'SME App 自動電郵系統 Automatic Mailing System');
        $mail->addAddress($MailerReplyEmail);     // Add a recipient
    
        // Content
        $mail->isHTML(true);                                  // Set email format to HTML
        
        if($MailerLanguage == "zh-hk"){
            $mail->Subject = "驗證您在 SME App 所註冊 / 更改的電子郵件";
            $mail->Body    = "系統已收到您的註冊 / 更改電郵地址的申請<br>請透過以下的連結驗證此電郵地址：<br>".
            $resetLink."<br><br>請注意：以上連結將會在發出後 30 分鐘失效，<br>如連結已失效，請於應用程式內重新發送驗證要求。".
            "<br><br><br><br>---------------------------------------------<br>".
            "此為系統自動發出的電郵，請勿直接回覆此電郵。<br>
            SME App 自動電郵系統<br>".$currenttime;
        } else {
            $mail->Subject = "Verify Your Registered / Changed Email in SME App";
            $mail->Body = "The system has received your registration / change email address application<br>Please verify this email address through the link below:<br> ".
            $resetLink."<br><br>Please note: the above link will expire 30 minutes after it is issued.<br>If the link has expired,please re-send the verification request in the app. ".
            "<br><br><br><br>------------------------------------- --------<br>".
            "This is an email sent automatically by the system. Please do not reply directly to this email.<br>
            SME App Automatic Mailing System<br>".$currenttime;
        }
        $mail->send();
        
        $SQL_Delete_AllUserRecords = $conn->prepare(
            "DELETE FROM $Table_ValidationRequest WHERE UID = ?"
        );
        $SQL_Delete_AllUserRecords->execute(array($MailerUID));
        
        $SQL_Insert_InquiryRecord = $conn->prepare(
            "INSERT INTO $Table_ValidationRequest(UID, requestCode,requestDate) 
            VALUES(?,?,?)"
        );
        $SQL_Insert_InquiryRecord->execute(array($MailerUID, $requestCode,$currenttime));
        $Result = array();
        $Result["StatusCode"] = $statuscode["OK"];
    } catch (Exception $e) {
        $Result = array();
        $Result["StatusCode"] = $statuscode["Failed"];
        $Result["ErrorMessage"] = $mail->ErrorInfo;
    }
} else {
    $Result = array();
    $Result["StatusCode"] = $statuscode["AccountNotFound"];
    $Result["ErrorMessage"] = "Account Not Found";
}

$JSON_result = json_encode($Result,JSON_PRETTY_PRINT);
print_r($JSON_result);
?>