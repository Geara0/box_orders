import 'package:boxorders/router/router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ru')],
      path: "assets/translations",
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemStatusBarContrastEnforced: true,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top]);
}

final navigatorKey = GlobalKey<NavigatorState>();
const Color defaultColor = Colors.deepPurple;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
        builder: (ColorScheme? light, ColorScheme? dark) {
      ColorScheme lightColorScheme;
      ColorScheme darkColorScheme;
      var brightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;

      if (light != null && dark != null) {
        lightColorScheme = light.harmonized()..copyWith();
        darkColorScheme = dark.harmonized()..copyWith();
      } else {
        lightColorScheme = ColorScheme.fromSeed(seedColor: defaultColor);
        darkColorScheme = ColorScheme.fromSeed(
            seedColor: defaultColor, brightness: Brightness.dark);
      }
      return MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: brightness == Brightness.dark
              ? darkColorScheme
              : lightColorScheme,
        ),
        routerConfig: router,
      );
    });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('hello'.tr()),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
