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

$Limit_DayRequest = 10;
$Result = array();
$statuscode = array(
    "OK" => 1000,
    "Failed" => 1001,
    "OverLimitation" => 1002
);

// Instantiation and passing `true` enables exceptions
$mail = new PHPMailer(true);

// Storing the received JSON into $json variable.
$json = file_get_contents('php://input');
 
// Decode the received JSON and Store into $obj variable.
$obj = json_decode($json,true);

$currenttime = date("Y-m-d H:i:s");
$currentdate = date("Y-m-d");
$Table_MailingInquiry = table_MailingInquiry;

$Mail_Title = $obj["Title"];
$Mail_Body = $obj["Body"];
$MailerUID = $obj["UID"];
$MailerUserName = $obj["UserName"];
//$MailerFirstName = $obj["FirstName"];
$MailerLastName = $obj["LastName"];
$MailerTitle = $obj["NameTitle"];
$MailerReplyEmail = $obj["ReplyEmail"];
$MailerLanguage = $obj["Language"];


/*
$Mail_Title = $_GET["Title"];
$Mail_Body = $_GET["Body"];
$MailerUID = $_GET["UID"];
$MailerUserName = $_GET["UserName"];
$MailerFirstName = $_GET["FirstName"];
$MailerLastName = $_GET["LastName"];
$MailerTitle = $_GET["NameTitle"];
$MailerReplyEmail = $_GET["ReplyEmail"];
$MailerLanguage = $_GET["Language"];
*/

// Get Last Auto Increment ID.
$SQL_Get_InquiryID = $conn->prepare(
    "SELECT AUTO_INCREMENT FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?"
);
$SQL_Get_InquiryID->execute(array(DB_NAME,$Table_MailingInquiry));
$count = $SQL_Get_InquiryID->rowCount();

if($count == 1){
    while($row = $SQL_Get_InquiryID->fetch()) {
        $Last_InquiryID = (int)$row['AUTO_INCREMENT'];
    }
}

$SQL_Get_CountOfMailingRecord = $conn->prepare(
    "SELECT * FROM $Table_MailingInquiry WHERE Mailer_UID = ? AND MailingDate BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL 1 DAY"
);
$SQL_Get_CountOfMailingRecord->execute(array($MailerUID));
$count_records = $SQL_Get_CountOfMailingRecord->rowCount();

if($count_records < $Limit_DayRequest){
    try {
        // Send Email to researchers
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
        //$mail->addAddress('vyaslina@eduhk.hk', 'Lina Vyas');     // Add a recipient
        //$mail->addAddress('wwy@eduhk.hk', 'Vivian Wong');     // Add a recipient
        $mail->addAddress('sme@enquiry.dsgshk.com', 'Enquiry System');
    
        // Content
        $mail->isHTML(true);                                  // Set email format to HTML
        $mail->Subject = "[".$currentdate." #".$Last_InquiryID."]".$Mail_Title;
        $mail->Body    = "English Version:<br>(The Chinese version will be written below the English version)<br>".
                        "The system received the query from the user.<br>You can reply to the user’s query based on the following information<br>---------------------------------------------".
                        "<br>User Information:<br>UID: ".$MailerUID.
                        "<br>Username: ".$MailerUserName.
                        "<br>Last Name: ".$MailerLastName.
                        "<br>Email: ".$MailerReplyEmail.
                        "<br>---------------------------------------------<br>Email Message:<br>".$Mail_Body.
                        "<br><br><br><br>---------------------------------------------<br>".
                        "This is an email sent automatically by the system.<br>Please do not reply directly to this email.<br><br>
                        SME App Automatic Mailing System<br>".$currenttime."<br><br>---------------------------------------------<br>".
                        "系統收到以下應用程式用戶發出的查詢，<br>你可根據以下資料回覆該用戶的查詢<br>---------------------------------------------".
                        "<br>用戶資料:<br>用戶編號: ".$MailerUID.
                        "<br>登入名稱: ".$MailerUserName.
                        "<br>姓氏: ".$MailerLastName.
                        "<br>電郵地址: ".$MailerReplyEmail.
                        "<br>---------------------------------------------<br>電郵內容:<br>".$Mail_Body.
                        "<br><br><br><br>---------------------------------------------<br>".
                        "此為系統自動發出的電郵，請勿直接回覆此電郵。<br><br>
                        SME App 自動電郵系統<br>".$currenttime."<br><br>";
        $mail->send();
        
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
        $mail->addAddress($MailerReplyEmail, $MailerTitle.$MailerLastName);     // Add a recipient
    
        // Content
        $mail->isHTML(true);                                  // Set email format to HTML
        
        if($MailerLanguage == "繁體中文"){
            $mail->Subject = "[".$currentdate." #".$Last_InquiryID."]研究團隊已接獲您的查詢";
            $mail->Body    = $MailerLastName." ".$MailerTitle." 您好<br>系統已收到您的查詢，<br>研究團隊將會於稍後時間回覆。<br>感謝您的查詢<br>".
            "<br>參考編號: ".$currentdate." #".$Last_InquiryID.
            "<br>---------------------------------------------<br>以下是您的查詢內容副本".
            "<br>電郵主旨: ".$Mail_Title.
            "<br>電郵內容:<br>".$Mail_Body.
            "<br><br><br><br>---------------------------------------------<br>".
            "此為系統自動發出的電郵，請勿直接回覆此電郵。<br>
            SME App 自動電郵系統<br>".$currenttime;
        } else {
            $mail->Subject = "[".$currentdate." #".$Last_InquiryID."] Research team has received your inquiry";
            $mail->Body = "Dear ".$MailerTitle." ".$MailerLastName."<br>The system has received your inquiry. <br>The research team will reply later<br>Thank you for your inquiry<br>".
            "<br>Reference Number: ".$currentdate." #".$Last_InquiryID.
            "<br>---------------------------------------------<br>The following is a copy of your inquiry".
            "<br>Email Title: ".$Mail_Title.
            "<br>Email Content:<br>".$Mail_Body.
            "<br><br><br><br>------------------------------------- --------<br>".
            "This is an email sent automatically by the system.<br>Please do not reply directly to this email.<br><br>
            SME App Automatic Mailing System<br>".$currenttime;
        }
        $mail->send();
        $SQL_Insert_InquiryRecord = $conn->prepare(
            "INSERT INTO $Table_MailingInquiry(Mailer_UID,MailingDate) 
            VALUES(?,?)"
        );
        $SQL_Insert_InquiryRecord->execute(array($MailerUID,$currenttime));
        $Result = array();
        $Result["StatusCode"] = $statuscode["OK"];
    } catch (Exception $e) {
        $Result = array();
        $Result["StatusCode"] = $statuscode["Failed"];
        $Result["ErrorMessage"] = $mail->ErrorInfo;
    }
} else {
    $Result = array();
    $Result["StatusCode"] = $statuscode["OverLimitation"];
}


$JSON_result = json_encode($Result,JSON_PRETTY_PRINT);
print_r($JSON_result);
?>