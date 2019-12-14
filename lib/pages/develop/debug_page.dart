import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:allpass/dao/password_dao.dart';
import 'package:allpass/dao/card_dao.dart';
import 'package:allpass/application.dart';
import 'package:allpass/utils/encrypt_helper.dart';

/// 调试页
class DebugPage extends StatefulWidget {
  @override
  _DebugPage createState() {
    return _DebugPage();
  }

}

class _DebugPage extends State<DebugPage> {

  final PasswordDao _passwordDao = PasswordDao();
  final CardDao _cardDao = CardDao();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("DEBUG MODE"),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ListTile(
              title: FlatButton(
                child: Text("删除所有密码记录"),
                onPressed: () async {
                  await _passwordDao.deleteContent();
                  Fluttertoast.showToast(msg: "已删除所有密码");
                },
              ),
            ),
            ListTile(
              title: FlatButton(
                child: Text("删除所有卡片记录"),
                onPressed: () async {
                  await _cardDao.deleteContent();
                  Fluttertoast.showToast(msg: "已删除所有卡片");
                },
              ),
            ),
            ListTile(
              title: FlatButton(
                child: Text("删除密码数据库"),
                onPressed: () async {
                  await _passwordDao.deleteTable();
                  Fluttertoast.showToast(msg: "已删除密码数据库");
                },
              ),
            ),
            ListTile(
              title: FlatButton(
                child: Text("删除卡片数据库"),
                onPressed: () async {
                  await _cardDao.deleteTable();
                  Fluttertoast.showToast(msg: "已删除卡片数据库");
                },
              ),
            ),
            ListTile(
              title: FlatButton(
                child: Text("查看主密码"),
                onPressed: () async {
                  String _pass = await EncryptHelper.decrypt(Application.sp.getString("password"));
                  Fluttertoast.showToast(msg: "$_pass");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}