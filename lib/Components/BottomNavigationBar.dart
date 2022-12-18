import 'package:flutter/material.dart';
import 'package:smeapp/Components/HomePage.dart';
import '../Helper/ComponentsList.dart';
import '../Helper/global_setting.dart' as globals;
import 'package:smeapp/Helper/Localizations.dart';

class BottomBarWidget extends StatefulWidget {
  BottomBarWidget({Key key}) : super(key: key);
  @override
  BottomBarWidgetState createState() => BottomBarWidgetState();
}

class BottomBarWidgetState extends State<BottomBarWidget> {
  //Widget BottomBar;
  Widget CenterPage;
  BottomBarWidgetState(){
    globals.state_BottomBar = this;
  }

  void setPageIndex(int index){
    setState(() {
      globals.PageIndex = index;
    });
  }

  _recommendNotificationOn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getInt(Pref_NotificationPermission) != 1) {
      showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog_Selection(
          dialog_type: dialog_Status.Custom,
          image: notification_Icon,
          title: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.NotificationPermission_Recommend],
          description: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.NotificationPermission_RecommendDescription],
          buttonText_Confirm: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.NotificationPermission_Recommend_ToSetting],
          callback_Confirm: () async =>
          {
            Navigator.of(context).pop(),
            setState(() {
              globals.PageIndex = 2;
            })
          },
          callback_Cancel: () => {
            Navigator.of(context).pop(),
          },
          leftbtn_flex: 7,
          rightbtn_flex: 4,
        )
      );
    }
  }

  @override
  void initState() {
    if(!globals.isFirstRun) {
      _recommendNotificationOn();
      globals.isFirstRun = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    var screen_size = MediaQuery.of(context).size;

    //List pages_before_login = [SignUpPage(), LoginPage(), SettingPage()];

    List<Widget> _buildScreens;
    List<GButton> _buttons;

    if(globals.isLoggedIn) {
      _buildScreens = [ProfilesPage(), HomePage(), SettingPage()];
      _buttons = [
        GButton(
          icon: Icons.account_box,
          text: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.ProfilesLabelText],
          textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: globals.fontSize_Middle
          )
        ),
        GButton(
            icon: Icons.home,
            text: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.HomePageText],
            textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: globals.fontSize_Middle
            )
        ),
        GButton(
            icon: Icons.settings,
            text: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.settingButtonText],
            textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: globals.fontSize_Middle
            )
        ),
      ];
      CenterPage = _buildScreens[globals.PageIndex];
      if(globals.PageIndex == 1){

      }
    } else {
      _buildScreens = [SignUpPage(),LoginPage(), SettingPage()];
      _buttons = [
        GButton(
            icon: Icons.person_add,
            text: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.signupButtonText],
            textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: globals.fontSize_Middle
            )
        ),
        GButton(
            icon: Icons.system_update_alt,
            text: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.loginButtonText],
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
                fontSize: globals.fontSize_Middle
            )
        ),
        GButton(
            icon: Icons.settings,
            text: Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.settingButtonText],
            textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: globals.fontSize_Middle
            )
        ),
      ];
      CenterPage = _buildScreens[globals.PageIndex];
    }

    var BottomBar_New = SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0),
        child: GNav(
          rippleColor: Colors.white.withOpacity(0.1), // tab button ripple color when pressed
          hoverColor: Colors.white.withOpacity(0.1), // tab button hover color
          haptic: true, // haptic feedback
          tabBorderRadius: 30,
          tabActiveBorder: Border.all(color: appDarkGreyColor, width: 1), // tab button border
          //tabBorder: Border.all(color: Colors.grey, width: 1), // tab button border
          curve: Curves.easeInOutQuart, // tab animation curves
          duration: Duration(milliseconds: 350), // tab animation duration
          gap: 15, // the tab button gap between icon and text
          color: appDarkGreyColor, // unselected icon color
          activeColor: appTitleBarColor, // selected icon and text color
          iconSize: screen_size.height / 35, // tab button icon size
          tabBackgroundColor: Colors.white.withOpacity(0.1), // selected tab background color
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10), // navigation bar padding
          tabs: _buttons,
          selectedIndex: globals.PageIndex,
          mainAxisAlignment: MainAxisAlignment.center,
          tabMargin: EdgeInsets.fromLTRB(10, 0, 10, 0),
          onTabChange: (index) {
            setState(() {
              globals.PageIndex = index;
            });
          },
        ),
      ),
    );

    return Scaffold(
      body: Center(
          child: CenterPage
      ),
      bottomNavigationBar: !globals.visible_Loading ? SizedBox(height: screen_size.height / 8, child: BottomBar_New,) :
      Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                child: CircularProgressIndicator(),
                width: 100,
                height: 100,
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: AutoSizeText(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.loadingText],
                    maxLines: 1, minFontSize: minFontSize, maxFontSize: maxFontSize),
              )
            ],
          )
      ),
      resizeToAvoidBottomInset: false,
    );

  }

}
