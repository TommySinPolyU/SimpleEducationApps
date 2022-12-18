<?php
include($_SERVER['DOCUMENT_ROOT']."/Secret/MySQL/config.php");
$Table_ac = table_ac;
$Table_ValidationRequest = table_ValidationRequest;
$UID=$_GET['UID'];
$Language=$_GET['Lang'];
$Link_RequestCode=$_GET['RequestCode'];

$isValid = 1;
$currenttime = new DateTime();

$SQL_Get_RequestRecord = $conn->prepare(
    "SELECT * FROM $Table_ValidationRequest WHERE UID = ?"
);
$SQL_Get_RequestRecord->execute(array($UID));
$count_reset = $SQL_Get_RequestRecord->rowCount();

if($count_reset > 0){
    while($row = $SQL_Get_RequestRecord->fetch()) {
        $DB_ResetCode = $row['requestCode'];
        $DB_IssueDate = $row['requestDate'];
    }
    $DB_IssueDate = (strtotime($DB_IssueDate));
    $minutes_diff = abs($DB_IssueDate - time()) / 60;
    //$minutes_diff = 0;
    if($DB_ResetCode != $Link_RequestCode || $minutes_diff >= 30){
        $isValid = 0;
    }
} else {
    $isValid = 0;
}


$SQL_Get_User = $conn->prepare(
    "SELECT * FROM $Table_ac WHERE UID = ?"
);
$SQL_Get_User->execute(array($UID));
$count = $SQL_Get_User->rowCount();

if($count == 1){
    while($row = $SQL_Get_User->fetch()) {
        $EmailValidationStatus = $row['emailverified'];
    }
    if($EmailValidationStatus == 1){
        $isValid = 2;
    }
    else if($isValid == 1){
        $SQL_Update_ValidStatus = $conn->prepare(
            "UPDATE $Table_ac SET emailverified = ? WHERE UID = ?"
        );
        $SQL_Update_ValidStatus->execute(array(1, $UID));
        
        $SQL_Delete_AllUserRecords = $conn->prepare(
            "DELETE FROM $Table_ValidationRequest WHERE UID = ?"
        );
        $SQL_Delete_AllUserRecords->execute(array($UID));
    }
}
?>
    
<html>
  <title>
      <? if ($Language=="zh-hk") : ?>
      SME 驗證電子郵件系統
      <? elseif ($Language=="en-gb") : ?>
      SME Email Validation System
      <? endif; ?>
      </title>
  <head>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://fonts.googleapis.com/css?family=Roboto:300,400,500,700" rel="stylesheet">
    <style>
      html, body {
      display: flex;
      justify-content: center;
      font-family: Roboto, Arial, sans-serif;
      font-size: 15px;
      }
      form {
      border: 5px solid #f1f1f1;
      }
      input[type=text], input[type=password] {
      width: 100%;
      padding: 16px 8px;
      margin: 8px 0;
      display: inline-block;
      border: 1px solid #ccc;
      box-sizing: border-box;
      }
      input:read-only {
          background-color: #C6C6C6;
      }
      .icon {
      font-size: 110px;
      display: flex;
      justify-content: center;
      color: #4286f4;
      }
      button {
      background-color: #4286f4;
      color: white;
      padding: 14px 0;
      margin: 10px 0;
      border: none;
      cursor: grab;
      width: 48%;
      }
      h1 {
      text-align:center;
      fone-size:18;
      }
      button:hover {
      opacity: 0.8;
      }
      .formcontainer {
      text-align: center;
      margin: 24px 50px 12px;
      }
      .container {
      padding: 16px 0;
      text-align:left;
      }
      span.psw {
      float: right;
      padding-top: 0;
      padding-right: 15px;
      }
      #reset_submit{
          background-color: #4286f4;
          color: #ffffff;
      }
      #reset_submit:disabled{
          background-color: #cccccc;
          color: #ffffff;
      }
      
      #Invaild_Msg {
        height: 425px;
        width: 600px;
        text-align: center;
        display: table-cell;
        vertical-align:middle;
        color: #E72222;
        font-size: 18px;
      }
      
      #Result_Msg_div {
        height: 0px;
        width: 0px;
        text-align: center;
        display: table-cell;
        vertical-align:middle;
      }
      
      /* Change styles for span on extra small screens */
      @media screen and (max-width: 300px) {
      span.psw {
      display: block;
      float: none;
      }
    </style>
  </head>
  <body>
    <form id="reset_pw_form" method="post">
      <h1>
      <? if ($Language=="zh-hk") : ?>
         SME 驗證電子郵件系統
      <? elseif ($Language=="en-gb") : ?>
        SME Email Validation System
      <? endif; ?>
      </h1>
      <div class="icon">
        <img src="email-verification.png" width="170" height="170">
      </div>
    <? if($isValid != 0) :?>
        <div id="Result_Msg_div">
            <p id="Result_Msg">

            </p>
        </div>
    <? elseif ($isValid==0) : ?>
    <div id="Invaild_Msg">
        <strong>
            <? if ($Language=="zh-hk") : ?>
              此驗證連結已失效<br>請於應用程式內重新發出驗證郵件申請
            <? elseif ($Language=="en-gb") : ?>
              This verification link has expired<br>Please re-send the verification email request in the app 
            <? endif; ?>
        </strong>
    </div>
    <? endif; ?>
    

    
  </body>
<script>
jQuery.noConflict();
<? if ($isValid==1) : ?>
    <? if ($Language=="zh-hk") : ?>
    jQuery('#Result_Msg').html("您的電子郵件已驗證<br>現在您已可於應用程式中登入您的帳號");
    <? elseif ($Language=="en-gb") : ?>
    jQuery('#Result_Msg').html("Your email has been verified.<br>You can now log in to your account in the app。");
    <? endif; ?>
    jQuery('#Result_Msg').css({ 'color': '#20A87D', 'font-size': '125%' });
    jQuery('#Result_Msg_div').height("425px");
    jQuery('#Result_Msg_div').width("600px");
<? elseif ($isValid==0) : ?>
    <? if ($Language=="zh-hk") : ?>
    jQuery('#Result_Msg').html("驗證失敗<br>此驗證連結或已失效<br>請於應用程式內重新發出驗證申請");
    <? elseif ($Language=="en-gb") : ?>
    jQuery('#Result_Msg').html("Verification Failed<br>This verification link has expired<br>Please re-send the verification email request in the app");
    <? endif; ?>
    jQuery('#Result_Msg').css({ 'color': 'red', 'font-size': '125%' });
    jQuery('#form_elements').hide();
    jQuery('#reset_submit').hide();
    jQuery('#Result_Msg_div').height("425px");
    jQuery('#Result_Msg_div').width("600px");
<? elseif ($isValid==2) : ?>
    <? if ($Language=="zh-hk") : ?>
    jQuery('#Result_Msg').html("您的帳號已完成電郵驗證<br>您無須再次提交驗證");
    <? elseif ($Language=="en-gb") : ?>
    jQuery('#Result_Msg').html("Your account has been verified by email<br>You don’t need to submit for verification again.");
    <? endif; ?>
    jQuery('#Result_Msg').css({ 'color': '#20A87D', 'font-size': '125%' });
    jQuery('#form_elements').hide();
    jQuery('#reset_submit').hide();
    jQuery('#Result_Msg_div').height("425px");
    jQuery('#Result_Msg_div').width("600px");
<? endif; ?>
</script>
</html>
    
    