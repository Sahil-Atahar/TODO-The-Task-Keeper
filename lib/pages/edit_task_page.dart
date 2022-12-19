import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:todo/features/bottom_sheet.dart';
import 'package:todo/features/functions.dart';
import 'package:todo/main.dart';
import 'package:todo/database/db_helper.dart';
import 'package:todo/model/task.dart';

import '../assets/color_picker.dart';
import '../features/image_view.dart';
import 'add_task_page.dart';
import 'task_list_view_page.dart';

class EditTaskPage extends StatefulWidget {
  static String listName = '';
  EditTaskPage({Key? key, required task, required nameOfList})
      : super(key: key) {
    Task(task);
    listName = nameOfList;
  }

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  _EditTaskPageState() {
    isImportant = false;
    readOnly = false;
    isPinned = false;
    isSomethingChanged = false;

    fgColor = Color(Task.fgColor);

    _titleController.text = Task.title;
    _descriptionController.text = Task.description;

    isImportant = Task.isImportant.compareTo('true') == 0 ? true : false;
    isPinned = Task.isPinned.compareTo('true') == 0 ? true : false;
    images = Task.imageBytes;
    bgColor = Color(Task.bgColor);
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late Color fgColor;
  bool isSomethingChanged = false;
  late bool isImportant;
  static bool isPinned = false;
  static bool readOnly = false;
  static String _descriptionText = '';
  static Color bgColor = Colors.white;
  static List<Uint8List> images = [];
  static bool imagesEditMode = false;
  bool reverse = false;

  @override
  void initState() {
    numbering = 0;
    reverse = false;
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (imagesEditMode) {
          setState(() {
            imagesEditMode = false;
          });
          return Future.value(false);
        }
        if (isSomethingChanged) {
          DateTime dateTime = DateTime.now();
          var task = {
            'title': _titleController.text.isEmpty ? '' : _titleController.text,
            'description': _descriptionController.text,
            'datetime':
                '      ${dateTime.hour > 12 ? (dateTime.hour - 12).toString().padLeft(2, '0') : dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}\n${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}',
            'fgColor': fgColor.value,
            'isCompleted': 'false',
            'isImportant': isImportant.toString(),
            'isPinned': isPinned.toString(),
            'isHidden': Task.isHidden,
            'bgColor': Task.bgColor,
            'imagesString': imageToString(bytes: images)
          };
          AddTaskPage(
            nameOfList: EditTaskPage.listName,
          ).alertWithoutsavingTaskConfirmation(context, task);
        }
        Navigator.push(
            context,
            PageTransition(
                child: TaskListViewPage(nameOfList: EditTaskPage.listName),
                type: PageTransitionType.theme,
                childCurrent: widget,
                reverseDuration: routAnimationDuration));
        return Future(() => false);
      },
      child: Scaffold(
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? bgColor
              : Theme.of(context).scaffoldBackgroundColor,
          appBar: PreferredSize(
              preferredSize: Size(MediaQuery.of(context).size.width, 60.0),
              child: Column(children: [
                SizedBox(
                  height: MediaQuery.of(context).viewPadding.top,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 8.0, bottom: 5.0, top: 3.0, right: 8.0),
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5.0)),
                            border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 0.8)),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                  onPressed: () => TaskListViewPage(
                                        nameOfList: EditTaskPage.listName,
                                      ).changeTaskList(context,
                                          EditTaskPage.listName, Task.id),
                                  icon: Column(
                                    children: [
                                      const Icon(
                                        Icons.format_list_bulleted_rounded,
                                        size: 20.0,
                                      ),
                                      Text('Change List',
                                          style: Theme.of(context)
                                              .textTheme
                                              .displaySmall
                                              ?.copyWith(
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.bold))
                                    ],
                                  )),
                              IconButton(
                                  onPressed: () {
                                    readOnly = !readOnly;
                                    setState(() {});
                                  },
                                  icon: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        readOnly
                                            ? Icons.lock
                                            : Icons.lock_open_rounded,
                                        color: readOnly
                                            ? Colors.deepOrange
                                            : Theme.of(context).primaryColor,
                                        size: 20.0,
                                      ),
                                      Text('Read Only',
                                          style: Theme.of(context)
                                              .textTheme
                                              .displaySmall
                                              ?.copyWith(
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.bold)),
                                    ],
                                  )),
                              IconButton(
                                  onPressed: () {
                                    isSomethingChanged = true;
                                    isPinned = !isPinned;
                                    setState(() {});
                                  },
                                  icon: Column(
                                    children: [
                                      Icon(
                                        isPinned
                                            ? Icons.push_pin
                                            : Icons.push_pin_outlined,
                                        color: isPinned
                                            ? Colors.deepOrange
                                            : Theme.of(context).primaryColor,
                                        size: 20.0,
                                      ),
                                      Text('Pin',
                                          style: Theme.of(context)
                                              .textTheme
                                              .displaySmall
                                              ?.copyWith(
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.bold))
                                    ],
                                  )),
                              IconButton(
                                  onPressed: () {
                                    isSomethingChanged = true;
                                    isImportant = !isImportant;
                                    setState(() {});
                                  },
                                  icon: Column(
                                    children: [
                                      Icon(
                                        isImportant
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: isImportant
                                            ? Colors.deepOrange
                                            : Theme.of(context).primaryColor,
                                        size: 20.0,
                                      ),
                                      Text('Important',
                                          style: Theme.of(context)
                                              .textTheme
                                              .displaySmall
                                              ?.copyWith(
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.bold))
                                    ],
                                  )),
                              IconButton(
                                onPressed: () async {
                                  Color previousColor = fgColor;
                                  fgColor = await fgColorPicker(
                                      context: context, initialcolor: fgColor);
                                  if (previousColor != fgColor) {
                                    isSomethingChanged = true;
                                    setState(() {});
                                  }
                                },
                                icon: Column(
                                  children: [
                                    Container(
                                      height: 20.0,
                                      width: 20.0,
                                      decoration: BoxDecoration(
                                          color: fgColor,
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(12.0))),
                                    ),
                                    Text('FG Color',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall
                                            ?.copyWith(
                                                fontSize: 10.0,
                                                fontWeight: FontWeight.bold))
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: Theme.of(context).brightness ==
                                    Brightness.light,
                                child: IconButton(
                                    onPressed: () async {
                                      isSomethingChanged = true;
                                      var previousColor = bgColor;
                                      bgColor = await bgColorPicker(
                                        context: context,
                                        initialColor: bgColor,
                                      );
                                      if (previousColor != bgColor) {
                                        setState(() {});
                                      }
                                    },
                                    icon: Column(
                                      children: [
                                        Container(
                                          height: 20.0,
                                          width: 20.0,
                                          decoration: BoxDecoration(
                                              color: bgColor,
                                              border: Border.all(
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(12.0))),
                                        ),
                                        Text('BG Color',
                                            style: Theme.of(context)
                                                .textTheme
                                                .displaySmall
                                                ?.copyWith(
                                                    fontSize: 10.0,
                                                    fontWeight:
                                                        FontWeight.bold))
                                      ],
                                    )),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    readOnly ||
                            _descriptionController.text.isEmpty &&
                                _titleController.text.isEmpty
                        ? const SizedBox()
                        : isSomethingChanged
                            ? InkWell(
                                onTap: () async {
                                  imagesEditMode = false;
                                  DateTime dateTime = DateTime.now();
                                  var task = {
                                    'title': _titleController.text,
                                    'description': _descriptionController.text,
                                    'datetime':
                                        '${dateTime.hour > 12 ? (dateTime.hour - 12).toString().padLeft(2, '0') : dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour > 12 ? 'pm' : 'am'}   ${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}',
                                    'fgColor': fgColor.value,
                                    'isCompleted': Task.isCompleted,
                                    'isImportant': isImportant.toString(),
                                    'isPinned': isPinned.toString(),
                                    'isHidden': Task.isHidden,
                                    'bgColor': bgColor.value,
                                    'imagesString': imageToString(bytes: images)
                                  };
                                  DBHelper instance = DBHelper.instance;
                                  await instance.specialDelete(
                                      EditTaskPage.listName, Task.id);
                                  await instance
                                      .insert(EditTaskPage.listName, task)
                                      .then((value) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content:
                                          Text('Task Updated Succesfully.'),
                                      duration: Duration(seconds: 1),
                                      behavior: SnackBarBehavior.fixed,
                                    ));
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            child: TaskListViewPage(
                                              nameOfList: EditTaskPage.listName,
                                            ),
                                            type: PageTransitionType.theme,
                                            childCurrent: widget,
                                            duration: routAnimationDuration));
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    'Save',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.blue
                                          : Colors.cyan,
                                    ),
                                  ),
                                ))
                            : const SizedBox()
                  ],
                ),
              ])),
          bottomSheet: customBottomSheet(
            listName: EditTaskPage.listName,
            taskId: Task.id,
            images: images,
            bgColor: Theme.of(context).brightness == Brightness.light
                ? bgColor
                : Theme.of(context).scaffoldBackgroundColor,
            context: context,
            titleController: _titleController,
            descriptionController: _descriptionController,
            onChange: () {
              isSomethingChanged = true;
              setState(() {});
            },
            deleteTaskListTile: bottomSheetListTile(
                tileColor: Theme.of(context).brightness == Brightness.light
                    ? bgColor
                    : Theme.of(context).scaffoldBackgroundColor,
                leading: const Icon(
                  Icons.delete_forever_rounded,
                ),
                title: 'Delete',
                onTap: () async {
                  DBHelper instance = DBHelper.instance;
                  await instance
                      .specialDelete(EditTaskPage.listName, Task.id)
                      .then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Task Deleted'),
                      behavior: SnackBarBehavior.fixed,
                      action: SnackBarAction(
                        onPressed: () async {
                          var newTask = {
                            'title': Task.title,
                            'description': Task.description,
                            'datetime': Task.datetime,
                            'fgColor': Task.fgColor,
                            'isCompleted': Task.isCompleted,
                            'isImportant': Task.isImportant,
                            'isPinned': Task.isPinned,
                            'isHidden': Task.isHidden,
                            'bgColor': Task.bgColor,
                            'imagesString': imageToString(bytes: images)
                          };
                          await instance
                              .insert(TaskListViewPage.listName, newTask)
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
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              reverse: reverse,
              padding:
                  const EdgeInsets.only(left: 22.0, right: 22.0, bottom: 5.0),
              child: Column(
                children: [
                  images.isNotEmpty
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height / 3.0,
                          child: Swiper(
                            itemCount: images.length,
                            scale: 0.8,
                            index: 0,
                            loop: false,
                            axisDirection: AxisDirection.left,
                            pagination: const SwiperPagination(),
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(PageTransition(
                                      child: ImageViewer(
                                          images: images, imageIndex: index),
                                      type: PageTransitionType.theme,
                                      childCurrent: widget,
                                      duration: routAnimationDuration));
                                },
                                onLongPress: () {
                                  imagesEditMode = !imagesEditMode;
                                  isSomethingChanged = true;
                                  setState(() {});
                                },
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(16.0)),
                                      child: Image.memory(
                                        images.elementAt(index),
                                        fit: BoxFit.cover,
                                        width:
                                            MediaQuery.of(context).size.width -
                                                20,
                                      ),
                                    ),
                                    Visibility(
                                      visible: imagesEditMode,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                              onPressed: () async {
                                                images.remove(
                                                    images.elementAt(index));
                                                setState(() {});
                                              },
                                              icon: const Icon(
                                                Icons.delete_rounded,
                                                color: Colors.red,
                                              ))
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      : const SizedBox(),
                  TextField(
                    onTap: () {
                      reverse = true;
                    },
                    style: TextStyle(
                        fontSize: fontSize + 2, fontWeight: FontWeight.bold),
                    readOnly: readOnly,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(50),
                    ],
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (value) {
                      isSomethingChanged = true;
                      if (value.length == 50) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content:
                              Text("Title can't be more than 50 characters"),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.blue,
                          behavior: SnackBarBehavior.floating,
                        ));
                      }
                      setState(() {});
                    },
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Title',
                      hintStyle: TextStyle(
                          color: Theme.of(context).primaryColor == Colors.white
                              ? Colors.white70
                              : Colors.black54,
                          fontSize: fontSize + 4),
                      border: InputBorder.none,
                    ),
                  ),
                  SizedBox(
                    height: 3.0,
                    child: Divider(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 15.0),
                    height: MediaQuery.of(context).size.height / 2,
                    child: TextField(
                      onTap: () {
                        reverse = true;
                      },
                      style: TextStyle(fontSize: fontSize),
                      readOnly: readOnly,
                      autocorrect: true,
                      mouseCursor: MouseCursor.uncontrolled,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (value) {
                        isSomethingChanged = true;
                        descriptionOnChanged(value);
                      },
                      controller: _descriptionController,
                      decoration: InputDecoration(
                          hintText: 'Write here something...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                              color:
                                  Theme.of(context).primaryColor == Colors.white
                                      ? Colors.white70
                                      : Colors.black54,
                              fontSize: fontSize)),
                      keyboardType: TextInputType.multiline,
                      maxLines: 10000,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        'Last Updated : ${Task.datetime}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  void descriptionOnChanged(value) {
    var cursorPosition = _descriptionController.selection.base.offset;
    String prefixText =
        _descriptionController.text.substring(0, cursorPosition);
    String suffixText = _descriptionController.text.substring(cursorPosition);

    if (_descriptionText.length < value.length) {
      if (numberingListMode && prefixText.endsWith('\n')) {
        numbering++;
        _descriptionController.text =
            '$prefixText($numbering) ${suffixText.isNotEmpty ? suffixText : ''}';
        _descriptionController.selection = TextSelection.fromPosition(
            TextPosition(
                offset: cursorPosition + 3 + numbering.toString().length));
      } else if (listMode && prefixText.endsWith('\n')) {
        _descriptionController.text =
            '$prefixText• ${suffixText.isNotEmpty ? suffixText : ''}';
        _descriptionController.selection = TextSelection.fromPosition(
            TextPosition(offset: cursorPosition + 2));
      }
    } else {
      if (prefixText.endsWith('\n') && numbering > 0) {
        numbering--;
      }
    }
    _descriptionText = value;
    isSomethingChanged = true;
    setState(() {});
  }
}
