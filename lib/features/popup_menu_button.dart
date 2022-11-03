import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/main.dart';
import 'package:todo/pages/setting_page.dart';
import 'package:todo/pages/task_list_view_page.dart';

Widget getpopupMenuButton({required context, required nameOfList}) {
  return PopupMenuButton(
      color: Theme.of(context).scaffoldBackgroundColor,
      onSelected: ((value) async {
        if (value == 'viewMode') {
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
                      nameOfList: nameOfList,
                    ),
                    type: PageTransitionType.theme));
          });
        } else if (value == 'Setings') {
          Navigator.of(context).push(PageTransition(
              child: const SettingPage(),
              type: PageTransitionType.theme,
              childCurrent: TaskListViewPage(nameOfList: nameOfList),
              duration: routAnimationDuration));
        }
      }),
      shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          side: BorderSide(
              style: BorderStyle.solid, color: Theme.of(context).primaryColor)),
      itemBuilder: (context) => [
            PopupMenuItem(
              value: 'viewMode',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(viewMode == 'List View' ? Icons.grid_view : Icons.list,
                      color: Theme.of(context).primaryColor),
                  const SizedBox(
                    width: 8.0,
                  ),
                  Text(viewMode == 'List View'
                      ? 'View as Grid'
                      : 'View as List'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'Setings',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.settings, color: Theme.of(context).primaryColor),
                  const SizedBox(
                    width: 8.0,
                  ),
                  const Text('Setings'),
                ],
              ),
            ),
          ]);
}
