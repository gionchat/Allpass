import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:allpass/core/param/runtime_data.dart';
import 'package:allpass/core/param/allpass_type.dart';
import 'package:allpass/common/ui/allpass_ui.dart';
import 'package:allpass/setting/category/widget/add_category_dialog.dart';
import 'package:allpass/setting/category/widget/edit_category_dialog.dart';
import 'package:allpass/common/widget/confirm_dialog.dart';
import 'package:allpass/card/data/card_provider.dart';
import 'package:allpass/password/data/password_provider.dart';

const String defaultFolderName = "默认";

/// 属性管理页
/// 通过指定[type]来指定属性页的名称，属性页中是[ListView]
/// 点击每一个[ListTile]弹出模态菜单，菜单中有编辑与删除选项
class CategoryManagerPage extends StatefulWidget {

  final CategoryType type;

  CategoryManagerPage(this.type);

  @override
  State<StatefulWidget> createState() {
    return _CategoryManagerPage();
  }
}

class _CategoryManagerPage extends State<CategoryManagerPage> {

  CategoryType type;
  String categoryName;
  List<String> data;

  @override
  void initState() {
    super.initState();
    this.type = widget.type;
    categoryName = Category.getCategoryName(type);
    data = _getCategoryData(type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$categoryName管理", style: AllpassTextUI.titleBarStyle,),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ReorderableListView(
              children: _getAllWidget(),
              onReorder: (int oldIndex, int newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                setState(() {
                  var child = data.removeAt(oldIndex);
                  data.insert(newIndex, child);
                });
                if (this.type == CategoryType.Label) {
                  RuntimeData.labelParamsPersistence();
                } else {
                  RuntimeData.folderParamsPersistence();
                }
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "add$categoryName",
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AddCategoryDialog(type: this.type)
          ).then((value) {
            if (value != null) {
              if (this.type == CategoryType.Folder && RuntimeData.folderListAdd(value)) {
                Fluttertoast.showToast(msg: "添加$categoryName $value 成功");
              } else if (this.type == CategoryType.Label && RuntimeData.labelListAdd([value])) {
                Fluttertoast.showToast(msg: "添加$categoryName $value 成功");
              } else {
                Fluttertoast.showToast(msg: "$categoryName $value 已存在");
              }
            }
          });
        },
      ),
    );
  }

  List<Widget> _getAllWidget() {
    List<Widget> widgets = List();
    for (int currIndex = 0; currIndex < data.length; currIndex++) {
      String currCategoryName = data[currIndex];
      widgets.add(Container(
        key: ValueKey(data[currIndex]),
        child: ListTile(
          // TODO 增加trailing属性显示有多少个密码账号含有此标签
          title: Text(currCategoryName, overflow: TextOverflow.ellipsis,),
          leading: Icon(Icons.list, color: Colors.grey,),
          onTap: () {
            if (this.type == CategoryType.Folder && currCategoryName == defaultFolderName) {
              Fluttertoast.showToast(msg: "此文件夹不允许修改！");
              return;
            }
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      padding: AllpassEdgeInsets.listInset,
                      child: ListTile(
                        title: Text("编辑$categoryName"),
                        leading: Icon(Icons.edit_attributes, color: Colors.blue,),
                        onTap: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => EditCategoryDialog(widget.type, data[currIndex])
                          ).then((value) async {
                            if (value != null) {
                              if (this.type == CategoryType.Label) {
                                if (RuntimeData.labelList.contains(value)) {
                                  Fluttertoast.showToast(msg: "$categoryName $value 已存在");
                                  return;
                                }
                                await editLabelAndUpdate(currIndex, value);
                              } else if (this.type == CategoryType.Folder){
                                if (RuntimeData.folderList.contains(value)) {
                                  Fluttertoast.showToast(msg: "$categoryName $value 已存在");
                                  return;
                                }
                                await editFolderAndUpdate(currIndex, value);
                              }
                              Fluttertoast.showToast(msg: "保存$categoryName $value");
                            }
                          });
                        },
                      ),
                    ),
                    Container(
                      padding: AllpassEdgeInsets.listInset,
                      child: ListTile(
                        title: Text("删除$categoryName"),
                        leading: Icon(Icons.delete, color: Colors.red,),
                        onTap: () async {
                          String hintText = "";
                          Future<Null> Function() deleteCallback;
                          if (this.type == CategoryType.Label) {
                            hintText = "拥有此标签的密码或卡片将删除此标签，确认吗？";
                            deleteCallback = () async {
                              await deleteLabelAndUpdate(currCategoryName);
                            };
                          } else if (this.type == CategoryType.Folder) {
                            hintText = "此操作将会移动此文件夹下的所有密码及卡片到‘默认’文件夹中，确认吗？";
                            deleteCallback = () async {
                              await deleteFolderAndUpdate(currCategoryName);
                            };
                          }
                          Navigator.pop(context);
                          bool res = await showDialog(
                              context: context,
                              builder: (context) => ConfirmDialog("确认删除", hintText)
                          );
                          if (res != null && res) {
                            await deleteCallback();
                          }
                        },
                      ),
                    )
                  ],
                );
              }
            );
          },
        ),
        padding: EdgeInsets.only(right: 20, left: 20),
      ));
    }
    return widgets;
  }

  Future<Null> editLabelAndUpdate(int index, String newLabel) async {
    String oldLabel = RuntimeData.labelList[index];
    setState(() {
      RuntimeData.labelList[index] = newLabel;
    });
    RuntimeData.labelParamsPersistence();
    
    for (var bean in Provider.of<PasswordProvider>(context).passwordList) {
      if (bean.label.contains(oldLabel)) {
        bean.label[bean.label.indexOf(oldLabel)] = newLabel;
        await Provider.of<PasswordProvider>(context).updatePassword(bean);
      }
    }
    for (var bean in Provider.of<CardProvider>(context).cardList) {
      if (bean.label.contains(oldLabel)) {
        bean.label[bean.label.indexOf(oldLabel)] = newLabel;
        await Provider.of<CardProvider>(context).updateCard(bean);
      }
    }
  }

  Future<Null> editFolderAndUpdate(int index, String newFolder) async {
    String oldFolder = RuntimeData.folderList[index];
    setState(() {
      RuntimeData.folderList[index] = newFolder;
    });
    RuntimeData.folderParamsPersistence();
    
    for (var bean in Provider.of<PasswordProvider>(context).passwordList) {
      if (bean.folder == oldFolder) {
        bean.folder = newFolder;
        await Provider.of<PasswordProvider>(context).updatePassword(bean);
      }
    }
    for (var bean in Provider.of<CardProvider>(context).cardList) {
      if (bean.folder == oldFolder) {
        bean.folder = newFolder;
        await Provider.of<CardProvider>(context).updateCard(bean);
      }
    }
  }

  Future<Null> deleteLabelAndUpdate(String label) async {
    setState(() {
      RuntimeData.labelList.remove(label);
    });
    RuntimeData.labelParamsPersistence();

    for (var bean in Provider.of<PasswordProvider>(context).passwordList) {
      if (bean.label.contains(label)) {
        bean.label.remove(label);
        Provider.of<PasswordProvider>(context).updatePassword(bean);
      }
    }
    for (var bean in Provider.of<CardProvider>(context).cardList) {
      if (bean.label.contains(label)) {
        bean.label.remove(label);
        Provider.of<CardProvider>(context).updateCard(bean);
      }
    }
  }

  Future<Null> deleteFolderAndUpdate(String folder) async {
    setState(() {
      RuntimeData.folderList.remove(folder);
    });
    RuntimeData.folderParamsPersistence();

    for (var bean in Provider.of<PasswordProvider>(context).passwordList) {
      if (folder == bean.folder) {
        bean.folder = defaultFolderName;
        Provider.of<PasswordProvider>(context).updatePassword(bean);
      }
    }
    for (var bean in Provider.of<CardProvider>(context).cardList) {
      if (folder == bean.folder) {
        bean.folder = defaultFolderName;
        Provider.of<CardProvider>(context).updateCard(bean);
      }
    }
  }

  List<String> _getCategoryData(CategoryType type) {
    if (type == CategoryType.Folder) {
      return RuntimeData.folderList;
    } else if (type == CategoryType.Label) {
      return RuntimeData.labelList;
    } else {
      return List();
    }
  }

}