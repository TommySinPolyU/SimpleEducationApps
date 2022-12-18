<?php
include($_SERVER['DOCUMENT_ROOT']."/Secret/MySQL/config.php");
$Table_ac = table_ac;
$Table_ResetPWRecords = table_ResetPWRecords;
$UID=$_GET['UID'];
$Language=$_GET['Lang'];
$Link_ResetCode=$_GET['ResetCode'];

$isVaild = 1;
$currenttime = new DateTime();

$SQL_Get_ResetPWRecord = $conn->prepare(
    "SELECT * FROM $Table_ResetPWRecords WHERE UID = ?"
);
$SQL_Get_ResetPWRecord->execute(array($UID));
$count_reset = $SQL_Get_ResetPWRecord->rowCount();

if($count_reset > 0){
    while($row = $SQL_Get_ResetPWRecord->fetch()) {
        $DB_ResetCode = $row['resetCode'];
        $DB_IssueDate = $row['resetDate'];
    }
    
    $DB_IssueDate = (strtotime($DB_IssueDate));
    $minutes_diff = abs($DB_IssueDate - time()) / 60;
    //$minutes_diff = 0;
    if($DB_ResetCode != $Link_ResetCode || $minutes_diff >= 30){
        $isVaild = 0;
    }
} else {
    $isVaild = 0;
}


$SQL_Get_User = $conn->prepare(
    "SELECT * FROM $Table_ac WHERE UID = ?"
);
$SQL_Get_User->execute(array($UID));
$count = $SQL_Get_User->rowCount();

if($count == 1){
    while($row = $SQL_Get_User->fetch()) {
        $Username = $row['username'];
    }
}
?>
    
<html>
  <title>
      <? if ($Language=="zh-hk") : ?>
      SME 密碼重置系統
      <? elseif ($Language=="en-gb") : ?>
      SME Password Reset System
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
  <body onload="onload_event();">
    <form id="reset_pw_form" method="post">
      <h1>
        <? if ($Language=="zh-hk") : ?>
          SME 密碼重置系統
        <? elseif ($Language=="en-gb") : ?>
          SME Password Reset System
        <? endif; ?>
      </h1>
      <div class="icon">
        <img src="change_password.png" width="170" height="170">
      </div>
      
      <? if($isVaild == 1) :?>
      <div class="formcontainer">
      <div class="container" id="form_elements">
        <label for="uname"><strong>
            <? if ($Language=="zh-hk") : ?>
              用戶帳號
            <? elseif ($Language=="en-gb") : ?>
              Username
            <? endif; ?>
        </strong></label>
        <input type="hidden" name="UID" value="<?php echo htmlentities($_GET['UID']) ?>"/>
        <input type="hidden" name="Lang" value="<?php echo htmlentities($_GET['Lang']) ?>"/>
        <input type="hidden" name="resetCode" value="<?php echo htmlentities($_GET['ResetCode']) ?>"/>
        <input type="hidden" name="ResetFromLink" value="1"/>
        <input type="text" placeholder="Enter Username" name="uname" value = "<?php echo htmlentities($Username) ?>" required readonly>
        <label for="psw"><strong>
            <? if ($Language=="zh-hk") : ?>
              新密碼
            <? elseif ($Language=="en-gb") : ?>
              New Password
            <? endif; ?>
        </strong></label>
        <input type="password" placeholder="<?php if ($Language=="zh-hk") {echo "請輸入新密碼";} else {echo "Enter New Password";} ?>" id="pwd" name="Password" required 
            oninvalid="this.setCustomValidity('<?php if ($Language=="zh-hk") {echo "請輸入新密碼";} else {echo "Enter New Password";} ?>')"
			oninput="register_pwd_change(this.value)">
        <? if ($Language=="zh-hk") : ?>
        <div id="pwdcheck">
		    <div style="font-size:13px;padding-top:5px;">密碼必須符合以下條件: </div>
			<ui style="font-size:11px;list-style-type:none;">
				<li id="pwdcheck_length" style="color:red;">&emsp;&emsp;密碼長度需介乎9~32字符</li>
				<li id="pwdcheck_uppercase" style="color:red;">&emsp;&emsp;必須含有大寫字母</li>
				<li id="pwdcheck_lowercase" style="color:red;">&emsp;&emsp;必須含有小寫字母</li>
				<li id="pwdcheck_sc" style="color:red;">&emsp;&emsp;必須含有至少一個括號內的特殊符號(* ! @ # &)</li>
			</ui>
		</div>
		<? elseif ($Language=="en-gb") : ?>
		<div id="pwdcheck">
		    <div style="font-size:13px;padding-top:5px;">The password must meet the following conditions: </div>
				<ui style="font-size:11px;list-style-type:none;">
					<li id="pwdcheck_length" style="color:red;">&emsp;&emsp;Password length must be between 9 and 32 characters</li>
					<li id="pwdcheck_uppercase" style="color:red;">&emsp;&emsp;Must contain uppercase letters</li>
					<li id="pwdcheck_lowercase" style="color:red;">&emsp;&emsp;Must contain lowercase letters</li>
					<li id="pwdcheck_sc" style="color:red;">&emsp;&emsp;Must contain at least one special symbol in parentheses(* ! @ # &)</li>
				</ui>
		</div>
		<? endif; ?>
		
		</br>
        <label for="psw-check"><strong>
            <? if ($Language=="zh-hk") : ?>
              再次輸入新密碼
            <? elseif ($Language=="en-gb") : ?>
              Enter your New Password Again
            <? endif; ?>
        </strong></label>
        <input type="password" placeholder="<?php if ($Language=="zh-hk") echo '請再次輸入新密碼'; else echo 'Enter New Password Again'; ?>" id="confirmpwd" name="confirmpwd" required	
            oninvalid="this.setCustomValidity('<?php if ($Language=="zh-hk") {echo "請再次輸入新密碼";} else {echo "Please Enter New Password Again";} ?>')"
			oninput="register_confirmpwd_change(this.value)">
        <div id="pwdcheck_confirm" style="font-size:13px;padding-top:5px;color:red;">&emsp;</div>
      </div>
      <button type="submit" id="reset_submit"><strong>
            <? if ($Language=="zh-hk") : ?>
              重置
            <? elseif ($Language=="en-gb") : ?>
              Reset
            <? endif; ?>
      </strong></button>
    </form>
    <? elseif ($isVaild==0) : ?>
    <div id="Invaild_Msg">
        <strong>
            <? if ($Language=="zh-hk") : ?>
              此重置連結已失效<br>請於應用程式內重新發出重置密碼申請
            <? elseif ($Language=="en-gb") : ?>
              This reset link is no longer valid<br>Please reissue the password reset request in the app
            <? endif; ?>
        </strong>
    </div>
    <? endif; ?>
    
    <div id="Result_Msg_div">
        <p id="Result_Msg"></p>
    </div>
    
    
  </body>
<script>
jQuery.noConflict();
function onload_event(){
    document.getElementById("reset_submit").disabled = true;
}
function register_pwd_change(change){
    register_confirmpwd_change(document.getElementById("confirmpwd").value);
    var pwd_regex_length = /^.{9,32}$/g;
    var pwd_regex_lower= /^(?=.*[a-z]).{1,}$/g;
    var pwd_regex_upper= /^(?=.*[A-Z]).{1,}$/g;
    var pwd_regex_sc= /^(?=.*[*!@#&]).{1,}$/g;
    var pwd_vaildation_length = change.toString().match(pwd_regex_length);
    var pwd_vaildation_lower = change.toString().match(pwd_regex_lower);
    var pwd_vaildation_upper = change.toString().match(pwd_regex_upper);
    var pwd_vaildation_sc = change.toString().match(pwd_regex_sc);
    document.getElementById("pwd").setCustomValidity('');
    if (pwd_vaildation_length){
    	document.getElementById("pwdcheck_length").style.color = "#63B64A";
    } else {
    	document.getElementById("pwdcheck_length").style.color = "#FF0000";
    }
    if (pwd_vaildation_lower){
    	document.getElementById("pwdcheck_lowercase").style.color = "#63B64A";
    } else {
    	document.getElementById("pwdcheck_lowercase").style.color = "#FF0000";
    }
    if (pwd_vaildation_upper){
    	document.getElementById("pwdcheck_uppercase").style.color = "#63B64A";
    } else {
    	document.getElementById("pwdcheck_uppercase").style.color = "#FF0000";
    }
    if (pwd_vaildation_sc){
    	document.getElementById("pwdcheck_sc").style.color = "#63B64A";
    } else {
    	document.getElementById("pwdcheck_sc").style.color = "#FF0000";
    }
    if(pwd_vaildation_length&&pwd_vaildation_lower&&pwd_vaildation_upper&&pwd_vaildation_sc){
    	document.getElementById("confirmpwd").disabled = false;
    	register_pwd_vaild = true;
    } else {
    	document.getElementById("confirmpwd").disabled = true;
    	register_pwd_vaild = false;
    	<? if ($Language=="zh-hk") : ?>
    		document.getElementById("pwdcheck_confirm").innerHTML = "密碼未能符合所有條件，請重新輸入";
    	<? elseif ($Language=="en-gb") : ?>
    		document.getElementById("pwdcheck_confirm").innerHTML = "The password did not meet all the conditions, please re-enter";
    	<? endif; ?>
    }
    if(!change){
        document.getElementById("pwdcheck_confirm").innerHTML = "";
        document.getElementById("pwdcheck_confirm").style.color = "#FF0000";;
    }
}

function register_confirmpwd_change(change){
	var pwd = document.getElementById("pwd").value;
	if(pwd){
		<? if ($Language=="zh-hk") : ?>
			document.getElementById("pwdcheck_confirm").innerHTML = "請再次輸入與上欄相同的密碼";
		<? elseif ($Language=="en-gb") : ?>
			document.getElementById("pwdcheck_confirm").innerHTML = "Please enter the same password as above.";
		<? endif; ?>
		var confirmpwd = document.getElementById("confirmpwd").value;
		document.getElementById("confirmpwd").setCustomValidity('');
		if (pwd===confirmpwd){
			document.getElementById("pwdcheck_confirm").style.color = "#63B64A";
			<? if ($Language=="zh-hk") : ?>
				document.getElementById("pwdcheck_confirm").innerHTML = "密碼檢查已通過";
			<? elseif ($Language=="en-gb") : ?>
				document.getElementById("pwdcheck_confirm").innerHTML = "Password check passed.";
			<? endif; ?>
			document.getElementById("reset_submit").disabled = false;
		} else {
			document.getElementById("pwdcheck_confirm").style.color = "#FF0000";
			document.getElementById("reset_submit").disabled = true;
		}
	} else {
		document.getElementById("pwdcheck_confirm").style.color = "#FF0000";
	}
}


jQuery.fn.serializeObject = function()
{
    var o = {};
    var a = this.serializeArray();
    jQuery.each(a, function() {
        if (o[this.name] !== undefined) {
            if (!o[this.name].push) {
                o[this.name] = [o[this.name]];
            }
            o[this.name].push(this.value || '');
        } else {
            o[this.name] = this.value || '';
        }
    });
    return o;
};

jQuery('#reset_pw_form').submit(function () {
    var jsonText = JSON.stringify(jQuery('#reset_pw_form').serializeObject());
    
    jQuery.ajax({
      type: "POST",
      url: "./change_password.php",
      data: jsonText,
      success: function(){
          <? if ($Language=="zh-hk") : ?>
          jQuery('#Result_Msg').html("密碼已成功重置<br>請使用新密碼登入應用程式");
          <? elseif ($Language=="en-gb") : ?>
          jQuery('#Result_Msg').html("The password has been successfully reset<br>Please use the new password to log in to the app");
          <? endif; ?>
          jQuery('#Result_Msg').css({ 'color': '#20A87D', 'font-size': '125%' });
          jQuery('#form_elements').hide();
          jQuery('#reset_submit').hide();
          jQuery('#Result_Msg_div').height("425px");
          jQuery('#Result_Msg_div').width("600px");
      },
      error: function(xhr, status, error) {
          /*
            alert("readyState: " + xhr.readyState);
            alert("responseText: "+ xhr.responseText);
            alert("status: " + xhr.status);
            alert("text status: " + textStatus);
            alert("error: " + err);
          */
          <? if ($Language=="zh-hk") : ?>
          jQuery('#Result_Msg').html("密碼未能重置<br>此重置連結或已失效<br>請於應用程式內重新發出重置密碼申請");
          <? elseif ($Language=="en-gb") : ?>
          jQuery('#Result_Msg').html("Password could not be reset<br>This reset link may have expired<br>Please re-issue a password reset request in the app");
          <? endif; ?>
          jQuery('#Result_Msg').css({ 'color': 'red', 'font-size': '125%' });
          jQuery('#form_elements').hide();
          jQuery('#reset_submit').hide();
          jQuery('#Result_Msg_div').height("425px");
          jQuery('#Result_Msg_div').width("600px");
      },
      dataType: "json",
      contentType : "application/json"
    });
    return false;
});
</script>
</html>
    
    