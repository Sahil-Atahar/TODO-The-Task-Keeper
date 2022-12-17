import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:todo/features/bottom_sheet.dart';
import 'package:todo/features/functions.dart';
import 'package:todo/features/image_view.dart';
import 'package:todo/main.dart';
import 'package:todo/database/db_helper.dart';
import '../assets/color_picker.dart';
import 'task_list_view_page.dart';

class AddTaskPage extends StatefulWidget {
  AddTaskPage({required nameOfList, Key? key}) : super(key: key) {
    listName = nameOfList;
  }

  static String listName = '';

  void alertWithoutsavingTaskConfirmation(context, task) {
    showDialog(
        context: context,
        builder: (context) => SimpleDialog(
              title: const Text('Save your Tasks or discard them?',
                  style: TextStyle(fontSize: 15.0, color: Colors.black)),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                        )),
                    TextButton(
                        onPressed: () => Navigator.push(
                            context,
                            PageTransition(
                                child: TaskListViewPage(nameOfList: listName),
                                type: PageTransitionType.theme,
                                childCurrent: this,
                                duration: routAnimationDuration)),
                        child: const Text(
                          'Discard',
                        )),
                    TextButton(
                        onPressed: () async {
                          await saveTask(task, context).then((value) =>
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      child: TaskListViewPage(
                                          nameOfList: listName),
                                      type: PageTransitionType.theme,
                                      childCurrent: this,
                                      duration: routAnimationDuration)));
                        },
                        child: const Text(
                          'Save',
                        )),
                  ],
                )
              ],
            ));
  }

  Future<int> saveTask(Map<String, dynamic> task, context) async {
    DBHelper instance = DBHelper.instance;
    int id = await instance.insert(listName, task);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Task Added.',
        ),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.fixed,
      ),
    );
    Navigator.push(
        context,
        PageTransition(
            child: TaskListViewPage(nameOfList: listName),
            type: PageTransitionType.theme,
            childCurrent: this,
            duration: routAnimationDuration));
    return id;
  }

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Color fgColor = Colors.blue;
  bool isImportant = false;
  static bool isPinned = false;
  static bool readOnly = false;
  static String _descriptionText = '';
  static Color bgColor = Colors.white;
  Duration routAnimationDuration = const Duration(microseconds: 500);
  List<Uint8List> images = [];

  @override
  initState() {
    super.initState();
    isImportant = false;
    readOnly = false;
    isPinned = false;
    showMoreFeatures = false;
    numbering = 0;
    bgColor = Colors.white;
    images = [];
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
      onWillPop: _titleController.text.isNotEmpty ||
              _descriptionController.text.isNotEmpty ||
              images.isNotEmpty
          ? () {
              DateTime dateTime = DateTime.now();
              var task = {
                'title':
                    _titleController.text.isEmpty ? '' : _titleController.text,
                'description': _descriptionController.text,
                'datetime':
                    '${dateTime.hour > 12 ? (dateTime.hour - 12).toString().padLeft(2, '0') : dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour > 12 ? 'pm' : 'am'}   ${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}',
                'fgColor': fgColor.value,
                'isCompleted': 'false',
                'isImportant': isImportant.toString(),
                'isPinned': isPinned.toString(),
                'isHidden': 'false',
                'bgColor': bgColor.value,
                'imagesString': imageToString(bytes: images)
              };
              AddTaskPage(
                nameOfList: AddTaskPage.listName,
              ).alertWithoutsavingTaskConfirmation(context, task);
              return Future(() => false);
            }
          : () {
              Navigator.push(
                  context,
                  PageTransition(
                      child: TaskListViewPage(nameOfList: AddTaskPage.listName),
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
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).viewPadding.top,
                ),
                Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          margin: const EdgeInsets.only(
                              left: 8.0, bottom: 5.0, top: 3.0),
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5.0)),
                              border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 0.8)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
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
                                    var previousColor = fgColor;
                                    fgColor = await fgColorPicker(
                                        context: context,
                                        initialcolor: fgColor);
                                    if (previousColor != fgColor) {
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
                                            borderRadius:
                                                const BorderRadius.all(
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
                                  )),
                              Visibility(
                                visible: Theme.of(context).brightness ==
                                    Brightness.light,
                                child: IconButton(
                                    onPressed: () async {
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
                          )),
                      readOnly
                          ? const SizedBox()
                          : TextButton(
                              onPressed: () async {
                                if (_titleController.text.isEmpty &&
                                    _descriptionController.text.isEmpty &&
                                    images.isEmpty) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                          duration: Duration(seconds: 2),
                                          behavior: SnackBarBehavior.fixed,
                                          backgroundColor: Colors.red,
                                          content: Text(
                                            'No content to save.',
                                            style:
                                                TextStyle(color: Colors.white),
                                          )));
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          child: TaskListViewPage(
                                              nameOfList:
                                                  TaskListViewPage.listName),
                                          type: PageTransitionType.theme,
                                          childCurrent: widget,
                                          duration: routAnimationDuration));
                                  return;
                                }
                                DateTime dateTime = DateTime.now();
                                var task = {
                                  'title': _titleController.text,
                                  'description': _descriptionController.text,
                                  'datetime':
                                      '${dateTime.hour > 12 ? (dateTime.hour - 12).toString().padLeft(2, '0') : dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour > 12 ? 'pm' : 'am'}   ${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}',
                                  'fgColor': fgColor.value,
                                  'isCompleted': false.toString(),
                                  'isImportant': isImportant.toString(),
                                  'isPinned': isPinned.toString(),
                                  'isHidden': 'false',
                                  'bgColor': bgColor.value,
                                  'imagesString': imageToString(bytes: images)
                                };
                                await AddTaskPage(
                                  nameOfList: AddTaskPage.listName,
                                ).saveTask(task, context);
                              },
                              child: Text(
                                'Save',
                                style: TextStyle(
                                    //fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.dark
                                        ? Colors.cyan
                                        : Colors.blue),
                              ),
                            )
                    ]),
              ],
            ),
          ),
          bottomSheet: customBottomSheet(
            images: images,
            bgColor: Theme.of(context).brightness == Brightness.light
                ? bgColor
                : Theme.of(context).scaffoldBackgroundColor,
            context: context,
            titleController: _titleController,
            descriptionController: _descriptionController,
            onChange: () {
              setState(() {});
            },
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              reverse: true,
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
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
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
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      : const SizedBox(),
                  TextField(
                    onTap: () {
                      showMoreFeatures = false;
                    },
                    style: TextStyle(
                        fontSize: fontSize + 2, fontWeight: FontWeight.bold),
                    readOnly: readOnly,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(50),
                    ],
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) {
                      if (value.length == 50) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text(
                              "Title can't be more than 50 characters",
                              style: TextStyle(color: Colors.white)),
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
                          fontSize: fontSize + 2),
                      border: InputBorder.none,
                    ),
                  ),
                  SizedBox(
                    height: 3.0,
                    child: Divider(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 3,
                    child: TextField(
                      onTap: () {
                        showMoreFeatures = false;
                      },
                      style: TextStyle(fontSize: fontSize),
                      readOnly: readOnly,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (value) {
                        int cursorPosition =
                            _descriptionController.selection.base.offset;
                        String prefixText = _descriptionController.text
                            .substring(0, cursorPosition);
                        String suffixText = _descriptionController.text
                            .substring(cursorPosition);

                        if (_descriptionText.length < value.length) {
                          if (numberingListMode && prefixText.endsWith('\n')) {
                            numbering++;
                            _descriptionController.text =
                                '$prefixText($numbering) ${suffixText.isNotEmpty ? suffixText : ''}';
                            _descriptionController.selection =
                                TextSelection.fromPosition(TextPosition(
                                    offset: cursorPosition +
                                        3 +
                                        numbering.toString().length));
                          } else if (listMode && prefixText.endsWith('\n')) {
                            _descriptionController.text =
                                '$prefixText• ${suffixText.isNotEmpty ? suffixText : ''}';
                            _descriptionController.selection =
                                TextSelection.fromPosition(
                                    TextPosition(offset: cursorPosition + 2));
                          }
                        } else {
                          if (prefixText.endsWith('\n') && numbering > 0) {
                            numbering--;
                          }
                        }
                        _descriptionText = value;
                        setState(() {});
                      },
                      controller: _descriptionController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 10000,
                      decoration: InputDecoration(
                          hintText: 'Write here something...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                              color:
                                  Theme.of(context).primaryColor == Colors.white
                                      ? Colors.white70
                                      : Colors.black54,
                              fontSize: fontSize)),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
