import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:todo/database/db_helper.dart';
import 'package:todo/features/image_picker.dart';

import '../model/task.dart';
import '../pages/task_list_view_page.dart';

bool listMode = false;
bool numberingListMode = false;
int numbering = 1;

Widget customBottomSheet(
    {required context,
    required titleController,
    required descriptionController,
    required Function() onChange,
    required Color bgColor,
    required List<Uint8List> images,
    Widget deleteTaskListTile = const SizedBox(),
    required taskId,
    required listName}) {
  return SingleChildScrollView(
    child: Container(
      height: 40.0,
      decoration: BoxDecoration(
        color: bgColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                  onPressed: () async {
                    await showAddingFeature(
                        context: context,
                        images: images,
                        onChange: onChange,
                        bgColor: bgColor);
                  },
                  icon: const Icon(Icons.add_box_outlined)),
              IconButton(
                  onPressed: () {
                    descriptionController.text = sort(
                        text: descriptionController.text.trim(),
                        sortingMethod: 'A to Z');
                    onChange();
                  },
                  icon: Text(
                    'AZ',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 18.0),
                  )),
              IconButton(
                  onPressed: () {
                    descriptionController.text = sort(
                        text: descriptionController.text.trim(),
                        sortingMethod: 'Z to A');
                    onChange();
                  },
                  icon: Text(
                    'ZA',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 18.0),
                  )),
              IconButton(
                onPressed: () {
                  listMode = !listMode;
                  onChange();
                },
                icon: Icon(
                  Icons.list,
                  color: listMode
                      ? Colors.deepOrange
                      : Theme.of(context).primaryColor,
                ),
              ),
              IconButton(
                  onPressed: () {
                    numberingListMode = !numberingListMode;
                    if (numbering != 0) {
                      numbering = 0;
                    }
                    onChange();
                  },
                  icon: Icon(
                    Icons.format_list_numbered_rounded,
                    color: numberingListMode
                        ? Colors.deepOrange
                        : Theme.of(context).primaryColor,
                  )),
            ],
          ),
          IconButton(
              onPressed: () async {
                await showMoreFeatures(
                    deleteTaskListTile: deleteTaskListTile,
                    context: context,
                    bgColor: bgColor,
                    titleController: titleController,
                    descriptionController: descriptionController,
                    images: images,
                    taskId: taskId,
                    listName: listName);
                onChange();
              },
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).primaryColor,
              )),
        ],
      ),
    ),
  );
}

Future showMoreFeatures(
    {required context,
    required bgColor,
    required titleController,
    required descriptionController,
    required Widget deleteTaskListTile,
    required List<Uint8List> images,
    required taskId,
    required listName}) async {
  await showModalBottomSheet(
      context: context,
      builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              bottomSheetListTile(
                  tileColor: bgColor,
                  leading: Icon(
                    Icons.share,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: 'Send',
                  onTap: () async {
                    Navigator.pop(context);
                    await shareTask(
                        images: images,
                        title: titleController.text,
                        description: descriptionController.text);
                  }),
              listName != null
                  ? bottomSheetListTile(
                      tileColor: bgColor,
                      leading: Icon(
                        Icons.copy,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: 'Make a Copy',
                      onTap: () async {
                        Navigator.pop(context);
                        DBHelper instance = DBHelper.instance;
                        var task =
                            (await instance.specialQuerry(listName, taskId))
                                .elementAt(0);
                        await instance
                            .insert(listName, Task(task).toMap())
                            .then(
                              (value) => Navigator.of(context).push(
                                  PageTransition(
                                      child: TaskListViewPage(
                                          nameOfList: listName),
                                      type: PageTransitionType.theme)),
                            );
                      })
                  : const SizedBox(),
              bottomSheetListTile(
                  tileColor: bgColor,
                  leading: Icon(
                    Icons.remove_circle_outline_rounded,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: 'Clear All',
                  onTap: () {
                    Navigator.pop(context);
                    titleController.text = '';
                    descriptionController.text = '';
                  }),
              deleteTaskListTile
            ],
          ));
}

Future shareTask(
    {required images, required title, required description}) async {
  if (images.isNotEmpty) {
    List<File> files = [];
    final tempDir = await getTemporaryDirectory();
    for (var image in images) {
      var file = await File('${tempDir.path}/image${images.indexOf(image)}.png')
          .create();
      file.writeAsBytesSync(image);
      files.add(file);
    }
    Share.shareXFiles(files.map((file) => XFile(file.path)).toList(),
        subject: title, text: "$title\n\n$description");
    files.map((file) => file.delete());
  } else {
    Share.share("$title\n\n$description", subject: '$title');
  }
}

Future showAddingFeature(
    {required context,
    required images,
    required onChange,
    required bgColor}) async {
  await showModalBottomSheet(
      context: context,
      builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              bottomSheetListTile(
                  leading: const Icon(
                    Icons.camera_enhance_outlined,
                  ),
                  title: 'Take Photo',
                  onTap: () async {
                    Navigator.pop(context);
                    var image =
                        await pickImage(imageSource: ImageSource.camera);
                    if (image != null) {
                      images.add(image);
                    }
                    onChange();
                  },
                  tileColor: bgColor),
              bottomSheetListTile(
                  leading: const Icon(
                    Icons.image_outlined,
                  ),
                  title: 'Add image',
                  onTap: () async {
                    Navigator.pop(context);
                    var image =
                        await pickImage(imageSource: ImageSource.gallery);
                    if (image != null) {
                      images.add(image);
                    }
                    onChange();
                  },
                  tileColor: bgColor),
            ],
          ));
}

String sort({required text, required sortingMethod}) {
  List<String> stringList = text.split('\n');
  if (sortingMethod == 'A to Z') {
    stringList = stringList..sort();
  } else {
    stringList = stringList..sort(((a, b) => b.compareTo(a)));
  }
  text = stringList.join('\n');
  return text;
}

Widget bottomSheetListTile(
    {required Icon leading,
    required String title,
    required Function() onTap,
    required Color tileColor}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      color: tileColor,
      height: 42.0,
      child: Row(
        children: [
          const SizedBox(
            width: 12.0,
          ),
          leading,
          const SizedBox(
            width: 16.0,
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 16.0),
          )
        ],
      ),
    ),
  );
}
