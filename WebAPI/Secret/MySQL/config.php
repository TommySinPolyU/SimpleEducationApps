<?php
date_default_timezone_set("Asia/Hong_Kong"); // Change the php timezone to HK for insert the HK datetime to DB. 
define("DB_HOST", "localhost");
define("DB_NAME", "dbname");
define("DB_USER", "dbusername");
define("DB_PASS", "dbpass");

define("table_ac", "tb_useraccount"); // A table that contain a account info
define("table_userinfo", "tb_userprofiles"); // A table that contain a user info
define("table_userloginrecord", "tb_userloginoutrecords"); // A table that contain a user login/out records.
define("table_RegisterIpcheckRecord", "tb_registeripcheckrecord"); // A table that contain a ipchecker
define("table_ApplicationSetting", "tb_applicationsetting");
define("table_GroupPermission", "tb_usergrouppermission");
define("table_Materials", "tb_materials");
define("table_Courses", "tb_courses");
define("table_Units", "tb_courseunits");
define("table_Survey", "tb_survey");
define("table_Course_Progress", "tb_courses_progress");
define("table_Unit_Progress", "tb_units_progress");
define("table_Module_Progress", "tb_materials_progress");
define("table_Attachment", "tb_materials_attachment");
define("table_AttachmentChecker", "tb_att_checker");
define("table_CourseAccessible", "tb_course_accessible");
define("table_SubGroups", "tb_subgrouplist");
define("table_UserSubGroups", "tb_usersubgroups");
define("table_MailingInquiry", "tb_mailinginquiry");
define("table_SurveyAccessible", "tb_survey_accessible");
define("table_ResetPWRecords", "tb_reset_pw_records");
define("table_InvitationCodes", "tb_invitation_codes");
define("table_InvitationRecords", "tb_Invitation_codes_records");
define("table_ValidationRequest", "tb_validation_records");

try{
   $conn = new PDO('mysql:host='.DB_HOST.';'.'dbname='.DB_NAME.';'.'charset=utf8', DB_USER,DB_PASS);
} catch (PDOException $e) {
   print "Error!: " . $e->getMessage() . "<br/>";
   die();
}
// set the PDO error mode to exception
$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
?>
