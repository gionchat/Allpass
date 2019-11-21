import 'package:allpass/bean/password_bean.dart';
import 'package:allpass/bean/card_bean.dart';

/// 密码测试数据
class PasswordTestData {

  static List<PasswordBean> passwordList = List();

  PasswordTestData() {
    if (passwordList.length == 0) {
      passwordList.add(
          PasswordBean(1, "sys6511@126.com", "1234", "https://www.weibo.com"));
      passwordList.add(
          PasswordBean(2, "sys6511@126.com", "12345", "https://www.zhihu.com"));
      passwordList.add(PasswordBean(
          3, "sys6511@126.com", "31238912", "https://www.126.com"));
      passwordList.add(PasswordBean(
          4, "sunyongsheng6511@gmail.com", "joi123123", "https://www.gmail.com"));
      passwordList.add(
          PasswordBean(5, "sys6511@126.com", "1234", "https://www.weibo.com"));
      passwordList.add(
          PasswordBean(6, "sys6511@126.com", "1234", "https://www.weibo.com"));
      passwordList.add(
          PasswordBean(7, "sys6511@126.com", "1234", "https://www.weibo.com"));
      passwordList.add(
          PasswordBean(8, "sys6511@126.com", "1234", "https://www.weibo.com"));
      passwordList.add(
          PasswordBean(9, "sys6511@126.com", "1234", "https://www.weibo.com"));
      passwordList.add(
          PasswordBean(10, "sys6511@126.com", "1234", "https://www.weibo.com"));
    }

  }

}

/// 卡片测试数据
class CardTestData {

  static List<CardBean> cardList = List();

  CardTestData() {
    if (cardList.length == 0) {
      cardList..add(
          CardBean(1, "Aengus", "1233455214123123", name: "Aengus的身份证"))..add(
          CardBean(2, "Joye", "12312312312312312", name: "Joyed的身份证"))..add(
          CardBean(3, "Jike", "123146452132446748", name: "工商银行"));
    }
  }
}