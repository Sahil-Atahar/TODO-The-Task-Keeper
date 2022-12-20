import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/pages/homepage.dart';
import 'package:todo/theme/theme_manager.dart';

bool darkMode = false;
bool showHiddenTasks = true;
String viewMode = 'List View';
double fontSize = 16.0;
const Duration routAnimationDuration = Duration(milliseconds: 200);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SharedPreferences.getInstance().then((value) {
    darkMode = value.getBool('isDarkMode') ?? false;

    themeManager.toggleTheme(darkMode);
    showHiddenTasks = value.getBool('showHiddenTasks') ?? false;
    viewMode = value.getString('viewMode') ?? 'List View';
    fontSize = value.getDouble('fontSize') ?? 16.0;
  });

  //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]).then((value) => runApp(const MyApp()));
}

final ThemeManager themeManager = ThemeManager();

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    themeManager.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    themeManager.removeListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.blue,
      title: 'TODO - The Task Keeper',
      theme: lightTheme(context),
      darkTheme: darkTheme(context),
      themeMode: themeManager.themeMode,
      debugShowCheckedModeBanner: false,
      home: HomePage(index: -1),
    );
  }
}
