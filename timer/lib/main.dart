import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:timer/models/setting_model.dart';
import 'package:timer/run_timer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:timer/settings.dart';

import 'create_new_timer.dart';
import 'database.dart';
import 'models/timer.dart';

void main() {
  runApp(MyApp());
}

class ValueListenableBuilder2<A, B> extends StatelessWidget {
  ValueListenableBuilder2(
    this.first,
    this.second, {
    Key? key,
    required this.builder,
    required this.child,
  }) : super(key: key);

  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final Widget child;
  final Widget Function(BuildContext context, A a, B b, Widget child) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: first,
      builder: (_, a, __) {
        return ValueListenableBuilder<B>(
          valueListenable: second,
          builder: (context, b, __) {
            return builder(context, a, b, child);
          },
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.light);
  static final ValueNotifier<double> font1 = ValueNotifier(14.0);
  static final ValueNotifier<double> font2 = ValueNotifier(25.0);
  static final ValueNotifier<double> font3 = ValueNotifier(50.0);
  static final ValueNotifier<Locale> locale = ValueNotifier(Locale('ru'));

  @override
  Widget build(BuildContext context) {
    DBProvider.db.getAllSettings().then((value) {
      if (value.length == 0) {
        DBProvider.db.newSetting(SettingModel(id: 1, title: "dark", value: 1));
        DBProvider.db
            .newSetting(SettingModel(id: 2, title: "font1", value: 14));
        DBProvider.db
            .newSetting(SettingModel(id: 3, title: "font2", value: 25));
        DBProvider.db
            .newSetting(SettingModel(id: 4, title: "font3", value: 50));
        DBProvider.db.newSetting(SettingModel(id: 5, title: "lang", value: 1));
      }
      for (var item in value) {
        if (item.title == 'dark') {
          themeNotifier.value =
              item.value == 1 ? ThemeMode.dark : ThemeMode.light;
        } else if (item.title == 'font1')
          font1.value = item.value * 1.0;
        else if (item.title == 'font2')
          font2.value = item.value * 1.0;
        else if (item.title == 'font3')
          font3.value = item.value * 1.0;
        else if (item.title == 'lang')
          locale.value = item.value == 1 ? Locale('en') : Locale('ru');
      }
    });
    return ValueListenableBuilder2<ThemeMode, Locale>(
      themeNotifier,
      locale,
      builder: (context, themeValue, localeValue, __) {
        return MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en'),
            Locale('ru'),
          ],
          locale: localeValue,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeValue,
          home: new MyHomePage(),
        );
      },
      child: Container(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: Icon(MyApp.themeNotifier.value == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode),
              onPressed: () {
                DBProvider.db.updateSetting(SettingModel(
                    id: 1,
                    title: "dark",
                    value:
                        MyApp.themeNotifier.value == ThemeMode.light ? 1 : 0));
                MyApp.themeNotifier.value =
                    MyApp.themeNotifier.value == ThemeMode.light
                        ? ThemeMode.dark
                        : ThemeMode.light;
              }),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingPage()),
              ).then((value) => setState(() {}));
            },
            icon: Icon(Icons.settings),
          )
        ],
      ),
      body: FutureBuilder<List<MyTimer>>(
        future: DBProvider.db.getAllTimers(),
        builder: (BuildContext context, AsyncSnapshot<List<MyTimer>> snapshot) {
          if (snapshot.hasData) {
            return new ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                MyTimer item = snapshot.data![index];
                return Container(
                  color: Color(item.scolor),
                  child: ListTile(
                      title: ValueListenableBuilder<double>(
                          valueListenable: MyApp.font1,
                          builder: (_, double font, __) {
                            return Text(item.title,
                                style: TextStyle(
                                    backgroundColor: Color(item.scolor),
                                    fontSize: font));
                          }),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RunTimerPage(
                                          title:
                                              AppLocalizations.of(context)!.run,
                                          id: item.id,
                                        )),
                              ).then((value) => setState(() {}));
                            },
                            child: Icon(Icons.play_arrow_rounded),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NewTimer(
                                          title: AppLocalizations.of(context)!
                                              .editTimers,
                                          id: item.id,
                                        )),
                              ).then((value) => setState(() {}));
                            },
                            child: Icon(Icons.edit),
                          )
                        ],
                      )),
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var timer = new MyTimer(
              id: 1,
              title: "title",
              phaseDelay: 5,
              repeatDelay: 10,
              repeat: 1,
              scolor: Colors.blue[800]!.value,
              mcolor: Colors.blue.value);
          DBProvider.db.newTimer(timer).then((id) => setState(() {}));
        },
        tooltip: 'add timer',
        child: Icon(Icons.add),
      ),
    );
  }
}
