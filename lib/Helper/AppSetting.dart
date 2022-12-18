import 'package:encrypt/encrypt.dart' as encryption;
import 'package:smeapp/Helper/ComponentsList.dart';
// Application Verifier Setting
const Application_Identifier_Code = "Zq4t7w!z%C*F-JaNdRgUkXp2r5u8x/A?"; // No Need To Change This Code!!
const Application_Version = "V1.4.1 Public"; // Change This Version Code to match the DB Setting Before Upload To Appstore
//const Application_Version = "V1.1.0 Local Testing";

// Encryption Setting
final encryption_Key = encryption.Key.fromUtf8(Application_Identifier_Code);
final encryption_Tools = encryption.Encrypter(encryption.AES(encryption_Key));

// Files Uploader Setting
const fileSizeLimitInBytes = 4194304; // 4MB
const fileTotalNumberLimit = 5;

// WebServer Connection Setting
const Connection_Timeout_TimeLimit = 30;
const Server_Protocol = 'https://'; // Change to https for online, http for local test.

//const Server_Host = '192.168.1.101'; //Local
//const Server_Root_URL =  Server_Protocol + Server_Host + '/';// + 'SME/';

const Server_Host = 'sme.dsgshk.com'; // Internet
const Server_Root_URL = Server_Protocol + Server_Host + '/';// + 'SME/';

const Application_Root_URL = Server_Root_URL + 'Application/v1/';
const Account_Root_URL = Server_Root_URL + 'Account/v1/';
const Getter_Root_URL = Server_Root_URL + 'Getter/v1/';
const PrivacyPolicy_URL = Server_Root_URL + 'privacy_policy.php?Lang=LangCode';
const UserPolicy_URL = Server_Root_URL + 'user_terms.php?Lang=LangCode';

const Register_URL = Account_Root_URL+'register.php';
const Login_URL = Account_Root_URL+'login.php';
const Logout_URL = Account_Root_URL+'logout.php';
const CheckToken_URL = Account_Root_URL+'check_token.php';
const ChangePassword_URL = Account_Root_URL+'change_password.php';
const ChangeEmail_URL = Account_Root_URL+'change_email.php';
const ResetPassword_URL = Account_Root_URL+'send_resetpw_request.php';
const SendEmailValidation_URL = Account_Root_URL+'send_validation_request.php';

const Get_ProfilesData_URL = Getter_Root_URL + 'get_profiles.php';
const Get_CoursesData_URL = Getter_Root_URL + 'get_course.php';
const Get_CourseUnitData_URL = Getter_Root_URL + 'get_courseunits.php';
const Get_MaterialsData_URL = Getter_Root_URL + 'get_materials.php';
const Get_MaterialsFolder_URL = Getter_Root_URL + 'get_materialfolder.php';
const Get_SurveyData_URL = Getter_Root_URL + 'get_survey.php';
const Get_GroupsData_URL = Getter_Root_URL + 'get_groups.php';
const Get_UsersData_URL = Getter_Root_URL + 'get_users.php';

const Verifier_URL = Application_Root_URL + 'appverifier.php';
const Upload_URL = Application_Root_URL+'files_uploader.php';

const InsertMaterial_URL = Application_Root_URL+'insert_materials.php';
const InsertCourse_URL = Application_Root_URL+'insert_course.php';
const InsertCourseUnit_URL = Application_Root_URL+'insert_courseunit.php';
const InsertSurvey_URL = Application_Root_URL+'insert_survey.php';
const InsertUserGroup_URL = Application_Root_URL+'insert_group.php';

const UpdateMaterial_URL = Application_Root_URL+'update_materials.php';
const UpdateCourse_URL = Application_Root_URL+'update_course.php';
const UpdateCourseUnit_URL = Application_Root_URL+'update_courseunit.php';
const UpdateSurvey_URL = Application_Root_URL+'update_survey.php';
const UpdateProgress_URL = Application_Root_URL+'update_progress.php';
const UpdateGroupUsers_URL = Application_Root_URL+'update_groupusers.php';

const DeleteCourse_URL = Application_Root_URL+'delete_course.php';
const DeleteCourseUnit_URL = Application_Root_URL+'delete_courseunit.php';
const DeleteMaterial_URL = Application_Root_URL+'delete_material.php';
const DeleteSurvey_URL = Application_Root_URL+'delete_survey.php';
const DeleteGroup_URL = Application_Root_URL+'delete_group.php';

const SendEmailToResearchers_URL = Application_Root_URL + 'send_email_researchers.php';

