import 'package:clipboard/clipboard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:todo/features/image_picker.dart';

bool listMode = false;
bool showMoreFeatures = false;
bool numberingListMode = false;
int numbering = 1;

Widget customBottomSheet(
    {required context,
    required titleController,
    required descriptionController,
    required Function() onChange,
    required Color bgColor,
    required List<Uint8List> images,
    Widget deleteTaskListTile = const SizedBox()}) {
  return SingleChildScrollView(
    child: Column(
      children: [
        Column(
          children: [
            Container(
              height: 40.0,
              decoration: BoxDecoration(
                  color: bgColor,
                  border: Border.symmetric(
                      horizontal:
                          BorderSide(color: Theme.of(context).primaryColor))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
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
                                color: Theme.of(context).primaryColor,
                                fontSize: 18.0),
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
                                color: Theme.of(context).primaryColor,
                                fontSize: 18.0),
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
                            size: 22.0,
                          )),
                      IconButton(
                          onPressed: () async {
                            var image = await pickImageFromDevice();
                            if (image != null) {
                              images.add(image);
                            }
                            onChange();
                          },
                          icon: const Icon(
                            Icons.image_outlined,
                            size: 22.0,
                          )),
                    ],
                  ),
                  IconButton(
                      onPressed: () {
                        showMoreFeatures = !showMoreFeatures;
                        onChange();
                      },
                      icon: Icon(
                        showMoreFeatures
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        color: Theme.of(context).primaryColor,
                        size: 32.0,
                      )),
                ],
              ),
            ),
          ],
        ),
        Visibility(
          visible: showMoreFeatures,
          child: Column(
            children: [
              bottomSheetListTile(
                tileColor: bgColor,
                leading: Icon(
                  Icons.share,
                  color: Theme.of(context).primaryColor,
                ),
                title: const Text('Share'),
                onTap: () => Share.share(
                    "${titleController.text}\n\n${descriptionController.text}",
                    subject: '${titleController.text}'),
              ),
              bottomSheetListTile(
                  tileColor: bgColor,
                  leading: Icon(
                    Icons.copy_all,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text('Copy All'),
                  onTap: () {
                    FlutterClipboard.copy(
                        '${titleController.text}\n\n${descriptionController.text}');
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Copied'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 1),
                    ));
                  }),
              bottomSheetListTile(
                  tileColor: bgColor,
                  leading: Icon(
                    Icons.remove_circle_outline_rounded,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text('Clear All'),
                  onTap: () {
                    titleController.text = '';
                    descriptionController.text = '';
                  }),
              deleteTaskListTile
            ],
          ),
        ),
      ],
    ),
  );
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
    required Widget title,
    required Function() onTap,
    required Color tileColor}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      color: tileColor,
      height: 38.0,
      child: Row(
        children: [
          const SizedBox(
            width: 8.0,
          ),
          leading,
          const SizedBox(
            width: 8.0,
          ),
          title
        ],
      ),
    ),
  );
}
