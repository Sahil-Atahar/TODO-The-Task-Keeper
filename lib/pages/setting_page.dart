import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/main.dart';
import 'package:todo/pages/homepage.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
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
        appBar: AppBar(
          title: const Text('Settings'),
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).push(PageTransition(
                  child: HomePage(
                    index: -1,
                  ),
                  type: PageTransitionType.theme,
                  childCurrent: widget,
                  //alignment: Alignment.center,
                  duration: routAnimationDuration));
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
        body: SafeArea(
            child: ListView(
          children: [
            SwitchListTile(
              title: Row(
                children: const [
                  CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(
                        Icons.dark_mode,
                        color: Colors.white,
                      )),
                  SizedBox(
                    width: 8.0,
                  ),
                  Text('Dark Mode')
                ],
              ),
              value: darkMode,
              activeColor: Colors.blue,
              onChanged: ((value) async {
                darkMode = !darkMode;
                await SharedPreferences.getInstance()
                    .then((value) => value.setBool('isDarkMode', darkMode));
                themeManager.toggleTheme(value);
                setState(() {});
              }),
            ),
            ListTile(
              onTap: changeFontSize,
              title: Row(
                children: const [
                  CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        'F',
                        style: TextStyle(color: Colors.white, fontSize: 22.0),
                      )),
                  SizedBox(
                    width: 8.0,
                  ),
                  Text('Font Size')
                ],
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(right: 18.0),
                child: Text(
                  '${fontSize.toInt()}',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
            ),
            SwitchListTile(
              title: Row(
                children: const [
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(
                      Icons.visibility,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    width: 8.0,
                  ),
                  Text(
                    'Show Hidden Tasks',
                  )
                ],
              ),
              value: showHiddenTasks,
              activeColor: Colors.blue,
              onChanged: ((value) async {
                showHiddenTasks = value;
                await SharedPreferences.getInstance().then((value) {
                  value.setBool('showHiddenTasks', showHiddenTasks);
                  setState(() {});
                });
              }),
            ),
          ],
        )),
      ),
    );
  }

  changeFontSize() {
    int initialFontSize = fontSize.toInt();
    showDialog(
        useSafeArea: true,
        context: context,
        builder: (context) => StatefulBuilder(
              builder: (context, setState) => SimpleDialog(
                contentPadding: const EdgeInsets.all(22.0),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: initialFontSize > 16
                            ? () {
                                initialFontSize -= 2;
                                setState(() {});
                              }
                            : null,
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.black,
                        )),
                    const SizedBox(
                      width: 8.0,
                    ),
                    Text(
                      initialFontSize.toString(),
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(
                      width: 8.0,
                    ),
                    IconButton(
                        onPressed: initialFontSize < 26
                            ? () {
                                initialFontSize += 2;
                                setState(() {});
                              }
                            : null,
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.black,
                        ))
                  ],
                ),
                children: [
                  const Padding(
                      padding: EdgeInsets.only(left: 32.0, right: 32.0),
                      child: SizedBox()),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () async {
                            fontSize = initialFontSize.toDouble();
                            await SharedPreferences.getInstance().then((value) {
                              value.setDouble('fontSize', fontSize);
                              Navigator.of(context).pop();
                            });
                          },
                          child: const Text('Submit'))
                    ],
                  )
                ],
              ),
            ));
  }
}
