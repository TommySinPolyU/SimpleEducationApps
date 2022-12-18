import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:smeapp/Components/CourseCreator/CourseEditor.dart';

import '../../main.dart';

import '../../Helper/ComponentsList.dart';
import 'package:http/http.dart' as http;
import '../../Helper/global_setting.dart' as globals;
import 'package:intl/intl.dart';
import 'package:smeapp/Helper/Localizations.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebBrowser extends StatefulWidget {
  WebBrowser_State createState() => WebBrowser_State();
}

class WebBrowser_State extends State {
  // Dialog Information
  dialog_Status _dialogStatus = dialog_Status.Error;
  String dialog_Msg = "", dialog_Msg_Title = "";

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    final Completer<WebViewController> _controller = Completer<WebViewController>();
    return Scaffold(
        backgroundColor: appBGColor,
        appBar: AppBar(
          backgroundColor: appTitleBarColor,
          centerTitle: true,
          title: Text(globals.browser_Title),
          //title: Text(Localizations_Text[globals.CurrentLang][Localizations_Text_Identifier.Survey_AppBarTitle]),
        ),
        body: WebView(
          initialUrl: globals.browser_url,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
          },
        )
    );
  }
}