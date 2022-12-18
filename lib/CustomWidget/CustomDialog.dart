import 'package:flutter/material.dart';
import 'package:smeapp/Components/Survey/WebBrowser.dart';
import '../Helper/ComponentsList.dart';
import '../Helper/global_setting.dart' as globals;
import 'package:smeapp/Helper/Localizations.dart';

/*
================================================================================================
Custom Dialog Widget:
Stable Version (20200909V1)
================================================================================================
Two Class:
  - CustomDialog_Confirm
    Description: A Dialog provides one confirm button with default close dialog function only
    Six Variables:
      - Title: Dialog Title, which is display at top middle and below the Image.
      - Description (Required): Dialog Description / Details / Explanation, which is display below the Title.
      - ButtonText: Dialog Confirm Button Text, which is display at bottom right of dialog.
      - Image: Dialog Image with Circle Border, which is display at Top of dialog and above the Title
      - Dialog_type (Required): Dialog Type, Some Types have preset constant values.
      - showButton: show dialog button when it is true, otherwise, the button will not display.

  - CustomDialog_Selection
    Description: A Dialog provides two selection buttons, These buttons can apply their own custom function.
    Eight Variables:
      - Title: Dialog Title, which is display at top middle and below the Image.
      - Description (Required): Dialog Description / Details / Explanation, which is display below the Title.
      - ButtonText_Confirm: Dialog Confirm Button Text, which is display at bottom left of dialog.
      - ButtonText_Cancel: Dialog Cancel Button Text, which is display at bottom right of dialog.
      - Callback_Confirm (Required): Confirm Function.
      - Callback_Cancel: Cancel Function, If it is null, it will be replace by default pop function (Navigator.of(context).pop())
      - Dialog_Type (Required): Dialog Type, Some Types have preset constant values.
      - Image: Dialog Image with Circle Border, which is display at Top of dialog and above the Title

Five Types:
  - Success
  - Error
  - Warning
  - Loading
    The above types have preset constant values, including Image, Title and Button Text.
  - Custom
    Custom type have not preset values, Users should set all variables by themselves,
    if some values have not set yet, these values will be display by NULL.
================================================================================================
Examples:
  CustomDialog_Confirm:
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => CustomDialog_Confirm(
        dialog_type: dialog_Status.Success,
        description: dialog_Msg,
        title: dialog_Msg_Title, // Optional
        buttonText: dialog_ButtonText, // Optional
        image: dialog_image, // Optional
      ),
    )

    Custom Type:
      showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => CustomDialog_Confirm(
        dialog_type: dialog_Status.Custom,
        title: dialog_Msg_Title,
        description: dialog_Msg,
        buttonText: dialog_ButtonText,
        image: dialog_image,
      ),
    )

================================================================================================
  CustomDialog_Selection:
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) => CustomDialog_Selection(
      dialog_type: dialog_Status.Success,
      description: dialog_Msg,
      callback_Confirm: () => {},
      title: dialog_Msg_Title, // Optional
      buttonText_Confirm: dialog_Confirm_ButtonText, // Optional
      buttonText_Cancel: dialog_Cancel_ButtonText, // Optional
      callback_Cancel: () => {}, // Optional
      image: dialog_image, // Optional
    ),
  )

  Custom Type:
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => CustomDialog_Selection(
        dialog_type: dialog_Status.Custom,
        title: dialog_Msg_Title,
        description: dialog_Msg,
        buttonText_Confirm: dialog_Confirm_ButtonText,
        buttonText_Cancel: dialog_Cancel_ButtonText,
        callback_Confirm: () => {},
        callback_Cancel: () => {},
        image: dialog_image,
      ),
    )
*/

enum dialog_Status{
  Success,
  Error,
  Warning,
  Loading,
  Custom
}

class Consts {
  Consts._();

  static const double padding = 16.0;
  static const double avatarRadius = 30.0;
}

class CustomDialog_Confirm extends StatelessWidget {
  String title, description, buttonText;
  bool showButton, desc_to_widget;
  Widget image, desc_widget;
  dialog_Status dialog_type;
  VoidCallback callback_Confirm;

  CustomDialog_Confirm({
    this.title,
    @required this.description,
    this.buttonText,
    @required this.dialog_type,
    this.image,
    this.callback_Confirm,
    this.showButton,
    this.desc_to_widget,
    this.desc_widget
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    if(callback_Confirm == null) callback_Confirm = () => {Navigator.of(context).pop()};
    if(showButton == null) showButton = true;
    if(buttonText == null) buttonText = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Confirm];
    if(desc_to_widget == null) desc_to_widget = false;
    switch(dialog_type){
      case dialog_Status.Success:
        title = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Tips_Success];
        image = tips_success_Icon;
        break;
      case dialog_Status.Warning:
        title = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Tips_Warning];
        image = tips_warning_Icon;
        break;
      case dialog_Status.Error:
        title = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Tips_Error];
        image = tips_error_Icon;
        break;
      case dialog_Status.Loading:
        if(title == null) title = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.LoadingTitle];
        image = CircularProgressIndicator();
        break;
      case dialog_Status.Custom:

        break;
    }
    return WillPopScope(
      onWillPop: () {},
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              top: Consts.avatarRadius + Consts.padding,
              bottom: Consts.padding,
              left: Consts.padding,
              right: Consts.padding,
            ),
            margin: EdgeInsets.only(top: Consts.avatarRadius),
            decoration: new BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(Consts.padding),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: const Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // To make the card compact
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: globals.fontSize_Big,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  constraints: new BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height - 400,
                    minHeight: 40
                  ),
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: <Widget>[
                      !desc_to_widget ?
                      Linkify(
                        onOpen: (link) => {
                          globals.browser_url = link.url,
                          Navigator.of(context).push(globals.gotoPage(WebBrowser(), Duration(seconds: 0, milliseconds: 500))),
                        },
                        text: description, textAlign: TextAlign.left, style: TextStyle(fontSize: globals.fontSize_Normal),
                      )
                          : desc_widget
                    ],
                  ),
                ),
                Visibility(
                    visible: showButton,
                    child: SizedBox(height: 16.0)
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Visibility(
                    visible: showButton,
                    child: FlatButton(
                      onPressed: callback_Confirm,
                      child: Text(buttonText, style: TextStyle(fontSize: globals.fontSize_Middle)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: Consts.padding,
            right: Consts.padding,
            child: CircleAvatar(
              radius: Consts.avatarRadius,
              child: ClipOval(
                child: image,
              ),
              backgroundColor: appBGColor,
            ),
          ),
        ],
      ),
    );
  }

}

class CustomDialog_Selection extends StatelessWidget {
  String title, description, buttonText_Confirm, buttonText_Cancel;
  bool showButton, desc_to_widget;
  Widget image;
  Widget desc_widget;
  VoidCallback callback_Confirm;
  VoidCallback callback_Cancel;
  dialog_Status dialog_type;
  int leftbtn_flex, rightbtn_flex;

  CustomDialog_Selection({
    this.title,
    @required this.description,
    this.buttonText_Confirm,
    this.buttonText_Cancel,
    @required this.callback_Confirm,
    this.callback_Cancel,
    @required this.dialog_type,
    this.image,
    this.desc_to_widget,
    this.desc_widget,
    this.leftbtn_flex,
    this.rightbtn_flex
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    if(callback_Cancel == null) callback_Cancel = () => {Navigator.of(context).pop()};
    if(buttonText_Confirm == null) buttonText_Confirm = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Confirm];
    if(buttonText_Cancel == null) buttonText_Cancel = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Cancel];
    if(desc_to_widget == null) desc_to_widget = false;
    if(leftbtn_flex == null) leftbtn_flex = 5;
    if(rightbtn_flex == null) rightbtn_flex = 5;
    switch(dialog_type){
      case dialog_Status.Success:
        title = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Tips_Success];
        image = tips_success_Icon;
        break;
      case dialog_Status.Warning:
        title = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Tips_Warning];
        image = tips_warning_Icon;
        break;
      case dialog_Status.Error:
        title = Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Tips_Error];
        image = tips_error_Icon;
        break;
      case dialog_Status.Custom:

        break;
    }
    return WillPopScope(
      onWillPop: () {},
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              top: Consts.avatarRadius + Consts.padding,
              bottom: Consts.padding,
              left: Consts.padding,
              right: Consts.padding,
            ),
            margin: EdgeInsets.only(top: Consts.avatarRadius),
            decoration: new BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(Consts.padding),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: const Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // To make the card compact
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: globals.fontSize_Big,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  constraints: new BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height - 400,
                      minHeight: 40
                  ),
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: <Widget>[
                      !desc_to_widget ?
                      Linkify(
                        onOpen: (link) => {
                          globals.browser_url = link.url,
                          Navigator.of(context).push(globals.gotoPage(WebBrowser(), Duration(seconds: 0, milliseconds: 500))),
                        },
                        text: description, textAlign: TextAlign.left, style: TextStyle(fontSize: globals.fontSize_Normal),)
                          : desc_widget
                    ],
                  ),
                ),
                SizedBox(height: 24.0),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: leftbtn_flex,
                          child: FlatButton(
                            child: Text(buttonText_Confirm, style: TextStyle(fontSize: globals.fontSize_Middle),),
                            onPressed: callback_Confirm,
                          ),
                        ),
                        Expanded(
                          flex: rightbtn_flex,
                          child: FlatButton(
                            child: Text(buttonText_Cancel, style: TextStyle(fontSize: globals.fontSize_Middle)),
                            onPressed: callback_Cancel,
                          ),
                        )
                      ],
                    )
                ),
              ],
            ),
          ),
          Positioned(
            left: Consts.padding,
            right: Consts.padding,
            child: CircleAvatar(
              radius: Consts.avatarRadius,
              child: ClipOval(
                child: image,
              ),
              backgroundColor: appBGColor,
            ),
          ),
        ],
      ),
    );
  }
}