import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:page_transition/page_transition.dart';
import 'package:todo/main.dart';
import 'package:todo/database/db_helper.dart';
import 'package:todo/pages/setting_page.dart';
import 'package:todo/pages/task_list_view_page.dart';

class HomePage extends StatefulWidget {
  HomePage({required int index, Key? key}) : super(key: key) {
    if (!(index.isNegative)) {
      _HomePageState.index = index;
    }
  }

  Future showAboutDeveloper(context) {
    return showDialog(
        context: context,
        builder: (context) => Dialog(
              clipBehavior: Clip.none,
              child: Stack(
                children: [
                  Image.asset('assets/images/developer_image.png',
                      fit: BoxFit.cover),
                ],
              ),
            ));
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  _HomePageState() {
    widgetList = [];
    namesList = [];
    getListOfNames();
  }
  void getListOfNames() async {
    List<Widget> singleWidgetList = [];

    DBHelper instance = DBHelper.instance;
    namesList = await instance.queryAllForTableName();
    for (var element in namesList) {
      singleWidgetList.add(Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            element['tableName'],
            style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(
            height: 12.0,
            child: Divider(
              thickness: 2.0,
              color: Colors.white,
            ),
          ),
        ],
      ));
      //add
      var listOfMaps = await instance.queryAll(element['tableName']);
      for (var element1 in listOfMaps.reversed) {
        singleWidgetList.add(RichText(
          overflow: TextOverflow.clip,
          text: TextSpan(
              text: '• ',
              style:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                    text: element1['title'].toString().isNotEmpty
                        ? element1['title']
                        : 'No Title',
                    style: TextStyle(
                        fontSize: 16.0,
                        decoration: element1['isCompleted']
                                    .toString()
                                    .compareTo('true') ==
                                0
                            ? TextDecoration.lineThrough
                            : TextDecoration.none))
              ]),
        ));
      }
      widgetList.add(singleWidgetList);
      singleWidgetList = [];
    }
    setState(() {});
  }

  Color color = Colors.blue;

  static List<Map<String, dynamic>> namesList = [];
  static List<List<Widget>> widgetList = [];
  static int index = 0;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return WillPopScope(
      onWillPop: () => exit(0),
      child: Scaffold(
        appBar: AppBar(
            elevation: 0.0,
            automaticallyImplyLeading: false,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                onPressed: (() => HomePage(
                      index: index,
                    ).showAboutDeveloper(context)),
                icon: Image.asset(
                  'assets/images/creater_image.png',
                  height: 32.0,
                ),
              ),
            ),
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.of(context).push(PageTransition(
                        child: const SettingPage(),
                        type: PageTransitionType.theme,
                        childCurrent: widget,
                        duration: routAnimationDuration));
                  },
                  icon: const Icon(Icons.settings))
            ]),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        AnimatedTextKit(animatedTexts: [
                          TyperAnimatedText('TODO - The Task Keeper',
                              textStyle: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.red
                                      : Colors.white,
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold)),
                        ]),
                        Column(
                          children: [
                            const Divider(thickness: 2.0),
                            RichText(
                              text: TextSpan(
                                  text: 'Tasks ',
                                  style: textTheme.bodyLarge?.copyWith(
                                      fontSize: 28.0,
                                      fontWeight: FontWeight.bold),
                                  children: [
                                    TextSpan(
                                      text: 'List',
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontSize: 28.0,
                                      ),
                                    )
                                  ]),
                            ),
                            const Divider(
                              thickness: 2.0,
                            ),
                            const SizedBox(
                              height: 8.0,
                            )
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Center(
                              child: Container(
                                height: 50.0,
                                width: 50.0,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(12.0),
                                    ),
                                    border: Border.all(
                                        color: Theme.of(context).primaryColor),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          offset: const Offset(-8, -8),
                                          blurRadius: 15.0),
                                      BoxShadow(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          blurRadius: 15.0,
                                          spreadRadius: 2.0,
                                          offset: const Offset(8, 8))
                                    ]),
                                child: IconButton(
                                  onPressed: () async {
                                    var tableRecord =
                                        await showDialogToCreateList(
                                            purpose: 'Create',
                                            context: context,
                                            selectedColor: Colors.blue);
                                    if (tableRecord['tableName'] == 'null') {
                                      return;
                                    }
                                    DBHelper db = DBHelper.instance;
                                    await db
                                        .createTable(tableRecord['tableName']);
                                    await db.insertTableName(tableRecord).then(
                                        (value) => Navigator.push(
                                            context,
                                            PageTransition(
                                                child: HomePage(
                                                  index: index,
                                                ),
                                                type: PageTransitionType.theme,
                                                childCurrent: widget,
                                                duration:
                                                    routAnimationDuration)));
                                  },
                                  icon: const Icon(
                                    Icons.add,
                                    size: 30.0,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                            const Text(
                              'Add Lists',
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 2.5,
                    child: widgetList.isNotEmpty
                        ? Center(
                            child: Swiper(
                              onIndexChanged: (i) {
                                index = i;
                              },
                              loop: false,
                              itemCount: widgetList.length,
                              viewportFraction: 0.6,
                              scale: 0.7,
                              axisDirection: AxisDirection.left,
                              index: index,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (BuildContext context, itemIndex) {
                                return FocusedMenuHolder(
                                  menuWidth:
                                      MediaQuery.of(context).size.width / 2,
                                  animateMenuItems: false,
                                  duration: const Duration(seconds: 0),
                                  menuItems: [
                                    FocusedMenuItem(
                                        title: const Text(
                                          'Edit',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        trailingIcon: const Icon(
                                          Icons
                                              .drive_file_rename_outline_outlined,
                                          color: Colors.black,
                                        ),
                                        onPressed: () async {
                                          var tableRecord =
                                              await showDialogToCreateList(
                                                  purpose: 'Update',
                                                  context: context,
                                                  selectedColor: Color(
                                                      namesList.elementAt(
                                                          itemIndex)['color']));
                                          if (tableRecord['tableName'] !=
                                              'null') {
                                            DBHelper instance =
                                                DBHelper.instance;
                                            await instance.updateNamesTable(
                                                tableRecord,
                                                namesList
                                                    .elementAt(index)['id']);
                                            await instance
                                                .renameTable(
                                                    oldName:
                                                        namesList.elementAt(
                                                            index)['tableName'],
                                                    newName: tableRecord[
                                                        'tableName'])
                                                .then((value) => Navigator.push(
                                                    context,
                                                    PageTransition(
                                                        child: HomePage(
                                                          index: index,
                                                        ),
                                                        type: PageTransitionType
                                                            .theme,
                                                        childCurrent: widget,
                                                        duration:
                                                            routAnimationDuration)));
                                          }
                                        }),
                                    FocusedMenuItem(
                                        title: const Text(
                                          'Move To Start',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        trailingIcon: const Icon(
                                          Icons.arrow_back_ios_new_rounded,
                                          color: Colors.black,
                                        ),
                                        onPressed: () async {
                                          DBHelper instance = DBHelper.instance;
                                          var listName = await instance
                                              .queryAllForTableName();
                                          for (var element in listName) {
                                            await instance.deleteTableName(
                                                element['tableName']);
                                          }
                                          await instance.insertTableName(
                                              listName.elementAt(index));
                                          for (var element in listName) {
                                            if (!element.containsValue(
                                                listName.elementAt(
                                                    index)['tableName'])) {
                                              await instance.insertTableName({
                                                'tableName':
                                                    element['tableName'],
                                                'color': element['color'],
                                              });
                                            }
                                          }
                                          setState(() {
                                            Navigator.of(context).push(
                                                PageTransition(
                                                    child: HomePage(
                                                      index: index,
                                                    ),
                                                    type: PageTransitionType
                                                        .theme,
                                                    childCurrent: widget,
                                                    duration:
                                                        routAnimationDuration));
                                          });
                                        }),
                                    FocusedMenuItem(
                                        backgroundColor: Colors.red,
                                        title: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        trailingIcon: const Icon(
                                          Icons.delete_outline_outlined,
                                          color: Colors.white,
                                        ),
                                        onPressed: () async {
                                          DBHelper instance = DBHelper.instance;

                                          await instance.deleteTableName(
                                              namesList.elementAt(
                                                  index)['tableName']);
                                          await instance
                                              .deleteTable(namesList.elementAt(
                                                  index)['tableName'])
                                              .then((value) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              content: Text('List Deleted'),
                                            ));
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        HomePage(index: 0)));
                                          });
                                        }),
                                  ],
                                  onPressed: () => Navigator.push(
                                      context,
                                      PageTransition(
                                          child: TaskListViewPage(
                                            nameOfList: namesList
                                                .elementAt(index)['tableName'],
                                            // index: index,
                                          ),
                                          type: PageTransitionType.theme)),
                                  child: AnimatedContainer(
                                      duration: routAnimationDuration,
                                      curve: Curves.fastLinearToSlowEaseIn,
                                      padding: const EdgeInsets.all(18.0),
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(15.0)),
                                          color: Color(namesList
                                              .elementAt(itemIndex)['color']),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                                offset: const Offset(-8, -8),
                                                blurRadius: 15.0),
                                            BoxShadow(
                                                color: Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                                blurRadius: 15.0,
                                                spreadRadius: 2.0,
                                                offset: const Offset(8, 8))
                                          ]),
                                      child: SingleChildScrollView(
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: widgetList
                                                .elementAt(itemIndex)),
                                      )),
                                );
                              },
                            ),
                          )
                        : Center(
                            child: Text(
                            'No List Found',
                            style:
                                textTheme.subtitle2?.copyWith(fontSize: 16.0),
                          )),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> showDialogToCreateList(
      {required context, required purpose, required selectedColor}) async {
    Map<String, dynamic> tableRecord = {};
    TextEditingController newListNameController = TextEditingController();

    // ignore: unnecessary_const
    const List<ColorSwatch> colors = const <ColorSwatch>[
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
    ];

    await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextFormField(
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    autocorrect: true,
                    style: const TextStyle(color: Colors.black),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(25),
                      FilteringTextInputFormatter.allow(RegExp("[ a-zA-Z]")),
                      FilteringTextInputFormatter.deny(
                        RegExp(r'^ +'),
                      )
                    ],
                    controller: newListNameController,
                    decoration: const InputDecoration(
                      hintText: 'New List Name',
                      hintStyle: TextStyle(color: Colors.black54),
                      labelText: 'New List Name',
                      labelStyle: TextStyle(color: Color(0xff373f51)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          borderSide:
                              BorderSide(color: Color(0xff373f51), width: 2.0)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          borderSide:
                              BorderSide(color: Color(0xff373f51), width: 2.0)),
                    ),
                    onChanged: (value) {
                      if (value.length < 25) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      }
                      if (value.length == 25) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text(
                              "List Name can't be more than 25 characters",
                              style: TextStyle(color: Colors.white)),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.blue,
                          behavior: SnackBarBehavior.floating,
                        ));
                      }
                      setState(() {});
                    },
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: colors
                          .map((e) => Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(35.0))),
                                    child: CircleColor(
                                      color: e,
                                      circleSize: 35.0,
                                      iconSelected: Icons.check,
                                      onColorChoose: (newColor) {
                                        color = newColor;
                                        setState(() {});
                                      },
                                      isSelected: color == e,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5.0,
                                  )
                                ],
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  SizedBox(
                    width: 200.0,
                    child: ElevatedButton(
                      onPressed: newListNameController.text.isNotEmpty
                          ? () async {
                              for (var element in namesList) {
                                if (element['tableName'] ==
                                    newListNameController.text) {
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text(
                                        "List Already Exists. Use Another Name",
                                        style: TextStyle(color: Colors.white)),
                                    duration: Duration(seconds: 1),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ));
                                  return;
                                }
                              }
                              Navigator.of(context).pop();
                            }
                          : () {},
                      style: ElevatedButton.styleFrom(
                          backgroundColor: newListNameController.text.isNotEmpty
                              ? const Color(0xff19ca4b)
                              : const Color(0xff8deeb3)),
                      child: Text(
                        '$purpose List',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });

    tableRecord = {
      'tableName': newListNameController.text.trim().isEmpty
          ? 'null'
          : newListNameController.text.trim(),
      'color': color.value,
    };

    return tableRecord;
  }
}
