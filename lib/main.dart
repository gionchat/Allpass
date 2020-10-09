import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:device_info/device_info.dart';

import 'package:allpass/param/config.dart';
import 'package:allpass/param/param.dart';
import 'package:allpass/application.dart';
import 'package:allpass/ui/allpass_ui.dart';
import 'package:allpass/provider/card_provider.dart';
import 'package:allpass/provider/password_provider.dart';
import 'package:allpass/provider/theme_provider.dart';
import 'package:allpass/page/login/login_page.dart';
import 'package:allpass/page/login/auth_login_page.dart';
import 'package:allpass/service/allpass_service.dart';
import 'package:allpass/util/encrypt_util.dart';
import 'package:allpass/util/version_util.dart';
import 'package:allpass/model/api/allpass_response.dart';

bool needUpdateSecret = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 自定义报错页面
  _initErrorPage();

  try {
    await Application.initSp();
    await EncryptUtil.initEncrypt();
    Config.initConfig();
    Application.initRouter();
    Application.initLocator();
    Application.initChannelAndHandle();

    if (Platform.isAndroid) {
      //设置Android头部的导航栏透明
      var systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    }

    needUpdateSecret = !(Application.sp.getBool(SPKeys.firstRun) ?? true)
        && VersionUtil.twoIsNewerVersion(Application.sp.getString(SPKeys.allpassVersion) ?? "1.0.0", "1.5.0");

    _registerUser();

    final PasswordProvider passwords = PasswordProvider()
      ..init();
    final CardProvider cards = CardProvider()
      ..init();
    final ThemeProvider theme = ThemeProvider()
      ..init();
    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider<PasswordProvider>.value(
          value: passwords,
        ),
        ChangeNotifierProvider<CardProvider>.value(
          value: cards,
        ),
        ChangeNotifierProvider<ThemeProvider>.value(
            value: theme
        )
      ],
      child: Allpass(),
    ));
  } on Error catch (e) {
    runApp(InitialErrorPage(errorMsg: " ${e.runtimeType.toString()} \n ${e.toString()}\n ${e.stackTrace.toString()}"));
  }
}

class Allpass extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Allpass',
      theme: Provider.of<ThemeProvider>(context).lightTheme,
      darkTheme: Provider.of<ThemeProvider>(context).darkTheme,
      themeMode: Provider.of<ThemeProvider>(context).themeMode,
      home: Config.enabledBiometrics ? AuthLoginPage() : LoginPage(),
      onGenerateRoute: Application.router.generator,
    );
  }
}

class InitialErrorPage extends StatelessWidget {
  final String errorMsg;

  const InitialErrorPage({Key key, this.errorMsg}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Allpass",
      home: _InitialErrorPage(msg: errorMsg),
    );
  }
}

class _InitialErrorPage extends StatelessWidget {

  final String msg;

  const _InitialErrorPage({Key key, this.msg}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("软件初始化时出现了错误(灬ꈍ ꈍ灬)\n", style: TextStyle(color: Colors.red, fontSize: 20),),
            Text("错误信息：\n"),
            Text(msg)
          ],
        )
      ),
    );
  }
}

void _registerUser() async {
  Future<Null> registerUserActual() async {
    DeviceInfoPlugin infoPlugin = DeviceInfoPlugin();
    Map<String, String> user = Map();
    String identification;
    String systemInfo;
    if (Platform.isAndroid) {
      AndroidDeviceInfo info = await infoPlugin.androidInfo;
      identification = info.androidId;
      systemInfo = "${info.model} android${info.version.release}";
    } else if (Platform.isIOS) {
      IosDeviceInfo info = await infoPlugin.iosInfo;
      identification = info.identifierForVendor;
      systemInfo = "${info.model} IOS${info.systemVersion}";
    } else {
      return;
    }
    try {
      user['identification'] = identification;
      user['systemInfo'] = systemInfo;
      user['allpassVersion'] = Application.version;
      AllpassResponse response = await Application.getIt<AllpassService>().registerUser(user);
      if (response.success) {
        Application.sp.setBool(SPKeys.needRegister, false);
      } else {
        Application.sp.setBool(SPKeys.needRegister, true);
      }
    } catch (e) {
      debugPrint("用户注册失败：${e.toString()}");
    }
  }
  if (Application.sp.getBool(SPKeys.needRegister)??true) {
    await registerUserActual();
  } else {
    if (!((Application.sp.getString(SPKeys.allpassVersion)??"1.0.0") == Application.version)) {
      await registerUserActual();
      Application.sp.setString(SPKeys.allpassVersion, Application.version);
    }
  }
}

void _initErrorPage() {
  ErrorWidget.builder = (FlutterErrorDetails flutterErrorDetails) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "出错了",
          style: AllpassTextUI.titleBarStyle,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              child: Text("App出现错误，快去反馈给作者!"),
              padding: AllpassEdgeInsets.smallTBPadding,
            ),
            Padding(
              padding: AllpassEdgeInsets.smallTBPadding,
            ),
            Padding(
              child: Text("以下是出错信息，请截图发到邮箱sys6511@126.com"),
              padding: AllpassEdgeInsets.smallTBPadding,
            ),
            Padding(
              child: Text(flutterErrorDetails.toString(), style: TextStyle(color: Colors.red),),
              padding: AllpassEdgeInsets.smallTBPadding,
            ),
          ],
        ),
      ),
    );
  };
}