import 'package:flutter/material.dart';

// Colors
Color appDarkGreyColor = Color.fromRGBO(58, 66, 86, 1.0);
Color appGreyColor = Color.fromRGBO(64, 75, 96, .9);
Color appBGColor = Color.fromRGBO(255, 255, 255, 1.0);
Color appPrimaryColor = Color.fromRGBO(0, 0, 0, 1.0);
Color appTitleBarColor = Colors.lightBlue;

// Sizes
const bigRadius = 66.0;
const buttonHeight = 24.0;
double minFontSize = 24;
double maxFontSize = 60;

// KeyStrings_SharedPreferences
const Setting_Language = "SettingLanguage";
const Pref_Profiles_Nickname = "Profiles_Nickname";
const Pref_Profiles_Firstname = "Profiles_Firstname";
const Pref_Profiles_Lastname = "Profiles_Lastname";
const Pref_Profiles_Gender = "Profiles_Gender";
const Pref_Profiles_Email = "Profiles_Email";
const Pref_Profiles_UID = "Profiles_UID";
const Pref_User_RegisCode= "RegisCode";
const Pref_User_SaltedPassword= "SaltedPassword";
const Pref_User_UserName = "Logged_In_Username";
const Pref_AutoLogin= "isAutoLogin";
const Pref_FontSize= "fontSizeSet";
const Pref_NotificationPermission= "NotificationPermission";
const Pref_DefaultFontSize= "DefaultFontSizeSet";
const Pref_SaveAccount= "isAccountSaved";
const Pref_isFirstTimeRun= "isFirstTimeRun";

// Images
Image appLogo = Image.asset('assets/images/app_icon.png');
Image tips_error_Icon = Image.asset('assets/images/dialog_cross.png', width: 60, height: 60);
Image tips_success_Icon = Image.asset('assets/images/dialog_tick.png', width: 60, height: 60);
Image tips_warning_Icon = Image.asset('assets/images/dialog_warning.png', width: 60, height: 60);
Image doc_Icon = Image.asset('assets/images/doc-icon.png', width: 60, height: 60);
Image image_Icon = Image.asset('assets/images/image-icon.png', width: 60, height: 60,);
Image music_Icon = Image.asset('assets/images/music-icon.png', width: 60, height: 60);
Image pdf_Icon = Image.asset('assets/images/pdf-icon.png', width: 60, height: 60);
Image video_Icon = Image.asset('assets/images/video-icon.png', width: 60, height: 60);
Image url_Icon = Image.asset('assets/images/url-icon.png', width: 60, height: 60);
Image zip_Icon = Image.asset('assets/images/zip-icon.png', width: 60, height: 60);
Image course_Icon = Image.asset('assets/images/course_icon.png', width: 60, height: 60);
Image notification_Icon = Image.asset('assets/images/notification_icon.png', width: 60, height: 60);
Image add_notification_Icon = Image.asset('assets/images/add_reminder_icon.png', width: 24, height: 24);
Image usergroup_manager_Icon = Image.asset('assets/images/user_manager_icon.png', width: 60, height: 60);
Image technicalSupport_Icon = Image.asset('assets/images/support-icon.png', width: 60, height: 60);
Image survey_Icon = Image.asset('assets/images/survey-icon.png', width: 60, height: 60);
Image changePw_Icon = Image.asset('assets/images/change_password.png', width: 60, height: 60);
Image changeEmail_Icon = Image.asset('assets/images/change_email.png', width: 60, height: 60);
Image resetPw_Icon = Image.asset('assets/images/forgot_password.png', width: 45, height: 45, color: Colors.white,);