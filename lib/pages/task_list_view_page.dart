import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:page_transition/page_transition.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/main.dart';
import 'package:todo/pages/add_task_page.dart';
import 'package:todo/database/db_helper.dart';
import 'package:todo/pages/edit_task_page.dart';
import 'package:todo/pages/homepage.dart';
import 'package:todo/features/popup_menu_button.dart';
import 'package:todo/model/task.dart';
import 'package:todo/theme/theme_manager.dart';

class TaskListViewPage extends StatefulWidget {
  static String listName = '';

  TaskListViewPage({required nameOfList, Key? key}) : super(key: key) {
    listName = nameOfList;
  }

  void changeTaskList(context, listName, id) async {
    DBHelper instance = DBHelper.instance;
    var namesList = await instance.queryAllForTableName();
    var leftNamesList = [];
    for (var element in namesList) {
      if (!(element['tableName'] == listName)) {
        leftNamesList.add(element);
      }
    }
    if (leftNamesList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Another List not found",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
              builder: (context, setstate) => SimpleDialog(
                contentPadding: const EdgeInsets.all(22.0),
                title: const Center(
                  child: Text(
                    'Select List To Move',
                    style: TextStyle(fontSize: 18.0, color: Colors.black),
                  ),
                ),
                children: leftNamesList
                    .map((e) => TextButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Color(e['color']);
                              }
                              return Color(e['color']);
                            }),
                          ),
                          child: Text(
                            e['tableName'],
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            DBHelper instance = DBHelper.instance;
                            Map<String, dynamic> specialTask =
                                (await instance.specialQuerry(listName, id))
                                    .elementAt(0);
                            await instance.specialDelete(
                                listName, id.toString());
                            await instance
                                .insert(
                                    e['tableName'], Task(specialTask).toMap())
                                .then((value) => Navigator.push(
                                    context,
                                    PageTransition(
                                        child: TaskListViewPage(
                                          nameOfList: TaskListViewPage.listName,
                                        ),
                                        type: PageTransitionType.theme,
                                        childCurrent: this,
                                        duration: const Duration(
                                            milliseconds: 500))));
                          },
                        ))
                    .toList(),
              ),
            ));
  }

  @override
  State<TaskListViewPage> createState() => _TaskListViewPageState();
}

class _TaskListViewPageState extends State<TaskListViewPage> {
  _TaskListViewPageState() {
    loadDataOfList();
  }

  List<Widget> listOfWidgetData = [];
  ScrollController scrollController = ScrollController();
  bool showUpButton = false;
  final searchTextFieldController = TextEditingController();

  @override
  void initState() {
    scrollController.addListener(() {
      //scroll listener
      double showoffset = 300.0;
      if (scrollController.offset > showoffset) {
        showUpButton = true;
        setState(() {});
      } else {
        showUpButton = false;
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.push(
              context,
              PageTransition(
                  child: HomePage(
                    index: -1,
                  ),
                  type: PageTransitionType.theme,
                  childCurrent: widget,
                  //alignment: Alignment.center,
                  duration: routAnimationDuration));
          return Future(() => false);
        },
        child: Scaffold(
            floatingActionButton: showUpButton
                ? FloatingActionButton(
                    elevation: 0.0,
                    onPressed: () {
                      scrollController.animateTo(
                          //go to top of scroll
                          0, //scroll offset to go
                          duration: const Duration(
                              milliseconds: 500), //duration of scroll
                          curve: Curves.fastOutSlowIn //scroll type
                          );
                    },
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.arrow_upward),
                  )
                : FloatingActionButton(
                    elevation: 0.0,
                    backgroundColor: Colors.red,
                    onPressed: () =>
                        Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AddTaskPage(
                        nameOfList: TaskListViewPage.listName,
                      ),
                    )),
                    child: const Tooltip(
                      message: 'Add Task',
                      textStyle: TextStyle(color: Colors.white),
                      decoration: BoxDecoration(color: Colors.black),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ),
            appBar: AppBar(
              title: Text(
                TaskListViewPage.listName,
              ),
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: Icon(
                    viewMode == 'List View' ? Icons.grid_view : Icons.list),
                onPressed: () async {
                  if (viewMode == 'List View') {
                    viewMode = 'Grid View';
                  } else {
                    viewMode = 'List View';
                  }
                  await SharedPreferences.getInstance().then((value) {
                    value.setString('viewMode', viewMode);

                    Navigator.push(
                        context,
                        PageTransition(
                            child: TaskListViewPage(
                              nameOfList: TaskListViewPage.listName,
                            ),
                            type: PageTransitionType.theme));
                  });
                },
              ),
              actions: [
                getpopupMenuButton(
                    context: context, nameOfList: TaskListViewPage.listName)
              ],
              bottom: PreferredSize(
                preferredSize: Size(MediaQuery.of(context).size.width, 42.0),
                child: Container(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  margin: const EdgeInsets.only(bottom: 3.0),
                  child: CupertinoSearchTextField(
                    controller: searchTextFieldController,
                    style: const TextStyle(fontSize: 16.0, color: Colors.black),
                    suffixIcon: const Icon(
                      Icons.close_rounded,
                      color: Colors.black,
                    ),
                    onSuffixTap: () {
                      searchTextFieldController.text = '';
                      setState(() {});
                    },
                    decoration: BoxDecoration(
                      color: lightTheme(context).scaffoldBackgroundColor,
                      border: Border.all(color: Colors.black),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(15.0)),
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Colors.black,
                    ),
                    onChanged: (value) async {
                      loadDataOfList();
                      setState(() {});
                    },
                  ),
                ),
              ),
            ),
            body: listOfWidgetData.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(right: 2.0, left: 2.0),
                    child: Scrollbar(
                      thickness: 5.0,
                      radius: const Radius.circular(15.0),
                      child: viewMode == 'Grid View'
                          ? AnimationLimiter(
                              child: GridView.count(
                              padding: const EdgeInsets.all(8.0),
                              crossAxisCount: 2,
                              controller: scrollController,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                              physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics()),
                              children: List.generate(listOfWidgetData.length,
                                  (index) {
                                return AnimationConfiguration.staggeredGrid(
                                    position: index,
                                    columnCount: 2,
                                    child: ScaleAnimation(
                                      duration:
                                          const Duration(milliseconds: 900),
                                      curve: Curves.fastLinearToSlowEaseIn,
                                      child: FadeInAnimation(
                                        child:
                                            listOfWidgetData.elementAt(index),
                                      ),
                                    ));
                              }),
                            ))
                          : AnimationLimiter(
                              child: ListView.builder(
                                  padding: const EdgeInsets.only(right: 5.0),
                                  controller: scrollController,
                                  itemCount: listOfWidgetData.length,
                                  itemBuilder: (context, index) {
                                    return AnimationConfiguration.staggeredList(
                                        delay:
                                            const Duration(milliseconds: 100),
                                        position: index,
                                        child: SlideAnimation(
                                          duration: const Duration(
                                              milliseconds: 2500),
                                          curve: Curves.fastLinearToSlowEaseIn,
                                          horizontalOffset: 30.0,
                                          verticalOffset: 300.0,
                                          child: FlipAnimation(
                                            duration: const Duration(
                                                milliseconds: 3000),
                                            curve:
                                                Curves.fastLinearToSlowEaseIn,
                                            flipAxis: FlipAxis.y,
                                            child: listOfWidgetData
                                                .elementAt(index),
                                          ),
                                        ));
                                  })),
                    ))
                : Center(
                    child: Text(
                      'No Task Found',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )));
  }

  void loadDataOfList() async {
    listOfWidgetData.clear();

    DBHelper instance = DBHelper.instance;
    var tasks = await instance.queryAll(TaskListViewPage.listName);

    for (var task in tasks) {
      if (task['isPinned'] == 'false') {
        insertIntoWidgetData(task);
      }
    }
    for (var task in tasks) {
      if (task['isPinned'] == 'true') {
        insertIntoWidgetData(task);
      }
    }
    setState(() {});
  }

  void insertIntoWidgetData(Map<String, dynamic> task) {
    Task(task);

    if (!showHiddenTasks && Task.isHidden == 'true') return;

    var searchText = searchTextFieldController.text.trim();

    if (searchText.isNotEmpty) {
      if (Task.title.contains(searchText) ||
          Task.description.contains(searchText)) {
      } else {
        return;
      }
    }
    listOfWidgetData.insert(
        0,
        OpenContainer(
          closedColor: Colors.transparent,
          middleColor: Colors.transparent,
          openColor: Colors.transparent,
          transitionDuration: const Duration(milliseconds: 800),
          openBuilder: (context, _) =>
              EditTaskPage(task: task, nameOfList: TaskListViewPage.listName),
          closedBuilder: (context, onTap) => FocusedMenuHolder(
            blurSize: 8.0,
            animateMenuItems: false,
            duration: const Duration(seconds: 0),
            menuWidth: MediaQuery.of(context).size.width / 2,
            menuItems: [
              FocusedMenuItem(
                  title: Text(
                    task['isPinned'] == 'true'
                        ? 'Unpin From Top'
                        : 'Pin on Top',
                    style: const TextStyle(color: Colors.black),
                  ),
                  trailingIcon: Icon(
                    task['isPinned'] == 'true'
                        ? Icons.remove_circle_outline
                        : Icons.push_pin_outlined,
                    color: Colors.black,
                  ),
                  onPressed: () async {
                    DBHelper instance = DBHelper.instance;
                    DateTime dateTime = DateTime.now();
                    var updatedTask = {
                      'id': task['id'],
                      'title': task['title'],
                      'description': task['description'],
                      'datetime':
                          '${dateTime.hour > 12 ? (dateTime.hour - 12).toString().padLeft(2, '0') : dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour > 12 ? 'pm' : 'am'}   ${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}',
                      'fgColor': task['fgColor'],
                      'isCompleted': task['isCompleted'],
                      'isImportant': task['isImportant'],
                      'isPinned': task['isPinned'] == 'true'
                          ? false.toString()
                          : true.toString(),
                      'isHidden': task['isHidden'],
                      'bgColor': task['bgColor'],
                      'imagesString': task['imagesString']
                    };
                    await instance
                        .update(TaskListViewPage.listName,
                            task['id'].toString(), updatedTask)
                        .then((value) => Navigator.push(
                            context,
                            PageTransition(
                                child: TaskListViewPage(
                                    nameOfList: TaskListViewPage.listName),
                                type: PageTransitionType.theme,
                                childCurrent: widget,
                                duration: routAnimationDuration)));
                  }),
              FocusedMenuItem(
                  title: const Text('Share',
                      style: TextStyle(color: Colors.black)),
                  trailingIcon: const Icon(
                    Icons.share,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Share.share("${Task.title}\n\n${Task.description}");
                  }),
              FocusedMenuItem(
                  backgroundColor: task['isCompleted'] == 'false'
                      ? Colors.green
                      : Colors.white,
                  title: Text(
                    task['isCompleted'] == 'false'
                        ? 'Completed'
                        : 'Not Completed',
                    style: TextStyle(
                      color: task['isCompleted'] == 'false'
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  trailingIcon: Icon(
                    task['isCompleted'] == 'false'
                        ? Icons.check_circle_outlined
                        : Icons.unpublished_outlined,
                    color: task['isCompleted'] == 'false'
                        ? Colors.white
                        : Colors.black,
                  ),
                  onPressed: () async {
                    DateTime dateTime = DateTime.now();
                    var updatedTask = {
                      'id': task['id'],
                      'title': task['title'],
                      'description': task['description'],
                      'datetime':
                          '${dateTime.hour > 12 ? (dateTime.hour - 12).toString().padLeft(2, '0') : dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour > 12 ? 'pm' : 'am'}   ${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}',
                      'fgColor': task['fgColor'],
                      'isCompleted': task['isCompleted'] == 'false'
                          ? true.toString()
                          : false.toString(),
                      'isImportant': task['isImportant'],
                      'isPinned': task['isPinned'],
                      'isHidden': task['isHidden'],
                      'bgColor': task['bgColor'],
                      'imagesString': task['imagesString']
                    };
                    DBHelper instance = DBHelper.instance;
                    await instance
                        .update(TaskListViewPage.listName,
                            task['id'].toString(), updatedTask)
                        .then((value) => Navigator.push(
                            context,
                            PageTransition(
                                child: TaskListViewPage(
                                    nameOfList: TaskListViewPage.listName),
                                type: PageTransitionType.theme,
                                childCurrent: widget,
                                duration: routAnimationDuration)));
                  }),
              FocusedMenuItem(
                  title: Text(
                    task['isHidden'] == 'true'
                        ? 'Remove From Hide'
                        : 'Hide Task',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  trailingIcon: Icon(
                    task['isHidden'] == 'true'
                        ? Icons.remove_circle_outline
                        : Icons.visibility,
                    color: Colors.black,
                  ),
                  onPressed: () async {
                    DateTime dateTime = DateTime.now();
                    var updatedTask = {
                      'id': task['id'],
                      'title': task['title'],
                      'description': task['description'],
                      'datetime':
                          '${dateTime.hour > 12 ? (dateTime.hour - 12).toString().padLeft(2, '0') : dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour > 12 ? 'pm' : 'am'}   ${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}',
                      'fgColor': task['fgColor'],
                      'isCompleted': task['isCompleted'],
                      'isImportant': task['isImportant'],
                      'isPinned': task['isPinned'],
                      'isHidden': task['isHidden'] == 'true'
                          ? false.toString()
                          : true.toString(),
                      'bgColor': task['bgColor'],
                      'imagesString': task['imagesString']
                    };
                    DBHelper instance = DBHelper.instance;
                    await instance
                        .update(TaskListViewPage.listName,
                            task['id'].toString(), updatedTask)
                        .then((value) => Navigator.push(
                            context,
                            PageTransition(
                                child: TaskListViewPage(
                                    nameOfList: TaskListViewPage.listName),
                                type: PageTransitionType.theme,
                                childCurrent: widget,
                                duration: routAnimationDuration)));
                  }),
              FocusedMenuItem(
                  backgroundColor: Colors.white,
                  title: const Text(
                    'Change List',
                    style: TextStyle(color: Colors.black),
                  ),
                  trailingIcon: const Icon(
                    Icons.format_list_bulleted_rounded,
                    color: Colors.black,
                  ),
                  onPressed: () =>
                      TaskListViewPage(nameOfList: TaskListViewPage.listName)
                          .changeTaskList(
                              context, TaskListViewPage.listName, task['id'])),
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
                    await instance
                        .specialDelete(TaskListViewPage.listName, task['id'])
                        .then((value) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('Task Deleted'),
                        behavior: SnackBarBehavior.fixed,
                        action: SnackBarAction(
                          onPressed: () async {
                            await instance
                                .insert(TaskListViewPage.listName,
                                    Task(task).toMap())
                                .then((value) => Navigator.push(
                                    context,
                                    PageTransition(
                                        child: TaskListViewPage(
                                            nameOfList:
                                                TaskListViewPage.listName),
                                        type: PageTransitionType.theme,
                                        childCurrent: widget,
                                        duration: routAnimationDuration)));
                          },
                          label: 'Undo',
                        ),
                      ));

                      Navigator.push(
                          context,
                          PageTransition(
                              child: TaskListViewPage(
                                  nameOfList: TaskListViewPage.listName),
                              type: PageTransitionType.theme,
                              childCurrent: widget,
                              duration: routAnimationDuration));
                    });
                  }),
            ],
            onPressed: () {},
            child: viewMode == 'Grid View'
                ? InkWell(
                    onTap: onTap,
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2 - 30,
                      height: MediaQuery.of(context).size.width / 2,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          color: Color(task['fgColor']),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12.0)),
                          boxShadow: [
                            BoxShadow(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                offset: const Offset(-8, -8),
                                blurRadius: 15.0),
                            BoxShadow(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                blurRadius: 15.0,
                                spreadRadius: 2.0,
                                offset: const Offset(8, 8))
                          ]),
                      child: SingleChildScrollView(
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Column(
                              children: [
                                Text(
                                  task['title'],
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                      overflow: TextOverflow.ellipsis,
                                      decoration: task['isCompleted'] == 'true'
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none),
                                ),
                                const Divider(
                                  color: Colors.white,
                                ),
                                Text(task['description'],
                                    style: TextStyle(
                                        color: Colors.white,
                                        decoration:
                                            task['isCompleted'] == 'true'
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none)),
                              ],
                            ),
                            Visibility(
                                visible: task['isPinned'] == 'true' ||
                                    task['isImportant'] == 'true' ||
                                    task['isHidden'] == 'true' ||
                                    task['imagesString'].isNotEmpty,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    task['isHidden'] == 'true'
                                        ? const Text(
                                            'H',
                                            style:
                                                TextStyle(color: Colors.white),
                                          )
                                        : task['isPinned'] == 'true' ||
                                                task['isImportant'] == 'true'
                                            ? Icon(
                                                task['isPinned'] == 'true'
                                                    ? Icons.push_pin
                                                    : Icons.star,
                                                color: Colors.amber,
                                              )
                                            : const SizedBox(),
                                    task['imagesString'].isNotEmpty
                                        ? const Icon(
                                            Icons.image_rounded,
                                            color: Colors.amber,
                                          )
                                        : const SizedBox()
                                  ],
                                )),
                          ],
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: ListTile(
                        onTap: onTap,
                        isThreeLine: true,
                        textColor: Colors.white,
                        title: Text(
                          task['title'],
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: task['isCompleted'] == 'true'
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              overflow: TextOverflow.ellipsis),
                        ),
                        subtitle: Text(
                          task['description'].toString().trim(),
                          maxLines: 2,
                          style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              decoration: task['isCompleted'] == 'true'
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none),
                        ),
                        trailing: Visibility(
                            visible: task['isPinned'] == 'true' ||
                                task['isImportant'] == 'true' ||
                                task['isHidden'] == 'true' ||
                                task['imagesString'].isNotEmpty,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                task['isHidden'] == 'true'
                                    ? const Text('H')
                                    : task['isPinned'] == 'true' ||
                                            task['isImportant'] == 'true'
                                        ? Icon(
                                            task['isPinned'] == 'true'
                                                ? Icons.push_pin
                                                : Icons.star,
                                            color: Colors.amber,
                                          )
                                        : const SizedBox(),
                                task['imagesString'].isNotEmpty
                                    ? const Icon(
                                        Icons.image_rounded,
                                        color: Colors.amber,
                                      )
                                    : const SizedBox()
                              ],
                            )),
                        tileColor: Color(task['fgColor']),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        )),
                  ),
          ),
        ));
  }
}
